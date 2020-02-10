
ALTER PROCEDURE [dbo].[PR_Delete_Test]
(
	@TestID INT,
	@Status INT OUT,
	@PlatePlanName NVARCHAR(MAX) OUT
)
AS BEGIN
	DECLARE @FileID INT;
	DECLARE @TestType NVARCHAR(50),@RequiredPlates BIT,@DeterminationRequired BIT;
	IF NOT EXISTS(SELECT TestID FROM Test WHERE TestID = @TestID) BEGIN
		EXEC PR_ThrowError 'Invalid test.';
		RETURN;
	END

	SELECT 
		@Status = ISNULL(T.StatusCode,0),
		@PlatePlanName = ISNULL(T.LabPlatePlanName,''),
		@FileID = ISNULL(T.FileID,0),
		@TestType = TT.TestTypeCode,
		@RequiredPlates = CASE WHEN ISNULL(TT.PlateTypeID,0) = 0 THEN 0 ELSE 1 END,
		@DeterminationRequired = CASE WHEN ISNULL(TT.DeterminationRequired,0) = 0 THEN 0 ELSE 1 END
	FROM Test T 
	JOIN TestType TT ON TT.TestTypeID = T.TestTypeID
	WHERE T.TestID = @TestID;

	IF(@Status > 400) BEGIN
		EXEC PR_ThrowError 'Cannot delete test which is sent to LIMS.';
		RETURN;
	END
	
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
		
		IF(@TestType = 'C&T') BEGIN

			WHILE 1 =1
			BEGIN
				DELETE TOP (5000) I
				FROM CnTInfo I
				JOIN [Row] R ON R.RowID = I.RowID
				JOIN [File] F ON F.FileID = R.FileID
				JOIN Test T ON T.FileID = F.FileID
				WHERE T.TestID = @TestID;

				IF @@ROWCOUNT < 5000
				BREAK;
			END
		END
		
		IF(@RequiredPlates = 1)
		BEGIN			
			--delete from well
			DELETE W
			FROM Well W 
			JOIN Plate P ON P.PlateID = W.PlateID
			WHERE P.TestID = @TestID;

			--delete from Plate
			DELETE Plate WHERE TestID = @TestID;
		END
		--delete from slottest
		DELETE SlotTest WHERE TestID = @TestID;

		--delete from testmaterialdetermination
		IF(@DeterminationRequired = 1)
		BEGIN
			
			WHILE 1=1
			BEGIN
				DELETE TOP (5000) TestMaterialDetermination WHERE TestID = @TestID				
				IF @@ROWCOUNT < 5000
				BREAK;
			END

			
		END
		
		IF(@TestType = 'S2S')
		BEGIN
			--delete Donor info for S2S 
			
			WHILE 1=1
			BEGIN
				DELETE TOP (5000) SD 
				FROM Test T 
				JOIN [Row] R ON R.FileID = T.FileID
				JOIN S2SDonorInfo SD ON SD.RowID = R.RowID
				WHERE T.TestID = @TestID

				IF @@ROWCOUNT < 5000
				BREAK;
			END
			
						
			WHILE 1=1
			BEGIN
				--delete marker score
				DELETE TOP(5000) FROM S2SDonorMarkerScore WHERE TestID = @TestID

				IF @@ROWCOUNT < 5000
				BREAK;
			END

			
		END
		--delete test
		DELETE Test WHERE TestID = @TestID


		WHILE 1= 1 
		BEGIN
			--delete cell
			DELETE TOP (5000) C FROM Cell C 
			JOIN [Row] R ON R.RowID = C.RowID
			WHERE R.FileID = @FileID
			
			IF @@ROWCOUNT < 5000
			BREAK;
		END
		--delete column
		DELETE [Column] WHERE FileID = @FileID

		--delete row
		DELETE [Row] WHERE FileID = @FileID

		--delete file
		DELETE [File] WHERE FileID = @FileID

		COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK;
		THROW;
	END CATCH


	
END
