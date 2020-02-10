
/*
Author					Date				Description
KRISHNA GAUTAM			2019-May-20			Service created for geting material to upload to S2S on Cordys
KRISHNA GAUTAM			2019-Dec-10			DH0MakerTestNeeded is added on query
KRISHNA GAUTAM			2020-Jan-31			Fetch only donors that are not yet sent to cordys


=================Example===============
EXEC PR_S2S_GetDonorInfoForUpload 4542
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
		, ISNULL(V1.MasterNr, '') AS 'MasterNumber'
		, CAST (M.MaterialID AS NVARCHAR(50)) AS 'BreEysPKReference'
		, T.TestID AS 'BreEzysID'
		, CAST(M.RefExternal AS INT) AS 'BreEzRefCode'
		, M.BreedingStationCode AS 'BreedingStation'
		, ISNULL(DI.ProjectCode, '') AS 'Project'
		, ISNULL(DI.DonorNumber, '') AS 'DonorNumber'
		, ISNULL(V1.PlantNr,'') AS 'PlantNumber'
		, CAST (0 AS INT ) AS 'LotNumer'
		, DI.ToBeSown AS 'NrOfSeeds'
		, DI.Transplant AS 'NrOfPlannedTransplanted'
		, DI.DH0Net AS 'NrOfPlannedDHEmbryoRescueNett'
		, DI.Requested AS 'NrOfPlannedDHEmbryoRescueGross'
		, DH0MakerTestNeeded = CAST(CASE WHEN T1.MarkersCount > 0 THEN 1 ELSE 0 END AS BIT)
	FROM Test T 
	JOIN S2SCapacitySlot CS ON CS.CapacitySlotID = T.CapacitySlotID
	JOIn [File] F ON F.FileID = T.FileID
	JOIN [Row] R ON R.FileID = T.FileID
	JOIN Material M ON M.MaterialKey = R.MaterialKey
	JOIN S2SDonorInfo DI ON DI.RowID = R.RowID
	LEFT JOIN 
	(
		SELECT MaterialID,COUNT(MaterialID) AS MarkersCount FROM S2SDonorMarkerScore MS
		WHERE MS.TestID = @TestID GROUP BY MaterialID

	)T1 ON T1.MaterialID = M.MaterialID	
	LEFT JOIN 
	(
		SELECT V2.MaterialKey, V2.[MasterNr], V2.PlantNr
		FROM
		(
			SELECT 
				R.MaterialKey,
				C2.ColumLabel,
				CellValue = C.[Value]
			FROM [Cell] C
			JOIN [Column] C2 ON C2.ColumnID = C.ColumnID
			JOIN [Row] R ON R.RowID = C.RowID
			JOIN [File] F ON F.FileID = R.FileID
			JOIN Test T ON T.FileID = F.FileID
			WHERE 
			C2.ColumLabel IN('MasterNr', 'PlantNr') AND 
			T.TestID = @TestID
		) V1
		PIVOT
		(
			Max(CellValue)
			FOR [ColumLabel] IN ([MasterNr], [PlantNr])
		) V2
	) V1 ON V1.MaterialKey = M.MaterialKey
	WHERE T.TestID = @TestID AND R.Selected = 1 AND ISNULL(DI.DonorNumber,'') = ''

END

GO



/*
Author					Date				Description
Binod Gurung			2019-Aug-20			SP Created
KRISHNA GAUTAM			2020-Jan-31			Update status code to 700 if all donors have received donor number from cordys.

=================Example===============

*/
ALTER PROCEDURE [dbo].[PR_S2S_UpdateDonorNumber]
(
	@TVP_DonerInfo TVP_DonerInfo READONLY,
	@TestID INT
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @FileID INT;

	BEGIN TRY
		BEGIN TRANSACTION;

		SELECT @FileID  = FileID FROM Test WHERE TestID = @TestID;

		--Update DonorNumber
		MERGE INTO S2SDonorInfo T
		USING
		(
			SELECT R.RowID, TVP1.DonorNumber FROM @TVP_DonerInfo TVP1
			JOIN Material M ON M.MaterialID = TVP1.MaterialID
			JOIN [Row] R ON R.MaterialKey = M.MaterialKey
			WHERE R.FileID = @FileID
		) S
		ON T.RowID = S.RowID
		WHEN MATCHED THEN
			UPDATE
			SET T.DonorNumber = S.DonorNumber;

		--Update Test status
		IF NOT ExISTS(SELECT R.RowID FROM S2SDonorInfo DI JOIN [Row] R ON R.RowID = DI.RowID WHERE R.FileID = @FileID AND ISNULL(DI.DonorNumber,'') <> '' )
		BEGIN
			UPDATE Test
				SET StatusCode = 700
			WHERE TestID = @TestID
		END
		
	COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH
END
GO
