/****** Object:  StoredProcedure [dbo].[PR_ValidateTest]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_ValidateTest]
GO
/****** Object:  StoredProcedure [dbo].[PR_Validate_Columns_Determination]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Validate_Columns_Determination]
GO
/****** Object:  StoredProcedure [dbo].[PR_UpdateAndVerifyTraitDeterminationResult]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_UpdateAndVerifyTraitDeterminationResult]
GO
/****** Object:  StoredProcedure [dbo].[PR_Update_TestStatus]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Update_TestStatus]
GO
/****** Object:  StoredProcedure [dbo].[PR_Update_Test]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Update_Test]
GO
/****** Object:  StoredProcedure [dbo].[PR_ThrowError]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_ThrowError]
GO
/****** Object:  StoredProcedure [dbo].[PR_SaveTraitDeterminationResult]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_SaveTraitDeterminationResult]
GO
/****** Object:  StoredProcedure [dbo].[PR_SaveTestMaterialDeterminationWithTVP]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_SaveTestMaterialDeterminationWithTVP]
GO
/****** Object:  StoredProcedure [dbo].[PR_SaveTestMaterialDeterminationWithQuery]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_SaveTestMaterialDeterminationWithQuery]
GO
/****** Object:  StoredProcedure [dbo].[PR_SaveTestMaterialDetermination]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_SaveTestMaterialDetermination]
GO
/****** Object:  StoredProcedure [dbo].[PR_SaveRemark]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_SaveRemark]
GO
/****** Object:  StoredProcedure [dbo].[PR_SavePlannedDate]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_SavePlannedDate]
GO
/****** Object:  StoredProcedure [dbo].[PR_Save_SlotTest]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Save_SlotTest]
GO
/****** Object:  StoredProcedure [dbo].[PR_Save_Score]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Save_Score]
GO
/****** Object:  StoredProcedure [dbo].[PR_Save_RelationTraitDetermination]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Save_RelationTraitDetermination]
GO
/****** Object:  StoredProcedure [dbo].[PR_Replicate_Material]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Replicate_Material]
GO
/****** Object:  StoredProcedure [dbo].[PR_ReorderMaterial]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_ReorderMaterial]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_UpdateCapacitySlot]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_UpdateCapacitySlot]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_Update_Slot_Period]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_Update_Slot_Period]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_SaveCapacity]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_SaveCapacity]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_Reserve_Capacity]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_Reserve_Capacity]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_RejectSlot]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_RejectSlot]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetSlotData]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_GetSlotData]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetPlanPeriods]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_GetPlanPeriods]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetPlannedOverview]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_GetPlannedOverview]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetPlanApprovalListForLAB]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_GetPlanApprovalListForLAB]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetPlanApprovalListBySlotForLAB]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_GetPlanApprovalListBySlotForLAB]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetPeriodDetail]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_GetPeriodDetail]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetMaterialTypePerCrop_Lookup]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_GetMaterialTypePerCrop_Lookup]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetCurrentPeriod]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_GetCurrentPeriod]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetCapacity]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_GetCapacity]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_Get_ReserveCapacity_LookUp]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_Get_ReserveCapacity_LookUp]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_Get_Avail_Plates_Tests]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_Get_Avail_Plates_Tests]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_ChangeSlot]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_ChangeSlot]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_ApproveSlot]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_ApproveSlot]
GO
/****** Object:  StoredProcedure [dbo].[PR_Insert_ExcelData]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Insert_ExcelData]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetWellPositionsLookup]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetWellPositionsLookup]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetTraitValues]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetTraitValues]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetTestsLookup]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetTestsLookup]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetTestInfoForLIMS]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetTestInfoForLIMS]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetTestDetail]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetTestDetail]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetStatusList]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetStatusList]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetSlot_ForTest]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetSlot_ForTest]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetPunchList]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetPunchList]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetPlatesForLims]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetPlatesForLims]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetPlateLabels]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetPlateLabels]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetPlantsLookup]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetPlantsLookup]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetNextAvailableWellPostion]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetNextAvailableWellPostion]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetMaxWellPostionCreated]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetMaxWellPostionCreated]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetMaterialWithMarker]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetMaterialWithMarker]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetDeterminations1]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetDeterminations1]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetDeterminations]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetDeterminations]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetDataWithMarkers]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetDataWithMarkers]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetCrop]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetCrop]
GO
/****** Object:  StoredProcedure [dbo].[PR_Get_WellType]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Get_WellType]
GO
/****** Object:  StoredProcedure [dbo].[PR_GET_Traits_All]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GET_Traits_All]
GO
/****** Object:  StoredProcedure [dbo].[PR_Get_TraitDeterminationResult]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Get_TraitDeterminationResult]
GO
/****** Object:  StoredProcedure [dbo].[PR_Get_RelationTraitDetermination]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Get_RelationTraitDetermination]
GO
/****** Object:  StoredProcedure [dbo].[PR_Get_MaterialType]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Get_MaterialType]
GO
/****** Object:  StoredProcedure [dbo].[PR_Get_MaterialState]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Get_MaterialState]
GO
/****** Object:  StoredProcedure [dbo].[PR_Get_Files]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Get_Files]
GO
/****** Object:  StoredProcedure [dbo].[PR_GET_Determination_All]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GET_Determination_All]
GO
/****** Object:  StoredProcedure [dbo].[PR_GET_Data]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GET_Data]
GO
/****** Object:  StoredProcedure [dbo].[PR_Delete_Material]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Delete_Material]
GO
/****** Object:  StoredProcedure [dbo].[PR_Delete_EmptyORDeadMaterial]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Delete_EmptyORDeadMaterial]
GO
/****** Object:  StoredProcedure [dbo].[PR_CreatePlateAndWell]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_CreatePlateAndWell]
GO
/****** Object:  StoredProcedure [dbo].[PR_CalculatePlatesRequired]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_CalculatePlatesRequired]
GO
/****** Object:  StoredProcedure [dbo].[PR_AssignLIMSPlate]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_AssignLIMSPlate]
GO
/****** Object:  StoredProcedure [dbo].[PR_AssignFixedPlants]    Script Date: 7/23/2018 2:40:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_AssignFixedPlants]
GO
/****** Object:  StoredProcedure [dbo].[PR_AssignFixedPlants]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_AssignFixedPlants]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_AssignFixedPlants] AS' 
END
GO



/*
EXEC PR_AssignFixedPlants 109,203214,'A9'
EXEC PR_AssignFixedPlants 109,203300,'A8' -- FROM A4
EXEC PR_AssignFixedPlants 109,203299,'A5' --FROM A3
EXEC PR_AssignFixedPlants 38,5,'A5' --FROM A11
*/
ALTER PROCEDURE [dbo].[PR_AssignFixedPlants]
(
	@TestID INT,
	@Material INT,
	@Position NVARCHAR(5),
	@MaxPlates INT
	
)
AS BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
			IF(ISNULL(@TestID,0)=0) BEGIN
				EXEC PR_ThrowError 'Requested Test does not exist.';
				RETURN;
			END

			--check status for validation of changed column
			IF EXISTS(SELECT StatusCode FROM Test WHERE StatusCode >= 400 AND TestID = @TestID) BEGIN
				EXEC PR_ThrowError 'Cannot change status for this test.';
				RETURN;
			END

			IF EXISTS(SELECT TOP 1 W.WellID FROM Well W
			JOIN Plate P ON P.PlateID = W.PlateID
			JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
			WHERE P.TestID = @TestID AND WT.WellTypeName = 'F' AND W.Position = @Position) BEGIN
				EXEC PR_ThrowError 'Fixed positon cannot be completed. Well is already fixed';
				RETURN;
			END
			IF(ISNULL(@Material,0)=0) BEGIN
				EXEC PR_ThrowError 'Fixed positon cannot be completed. Invalid Material';
				RETURN;
			END

			IF EXISTS( SELECT TOP 1 W.WellID FROM WELL W
			JOIN Plate P ON P.PlateID = W.PlateID
			JOIN WellTYpe WT ON WT.WellTypeID = W.WellTypeID
			WHERE P.TestID = @TestID AND WT.WellTYpeName = 'D') BEGIN
				EXEC PR_ThrowError 'Fixed positon cannot be completed. Remove dead material(s) first.';
				RETURN;
			END

			DECLARE @FixedWellTypeID INT;
			SELECT @FixedWellTypeID = WellTypeID 
			FROM WellType WHERE WellTypeName ='F'; 

			IF EXISTS( SELECT TOP 1 TMDW.MaterialID FROM TestMaterialDeterminationWell TMDW 
			JOIN Well W ON W.WellID = TMDW.WellID
			JOIN Plate P ON P.PlateID = W.PlateID
			WHERE P.TestID = @TestID 
			GROUP BY TMDW.MaterialID, W.WellTypeID HAVING COUNT(TMDW.MaterialID) > 1 AND TMDW.MaterialID = @Material AND W.WellTypeID != @FixedWellTypeID) BEGIN
				EXEC PR_ThrowError 'Fixed positon cannot be completed. Replicated material cannot be assinged to fixed position.';
				RETURN;
			END
	
			DECLARE @WellPerRow INT =0,	
			@PlateID INT =0,
			@TotalPlatesRequired INT =0,
			@PlatesCreated INT =0,
			@Count INT =0,
			@TotalMaterialExceptFixed INT = 0,
			@MaterialCount INT =0,
			@MaterialID INT,
			@WellID INT,
			--@AvailableWellWithoutBlock INT = 0,
			@WellTypeID INT = 0,
			@FixedWellCount INT =0,
			@PlateIDLast INT,
			@LastPlateName NVARCHAR(200) = '',
			@EmptyWellType INT,
			@AssignedWellType INT

			DECLARE @NewPlateCreated BIT = 0;
			DECLARE @FixedOnlyMaterial TVP_TMDW, 
			@TempWellTable TVP_TempWellTable, @TempWellTable1 TVP_TempWellTable;
			DECLARE @MaterialExceptFixed TVP_Material,@TempInsertedWell TVP_Material,@MaterialAll TVP_Material,@Well TVP_Material,@MaterialWithWell TVP_TMDW;
		

			SELECT @FixedWellCount = COUNT(DISTINCT Position)
			FROM Well W 
			JOIN WellType WT ON WT.WellTypeId = W.WellTypeID
			JOIN Plate P ON P.PlateID = W.PlateID
			WHERE P.TestID = @TestID AND WT.WellTypeName = 'F';
			
			IF(ISNULL(@MaterialID,0)<>0 OR ISNULL(@Position,'')<>'') BEGIN	
				SET @FixedWellCount = @FixedWellCount +1;
				--DECLARE @T1 INT ;				
				EXEC PR_CalculatePlatesRequired @TestID,@FixedWellCount, @TotalPlatesRequired OUT;

				SELECT TOP 1 @PlateIDLast = PlateID
				FROM Plate P
				WHERE TestID = @TestID;

				SELECT @PlatesCreated = COUNT(PlateID)
				FROM Plate 
				WHERE TestID = @TestID;


				IF(@TotalPlatesRequired > @MaxPlates) BEGIN
					DECLARE @Error NVARCHAR(MAX) = 'Fixed position cannot be completed. Maximum of '+ CAST(@MaxPlates AS NVARCHAR(10)) + ' plates can be used for test. This requires more than ' + CAST(@MaxPlates AS NVARCHAR(10)) + ' plates.';
					EXEC PR_ThrowError @Error;
					RETURN;					
				END

				WHILE(@PlatesCreated < @TotalPlatesRequired) BEGIN
					IF EXISTS(SELECT StatusCode FROM Test WHERE StatusCode >= 200 AND TestID = @TestID) BEGIN
						EXEC PR_ThrowError 'Fixed positioin cannot be completed. This requires more plates than reserved on LIMS.';
						RETURN;
					END

					SELECT TOP 1 @LastPlateName =LEFT(PlateName, LEN(PlateName) -2) + RIGHT('000' + CAST((CAST(RIGHT(PlateName,2) AS INT) +1) AS NVARCHAR(5)),2)
					FROM Plate
					WHERE TestID = @TestID
					ORDER BY PlateID DESC

					INSERT INTO Plate ( PlateName,TestID)
					VALUES(@LastPlateName,@TestID);
						
					SELECT @PlateID = @@IDENTITY;

					INSERT INTO Well(WellTypeID,Position,PlateID)
					OUTPUT INSERTED.WellID INTO @TempInsertedWell(MaterialID) --inserted well is a material for this temptable
					SELECT WellTypeID,Position,@PlateID
					FROM Well W
					JOIN Plate P ON P.PlateID = W.PlateID
					WHERE P.PlateID = @PlateIDLast;

					SET @PlatesCreated = @PlatesCreated +1;					
						
				END
			END

			SELECT TOP 1 @PlateID = PlateID 
			FROM Plate
			WHERE TestID = @TestID
			ORDER BY PlateID;

			SELECT @WellPerRow = EndColumn 
			FROM PlateType PT
			JOIN TestType TT ON PT.PlateTypeID = TT.PlateTypeID
			JOIN Test T ON T.TestTypeId = TT.TestTypeID
			WHERE T.TestID = @TestID;
		
			SELECT @WellTypeID = WellTypeID
			FROM WellType
			WHERE WellTypeName = 'F'

			SELECT @EmptyWellType = WellTypeID
			FROM WellType
			WHERE WellTypeName = 'E'
			
			SELECT @AssignedWellType = WellTypeID
			FROM WellType
			WHERE WellTypeName = 'A'

			--SELECT @AvailableWellWithoutBlock = (CAST(ASCII(EndRow) AS INT) -64) * @WellPerRow
			--FROM PlateType PT
			--JOIN TestType TT ON PT.PlateTypeID = TT.PlateTypeID
			--JOIN Test T ON T.TestTypeId = TT.TestTypeID		
			--WHERE T.TestID = @TestID;

			--SELECT @AvailableWellWithoutBlock = @AvailableWellWithoutBlock - COUNT(WTP.WellTypePositionID)
			--FROM WellTypePosition WTP
			--JOIN WellType WT ON WT.WellTypeID = WTP.WellTypeID
			--JOIN Test T ON T.TestTypeId = WTP.TestTypeID		
			--WHERE T.TestID = @TestID AND WT.WellTypeName = 'B';

			INSERT INTO @TempWellTable(WellID)
			SELECT T.Position
			FROM 
			(
				SELECT W.*, CAST(RIGHT(Position,LEN(Position)-1) AS INT) AS Position1
				,LEFT(Position,1) as Position2
				FROM Well W
				JOIN Plate P ON P.PlateID = W.PlateID
				WHERE P.TestID = @TestID				
			) T
			ORDER BY PlateID,Position2,Position1

			--first select fixed position material for single palate which will be replicated for all paltes
			--Here wellID is treated as well position in integer number eg: A1 = 1,B1 = 13 H12= 92(Instead of 96) due to some blocked B1,D1,E1,H1
			INSERT INTO @FixedOnlyMaterial(MaterialID,WellID)
			SELECT MaterialID,TT.Nr +1 --1 is added because autoincrement field starts with seed 0.
			FROM 
			TestMaterialDeterminationWell TMDW 
			JOIN Well W ON W.WellID = TMDW.WellID
			JOIN Plate P ON P.PlateID = W.PlateID
			JOIN WellType WT ON Wt.WellTypeID = W.WellTypeID 
			JOIN @TempWellTable TT ON TT.WellID = W.Position
			WHERE P.PlateID = @PlateID AND WT.WellTypeName = 'F';-- OR W.Position = @Position)

			--this is included because of we cannot update wellid to fixed until we apply merge statement for TMDW table.
			INSERT INTO @FixedOnlyMaterial(MaterialID,WellID)
			SELECT @Material,Nr +1
			FROM @TempWellTable
			WHERE WellID = @Position;
			
			SET @Count = 0;

			INSERT INTO @MaterialExceptFixed (MaterialID)
			SELECT MaterialID
			FROM 
			(
				SELECT MaterialID
				,Position,Position2,Position1,PlateID
				FROM 
				(
					SELECT DISTINCT Position, MaterialID,W.PlateID,
					CAST(RIGHT(Position,LEN(Position)-1) AS INT) AS Position1, -- this is column number
					CAST(ASCII(LEFT(Position,1)) -65 AS INT) as Position2 -- this is row number
					FROM Well W
					JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID
					JOIN Plate P ON P.PlateID = W.PlateID
					JOIN WellType WT ON WT.WellTypeID = W.WellTypeID		
					WHERE P.TestID = @TestID AND  NOT EXISTS (	SELECT DISTINCT MaterialID 
																FROM @FixedOnlyMaterial 
																WHERE MaterialID = TMDW.MaterialID)
					
				) T
			) T1
			ORDER BY PlateID, Position2, Position1			
			
			SELECT @TotalMaterialExceptFixed = COUNT(MaterialID)
			FROM @MaterialExceptFixed			

			SET @Count = 1;
			WHILE(@Count <= @TotalMaterialExceptFixed) BEGIN
				WHILE EXISTS(SELECT WellID FROM @FixedOnlyMaterial WHERE WellID = @Count) BEGIN
					INSERT INTO @MaterialAll (MaterialID)
					SELECT MaterialID FROM @FixedOnlyMaterial WHERE WellID = @Count;
					--We update this value because next not fixed material will be inserted if consecutive fixed position found.
					UPDATE @FixedOnlyMaterial SET WellID = WellID -1;
				END
				INSERT INTO @MaterialAll(MaterialID)
				SELECT MaterialID FROM @MaterialExceptFixed WHERE RowNr = @Count
			
				SET @Count = @Count +1;
				IF(@Count > @TotalMaterialExceptFixed) BEGIN
					DECLARE @MaxWellID INT;
					SELECT @MaxWellID = MAX(WellID) FROM @FixedOnlyMaterial
					--THIS LOGIC IS USED TO MATCH RowNr from welltable  
					WHILE(@Count <= @MaxWellID ) BEGIN
						
						IF EXISTS(SELECT WellID FROM @FixedOnlyMaterial WHERE WellID = @Count) BEGIN
							INSERT INTO @MaterialAll (MaterialID)
							SELECT MaterialID FROM @FixedOnlyMaterial WHERE WellID = @Count;							
						END
						ELSE BEGIN
							INSERT INTO @MaterialAll (MaterialID)
							VALUES(-1);							
						END
						SET @Count = @Count +1;
					
					END
					
				END
			
			END
			
			INSERT INTO @Well(MaterialID)
			SELECT T.WellID
			FROM 
			(
				SELECT W.*, CAST(RIGHT(Position,LEN(Position)-1) AS INT) AS Position1
				,LEFT(Position,1) as Position2
				FROM Well W
				JOIN Plate P ON P.PlateID = W.PlateID
				WHERE P.TestID = @TestID				
			) T
			ORDER BY PlateID,Position2,Position1

			SET @Count = 1;
			SELECT @MaterialCount = COUNT(MaterialID)
			FROM @MaterialAll;
	
			INSERT INTO @MaterialWithWell(MaterialID,WellID)
			SELECT M.MaterialID,W.MaterialID
			FROM @Well W
			JOIN @MaterialAll M ON M.RowNr = W.RowNr
			AND M.MaterialID <> -1;

			--SELECT * FROM @MaterialWithWell T1
			--JOIN Well W ON W.WellID = T1.WellID

			--this update will update well with fixed 
			UPDATE W
			SET W.WellTypeID = @WellTypeID
			FROM Well W
			JOIN Plate P ON P.PlateID = W.PlateID
			WHERE P.TestID = @TestID AND W.Position = @Position;
			
			--this update is to find assigned and empty wells.
			UPDATE W
			SET W.WellTypeID = @EmptyWellType
			FROM Well W
			JOIN @Well W1 ON W1.MaterialID = W.WellID
			JOIN @MaterialAll M ON M.RowNr = W1.RowNr
			WHERE M.MaterialID = -1;
			

			UPDATE W
			SET W.WellTypeID = @EmptyWellType
			FROM Well W
			JOIN @Well W1 ON W1.MaterialID = W.WellID
			WHERE W1.RowNr > (SELECT MAX(RowNr) FROM  @MaterialAll)

			UPDATE W
			SET W.WellTypeID = @AssignedWellType
			FROM Well W
			JOIN @Well W1 ON W1.MaterialID = W.WellID
			JOIN @MaterialAll M ON M.RowNr = W1.RowNr
			WHERE M.MaterialID <> -1 AND W.WellTypeID <> @AssignedWellType AND W.WellTypeID <> @WellTypeID;

			MERGE TestMaterialDeterminationWell T
			USING @MaterialWithWell S
			ON T.WellID = S.WellID
			WHEN NOT MATCHED
			THEN INSERT (MaterialID,WellID)
			VALUES (S.MaterialID,S.WellID);

			MERGE TestMaterialDeterminationWell T
			USING @MaterialWithWell S
			ON T.WellID = S.WellID AND T.MaterialID <> S.MaterialID
			WHEN MATCHED
			THEN UPDATE SET T.MaterialID = S.MaterialID;
		COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK;
		THROW;
	END CATCH
END


GO
/****** Object:  StoredProcedure [dbo].[PR_AssignLIMSPlate]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_AssignLIMSPlate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_AssignLIMSPlate] AS' 
END
GO
/*
=================EXAMPLE=============
DECLARE @T1 TVP_Plates
INSERT INTO @T1(LIMSPlateID,LIMSPlateName)
VALUES(336,'abc'),(337,'bcd')
EXEC PR_AssignLIMSPlate 'KATHMANDU\krishna',44,'Test',44,@T1
*/
ALTER PROCEDURE [dbo].[PR_AssignLIMSPlate]
(
	@UserID		NVARCHAR(100),
	@LIMSPlateplanID		INT,
	@LIMSPlateplanName NVARCHAR(100),
	@TestID INT,
	@TVP_Plates TVP_Plates READONLY
) AS BEGIN

	SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @LabPlateTable TABLE
		(
			ID INT IDENTITY(1,1),
			LabID INT,
			LabPlateName NVARCHAR(100)
		);
		DECLARE @PlateTable TABLE
		(
			ID INT IDENTITY(1,1),
			PlateID INT,
			LabPlateID INT NULL,
			LabPlateName NVARCHAR(100)
		);

		INSERT INTO @LabPlateTable (LabID, LabPlateName)
		SELECT LIMSPlateID, LIMSPlateName
		FROM @TVP_Plates;

		INSERT INTO @PlateTable (PlateID)
		SELECT PlateID 
		FROM Plate
		WHERE TestID = @TestID;
		
		BEGIN TRANSACTION;
	
			UPDATE Test 
			SET LabPlatePlanID = @LIMSPlateplanID,
			LabPlatePlanName = @LIMSPlateplanName,
			StatusCode = 300
			WHERE TestID = @TestID;

			UPDATE PT SET 
				PT.LabPlateID = LPT.LabID,
				PT.LabPlateName = LPT.LabPlateName
			FROM @PlateTable PT
			JOIN @LabPlateTable LPT ON LPT.ID = PT.ID
	
			UPDATE P SET 
				P.LabPlateID = PT.LabPlateID,
				P.PlateName = PT.LabPlateName
			FROM Plate P 
			JOIN @PlateTable PT ON PT.PlateID = P.PlateID
			WHERE P.TestID = @TestID;

		COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[PR_CalculatePlatesRequired]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_CalculatePlatesRequired]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_CalculatePlatesRequired] AS' 
END
GO
/*
DECLARE @TOT INT;
EXEC PR_CalculatePlatesRequired 83,1, @TOT OUT
PRINT @TOT
*/

ALTER PROCEDURE [dbo].[PR_CalculatePlatesRequired]
(
	@TestID INT,
	--@WithFixed BIT,
	@FixedWellCount INT,
	@TotalPlatesRequired INT OUT
)
AS BEGIN
	SET NOCOUNT ON;
	DECLARE @TempWellTable TVP_TempWellTable;	
	DECLARE @StartRow VARCHAR(2);
	DECLARE @EndRow VARCHAR(2);
	DECLARE @StartColumn INT;
	DECLARE @EndColumn INT;
	DECLARE @RowCounter INT;
	DECLARE @ColumnCounter INT;
	DECLARE @TotalWellsPerPlate INT, @Cx INT =0, @FixedCount INT =0;

	SELECT @StartRow = UPPER(StartRow), @EndRow = UPPER(EndRow), @StartColumn = StartColumn,@EndColumn = EndColumn
	FROM PlateType PT
	JOIN TestType TT ON TT.PlateTypeID = PT.PlateTypeID
	JOIN Test T ON T.TestTypeID = TT.TestTypeID
	WHERE T.TestID = @TestID;
		
	SET @RowCounter=Ascii(@StartRow)
	WHILE @RowCounter<=Ascii(@EndRow)	BEGIN
		SET @ColumnCounter = @StartColumn;
		WHILE(@ColumnCounter <= @EndColumn) BEGIN							
			INSERT INTO @TempWellTable(WellID)
				VALUES(CHAR(@RowCounter)+RIGHT('00'+CAST(@ColumnCounter AS VARCHAR),2))--CAST(@ColumnCounter AS VARCHAR))
			SET @ColumnCounter = @ColumnCounter +1;
		END
		SET @RowCounter=@RowCounter+1
	END

	DELETE TT 
	FROM @TempWellTable TT
	JOIN WellTYpePosition WTP ON WTP.PositionOnPlate = TT.WellID
	JOIN WellType WT ON WT.WellTypeID = WTP.WellTypeID
	JOIN Test T ON T.TestTypeID = WTP.TestTypeID
	WHERE T.TestID = @TestID AND WT.WellTypeName = 'B'

	SELECT @TotalWellsPerPlate = Count(NR) 
	FROM @TempWellTable TT1

	IF(ISNULL(@FixedWellCount,0)<>0) BEGIN
		--one is subtracted because new material to be fixed should be excluted.
		SELECT @Cx = COUNT(TestMaterialDeterminationWellID) -1
		FROM TestMaterialDeterminationWell TMDW 
		JOIN Well W ON TMDW.WellID = W.WellID
		JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
		JOIN Plate P ON P.PlateID = W.PlateID
		WHERE WT.WellTypeName !='F' AND P.TestID = @TestID

		--total wells per plate will be actual well available minus fixed well count
		SET @TotalWellsPerPlate = @TotalWellsPerPlate - @FixedWellCount;
	END
	ELSE BEGIN
		SELECT @Cx = COUNT(RowID)
		FROM [ROW] R
		JOIN Test T ON T.FileID = R.FileID
		WHERE T.TestID = @TestID;
	END

	SELECT @TotalPlatesRequired = CEILING (CAST(@Cx AS FLOAT) / CAST(@TotalWellsPerPlate AS FLOAT))
	
