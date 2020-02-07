/****** Object:  StoredProcedure [dbo].[PR_Get3GBMaterialsForUpload]    Script Date: 11/23/2018 10:37:17 AM ******/
DROP PROCEDURE if exists [dbo].[PR_Get3GBMaterialsForUpload]
GO

--EXEC PR_Get3GBMaterialsForUpload 2061;
CREATE PROCEDURE [dbo].[PR_Get3GBMaterialsForUpload]
(
	@TestID		INT
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @SQL NVARCHAR(MAX);
	DECLARE @Columns NVARCHAR(MAX);	
	DECLARE @ColumnIDs NVARCHAR(MAX);

	DECLARE @tbl TABLE(BreEZysAdministrationCode NVARCHAR(20), ThreeGBTaskID INT, PlantNumber NVARCHAR(100), BreedingProject NVARCHAR(10), PlantID NVARCHAR(50), Gen NVARCHAR(50));

	INSERT @tbl (BreEZysAdministrationCode, ThreeGBTaskID, PlantNumber, BreedingProject, PlantID, Gen)
	SELECT
		BreEZysAdministrationCode = CASE WHEN T.RequestingSystem = 'Phenome' THEN 'PH' ELSE 'NL' END,
		T.ThreeGBTaskID,
		PlantNumber = COALESCE(V1.[Plant name], V1.PlantNr),
		BreedingProject = T.BreedingStationCode,
		PlantID = R.MaterialKey,
		V1.Gen
	FROM [Row] R
	JOIN [File] F ON F.FileID = R.FileID
	JOIN Test T ON T.FileID = F.FileID
	LEFT JOIN
	(
		SELECT V2.MaterialKey, V2.[Plant name], V2.PlantNr, V2.Gen 
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
			WHERE C2.ColumLabel IN('Plant name', 'PlantNr', 'Gen')
			AND T.TestID = @TestID
		) V1
		PIVOT
		(
			Max(CellValue)
			FOR [ColumLabel] IN ([Plant name], [PlantNr], [Gen])
		) V2
	) V1 ON V1.MaterialKey = R.MaterialKey
	WHERE T.TestID = @TestID
	AND ISNULL(R.To3GB, 0) = 1;
	

	SELECT 
		V1.*,
		V2.TwoGBPlatePlanID,
		V2.TwoGBPlateNumber,
		V2.TwoGBRow,
		V2.TwoGBColumn,
		V2.TwoGBWeek,
		V2.MarkerName,
		V2.Result
	FROM @tbl V1
	LEFT JOIN
	(
		SELECT
			TwoGBPlatePlanID = T.LabPlatePlanName,
			TwoGBPlateNumber = P.PlateName,
			TwoGBRow =  LEFT(W.Position, 1),
			TwoGBColumn = RIGHT(W.Position, LEN(W.Position) - 1),
			TwoGBWeek = DATEPART(WEEK, T.ExpectedDate),
			MarkerName = D.DeterminationName,
			Result = TR.ObsValueChar,
			M.MaterialKey
			--P.PlateID,
			--,W.WellID,
			--TMD.DeterminationID	
		FROM [File] F
		JOIN Test T ON T.FileID = F.FileID
		JOIN [Row] R ON R.FileID = F.FileID
		JOIN Material M ON M.MaterialKey = R.MaterialKey
		JOIN Plate P ON P.TestID = T.TestID
		JOIN Well W ON W.PlateID = P.PlateID
		JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID AND TMDW.MaterialID = M.MaterialID
		JOIN TestMaterialDetermination TMD ON TMD.MaterialID = TMDW.MaterialID AND TMD.TestID = T.TestID
		JOIN Determination D ON D.DeterminationID = TMD.DeterminationID
		JOIN TestResult TR ON TR.DeterminationID = TMD.DeterminationID AND TR.WellID = W.WellID
		JOIN TestType TT ON TT.TestTypeID = T.TestTypeID
		WHERE TT.DeterminationRequired = 1 /*Get only determination required test types*/
		  AND T.StatusCode >= 600 /*Received*/
	) V2 ON V2.MaterialKey = V1.PlantID;	
END
GO



DROP PROCEDURE IF EXISTS [dbo].[PR_Save_SlotTest]
GO


CREATE PROCEDURE [dbo].[PR_Save_SlotTest]
(
	@TestID INT,
	--@UserID NVARCHAR(200),
	@SlotID INT
) AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnValue INT;
	--EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
	--IF(@ReturnValue <> 1) BEGIN
	--	RETURN;
	--END

	BEGIN TRY
		
		IF EXISTS(SELECT TestID FROM Test WHERE TestID = @TestID AND StatusCode >= 200) BEGIN
			EXEC PR_ThrowError 'Cannot change slot after request is sent to LIMS.';
			RETURN;		
		END
		IF(ISNULL(@SlotID,0)= 0) BEGIN
			EXEC PR_ThrowError 'Invalid slot.';
			RETURN;	
		END

		IF NOT EXISTS( 
			SELECT T.TestID--,s.SlotID, T.MaterialStateID,S.MaterialStateID,T.MaterialTypeID,S.MaterialTypeID,T.Isolated, S.Isolated,T.MaterialStateId, S.MaterialStateID
			 FROM [File] F 
			JOIN Test T ON T.FileID = F.FileID
			JOIN Slot S ON F.CropCode = S.CropCode 
			JOIN [Period] P ON P.PeriodID = S.PeriodID

			WHERE 
			F.CropCode = S.CropCode
			AND T.MaterialTypeID = S.MaterialTypeID
			AND T.Isolated = S.Isolated
			AND T.BreedingStationCode = S.BreedingStationCode			
			AND S.StatusCode = 200 
			AND T.TestID = @TestID 
			AND S.SlotID = @SlotID
			AND CAST(T.PlannedDate AS DATE) BETWEEN CAST(P.StartDate AS DATE) AND CAST(P.EndDate AS DATE)
			) BEGIN

			EXEC PR_ThrowError 'Cannot link slot to test. Please check property of test.';
			RETURN;		

		END

		BEGIN TRAN;			
			
			IF EXISTS(SELECT TestID FROM SlotTest WHERE TestID = @TestID) BEGIN
				IF ISNULL(@SlotID,0) =0 BEGIN
					DELETE FROM SlotTest Where TestID = @TestID
					UPDATE Test SET StatusCode = 100 WHERE TestID = @TestID;
				END
				ELSE BEGIN
					UPDATE SlotTest SET SlotID = @SlotID WHERE TestID = @TestID;
				END
			END
			ELSE BEGIN
				INSERT INTO SlotTest(SlotID, TestID)
				VALUES(@SlotID, @TestID)	
				--UPdate test status to 150 meaning status changed from created to slot consumed.
				EXEC PR_Update_TestStatus @TestID, 150;
			END			
			

		COMMIT TRAN;
		--Get test detail
		--EXEC PR_GetTestDetail @TestID, @UserID;
		EXEC PR_GetTestDetail @TestID
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK;
		THROW;
	END CATCH
END
GO




