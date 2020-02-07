
DROP PROCEDURE IF EXISTS [dbo].[PR_Delete_Test]
GO

CREATE PROCEDURE [dbo].[PR_Delete_Test]
(
	@TestID INT,
	@Status INT OUT,
	@PlatePlanName NVARCHAR(MAX) OUT
)
AS BEGIN
	DECLARE @FileID INT;
	IF NOT EXISTS(SELECT TestID FROM Test WHERE TestID = @TestID) BEGIN
		EXEC PR_ThrowError 'Invalid test.';
		RETURN;
	END

	SELECT 
		@Status = ISNULL(StatusCode,0),
		@PlatePlanName = ISNULL(LabPlatePlanName,''),
		@FileID = ISNULL(FileID,0) 
	FROM Test WHERE TestID = @TestID;

	IF(@Status > 400) BEGIN
		EXEC PR_ThrowError 'Cannot delete test which is sent to LIMS.';
		RETURN;
	END
	
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
		--DELETE FROM TestMaterialDeterminationWell
		DELETE TMDW
		FROM TestMaterialDeterminationWell TMDW
		JOIN Well W ON W.WellID = TMDW.WellID
		JOIN Plate P ON P.PlateID = W.PlateID
		WHERE P.TestID = @TestID;

		--delete from well
		DELETE W
		FROM Well W 
		JOIN Plate P ON P.PlateID = W.PlateID
		WHERE P.TestID = @TestID;

		--delete from Plate
		DELETE Plate WHERE TestID = @TestID;

		--delete from slottest
		DELETE SlotTest WHERE TestID = @TestID;

		--delete from testmaterialdetermination
		DELETE TestMaterialDetermination WHERE TestID = @TestID
		

		--delete test
		DELETE Test WHERE TestID = @TestID

		--delete cell
		DELETE C FROM Cell C 
		JOIN Row R ON R.RowID = C.RowID
		WHERE R.FileID = @FileID

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
GO