END
GO
/****** Object:  StoredProcedure [dbo].[PR_CreatePlateAndWell]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_CreatePlateAndWell]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_CreatePlateAndWell] AS' 
END
GO
/*
	EXEC PR_CreatePlateAndWell 66, 'KATHMANDU\krishna'
	EXEC PR_CreatePlateAndWell 112, 'KATHMANDU\krishna'
*/
ALTER PROCEDURE [dbo].[PR_CreatePlateAndWell]
(
	@TestID			INT,
	@User			NVARCHAR(100)
	
) AS BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
		DECLARE @TotalPlatesRequired INT, @PlatesCreated INT =0, @PlateID INT =0,  @StartColumn INT = 0,@EndColumn INT,@RowCounter INT = 0, @ColumnCounter INT, @WellCount INT, @MaterialCount INT = 0, @TotalMaterial INT, @WellTypeID INT, @WellID INT, @PlateID1 INT, @PlateCount INT = 0, @LastPlateID INT =0, @WellCreated INT = 0,@FixedWellCount INT =0,@SameTestCount NVARCHAR(100),@EmptyWellType INT;
		DECLARE @FileName NVARCHAR(100),@Crop NVARCHAR(10),@TestTypeID INT;
		DECLARE @StartRow VARCHAR(2),@EndRow VARCHAR(2), @MaxWellPosition NVARCHAR(5);
		DECLARE @TempWellTable TVP_TempWellTable,@TempWellTable1 TVP_TempWellTable,@TempInsertedWell TVP_Material, @TempMaterial TVP_Material, @CreatedPlates TVP_PlatesCreated, @TempTMDW TVP_TMDW;
		
		SELECT @PlatesCreated = COUNT(PlateID) 
		FROM Plate 
		WHERE TestID = @TestID;

		IF(@PlatesCreated = 0) BEGIN

			SELECT @TestTypeID = TestTypeID 
			FROM TesT
			WHERE TestID = @TestID;

			 SELECT @FileName = T.TestName, @Crop = CropCode
			 FROM [File] F
			 JOIN Test T ON T.FileID = F.FileID 
			WHERE T.TestID = @TestID AND T.RequestingUser = F.UserID;

			 SELECT @SameTestCount = RIGHT('000' + CAST(COUNT(TestID) AS NVARCHAR(5)),2)
			 FROM [Test] 
			 WHERE TestName = @FileName;

			SELECT @FixedWellCount = COUNT(DISTINCT Position)
			FROM Well W 
			JOIN WellType WT ON WT.WellTypeId = W.WellTypeID
			JOIN Plate P ON P.PlateID = W.PlateID
			WHERE P.TestID = @TestID AND WT.WellTypeName = 'F';

			EXEC PR_CalculatePlatesRequired @TestID,@FixedWellCount, @TotalPlatesRequired OUT
	
			SELECT @StartRow = UPPER(StartRow), @EndRow = UPPER(EndRow), @StartColumn = StartColumn,@EndColumn = EndColumn
					 FROM PlateType ;
	


			SET @RowCounter=Ascii(@StartRow)
				WHILE @RowCounter<=Ascii(@EndRow)	BEGIN
					SET @ColumnCounter = @StartColumn;
					WHILE(@ColumnCounter <= @EndColumn) BEGIN							
						INSERT INTO @TempWellTable(WellID)
							VALUES(CHAR(@RowCounter)+RIGHT('00'+CAST(@ColumnCounter AS VARCHAR),2))--CAST(@ColumnCounter AS VARCHAR))
						SET @ColumnCounter = @ColumnCounter +1;
					END
					SET @RowCounter=@RowCounter+1
				END

				DELETE TWT FROM @TempWellTable TWT
				JOIN WellTypePosition WTP ON WTP.PositionOnPlate = TWT.WellID
				JOIN WellTYpe WT ON WT.WellTypeID = WTP.WellTypeID
				WHERE  WT.WellTypeName = 'B' AND TestTypeID = @TestTypeID;

				--this is inserted to adjust autoincremented field
				INSERT INTO @TempWellTable1(WellID)
				SELECT WellID 
				FROM  @TempWellTable

				SELECT @WellCount = Count(WellID)
				FROM @TempWellTable1;

				SELECT @WellTypeID = WT.WellTypeID
				FROM WellType WT
				WHERE WellTypeName = 'A'

				SELECT @EmptyWellType = WT.WellTypeID
				FROM WellType WT
				WHERE WellTypeName = 'E'

				INSERT INTO @TempMaterial 
				SELECT M.MaterialID 
				FROM Material M 
				JOIN [Row] R ON R.MaterialKey = M.MaterialKey
				JOIN Test T ON T.FileID = R.FileID
				WHERE T.TestID = @TestID
				ORDER BY R.RowNR;


				--CREATE PLATE AND WELL
				WHILE(@PlatesCreated < @TotalPlatesRequired) BEGIN
					INSERT INTO Plate (PlateName,TestID)
					VALUES(@Crop +'_' + @FileName + '_' + @SameTestCount + '_' +RIGHT('000'+CAST(@PlatesCreated +1 AS NVARCHAR),2) ,@TestID);
					SELECT @PlateID = @@IDENTITY;
					SET @WellCreated = 0;
					WHILE(@WellCreated < @WellCount) BEGIN
						INSERT INTO WELL(WellTypeID,Position,PlateID)
						OUTPUT INSERTED.WellID INTO @TempInsertedWell(MaterialID) --inserted well is a material for this temptable
						SELECT @WellTypeID,WellID,@PlateID
						FROM @TempWellTable1
						WHERE Nr = @WellCreated;

						SET @WellCreated = @WellCreated +1;
					END
					SET @PlatesCreated = @PlatesCreated + 1
				END
				
				INSERT INTO TestMaterialDeterminationWell(MaterialID,WellID)
				SELECT M.MaterialID,W.MaterialID 
				FROM  @TempMaterial M
				JOIN @TempInsertedWell W ON W.RowNr = M.RowNr
				ORDER BY W.RowNr;

				UPDATE W
				SET W.WellTypeID = @EmptyWellType
				FROM Well W 
				JOIN @TempInsertedWell W1 ON W1.MaterialID = W.WellID
				WHERE W1.RowNr > (SELECT MAX(RowNr) FROM  @TempMaterial)
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
/****** Object:  StoredProcedure [dbo].[PR_Delete_EmptyORDeadMaterial]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_Delete_EmptyORDeadMaterial]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_Delete_EmptyORDeadMaterial] AS' 
END
GO
/*
===========EXAMPLE=============
EXEC PR_Delete_EmptyORDeadMaterial 56,'KATHMANDU\Krishna'

*/


ALTER PROCEDURE [dbo].[PR_Delete_EmptyORDeadMaterial]
(
	@TestID INT,
	@UserID NVARCHAR(200),
	@MaterialID INT
)
AS 
BEGIN
	DECLARE @ReturnValue INT,@Material TVP_Material,@Well TVP_Material, @AssignedWellType INT, @EmptyWellType INT,@MaterialWithWell TVP_TMDW, @MaxRowNr INT;--, @DeadMaterialCount INT;

	IF(ISNULL(@TestID,0)=0) BEGIN
		EXEC PR_ThrowError 'Test doesn''t exist.';
		RETURN;
	END

	--check valid test.
	EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
	IF(@ReturnValue <> 1) BEGIN
		RETURN;
	END
	--check status for validation of changed column
	IF EXISTS(SELECT StatusCode FROM Test WHERE StatusCode >= 400 AND TestID = @TestID) BEGIN
		EXEC PR_ThrowError 'Cannot change for this test.';
		RETURN;
	END

	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;

			SELECT @AssignedWellType = WellTypeID
			FROM WellType WHERE WellTypeName = 'A';
			SELECT @EmptyWellType = WellTypeID 
			FROM WellType WHERE WellTypeName = 'E';

			--DELETE ALL Material
			IF(ISNULL(@MaterialID,0) = 0) BEGIN
				--Get material assigned on well without dead, empty and fixed well position.
				INSERT INTO @Material (MaterialID)
					SELECT MaterialID
					FROM 
					(
						SELECT MaterialID
						,Position,Position2,Position1,PlateID
						FROM 
						(
							SELECT DISTINCT Position, MaterialID,W.PlateID,
							CAST(RIGHT(Position,LEN(Position)-1) AS INT) AS Position1, -- this is column number
							CAST(ASCII(LEFT(Position,1)) -65 AS INT) as Position2 -- this is row number
							FROM Well W
							JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID
							JOIN Plate P ON P.PlateID = W.PlateID
							JOIN WellType WT ON WT.WellTypeID = W.WEllTypeID		
							WHERE P.TestID = @TestID AND WT.WellTypeName = 'A' 
						) T
					) T1
					ORDER BY PlateID, Position2, Position1

				--Update all dead material well position to assigned well position
				UPDATE W
				SET W.WellTypeID = @AssignedWellType
				FROM Well W
				JOIN Plate P ON P.PlateID = W.PlateID
				JOIN WellType WT ON WT.WellTypeID =W.WellTypeID
				WHERE P.TestID = @TestID AND WT.WellTypeName = 'D'

				--Get all well postion without fixed, empty and dead.
				INSERT INTO @Well(MaterialID)
				SELECT T.WellID
				FROM 
				(
					SELECT W.*, CAST(RIGHT(Position,LEN(Position)-1) AS INT) AS Position1
					,LEFT(Position,1) as Position2
					FROM Well W
					JOIN Plate P ON P.PlateID = W.PlateID
					JOIN WellType WT ON WT.WellTypeID = W.WEllTypeID
					WHERE P.TestID = @TestID AND WT.WellTypeName = 'A' 				
				) T
				ORDER BY PlateID,Position2,Position1;

				INSERT INTO @MaterialWithWell(MaterialID,WellID)
				SELECT M.MaterialID,W.MaterialID
				FROM @Well W
				JOIN @Material M ON M.RowNr = W.RowNr;

				SELECT @MaxRowNr = MAX(RowNr)
				FROM @Material;

				--Update all unassigned well position to empty well
				UPDATE W
				SET W.WellTypeID = @EmptyWellType
				FROM Well W
				JOIN Plate P ON P.PlateID = W.PlateID
				WHERE P.TestID = @TestID AND W.WellID IN (SELECT MaterialID FROM @Well WHERE RowNr > @MaxRowNr)

				DELETE TMDW
				FROM TestMaterialDeterminationWell TMDW
				WHERE TMDW.WellID IN (SELECT MaterialID FROM @Well WHERE RowNr > @MaxRowNr)

				MERGE TestMaterialDeterminationWell T
				USING @MaterialWithWell S
				ON T.WellID = S.WellID AND T.MaterialID <> S.MaterialID
				WHEN MATCHED
				THEN UPDATE SET T.MaterialID = S.MaterialID;

				IF EXISTS(SELECT TOP 1 DeterminationID FROM TestMaterialDetermination WHERE MaterialID = @MaterialID AND TestID = @TestID) BEGIN
					DELETE FROM TestMaterialDetermination WHERE MaterialID = @MaterialID AND TestID = @TestID;
					--Update status
					IF EXISTS(SELECT StatusCode FROM Test WHERE StatusCode = 300 AND TestID = @TestID) BEGIN
						EXEC PR_Update_TestStatus @TestID, 350
					END
				END

			COMMIT;
		END
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK;
		THROW;
	END CATCH
	
END
GO
/****** Object:  StoredProcedure [dbo].[PR_Delete_Material]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_Delete_Material]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_Delete_Material] AS' 
END
GO
/*
==============EXAMPLE================
EXEC PR_Delete_Material 1,50,'KATHMANDU\krishna',1
*/

ALTER PROCEDURE [dbo].[PR_Delete_Material]
(	
	@TestID			INT,
	@UserID			NVARCHAR(100),
	@MaterialID		INT NULL--,
	--@WellType		INT OUT
) AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ReturnValue INT;
	DECLARE @WellID INT,@WellType INT;
		
	EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
	IF(@ReturnValue <> 1) BEGIN
		RETURN;
	END
	IF(ISNULL(@MaterialID,0)=0 ) BEGIN
		EXEC PR_ThrowError 'Invalid Material';
		RETURN;
	END

	BEGIN TRY
		SELECT @WellType = WellTypeID 
		FROM WellType 
		WHERE WellTYpeName = 'D';

		BEGIN TRAN;

			UPDATE Well 
			SET WellTypeID = @WellType
			WHERE WellID IN ( SELECT  W.WellID 
								FROM TestMaterialDeterminationWell TMDW
								JOIN Well W ON W.WellID = TMDW.WellID
								JOIN Plate P ON P.PlateID = W.PlateID
								WHERE MaterialID = @MaterialID AND P.TestID = @TestID);

			IF EXISTS(SELECT TOP 1 DeterminationID FROM TestMaterialDetermination WHERE MaterialID = @MaterialID AND TestID = @TestID) BEGIN
				DELETE FROM TestMaterialDetermination WHERE MaterialID = @MaterialID AND TestID = @TestID;
				--Update status
				IF EXISTS(SELECT StatusCode FROM Test WHERE StatusCode = 300 AND TestID = @TestID) BEGIN
					EXEC PR_Update_TestStatus @TestID, 350
				END
			END
			
			SELECT @WellType, TestID, StatusCode 
			FROM Test WHERE TestID = @TestID;

		COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK;
		THROW;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[PR_GET_Data]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_GET_Data]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_GET_Data] AS' 
END
GO
/*
Author:			KRISHNA GAUTAM
Created Date:	2017-11-24
Description:	Get transposed data. */

/*
=================Example===============

EXEC PR_GET_Data 56,'KATHMANDU\dsuvedi', 1, 3, '[Lotnr]   LIKE  ''%9%''   and [Crop]   LIKE  ''%LT%'''
EXEC PR_GET_Data 56,'KATHMANDU\dsuvedi', 1, 100, ''
*/
ALTER PROCEDURE [dbo].[PR_GET_Data]
(
	@TestID INT,
	@User NVARCHAR(100),
	@Page INT,
	@PageSize INT,
	@FilterQuery NVARCHAR(MAX) = NULL
)
AS BEGIN
	SET NOCOUNT ON;
	DECLARE @FileID INT;
	DECLARE @FilterClause NVARCHAR(MAX);
	DECLARE @Offset INT;
	DECLARE @Query NVARCHAR(MAX);
	DECLARE @Columns2 NVARCHAR(MAX)
	DECLARE @Columns NVARCHAR(MAX);	
	DECLARE @ColumnIDs NVARCHAR(MAX);

	IF(ISNULL(@FilterQuery,'')<>'')
	BEGIN
		SET @FilterClause = ' AND '+ @FilterQuery
	END
	ELSE
	BEGIN
		SET @FilterClause = '';
	END

	SET @Offset = @PageSize * (@Page -1);

	--get file id based on testid
	SELECT @FileID = FileID 
	FROM Test 
	WHERE TestID = @TestID;
	IF(ISNULL(@FileID, 0) = 0) BEGIN
		EXEC PR_ThrowError 'Invalid file or test.';
		RETURN;
	END
	
	SELECT 
		@Columns  = COALESCE(@Columns + ',', '') +'CAST('+ QUOTENAME(ColumnID) +' AS '+[Column].[Datatype] +')' + ' AS ' + ISNULL(QUOTENAME(TraitID),QUOTENAME(ColumLabel)),
		@Columns2  = COALESCE(@Columns2 + ',', '') + ISNULL(QUOTENAME(TraitID),QUOTENAME(ColumLabel)),
		@ColumnIDs  = COALESCE(@ColumnIDs + ',', '') + QUOTENAME(ColumnID)
	FROM [Column]
	WHERE FileID = @FileID
	ORDER BY [ColumnNr] ASC;

	IF(ISNULL(@Columns, '') = '') BEGIN
		EXEC PR_ThrowError 'At lease 1 columns should be specified';
		RETURN;
	END

	SET @Query = N' ;WITH CTE AS 
	(
		SELECT R.[RowNr], ' + @Columns2 + ' 
		FROM [ROW] R 
		LEFT JOIN 
		(
			SELECT PT.[MaterialKey], PT.[RowNr], ' + @Columns + ' 
			FROM
			(
				SELECT *
				FROM 
				(
					SELECT 
						T3.[MaterialKey],T3.RowNr,T1.[ColumnID], T1.[Value]
					FROM [Cell] T1
					JOIN [Column] T2 ON T1.ColumnID = T2.ColumnID
					JOIN [Row] T3 ON T3.RowID = T1.RowID
					JOIN [FILE] T4 ON T4.FileID = T3.FileID
					WHERE T2.FileID = @FileID AND T4.UserID = @User
				) SRC
				PIVOT
				(
					Max([Value])
					FOR [ColumnID] IN (' + @ColumnIDs + ')
				) PIV
			) AS PT 					
		) AS T1	ON R.[MaterialKey] = T1.MaterialKey  				
			WHERE R.FileID = @FileID ' + @FilterClause + '
	), Count_CTE AS (SELECT COUNT([RowNr]) AS [TotalRows] FROM CTE) 					
	SELECT '+ @Columns2 + ', Count_CTE.[TotalRows] FROM CTE, COUNT_CTE
	ORDER BY CTE.[RowNr]
	OFFSET ' + CAST(@Offset AS NVARCHAR) + ' ROWS
	FETCH NEXT ' + CAST (@PageSize AS NVARCHAR) + ' ROWS ONLY';
					
	--PRINT @Query;
	EXEC sp_executesql @Query, N'@FileID INT, @User NVARCHAR(100)', @FileID,@User;	
	SELECT [TraitID], [ColumLabel] as ColumnLabel, [DataType],[ColumnNr],CASE WHEN [TraitID] IS NULL THEN 0 ELSE 1 END AS IsTraitColumn FROM [Column] WHERE [FileID]= @FileID
	ORDER BY ColumnNr;
	

END
GO
/****** Object:  StoredProcedure [dbo].[PR_GET_Determination_All]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_GET_Determination_All]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_GET_Determination_All] AS' 
END
GO
/*
	EXEC PR_GET_Determination_All '0010'
*/
ALTER PROCEDURE [dbo].[PR_GET_Determination_All]
(
	@DeterminationName NVARCHAR(100),
	@CropCode NVARCHAR(10)
)
AS
BEGIN
	SELECT TOP 200 DeterminationID,DeterminationName, DeterminationAlias 
	FROM Determination
	WHERE DeterminationName like '%'+ @DeterminationName+'%'
	AND CropCode = @CropCode
END
GO
/****** Object:  StoredProcedure [dbo].[PR_Get_Files]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_Get_Files]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_Get_Files] AS' 
END
GO

/*
EXEC  PR_Get_Files 'KATHMANDU\krishna'
*/
ALTER PROCEDURE [dbo].[PR_Get_Files]
(
	@UserID NVARCHAR(100),
	@TestID INT = NULL
) AS
BEGIN
	
	DECLARE @TotalWells INT,@BlockedWells INT;

	SELECT @TotalWells = ((CAST(ASCII(EndRow) AS INT) - CAST(ASCII(StartRow) AS INT) +1)  * (EndColumn  - StartColumn + 1))
	FROM PlateType;

	SELECT                  
		F.FileID, 	                        
		F.CropCode, 
		F.FileTitle, 
		F.UserID, 
		F.ImportDateTime,
		T.TestID,
		T.TestTypeID,
		T.Remark,
		TT.RemarkRequired,
		T.StatusCode,
		T.MaterialStateID,
		T.MaterialTypeID,
		T.ContainerTypeID,
		T.Isolated,
		T.PlannedDate,
		ST.SlotID,
		WellsPerPlate = @TotalWells - ISNULL(T1.Blocked,0)
	FROM [File] F
	JOIN Test T ON T.FileID = F.FileID	
	JOIN TestType TT ON TT.TestTypeID = T.TestTypeID
	LEFT JOIN SlotTest ST ON ST.TestID = T.TestID
	LEFT JOIN 
	(
		SELECT Blocked = COUNT(TT.TestTypeID),TT.TestTypeID
		FROM TestType TT
		LEFT JOIN WellTypePosition WTP ON TT.TestTypeID = WTP.TestTypeID
		LEFT JOIN WellType WT ON WT.WellTypeID = WTP.WellTypeID
		WHERE WT.WellTypeName = 'B'
		GROUP BY TT.TestTypeID,WTP.WellTypeID
	) T1 ON T1.TestTypeID = T.TestTypeID
	WHERE F.UserID = @UserID
	AND T.StatusCode <= 600 
	AND (ISNULL(@TestID, 0) = 0 OR T.TestID = @TestID)
	ORDER BY FileID DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[PR_Get_MaterialState]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_Get_MaterialState]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_Get_MaterialState] AS' 
END
GO
ALTER PROCEDURE [dbo].[PR_Get_MaterialState]
AS
BEGIN
	SELECT MaterialStateID, MaterialStateCode,MaterialStateDescription
	FROM MaterialState
END
GO
/****** Object:  StoredProcedure [dbo].[PR_Get_MaterialType]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_Get_MaterialType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_Get_MaterialType] AS' 
END
GO
ALTER PROCEDURE [dbo].[PR_Get_MaterialType]
AS
BEGIN
	SELECT MaterialTypeID, MaterialTypeCode,MaterialTypeDescription
	FROM MaterialType
END
GO
/****** Object:  StoredProcedure [dbo].[PR_Get_RelationTraitDetermination]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_Get_RelationTraitDetermination]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_Get_RelationTraitDetermination] AS' 
END
GO

/*  
 DECLARE @Total INT;  
 EXEC PR_Get_RelationTraitDetermination 200, 1, 'traitlabel like ''%s%'''
*/  
ALTER PROCEDURE [dbo].[PR_Get_RelationTraitDetermination]  
(  
 @PageSize INT,  
 @PageNumber INT,
 @Filter NVARCHAR(MAX)
)  
AS  
BEGIN  
 DECLARE @Offset INT, @SQL NVARCHAR(MAX);
 SET @Offset = @PageSize * (@PageNumber -1);  


IF(ISNULL(@Filter,'') <> '') BEGIN
	SET @Filter =' WHERE '+ @Filter;
END

ELSE BEGIN
	SET @Filter = '';
END
  
 SET @SQL = N'
;WITH CTE AS  
(  
	SELECT * FROM 
	(
		SELECT 
			T1.[Source],
			T1.CropCode,
			T1.TraitID,
			T2.RelationID,
			TraitLabel = T1.TraitName,
			T2.DeterminationID,
			T2.DeterminationName,
			T2.DeterminationAlias,
			T2.[Status]
		FROM Trait T1
		LEFT JOIN
		(
			SELECT 
				RTD.[Source],
				--RTD.CropCode,    
				RTD.RelationID, 	    
				RTD.TraitID,  
				RTD.ColumnLabel,   
				RTD.DeterminationID,	  
				RTD.[Status],
				D.DeterminationName,  
				D.DeterminationAlias 
			FROM RelationTraitDetermination RTD 
			JOIN Determination D ON D.DeterminationID = RTD.DeterminationID
		) T2 ON T2.TraitID = T1.TraitID --AND T2.[Source] = T1.[Source] AND T2.CropCode = T1.CropCode
		WHERE T1.[Source] <> ''Breezys''
	) AS T '+@Filter +' 
), Count_CTE AS 
(	
	SELECT 
		COUNT(TraitID) AS [TotalRows] 
	FROM CTE
)  

SELECT 
	CropCode, 
	TraitID, 
	TraitLabel, 
	DeterminationID,
	[Source],
	DeterminationName,
	DeterminationAlias, 
	RelationID,
	[Status],  
Count_CTE.[TotalRows] 
FROM CTE, Count_CTE' ;

--IF(ISNULL(@Filter,'') <> '') BEGIN
--	SET @SQL = @SQL + ' WHERE '+ @Filter;
--END
 

 SET @SQL = @SQL + ' ORDER BY CTE.[Source], CTE.CropCode, CTE.TraitLabel,CTE.TraitID 
 OFFSET @Offset ROWS  
 FETCH NEXT @PageSize ROWS ONLY'
 --PRINT @SQL

 EXEC sp_executesql @SQL, N'@Offset INT, @PageSize INT', @Offset,@PageSize;	

 

   
