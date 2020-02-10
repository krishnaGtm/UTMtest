DROP TYPE IF EXISTS TVP_DonerInfo
Go

CREATE TYPE TVP_DonerInfo AS TABLE
(
	MaterialID INT,
	DH0net INT,
	Requested INT,
	ToBeSown INT,
	Transplant INT
)
GO



/*
Author					Date				Description
KRISHNA GAUTAM			2019-Apr-23			Stored procedure created

=================Example===============

*/

ALTER PROCEDURE [dbo].[PR_SaveTestMaterialDeterminationWithTVP_ForS2S]
(	
	@CropCode		NVARCHAR(15),
	@TestID			INT,	
	@TVPM TVP_TMD_WithScore	READONLY,
	@TVP_DonerInfo	TVP_DonerInfo	READONLY
) AS BEGIN
	SET NOCOUNT ON;	
	DECLARE @Tbl TABLE (MaterialID INT, MaterialKey NVARCHAR(50));
	DECLARE @Tbl1 TABLE (MaterialID INT, MaterialKey NVARCHAR(50));

	INSERT INTO @Tbl (MaterialID, MaterialKey)
	SELECT M.MaterialID, M.MaterialKey
	FROM Material M
	JOIN
	(
		SELECT DISTINCT MaterialID 
		FROM @TVPM 
		--WHERE Selected = 1
	) M2 ON M2.MaterialID = M.MaterialID;

	--insert or delete statement for merge
	MERGE INTO S2SDonorMarkerScore T 
	USING 
	(
		SELECT T2.MaterialID,T1.DeterminationID,T1.Selected,T1.Score FROM @TVPM T1
		LEFT JOIN @Tbl T2 ON T1.MaterialID = T2.MaterialID			
	) S
	ON T.MaterialID = S.MaterialID  AND T.DeterminationID = S.DeterminationID AND T.TestID = @TestID
	--This is done because front end may send null for selected value if no change is done on checkbox for determination 
	WHEN MATCHED AND ISNULL(S.Selected,1) = 1 AND ISNULL(T.Score,'') != ISNULL(S.Score,'')
		THEN UPDATE SET T.Score = S.Score
		--This is done because front end may send null for selected value if no change is done on checkbox for determination 
	WHEN MATCHED AND ISNULL(S.Selected,1) = 0 
	THEN DELETE
	WHEN NOT MATCHED AND ISNULL(S.Selected,0) = 1 THEN 
	INSERT(TestID,MaterialID,DeterminationID,Score) VALUES (@TestID,S.MaterialID,s.DeterminationID,S.Score);

	--merge donerinfo table
	MERGE INTO S2SDonorInfo T 
	USING 
	(
		SELECT R.RowID,D.DH0Net,D.Requested,D.Transplant,D.ToBeSown FROM Test T
		JOIN [File] F ON F.FileID = T.FileID
		JOIN [Row] R ON R.FileID = F.FileID
		JOIN Material M ON M.MaterialKey = R.MaterialKey
		JOIN @TVP_DonerInfo D ON D.MaterialID = M.MaterialID
		WHERE T.TestID = @TestID
	) S
	ON T.RowID = S.RowID
	WHEN MATCHED
	THEN UPDATE SET T.DH0Net = ISNULL(S.DH0Net,T.DH0Net), T.Requested = ISNULL(S.Requested,T.Requested), T.Transplant = ISNULL(S.Transplant,T.Transplant), T.ToBeSown = ISNULL(S.ToBeSown,T.ToBeSown); 
		
END

Go
/*
Author					Date				Description
KRISHNA GAUTAM			2018-JAN-11			Save test material determination.

=================Example===============
EXEC [PR_GetDataWithMarkers] 48, 1, 200, '[700] LIKE ''v%'''
EXEC [PR_GetDataWithMarkers] 45, 1, 200, ''
EXEC [PR_GetDataWithMarkers1] 4260, 1, 1000, ''

=================Example===============

*/
ALTER PROCEDURE [dbo].[PR_SaveTestMaterialDetermination_ForS2S]
(
	@TestTypeID							INT,
	@TestID								INT,
	@Columns							NVARCHAR(MAX) = NULL,
	@Filter								NVARCHAR(MAX) = NULL,
	@TVPM TVP_TMD_WithScore				READONLY,	
	@Determinations TVP_Determinations	READONLY,
	@TVP_DonerInfo	TVP_DonerInfo		READONLY
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
			EXEC  PR_SaveTestMaterialDeterminationWithQuery_ForS2S @FileID, @CropCode, @TestID, @Columns, @Filter, @Determinations
		END
		ELSE BEGIN
			EXEC PR_SaveTestMaterialDeterminationWithTVP_ForS2S @CropCode, @TestID, @TVPM, @TVP_DonerInfo
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