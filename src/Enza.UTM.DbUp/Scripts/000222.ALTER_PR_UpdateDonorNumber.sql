
DROP PROCEDURE IF EXISTS [dbo].[PR_S2S_UpdateDonorNumber]
GO

CREATE PROCEDURE [dbo].[PR_S2S_UpdateDonorNumber]
(
	@TVP_DonerInfo TVP_DonerInfo READONLY,
	@TestID INT
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @FileID INT;

	BEGIN TRY
		BEGIN TRANSACTION;

		SELECT @FileID  = FileID FROM Test WHERE TestID = @TestID;

		--Update DonorNumber
		MERGE INTO S2SDonorInfo T
		USING
		(
			SELECT R.RowID, TVP1.DonorNumber FROM @TVP_DonerInfo TVP1
			JOIN Material M ON M.MaterialID = TVP1.MaterialID
			JOIN [Row] R ON R.MaterialKey = M.MaterialKey
			WHERE R.FileID = @FileID
		) S
		ON T.RowID = S.RowID
		WHEN MATCHED THEN
			UPDATE
			SET T.DonorNumber = S.DonorNumber;

		--Update Test status
		UPDATE Test
			SET StatusCode = 700
		WHERE TestID = @TestID

	COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH
END
GO