END
GO
/****** Object:  StoredProcedure [dbo].[PR_Get_TraitDeterminationResult]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_Get_TraitDeterminationResult]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_Get_TraitDeterminationResult] AS' 
END
GO
/*
EXEC PR_Get_TraitDeterminationResult 200, 1, 'CropCode like ''%TO%'''
*/
ALTER PROCEDURE [dbo].[PR_Get_TraitDeterminationResult]
(
	@PageSize	INT,
	@PageNumber INT,
	@Filter NVARCHAR(MAX)
)
AS
BEGIN
	DECLARE @Offset INT;
	SET @Offset = @PageSize * (@PageNumber -1);
	DECLARE @SQL NVARCHAR(MAX);

	IF(ISNULL(@Filter,'') <> '') BEGIN
	SET @Filter =' WHERE '+ @Filter;
	END

	ELSE BEGIN
		SET @Filter = '';
	END

	SET @SQL = N'
	;WITH CTE AS
	(
		SELECT * FROM 
		(
			SELECT 
				DTR.TraitDeterminationResultID,
				--DTR.CropCode, 
				DTR.TraitID,
				T.TraitName, 
				DTR.DeterminationID, 
				D.DeterminationName,
				D.DeterminationAlias,
				DTR.DetResChar AS DeterminationValue,
				DTR.TraitResChar AS TraitValue,
				ListOfValues = CAST(ISNULL(T.ListOfValues, 0) AS BIT),
				T.[Source]
			FROM TraitDeterminationResult DTR 
			JOIN Determination D ON D.DeterminationID = DTR.DeterminationID --AND D.CropCode = DTR.CropCode
			JOIN Trait T ON T.TraitID = DTR.TraitID --AND T.CropCode = DTR.CropCode
			WHERE T.[Source] <> ''Breezys''
		) AS T ' +@Filter +' 
	), CTE_COUNT AS
	(
		SELECT COUNT(TraitDeterminationResultID) AS TotalRows FROM CTE
	)

	SELECT * FROM CTE, CTE_COUNT'

	--IF(ISNULL(@Filter,'')<> '') BEGIN
	--	SET @SQL = @SQL + ' WHERE '+@Filter;
	--END

	SET @SQL = @SQL + '	ORDER BY CTE.[Source], CTE.CropCode, CTE.TraitName,CTE.TraitID
	OFFSET @Offset ROWS
	FETCH NEXT @PageSize ROWS ONLY';

	--PRINT @SQL;
	EXEC sp_executesql @SQL, N'@Offset INT, @PageSize INT', @Offset,@PageSize;
END
GO
/****** Object:  StoredProcedure [dbo].[PR_GET_Traits_All]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_GET_Traits_All]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_GET_Traits_All] AS' 
END
GO
/*
	EXEC PR_GET_Determination_All 'r 0010'
*/
ALTER PROCEDURE [dbo].[PR_GET_Traits_All]
(
	@TraitName NVARCHAR(100),
	@CropCode NVARCHAR(10),
	@Source	  NVARCHAR(50)
)
AS
BEGIN
	SELECT TOP 200 TraitID,TraitName,TraitDescription, CropCode, ListOfValues = CAST ( ISNULL(ListOfValues, 0) AS BIT )
	FROM Trait
	WHERE TraitName like '%'+ @TraitName+'%'
	AND CropCode = @CropCode
	AND [Source] = @Source;
END
GO
/****** Object:  StoredProcedure [dbo].[PR_Get_WellType]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_Get_WellType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_Get_WellType] AS' 
END
GO
ALTER PROCEDURE [dbo].[PR_Get_WellType]
AS
BEGIN
	SELECT WellTypeID,BGColor,FGColor FROM WellType;
END

GO
/****** Object:  StoredProcedure [dbo].[PR_GetCrop]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_GetCrop]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_GetCrop] AS' 
END
GO
ALTER PROCEDURE [dbo].[PR_GetCrop]
AS 
BEGIN
	SELECT CropCode, CropName FROM CropRD
END
GO
/****** Object:  StoredProcedure [dbo].[PR_GetDataWithMarkers]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_GetDataWithMarkers]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_GetDataWithMarkers] AS' 
END
GO
/*
	EXEC [PR_GetDataWithMarkers] 48, 'KATHMANDU\psindurakar', 1, 200, '[700] LIKE ''v%'''
	EXEC [PR_GetDataWithMarkers] 45, 'KATHMANDU\krishna', 1, 200, ''
*/
ALTER PROCEDURE [dbo].[PR_GetDataWithMarkers]
(
	@TestID			INT,
	@User			NVARCHAR(100),
	@Page			INT,
	@PageSize		INT,
	@Filter			NVARCHAR(MAX) = NULL
) AS BEGIN
	SET NOCOUNT ON;

	DECLARE @Offset INT, @FileID INT, @Total INT--, @SameTestCount INT =1;
	DECLARE @SQL NVARCHAR(MAX), @Columns NVARCHAR(MAX), @ColumnIDs NVARCHAR(MAX), @Columns2 NVARCHAR(MAX), @ColumnID2s NVARCHAR(MAX), @Columns3 NVARCHAR(MAX);
	DECLARE @TblColumns TABLE(ColumnID INT, TraitID VARCHAR(20), ColumnLabel NVARCHAR(50), ColumnType INT, ColumnNr INT, DataType NVARCHAR(15));
	DECLARE @PlateAndWellAssigned BIT = 0; --here we have to check whether well and plate is assigned previously or not.. for now we set it to false 
	DECLARE @FileName NVARCHAR(100) = '', @Crop NVARCHAR(10) = ''; -- ,@SameTestCount NVARCHAR(5);

	SELECT @FileID = F.FileID, @FileName = T.TestName, @Crop = CropCode
	FROM [File] F
	JOIN Test T ON T.FileID = F.FileID 
	WHERE T.TestID = @TestID AND T.RequestingUser = F.UserID;

	IF(ISNULL(@FileID, 0) = 0) BEGIN
		EXEC PR_ThrowError 'File or test doesn''t exist.';
		RETURN;
	END

	--CREATE PLATE AND WELLS IF REQUIRED
	EXEC PR_CreatePlateAndWell @TestID,@User

	--Determination columns
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr)
	SELECT DeterminationID, TraitID, ColumnLabel, 1, ROW_NUMBER() OVER(ORDER BY ColumnNR)
	FROM
	(	
		SELECT DISTINCT 
			T1.DeterminationID,
			CONCAT('D_', T1.DeterminationID) AS TraitID,
			T3.ColumnLabel,
			T4.ColumnNR
		FROM TestMaterialDetermination T1
		JOIN Determination T2 ON T2.DeterminationID = T1.DeterminationID
		JOIN RelationTraitDetermination T3 ON T3.DeterminationID = T1.DeterminationID
		JOIN [Column] T4 ON T4.TraitID = T3.TraitID AND ISNULL(T4.TraitID, 0) <> 0
		WHERE T1.TestID = @TestID
		AND T4.FileID = @FileID		
	) V1
	ORDER BY V1.ColumnNr;
	--get total rows inserted 
	SELECT @Total = (@@ROWCOUNT + 1);

	--Trait and Property columns
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr, DataType)
	SELECT ColumnID, TraitID, ColumLabel, 2, (ColumnNr + @Total), DataType
	FROM [Column]
	WHERE FileID = @FileID;
	
	--get dynamic columns
	SELECT 
		@Columns  = COALESCE(@Columns + ',', '') + CONCAT(QUOTENAME(ColumnID), ' AS ', QUOTENAME(TraitID)),
		@ColumnIDs  = COALESCE(@ColumnIDs + ',', '') + QUOTENAME(ColumnID)
	FROM @TblColumns
	WHERE ColumnType = 1
	ORDER BY [ColumnNr] ASC;

	SELECT 
		@Columns2  = COALESCE(@Columns2 + ',', '') + CONCAT(QUOTENAME(ColumnID), ' AS ', QUOTENAME(ISNULL(TraitID, ColumnLabel))),
		@ColumnID2s  = COALESCE(@ColumnID2s + ',', '') + QUOTENAME(ColumnID)
	FROM @TblColumns
	WHERE ColumnType = 2
	ORDER BY [ColumnNr] ASC;

	SELECT 
		@Columns3  = COALESCE(@Columns3 + ',', '') +  QUOTENAME(ISNULL(TraitID, ColumnLabel))
	FROM @TblColumns
	ORDER BY [ColumnNr] ASC;

	SET @SQL = N';WITH CTE AS 
	(
		SELECT V1.MaterialID, V1.MaterialKey, V1.PlateID, V1.Plate, V1.WellID, V1.Well, V1.Position1, V1.Position2, 
		V1.WellTypeID, V1.Fixed, ' + @Columns3 + N'
		FROM 
		(
			SELECT
				M.MaterialID, 
				M.MaterialKey,
				P.PlateID, 
				P.PlateName AS Plate, 
				W.WellID,
				W.Position AS Well, 
				CAST(RIGHT(Position, LEN(Position) - 1) AS INT) AS Position1 
				,LEFT(Position, 1) as Position2,
				WT.WellTypeID,
				Fixed = CAST((CASE WHEN WT.WellTypeName = ''F'' OR WT.WellTypeName = ''D'' THEN 1 ELSE 0 END) AS BIT)
			FROM TestMaterialDeterminationWell TMDW
			JOIN Well W ON W.WellID = TMDW.WellID
			JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
			JOIN Material M ON M.MaterialID = TMDW.MaterialID 
			JOIN Plate P ON P.PlateID = W.PlateID
			WHERE P.TestID = @TestID
		) V1
		JOIN 
		(
			--trait and property columns
			SELECT MaterialKey, RowNr, ' + @Columns2 + N'  FROM 
			(
				SELECT T3.[MaterialKey], T3.RowNr, T1.[ColumnID], T1.[Value]
				FROM [Cell] T1
				JOIN [Column] T2 ON T1.ColumnID = T2.ColumnID
				JOIN [Row] T3 ON T3.RowID = T1.RowID
				JOIN [FILE] T4 ON T4.FileID = T3.FileID
				WHERE T2.FileID = @FileID AND T4.UserID = @User
			) SRC
			PIVOT
			(
				Max([Value])
				FOR [ColumnID] IN (' + @ColumnID2s + N')
			) PV
		) V2 ON V2.MaterialKey = V1.MaterialKey ';	
		
		IF(ISNULL(@Columns, '') <> '') BEGIN
			SET @SQL = @SQL + N'
			LEFT JOIN 
			(
				--markers info
				SELECT MaterialID, MaterialKey, ' + @Columns  + N'
				FROM 
				(
					SELECT T2.MaterialID,T2.MaterialKey, T1.DeterminationID
					FROM [TestMaterialDetermination] T1
					JOIN Material T2 ON T2.MaterialID = T1.MaterialID
					WHERE T1.TestID = @TestID
				) SRC 
				PIVOT
				(
					COUNT(DeterminationID)
					FOR [DeterminationID] IN (' + @ColumnIDs + N')
				) AS T
			) V3 ON V3.MaterialKey  = V1.Materialkey ';
		END	
		
		SET @SQL = @SQL + N' WHERE  1 = 1 ';	

		IF(ISNULL(@Filter, '') <> '') BEGIN
			SET @SQL = @SQL + ' AND ' + @Filter
		END

	SET @SQL = @SQL + N'
	), CTE_COUNT AS (SELECT COUNT([MaterialKey]) AS [TotalRows] FROM CTE)
	
	SELECT CTE.MaterialID,CTE.WellTypeID, CTE.WellID, CTE.Fixed, CTE.Plate, CTE.Well, ' + @Columns3 + N', CTE_COUNT.TotalRows 
	FROM CTE, CTE_COUNT
	ORDER BY PlateID, Position2, Position1
	--Well
	OFFSET @Offset ROWS
	FETCH NEXT @PageSize ROWS ONLY;';

	--PRINT @SQL
	
	SET @Offset = @PageSize * (@Page -1);

	EXEC sp_executesql @SQL , N'@FileID INT, @User NVARCHAR(100), @Offset INT, @PageSize INT, @TestID INT', @FileID, @User, @Offset, @PageSize, @TestID;

	--insert well and plate column
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr, DataType)
	VALUES(999991,NULL,'Plate',3,1,'NVARCHAR(255)'),(999992,NULL,'Well',3,2,'NVARCHAR(255)')
	--get columns information
	SELECT TraitID, ColumnLabel, ColumnType, ColumnNr, DataType
	FROM @TblColumns T1;
END

GO
/****** Object:  StoredProcedure [dbo].[PR_GetDeterminations]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_GetDeterminations]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_GetDeterminations] AS' 
END
GO
/*
	EXEC PR_GetDeterminations 'Kathmandu\dsuvedi','LT', 1, 62
*/
ALTER PROCEDURE [dbo].[PR_GetDeterminations]
(
	@UserID		NVARCHAR(50),
	@CropCode	NVARCHAR(10),
	@TestTypeID	INT,
	@TestID		INT
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @Source NVARCHAR(20);

	SELECT 
		T1.DeterminationID,
		T1.DeterminationName,
		T1.DeterminationAlias,
		T2.ColumnLabel
	FROM Determination T1
	JOIN
	(
		SELECT DISTINCT
			--T1.CropCode,
			T1.DeterminationID,
			T1.ColumnLabel,
			T2.ColumnNr
		FROM RelationTraitDetermination T1
		JOIN 
		(
			SELECT 
				C.TraitID,
				C.ColumnNr,
				T.RequestingSystem
			FROM [Column] C
			JOIN [File] F ON F.FileID = C.FileID
			JOIN Test T ON T.FileID = F.FileID AND T.RequestingUser = F.UserID 
			WHERE T.TestID = @TestID 
			AND F.UserID = @UserID			
		) T2 ON T2.TraitID = T1.TraitID --AND T2.RequestingSystem = T1.[Source] 
		AND T1.[Status] = 'ACT'
	) T2 --ON T2.CropCode = T1.CropCode AND T2.DeterminationID = T1.DeterminationID
	ON T2.DeterminationID = T1.DeterminationID
	WHERE T1.CropCode = @CropCode AND T1.TestTypeID = @TestTypeID
	ORDER BY T2.ColumnNr;
END
GO
/****** Object:  StoredProcedure [dbo].[PR_GetDeterminations1]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_GetDeterminations1]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_GetDeterminations1] AS' 
END
GO
/*
	EXEC PR_GetDeterminations 'Kathmandu\dsuvedi','LT', 1, 62
*/
ALTER PROCEDURE [dbo].[PR_GetDeterminations1]
(
	@UserID		NVARCHAR(50),
	@CropCode	NVARCHAR(10),
	@TestTypeID	INT,
	@TestID		INT
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @Source NVARCHAR(20);

	SELECT 
		T1.DeterminationID,
		T1.DeterminationName,
		T1.DeterminationAlias,
		T2.ColumnLabel
	FROM Determination T1
	JOIN
	(
		SELECT DISTINCT
			--T1.CropCode,
			T1.DeterminationID,
			T1.ColumnLabel,
			T2.ColumnNr
		FROM RelationTraitDetermination T1
		JOIN 
		(
			SELECT 
				C.TraitID,
				C.ColumnNr,
				T.RequestingSystem
			FROM [Column] C
			JOIN [File] F ON F.FileID = C.FileID
			JOIN Test T ON T.FileID = F.FileID AND T.RequestingUser = F.UserID 
			WHERE T.TestID = @TestID 
			AND F.UserID = @UserID			
		) T2 ON T2.TraitID = T1.TraitID --AND T2.RequestingSystem = T1.[Source] 
		AND T1.[Status] = 'ACT'
	) T2 --ON T2.CropCode = T1.CropCode AND T2.DeterminationID = T1.DeterminationID
	ON T2.DeterminationID = T1.DeterminationID
	WHERE T1.CropCode = @CropCode AND T1.TestTypeID = @TestTypeID
	ORDER BY T2.ColumnNr;
END
GO
/****** Object:  StoredProcedure [dbo].[PR_GetMaterialWithMarker]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_GetMaterialWithMarker]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_GetMaterialWithMarker] AS' 
END
GO

/*
	Author:			KRISHNA GAUTAM
	Created Date:	2017-DEC-04
	Updated Date:	2018-FEB-26
	Description:	Get Material and with assigned Marker data. */

	/*
	=================Example===============
	EXEC [PR_GetMaterialWithMarker] 86,'intra\krishnag', 1, 150, ''
	EXEC PR_GET_Data 31, 'KATHMANDU\krishna', 1, 100, '';
*/
ALTER PROCEDURE [dbo].[PR_GetMaterialWithMarker]
(
	@TestID INT,
	@UserID NVARCHAR(100),
	@Page INT,
	@PageSize INT,
	@Filter NVARCHAR(MAX) = NULL
)
AS BEGIN
	SET NOCOUNT ON;

	DECLARE @ColumnIDs NVARCHAR(MAX), @Columns2 NVARCHAR(MAX), @ColumnID2s NVARCHAR(MAX), @Columns3 NVARCHAR(MAX);
	DECLARE @Offset INT, @Total INT, @FileID INT,@ReturnValue INT, @Query NVARCHAR(MAX),@Columns NVARCHAR(MAX);	
	DECLARE @TblColumns TABLE(ColumnID INT, TraitID VARCHAR(20), ColumnLabel NVARCHAR(50), ColumnType INT, ColumnNr INT, DataType NVARCHAR(15));

	EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
	IF(@ReturnValue <> 1) BEGIN
		RETURN;
	END

	SELECT @FileID = F.FileID
	FROM [File] F
	JOIN Test T ON T.FileID = F.FileID 
	WHERE T.TestID = @TestID AND F.UserID = @UserID;


	--Determination columns
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr)
	SELECT DeterminationID, TraitID, ColumnLabel, 1, ROW_NUMBER() OVER(ORDER BY ColumnNR)
	FROM
	(	
		SELECT DISTINCT 
			T1.DeterminationID,
			CONCAT('D_', T1.DeterminationID) AS TraitID,
			T3.ColumnLabel,
			T4.ColumnNR
		FROM TestMaterialDetermination T1
		JOIN Determination T2 ON T2.DeterminationID = T1.DeterminationID
		JOIN RelationTraitDetermination T3 ON T3.DeterminationID = T1.DeterminationID
		JOIN [Column] T4 ON T4.TraitID = T3.TraitID AND ISNULL(T4.TraitID, 0) <> 0
		WHERE T1.TestID = @TestID
		AND T4.FileID = @FileID		
	) V1
	ORDER BY V1.ColumnNr;
	--get total rows inserted 
	SELECT @Total = (@@ROWCOUNT + 1);

	

	--Trait and Property columns
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr, DataType)
	SELECT ColumnID, TraitID, ColumLabel, 2, (ColumnNr + @Total), DataType
	FROM [Column]
	WHERE FileID = @FileID;
	
	--get dynamic columns
	SELECT 
		@Columns  = COALESCE(@Columns + ',', '') + CONCAT(QUOTENAME(ColumnID), ' AS ', QUOTENAME(TraitID)),
		@ColumnIDs  = COALESCE(@ColumnIDs + ',', '') + QUOTENAME(ColumnID)
	FROM @TblColumns
	WHERE ColumnType = 1
	ORDER BY [ColumnNr] ASC;

	SELECT 
		@Columns2  = COALESCE(@Columns2 + ',', '') + CONCAT(QUOTENAME(ColumnID), ' AS ', QUOTENAME(ISNULL(TraitID, ColumnLabel))),
		@ColumnID2s  = COALESCE(@ColumnID2s + ',', '') + QUOTENAME(ColumnID)
	FROM @TblColumns
	WHERE ColumnType = 2
	ORDER BY [ColumnNr] ASC;

	SELECT 
		@Columns3  = COALESCE(@Columns3 + ',', '') +  QUOTENAME(ISNULL(TraitID, ColumnLabel))
	FROM @TblColumns
	ORDER BY [ColumnNr] ASC;


	IF(ISNULL(@Columns,'') = '') BEGIN
		
		SET @Query = N';WITH CTE AS
		(
			SELECT M.MaterialID, T1.RowNr, T1.MaterialKey, ' + @Columns3 + N'
			FROM 
			(
				SELECT MaterialKey, RowNr, ' + @Columns2 + N'  FROM 
				(
					SELECT T3.[MaterialKey], T3.RowNr, T1.[ColumnID], T1.[Value]
					FROM [Cell] T1
					JOIN [Column] T2 ON T1.ColumnID = T2.ColumnID
					JOIN [Row] T3 ON T3.RowID = T1.RowID
					--JOIN Material M ON M.Materialkey= T3.MaterialKey
					JOIN [FILE] T4 ON T4.FileID = T3.FileID
					WHERE T4.FileID = @FileID AND T4.UserID = @UserID
				) SRC
				PIVOT
				(
					Max([Value])
					FOR [ColumnID] IN (' + @ColumnID2s + N')
				) PV
			) AS T1
			JOIN Material M ON M.MaterialKey = T1.MaterialKey
			'
	END
	ELSE BEGIN
		SET @Query = N';WITH CTE AS
		(
			SELECT M.MaterialID, T1.RowNr, T1.MaterialKey, ' + @Columns3 + N'
			FROM 
			(
				SELECT MaterialKey, RowNr, ' + @Columns2 + N'  FROM 
				(
					SELECT  T3.[MaterialKey], T3.RowNr, T1.[ColumnID], T1.[Value]
					FROM [Cell] T1
					JOIN [Column] T2 ON T1.ColumnID = T2.ColumnID
					JOIN [Row] T3 ON T3.RowID = T1.RowID
					--JOIN Material M ON M.Materialkey= T3.MaterialKey
					JOIN [FILE] T4 ON T4.FileID = T3.FileID
					WHERE T4.FileID = @FileID AND T4.UserID = @UserID
				) SRC
				PIVOT
				(
					Max([Value])
					FOR [ColumnID] IN (' + @ColumnID2s + N')
				) PV
			) AS T1
			
			JOIN Material M ON M.MaterialKey = T1.MaterialKey

			LEFT JOIN 
			(
				--markers info
				SELECT MaterialID, MaterialKey, ' + @Columns  + N'
				FROM 
				(
					SELECT T2.MaterialID,T2.MaterialKey, T1.DeterminationID
					FROM [TestMaterialDetermination] T1
					JOIN Material T2 ON T2.MaterialID = T1.MaterialID
					WHERE T1.TestID = @TestID
				) SRC 
				PIVOT
				(
					COUNT(DeterminationID)
					FOR [DeterminationID] IN (' + @ColumnIDs + N')
				) PV
				
			) AS T2			
			ON T2.MaterialID = M.MaterialID
			WHERE 1= 1';
		END

		IF(ISNULL(@Filter, '') <> '') BEGIN
			SET @Query = @Query + ' AND ' + @Filter
		END

		SET @Query = @Query + N'
		), CTE_COUNT AS (SELECT COUNT([RowNr]) AS [TotalRows] FROM CTE)
	
		SELECT MaterialID, MaterialKey, ' + @Columns3 + N', CTE_COUNT.TotalRows 
		FROM CTE, CTE_COUNT
		ORDER BY RowNr
		OFFSET @Offset ROWS
		FETCH NEXT @PageSize ROWS ONLY;';

		SET @Offset = @PageSize * (@Page -1);

		PRINT @QUERY;

		EXEC sp_executesql @Query,N'@FileID INT, @UserID NVARCHAR(200), @Offset INT, @PageSize INT, @TestID INT', @FileID, @UserID, @Offset, @PageSize, @TestID;

		SELECT TraitID, ColumnLabel, ColumnType, ColumnNr, DataType
		FROM @TblColumns T1
		ORDER BY ColumnNr;
	--END
END;
GO
/****** Object:  StoredProcedure [dbo].[PR_GetMaxWellPostionCreated]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_GetMaxWellPostionCreated]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_GetMaxWellPostionCreated] AS' 
END
GO
/*
DECLARE @T NVARCHAR(5);
EXEC PR_GetMaxWellPostionCreated 64 , @T OUT;
PRINT @T;
*/
ALTER PROCEDURE [dbo].[PR_GetMaxWellPostionCreated]
(
	@TestID			INT,
	@WellPostion	NVARCHAR(5) OUT
) 
AS BEGIN

	SELECT
	@WellPostion = T.Position 
	FROM 
	(
		SELECT TOP 1 W.*, CAST(RIGHT(Position,LEN(Position)-1) AS INT) AS Position1 
		--LEN(Position) AS Position1
		,LEFT(Position,1) as Position2
		FROM TestMaterialDeterminationWell1 TMDW
		JOIN Well W ON W.WellID = TMDW.WellID
		JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
		JOIN Material M ON M.MaterialID = TMDW.MaterialID
		JOIN Plate P ON P.PlateID = W.PlateID
		WHERE WT.WellTypeName = 'E' AND P.TestID = @TestID
		ORDER BY W.PlateID DESC	
		,Position2 DESC
		,Position1 DESC
	) T

END
GO
/****** Object:  StoredProcedure [dbo].[PR_GetNextAvailableWellPostion]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_GetNextAvailableWellPostion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_GetNextAvailableWellPostion] AS' 
END
GO
/*
DECLARE @T NVARCHAR(5);
EXEC PR_GetMaxWellPostionCreated 64 , @T OUT;
PRINT @T;
*/
ALTER PROCEDURE [dbo].[PR_GetNextAvailableWellPostion]
(
	@TestID				INT,
	@LastWellPosition	NVARCHAR(5),
	@WellPostion		NVARCHAR(5) OUT
) 
AS BEGIN
	DECLARE @TotalPlatesRequired INT,@StartColumn INT = 0,@EndColumn INT,@RowCounter INT = 0,@ColumnCounter INT, @ID INT =0, @LastWellNr INT =0;
	DECLARE @StartRow VARCHAR(2),@EndRow VARCHAR(2);
	DECLARE @TempWellTable TVP_TempWellTable;

	SET @RowCounter=Ascii(@StartRow)
	WHILE @RowCounter<=Ascii(@EndRow)	BEGIN
		SET @ColumnCounter = @StartColumn;
		WHILE(@ColumnCounter <= @EndColumn) BEGIN							
			INSERT INTO @TempWellTable(WellID)
				VALUES(CHAR(@RowCounter)+RIGHT('00'+CAST(@ColumnCounter AS VARCHAR),2))--+CAST(@ColumnCounter AS VARCHAR))
			SET @ColumnCounter = @ColumnCounter +1;
		END
		SET @RowCounter=@RowCounter+1
	END

	DELETE TWT FROM @TempWellTable TWT
	JOIN WellTypePosition WTP ON WTP.PositionOnPlate = TWT.WellID
	JOIN WellTYpe WT ON WT.WellTypeID = WTP.WellTypeID
	JOIN Test T ON T.TestTypeID = WTP.TestTypeID	
	WHERE  WT.WellTypeName = 'B' AND WT.WellTypeName = 'F' AND T.TestID = @TestID

	SELECT TOP 1 @LastWellNr = Nr +1 
	FROM @TempWellTable
	WHERE WellID = @LastWellPosition 

	IF NOT EXISTS(SELECT TOP 1  Nr FROM @TempWellTable WHERE Nr = @LastWellNr) BEGIN
		SET @LastWellNr = 0;
	END
				
	SELECT @WellPostion = WellID 
	FROM @TempWellTable 
	WHERE NR = @LastWellNr;

