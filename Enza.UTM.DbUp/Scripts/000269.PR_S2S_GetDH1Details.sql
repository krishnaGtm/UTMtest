INSERT [Status](StatusID, StatusTable, StatusCode, StatusName, StatusDescription)
VALUES 
(34, 'RelationDonorDH0', 100, 'New', 'Proposed name received from Cordys'), 
(35, 'RelationDonorDH0', 200, 'DH1 Created', 'DH1 Created on Phenome'),
(36, 'RelationDonorDH0', 300, 'DH1 Info Sent', 'DH1 Information Sent to Cordys');
GO

DROP PROCEDURE IF EXISTS PR_S2S_GetDH1Details
GO
-- EXEC PR_S2S_GetDH1Details 5579
CREATE PROCEDURE PR_S2S_GetDH1Details
(
    @TestID INT
) AS BEGIN
SET NOCOUNT ON;
    SELECT
	   GID = RDH.DH1GID,
	   PlantNr = RDH.ProposedName,
	   MasterNr = RDH.DH1MasterNr,
	   SC.ResearchGroupID
    FROM RelationDonorDH0 RDH
    JOIN DHSyncConfig SC ON SC.CropCode = RDH.CropCode
    WHERE RDH.StatusCode = 200
    AND RDH.TestID = @TestID;
END
GO

DROP PROCEDURE IF EXISTS PR_S2S_Get_DHConfigSetting
GO

CREATE PROCEDURE [dbo].[PR_S2S_Get_DHConfigSetting]
    @StatusCode INT
AS 
BEGIN
	SELECT 
		CropCode = MAX(DH.CropCode),
		DHFieldSetID = MAX(DH.DHFieldSetID),
		ResearchGroupID = MAX(DH.ResearchGroupID),
		RD.TestID
	FROM DHSyncConfig DH
	JOIN RelationDonorDH0 RD ON DH.CropCode = RD.CropCode
	WHERE RD.StatusCode = @StatusCode
	GROUP BY RD.TestID;
	
END
GO

DROP PROCEDURE IF EXISTS PR_S2S_UpdateRelationDonorStatus
GO

CREATE PROCEDURE PR_S2S_UpdateRelationDonorStatus
(
    @TestID	 INT,
    @StatusCode INT
) AS BEGIN
    SET NOCOUNT ON;

    UPDATE RelationDonorDH0 SET
	   StatusCode = @StatusCode
    WHERE TestID = @TestID;
END
GO