CREATE PROCEDURE PR_GetBreedingStation
AS BEGIN
	SELECT BreedingStationCode, BreedingStationName FROM BreedingStation
END


DROP PROCEDURE IF EXISTS [dbo].[PR_Delete_Material]
GO

DROP PROCEDURE IF EXISTS [dbo].[PR_Delete_EmptyORDeadMaterial]
GO

DROP PROCEDURE IF EXISTS [dbo].[PR_DeleteDeadMaterial]
GO