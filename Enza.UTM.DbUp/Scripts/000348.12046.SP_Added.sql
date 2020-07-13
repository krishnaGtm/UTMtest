DROP PROCEDURE IF EXISTS [dbo].[PR_SaveTestMaterialDetermination_ForRDT]
GO

/*
Date			Author				Remarks
2020-07-13		Krishna Gautam		Stored procedure created

======================================Example=================================


*/

CREATE PROCEDURE [dbo].[PR_SaveTestMaterialDetermination_ForRDT]
(
	@TestTypeID							INT,
	@TestID								INT,
	@Columns							NVARCHAR(MAX) = NULL,
	@Filter								NVARCHAR(MAX) = NULL,
	@TVPTestWithExpDate TVP_TMD_WithDate	READONLY,
	@Determinations TVP_Determinations	READONLY
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @FileName NVARCHAR(100);
	DECLARE @Tbl TABLE (MaterialID INT, MaterialKey NVARCHAR(50));
	DECLARE @CropCode	NVARCHAR(10),@TestType1 INT,@StatusCode INT;
	DECLARE @FileID		INT;


	BEGIN TRY
		BEGIN TRANSACTION;
		SELECT 
			@FileID = F.FileID,
			@FileName = F.FileTitle,
			@CropCode = CropCode,
			@TestType1 = T.TestTypeID,
			@StatusCode = T.StatusCode
		FROM [File] F
		JOIN Test T ON T.FileID = F.FileID AND T.RequestingUser = F.UserID 
		WHERE T.TestID = @TestID --AND F.UserID = @UserID;

		IF(ISNULL(@FileName, '') = '') BEGIN
			EXEC PR_ThrowError 'Specified file not found';
			RETURN;
		END
		IF(ISNULL(@CropCode,'')='')
		BEGIN
			EXEC PR_ThrowError 'Specified crop not found';
			RETURN;
		END
		--Prevent changing testType when user choose different type of test after creating test.
		IF(ISNULL(@TestTypeID,0) <> ISNULL(@TestType1,0)) BEGIN
			EXEC PR_ThrowError 'Cannot assign different test type for already created test.';
			RETURN;
		END
		--Prevent asigning determination when status is changed to point of no return
		IF(ISNULL(@StatusCode,0) >=400) BEGIN
			EXEC PR_ThrowError 'Cannot assign determination for confirmed test.';
			RETURN;
		END

		IF EXISTS (SELECT 1 FROM @Determinations) BEGIN	
			EXEC  PR_SaveTestMaterialDeterminationWithQuery_ForRDT @FileID, @CropCode, @TestID, @Columns, @Filter, @Determinations
		END
		ELSE BEGIN
			EXEC PR_SaveTestMaterialDeterminationWithTVP_ForRDT @CropCode, @TestID, @TVPTestWithExpDate
		END

		IF EXISTS(SELECT TestID FROM Test WHERE StatusCode = 300 AND TestID = @TestID) BEGIN
			EXEC PR_Update_TestStatus @TestID, 350;
		END
		SELECT TestID, StatusCode 
		FROM Test WHERE TestID = @TestID;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		THROW;
	END CATCH	
END
GO


DROP PROCEDURE IF EXISTS [dbo].[PR_SaveTestMaterialDeterminationWithQuery_ForRDT]
GO


/*
Date				Author							Description
2020-07-13			Krishna Gautam					Stored procedure created

=================Example===============
DECLARE @T1 TVP_Determinations
INSERT INTO @T1 VALUES(1);
INSERT INTO @T1 VALUES(6);
PR_SaveTestMaterialDeterminationWithQuery_ForS2S 4052, 1, '''712'',''715'',''Lotnr''', '', @T1
*/

CREATE PROCEDURE [dbo].[PR_SaveTestMaterialDeterminationWithQuery_ForRDT]
(
	@FileID			INT,
	@CropCode		NVARCHAR(10),
	@TestID			INT,
	@Columns		NVARCHAR(MAX) = NULL,
	@Filter	NVARCHAR(MAX) = NULL,
	@Determinations TVP_Determinations READONLY
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @ColumnQuery	NVARCHAR(MAX);
	DECLARE @Query			NVARCHAR(MAX);
	DECLARE @FilterClause	NVARCHAR(MAX)
	DECLARE @ColumnIDs		NVARCHAR(MAX);
	DECLARE @SelectColumns	NVARCHAR(MAX);
	DECLARE @TraitIDs		NVARCHAR(MAX);
	DECLARE @Tbl			TABLE (MaterialID INT, MaterialKey NVARCHAR(50));
	DECLARE @ColumnTable	TABLE([ColumnID] INT, [ColumnName] NVARCHAR(100));
	DECLARE @MaterialTable	TABLE(MaterialKey NVARCHAR(100));


	IF(ISNULL(@Filter,'') <> '') BEGIN
		SET @FilterClause = ' AND '+ @Filter
	END
	ELSE BEGIN
		SET @FilterClause = '';
	END
	IF(ISNULL(@Columns,'') <> '') BEGIN
		SET @ColumnQuery = N'
			SELECT ColumnID,ColumnName 
			FROM 
			(
				SELECT ColumnID,COALESCE(CAST(TraitID AS NVARCHAR) ,ColumLabel,'''') as ColumnName FROM [COLUMN]
				WHERE FileID = @FileID 
			) AS T			
			WHERE ColumnName in ('+@Columns+');';

			--PRINT @ColumnQuery;

		INSERT INTO @ColumnTable ([ColumnID],[ColumnName])
		EXEC sp_executesql @ColumnQuery, N'@FileID INT', @FileID;
		
		SELECT 
			@SelectColumns  = COALESCE(@SelectColumns + ',', '') + QUOTENAME([ColumnID])+ ' AS ' + QUOTENAME([ColumnName]),
			@ColumnIDs = COALESCE(@ColumnIDs + ',', '') + QUOTENAME([ColumnID])
		FROM @ColumnTable
		
		SET @Query = N'		
		SELECT R.[MaterialKey]
		FROM [ROW] R		
		LEFT JOIN 
		(
			SELECT PT.[MaterialKey], PT.[RowNr], ' + @SelectColumns + ' 
			FROM
			(
				SELECT *
				FROM 
				(
					SELECT 
						T3.[MaterialKey],T3.RowNr,T1.[ColumnID], T1.[Value]
					FROM [Cell] T1
					JOIN [Column] T2 ON T1.ColumnID = T2.ColumnID
					JOIN [Row] T3 ON T3.RowID = T1.RowID
					JOIN [FILE] T4 ON T4.FileID = T3.FileID
					WHERE T2.FileID = @FileID
				) SRC
				PIVOT
				(
					Max([Value])
					FOR [ColumnID] IN (' + @ColumnIDs + ')
				) PIV
			) AS PT 					
		) AS T1	ON R.[MaterialKey] = T1.MaterialKey  				
			WHERE R.FileID = @FileID ' + @FilterClause + '';

		--PRINT @Query

		INSERT INTO @MaterialTable ([MaterialKey])		
		--EXEC sp_executesql @Query, N'@FileID INT, @UserID NVARCHAR(100)', @FileID,@UserID;
		EXEC sp_executesql @Query, N'@FileID INT', @FileID;
	END
	ELSE BEGIN 
		INSERT INTO @MaterialTable ([MaterialKey])
		SELECT R.[MaterialKey]
		FROM [ROW] R
		WHERE R.FileID = @FileID	
	END;

	INSERT INTO @Tbl (MaterialID , MaterialKey)
	SELECT M.MaterialID, M.MaterialKey 
	FROM Material M
	JOIN @MaterialTable M2 ON M2.MaterialKey = M.MaterialKey;

		
	MERGE INTO TestMaterialDetermination T
	USING 
	( 
		SELECT 
			M.MaterialID, D.DeterminationID 
		FROM @Tbl M 
		CROSS JOIN 
		(
			SELECT DeterminationID  
			FROM @Determinations 
			GROUP BY DeterminationID
		) D 
		
	) S
	ON T.MaterialID = S.MaterialID AND T.TestID = @TestID AND T.DeterminationID = S.DeterminationID
	WHEN NOT MATCHED THEN 
	INSERT(TestID,MaterialID,DeterminationID) VALUES(@TestID,S.MaterialID,s.DeterminationID);
		
END
GO

DROP PROCEDURE IF EXISTS [dbo].[PR_SaveTestMaterialDeterminationWithTVP_ForRDT]
GO

/*
Date				Author							Description
2020-07-13			Krishna Gautam					Stored procedure created

=================Example===============

*/



CREATE PROCEDURE [dbo].[PR_SaveTestMaterialDeterminationWithTVP_ForRDT]
(	
	@CropCode							NVARCHAR(15),
	@TestID								INT,	
	@TVP_TMD_WithDate TVP_TMD_WithDate	READONLY
) AS BEGIN
	SET NOCOUNT ON;	
	
	--insert or delete statement for merge
	MERGE INTO TestMaterialDetermination T 
	USING @TVP_TMD_WithDate S	
	ON T.MaterialID = S.MaterialID  AND T.DeterminationID = S.DeterminationID AND T.TestID = @TestID
	--This is done because front end may send null for selected value if no change is done on checkbox for determination 
	WHEN MATCHED AND ISNULL(S.Selected,1) = 1 AND ISNULL(T.ExpectedDate,'') != ISNULL(S.ExpectedDate,'')
		THEN UPDATE SET T.ExpectedDate = S.ExpectedDate		
	WHEN MATCHED AND ISNULL(S.Selected,1) = 0 
	THEN DELETE
	WHEN NOT MATCHED AND ISNULL(S.Selected,0) = 1 THEN 
	INSERT(TestID,MaterialID,DeterminationID,ExpectedDate) VALUES (@TestID,S.MaterialID,s.DeterminationID,S.ExpectedDate);

			
END

GO