END




GO
/****** Object:  StoredProcedure [dbo].[PR_GetPlantsLookup]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_GetPlantsLookup]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_GetPlantsLookup] AS' 
END
GO
/*
	EXEC PR_GetPlantsLookup 42, 'KATHMANDU\PBantwa',  'nl'
*/
ALTER PROCEDURE [dbo].[PR_GetPlantsLookup]
(
	@TestID		INT,
	@UserID		NVARCHAR(100),
	@Query		NVARCHAR(1024) = NULL
) AS BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT TOP 20
		M.MaterialID, 
		MaterialKey = CE.Value 
	FROM Material M
	JOIN [Row] R ON R.MaterialKey = M.MaterialKey
	JOIN [Column] C ON C.FileID = R.FileID
	JOIN [Cell] CE ON CE.ColumnID = C.ColumnID AND CE.RowID = R.RowID
	JOIN Test T ON T.FileID = R.FileID

	WHERE T.TestID = @TestID AND C.ColumLabel = 'Plantnr' AND CE.[Value] LIKE '%' + ISNULL(@Query, '') + '%'
	ORDER BY CE.Value;	
END
GO
/****** Object:  StoredProcedure [dbo].[PR_GetPlateLabels]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_GetPlateLabels]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_GetPlateLabels] AS' 
END
GO
-- EXEC PR_GetPlateLabels 87, 'KATHMANDU\binodg'
ALTER PROCEDURE [dbo].[PR_GetPlateLabels]
(
	@TestID	INT,
	@UserID	NVARCHAR(100)
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @SyncCode NVARCHAR(4);

	DECLARE @ReturnValue INT;
	EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
	IF(@ReturnValue <> 1) BEGIN
		RETURN;
	END

	SELECT
		SyncCode = T.BreedingStationCode,
		F.CropCode, 		
		P.PlateName,
		P.LabPlateID
	FROM Plate P
	JOIN Test T ON T.TestID = P.TestID
	JOIN [File] F ON F.FileID = T.FileID AND F.UserID = T.RequestingUser
	WHERE T.TestID =  @TestID
	AND T.RequestingUser = @UserID;
END
GO
/****** Object:  StoredProcedure [dbo].[PR_GetPlatesForLims]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_GetPlatesForLims]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_GetPlatesForLims] AS' 
END
GO
/*
	EXEC PR_GetPlatesForLims 87, 'KATHMANDU\binodg'

	Description: This stored procedure is executed to fill plates in lims
*/
ALTER PROCEDURE [dbo].[PR_GetPlatesForLims]
(
	@TestID	INT,
	@UserID	NVARCHAR(100)
) AS BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnValue INT;
	EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
	IF(@ReturnValue <> 1) BEGIN
		RETURN;
	END


	SET @ReturnValue = dbo.Validate_Capacity(@TestID);
	IF(@ReturnValue = 0) BEGIN
		EXEC PR_ThrowError N'Reservation Qouta exceed for tests or plates. Unassign some markers or change slot for this test.';
		RETURN;
	END
	--GET Plant Name
	DECLARE @PlantNrColumnID NVARCHAR(MAX), @SQL NVARCHAR(MAX);
	DECLARE @tbl TABLE
	(	
		MaterialID INT,
		PlantNr NVARCHAR(200)
	);

	SELECT DISTINCT
		@PlantNrColumnID =  QUOTENAME(ColumnID)
	FROM [Column] C
	JOIN [File] F ON F.FileID = C.FileID
	JOIN Test T ON T.FileID = F.FileID
	WHERE C.ColumLabel = 'Plantnr'
	AND T.TestID = @TestID
	AND T.RequestingUser = @UserID;

	SET @SQL = N' SELECT MaterialID,' + @PlantNrColumnID + ' AS Plantnr  
		FROM 
		(
			SELECT 
				M.MaterialID, 
				C.ColumnID, 
				C.[Value]
			FROM [Cell] C
			JOIN [Column] C1 ON C1.ColumnID = C.ColumnID
			JOIN [Row] R ON R.RowID = C.RowID
			JOIN Material M ON M.MaterialKey = R.MaterialKey
			JOIN [File] F ON F.FileID = C1.FileID
			JOIN Test T ON T.FileID = F.FileID
			WHERE C1.ColumLabel = ''Plantnr''
			AND T.TestID = @TestID
			AND T.RequestingUser = @UserID
		) SRC
		PIVOT
		(
			MAX([Value])
			FOR [ColumnID] IN (' + @PlantNrColumnID + ')
		) PV';

	INSERT INTO @tbl(MaterialID, PlantNr) 
	EXEC sp_executesql @SQL, N'@TestID INT, @UserID	NVARCHAR(100)', @TestID, @UserID;

	--GET Well and Material Information
	SELECT
		F.CropCode,
		LimsPlateplanID = T.LabPlatePlanID,0,
		RequestID = T.TestID,
		LimsPlateID = P.LabPlateID,0,
		LimsPlateName = P.PlateName,
		PlateColumn = SUBSTRING(W.Position, 2, LEN(W.Position) - 1),
		PlateRow = LEFT(W.Position, 1),
		PlantNr = RIGHT(M.MaterialKey, LEN(M.MaterialKey) - 2),
		PlantName = M2.PlantNr,
		T.BreedingStationCode
	FROM Plate P
	JOIN Test T ON T.TestID = P.TestID
	JOIN [File] F ON F.FileID = T.FileID
	JOIN Well W ON W.PlateID = P.PlateID
	JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
	JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID
	JOIN Material M ON M.MaterialID = TMDW.MaterialID
	JOIN @tbl M2 ON M2.MaterialID = M.MaterialID	
	WHERE T.TestID =  @TestID
	AND T.RequestingUser = @UserID AND WellTypeName !='D';


	--GET Markers information
	SELECT DISTINCT
		LimsPlateID = P.LabPlateID,
		D.DeterminationID AS MarkerNr, 
		D.DeterminationName AS MarkerName
	FROM TestMaterialDetermination TMD
	JOIN Test T ON T.TestID = TMD.TestID
	JOIN Plate P ON P.TestID = T.TestID
	JOIN Determination D ON D.DeterminationID = TMD.DeterminationID
	WHERE T.TestID =  @TestID
	AND T.RequestingUser = @UserID
	ORDER BY P.LabPlateID, D.DeterminationID;
END
GO
/****** Object:  StoredProcedure [dbo].[PR_GetPunchList]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_GetPunchList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_GetPunchList] AS' 
END
GO
/*
DECLARE @p1 INT, @p2 NVARCHAR(200);
EXEC PR_GetPunchList 52, @p1 OUT, @p2 OUT;
PRINT @P1
PRINT @P2;
*/
ALTER PROCEDURE [dbo].[PR_GetPunchList]
(
	@TestID INT,
	@PlatePlanID INT OUT,
	@PlatePlanName NVARCHAR(200) OUT
)
AS BEGIN
	SET NOCOUNT ON;

	DECLARE @Table Table
	(	MaterialKey NVARCHAR(100),
		Position NVARCHAR(5),
		BgColor NVARCHAR(30),
		FgColor NVARCHAR(30),
		PlateID INT,
		PlateName NVARCHAR(150)
	);

	DECLARE @PlatntNrTable TABLE
	(	
		MaterialID INT,
		PlantNr NVARCHAR(100)
	);

	DECLARE @TotalPlates INT, @Count INT = 0, @PlateID INT = 0,@TestType INT,@PlateName NVARCHAR(150),@FileID INT,@PlantNrColumnID NVARCHAR(MAX),@SQL NVARCHAR(MAX), @FileTitle NVARCHAR(MAX);
	--DECLARE @PlatePlanID INT, @PlatePlanName NVARCHAR(200);

	SELECT @PlatePlanID = LabPlatePlanID,
	@PlatePlanName = LabPlatePlanName 
	FROM Test WHERE TestID = @TestID;
			
	SELECT @TotalPlates = COUNT(PlateID)
	FROM Plate
	WHERE TestID = @TestID; 

	SELECT @TestType = TestTypeID 
	FROM Test
	WHERE TestID = @TestID;

	SELECT @FileID = T.FileID ,
		   @FileTitle = F.FileTitle
	FROM [File] F
	JOIN Test T on T.FileID = F.FileID
	WHERE T.TestID = @TestID;

	SELECT @PlantNrColumnID = QUOTENAME(ColumnID)
	FROM [Column] C
	JOIN [File] F ON F.FileID = C.FileID
	WHERE F.FileID = @FileID AND C.ColumLabel = 'Plantnr';

	SET @SQL = N'		
		SELECT MaterialID,'+@PlantNrColumnID +' AS Plantnr  FROM 
		(
			SELECT M.MaterialID,C.ColumnID,c.[Value]
			FROM [Cell] C
			JOIN [Column] C1 ON C1.ColumnID = C.ColumnID
			JOIN [Row] R ON R.RowID = C.RowID
			JOIN Material M ON M.MaterialKey = R.MaterialKey
			JOIN [File] F ON F.FileID = C1.FileID
			WHERE F.FIleID = '+CAST(@FileID AS NVARCHAR(10))+'
		) SRC
		PIVOT
		(
			MAX([Value])
			FOR [ColumnID] IN ('+@PlantNrColumnID+')
		) PV'

	INSERT INTO @PlatntNrTable(MaterialID,PlantNr) EXEC sp_executesql @SQL;
		 
	INSERT INTO @Table(Position,PlateID,PlateName,MaterialKey,BgColor,FgColor)
	SELECT
	W.Position,W.PlateID,P.PlateName, 
	--M.MaterialKey,
	M.Plantnr,
	WT.BGColor,WT.FGColor
	FROM Well W
	LEFT JOIN TestMaterialDeterminationWell TMDW ON W.WellID = TMDW.WellID
	--LEFT JOIN Material M ON M.MaterialID = TMDW.MaterialID
	LEFT JOIN @PlatntNrTable M ON M.MaterialID = TMDW.MaterialID	
	JOIN WellType WT ON Wt.WellTypeID = W.WellTypeId		
	JOIN Plate P ON P.PlateID = W.PlateID
	WHERE P.TestID = @TestID

	--SELECT * FROM @Table;
	WHILE(@Count < @TotalPlates) BEGIN
		SELECT @PlateID = PlateID,@PlateName = PlateName
		FROM Plate 
		WHERE TestID = @TestID
		ORDER BY PlateID
		OFFSET @Count ROWS
		FETCH NEXT 1 ROWS ONLY;

		INSERT INTO @Table(Position,PlateID,PlateName,MaterialKey,BgColor,FgColor)
		SELECT PositionOnPlate,@PlateID,@PlateName,'QC',WT.BGColor,FGColor
		FROM WellTypePosition WTP
		JOIN WellType WT ON WT.WellTypeID = WTP.WellTypeID
		WHERE TestTypeID = @TestType;

		SET @Count = @Count +1;
	END
	SELECT PlateID,PlateName,MaterialKey,Position,BgColor,FgColor,Position2 as [Row], Position1 as [Column], @FileTitle FROM
	( 
		SELECT *,CAST(RIGHT(Position,LEN(Position)-1) AS INT) AS Position1
		,LEFT(Position,1) as Position2
		FROM @Table
	) T ORDER BY PlateID,Position2,Position1

END



GO
/****** Object:  StoredProcedure [dbo].[PR_GetSlot_ForTest]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_GetSlot_ForTest]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_GetSlot_ForTest] AS' 
END
GO
/*
EXEC PR_GetSlot_ForTest 80

*/
ALTER PROCEDURE [dbo].[PR_GetSlot_ForTest]
(
	--@User NVARCHAR(200),
	@TestID INT = NULL
	
)
AS BEGIN
	IF(ISNULL(@TestID,0)=0)BEGIN
		EXEC PR_ThrowError 'Invalid Test.';
		RETURN;	
	END
	ELSE BEGIN
		SELECT S.SlotID,S.SlotName FROM Slot S
		JOIN [Period] P ON P.PeriodID = S.PeriodID
		
		JOIN 
		(
			SELECT F.CropCode, T.* 
			FROM [File] F JOIN Test T ON T.FileID = F.FileID
			WHERE T.TestID = @TestID
		) AS T
		ON T.CropCode = S.CropCode 
		AND T.MaterialTypeID = S.MaterialTypeID 
		AND T.Isolated = S.Isolated
		AND T.BreedingStationCode = S.BreedingStationCode
		LEFT JOIN SlotTest ST on ST.SlotID = ST.TestID
		WHERE S.StatusCode = 200 AND T.TestID = @TestID 
		AND CAST(T.PlannedDate AS DATE) BETWEEN CAST(P.StartDate AS DATE) AND CAST(P.EndDate AS DATE)
	END
END
GO
/****** Object:  StoredProcedure [dbo].[PR_GetStatusList]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_GetStatusList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_GetStatusList] AS' 
END
GO
-- =============================================
-- Author:		Binod Gurung
-- Create date: 2018/01/29
-- Description:	Get Status list 
-- =============================================
-- EXEC PR_GetStatusList 'Test'
-- =============================================
ALTER PROCEDURE [dbo].[PR_GetStatusList]
(
	@StatusTable NVARCHAR(50)
)
AS
BEGIN
	
	SET NOCOUNT ON;

	IF(ISNULL(@StatusTable, '') = '')
	BEGIN
		SELECT 
			StatusCode,
			StatusName
		FROM [Status]
	END
	ELSE
	BEGIN
		SELECT 
			StatusCode,
			StatusName 
		FROM [Status]
		WHERE StatusTable = @StatusTable
	END

END


GO
/****** Object:  StoredProcedure [dbo].[PR_GetTestDetail]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_GetTestDetail]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_GetTestDetail] AS' 
END
GO
-- =============================================
-- Author:		Binod Gurung
-- Create date: 2018/01/19
-- Description:	Get all information for selected Test
-- =============================================
ALTER PROCEDURE [dbo].[PR_GetTestDetail]
(
	@TestID	INT,
	@UserID	NVARCHAR(100)
)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @ReturnValue INT;
	EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
	IF(@ReturnValue <> 1) BEGIN
		RETURN;
	END

    SELECT
		TestID,
		StatusCode
	FROM Test 
	WHERE TestID =  @TestID
	AND   RequestingUser = @UserID;

	IF(@@ROWCOUNT <= 0) BEGIN
		EXEC PR_ThrowError N'You are not authorized to use this test.';
		RETURN;
	END

END
GO
/****** Object:  StoredProcedure [dbo].[PR_GetTestInfoForLIMS]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_GetTestInfoForLIMS]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_GetTestInfoForLIMS] AS' 
END
GO

-- =============================================
-- Author:		Binod Gurung
-- Create date: 2018/01/17
-- Description:	Pull Test Information
-- =============================================
/*
EXEC PR_GetTestInfoForLIMS 2,'KATHMANDU\PBantwa',40
EXEC PR_GetTestInfoForLIMS 90,'KATHMANDU\psindurakar',40
*/
ALTER PROCEDURE [dbo].[PR_GetTestInfoForLIMS]
(
	@TestID INT,
	@UserID NVARCHAR(100),
	@MaxPlates INT
)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @SynCode CHAR(2), @CropCode CHAR(2), @TotalTests INT, @Isolated BIT, @ReturnValue INT, @RemarkRequired BIT, @DeterminationRequired INT,@DeadWellType INT,@TotalPlates INT;

	--Validate Test for corresponding user
	EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
	IF(@ReturnValue <> 1) BEGIN
		RETURN;
	END

	SELECT @TotalPlates = COUNT(PlateID)
	FROM Plate WHERE TestID = @TestID;

	IF(@TotalPlates > @MaxPlates) BEGIN
		DECLARE @Error NVARCHAR(MAX) = 'Reservation of Plate failed. Maximum of '+ CAST(@MaxPlates AS NVARCHAR(10)) + ' plates can be reserved for test. ';
		EXEC PR_ThrowError @Error;
		RETURN;			
	END

	--check if total tests and plates falls within range of total marker and palates for this test
	SET @ReturnValue = dbo.Validate_Capacity(@TestID);
	IF(@ReturnValue = 0) BEGIN
		EXEC PR_ThrowError N'Reservation Qouta exceed for tests or plates. Unassign some markers or change slot for this test.';
		RETURN 0;
	END


	SELECT TOP 1 @SynCode = (LEFT(M.MaterialKey,2)) , 
				 @CropCode = M.CropCode
	FROM Row R
	JOIN Test T ON T.FileID = R.FileID
	JOIN Material M ON M.MaterialKey = R.MaterialKey
	WHERE T.TestID = @TestID
	  AND T.RequestingUser = @UserID;

	SELECT @DeadWellType = WellTypeID 
	FROM WEllType WHERE WellTypeName = 'D'
	
	--Amount of tests per plate CUMULATED for ALL plates together
	SELECT @TotalTests = COUNT(V2.DeterminationID)
	FROM
	(
		SELECT V.DeterminationID, V.PlateID
		FROM
		(
			SELECT P.PlateID, TMDW.MaterialID, TMD.DeterminationID FROM TestMaterialDetermination TMD 
			JOIN TestMaterialDeterminationWell TMDW ON TMDW.MaterialID = TMD.MaterialID
			JOIN Well W ON W.WellID = TMDW.WellID
			JOIN Plate P ON P.PlateID = W.PlateID AND P.TestID = TMD.TestID
			WHERE TMD.TestID = @TestID AND W.WellTypeID <> @DeadWellType
		
		) V
		GROUP BY V.DeterminationID, V.PlateID
	) V2 ;	
	
	SELECT  @RemarkRequired = TT.RemarkRequired, 
			@DeterminationRequired = TT.DeterminationRequired 
	FROM TestType TT
	JOIN Test T ON T.TestTypeID = TT.TestTypeID
	WHERE T.TestID = @TestID
	  AND T.RequestingUser = @UserID;

	--For Test type with Remarkrequired true is DNA Isolation type. For DNA Isolation type, Isolated value is true
	IF(@RemarkRequired = 1)
		SET @Isolated = 1

	--Determination should be used for Test type with DeterminatonRequired true
	IF(@TotalTests = 0 AND @DeterminationRequired = 1)
	BEGIN
		EXEC PR_ThrowError N'Please assign at least one marker.';
		RETURN 0;
	END

	--For DNA Isolation type Markers are not used. Dummy value -1 is sent for now. Should be changed later
	IF(@Isolated = 1)
		SET @TotalTests = -1;

	SELECT	YEAR(T.PlannedDate)				AS PlannedYear, 
			COUNT(P.PlateID)				AS TotalPlates, 
			@TotalTests						AS TotalTests, 
			@SynCode						AS SynCode, 
			T.Remark						AS Remark, 
			--@Isolated						AS Isolated, 
			IsIsolated = CASE WHEN T.Isolated = 1 THEN 'T' ELSE 'F' END,
			@CropCode						AS CropCode, 
			DATEPART(WEEK, T.PlannedDate)	AS PlannedWeek,
			MS.MaterialStateCode,
			MT.MaterialTypeCode,
			CT.ContainerTypeCode,
			ExpecdedYear = YEAR(T.ExpectedDate),
			ExpectedWeek = DATEPART(WEEK, T.ExpectedDate)
	FROM Test T
	JOIN Plate P ON P.TestID = T.TestID
	LEFT JOIN MaterialState MS ON MS.MaterialStateID = T.MaterialStateID
	LEFT JOIN MaterialType MT ON MT.MaterialTypeID = T.MaterialTypeID
	LEFT JOIN ContainerType CT ON CT.ContainerTypeID = T.ContainerTypeID	
	WHERE T.TestID = @TestID
	 AND  T.RequestingUser = @UserID
	GROUP BY T.TestID, T.PlannedDate, T.Remark, MS.MaterialStateCode, MT.MaterialTypeCode, CT.ContainerTypeCode, T.Isolated,T.ExpectedDate;

END
GO
/****** Object:  StoredProcedure [dbo].[PR_GetTestsLookup]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_GetTestsLookup]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_GetTestsLookup] AS' 
END
GO
-- =============================================
-- Author:		Binod Gurung
-- Create date: 12/14/2017
-- Description:	Get List of Test to fill combo box 
-- =============================================
-- EXEC [PR_GetTestsLookup] 'kathmandu\krishna'
ALTER PROCEDURE [dbo].[PR_GetTestsLookup] 
(
	@UserID nvarchar(100)
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @TotalWells INT,@BlockedWells INT;

	SELECT @TotalWells = ((CAST(ASCII(EndRow) AS INT) - CAST(ASCII(StartRow) AS INT) +1)  * (EndColumn  - StartColumn + 1))
	FROM PlateType

    SELECT 
		T.TestID, 
		T.TestName, 
		TT.TestTypeID, 
		TT.TestTypeName,
		T.Remark,
		TT.RemarkRequired,
		T.StatusCode,
		FixedPositionAssigned = CAST((CASE WHEN ISNULL(T1.TotalFixed,0) = 0 THEN 0 ELSE 1 END) AS BIT),
		T.MaterialStateID,
		T.MaterialTypeID,
		T.ContainerTypeID,
		MaterialReplicated = CAST((CASE WHEN ISNULL(T2.ReplicatedCount,1) = 1 THEN 0 ELSE 1 END) AS BIT),
		T.PlannedDate,
		T.Isolated,
		ST1.SlotID,
		WellsPerPlate = @TotalWells - ISNULL(T3.Blocked,0)
	FROM Test T 
	JOIN TestType TT ON T.TestTypeID = TT.TestTypeID
	LEFT JOIN [Status] ST ON ST.StatusCode = T.StatusCode AND ST.StatusTable = 'Test'
	LEFT JOIN
	(
		SELECT T.TestID, COUNT(WT.WellTypeID) AS TotalFixed
		FROM Well W
		JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
		JOIN Plate P ON P.PlateID = W.PlateID
		JOIN Test T ON T.TestID = P.TestID
		WHERE WT.WellTypeName   = 'F' AND 
		       T.RequestingUser = @UserID
		GROUP BY T.TestID
	) T1 ON T1.TestID = T.TestID
	LEFT JOIN 
	(
		SELECT T.TestID, COUNT(MaterialID) AS ReplicatedCount FROM 
		Test T 
		JOIN Plate P ON P.TestID = T.TestID
		JOIN Well W ON W.PlateID = P.PlateID
		JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
		JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID
		WHERE T.RequestingUser = @UserID
			AND WT.WellTypeName <> 'F'
			GROUP BY T.TestID
			HAVING COUNT(MaterialID) > 1
	) T2 ON T2.TestID = T.TestID
	LEFT JOIN SlotTest ST1 ON ST1.TestID = T.TestID
	LEFT JOIN 
	(
		SELECT Blocked = COUNT(TT.TestTypeID),TT.TestTypeID
		FROM TestType TT
		LEFT JOIN WellTypePosition WTP ON TT.TestTypeID = WTP.TestTypeID
		LEFT JOIN WellType WT ON WT.WellTypeID = WTP.WellTypeID
		WHERE WT.WellTypeName = 'B'
		GROUP BY TT.TestTypeID,WTP.WellTypeID
	) T3 ON T3.TestTypeID = T.TestTypeID
	WHERE T.RequestingUser = @UserID
	AND T.StatusCode <= 600
	ORDER BY TestID DESC;

END

GO
/****** Object:  StoredProcedure [dbo].[PR_GetTraitValues]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_GetTraitValues]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_GetTraitValues] AS' 
END
GO
/*
	EXEC PR_GetTraitValues 'TO', 230
*/
ALTER PROCEDURE [dbo].[PR_GetTraitValues]
(
	@CropCode NVARCHAR(10),
	@TraitID  INT
)
AS
BEGIN
	SELECT 
		TraitValueCode,
		TraitValueName
	FROM TraitValue
	--WHERE CropCode = @CropCode
	--AND TraitID = @TraitID
	WHERE TraitID = @TraitID
	ORDER BY DisplayOrder;
