
/****** Object:  StoredProcedure [dbo].[PR_S2S_UpdateDonorNumber]    Script Date: 5/24/2019 2:49:58 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_S2S_UpdateDonorNumber]
GO

CREATE PROCEDURE [dbo].[PR_S2S_UpdateDonorNumber]
(
	@TVP_DonerInfo TVP_DonerInfo READONLY
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @TestID INT;

	BEGIN TRY
		BEGIN TRANSACTION;

		--Update DonorNumber
		MERGE INTO S2SDonorInfo T
		USING
		(
			SELECT R.RowID, TVP1.DonorNumber FROM @TVP_DonerInfo TVP1
			JOIN Material M ON M.MaterialID = TVP1.MaterialID
			JOIN [Row] R ON R.MaterialKey = M.MaterialKey
		) S
		ON T.RowID = S.RowID
		WHEN MATCHED THEN
			UPDATE
			SET T.DonorNumber = S.DonorNumber;

		--Update Test status
		UPDATE Test
			SET StatusCode = 700
		WHERE TestID IN 
		(
			SELECT TOP 1 TestID FROM Test T
			JOIN [Row] R ON R.FileID = T.FileID
			JOIN [Material] M ON M.MaterialKey = R.MaterialKey
			JOIN @TVP_DonerInfo TVP On TVP.MaterialID = M.MaterialID
		)

	COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH
END
GO


