/*
=========Changes====================
Changed By			DATE				Description
Krishna Gautam		2019-Mar-25			SP Created to get plateplanOverview on UTM
Krishna Gautam		2019-April-01		Add Crops parameter to provide data based on crops provided on user service
Krishna Gautam		2019-April-10		Show used plates and used marker for test.
Dibya Mani Suvedi	2019-July-15		Calculation of UsedMarkers fixed.

========Example=============
EXEC PR_Get_PlatePlanOverview 'ON,TO','','',1,211
*/

ALTER PROCEDURE [dbo].[PR_Get_PlatePlanOverview]
(
	@Crops NVARCHAR(MAX),
	@Filter NVARCHAR(MAX),
	@Sort NVARCHAR(MAX),
	@Page INT,
	@PageSize INT
)
AS BEGIN
	 
	DECLARE @Query NVARCHAR(MAX), @Offset INT,@CropCodes NVARCHAR(MAX), @DeadWellTypeID INT =0;

	SELECT @DeadWellTypeID = WellTypeID FROM WellType WHERE WellTypeName = 'D';

	 SELECT @CropCodes = COALESCE(@CropCodes + ',', '') + ''''+ T.[value] +'''' FROM 
		string_split(@Crops,',') T

	SET @Offset = @PageSize * (@Page -1);

	IF(ISNULL(@Filter,'')<> '') BEGIN
		SET @Filter = 'WHERE '+@Filter
	END
	ELSE
		SET @Filter = '';

	SET @Query =	N';WITH CTE AS 
					(
						SELECT * FROM 
						(
							SELECT T.TestID, Crop = F.CropCode, [BreedingStation] = T.BreedingStationCode ,[Test] = T.TestName, [PlatePlan] = T.LabPlatePlanName,
							S.SlotName,T.PlannedDate,T.ExpectedDate,[Status] = Stat.StatusName, 
							UsedPlates,UsedMarkers
							FROM Test T
							JOIN [File] F ON F.FileID = T.FileID
							JOIN SlotTest ST ON St.TestID = T.TestID
							JOIN Slot S ON S.SlotID = ST.SlotID
							JOIN [Status] Stat ON Stat.StatusCode = T.StatusCode
							LEFT JOIN 
							(
								SELECT 
								    V1.TestID,
								    UsedMarkers = SUM(V1.UsedMarkers),
								    UsedPlates = COUNT(V1.PlateID)
								FROM
								(
								    SELECT
									   T.TestID,
									   P.PlateID,
									   UsedMarkers = COUNT(DISTINCT TMD.DeterminationID)
								    FROM
								    (
									   SELECT 
										  TestID,
										  MaterialID,
										  DeterminationID = MAX(DeterminationID)
									   FROM TestMaterialDetermination 
									   GROUP BY TestID, MaterialID
								    ) TMD
								    JOIN Test T ON T.TestID = TMD.TestID
								    JOIN TestMaterialDeterminationWell TMDW ON TMDW.MaterialID = TMD.MaterialID
								    JOIN Well W ON W.WellID = TMDW.WellID
								    JOIN Plate P ON P.PlateID = W.PlateID AND P.TestID = T.TestID
								    GROUP BY T.TestID, P.PlateID
								) V1 GROUP BY V1.TestID
							) T2 ON T2.TestID = T.TestID
							WHERE F.CropCode IN  ('+@CropCodes +') AND T.CreationDate >= DATEADD(YEAR,-1,GetDate()) AND T.StatusCode >= 200 AND Stat.StatusTable = ''Test''
						) T1 '+@Filter+'
					), COUNT_CTE AS (SELECT COUNT(TestID) AS TotalRows FROM CTE)
					SELECT CTE.*,
					Count_CTE.[TotalRows] FROM CTE,COUNT_CTE
					ORDER BY CTE.PlannedDate DESC
					OFFSET '+CAST(@offset AS varchar(MAX))+' ROWS
					FETCH NEXT '+CAST (@pageSize AS VARCHAR(MAX))+' ROWS ONLY
					--OPTION (USE HINT ( ''FORCE_LEGACY_CARDINALITY_ESTIMATION'' ))
					'
	
	EXEC sp_executesql @Query, N'@DeadWellTypeID INT', @DeadWellTypeID;

END
GO