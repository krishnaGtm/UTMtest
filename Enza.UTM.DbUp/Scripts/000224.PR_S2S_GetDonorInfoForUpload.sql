/*
Author					Date				Description
KRISHNA GAUTAM			2019-May-20			Service created for geting material to upload to S2S on Cordys


=================Example===============
EXEC PR_S2S_GetDonorInfoForUpload 4389
*/
ALTER PROCEDURE [dbo].[PR_S2S_GetDonorInfoForUpload]
(
	@TestID INT
)
AS
BEGIN

	SELECT 
		F.CropCode
		, T.CapacitySlotID
		, CS.CapacitySlotName
		, 'MasterNr' AS 'MasterNumber' --needs to be changed
		, CAST (M.MaterialID AS NVARCHAR(50)) AS 'BreEysPKReference'
		, T.TestID AS 'BreEzysID'
		, CAST (0 AS INT ) AS 'BreEzRefCode' --needs to be changed
		, M.BreedingStationCode AS 'BreedingStation'
		, 'Project' AS 'Project' --needs to be changed
		, ISNULL(DI.DonorNumber, '') AS 'DonorNumber'
		, 'PlantNumber' AS 'PlantNumber' --needs to be changed
		, CAST (0 AS INT ) AS 'LotNumer' --needs to be changed
		, DI.ToBeSown AS 'NrOfSeeds'
		, DI.Transplant AS 'NrOfPlannedTransplanted'
		, DI.DH0Net AS 'NrOfPlannedDHEmbryoRescueNett'
		, DI.Requested AS 'NrOfPlannedDHEmbryoRescueGross'

	FROM Test T 
	JOIN S2SCapacitySlot CS ON CS.CapacitySlotID = T.CapacitySlotID
	JOIn [File] F ON F.FileID = T.FileID
	JOIN [Row] R ON R.FileID = T.FileID
	JOIN Material M ON M.MaterialKey = R.MaterialKey
	JOIN S2SDonorInfo DI ON DI.RowID = R.RowID
	WHERE T.TestID = @TestID AND R.Selected = 1

END