END
GO
/****** Object:  StoredProcedure [dbo].[PR_GetWellPositionsLookup]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_GetWellPositionsLookup]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_GetWellPositionsLookup] AS' 
END
GO
-- =============================================
-- Author:		Binod Gurung
-- Create date: 12/15/2017
-- Description:	Get List of Test with TestTypeCode 
-- =============================================
ALTER PROCEDURE [dbo].[PR_GetWellPositionsLookup] 
	( @TestID int )
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @Total1 INT;
	DECLARE @TempWellTable TVP_TempWellTable;

	DECLARE @TempWellTable1 TVP_TempWellTable;
	DECLARE @StartRow VARCHAR(2);
	DECLARE @EndRow VARCHAR(2);
	DECLARE @StartColumn INT;
	DECLARE @EndColumn INT;
	DECLARE @RowCounter INT;
	DECLARE @ColumnCounter INT;

	--fetch plate position according to PlateType
	SELECT @StartRow = UPPER(StartRow), @EndRow = UPPER(EndRow), @StartColumn = StartColumn,@EndColumn = EndColumn
		FROM PlateType PT
		JOIN TestType TT ON PT.PlateTypeID = TT.PlateTypeID 
		JOIN Test TS ON TT.TestTypeID = TS.TestTypeID
		WHERE TS.TestID = @TestID;
  
	SET @RowCounter=Ascii(@StartRow)
	WHILE @RowCounter<=Ascii(@EndRow) BEGIN
	SET @ColumnCounter = @StartColumn;
	WHILE(@ColumnCounter <= @EndColumn) BEGIN       
		INSERT INTO @TempWellTable1(WellID)
		VALUES(CHAR(@RowCounter)+RIGHT('00'+CAST(@ColumnCounter AS VARCHAR),2))--+CAST(@ColumnCounter AS VARCHAR))
		SET @ColumnCounter = @ColumnCounter +1;
	END
	SET @RowCounter=@RowCounter+1
	END

	--Exclude Positions for Reserved
	DELETE TWT FROM @TempWellTable1 TWT
	JOIN WellTypePosition WTP ON WTP.PositionOnPlate = TWT.WellID 
	JOIN WellType WT ON WTP.WellTypeID = WT.WellTypeID
	JOIN Test T ON T.TestTypeID = WTP.TestTypeID
	WHERE WT.WellTypeName = 'B' AND T.TestID = @TestID;

	--Exclude Positions for Fixed Plant
	DELETE TWT FROM @TempWellTable1 TWT
	JOIN Well W On W.Position = TWT.WellID
	JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
	JOIN Plate P On P.PlateID = W.PlateID
	WHERE WT.WellTypeName = 'F' AND P.TestID = @TestID;

	SELECT @Total1 = Count(NR) FROM @TempWellTable1;

	INSERT INTO @TempWellTable(WellID)
		SELECT WEllID FROM  @TempWellTable1;
	
	SELECT WEllID FROM  @TempWellTable;

END
GO
/****** Object:  StoredProcedure [dbo].[PR_Insert_ExcelData]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_Insert_ExcelData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_Insert_ExcelData] AS' 
END
GO
/*
Author:			KRISHNA GAUTAM
Created Date:	2017-11-23
Description:	Import Excel data to database. */
ALTER PROCEDURE [dbo].[PR_Insert_ExcelData]
(
	@CropCode				NVARCHAR(10),
	@BreedingStationCode     NVARCHAR(10),
	@TestTypeID				INT,
	@UserID					NVARCHAR(100),
	@FileTitle				NVARCHAR(200),
	@TestName				NVARCHAR(200),
	@TVPColumns TVP_Column	READONLY,
	@TVPRow TVP_Row			READONLY,
	@TVPCell TVP_Cell		READONLY,
	@PlannedDate			DATETIME,
	@MaterialStateID		INT,
	@MaterialTypeID			INT,
	@ContainerTypeID		INT,
	@Isolated				BIT,
	@Source					NVARCHAR(50),
	@TestID					INT OUTPUT,
	@ObjectID				NVARCHAR(100)
)
AS BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
		IF(ISNULL(@TestTypeID,0)=0) BEGIN
			EXEC PR_ThrowError 'Invalid test type ID.';
			RETURN;
		END

		DECLARE @RowData TABLE([RowID] int,	[RowNr] int	);
		DECLARE @ColumnData TABLE([ColumnID] int,[ColumnNr] int);
		DECLARE @FileID INT;

		INSERT INTO [FILE] ([CropCode],[FileTitle],[UserID],[ImportDateTime], [RefExternal])
		VALUES(@CropCode, @FileTitle, @UserID, GETUTCDATE(), @ObjectID);
		--Get Last inserted fileid
		SELECT @FileID = SCOPE_IDENTITY();

		INSERT INTO [Row] ( [RowNr], [MaterialKey], [FileID])
		OUTPUT INSERTED.[RowID],INSERTED.[RowNr] INTO @RowData
		SELECT T.RowNr,T.MaterialKey,@FileID FROM @TVPRow T;

		INSERT INTO [Column] ([ColumnNr], [TraitID], [ColumLabel], [FileID], [DataType])
		OUTPUT INSERTED.[ColumnID], INSERTED.[ColumnNr] INTO @ColumnData
		SELECT T.[ColumnNr], T1.[TraitID], T.[ColumLabel], @FileID, T.[DataType] FROM @TVPColumns T
		LEFT JOIN Trait T1 ON T1.SourceID = T.TraitID AND T1.Source = @Source AND T1.CropCode = @CropCode;		

		INSERT INTO [Cell] ( [RowID], [ColumnID], [Value])
		SELECT [RowID], [ColumnID], [Value] 
		FROM @TVPCell T1
		JOIN @RowData T2 ON T2.RowNr = T1.RowNr
		JOIN @ColumnData T3 ON T3.ColumnNr = T1.ColumnNr;	

		--CREATE TEST
		INSERT INTO [Test]([TestTypeID],[FileID],[RequestingSystem],[RequestingUser],[TestName],[CreationDate],[StatusCode],[PlannedDate], [MaterialStateID],[MaterialTypeID], [ContainerTypeID],[Isolated],[BreedingStationCode],[ExpectedDate])
		VALUES(@TestTypeID, @FileID, @Source, @UserID,@TestName , GETUTCDATE(), 100,@PlannedDate,@MaterialStateID, @MaterialTypeID, @ContainerTypeID, @Isolated,@BreedingStationCode, DateAdd(Week,2,@PlannedDate));
		--Get Last inserted testid
		SELECT @TestID = SCOPE_IDENTITY();

		--CREATE Materials if not already created
		MERGE INTO Material T 
		USING
		(
			SELECT R.MaterialKey
			FROM [Row] R
			WHERE FileID = @FileID		
		) S	ON S.MaterialKey = T.MaterialKey
		WHEN NOT MATCHED THEN 
			INSERT(MaterialType, MaterialKey, [Source], CropCode)
			VALUES ('PLT', S.MaterialKey, @Source, @CropCode);
			
		COMMIT;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		THROW;
	END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_ApproveSlot]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_PLAN_ApproveSlot]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_PLAN_ApproveSlot] AS' 
END
GO
ALTER PROC [dbo].[PR_PLAN_ApproveSlot]
(
	@SlotID INT
) 
AS BEGIN
SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN
			IF NOT EXISTS (SELECT SlotID FROM Slot WHERE SlotID = @SlotID) BEGIN	
				EXEC PR_ThrowError 'Invalid slot';
				RETURN;
			END
			EXEC PR_PLAN_UpdateCapacitySlot @SlotID,200;			
		COMMIT TRAN;
		SELECT
			ReservationNumber = RIGHT('0000' + CAST(SlotID AS NVARCHAR(5)),5), 
			SlotName, 
			PeriodName, 
			ChangedPeriodname = PeriodName, 
			PlannedDate,
			ChangedPlannedDate = PlannedDate, 
			RequestUser, 
			ExpectedDate, 
			ChangedExpectedDate = ExpectedDate			
		FROM Slot S
		JOIN [Period] P ON P.PeriodID = S.PeriodID WHERE S.SlotID = @SlotID;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_ChangeSlot]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_PLAN_ChangeSlot]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_PLAN_ChangeSlot] AS' 
END
GO

ALTER PROC [dbo].[PR_PLAN_ChangeSlot]
(
	@SlotID INT,
	@PlannedDate DATETIME,
	@ExpectedDate DATETIME
) 
AS BEGIN
SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @CurrentPlannedDate DATETIME, @CurrentExpectedDate DATETIME, @CurrentPeriodName NVARCHAR(100);
		DECLARE @CurrentPeriod INT, @ChangedPeriod INT;
		DECLARE @InRange INT;

		
		IF NOT EXISTS (SELECT SlotID FROM Slot WHERE SlotID = @SlotID) BEGIN	
			EXEC PR_ThrowError 'Invalid slot';
			RETURN;
		END
		--First we have to select before we update data for this stored procedure
		SELECT 
			@CurrentPeriodName = PeriodName, 
			@CurrentPlannedDate = PlannedDate,
			@CurrentExpectedDate = ExpectedDate 
		FROM Slot S
		JOIN [Period] P ON P.PeriodID = S.PeriodID WHERE S.SlotID = @SlotID;

		SELECT @CurrentPeriod = PeriodID
		FROM Period WHERE @CurrentPlannedDate BETWEEN StartDate AND EndDate;
		
		SELECT @ChangedPeriod = PeriodID
		FROM Period WHERE @PlannedDate BETWEEN StartDate AND EndDate;

		IF(ISNULL(@CurrentPeriod,0) = ISNULL(@ChangedPeriod,0)) BEGIN
			EXEC PR_ThrowError 'Cannot change planned date to same week.';
			RETURN;
		END

		IF(dbo.Validate_Capacity_Period_Protocol(@SlotID,@PlannedDate) = 0) BEGIN
			EXEC PR_ThrowError 'Reservation quota is full. Please plan on another week.';
			RETURN;
		END
		

		BEGIN TRAN
			UPDATE Slot 
				SET PlannedDate = CAST(@PlannedDate AS DATE), 
				ExpectedDate = CAST(@ExpectedDate AS DATE),
				PeriodID = @ChangedPeriod,
				StatusCode = 200
			WHERE SlotID = @SlotID;	
		COMMIT TRAN;

		SELECT 
			ReservationNumber = RIGHT('0000' + CAST(SlotID AS NVARCHAR(5)),5), 
			SlotName, 
			PeriodName = @CurrentPeriodName, 
			ChangedPeriodname = PeriodName, 
			PlannedDate = @CurrentPlannedDate,
			ChangedPlannedDate = PlannedDate,
			RequestUser,  
			ExpectedDate = @CurrentExpectedDate, 
			ChangedExpectedDate = ExpectedDate 
		FROM Slot S
		JOIN [Period] P ON P.PeriodID = S.PeriodID WHERE S.SlotID = @SlotID;
		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_Get_Avail_Plates_Tests]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_PLAN_Get_Avail_Plates_Tests]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_PLAN_Get_Avail_Plates_Tests] AS' 
END
GO
-- =============================================
-- Author:		Binod Gurung
-- Create date: 2018/03/15
-- Description:	Get available plates tests
/*
DECLARE @DisplayPlannedWeek NVARCHAR(20),@ExpectedDate DateTime ,@DisplayExpectedWeek NVARCHAR(20),@AvailPlates INT,@AvailTests INT;

EXEC PR_PLAN_Get_Avail_Plates_Tests 2,'LT',0,'2018-03-30',@DisplayPlannedWeek OUT,@ExpectedDate OUT, @DisplayExpectedWeek OUT, @AvailPlates OUT, @AvailTests OUT;
PRINT @DisplayPlannedWeek;
PRINT @ExpectedDate;
PRINT @DisplayExpectedWeek;
PRINT @AvailPlates;
PRINT @AvailTests;

*/
-- =============================================
ALTER PROCEDURE [dbo].[PR_PLAN_Get_Avail_Plates_Tests]
(
	@MaterialTypeID INT,
	@CropCode NVARCHAR(10),
	@Isolated BIT,
	@PlannedDate DateTime,
	@DisplayPlannedWeek NVARCHAR(20) OUT,
	@ExpectedDate DateTime OUT,
	@DisplayExpectedWeek NVARCHAR(20) OUT,
	@AvailPlates INT OUT,
	@AvailTests INT OUT
)
AS
BEGIN

	SET NOCOUNT ON;
	--DECLARE @MarkerTypeTestProtocolID INT =0, @DNATypeTestProtocolID INT =0;
	DECLARE @PeriodID INT, @TotalPlates INT, @ReservedPlates INT, @TotalTests INT, @ReservedTests INT, @TestProtocolID INT;

	--get TestProtocolID for selected Material type and crop
	SELECT 
		@TestProtocolID = TestProtocolID
	FROM MaterialTypeTestProtocol
	WHERE MaterialTypeID = @MaterialTypeID AND CropCode = @CropCode


	IF(ISNULL(@TestProtocolID,0)=0) BEGIN
		EXEC PR_ThrowError 'No valid protocol found for selected material type and crop';
		RETURN;
	END
	
	SELECT 
		@PeriodID = PeriodID 
	FROM [Period] 
	WHERE @PlannedDate BETWEEN StartDate AND EndDate;

	IF(ISNULL(@PeriodID,0)=0) BEGIN
		EXEC PR_ThrowError 'No period found for selected planned date';
		RETURN;
	END


	
	--Total number of plates avail per period per method
	SELECT 
		@TotalPlates = NrOfPlates
	FROM AvailCapacity
	WHERE PeriodID = @PeriodID AND TestProtocolID = @TestProtocolID

	--Total number of tests avail per period
	SELECT DISTINCT
		@TotalTests = NrOfTests
	FROM AvailCapacity
	WHERE PeriodID = @PeriodID --AND NrOfTests IS NOT NULL

	
	--Reserved plates per period per method
	SELECT 
		@ReservedPlates = SUM(RC.NrOfPlates)
	FROM ReservedCapacity RC
	JOIN Slot S ON S.SlotID = RC.SlotID
	WHERE S.PeriodID = @PeriodID AND RC.TestProtocolID = @TestProtocolID AND S.StatusCode = 200
	--GROUP BY S.PeriodID

	--Reserved tests per period
	SELECT 
		@ReservedTests = SUM(RC.NrOfTests)
	FROM ReservedCapacity RC
	JOIN Slot S ON S.SlotID = RC.SlotID
	WHERE S.PeriodID = @PeriodID  AND S.StatusCode = 200
	--GROUP BY S.PeriodID


	--Default Expected Week is 2 Weeks later than Planned Week
	SET @ExpectedDate = DATEADD(week, 2, @PlannedDate);

	--Get display period for Planned date
	SELECT 
		@DisplayPlannedWeek = PeriodName + ' - ' + CAST(YEAR(@PlannedDate) AS NVARCHAR(10))
	FROM [Period] 
	WHERE @PlannedDate BETWEEN StartDate AND EndDate;

	--Get display period for Expected date
	SELECT 
		@DisplayExpectedWeek = PeriodName + ' - ' + CAST(YEAR(@ExpectedDate) AS NVARCHAR(10))
	FROM [Period] 
	WHERE @ExpectedDate BETWEEN StartDate AND EndDate;

	IF(@Isolated = 1) BEGIN
		SELECT  @AvailPlates = NULL,
				--@AvailTests = NULL;
				 @AvailTests = ISNULL(@TotalTests, 0) - ISNULL(@ReservedTests, 0);
	END
	ELSE BEGIN
		SELECT @AvailPlates = ISNULL(@TotalPlates, 0) - ISNULL(@ReservedPlates, 0),
			   @AvailTests = ISNULL(@TotalTests, 0) - ISNULL(@ReservedTests, 0);
	END
END
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_Get_ReserveCapacity_LookUp]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_PLAN_Get_ReserveCapacity_LookUp]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_PLAN_Get_ReserveCapacity_LookUp] AS' 
END
GO
ALTER PROCEDURE [dbo].[PR_PLAN_Get_ReserveCapacity_LookUp]
AS
BEGIN

	SELECT BreedingStationCode, BreedingStationName FROM BreedingStation;

	SELECT DISTINCT C.CropCode, CropName 
	FROM CropRD C
	JOIN MaterialTypeTestProtocol MTP ON MTP.CropCode = C.CropCode
	ORDER BY CropCode;

	SELECT TestTypeID, TestTypeCode, TestTypeName, DeterminationRequired FROM TestType;

	--SELECT MaterialTypeID, MaterialTypeCode, MaterialTypeDescription FROM MaterialType;
	SELECT MaterialStateID,MaterialStateCode, MaterialStateDescription FROM MaterialState;

	EXEC PR_PLAN_GetCurrentPeriod 1;
END


GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetCapacity]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_PLAN_GetCapacity]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_PLAN_GetCapacity] AS' 
END
GO
/*
EXEC PR_PLAN_GetCapacity 2018
*/
ALTER PROCEDURE [dbo].[PR_PLAN_GetCapacity]
(
	@Year INT = NULL
) AS
BEGIN	
	DECLARE @SQL NVARCHAR(MAX), @PeriodName NVARCHAR(MAX), @Where NVARCHAR(MAX) = '', @InnerSQL NVARCHAR(MAX) = dbo.FN_PLAN_GetAvailableCapacityByPeriodsQuery();
	IF(ISNULL(@Year,0)<>0) BEGIN
		SET @Where = 'WHERE Year(P.StartDate) = '+CAST(@Year AS NVARCHAR(MAX))+' OR Year(P.EndDate) = '+CAST(@Year AS NVARCHAR(MAX));
	END

	SET @PeriodName = 'Concat(P.PeriodName, ''('',Concat(FORMAT(P.StartDate,''MMM-d'',''en-US''),''-'',FORMAT(P.EndDate,''MMM-d'',''en-US'')),'')'') AS PeriodName';

	SET @InnerSQL = dbo.FN_PLAN_GetAvailableCapacityByPeriodsQuery();
	IF(ISNULL(@InnerSQL,'') = '') BEGIN
		EXEC PR_ThrowError 'No Protocol found for saving NoOfTest(Markers) or NoOfPlates';
		RETURN;
	END
	
	SET @SQL = N'SELECT '+@PeriodName+', P.Remark,P.PeriodID, T.*
					FROM [Period] P
					LEFT JOIN
					(
					'+@InnerSQL+'
					 
					) T ON P.PeriodID = T.PID
					'+@Where+
					'ORDER BY P.PeriodID';
		
	EXEC sp_executesql @SQL;

	--PRINT @SQL;

	--SELECT TestProtocolID, TestProtocolName
	--FROM
	--(
	--	SELECT 0 AS DispOrder, 'nrOfTests' AS TestProtocolID, 'Marker tests' AS TestProtocolName
	--	UNION
	--	SELECT 
	--		1,
	--		TestProtocolID = CAST(TestProtocolID AS VARCHAR(10)), 
	--		TestProtocolName
	--	FROM TestProtocol
	--) V
	--ORDER BY DispOrder;	
	SELECT TestProtocolID = CAST(TestProtocolID AS NVARCHAR(10)),TestProtocolName
	FROM TestProtocol
	WHERE Isolated = 0

END
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetCurrentPeriod]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_PLAN_GetCurrentPeriod]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_PLAN_GetCurrentPeriod] AS' 
END
GO
--EXEC PR_PLAN_GetCurrentPeriod
ALTER PROCEDURE [dbo].[PR_PLAN_GetCurrentPeriod]
(
	@DetailAlso BIT = 0
)
AS BEGIN
	SET NOCOUNT ON;
	DECLARE @PeriodID INT;
	SELECT 
		@PeriodID = [PeriodID]
	FROM [Period] 
	WHERE GETUTCDATE() BETWEEN StartDate AND EndDate;

	IF(ISNULL(@PeriodID, 0) = 0) BEGIN
		EXEC PR_ThrowError N'Couldn''t find period information in database.';
		RETURN 0;
	END

	IF (@DetailAlso = 1) BEGIN
		SELECT 
			[PeriodID], [PeriodName], [StartDate], [EndDate], [Remark]
		FROM [Period] 
		WHERE GETUTCDATE() BETWEEN StartDate AND EndDate;
	END
	RETURN @PeriodID;
END
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetMaterialTypePerCrop_Lookup]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_PLAN_GetMaterialTypePerCrop_Lookup]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_PLAN_GetMaterialTypePerCrop_Lookup] AS' 
END
GO
ALTER PROCEDURE [dbo].[PR_PLAN_GetMaterialTypePerCrop_Lookup]
(
	@CropCode NVARCHAR(10)
) 
AS BEGIN
	SET NOCOUNT ON;

	SELECT 
		MT.MaterialTypeID,
		MT.MaterialTypeCode,
		MT.MaterialTypeDescription
	 FROM MaterialType MT
	 JOIN MaterialTypeTestProtocol MTTP ON MTTP.MaterialTypeID = MT.MaterialTypeID
	 WHERE MTTP.CropCode = @CropCode
	
END
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetPeriodDetail]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_PLAN_GetPeriodDetail]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_PLAN_GetPeriodDetail] AS' 
END
GO

