/****** Object:  StoredProcedure [dbo].[PR_S2S_CreateCapacitySlot]    Script Date: 5/24/2019 2:28:10 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_S2S_CreateCapacitySlot]
GO

CREATE PROCEDURE [dbo].[PR_S2S_CreateCapacitySlot]
(
	@TVPCapacityS2S TVPCapacityS2s READONLY
) AS BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

		MERGE INTO S2SCapacitySlot T
		USING @TVPCapacityS2S S 
		ON T.CapacitySLotID = S.CapacitySlotID
		WHEN MATCHED THEN
			UPDATE
			SET T.MaxPlants = S.MaxPlants,
				T.CapacitySlotName = S.CapacitySlotName,
				T.CordysStatus = S.CordysStatus,
				T.AvailPlants = S.AvailPlants,
				T.DH0Location = S.DH0Location
		WHEN NOT MATCHED THEN
			INSERT (CapacitySlotID, CapacitySlotName, MaxPlants, CordysStatus, DH0Location, AvailPlants)
			VALUES (S.CapacitySlotID, S.CapacitySlotName, S.MaxPlants, S.CordysStatus, S.DH0Location, S.AvailPlants);

	COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH
END
GO


