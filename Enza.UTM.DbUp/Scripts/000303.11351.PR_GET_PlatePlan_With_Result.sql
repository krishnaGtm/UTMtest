
DROP PROCEDURE IF EXISTS [dbo].[PR_GET_PlatePlan_With_Result]
GO

/*
	Author					Date			Description
-------------------------------------------------------------------
	Krishna Gautam			2020-03-12		#11351: Created Stored procedure to show results to excel
-------------------------------------------------------------------
==============================Example==============================
EXEC PR_GET_PlatePlan_With_Result 5575
*/
CREATE PROCEDURE [dbo].[PR_GET_PlatePlan_With_Result]
(
	@TestID INT
)
AS BEGIN

	DECLARE @StatusCode INT, @FileID INT,@ColumnID INT, @ImportLabel NVARCHAR(20),@ColumnName NVARCHAR(100),@ColID NVARCHAR(MAX);
	DECLARE @Query NVARCHAR(MAX), @PivotQuery NVARCHAR(MAX);
	DECLARE @DeterminationsIDS NVARCHAR(MAX), @DeterminationsName NVARCHAR(MAX);
	DECLARE @DeterminationTable TABLE(DeterminationID INT, DeterminationName NVARCHAR(MAX));

	IF NOT EXISTS (SELECT * FROM Test WHERE TestID = @TestID)
	BEGIN
		EXEC PR_ThrowError 'Invalid Test/PlatePlan.';
		RETURN;
	END

	SELECT @FileID = FileID,@ImportLabel = ImportLevel FROM Test where TestID = @TestID;

	IF(@ImportLabel = 'PLT')
	BEGIN
		SET @ColumnName = 'Plant Name';
	END
	ELSE
	BEGIN
		SET @ColumnName = 'Entry code';
	END

	SELECT @ColumnID = ColumnID,@ColID = QUOTENAME(ColumnID) FROM [Column] WHERE FileID = @FileID AND ColumLabel = @ColumnName;


	IF(ISNULL(@ColumnID,0) = 0)
	BEGIN
		EXEC PR_ThrowError 'Plant Name or Entry code Column not found.';
		RETURN;
	END

	--insert unique determination on table variable
	INSERT INTO @DeterminationTable(DeterminationID,DeterminationName)
	SELECT 
		D.DeterminationID, 
		MAX(D.DeterminationName) 
	FROM Plate P 
	JOIN Well W ON W.PlateID = W.PlateID
	JOIN TestResult TR ON TR.WellID = W.WellID
	JOIN Determination D ON D.DeterminationID = TR.DeterminationID
	GROUP BY D.DeterminationID


	SELECT 
		@DeterminationsName = COALESCE(@DeterminationsName +',','') + QUOTENAME(DeterminationID) + ' AS ' + QUOTENAME(DeterminationName),
		@DeterminationsIDS = COALESCE(@DeterminationsIDS +',','') + QUOTENAME(DeterminationID) 
	FROM @DeterminationTable;


	SELECT @StatusCode = StatusCode FROM Test WHERE TEstID =@TestID;
	IF(ISNULL(@StatusCode,0) <= 600)
	BEGIN
		EXEC PR_ThrowError 'Result is not available yet.';
		RETURN;
	END


	SET @PivotQuery = N'LEFT JOIN 
						(
							SELECT * FROM 
							(
								SELECT WellID,ObsValueChar,DeterminationID FROM TestResult 
							) SRC
							PIVOT
							(
								MAX(ObsValueChar)
								FOR DeterminationID IN ('+@DeterminationsIDS+')
							) PV

						) T2 ON T2.WellID = W.WellID';

	SET @DeterminationsName = ',' + @DeterminationsName;

	SET @Query = N'

	SELECT
		P.PlateName,
	    [Row] = LEFT(W.Position,1),
		Well = SUBSTRING(W.Position,2,2),
		' +QuoteName(@ColumnName)+ ' = T1.'+@ColID+'
		'+ISNULL(@DeterminationsName,'')+'
	FROM Test T
	JOIN [File] F ON F.FileID = T.FileID
	JOIN [Row] R ON R.FileID = F.FileID
	JOIN Plate P ON P.TestID = T.TestID
	JOIN Well W ON W.PlateID = P.PlateID
	JOIN Material M ON M.Materialkey = R.Materialkey
	JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID AND TMDW.MaterialID = M.MaterialID	
	LEFT JOIN
	(
		SELECT *  
		FROM 
		(
			SELECT FileID, RowID, ColumnID, [Value] FROM VW_IX_Cell VW
			WHERE VW.FileID = @FileID AND VW.ColumnID = @ColumnID
			AND ISNULL([Value], '''') <> ''''
			
		) SRC
		PIVOT
		(
			Max([Value])
			FOR ColumnID IN ('+@ColID+')
		) PV
	) T1 ON T1.RowID = R.RowID

	'+ISNULL(@PivotQuery,'')+'
	WHERE T.TestID = @TestID order by W.WellID';

	PRINT @QUERY;

	 EXEC sp_executesql @Query,N'@FileID INT, @TestID INT, @ColumnID INT ', @FileID, @TestID,@ColumnID;

	

END
GO