ALTER PROCEDURE [dbo].[PR_PLAN_GetPeriodDetail]
(
	@InputDate DateTime
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT 
		PeriodName + ' - ' + CAST(YEAR(@InputDate) AS NVARCHAR(10)) AS 'DisplayPeriod'
	FROM Period 
	WHERE @InputDate BETWEEN StartDate AND EndDate;

END
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetPlanApprovalListBySlotForLAB]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_PLAN_GetPlanApprovalListBySlotForLAB]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_PLAN_GetPlanApprovalListBySlotForLAB] AS' 
END
GO
/*
	DECLARE @Periods TVP_PLAN_Period;
	INSERT INTO @Periods(PeriodID) VALUES(63),(64),(65);
	EXEC PR_PLAN_GetPlanApprovalListBySlotForLAB @Periods
*/
ALTER PROCEDURE [dbo].[PR_PLAN_GetPlanApprovalListBySlotForLAB]
(
	@Periods TVP_PLAN_Period READONLY
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @SQL NVARCHAR(MAX);

	DECLARE @TCols1 NVARCHAR(MAX), @TCols2 NVARCHAR(MAX), @PCols1 NVARCHAR(MAX), @PCols2 NVARCHAR(MAX);
	SELECT 
		@TCols1 = COALESCE(@TCols1 + ',', '') + QUOTENAME(TestProtocolID),
		@TCols2 = COALESCE(@TCols2 + ',', '') + QUOTENAME(TestProtocolID) + ' = ' + 'MAX(ISNULL(' + QUOTENAME(TestProtocolID) + ', 0))'
	FROM TestProtocol TP
	JOIN TestType TT ON TT.TestTypeID = TP.TestTypeID 
	WHERE Isolated = 0 
	AND TT.DeterminationRequired = 1;

	SELECT 
		@PCols1 = COALESCE(@PCols1 + ',', '') + QUOTENAME(TestProtocolID),
		@PCols2 = COALESCE(@PCols2 + ',', '') + QUOTENAME(TestProtocolID) + ' = ' + 'MAX(ISNULL(' + QUOTENAME(TestProtocolID) + ', 0))'
	FROM TestProtocol TP
	JOIN TestType TT ON TT.TestTypeID = TP.TestTypeID 
	WHERE Isolated = 0 
	AND TT.DeterminationRequired = 0;

	--get current period
	DECLARE @CurrentPeriodID INT, @CurrentPeriodEndDate DATETIME;
	EXEC @CurrentPeriodID = PR_PLAN_GetCurrentPeriod;
	--get end date of current period
	SELECT @CurrentPeriodEndDate = EndDate FROM [Period] WHERE PeriodID = @CurrentPeriodID;


	SET @SQL = N'	
	DECLARE @TBLPeriod TABLE(PeriodID INT, TestProtocolID INT);
	INSERT INTO @TBLPeriod (PeriodID, TestProtocolID)
	SELECT DISTINCT PeriodID, TestProtocolID 
	FROM @Periods P 
	CROSS JOIN TestProtocol TP
	WHERE TP.Isolated = 0;	

	DECLARE @ReservedCapacity TABLE(PeriodID INT, TestProtocolID INT, NrOfPlates INT, NrOfTests INT)
	DECLARE @NonReservedCapacity TABLE(SlotID INT, PeriodID INT, TestProtocolID INT, NrOfPlates INT, NrOfTests INT)
	DECLARE @MarkerTestProtocolID INT;

	--calculate slot wise detailed records
	SELECT 
		@MarkerTestProtocolID = TestProtocolID 
	FROM TestProtocol TP
	JOIN TestType TT On TT.TestTypeID = TP.TestTypeID
	WHERE TT.DeterminationRequired = 1;
	
	--Calculate sum of reserved capacity period and protocol wise
	INSERT INTO @ReservedCapacity(PeriodID, TestProtocolID, NrOfPlates, NrOfTests)
	SELECT 
		P.PeriodID, 
		TP.TestProtocolID, 
		ISNULL(NrOfPlates,0), 
		ISNULL(NrOfTests ,0)
	FROM TestProtocol TP
	JOIN @TBLPeriod P ON P.TestProtocolID = TP.TestProtocolID
	LEFT JOIN
	(
		 SELECT
			T2.PeriodID,
			T1.TestProtocolID,
			NrOfPlates = SUM(T1.NrOfPlates),
			NrOfTests = SUM(T1.NrOfTests)
		 FROM ReservedCapacity T1
		 JOIN Slot T2 ON T2.SlotID = T1.SlotID 
		 JOIN @Periods P ON P.PeriodID = T2.PeriodID
		 WHERE T2.StatusCode = 200
		 GROUP BY T2.PeriodID, T1.TestProtocolID
	) T2 ON T2.TestProtocolID = TP.TestProtocolID AND P.PeriodID = T2.PeriodID
	WHERE TP.Isolated = 0;

	--Calculate sum of non reserved but requested capacity slot, period and protocol wise
	;WITH CTE AS 
	(
		SELECT 
			T2.PeriodID,
			T1.SlotID,
			T1.TestProtocolID,
			NrOfPlates = SUM(T1.NrOfPlates),
			NrOfTests = SUM(T1.NrOfTests)
		FROM ReservedCapacity T1
		JOIN Slot T2 ON T2.SlotID = T1.SlotID
		JOIN @Periods P ON P.PeriodID = T2.PeriodID
		WHERE T2.StatusCode = 100
		GROUP BY T2.PeriodID, T1.SlotID, T1.TestProtocolID
	)
	INSERT INTO @NonReservedCapacity(PeriodID, SlotID, TestProtocolID, NrOfPlates, NrOfTests)
	SELECT 
		T1.PeriodID, 
		T1.SlotID, 
		T1.TestProtocolID, 
		SUM(T2.NrOfPlates), 
		SUM(T2.NrOfTests)
	FROM CTE T1
	JOIN CTE T2 ON T1.SlotID >= T2.SlotID AND T1.TestProtocolID = T2.TestProtocolID AND T1.PeriodID = T2.PeriodID
	GROUP BY T1.PeriodID, T1.SlotID, T1.TestProtocolID;

	--calculate and transpose slot test protocol wise
	;WITH CTE2 AS
	(
		 SELECT 
			T1.PeriodID,
			T1.SlotID, 
			T1.TestProtocolID, 
			TestProtocolID2 = T1.TestProtocolID,
			NrOfPlates = T1.NrOfPlates + T2.NrOfPlates, 
			NrOfTests = T1.NrOfTests + T2.NrOfTests
		 FROM @NonReservedCapacity T1
		 JOIN @ReservedCapacity T2 ON T2.PeriodID = T1.PeriodID AND T2.TestProtocolID = T1.TestProtocolID
	)
	SELECT T4.PeriodID, T2.Plates, T2.Markers, T1.*, T4.BreedingStationCode, T4.CropCode, T4.SlotName, T4.RequestUser, T3.TestProtocolName, T4.PlannedDate, T4.ExpectedDate,
	TotalWeeks = 
	(
		SELECT 
			COUNT(PP.PeriodID) 
		FROM [Period] PP
		WHERE PP.StartDate >  @CurrentPeriodEndDate
		AND PP.EndDate <= 
		(
			SELECT TOP 1
				PPP.EndDate 
			FROM [Period] PPP
			WHERE T4.PlannedDate BETWEEN PPP.StartDate AND PPP.EndDate
		)
	)
	FROM
	(
		 SELECT SlotID, ' + @TCols2 + N',' + @PCols2  + N' 
		 FROM
		 (
			  SELECT 
				   T3.SlotID,
				  ' + @TCols1 + N',' + @PCols1  + N'
			  FROM CTE2 T1
			  PIVOT
			  (
				   MAX(NrOfTests)
				   FOR TestProtocolID IN (' + @TCols1 + N')
			  ) AS T2
			  PIVOT
			  (
				   MAX(NrOfPlates)
				   FOR TestProtocolID2 IN (' + @PCols1 + N')
			  ) AS T3
		 ) V1
		 GROUP BY SlotID
	) T1
	RIGHT JOIN 
	(
		SELECT T1.SlotID, MAX(ISNULL([Plates], 0)) AS [Plates], MAX(ISNULL([Markers], 0)) As [Markers] 
		FROM 
		(
			SELECT SlotID, [Markers], [Plates]
			FROM
			(
				SELECT 
					S.SlotID, 
					NrOfTests, 
					NrOfPlates,
					Protocol1 = CASE WHEN RC.TestProtocolID = @MarkerTestProtocolID THEN ''Markers'' ELSE ''Plates'' END,
					Protocol2 = CASE WHEN RC.TestProtocolID = @MarkerTestProtocolID THEN ''Markers'' ELSE ''Plates'' END
				FROM SLOT S
				JOIN ReservedCapacity RC ON RC.SlotID = S.SlotID
				JOIN TestProtocol TP On TP.TestProtocolID = RC.TestProtocolID
				JOIN @Periods P ON P.PeriodID = S.PeriodID
				WHERE StatusCode = 100 
			) AS V1
			PIVOT 
			(
				SUM(NrOfTests)
				FOR Protocol1 IN ([Markers])
			) AS V2
			PIVOT 
			(
				SUM(NrOfPlates)
				FOR Protocol2 IN ([Plates])
			) AS V3
		) T1
		GROUP BY T1.SlotID
	) T2 ON T2.SlotID = T1.SlotID
	LEFT JOIN
	(
		SELECT 
			RC.SlotID, 
			TP.TestProtocolID, 
			TP.TestProtocolName			 
		FROM ReservedCapacity RC 
		JOIN TestProtocol TP ON RC.TestProtocolID = TP.TestProtocolID
		WHERE RC.TestProtocolID <> @MarkerTestProtocolID
	) T3 ON T3.SlotID = T2.SlotID
	LEFT JOIN Slot T4 ON T4.SlotID = T3.SlotID
	ORDER BY T4.PeriodID, T1.SlotID;
'
EXEC sp_executesql @SQL, N'@CurrentPeriodEndDate DATETIME, @Periods TVP_PLAN_Period READONLY', @CurrentPeriodEndDate, @Periods;

END
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetPlanApprovalListForLAB]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_PLAN_GetPlanApprovalListForLAB]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_PLAN_GetPlanApprovalListForLAB] AS' 
END
GO
--EXEC PR_PLAN_GetPlanApprovalListForLAB 63
ALTER PROCEDURE [dbo].[PR_PLAN_GetPlanApprovalListForLAB]
(
	@PeriodID	INT = NULL
) AS BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ARGS		NVARCHAR(MAX);
	DECLARE @SQL		NVARCHAR(MAX);

	--Prepare 3 periods to display
	DECLARE @Periods TVP_PLAN_Period;
	IF(ISNULL(@PeriodID, 0) <> 0) BEGIN
		INSERT INTO @Periods(PeriodID) 
		SELECT TOP 3 
			PeriodID
		FROM [Period] 
		WHERE PeriodID >= @PeriodID
		ORDER BY PeriodID;
	END
	ELSE BEGIN
		--get current period
		EXEC @PeriodID = PR_PLAN_GetCurrentPeriod;
		INSERT INTO @Periods(PeriodID) 
		SELECT TOP 3 
			PeriodID
		FROM [Period] 
		WHERE PeriodID >= @PeriodID
		ORDER BY PeriodID;
	END
	
	--Get standard values 
	SET @SQL = N'SELECT 
		PeriodName = CONCAT(PeriodName, FORMAT(StartDate, '' (MMM-dd - '', ''en-US'' ), FORMAT(EndDate, ''MMM-dd)'', ''en-US'' )), 
		T1.Remark, T1.PeriodID, T2.*
	FROM [Period] T1
	LEFT JOIN
	(' +
		dbo.FN_PLAN_GetAvailableCapacityByPeriodsQuery()			
	+ N') T2 ON T2.PID = T1.PeriodID
	WHERE T1.PeriodID IN (SELECT PeriodID FROM @Periods)
	ORDER BY T1.PeriodID;'

	EXEC sp_executesql @SQL, N'@Periods TVP_PLAN_Period READONLY', @Periods;
	
	--get current values
	SET @SQL = dbo.FN_PLAN_GetReservedCapacityByPeriodsQuery() + 
		N' WHERE PeriodID IN (SELECT PeriodID FROM @Periods);'
	EXEC sp_executesql @SQL, N'@Periods TVP_PLAN_Period READONLY', @Periods;

	--get columns list
	SELECT TestProtocolID, TestProtocolName
	FROM
	(
		SELECT
			0 AS DisplayOrder, 
			TestProtocolID = CAST(TestProtocolID AS VARCHAR(10)), 
			TestProtocolName
		FROM TestProtocol TP
		JOIN TestType TT ON TT.TestTypeID = TP.TestTypeID 
		WHERE TP.Isolated = 0
		AND TT.DeterminationRequired = 1
		UNION
		SELECT 
			1 AS DisplayOrder, 
			TestProtocolID = CAST(TestProtocolID AS VARCHAR(10)), 
			TestProtocolName
		FROM TestProtocol TP
		JOIN TestType TT ON TT.TestTypeID = TP.TestTypeID 
		WHERE TP.Isolated = 0
		AND TT.DeterminationRequired = 0
	) V
	ORDER BY DisplayOrder;

	--Get summary period and slot wise
	EXEC PR_PLAN_GetPlanApprovalListBySlotForLAB @Periods;
END
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetPlannedOverview]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_PLAN_GetPlannedOverview]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_PLAN_GetPlannedOverview] AS' 
END
GO
--EXEC PR_PLAN_GetPlannedOverview 2018, 63
ALTER PROCEDURE [dbo].[PR_PLAN_GetPlannedOverview]
(
	@Year		INT,
	@PeriodID	INT = NULL
) AS BEGIN
SET NOCOUNT ON;

	DECLARE @MarkerTestProtocolID INT;
	SELECT 
		@MarkerTestProtocolID = TestProtocolID 
	FROM TestProtocol TP
	JOIN TestType TT On TT.TestTypeID = TP.TestTypeID
	WHERE TT.DeterminationRequired = 1;

	SELECT 
		T3.PeriodID, 
		PeriodName = CONCAT(P.PeriodName, FORMAT(P.StartDate, ' (MMM-dd-yy - ', 'en-US' ), FORMAT(P.EndDate, 'MMM-dd-yy)', 'en-US' )),
		T1.*, 
		T2.TestProtocolName, 
		T3.BreedingStationCode, 
		T3.CropCode, 
		T3.RequestUser,
		T3.SlotName,
		CRD.CropName
	FROM
	(
		SELECT T1.SlotID, MAX(ISNULL([Markers], 0)) As [Markers] , MAX(ISNULL([Plates], 0)) AS [Plates]
		FROM 
		(
			SELECT SlotID, [Markers], [Plates]
			FROM
			(
				SELECT 
					S.SlotID, 
					NrOfTests, 
					NrOfPlates,
					Protocol1 = CASE WHEN RC.TestProtocolID = @MarkerTestProtocolID THEN 'Markers' ELSE 'Plates' END,
					Protocol2 = CASE WHEN RC.TestProtocolID = @MarkerTestProtocolID THEN 'Markers' ELSE 'Plates' END
				FROM SLOT S
				JOIN ReservedCapacity RC ON RC.SlotID = S.SlotID
				JOIN TestProtocol TP On TP.TestProtocolID = RC.TestProtocolID
				JOIN [Period] P ON P.PeriodID = S.PeriodID
				WHERE StatusCode = 200 
				AND @Year BETWEEN DATEPART(YEAR, P.StartDate) AND DATEPART(YEAR, P.EndDate)
				AND (ISNULL(@PeriodID, 0) = 0 OR S.PeriodID = @PeriodID)
			) AS V1
			PIVOT 
			(
				SUM(NrOfTests)
				FOR Protocol1 IN ([Markers])
			) AS V2
			PIVOT 
			(
				SUM(NrOfPlates)
				FOR Protocol2 IN ([Plates])
			) AS V3
		) T1
		GROUP BY T1.SlotID
	) T1
	LEFT JOIN
	(
		SELECT 
			RC.SlotID, 
			TP.TestProtocolID, 
			TP.TestProtocolName			 
		FROM ReservedCapacity RC 
		JOIN TestProtocol TP ON RC.TestProtocolID = TP.TestProtocolID
		WHERE RC.TestProtocolID <> @MarkerTestProtocolID
	) T2 ON T2.SlotID = T1.SlotID
	LEFT JOIN Slot T3 ON T3.SlotID = T1.SlotID
	JOIN [Period] P ON P.PeriodID = T3.PeriodID
	JOIN CropRD CRD ON CRD.CropCode = T3.CropCode
	ORDER BY T3.PeriodID, T3.BreedingStationCode, T3.CropCode;

END
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetPlanPeriods]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_PLAN_GetPlanPeriods]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_PLAN_GetPlanPeriods] AS' 
END
GO
ALTER PROCEDURE [dbo].[PR_PLAN_GetPlanPeriods]
(
	@Year INT = NULL
)
AS BEGIN
	SET NOCOUNT ON;

	SELECT [PeriodID]
        ,PeriodName = CONCAT(PeriodName, FORMAT(StartDate, ' (MMM-dd-yy - ', 'en-US' ), FORMAT(EndDate, 'MMM-dd-yy)', 'en-US' ))
        ,[StartDate]
        ,[EndDate]
        ,[Remark]
    FROM [Period]
	WHERE ISNULL(@Year, 0) = 0 
	OR @Year BETWEEN DATEPART(YEAR, StartDate) AND DATEPART(YEAR, EndDate);
END
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetSlotData]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_PLAN_GetSlotData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_PLAN_GetSlotData] AS' 
END
GO
-- =============================================
-- Author:		Binod Gurung
-- Create date: 2018/03/21
-- Description:	Get Slot detail 
-- =============================================
/***********************************************
EXEC PR_PLAN_GetSlotData 69 
***********************************************/
ALTER PROCEDURE [dbo].[PR_PLAN_GetSlotData]
(
	@SlotID INT
)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @MarkerTestProtocolID INT;

	SELECT 
		@MarkerTestProtocolID = TestProtocolID 
	FROM TestProtocol TP
	JOIN TestType TT On TT.TestTypeID = TP.TestTypeID
	WHERE TT.DeterminationRequired = 1

	SELECT 
		S.SlotID,
		SlotName,
		BreedingStationCode,
		CropCode,
		RequestUser,
		TestType = 
			CASE 
				WHEN RCT.NrOfTests IS NULL THEN (
					SELECT TOP 1 TestTypeName FROM TestType WHERE RemarkRequired = 1
				) ELSE (
					SELECT TOP 1 TestTypeName FROM TestType WHERE DeterminationRequired = 1
				)
				 
			END,
		MT.MaterialTypeCode,
		MS.MaterialStateCode,
		S.Isolated,
		TP.TestProtocolName,
		RCP.NrOfPlates,
		RCT.NrOfTests,
		S.PlannedDate,
		S.ExpectedDate
	FROM Slot S
	LEFT JOIN MaterialType MT ON MT.MaterialTypeID = S.MaterialTypeID
	LEFT JOIN MaterialState MS ON MS.MaterialStateID = S.MaterialStateID
	LEFT JOIN ReservedCapacity RCP ON RCP.SlotID = S.SlotID AND RCP.TestProtocolID <> @MarkerTestProtocolID
	LEFT JOIN ReservedCapacity RCT ON RCT.SlotID = S.SlotID AND RCT.TestProtocolID = @MarkerTestProtocolID
	LEFT JOIN TestProtocol TP ON TP.TestProtocolID = RCP.TestProtocolID
	WHERE S.SlotID = @SlotID

    
END
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_RejectSlot]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_PLAN_RejectSlot]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_PLAN_RejectSlot] AS' 
END
GO
/*
	EXEC PR_PLAN_RejectSlot 8
*/
ALTER PROC [dbo].[PR_PLAN_RejectSlot]
(
	@SlotID INT
) 
AS BEGIN
SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN
			IF NOT EXISTS (SELECT SlotID FROM Slot WHERE SlotID = @SlotID) BEGIN	
				EXEC PR_ThrowError 'Invalid slot';
				RETURN;
			END
			EXEC PR_PLAN_UpdateCapacitySlot @SlotID,300;			
		COMMIT TRAN;

		SELECT 
			ReservationNumber = RIGHT('0000' + CAST(SlotID AS NVARCHAR(5)),5), 
			SlotName, 
			PeriodName, 
			ChangedPeriodname = PeriodName, 
			PlannedDate,
			ChangedPlannedDate = PlannedDate, 
			RequestUser, 
			ExpectedDate, 
			ChangedExpectedDate = ExpectedDate 
		FROM Slot S
		JOIN [Period] P ON P.PeriodID = S.PeriodID WHERE S.SlotID = @SlotID;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_Reserve_Capacity]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_PLAN_Reserve_Capacity]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_PLAN_Reserve_Capacity] AS' 
END
GO
/*
DECLARE @IsSuccess BIT,@Message NVARCHAR(MAX);
EXEC PR_PLAN_Reserve_Capacity 'AUNA','LT',1,1,1,0,'2018-04-16 12:07:25.090','2018-05-15 12:07:25.090',20,20,'KATHMANDU\Krishna',0,@IsSuccess OUT,@Message OUT
PRINT @IsSuccess;
PRINT @Message;
*/

ALTER PROCEDURE [dbo].[PR_PLAN_Reserve_Capacity]
(
	@BreedingStationCode NVARCHAR(10),
	@CropCode NVARCHAR(10),
	@TestTypeID INT,
	@MaterialTypeID INT,
	@MaterialStateID INT,
	@Isolated BIT,
	@PlannedDate DateTime,
	@ExpectedDate DateTime,
	@NrOfPlates INT,
	@NrOfTests INT,
	@User NVARCHAR(200),
	@Forced BIT,
	@IsSuccess BIT OUT,
	@Message NVARCHAR(MAX) OUT
)
AS
BEGIN
	--SELECT * FROM TEST
	SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @MarkerTypeTestProtocolID INT =0, @DNATypeTestProtocolID INT =0, @PeriodID INT,@InRange BIT = 1, @SlotID INT, @NextPeriod INT, @CurrentPeriodEndDate DATETIME,@NextPeriodEndDate DATETIME;
		DECLARE @ReservedPlates INT =0, @ReservedTests INT=0, @CapacityPlates INT =0, @CapacityTests INT=0;
		DECLARE @MaxSlotID INT, @SlotName NVARCHAR(100);
		
		IF(ISNULL(@Isolated,0) = 0) BEGIN
			SELECT TOP 1 @DNATypeTestProtocolID = TestProtocolID 
			FROM MaterialTypeTestProtocol
			WHERE MaterialTypeID = @MaterialTypeID AND CropCode = @CropCode;
		END
		ELSE BEGIN
			SELECT TOP 1 @DNATypeTestProtocolID = TestProtocolID 
			FROM TestProtocol
			WHERE Isolated = 1;
		END


		IF EXISTS(SELECT TOP 1 TestTypeID FROM TestType WHERE TestTypeID = @TestTypeID AND DeterminationRequired = 1) BEGIN
			SELECT TOP 1 @MarkerTypeTestProtocolID = TestProtocolID 
			FROM TestProtocol
			WHERE TestTypeID = @TestTypeID;
		END
		
			
		SELECT TOP 1 @CurrentPeriodEndDate = EndDate
		FROM [Period]
		WHERE CAST(GETUTCDATE() AS DATE) BETWEEN StartDate AND EndDate

		SELECT TOP 1 @PeriodID = PeriodID
		FROM [Period]
		WHERE @PlannedDate BETWEEN StartDate AND EndDate

 

		IF(ISNULL(@DNATypeTestProtocolID,0)=0) BEGIN
			EXEC PR_ThrowError 'No valid protocol found for selected material type and crop';
			RETURN;
		END

		IF(ISNULL(@PeriodID,0)=0) BEGIN
			EXEC PR_ThrowError 'No period found for selected date';
			RETURN;
		END

		SELECT TOP 1 @NextPeriod = PeriodID,
		@NextPeriodEndDate = EndDate
		FROM [Period]
		WHERE StartDate > @CurrentPeriodEndDate
		ORDER BY StartDate;

		IF(ISNULL(@NextPeriod,0)=0) BEGIN
			EXEC PR_ThrowError 'No Next period found for selected date';
			RETURN;
		END

		IF(@PlannedDate  <= @NextPeriodEndDate) BEGIN			
			SET @InRange = 0;
			SET @IsSuccess = 0;
			SET @Message = 'Reservation time is too short. Do you want to request for reservation anyway?';
			IF(@Forced = 0)
				RETURN;
		END

		--get reserved tests if selected testtype is marker tests
		SELECT 
			@ReservedTests = SUM(RS.NrOfTests)
		FROM ReservedCapacity RS 
		JOIN Slot S ON S.SlotID = RS.SlotID
		WHERE S.PeriodID = @PeriodID AND S.StatusCode = 200 AND TestProtocolID = @MarkerTypeTestProtocolID --Only Approved slots can be treated as Reserved

		SET @ReservedTests = ISNULL(@ReservedTests,0);
		
		--WHERE S.PeriodID = @PeriodID AND S.StatusCode = 200 AND TestProtocolID IS NULL

		--get reserved plates for selected material type and crop
		SELECT 
			@ReservedPlates = SUM(RS.NrOfPlates)
		FROM ReservedCapacity RS 
		JOIN Slot S ON S.SlotID = RS.SlotID
		WHERE S.PeriodID = @PeriodID AND S.StatusCode = 200 AND TestProtocolID = @DNATypeTestProtocolID --Only Approved slots can be treated as Reserved

		SET @ReservedPlates = ISNULL(@ReservedPlates,0);
		

		--get total capacity (Test/Marker) per period only but to become to have data on db we added method.
		SELECT 
			@CapacityTests = NrOfTests
		FROM AvailCapacity
		WHERE PeriodID = @PeriodID AND TestProtocolID = @MarkerTypeTestProtocolID;

		SET @CapacityTests = ISNULL(@CapacityTests,0);

		--Get Total capacity( plates) PER period PER Method.
		SELECT 
			@CapacityPlates = NrOfPlates
		FROM AvailCapacity
		WHERE PeriodID = @PeriodID AND TestProtocolID = @DNATypeTestProtocolID;

		SET @CapacityPlates = ISNULL(@CapacityPlates,0);

		--for isolated check no of test(markers) and ignore no of plates.
		IF(ISNULL(@Isolated,0) =1) BEGIN
			IF((@ReservedTests + @NrOfTests) > @CapacityTests) BEGIN
				SET @InRange = 0;
			END
		END
		--for marker test type protocol we have to check both no of plates and no of tests(markers)
		ELSE IF(ISNULL(@MarkerTypeTestProtocolID,0) <> 0) BEGIN			
			IF(((@ReservedTests + @NrOfTests) > @CapacityTests) OR ( (@ReservedPlates + @NrOfPlates) > @CapacityPlates)) BEGIN
				SET @InRange = 0;
			END
		END
		--for dna  test type protocol we have to check only no plates not no of tests(markers)		
		ELSE BEGIN			
			IF(@ReservedPlates + @NrOfPlates > @CapacityPlates) BEGIN
				SET @InRange = 0;
			END
		END

		--do not create data if not in range and forced bit is false.
		IF(@Forced = 0 AND @InRange = 0) BEGIN
			SET @IsSuccess = 0;
			SET @Message = 'Reservation quota is already occupied. Do you want to reserve this capacity anyway?';
			RETURN;
		END

		BEGIN TRANSACTION;
			SELECT @MaxSlotID = ISNULL(IDENT_CURRENT('Slot'),0) + 1
			FROM Slot;

			IF(ISNULL(@MaxSlotID,0) = 0) BEGIN
				SET @MaxSlotID = 1;
			END

			SET @SlotName = @BreedingStationCode + '-' + @CropCode + '-' + RIGHT('00000'+CAST(@MaxSlotID AS NVARCHAR(10)),5);
			--on this case create slot and reserved capacity data			
			IF(@InRange = 1) BEGIN

				INSERT INTO Slot(SlotName, PeriodID, StatusCode, CropCode, MaterialTypeID, MaterialStateID, RequestUser, RequestDate, PlannedDate, ExpectedDate,BreedingStationCode,Isolated)
				VALUES(@SlotName,@PeriodID,'200',@CropCode,@MaterialTypeID,@MaterialStateID,@User,GetUTCDate(),@PlannedDate,@ExpectedDate,@BreedingStationCode,@Isolated);

				SELECT @SlotID = SCOPE_IDENTITY();

				SET @IsSuccess = 1;
				SET @Message = 'Reservation for '+ @SlotName + ' is completed.';				
			END
			ELSE IF(@Forced = 1 AND @InRange = 0) BEGIN				
				--create logic here....				
				INSERT INTO Slot(SlotName, PeriodID, StatusCode, CropCode, MaterialTypeID, MaterialStateID, RequestUser, RequestDate, PlannedDate, ExpectedDate,BreedingStationCode,Isolated)
				VALUES(@SlotName,@PeriodID,'100',@CropCode,@MaterialTypeID,@MaterialStateID,@User,GetUTCDate(),@PlannedDate,@ExpectedDate,@BreedingStationCode,@Isolated);

				SELECT @SlotID = SCOPE_IDENTITY();	

				SET @IsSuccess = 1;
				SET @Message = 'Your request for '+ @SlotName + ' is pending. You will get notification after action from LAB.';		
			END

			--create reserve capacity here based on two protocols
			IF(ISNULL(@MarkerTypeTestProtocolID,0) <> 0) BEGIN
				INSERT INTO ReservedCapacity(SlotID, TestProtocolID, NrOfTests)
				VALUES(@SlotID,@MarkerTypeTestProtocolID,@NrOfTests);
			END
			INSERT INTO ReservedCapacity(SlotID, TestProtocolID, NrOfPlates)
			VALUES(@SlotID,@DNATypeTestProtocolID,@NrOfPlates);
						

		COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH

