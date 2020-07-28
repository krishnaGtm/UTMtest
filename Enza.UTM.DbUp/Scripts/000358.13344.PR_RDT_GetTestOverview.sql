/*
=========Changes====================
Changed By			DATE				Description

Krishna Gautam		2020-07-15			#11251: Calculation of total plates used for DNA marker issue fixed.	

========Example=============
EXEC PR_RDT_GetTestOverview null, 'ON,TO','','',1,211
*/

ALTER PROCEDURE [dbo].[PR_RDT_GetTestOverview]
(
    @Active	BIT  = NULL,
	@Crops NVARCHAR(MAX),
	@Filter NVARCHAR(MAX),
	@Sort NVARCHAR(MAX),
	@Page INT,
	@PageSize INT
)
AS BEGIN
    SET NOCOUNT ON;

    DECLARE @Query NVARCHAR(MAX), @Offset INT,@CropCodes NVARCHAR(MAX);

    CREATE TABLE #Status(StatusCode INT, StatusName NVARCHAR(50));

    INSERT #Status(StatusCode, StatusName)
    SELECT StatusCode, StatusName
    FROM [Status]
    WHERE StatusTable = 'Test';
    IF(@Active IS NOT NULL AND @Active = 0) BEGIN
	   DELETE #Status WHERE StatusCode <> 700;
    END
    ELSE IF (@Active IS NOT NULL AND @Active = 1) BEGIN
	   DELETE #Status WHERE StatusCode = 700;	   
    END

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
							SELECT T.TestID, T.TestTypeID, Crop = F.CropCode, [BreedingStation] = T.BreedingStationCode ,[Test] = T.TestName,
							T.PlannedDate, T1.ExpectedDate, [Status] = Stat.StatusName, 
							T1.UsedMarkers,
							T.StatusCode
							FROM Test T
							JOIN [File] F ON F.FileID = T.FileID
							JOIN #Status Stat ON Stat.StatusCode = T.StatusCode
							JOIN
							(
								SELECT 
									TestID, 
									ExpectedDate = MAX(ExpectedDate),
									UsedMarkers = COUNT(DISTINCT DeterminationID)
								FROM TestMaterialDetermination
								GROUP BY TestID
							) T1 ON T.TestID = T1.TestID
							WHERE T.TestTypeID = 8 AND F.CropCode IN  ('+@CropCodes +') AND T.CreationDate >= DATEADD(YEAR,-1,GetDate())
						) T1 '+@Filter+'
					), COUNT_CTE AS (SELECT COUNT(TestID) AS TotalRows FROM CTE)
					SELECT CTE.*,
					Count_CTE.[TotalRows] FROM CTE,COUNT_CTE
					ORDER BY CTE.PlannedDate DESC
					OFFSET '+CAST(@offset AS varchar(MAX))+' ROWS
					FETCH NEXT '+CAST (@pageSize AS VARCHAR(MAX))+' ROWS ONLY
					--OPTION (USE HINT ( ''FORCE_LEGACY_CARDINALITY_ESTIMATION'' ))
					'
	
	EXEC sp_executesql @Query;

END
