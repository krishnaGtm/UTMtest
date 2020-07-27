/*
Authror					Date				Description

Krishna Gautam		   2020-July-23			#15188: Updating status to completed (700) without donor number is not allowed.
=================Example===============

*/
ALTER PROCEDURE [dbo].[PR_S2S_UpdateDonorNumber]
(
	@TVP_DonerInfo TVP_DonerInfo READONLY,
	@TestID INT
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @FileID INT;
	DECLARE @UpdateToCompleted BIT = 1;

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

		
		SELECT TOP 1 @UpdateToCompleted = CASE WHEN  ISNULL(R.RowID,0) > 0 THEN 0 
												ELSE 1 END
			FROM S2SDonorInfo DI 
			JOIN [Row] R ON R.RowID = DI.RowID 
			WHERE R.FileID = @FileID AND ISNULL(DI.DonorNumber,'') = '' AND ISNULL(R.Selected,0) = 1;

		--Update Test status
		IF(@UpdateToCompleted = 1)
		BEGIN
			UPDATE Test
				SET StatusCode = 700
			WHERE TestID = @TestID
		END

	COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH
END

GO