END
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_SaveCapacity]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_PLAN_SaveCapacity]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_PLAN_SaveCapacity] AS' 
END
GO
-- =============================================
-- Author:		Binod Gurung
-- Create date: 2018/03/12
-- Description:	Save Capacity
-- =============================================
ALTER PROCEDURE [dbo].[PR_PLAN_SaveCapacity]
(
	@TVP_Capacity TVP_PLAN_Capacity READONLY
)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @MarkerTypeTestProtocolID INT = 0;

	BEGIN TRY
		BEGIN TRANSACTION;
		
		--Find TestProtocolID for Marker Test
		SELECT 
			@MarkerTypeTestProtocolID = TP.TestProtocolID 
		FROM TestProtocol TP
		JOIN TestType TT ON TT.TestTypeID = TP.TestTypeID
		WHERE TT.DeterminationRequired = 1
						
		-- Insert / Update NrOfTests (For Marker Test)
		MERGE INTO AvailCapacity T
		USING 
		(
			SELECT * FROM @TVP_Capacity 
			WHERE ISNUMERIC(PivotedColumn) = 1 AND PivotedColumn = @MarkerTypeTestProtocolID
		) S
		ON T.PeriodID = S.PeriodID AND T.TestProtocolID = @MarkerTypeTestProtocolID
		WHEN NOT MATCHED THEN
			INSERT 
			(
				PeriodID, 
				TestProtocolID,
				NrOfTests
			)
			VALUES 
			(
				S.PeriodID, 
				CAST(PivotedColumn AS INT),
				CAST([Value] AS INT )
			)

		WHEN MATCHED THEN
			UPDATE
			SET T.NrOfTests  = CAST([Value] AS INT ) ;

		--Insert / Update NrOfPlates (For DNA Isolation)
		MERGE INTO AvailCapacity T
		USING 
		(
			SELECT * FROM @TVP_Capacity 
			WHERE ISNUMERIC(PivotedColumn) = 1 AND PivotedColumn <> @MarkerTypeTestProtocolID
		) S
		ON T.PeriodID = S.PeriodID AND T.TestProtocolID = CAST(S.PivotedColumn AS INT)
		WHEN NOT MATCHED THEN
			INSERT 
			(
				PeriodID, 
				TestProtocolID, 
				NrOfPlates
			)
			VALUES 
			(
				S.PeriodID, 
				CAST(PivotedColumn AS INT),
				CAST([Value] AS INT )
			)

		WHEN MATCHED THEN
			UPDATE
			SET T.NrOfPlates = CAST([Value] AS INT ) ;

		--Update Remark
		MERGE INTO Period T
		USING 
		(
			SELECT PeriodID, [Value] FROM @TVP_Capacity 
			WHERE PivotedColumn = 'remark'
		) S
		ON T.PeriodID = S.PeriodID
		WHEN MATCHED THEN
			UPDATE
			SET T.Remark = S.[Value] ;
		
		COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH
    
END
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_Update_Slot_Period]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_PLAN_Update_Slot_Period]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_PLAN_Update_Slot_Period] AS' 
END
GO

ALTER PROCEDURE [dbo].[PR_PLAN_Update_Slot_Period]
(
	@SlotID INT,
	@PlannedDate DATETIME,
	@ExpectedDate DATETIME
)
AS
BEGIN

	SET NOCOUNT ON;

	UPDATE SLOT
	SET PlannedDate  = @PlannedDate,
		ExpectedDate = @ExpectedDate
	WHERE SlotID = @SlotID

END
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_UpdateCapacitySlot]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_PLAN_UpdateCapacitySlot]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_PLAN_UpdateCapacitySlot] AS' 
END
GO
/*EXEC PR_PLAN_UpdateCapacitySlot 1, 100
*/
ALTER PROC [dbo].[PR_PLAN_UpdateCapacitySlot]
(
	@SlotID INT,
	@StatusCode INT
)
AS BEGIN
	--IF EXISTS (SELECT SlotID FROM Slot WHERE SlotID = @SlotID) BEGIN	
		UPDATE Slot Set StatusCode = @StatusCode 
		WHERE SlotID = @SlotID;
	--END

END
GO
/****** Object:  StoredProcedure [dbo].[PR_ReorderMaterial]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_ReorderMaterial]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_ReorderMaterial] AS' 
END
GO
ALTER PROCEDURE [dbo].[PR_ReorderMaterial]
(
	@TestID INT,
	@TVP_Material_Well	TVP_TMDW READONLY
)
AS BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF(ISNULL(@TestID,0)<>0) BEGIN
			IF EXISTS(SELECT StatusCode FROM Test WHERE StatusCode >= 400 AND TestID = @TestID) BEGIN
				EXEC PR_ThrowError 'Cannot change for this test.';
				RETURN;
			END
		END
		ELSE BEGIN
			EXEC PR_ThrowError 'Invalid test.';
			RETURN;
		END
		IF EXISTS(SELECT TMDW.MaterialID FROM @TVP_Material_Well TVP
			JOIN Well W ON W.WellID = TVP.WellID
			JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
			JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = TVP.WellID
			WHERE WellTypeName = 'F' AND TVP.MaterialID <> TMDW.MaterialID) BEGIN

			EXEC PR_ThrowError 'Fixed Well Can not be assigned to another material.';
			RETURN;
		END

		BEGIN TRANSACTION;
		UPDATE TMDW
		SET TMDW.MaterialID = MW.MaterialID
		FROM TestMaterialDeterminationWell TMDW
		JOIN @TVP_Material_Well MW ON MW.WellID = TMDW.WellID
		WHERE TMDW.MaterialID <> MW.MaterialID
		
		
	COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK;
		THROW;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[PR_Replicate_Material]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_Replicate_Material]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_Replicate_Material] AS' 
END
GO

/*
==================EXAMPLE============

DECLARE @TVP_Material TVP_Material_Rep
INSERT INTO @TVP_Material(MaterialID)
VALUES(5),(6);
DECLARE @TestID INT =76, @UserID NVARCHAR(200) = 'KATHMANDU\krishna', @NrOfReplicate INT = 2, @Collated BIT =1;
EXEC PR_Replicate_Material @TVP_Material,@TestID,@UserID,@NrOfReplicate,@Collated
 
*/
ALTER PROCEDURE [dbo].[PR_Replicate_Material]
(
	@TVP_Material TVP_Material_Rep READONLY,
	@TestID INT,
	@UserID NVARCHAR(200),
	@NrOfReplicate INT,
	@Collated BIT,
	@MaxPlates INT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ReturnValue INT,@MaterialToAdd INT,@ToReplicateMaterialCount INT, @TotalExistingMaterial INT,@TotalExistingMaterialExceptFixed INT,  @WellsCreated INT, @Count INT =0, @ReplicateCount INT =0, @MaterialID NVARCHAR(200), @Lastmaterial INT = 0, @AssignedWellType INT, @TVP_Material_Copy TVP_Material_Rep;
	DECLARE @LastPlateName NVARCHAR(200), @CreatePlateAndWell BIT = 0, @PlateID INT=0, @PlateIDLast INT =0, @FixedWellType INT;
	DECLARE @MaterialAll TVP_Material,@ExistingMaterial TVP_Material,@Well TVP_Material,@MaterialWithWell TVP_TMDW;
	DECLARE @FixedOnlyMaterial TVP_Material, @FixedOnlyWell TVP_Material, @FixedMaterialWithWell TVP_TMDW;
	DECLARE @WellsPerPlateWithoutFixed INT, @RequiredPlates INT, @CreatedPlates INT;
	BEGIN TRY
		IF(ISNULL(@TestID,0)=0) BEGIN
			EXEC PR_ThrowError 'Requested Test does not exist.';
			RETURN;
		END

		--check valid test.
		EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
		IF(@ReturnValue <> 1) BEGIN
			RETURN;
		END
		--check status for validation of changed column
		IF EXISTS(SELECT StatusCode FROM Test WHERE StatusCode >= 400 AND TestID = @TestID) BEGIN
			EXEC PR_ThrowError 'Cannot change Status for this test.';
			RETURN;
		END

		IF EXISTS( SELECT TOP 1 W.WellID FROM WELL W
			JOIN Plate P ON P.PlateID = W.PlateID
			JOIN WellTYpe WT ON WT.WellTypeID = W.WellTypeID
			WHERE P.TestID = @TestID AND WT.WellTYpeName = 'D') BEGIN
				EXEC PR_ThrowError 'Replica cannot be completed. Remove dead material first.';
				RETURN;
		END

		IF EXISTS(	SELECT TOP 1 T1.MaterialID FROM TestMaterialDeterminationWell TMDW 
			JOIN @TVP_Material T1 ON T1.MaterialID = TMDW.MaterialID
			JOIN Well W ON W.WellID = TMDW.WellID
			JOIN Plate P ON P.PlateID = W.PlateID
			JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
			WHERE WT.WellTypeName IN ('F','D') AND P.TestID = @TestID) BEGIN

			EXEC PR_ThrowError 'Cannot create replica of dead or fixed positioned material';
			RETURN;
		END

		IF EXISTS(SELECT MaterialID FROM @TVP_Material GROUP BY MaterialID Having COUNT(MaterialID) >1) BEGIN
			EXEC PR_ThrowError 'Duplicate material is selected.';
			RETURN;
		END

		SELECT @ToReplicateMaterialCount = COUNT(*) FROM @TVP_Material;
		SELECT @TotalExistingMaterial = COUNT(MaterialID) FROM TestMaterialDeterminationWell TMDW 
			JOIN Well W ON W.WellID = TMDW.WellID
			JOIN Plate P ON P.PlateID = W.PlateID
			WHERE P.TestID = @TestID;

		SELECT @TotalExistingMaterialExceptFixed = COUNT(MaterialID) FROM TestMaterialDeterminationWell TMDW 
		JOIN Well W ON W.WellID = TMDW.WellID
		JOIN Plate P ON P.PlateID = W.PlateID
		JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
		WHERE P.TestID = @TestID AND WT.WellTypeName != 'F';

		SET @MaterialToAdd = @ToReplicateMaterialCount * @NrOfReplicate;

		SELECT @WellsCreated = COUNT(WellID) FROM WELL W 
			JOIN Plate P ON P.PlateID = W.PlateID
			WHERE P.TestID = @TestID;

		IF(@TotalExistingMaterial + @MaterialToAdd > @WellsCreated) BEGIN
			IF EXISTS(SELECT StatusCode FROM Test WHERE StatusCode >= 200 AND TestID = @TestID) BEGIN
				EXEC PR_ThrowError 'Replica cannot be completed. This requires more plates than reserved on from LIMS.';
				RETURN;
			END
			--new plate and well is required on else condition
			ELSE BEGIN
				SELECT TOP 1 @LastPlateName =LEFT(PlateName, LEN(PlateName) -2) + RIGHT('000' + CAST((CAST(RIGHT(PlateName,2) AS INT) +1) AS NVARCHAR(5)),2),
				@PlateIDLast = PlateID
				FROM Plate
				WHERE TestID = @TestID
				ORDER BY PlateID DESC;

				SELECT @CreatedPlates = COUNT(PlateID)
				FROM Plate
				WHERE TestID = @TestID;

				SELECT @WellsPerPlateWithoutFixed = Count(WellID)
				FROM Well W
				JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
				WHERE PlateID = @PlateIDLast AND WT.WellTypeName != 'F';


				SELECT @RequiredPlates = CEILING (CAST(@TotalExistingMaterialExceptFixed + @MaterialToAdd  AS FLOAT) / CAST(@WellsPerPlateWithoutFixed AS FLOAT))

				IF(@RequiredPlates > @MaxPlates) BEGIN
					DECLARE @Error NVARCHAR(MAX) = 'Replica cannot be completed. Maximum of '+ CAST(@MaxPlates AS NVARCHAR(10)) + ' plates can be used for test. This requires more than ' + CAST(@MaxPlates AS NVARCHAR(10)) + ' plates.';
					EXEC PR_ThrowError @Error
					RETURN;
				END
				SET @CreatePlateAndWell = 1;
			END			
		END 

		BEGIN TRANSACTION;
			SET NOCOUNT ON;
			
			--if condition to create plate begin
			IF(@CreatePlateAndWell = 1) BEGIN						
				--NEW Plates and well will be created
				SELECT @FixedWellType = WellTypeID 
				FROM WellType WHERE WellTypeName = 'F';

				--while loop to create required plates and well begin
				WHILE (@CreatedPlates < @RequiredPlates) BEGIN
					SET @CreatedPlates = @CreatedPlates +1;
					
					SELECT TOP 1 @LastPlateName =LEFT(PlateName, LEN(PlateName) -2) + RIGHT('000' + CAST((CAST(RIGHT(PlateName,2) AS INT) +1) AS NVARCHAR(5)),2),
					@PlateIDLast = PlateID
					FROM Plate
					WHERE TestID = @TestID
					ORDER BY PlateID DESC;

					--Create new plates
					INSERT INTO Plate ( PlateName,TestID)
					VALUES(@LastPlateName,@TestID);
					
					SELECT @PlateID = @@IDENTITY;			
					--create well
					INSERT INTO Well(WellTypeID,Position,PlateID)
					SELECT WellTypeID,Position,@PlateID
					FROM Well W
					JOIN Plate P ON P.PlateID = W.PlateID
					WHERE P.PlateID = @PlateIDLast
					ORDER BY WellID;

					DELETE FROM  @FixedOnlyMaterial;
					--GET fixed only Material id
					INSERT INTO @FixedOnlyMaterial(MaterialID)
					SELECT MaterialID
					FROM TestMaterialDeterminationWell TMDW
					JOIN Well W ON W.WellID = TMDW.WellID
					JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
					WHERE W.PlateID = @PlateIDLast AND WT.WellTypeName = 'F'
					ORDER BY W.Position;		

					DELETE FROM @FixedOnlyWell;
					--GET fixed only well id
					INSERT INTO @FixedOnlyWell(MaterialID)
					SELECT W.WellID
					FROM Well W 
					--JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID
					JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
					WHERE WT.WellTypeName = 'F' AND W.PlateID = @PlateID
					ORDER BY W.Position;

					DELETE FROM  @FixedMaterialWithWell;
					--merge this two temp table
					INSERT INTO @FixedMaterialWithWell(MaterialID, WellID)
					SELECT M.MaterialID, W.MaterialID
					FROM @FixedOnlyMaterial M 
					JOIN @FixedOnlyWell W ON W.RowNr = M.RowNr;

					--INSERT INTO TMDW for fixed only material
					INSERT INTO TestMaterialDeterminationWell(MaterialID,WellID)
					SELECT MaterialID,WellID 
					FROM @FixedMaterialWithWell;

				END
				--While loop to create required plates and well ends

				
					
			END
			--if condition to create plate ends

			--create a copy TVP for TVP provided on parameter which is readonly
			INSERT INTO @TVP_Material_Copy
			SELECT MaterialID 
			FROM @TVP_Material;			

			--get all material without fixed material
			INSERT INTO @ExistingMaterial (MaterialID)
			SELECT MaterialID
			FROM 
			(
				SELECT MaterialID
				,Position,Position2,Position1,PlateID
				FROM 
				(
					SELECT Position, MaterialID,W.PlateID,
					CAST(RIGHT(Position,LEN(Position)-1) AS INT) AS Position1, -- this is column number
					CAST(ASCII(LEFT(Position,1)) -65 AS INT) as Position2 -- this is row number
					FROM Well W
					JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID
					JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
					JOIN Plate P ON P.PlateID = W.PlateID
					WHERE P.TestID = @TestID AND WT.WellTypeName !='F'
					
				) T
			) T1
			ORDER BY PlateID, Position2, Position1

			--get ordered well without fixed well 
			INSERT INTO @Well(MaterialID)
			SELECT T.WellID
			FROM 
			(
				SELECT W.*, CAST(RIGHT(Position,LEN(Position)-1) AS INT) AS Position1
				,LEFT(Position,1) as Position2
				FROM Well W
				JOIN Plate P ON P.PlateID = W.PlateID
				JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
				WHERE P.TestID = @TestID AND WT.WellTypeName != 'F'				
			) T
			ORDER BY PlateID,Position2,Position1

			--collated Logic BEGIN Here
			IF(@Collated = 1) BEGIN

				--First get last material id so that we can insert data after that row number
				SELECT @Lastmaterial = MAX(RowNr) 
				FROM @ExistingMaterial 
				WHERE MaterialID IN (SELECT DISTINCT MaterialID FROM @TVP_Material)

				INSERT INTO @MaterialAll (MaterialID)
				SELECT MaterialID
				FROM @ExistingMaterial 
				WHERE RowNr <= @Lastmaterial
				ORDER BY RowNr;

				SET @ReplicateCount = 0;
				WHILE(@ReplicateCount < @NrOfReplicate) BEGIN

					INSERT INTO @MaterialAll (MaterialID)
					SELECT MaterialID
					FROM 
					(
						SELECT MaterialID,Max(RowNr) AS RowNr
						FROM @ExistingMaterial WHERE MaterialID IN (SELECT MaterialID FROM @TVP_Material)						
						GROUP BY MaterialID
					) T					
					ORDER BY T.RowNr;

					SET @ReplicateCount = @ReplicateCount +1;
				END					
				--While end.

				--insert all material after last material id we fetched before while loop 
				INSERT INTO @MaterialAll (MaterialID)
				SELECT MaterialID
				FROM @ExistingMaterial 
				WHERE RowNr > @Lastmaterial
				ORDER BY RowNr;

				INSERT INTO @MaterialWithWell(MaterialID,WellID)
				SELECT M.MaterialID,W.MaterialID
				FROM @Well W
				JOIN @MaterialAll M ON M.RowNr = W.RowNr


				MERGE TestMaterialDeterminationWell T
				USING @MaterialWithWell S
				ON T.WellID = S.WellID
				WHEN NOT MATCHED
				THEN INSERT (MaterialID,WellID)
				VALUES (S.MaterialID,S.WellID);

				MERGE TestMaterialDeterminationWell T
				USING @MaterialWithWell S
				ON T.WellID = S.WellID AND T.MaterialID <> S.MaterialID
				WHEN MATCHED
				THEN UPDATE SET T.MaterialID = S.MaterialID;

				--Update well type to assigned
				SELECT @AssignedWellType = WellTypeID 
				FROM WELLType WHERE WellTypeName = 'A'

				UPDATE W
				SET W.WellTypeID = @AssignedWellType
				FROM Well W 
				JOIN @MaterialWithWell MW ON MW.WellID = W.WellID
				WHERE W.WellTypeID != @AssignedWellType

			END
			--collated Logic END Here 

			--Uncollated Logic Here
			ELSE BEGIN
				SET @Count = 1;
				WHILE(@Count <= @TotalExistingMaterialExceptFixed) BEGIN
					SELECT @MaterialID = MaterialID FROM @ExistingMaterial WHERE RowNr = @Count
					IF EXISTS( SELECT MaterialID FROM @TVP_Material_Copy WHERE MaterialID = @MaterialID) BEGIN
						SET @ReplicateCount = 0;
						
						WHILE(@ReplicateCount < @NrOfReplicate) BEGIN

							INSERT INTO @MaterialAll (MaterialID)
							VALUES(@MaterialID);

							SET @ReplicateCount = @ReplicateCount +1;
						END	
						--WHILE ENDS				
						DELETE FROM @TVP_Material_Copy
						WHERE MaterialID = @MaterialID
						
					END
					--IF ENDS
					INSERT INTO @MaterialAll (MaterialID)
					VALUES(@MaterialID)				
					SET @Count = @Count + 1;
					
				END
				--WHILE LOOP ENDS

				INSERT INTO @MaterialWithWell(MaterialID,WellID)
				SELECT M.MaterialID,W.MaterialID
				FROM @Well W
				JOIN @MaterialAll M ON M.RowNr = W.RowNr
				
				MERGE TestMaterialDeterminationWell T
				USING @MaterialWithWell S
				ON T.WellID = S.WellID
				WHEN NOT MATCHED
				THEN INSERT (MaterialID,WellID)
				VALUES (S.MaterialID,S.WellID);

				MERGE TestMaterialDeterminationWell T
				USING @MaterialWithWell S
				ON T.WellID = S.WellID AND T.MaterialID <> S.MaterialID
				WHEN MATCHED
				THEN UPDATE SET T.MaterialID = S.MaterialID;

				--Update well type to assigned
				SELECT @AssignedWellType = WellTypeID 
				FROM WELLType WHERE WellTypeName = 'A'

				UPDATE W
				SET W.WellTypeID = @AssignedWellType
				FROM Well W 
				JOIN @MaterialWithWell MW ON MW.WellID = W.WellID
				WHERE W.WellTypeID != @AssignedWellType
			END
			--Uncollated Logic ENDS
		COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK;
		THROW;
	END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[PR_Save_RelationTraitDetermination]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_Save_RelationTraitDetermination]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_Save_RelationTraitDetermination] AS' 
END
GO
--DROP PROC PR_Save_RelationTraitDetermination
ALTER PROCEDURE [dbo].[PR_Save_RelationTraitDetermination]
(
	@TVP_RelationTraitDetermination TVP_RelationTraitDetermination READONLY
)
AS
BEGIN
	SET NOCOUNT ON;
	--INsert Statement

	--IF EXISTS (SELECT R.RelationID 
	--	FROM RelationTraitDetermination R 
	--	JOIN  @TVP_RelationTraitDetermination T1 
	--	--ON T1.DeterminationID = R.DeterminationID AND R.Source=T1.Source AND R.TraitID = T1.TraitID
	--	ON R.TraitID = T1.TraitID
	--	WHERE T1.[Action] = 'I') BEGIN

	--	EXEC PR_ThrowError 'Insert Failed. Relation already exists.';
	--	RETURN;
	--END

	--IF EXISTS (SELECT R.RelationID 
	--	FROM RelationTraitDetermination R 
	--	JOIN  @TVP_RelationTraitDetermination T1 
	--	--ON T1.DeterminationID = R.DeterminationID AND R.Source=T1.Source AND R.TraitID = T1.TraitID AND R.RelationID != T1.RelationID
	--	ON R.TraitID = T1.TraitID AND R.RelationID != T1.RelationID
	--	WHERE T1.[Action] = 'U') BEGIN

	--	EXEC PR_ThrowError 'Update Failed.Relation already exists.';
	--	RETURN;
	--END

	INSERT INTO RelationTraitDetermination(TraitID, ColumnLabel, DeterminationID, [Status])
	SELECT T1.TraitID, T1.TraitName, D.DeterminationID, 'ACT'
	FROM @TVP_RelationTraitDetermination T1
	JOIN Determination D ON D.DeterminationID = T1.DeterminationID
	WHERE ISNULL(T1.RelationID, 0) = 0 AND T1.[Action] = 'I';

	--UPdate Statement 
	--We send Action = 'D' For Delete.
	UPDATE R SET 
		R.DeterminationID = T1.DeterminationID
	FROM @TVP_RelationTraitDetermination T1 
	JOIN RelationTraitDetermination R ON R.RelationID = T1.RelationID
	WHERE T1.[Action] = 'U';


	--DELETE Statement 
	DELETE R
	FROM @TVP_RelationTraitDetermination T1 
	JOIN RelationTraitDetermination R ON R.RelationID = T1.RelationID
	WHERE T1.[Action] = 'D';
	
END
GO
/****** Object:  StoredProcedure [dbo].[PR_Save_Score]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_Save_Score]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_Save_Score] AS' 
END
GO

ALTER PROCEDURE [dbo].[PR_Save_Score]
(
	@TestID INT,
	@TVP_ScoreResult TVP_ScoreResult READONLY
) AS

BEGIN
SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
					
			INSERT INTO TestResult(WellID, DeterminationID, ObsValueChar, ObsValueInt, ObsValueDate, ObsValueDec)
			SELECT W.WellID,D.DeterminationID,
				CASE WHEN ISNULL(D.DataType, 'CHR') = 'CHR' THEN ScoreVal ELSE NULL END,
				CASE WHEN ISNULL(D.DataType, 'CHR') = 'INT' THEN ScoreVal ELSE NULL END,
				CASE WHEN ISNULL(D.DataType, 'CHR') = 'DAT' THEN ScoreVal ELSE NULL END,
				CASE WHEN ISNULL(D.DataType, 'CHR') = 'DEC' THEN ScoreVal ELSE NULL END
			FROM @TVP_ScoreResult T1
			JOIN Well W ON W.Position = T1.Position 
			JOIN Plate P ON P.PlateID = W.PlateID
			JOIN Determination D on D.DeterminationID = T1.Determination
			JOIN TestMaterialDetermination TMD ON TMD.DeterminationID = D.DeterminationID AND TMD.TestID = P.TestID --TMD contains multiple materials for single determination which will fetch multipe result so group by needed.
			WHERE P.LabPlateID = T1.LimsPlateID
			AND P.TestID = @TestID
			GROUP BY W.WellID, D.DeterminationID, D.DataType, T1.ScoreVal;

			UPDATE Test SET StatusCode = 600 WHERE TestID = @TestID;

			
		COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK;
		THROW;
	END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[PR_Save_SlotTest]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_Save_SlotTest]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_Save_SlotTest] AS' 
END
GO

ALTER PROCEDURE [dbo].[PR_Save_SlotTest]
(
	@TestID INT,
	@UserID NVARCHAR(200),
	@SlotID INT
) AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnValue INT;
	EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
	IF(@ReturnValue <> 1) BEGIN
		RETURN;
	END

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
				UPDATE SlotTest SET SlotID = @SlotID;
			END
			ELSE BEGIN
				INSERT INTO SlotTest(SlotID, TestID)
				VALUES(@SlotID, @TestID)	
			END			
			--UPdate test status to 150 meaning status changed from created to slot consumed.
			EXEC PR_Update_TestStatus @TestID, 150;

		COMMIT TRAN;
		--Get test detail
		EXEC PR_GetTestDetail @TestID, @UserID;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK;
		THROW;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[PR_SavePlannedDate]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_SavePlannedDate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_SavePlannedDate] AS' 
END
GO
ALTER PROCEDURE [dbo].[PR_SavePlannedDate]
(
	@TestID INT,
	@UserID	NVARCHAR(100),
	@PlannedDate DATETIME
) AS
BEGIN
	
	DECLARE @ReturnValue INT;
	EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
	IF(@ReturnValue <> 1) BEGIN		
		RETURN;
	END

	UPDATE Test
	SET PlannedDate = @PlannedDate
	WHERE TestID = @TestID
END
GO
/****** Object:  StoredProcedure [dbo].[PR_SaveRemark]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_SaveRemark]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_SaveRemark] AS' 
END
GO
ALTER PROCEDURE [dbo].[PR_SaveRemark]
(
	@TestID INT,
	@Remark NVARCHAR(MAX)
)
AS BEGIN
	IF NOT EXISTS(SELECT TestID FROM Test WHERE TestID = @TestID) BEGIN
		EXEC PR_ThrowError 'Invalid test.';
		RETURN;
	END
	IF EXISTS(SELECT TestID FROM Test WHERE TestID = @TestID AND StatusCode >=400) BEGIN
		EXEC PR_ThrowError 'Can not save remark for this test.';
		RETURN;
	END
	UPDATE Test
	SET Remark = @Remark
	WHERE TestID = @TestID
END
GO
/****** Object:  StoredProcedure [dbo].[PR_SaveTestMaterialDetermination]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_SaveTestMaterialDetermination]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_SaveTestMaterialDetermination] AS' 
END
GO
/*
Author:			KRISHNA GAUTAM
Created Date:	2017-DEC-06
Updated Date:	2018-JAN-11
Description:	Save test material determination. */

