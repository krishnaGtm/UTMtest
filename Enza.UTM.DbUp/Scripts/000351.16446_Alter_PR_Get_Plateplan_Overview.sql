DROP PROCEDURE IF EXISTS [dbo].[PR_Get_PlatePlanOverview]
GO

/*
=========Changes====================
Changed By			DATE				Description
Krishna Gautam		2019-Mar-25			SP Created to get plateplanOverview on UTM
Krishna Gautam		2019-April-01		Add Crops parameter to provide data based on crops provided on user service
Krishna Gautam		2019-April-10		Show used plates and used marker for test.
Dibya Mani Suvedi	2019-July-15		Calculation of UsedMarkers fixed.
Krishna Gautam		2020-03-12			#11251: Calculation of total plates used for DNA marker issue fixed.	
Binod Gurung		2020-11-27			#16446: Use same procedure for BTR type
========Example=============
EXEC PR_Get_PlatePlanOverview null, 1, 'ON,TO','','',1,211
*/

CREATE PROCEDURE [dbo].[PR_Get_PlatePlanOverview]
(
    @Active	BIT  = NULL,
	@BTR BIT,
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

	--SET @Crops = 'ON,TO';

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

	IF(ISNULL(@BTR,0) = 0)
	BEGIN

	SET @Query =	N';WITH CTE AS 
					(
						SELECT * FROM 
						(
							SELECT T.TestID, T.TestTypeID, Crop = F.CropCode, [BreedingStation] = T.BreedingStationCode ,[Test] = T.TestName, [PlatePlan] = T.LabPlatePlanName,
							S.SlotName,T.PlannedDate,T.ExpectedDate,[Status] = Stat.StatusName, 
							UsedPlates,UsedMarkers,
							T.StatusCode,
							RequestedMarkers = STUFF((SELECT DISTINCT '','', + CAST(D.DeterminationName AS NVARCHAR(50) )
										FROM
										Test TT 
										JOIN TestMaterialDetermination TMD On TMD.TestID = TT.TestID
										JOIN TestMaterialDeterminationWell TMDW ON TMD.MaterialID = TMDW.MaterialID
										JOIN Determination D ON D.DeterminationID = TMD.DeterminationID
										WHERE TT.TestID = T.TestID
										FOR XML PATH('''')
									),1,1,'''')
							FROM Test T
							JOIN [File] F ON F.FileID = T.FileID
							JOIN SlotTest ST ON St.TestID = T.TestID
							JOIN Slot S ON S.SlotID = ST.SlotID
							JOIN #Status Stat ON Stat.StatusCode = T.StatusCode
							LEFT JOIN 
							(
								SELECT 
								    V1.TestID,
								    UsedPlates = COUNT(V1.PlateID),
								    UsedMarkers = SUM(V1.UsedMarkers)
								FROM
								(
								    SELECT
									   P.TestID,
									   P.PlateID,
									   UsedMarkers = SUM(T1.UsedMarkers)
								    FROM
									Plate P 
									LEFT JOIN
								    (
									   SELECT 
										  P.TestID,
										  P.PlateID, 
										  UsedMarkers = COUNT(DISTINCT TMD.DeterminationID) 
									   FROM TestMaterialDeterminationWell TMDW
									   JOIN TestMaterialDetermination TMD ON TMD.MaterialID = TMDW.MaterialID
									   JOIN Well W ON W.WellID = TMDW.WellID
									   JOIN Plate P ON P.TestID = TMD.TestID AND P.PlateID = W.PlateID
									   JOIN Test T ON T.TestID = P.TestID
									   JOIN [File] F ON F.FileID = T.FileID
									   JOIN #Status S ON S.StatusCode = T.StatusCode
									   WHERE T.CreationDate >= DATEADD(YEAR, -1, GetDate())
									   AND T.StatusCode >= 200
									   AND F.CropCode IN ('+@CropCodes + N')
									   GROUP BY P.TestID, P.PlateID, TMD.DeterminationID
								    ) T1 ON T1.TestID = P.TestID AND P.PlateID = T1.PlateID
								    GROUP BY P.TestID, P.PlateID
								) V1 
								GROUP BY V1.TestID
							) T2 ON T2.TestID = T.TestID
							WHERE F.CropCode IN  ('+@CropCodes +') AND T.CreationDate >= DATEADD(YEAR,-1,GetDate()) AND T.StatusCode >= 200 AND ISNULL(T.BTR,0) = 0
						) T1 '+@Filter+'
					), COUNT_CTE AS (SELECT COUNT(TestID) AS TotalRows FROM CTE)
					SELECT CTE.*,
					Count_CTE.[TotalRows] FROM CTE,COUNT_CTE
					ORDER BY CTE.PlannedDate DESC
					OFFSET '+CAST(@offset AS varchar(MAX))+' ROWS
					FETCH NEXT '+CAST (@pageSize AS VARCHAR(MAX))+' ROWS ONLY
					--OPTION (USE HINT ( ''FORCE_LEGACY_CARDINALITY_ESTIMATION'' ))
					'
	
	END
	ELSE --BTR type
	BEGIN
		SET @Query =	N';WITH CTE AS 
					(
						SELECT * FROM 
						(
							SELECT T.TestID, T.TestTypeID, Crop = F.CropCode, [BreedingStation] = T.BreedingStationCode ,[Test] = T.TestName, 
								[PlatePlan] = T.LabPlatePlanName,
								S.SlotName,
								--T.PlannedDate,
								T.ExpectedDate,[Status] = Stat.StatusName, 
								UsedPlates,UsedMarkers,
								T.StatusCode,
								T.Researcher,
								T.Remark,
								RequestedMarkers = STUFF((SELECT DISTINCT '','', + CAST(D.DeterminationName AS NVARCHAR(50) )
										FROM
										Test TT 
										JOIN TestMaterialDetermination TMD On TMD.TestID = TT.TestID
										JOIN TestMaterialDeterminationWell TMDW ON TMD.MaterialID = TMDW.MaterialID
										JOIN Determination D ON D.DeterminationID = TMD.DeterminationID
										WHERE TT.TestID = T.TestID
										FOR XML PATH('''')
									),1,1,'''')
							FROM Test T
							JOIN [File] F ON F.FileID = T.FileID
							JOIN SlotTest ST ON St.TestID = T.TestID
							JOIN Slot S ON S.SlotID = ST.SlotID
							JOIN #Status Stat ON Stat.StatusCode = T.StatusCode
							LEFT JOIN 
							(
								SELECT 
								    V1.TestID,
								    UsedPlates = COUNT(V1.PlateID),
								    UsedMarkers = SUM(V1.UsedMarkers)
								FROM
								(
								    SELECT
									   P.TestID,
									   P.PlateID,
									   UsedMarkers = SUM(T1.UsedMarkers)
								    FROM
									Plate P 
									LEFT JOIN
								    (
									   SELECT 
										  P.TestID,
										  P.PlateID, 
										  UsedMarkers = COUNT(DISTINCT TMD.DeterminationID) 
									   FROM TestMaterialDeterminationWell TMDW
									   JOIN TestMaterialDetermination TMD ON TMD.MaterialID = TMDW.MaterialID
									   JOIN Well W ON W.WellID = TMDW.WellID
									   JOIN Plate P ON P.TestID = TMD.TestID AND P.PlateID = W.PlateID
									   JOIN Test T ON T.TestID = P.TestID
									   JOIN [File] F ON F.FileID = T.FileID
									   JOIN #Status S ON S.StatusCode = T.StatusCode
									   WHERE T.CreationDate >= DATEADD(YEAR, -1, GetDate())
									   AND T.StatusCode >= 200
									   AND F.CropCode IN ('+@CropCodes + N')
									   GROUP BY P.TestID, P.PlateID, TMD.DeterminationID
								    ) T1 ON T1.TestID = P.TestID AND P.PlateID = T1.PlateID
								    GROUP BY P.TestID, P.PlateID
								) V1 
								GROUP BY V1.TestID
							) T2 ON T2.TestID = T.TestID
							WHERE F.CropCode IN  ('+@CropCodes +') AND T.CreationDate >= DATEADD(YEAR,-3,GetDate()) AND T.StatusCode >= 200 AND ISNULL(T.BTR,0) = 1
						) T1 '+@Filter+'
					), COUNT_CTE AS (SELECT COUNT(TestID) AS TotalRows FROM CTE)
					SELECT CTE.*,
					Count_CTE.[TotalRows] FROM CTE,COUNT_CTE
					ORDER BY CTE.ExpectedDate DESC
					OFFSET '+CAST(@offset AS varchar(MAX))+' ROWS
					FETCH NEXT '+CAST (@pageSize AS VARCHAR(MAX))+' ROWS ONLY
					--OPTION (USE HINT ( ''FORCE_LEGACY_CARDINALITY_ESTIMATION'' ))
					'
	END

	EXEC sp_executesql @Query;

END
GO


