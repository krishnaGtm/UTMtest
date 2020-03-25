
DROP PROCEDURE IF EXISTS [dbo].[PR_GET_Test_With_Plate_And_Well]
GO


/*
	Author					Date			Description
-------------------------------------------------------------------
	Krishna Gautam			2020-03-16		#11243: Created Stored procedure to test detail in excel
-------------------------------------------------------------------
==============================Example==============================
EXEC PR_GET_Test_With_Plate_And_Well 5575
*/

CREATE PROCEDURE [dbo].[PR_GET_Test_With_Plate_And_Well]
(
	@TestID INT
)
AS BEGIN

	DECLARE @StatusCode INT, @FileID INT,@ColumnID INT, @ImportLabel NVARCHAR(20),@ColumnName NVARCHAR(100),@ColID NVARCHAR(MAX);
	DECLARE @Query NVARCHAR(MAX);
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


	SET @Query = N'
		SELECT			
			' +QuoteName(ISNULL(@ColumnName,''))+ ' = T1.'+@ColID+',
			P.PlateName,
			[Row] = LEFT(W.Position,1),
			Well = CAST(SUBSTRING(W.Position,2,2) AS INT)
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

		)T1 ON R.RowID = T1.RowID
		WHERE T.TestID = @TestID order by W.WellID'


	EXEC sp_executesql @Query,N'@FileID INT, @TestID INT, @ColumnID INT ', @FileID, @TestID,@ColumnID;
END
GO


