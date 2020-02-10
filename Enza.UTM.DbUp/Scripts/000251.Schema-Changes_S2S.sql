
DROP TABLE IF EXiSTS [dbo].[DHSyncConfig]
GO
CREATE TABLE [dbo].[DHSyncConfig](
	[ID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[DH0FieldSetID] [int],
	[ResearchGroupID] [int],
	[CropCode] [nvarchar](max)
)
GO


DROP PROCEDURE IF EXISTS [dbo].[PR_S2S_Get_DHConfigSetting]
GO
CREATE PROCEDURE [dbo].[PR_S2S_Get_DHConfigSetting]
AS 
BEGIN
	SELECT 
		CropCode = MAX(DH.CropCode),
		DH0GermplasmSetID = MAX(DH.DH0FieldSetID),
		ResearchGroupID = MAX(DH.ResearchGroupID),
		RD.TestID
	FROM DHSyncConfig DH
	JOIN RelationDonorDH0 RD ON DH.CropCode = RD.CropCode
	WHERE RD.StatusCode = 100
	GROUP BY RD.TestID;
	
END
Go



DROP PROCEDURE IF EXISTS [PR_S2S_GET_DH_ToCreate]
GO

CREATE PROCEDURE [dbo].[PR_S2S_GET_DH_ToCreate]
(
	@TestID INT
)

AS 
BEGIN
	
	SELECT M.MaterialKey,RD.ProposedName,DI.DonorNumber,M.RefExternal,FieldEntiryType = CASE WHEN T.ImportLevel = 'PLT' THEN '2' ELSE '1' END
	FROM Test T 
	JOIN [File]  F ON F.FileID = T.FileID
	JOIN [Row] R ON R.FileID = F.FileID
	JOIN S2SDonorInfo DI ON DI.RowID = R.RowID
	JOIN Material M ON M.MaterialKey = R.MaterialKey
	JOIN RelationDonorDH0 RD ON RD.MaterialID = M.MaterialID AND RD.TestID = T.TestID
	WHERE RD.TestID = @TestID AND RD.StatusCode = 100;
END
GO




DROP PROCEDURE IF EXISTS [dbo].[PR_S2S_Save_DH_GIDs]
GO

CREATE PROCEDURE [dbo].[PR_S2S_Save_DH_GIDs]
(
	@Json  NVARCHAR(MAX)
)
AS 
BEGIN
	
	MERGE INTO RelationDonorDH0 T
	USING
	(
		SELECT DH0GID,DH1GID,ProposedName
		FROM OPENJSON(@Json)
		WITH
		(
			DH0GID			INT '$.DH0GID',
			DH1GID			INT '$.DH1GID',
			ProposedName NVARCHAR(MAX) '$.ProposedName'
		) AS JsonValues
	) S
	ON T.ProposedName = S.ProposedName
	WHEN MATCHED THEN
	UPDATE SET T.GID = S.DH0GID,T.DH1GID = S.DH1GID, T.StatusCode = 200;
END
GO
