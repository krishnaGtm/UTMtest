DROP TABLE IF EXISTS [dbo].[RelationDonorDH0]
GO

CREATE TABLE [dbo].[RelationDonorDH0](
	[RelationDonorID] [int] IDENTITY(1,1) NOT NULL,
	[MaterialID] [int] NULL,
	[CropCode] [nvarchar](10) NULL,
	[ProposedName] [nvarchar](100) NULL,
	[GID] [int] NULL,
	[DH1MasterNr] [nvarchar](100) NULL,
	[DH1GID] [int] NULL,
	[StatusCode] [int] NULL,
	[TestID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[RelationDonorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


DROP TABLE IF EXISTS [dbo].[DHSyncConfig]
GO


CREATE TABLE [dbo].[DHSyncConfig](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DHFieldSetID] [int] NULL,
	[ResearchGroupID] [int] NULL,
	[CropCode] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


DROP INDEX IF EXISTS [IX_ProposedName] ON [dbo].[RelationDonorDH0]
GO

CREATE NONCLUSTERED INDEX [IX_ProposedName] ON [dbo].[RelationDonorDH0]
(
	[ProposedName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

DROP INDEX IF EXISTS [IX_RelationDonorDH0_StatusCode] ON [dbo].[RelationDonorDH0]
GO

CREATE NONCLUSTERED INDEX [IX_RelationDonorDH0_StatusCode] ON [dbo].[RelationDonorDH0]
(
	[StatusCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO



DROP PROCEDURE IF EXISTS [dbo].[PR_S2S_StoreDH0Details]
GO

/****** Object:  StoredProcedure [dbo].[PR_S2S_StoreDH0Details]    Script Date: 11/22/2019 4:48:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
    DECLARE @DataAsJson NVARCHAR(MAX) = N'
    [
	    {
		    "TestID": 4463,
		    "MaterialID": 10295,
		    "DH0List": [
			    {
				    "ProposedName": "P1",
				    "Markers": [
					    {
						    "MarkerNumber": 695,
						    "Score": "0101"
					    },
					    {
						    "MarkerNumber": 740,
						    "Score": "0201"
					    }
				    ]
			    },
			    {
				    "ProposedName": "P2",
				    "Markers": [
					    {
						    "MarkerNumber": 88221,
						    "Score": "0102"
					    },
					    {
						    "MarkerNumber": 88222,
						    "Score": "0202"
					    }
				    ]
			    }
		    ]
	    }
    ]';
    EXEC PR_S2S_StoreDH0Details @DataAsJson;
*/
CREATE PROCEDURE [dbo].[PR_S2S_StoreDH0Details]
(
    @DataAsJson NVARCHAR(MAX)
) AS BEGIN
    SET NOCOUNT ON;

	DECLARE @IDs NVARCHAR(MAX);
    DECLARE @Tbl TABLE(TestID INT, MaterialID INT, ProposedName NVARCHAR(100), DeterminationID INT, Score NVARCHAR(20));

	BEGIN TRY
		BEGIN TRANSACTION;
				
				INSERT INTO @Tbl(TestID, MaterialID, ProposedName, DeterminationID, Score)
				SELECT T1.TestID, T1.MaterialID, T2.ProposedName, T3.DeterminationID, T3.Score
				FROM OPENJSON(@DataAsJson) WITH
				(
				   TestID		INT,
				   MaterialID	INT,
				   DH0List	NVARCHAR(MAX) AS JSON	  
				) T1
				OUTER APPLY OPENJSON(T1.DH0List) WITH
				(
				   ProposedName    NVARCHAR(100),
				   Markers	    NVARCHAR(MAX) AS JSON
				) T2
				OUTER APPLY OPENJSON(T2.Markers) WITH
				(
				   DeterminationID	   INT '$.MarkerNumber',
				   Score			   NVARCHAR(100)
				) T3;

				--TestID validation
				SELECT DISTINCT
				   @IDs = COALESCE(@IDs + ',', '') + CAST(T.TestID AS NVARCHAR(20))
				FROM @Tbl T
				LEFT JOIN Test T2 ON T2.TestID = T.TestID
				WHERE T2.TestID IS NULL;

				IF(ISNULL(@IDs, '') <> '') BEGIN
				   SET @IDs = N'Invalid Test ID(s): ' + @IDs;
				   EXEC PR_ThrowError @IDs;
				   RETURN;
				END

				--MaterialID validation
				SET @IDs = NULL;
				SELECT DISTINCT
				   @IDs = COALESCE(@IDs + ',', '') + CAST(M.MaterialID AS NVARCHAR(20))
				FROM @Tbl M
				LEFT JOIN Material T ON T.MaterialID = M.MaterialID
				WHERE T.MaterialID IS NULL;;
    
				IF(ISNULL(@IDs, '') <> '') BEGIN
				   SET @IDs = N'Invalid Material ID(s): ' + @IDs;
				   EXEC PR_ThrowError @IDs;
				   RETURN;
				END

				--MarkerNumber validation
				SET @IDs = NULL;
				SELECT
				   @IDs = COALESCE(@IDs + ',', '') + CAST(M.DeterminationID AS NVARCHAR(20))
				FROM @Tbl M
				LEFT JOIN Determination D ON D.DeterminationID = M.DeterminationID
				WHERE D.DeterminationID IS NULL;  
    
				IF(ISNULL(@IDs, '') <> '') BEGIN
				   SET @IDs = N'Invalid Marker Number(s): ' + @IDs;
				   EXEC PR_ThrowError @IDs;
				   RETURN;
				END
    
				--Update RelationDonorDH0 table first
				MERGE RelationDonorDH0 T
				USING
				(
				   SELECT
					  TestID = MAX(T1.TestID), 
					  MaterialID = MAX(T1.MaterialID),
					  T1.ProposedName,
					  CropCode = MAX(F.CropCode)
				   FROM @Tbl T1
				   JOIN Test T ON T.TestID = T1.TestID
				   JOIN [File] F ON F.FileID = T.FileID
				   GROUP BY T1.ProposedName
				) S ON S.ProposedName = T.ProposedName
				WHEN NOT MATCHED THEN
				   INSERT(MaterialID, CropCode, ProposedName, StatusCode, TestID)
				   VALUES(S.MaterialID, S.CropCode, S.ProposedName, 100, S.TestID);

				--Update S2SDonorMarkerScore table
				MERGE S2SDonorMarkerScore T
				USING 
				(
				   SELECT DISTINCT
					  M.DeterminationID, 
					  M.Score,
					  M.TestID,
					  M.MaterialID,
					  R.RelationDonorID
				   FROM @Tbl M 
				   JOIN RelationDonorDH0 R ON R.ProposedName = M.ProposedName
				) S ON S.TestID = T.TestID 
				AND S.MaterialID = T.MaterialID 
				AND S.DeterminationID = T.DeterminationID 
				AND S.Score = T.Score
				AND S.RelationDonorID = T.RelationDonorID
				WHEN NOT MATCHED THEN
				   INSERT(TestID, MaterialID, DeterminationID, Score, RelationDonorID)
				   VALUES(S.TestID, S.MaterialID, S.DeterminationID, S.Score, S.RelationDonorID);

		COMMIT;

	END TRY
	BEGIN CATCH
		ROLLBACK;
		THROW;
	END CATCH

END
GO

DROP PROCEDURE IF EXISTS [dbo].[PR_S2S_Get_DHConfigSetting]
GO


CREATE PROCEDURE [dbo].[PR_S2S_Get_DHConfigSetting]

AS 
BEGIN
	SELECT 
		CropCode = MAX(DH.CropCode),
		DHFieldSetID = MAX(DH.DHFieldSetID),
		ResearchGroupID = MAX(DH.ResearchGroupID),
		RD.TestID
	FROM DHSyncConfig DH
	JOIN RelationDonorDH0 RD ON DH.CropCode = RD.CropCode
	WHERE RD.StatusCode = 100
	GROUP BY RD.TestID;
	
END
GO

DROP PROCEDURE IF EXISTS [dbo].[PR_S2S_GET_DH_ToCreate]
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
		SELECT DH0GID,DH1GID,ProposedName,DH1MasterNr
		FROM OPENJSON(@Json)
		WITH
		(
			DH0GID			INT '$.DH0GID',
			DH1GID			INT '$.DH1GID',
			ProposedName NVARCHAR(MAX) '$.ProposedName',
			DH1MasterNr	 NVARCHAR(MAX) '$.DH1MasterNr'
		) AS JsonValues
	) S
	ON T.ProposedName = S.ProposedName
	WHEN MATCHED THEN
	UPDATE SET 
		T.GID = S.DH0GID, 
		T.DH1GID = S.DH1GID, 
		T.DH1MasterNr = S.DH1MasterNr, 
		T.StatusCode = 200;


END
GO


