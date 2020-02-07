
/*
=========Changes====================
Changed By			DATE				Description
Krishna Gautam		2019-Mar-25			SP Created to get plateplanOverview on UTM
Krishna Gautam		2019-April-01		Add Crops parameter to provide data based on crops provided on user service

========Example=============
EXEC PR_Get_PlatePlanOverview 'ON,CF','','',3,2
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

	DECLARE @Query NVARCHAR(MAX), @Offset INT,@CropCodes NVARCHAR(MAX);

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
							SELECT T.TestID, Crop = F.CropCode, [BreedingStation] = T.BreedingStationCode ,[Test] = T.TestName, [PlatePlan] = T.LabPlatePlanName,S.SlotName,T.PlannedDate,T.ExpectedDate, [Status] = Stat.StatusName FROM Test T
							JOIN [File] F ON F.FileID = T.FileID
							JOIN SlotTest ST ON St.TestID = T.TestID
							JOIN Slot S ON S.SlotID = ST.SlotID
							JOIN [Status] Stat ON Stat.StatusCode = T.StatusCode
							WHERE F.CropCode IN  ('+ @CropCodes +') AND T.CreationDate >= DATEADD(YEAR,-1,GetDate()) AND T.StatusCode >= 200 AND Stat.StatusTable = ''Test''
						) T1 '+@Filter+'
					), COUNT_CTE AS (SELECT COUNT(TestID) AS TotalRows FROM CTE)
					SELECT CTE.*,
					Count_CTE.[TotalRows] FROM CTE,COUNT_CTE
					ORDER BY CTE.PlannedDate
					OFFSET '+CAST(@offset AS varchar(MAX))+' ROWS
					FETCH NEXT '+CAST (@pageSize AS VARCHAR(MAX))+' ROWS ONLY'
	
	EXEC sp_executesql @Query;

END