/*
=================Example===============

*/
ALTER PROCEDURE [dbo].[PR_SaveTestMaterialDetermination]
(
	@UserID								NVARCHAR(200),
	@TestTypeID							INT,
	@TestID								INT,
	@Columns							NVARCHAR(MAX) = NULL,
	@Filter								NVARCHAR(MAX) = NULL,
	@TVPM TVP_TMD						READONLY,	
	@Determinations TVP_Determinations	READONLY
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @FileName NVARCHAR(100);
	DECLARE @Tbl TABLE (MaterialID INT, MaterialKey NVARCHAR(50));
	DECLARE @CropCode	NVARCHAR(10),@TestType1 INT,@StatusCode INT;
	DECLARE @FileID		INT;


	BEGIN TRY
		BEGIN TRANSACTION;
		SELECT 
			@FileID = F.FileID,
			@FileName = F.FileTitle,
			@CropCode = CropCode,
			@TestType1 = T.TestTypeID,
			@StatusCode = T.StatusCode
		FROM [File] F
		JOIN Test T ON T.FileID = F.FileID AND T.RequestingUser = F.UserID 
		WHERE T.TestID = @TestID AND F.UserID = @UserID;

		IF(ISNULL(@FileName, '') = '') BEGIN
			EXEC PR_ThrowError 'Specified file not found';
			RETURN;
		END
		IF(ISNULL(@CropCode,'')='')
		BEGIN
			EXEC PR_ThrowError 'Specified crop not found';
			RETURN;
		END
		--Prevent changing testType when user choose different type of test after creating test.
		IF(ISNULL(@TestTypeID,0) <> ISNULL(@TestType1,0)) BEGIN
			EXEC PR_ThrowError 'Cannot assign different test type for already created test.';
			RETURN;
		END
		--Prevent asigning determination when status is changed to point of no return
		IF(ISNULL(@StatusCode,0) >=400) BEGIN
			EXEC PR_ThrowError 'Cannot assign determination for confirmed test.';
			RETURN;
		END

		IF EXISTS (SELECT 1 FROM @Determinations) BEGIN
			EXEC  PR_SaveTestMaterialDeterminationWithQuery @FileID, @UserID, @CropCode, @TestID, @Columns, @Filter, @Determinations
		END
		ELSE BEGIN
			EXEC  PR_SaveTestMaterialDeterminationWithTVP @CropCode, @TestID, @TVPM
		END

		IF EXISTS(SELECT TestID FROM Test WHERE StatusCode = 300 AND TestID = @TestID) BEGIN
			EXEC PR_Update_TestStatus @TestID, 350;
		END
		SELECT TestID, StatusCode 
		FROM Test WHERE TestID = @TestID;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		THROW;
	END CATCH	
END




GO
/****** Object:  StoredProcedure [dbo].[PR_SaveTestMaterialDeterminationWithQuery]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_SaveTestMaterialDeterminationWithQuery]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_SaveTestMaterialDeterminationWithQuery] AS' 
END
GO
/*
Author:			KRISHNA GAUTAM
Created Date:	2017-DEC-05
Updated Date:	2071-DEC-06
Description:	Save test material determination. */

/*
=================Example===============
DECLARE @T1 TVP_Determinations
INSERT INTO @T1 VALUES(1);
INSERT INTO @T1 VALUES(6);
--EXEC PR_SaveTestMaterialDeterminationWithQuery 38,'KATHMANDU\dsuvedi', 1, '[960],[crop]', '[960]   LIKE  ''%9%''   and [Crop]   LIKE  ''%TO%'''
EXEC PR_SaveTestMaterialDeterminationWithQuery 38,'KATHMANDU\dsuvedi', 1, '''712'',''715'',''Lotnr''', '', @T1
*/
ALTER PROCEDURE [dbo].[PR_SaveTestMaterialDeterminationWithQuery]
(
	@FileID			INT,	
	@UserID			NVARCHAR(50),
	@CropCode		NVARCHAR(10),
	@TestID			INT,
	@Columns		NVARCHAR(MAX) = NULL,
	@Filter	NVARCHAR(MAX) = NULL,
	@Determinations TVP_Determinations READONLY
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @ColumnQuery	NVARCHAR(MAX);
	DECLARE @Query			NVARCHAR(MAX);
	DECLARE @FilterClause	NVARCHAR(MAX)
	DECLARE @ColumnIDs		NVARCHAR(MAX);
	DECLARE @SelectColumns	NVARCHAR(MAX);
	DECLARE @TraitIDs		NVARCHAR(MAX);
	DECLARE @Tbl			TABLE (MaterialID INT, MaterialKey NVARCHAR(50));
	DECLARE @ColumnTable	TABLE([ColumnID] INT, [ColumnName] NVARCHAR(100));
	DECLARE @MaterialTable	TABLE(MaterialKey NVARCHAR(100));


	IF(ISNULL(@Filter,'') <> '') BEGIN
		SET @FilterClause = ' AND '+ @Filter
	END
	ELSE BEGIN
		SET @FilterClause = '';
	END
	IF(ISNULL(@Columns,'') <> '') BEGIN
		SET @ColumnQuery = N'
			SELECT ColumnID,ColumnName 
			FROM 
			(
				SELECT ColumnID,COALESCE(CAST(TraitID AS NVARCHAR) ,ColumLabel,'''') as ColumnName FROM [COLUMN]
				WHERE FileID = @FileID 
			) AS T			
			WHERE ColumnName in ('+@Columns+');';

			--PRINT @ColumnQuery;

		INSERT INTO @ColumnTable ([ColumnID],[ColumnName])
		EXEC sp_executesql @ColumnQuery, N'@FileID INT', @FileID;
		
		SELECT 
			@SelectColumns  = COALESCE(@SelectColumns + ',', '') + QUOTENAME([ColumnID])+ ' AS ' + QUOTENAME([ColumnName]),
			@ColumnIDs = COALESCE(@ColumnIDs + ',', '') + QUOTENAME([ColumnID])
		FROM @ColumnTable
		
		SET @Query = N'		
		SELECT R.[MaterialKey]
		FROM [ROW] R		
		LEFT JOIN 
		(
			SELECT PT.[MaterialKey], PT.[RowNr], ' + @SelectColumns + ' 
			FROM
			(
				SELECT *
				FROM 
				(
					SELECT 
						T3.[MaterialKey],T3.RowNr,T1.[ColumnID], T1.[Value]
					FROM [Cell] T1
					JOIN [Column] T2 ON T1.ColumnID = T2.ColumnID
					JOIN [Row] T3 ON T3.RowID = T1.RowID
					JOIN [FILE] T4 ON T4.FileID = T3.FileID
					WHERE T2.FileID = @FileID AND T4.UserID = @UserID
				) SRC
				PIVOT
				(
					Max([Value])
					FOR [ColumnID] IN (' + @ColumnIDs + ')
				) PIV
			) AS PT 					
		) AS T1	ON R.[MaterialKey] = T1.MaterialKey  				
			WHERE R.FileID = @FileID ' + @FilterClause + '';

		--PRINT @Query

		INSERT INTO @MaterialTable ([MaterialKey])		
		EXEC sp_executesql @Query, N'@FileID INT, @UserID NVARCHAR(100)', @FileID,@UserID;
	END
	ELSE BEGIN 
		INSERT INTO @MaterialTable ([MaterialKey])
		SELECT R.[MaterialKey]
		FROM [ROW] R
		WHERE R.FileID = @FileID	
	END;

	INSERT INTO @Tbl (MaterialID , MaterialKey)
	SELECT M.MaterialID, M.MaterialKey 
	FROM Material M
	JOIN @MaterialTable M2 ON M2.MaterialKey = M.MaterialKey;
		
	MERGE INTO TestMaterialDetermination T
	USING 
	( 
		SELECT 
			M.MaterialID, D.DeterminationID 
		FROM @Tbl M 
		CROSS JOIN @Determinations D 
	) S
	ON T.MaterialID = S.MaterialID AND T.TestID = @TestID AND T.DeterminationID = S.DeterminationID
	WHEN NOT MATCHED THEN 
	INSERT(TestID,MaterialID,DeterminationID) VALUES(@TestID,S.MaterialID,s.DeterminationID);
		
END
GO
/****** Object:  StoredProcedure [dbo].[PR_SaveTestMaterialDeterminationWithTVP]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_SaveTestMaterialDeterminationWithTVP]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_SaveTestMaterialDeterminationWithTVP] AS' 
END
GO
/*
Author:			KRISHNA GAUTAM
Created Date:	2017-DEC-06
Description:	Save test material determination. */

/*
=================Example===============

*/


ALTER PROCEDURE [dbo].[PR_SaveTestMaterialDeterminationWithTVP]
(	
	@CropCode		NVARCHAR(15),
	@TestID			INT,	
	@TVPM TVP_TMD	READONLY
) AS BEGIN
	SET NOCOUNT ON;	
	DECLARE @Tbl TABLE (MaterialID INT, MaterialKey NVARCHAR(50));

	INSERT INTO @Tbl (MaterialID, MaterialKey)
	SELECT M.MaterialID, M.MaterialKey
	FROM Material M
	JOIN
	(
		SELECT DISTINCT MaterialID 
		FROM @TVPM 
		--WHERE Selected = 1
	) M2 ON M2.MaterialID = M.MaterialID;

	--insert or delete statement for merge
	MERGE INTO TestMaterialDetermination T 
	USING 
	(
		SELECT T2.MaterialID,T1.DeterminationID,T1.Selected FROM @TVPM T1
		LEFT JOIN @Tbl T2 ON T1.MaterialID = T2.MaterialID			
	) S
	ON T.MaterialID = S.MaterialID  AND T.DeterminationID = S.DeterminationID AND T.TestID = @TestID
	WHEN NOT MATCHED BY TARGET AND S.Selected = 1 THEN 
		INSERT(TestID,MaterialID,DeterminationID) VALUES (@TestID,S.MaterialID,s.DeterminationID)
	WHEN MATCHED AND S.Selected = 0 AND T.MaterialID = S.MaterialID  AND T.DeterminationID = S.DeterminationID AND T.TestID = @TestID THEN 
	DELETE;	
END




GO
/****** Object:  StoredProcedure [dbo].[PR_SaveTraitDeterminationResult]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_SaveTraitDeterminationResult]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_SaveTraitDeterminationResult] AS' 
END
GO




ALTER PROCEDURE [dbo].[PR_SaveTraitDeterminationResult]
(
	@CropCode	NCHAR(2),
	@TVP		TVP_TraitDeterminationResult READONLY
) AS BEGIN
	SET NOCOUNT ON;
	--VALIDATION
	IF EXISTS
	(
		SELECT 
			T1.TraitDeterminationResultID
		FROM TraitDeterminationResult T1
		JOIN  @TVP T2 ON T2.TraitID = T1.TraitID AND T2.DeterminationID = T1.DeterminationID AND T2.TraitResChar = T1.TraitResChar
		WHERE T2.[Action] = 'I'
	) BEGIN
		EXEC PR_ThrowError 'Insert failed. Relation already exists.';
		RETURN;
	END

	IF EXISTS
	(
		SELECT 
			T1.TraitDeterminationResultID
		FROM TraitDeterminationResult T1
		JOIN  @TVP T2 ON T2.TraitID = T1.TraitID AND T2.DeterminationID = T1.DeterminationID AND T2.TraitResChar = T1.TraitResChar AND T2.TraitDeterminationResultID <> T1.TraitDeterminationResultID
		WHERE T2.[Action] = 'U'
	) BEGIN
		EXEC PR_ThrowError 'Update failed. Relation already exists.';
		RETURN;
	END


	--INSERT NEW 
	INSERT INTO TraitDeterminationResult([DeterminationID], [TraitID], [DetResChar], [TraitResChar])
	SELECT		
		T1.DeterminationID,
		T1.TraitID,
		T1.DetResChar,
		T1.TraitResChar
	FROM @TVP T1
	WHERE T1.[Action] = 'I';

	--UPDATE IF AVAILABLE
	UPDATE T1 SET		
		[DeterminationID]		= T2.DeterminationID, 
		[TraitID]				= T2.TraitID, 
		[DetResChar]			= T2.DetResChar, 
		[TraitResChar]			= T2.TraitResChar
	FROM TraitDeterminationResult T1
	JOIN @TVP T2 ON T2.TraitDeterminationResultID = T1.TraitDeterminationResultID
	WHERE T2.[Action] = 'U';

	--DELETE 
	DELETE T1
	FROM TraitDeterminationResult T1
	JOIN @TVP T2 ON T2.TraitDeterminationResultID = T1.TraitDeterminationResultID
	WHERE T2.[Action] = 'D';
END
GO
/****** Object:  StoredProcedure [dbo].[PR_ThrowError]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_ThrowError]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_ThrowError] AS' 
END
GO
ALTER PROCEDURE [dbo].[PR_ThrowError]
(
	@msg NVARCHAR(MAX)
) AS BEGIN
	RAISERROR (60000, 16, 1, @msg);
END
GO
/****** Object:  StoredProcedure [dbo].[PR_Update_Test]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_Update_Test]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_Update_Test] AS' 
END
GO
/*
	EXEC PR_Update_Test 76,'KATHMANDU\psindurakar',2,0,2,2,'2018-04-27',1
*/

ALTER PROCEDURE [dbo].[PR_Update_Test]
(
	@TestID INT,
	@UserID NVARCHAR(200),
	@ContainerTypeID INT,
	@Isolated BIT,
	@MaterialTypeID INT,
	@MaterialStateID INT,
	@PlannedDate DateTime,
	@TestTypeID INT,
	@SlotID INT = NULL --This value is not required for now 
)
AS
BEGIN
	DECLARE @ReturnValue INT;
	DECLARE @MarkerNeeded BIT = 0, @AssignedDetermination INT =0;
	IF(ISNULL(@TestID,0)=0) BEGIN
		EXEC PR_ThrowError 'Test doesn''t exist.';
		RETURN;
	END

	--check valid test.
	EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
	IF(@ReturnValue <> 1) BEGIN
		RETURN;
	END
	--check status for validation of changed column
	IF EXISTS(SELECT StatusCode FROM Test WHERE StatusCode >= 400 AND TestID = @TestID) BEGIN
		EXEC PR_ThrowError 'Cannot change for this test.';
		RETURN;
	END

	--check if slot is assigned or not
	IF EXISTS(SELECT SlotID FROM Test T JOIN SlotTest ST ON ST.TestID = @TestID) BEGIN
		EXEC PR_ThrowError 'Cannot change test properties after assigning slot.';
		RETURN;
	END

	--check if markers assigned and new test type doesnot require marker
	SELECT @AssignedDetermination = COUNT(TestMaterialDeterminationID) FROM TestMaterialDetermination WHERE TestID = @TestID;
	SELECT @MarkerNeeded = DeterminationRequired FROM TestType WHERE TestTypeID = @TestTypeID
	IF(@MarkerNeeded = 0 AND @AssignedDetermination > 0) BEGIN
		EXEC PR_ThrowError 'Cannot change ''Test Type''. Marker already assigned for this Test.';
		RETURN;
	END

	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN
			UPDATE Test 
			SET 
			ContainerTypeID = @ContainerTypeID,
			Isolated = @Isolated,
			TestTypeID = @TestTypeID,
			PlannedDate = @PlannedDate,
			MaterialTypeID = @MaterialTypeID,
			MaterialStateID = @MaterialStateID,
			ExpectedDate = DATEADD(Week,2,@PlannedDate)
			WHERE TestID = @TestID;			
		COMMIT TRAN;
		END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK;
		THROW;
	END CATCH

END
GO
/****** Object:  StoredProcedure [dbo].[PR_Update_TestStatus]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_Update_TestStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_Update_TestStatus] AS' 
END
GO
-- =============================================
-- Author:		Binod Gurung
-- Create date: 2018/01/05
-- Description:	Update Test status
-- =============================================
ALTER PROCEDURE [dbo].[PR_Update_TestStatus]
	( @TestID	  INT,
	  @StatusCode INT )
AS
BEGIN
	
	SET NOCOUNT ON;
	DECLARE @Valid BIT =0;

	--TODO check nullable parameter
	IF(ISNULL(@TestID,0)=0 OR ISNULL(@StatusCode,0)=0) BEGIN
		EXEC PR_ThrowError 'Invalid TestID or Status.';
		RETURN;
	END
	--Check if test exists
	IF NOT EXISTS(SELECT TestID FROM Test WHERE TestID = @TestID) BEGIN
		EXEC PR_ThrowError 'Test not found.';
		RETURN;
	END
	--TODO check if status is less than already updated status or not.. eg: if status is already 400 than cannot change to 300
	IF EXISTS(SELECT TestID FROM Test WHERE TestID = @TestID AND StatusCode > @StatusCode ) BEGIN
		EXEC PR_ThrowError 'Status cannot be decreased.';
		RETURN;
	END
	--CHECK for validation or capacity whether test exceed reserved capacity if status is going to set on 400 which is point of no return
	IF(@StatusCode = 400 OR @StatusCode = 500) BEGIN
		SET @Valid = dbo.Validate_Capacity(@TestID);
		IF(@Valid = 0) BEGIN
			EXEC PR_ThrowError 'Reservation quota for tests or plates exceed.';
			RETURN;
		END
	END
    
	UPDATE Test
	SET StatusCode = @StatusCode
	WHERE TestID = @TestID

END
GO
/****** Object:  StoredProcedure [dbo].[PR_UpdateAndVerifyTraitDeterminationResult]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_UpdateAndVerifyTraitDeterminationResult]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_UpdateAndVerifyTraitDeterminationResult] AS' 
END
GO
--EXEC PR_UpdateAndVerifyTraitDeterminationResult
ALTER PROCEDURE [dbo].[PR_UpdateAndVerifyTraitDeterminationResult]
(
	@Source NVARCHAR(100)= NULL
)
AS BEGIN
	IF(ISNULL(@Source,'') = '') BEGIN
		SET @Source = 'Phenome'
	END

	SET NOCOUNT ON;
	DECLARE @tbl TABLE (TestID INT, DeterminationID INT, DeterminationValue NVARCHAR(255));
	INSERT INTO @tbl(TestID, DeterminationID, DeterminationValue)
	SELECT DISTINCT 
		T3.TestID, T1.DeterminationID, T1.ObsValueChar
	FROM TestResult T1
	JOIN Well T2 ON T2.WellID = T1.WellID
	JOIN Plate T3 ON T3.PlateID = T2.PlateID
	JOIN Test T ON T.TestID =T3.TestID
	WHERE NOT EXISTS
	(
		SELECT 
			TraitDeterminationResultID 
		FROM TraitDeterminationResult
		WHERE DeterminationID = T1.DeterminationID
		AND DetResChar = T1.ObsValueChar --compare determination and its values in both table and if matches, send traitid and its values to Phenome
	)
	AND T.RequestingSystem  = @Source
	AND T.StatusCode BETWEEN 600 AND 625;
	

	--UPDATE T1 SET 
	--	T1.StatusCode = 650
	--FROM Test T1
	--JOIN
	--(
	--	SELECT DISTINCT TestID FROM @tbl
	--) T2 ON T2.TestID = T1.TestID;

	SELECT 
		T1.TestID, 
		T2.TestName,
		T1.DeterminationID,
		T3.DeterminationName,
		T1.DeterminationValue,
		T2.RequestingUser,
		T2.StatusCode
	FROM @tbl T1
	JOIN Test T2 ON T2.TestID = T1.TestID
	JOIN Determination T3 ON T3.DeterminationID = T1.DeterminationID;

	--update to status 650 if all mapping of determinations and traits for test exists
	UPDATE T1 SET 
		T1.StatusCode = 650
	FROM Test T1
	WHERE NOT EXISTS
	(
		SELECT DISTINCT 
			T1.TestID 
		FROM @tbl TT1
		JOIN Test TT2 ON TT2.TestID = TT1.TestID
		JOIN Determination TT3 ON TT3.DeterminationID = TT1.DeterminationID
		WHERE TT1.TestID = T1.TestID
	)
	AND T1.RequestingSystem = @Source AND T1.StatusCode BETWEEN 600 AND 625

	--update to status 625 if mapping of determinations and traits for test not present.
	UPDATE T1 SET 
		T1.StatusCode = 625
	FROM Test T1
	WHERE EXISTS
	(
		SELECT DISTINCT 
			T1.TestID 
		FROM @tbl TT1
		JOIN Test TT2 ON TT2.TestID = TT1.TestID
		JOIN Determination TT3 ON TT3.DeterminationID = TT1.DeterminationID
		WHERE TT1.TestID = T1.TestID
	)
	AND T1.StatusCode != 625
END

GO
/****** Object:  StoredProcedure [dbo].[PR_Validate_Columns_Determination]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_Validate_Columns_Determination]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_Validate_Columns_Determination] AS' 
END
GO
/*
Author:			KRISHNA GAUTAM
Created Date:	2017-DEC-18
Description:	Validate trait columns that should contain single determination. */

/*
=================Example===============

DECLARE @T1 TVP_Column;
INSERT INTO @T1(ColumnNr,TraitID,ColumLabel,DataType)
VALUES (1,767,'a','t'),(2,707,'a','t'),(3,769,'a','t'),(4,712,'a','t'),(5,709,'a','t')

EXEC PR_Validate_Columns_Determination @T1, 'LT','Breezys'

*/
ALTER PROCEDURE [dbo].[PR_Validate_Columns_Determination]
(
	@TVPColumns TVP_Column	READONLY,
	@Crop		NVARCHAR(10),
	@Source		NVARCHAR(50)
)
AS BEGIN
--SELECT T1.TraitID,T2.DeterminationID FROM RelationTraitDetermination T1 
--	JOIN (
--		SELECT DISTINCT RTD.DeterminationID,Count(RTD.DeterminationID) AS TotalDetarmination
--		FROM RelationTraitDetermination RTD
--		JOIN @TVPColumns T1 ON T1.TraitID = RTD.TraitID WHERE RTD.CropCode = @Crop  GROUP BY RTD.DeterminationID
--	) T2 ON T2.DeterminationID = T1.DeterminationID WHERE T2.TotalDetarmination > 1 AND CropCode = @Crop

	SELECT t.DeterminationID, STUFF(
		(SELECT ',' + CAST(s.TraitID AS NVARCHAR)
			FROM RelationTraitDetermination s
			--JOIN @TVPColumns T1 ON T1.TraitID = S.TraitID AND S.CropCode = @Crop 
			--WHERE s.DeterminationID = t.DeterminationID AND S.Source = @Source AND s.[Status] = 'ACT'
			JOIN 
			(
				SELECT T.TraitID FROM Trait T 
				JOIN @TVPColumns T1 ON T1.TraitID = T.SourceID
				WHERE T.Source = @Source AND T.CropCode = @Crop
			) T12
			ON T12.TraitID = S.TraitID
			WHERE s.DeterminationID = t.DeterminationID AND s.[Status] = 'ACT'
		FOR XML PATH('')),1,1,'') AS Traits
		FROM RelationTraitDetermination AS T 
		--JOIN @TVPColumns T1 ON T1.TraitID = T.TraitID WHERE t.CropCode = @Crop  AND t.[Source] = @Source and T.[Status] = 'ACT'
		JOIN 
			(
				SELECT T.TraitID FROM Trait T 
				JOIN @TVPColumns T1 ON T1.TraitID = T.SourceID
				WHERE T.Source = @Source AND T.CropCode = @Crop
			) T1
			ON T1.TraitID = t.TraitID
			WHERE T.[Status] = 'ACT'
		GROUP BY t.DeterminationID Having Count(t.DeterminationID) > 1
END
GO
/****** Object:  StoredProcedure [dbo].[PR_ValidateTest]    Script Date: 7/23/2018 2:40:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_ValidateTest]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_ValidateTest] AS' 
END
GO
ALTER PROCEDURE [dbo].[PR_ValidateTest]
(
	@TestID	INT,
	@UserID	NVARCHAR(100)
) AS BEGIN
	IF NOT EXISTS(SELECT TestID FROM Test WHERE TestID = @TestID AND RequestingUser = @UserID) BEGIN
		EXEC PR_ThrowError N'Test is either not valid or you are not authorized to access it.';
		RETURN 0;
	END
	RETURN 1;
END
GO
