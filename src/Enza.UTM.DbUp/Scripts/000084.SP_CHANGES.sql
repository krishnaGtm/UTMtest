/****** Object:  StoredProcedure [dbo].[PR_ValidateTest]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_ValidateTest]
GO
/****** Object:  StoredProcedure [dbo].[PR_Validate_Columns_Determination]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Validate_Columns_Determination]
GO
/****** Object:  StoredProcedure [dbo].[PR_Validate_Capacity_Period_Protocol]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Validate_Capacity_Period_Protocol]
GO
/****** Object:  StoredProcedure [dbo].[PR_UpdateAndVerifyTraitDeterminationResult]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_UpdateAndVerifyTraitDeterminationResult]
GO
/****** Object:  StoredProcedure [dbo].[PR_Update3GBMaterials]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Update3GBMaterials]
GO
/****** Object:  StoredProcedure [dbo].[PR_Update_TestStatus]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Update_TestStatus]
GO
/****** Object:  StoredProcedure [dbo].[PR_Update_Test]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Update_Test]
GO
/****** Object:  StoredProcedure [dbo].[PR_UndoDead]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_UndoDead]
GO
/****** Object:  StoredProcedure [dbo].[PR_ThrowError]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_ThrowError]
GO
/****** Object:  StoredProcedure [dbo].[PR_SaveTraitDeterminationResult]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_SaveTraitDeterminationResult]
GO
/****** Object:  StoredProcedure [dbo].[PR_SaveTestMaterialDeterminationWithTVP]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_SaveTestMaterialDeterminationWithTVP]
GO
/****** Object:  StoredProcedure [dbo].[PR_SaveTestMaterialDeterminationWithQuery]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_SaveTestMaterialDeterminationWithQuery]
GO
/****** Object:  StoredProcedure [dbo].[PR_SaveTestMaterialDetermination]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_SaveTestMaterialDetermination]
GO
/****** Object:  StoredProcedure [dbo].[PR_SaveRemark]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_SaveRemark]
GO
/****** Object:  StoredProcedure [dbo].[PR_SavePlannedDate]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_SavePlannedDate]
GO
/****** Object:  StoredProcedure [dbo].[PR_Save_SlotTest]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Save_SlotTest]
GO
/****** Object:  StoredProcedure [dbo].[PR_Save_Score]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Save_Score]
GO
/****** Object:  StoredProcedure [dbo].[PR_Save_RelationTraitDetermination]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Save_RelationTraitDetermination]
GO
/****** Object:  StoredProcedure [dbo].[PR_Replicate_Material]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Replicate_Material]
GO
/****** Object:  StoredProcedure [dbo].[PR_ReorderMaterial]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_ReorderMaterial]
GO
/****** Object:  StoredProcedure [dbo].[PR_RearrangeMaterialOnWell]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_RearrangeMaterialOnWell]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_UpdateCapacitySlot]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_UpdateCapacitySlot]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_Update_Slot_Period]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_Update_Slot_Period]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_SaveCapacity]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_SaveCapacity]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_Reserve_Capacity]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_Reserve_Capacity]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_RejectSlot]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_RejectSlot]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetSlotsForBreeder]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_GetSlotsForBreeder]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetSlotData]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_GetSlotData]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetPlanPeriods]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_GetPlanPeriods]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetPlannedOverview]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_GetPlannedOverview]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetPlanApprovalListForLAB]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_GetPlanApprovalListForLAB]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetPlanApprovalListBySlotForLAB]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_GetPlanApprovalListBySlotForLAB]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetPeriodDetail]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_GetPeriodDetail]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetMaterialTypePerCrop_Lookup]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_GetMaterialTypePerCrop_Lookup]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetCurrentPeriod]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_GetCurrentPeriod]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetCapacity]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_GetCapacity]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_Get_ReserveCapacity_LookUp]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_Get_ReserveCapacity_LookUp]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_Get_Avail_Plates_Tests]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_Get_Avail_Plates_Tests]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_ChangeSlot]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_ChangeSlot]
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_ApproveSlot]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_ApproveSlot]
GO
/****** Object:  StoredProcedure [dbo].[PR_Material_MarkasDead]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Material_MarkasDead]
GO
/****** Object:  StoredProcedure [dbo].[PR_Insert_ExcelData]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Insert_ExcelData]
GO
/****** Object:  StoredProcedure [dbo].[PR_ImportTraitDeterminationRelation]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_ImportTraitDeterminationRelation]
GO
/****** Object:  StoredProcedure [dbo].[PR_ImportFromPhenomeFor3GB]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_ImportFromPhenomeFor3GB]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetWellPositionsLookup]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetWellPositionsLookup]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetTraitValues]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetTraitValues]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetTestsLookup]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetTestsLookup]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetTestInfoForLIMS]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetTestInfoForLIMS]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetTestDetail]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetTestDetail]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetStatusList]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetStatusList]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetSlot_ForTest]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetSlot_ForTest]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetPunchList]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetPunchList]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetPlatesForLims]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetPlatesForLims]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetPlateLabels]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetPlateLabels]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetPlantsLookup]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetPlantsLookup]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetNextAvailableWellPostion]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetNextAvailableWellPostion]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetMaxWellPostionCreated]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetMaxWellPostionCreated]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetMaterialWithMarker]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetMaterialWithMarker]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetDeterminations]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetDeterminations]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetDataWithMarkers]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetDataWithMarkers]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetCropTraitLOV]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetCropTraitLOV]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetCrop]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetCrop]
GO
/****** Object:  StoredProcedure [dbo].[PR_GetBreedingStation]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetBreedingStation]
GO
/****** Object:  StoredProcedure [dbo].[PR_Get3GBMaterialsForUpload]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Get3GBMaterialsForUpload]
GO
/****** Object:  StoredProcedure [dbo].[PR_Get_WellType]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Get_WellType]
GO
/****** Object:  StoredProcedure [dbo].[PR_GET_Traits_And_Determination]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GET_Traits_And_Determination]
GO
/****** Object:  StoredProcedure [dbo].[PR_Get_TraitDeterminationResult]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Get_TraitDeterminationResult]
GO
/****** Object:  StoredProcedure [dbo].[PR_Get_RelationTraitDetermination]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Get_RelationTraitDetermination]
GO
/****** Object:  StoredProcedure [dbo].[PR_Get_MaterialType]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Get_MaterialType]
GO
/****** Object:  StoredProcedure [dbo].[PR_Get_MaterialState]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Get_MaterialState]
GO
/****** Object:  StoredProcedure [dbo].[PR_Get_Files]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Get_Files]
GO
/****** Object:  StoredProcedure [dbo].[PR_GET_Determination_All]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GET_Determination_All]
GO
/****** Object:  StoredProcedure [dbo].[PR_GET_Data]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GET_Data]
GO
/****** Object:  StoredProcedure [dbo].[PR_GET_3GBSelected_Data]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GET_3GBSelected_Data]
GO
/****** Object:  StoredProcedure [dbo].[PR_DeleteReplicatedMaterial]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_DeleteReplicatedMaterial]
GO
/****** Object:  StoredProcedure [dbo].[PR_DeleteDeadMaterial]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_DeleteDeadMaterial]
GO
/****** Object:  StoredProcedure [dbo].[PR_CreatePlateAndWell]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_CreatePlateAndWell]
GO
/****** Object:  StoredProcedure [dbo].[PR_CalculatePlatesRequired]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_CalculatePlatesRequired]
GO
/****** Object:  StoredProcedure [dbo].[PR_AssignLIMSPlate]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_AssignLIMSPlate]
GO
/****** Object:  StoredProcedure [dbo].[PR_AssignFixedPlants_Undo]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_AssignFixedPlants_Undo]
GO
/****** Object:  StoredProcedure [dbo].[PR_AssignFixedPlants]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_AssignFixedPlants]
GO
/****** Object:  StoredProcedure [dbo].[PR_AddMaterialTO3GB]    Script Date: 9/28/2018 12:38:31 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_AddMaterialTO3GB]
GO
/****** Object:  StoredProcedure [dbo].[PR_AddMaterialTO3GB]    Script Date: 9/28/2018 12:38:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_AddMaterialTO3GB]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_AddMaterialTO3GB] AS' 
END
GO
/*
	DECLARE @TVP_3GBMaterial TVP_3GBMaterial;
	--INSERT INTO @TVP_3GBMaterial
	--VALUES('245625',0)
	--EXEC PR_AddMaterialTO3GB 2049,'','',@TVP_3GBMaterial
	--EXEC PR_AddMaterialTO3GB 2062,'','',@TVP_3GBMaterial
	EXEC PR_AddMaterialTO3GB 2061,'[plant name] like '%'','',@TVP_3GBMaterial


	declare @p4 dbo.TVP_3GBMaterial

	exec PR_AddMaterialTO3GB @TestID=2061,@Filter=N'[Plant name]   LIKE  ''%-2%''',@Columns=N'''Plant name''',@TVP_3GBMaterial=@p4

*/

ALTER PROCEDURE [dbo].[PR_AddMaterialTO3GB]
(
	@TestID INT,
	@Filter NVARCHAR(MAX),
	@Columns NVARCHAR(MAX),
	@TVP_3GBMaterial TVP_3GBMaterial READONLY
) 
AS BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
		DECLARE @FileName NVARCHAR(100),@FileID INT, @TVP_3GBMaterialTemp TVP_3GBMaterial, @ColumnQuery NVARCHAR(MAX),@Query NVARCHAR(MAX),@SelectColumns NVARCHAR(MAX),@ColumnIDs NVARCHAR(MAX),@FilterClause	NVARCHAR(MAX);
		DECLARE @ColumnTable TABLE([ColumnID] INT, [ColumnName] NVARCHAR(100));

		SELECT 
			@FileID = F.FileID,
			@FileName = F.FileTitle
		FROM [File] F
		JOIN Test T ON T.FileID = F.FileID AND T.RequestingUser = F.UserID 
		WHERE T.TestID = @TestID

		IF(ISNULL(@FileName, '') = '') BEGIN
			EXEC PR_ThrowError 'Specified file not found';
			RETURN;
		END

		IF(ISNULL(@Filter,'') <> '') BEGIN
			SET @FilterClause = ' AND '+ @Filter
			
		END
		ELSE BEGIN
			SET @FilterClause = ' ';
		END

		--Assign material from TVP
		IF EXISTS (SELECT TOP 1 * FROM @TVP_3GBMaterial) BEGIN
			MERGE INTO [Row] T
			USING @TVP_3GBMaterial S ON S.MaterialID = T.MaterialKey
			WHEN MATCHED AND T.FileID = @FileID THEN
			UPDATE SET T.To3GB = S.Selected;
		END
		
		--Assign material from Query
		ELSE BEGIN
			IF(ISNULL(@Columns,'')<>'') BEGIN
				SET @ColumnQuery = N'
					SELECT ColumnID,ColumnName 
					FROM 
					(
						SELECT ColumnID,COALESCE(CAST(TraitID AS NVARCHAR) ,ColumLabel,'''') as ColumnName FROM [COLUMN]
						WHERE FileID = @FileID 
					) AS T			
					WHERE ColumnName in ('+@Columns+');';

				INSERT INTO @ColumnTable ([ColumnID],[ColumnName])
					EXEC sp_executesql @ColumnQuery, N'@FileID INT', @FileID;

				SELECT 
					@SelectColumns  = COALESCE(@SelectColumns + ',', '') + QUOTENAME([ColumnID])+ ' AS ' + QUOTENAME([ColumnName]),
					@ColumnIDs = COALESCE(@ColumnIDs + ',', '') + QUOTENAME([ColumnID])
				FROM @ColumnTable
			END
			IF(ISNULL(@SelectColumns, '') =  '') BEGIN
				SET @Query = N'		
						SELECT R.[MaterialKey]
						FROM [ROW] R
						WHERE R.FileID = @FileID'
			END
			ELSE BEGIN
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
								WHERE T2.FileID = @FileID --AND T4.UserID = @UserID
							) SRC
							PIVOT
							(
								Max([Value])
								FOR [ColumnID] IN (' + @ColumnIDs + ')
							) PIV
						) AS PT 					
					) AS T1	ON R.[MaterialKey] = T1.MaterialKey  				
				WHERE R.FileID = @FileID ' + @FilterClause + '';
			END


			INSERT INTO @TVP_3GBMaterialTemp(MaterialID)
				EXEC sp_executesql @Query, N'@FileID INT', @FileID;

			MERGE INTO [Row] T
			USING @TVP_3GBMaterialTemp S ON S.MaterialID = T.MaterialKey
			WHEN MATCHED AND T.FileID = @FileID THEN
			UPDATE SET T.To3GB = 1;
			
		END

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		THROW;
	END CATCH	
END	
GO
/****** Object:  StoredProcedure [dbo].[PR_AssignFixedPlants]    Script Date: 9/28/2018 12:38:31 PM ******/
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
EXEC PR_AssignFixedPlants 2056,3809,'A01',40
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

			IF(ISNULL(@Material,0)=0) BEGIN
				EXEC PR_ThrowError 'Fixed positon cannot be completed. Invalid Material';
				RETURN;
			END

			--IF EXISTS( SELECT TOP 1 W.WellID FROM WELL W
			--JOIN Plate P ON P.PlateID = W.PlateID
			--JOIN WellTYpe WT ON WT.WellTypeID = W.WellTypeID
			--WHERE P.TestID = @TestID AND WT.WellTYpeName = 'D') BEGIN
			--	EXEC PR_ThrowError 'Fixed positon cannot be completed. Remove dead material(s) first.';
			--	RETURN;
			--END

			DECLARE --@WellPerRow INT =0,	
			@PlateID INT =0,
			@TotalPlatesRequired INT =0,
			@PlatesCreated INT =0,
			--@Count INT =0,
			--@TotalMaterialExceptFixed INT = 0,
			--@MaterialCount INT =0,
			--@MaterialID INT,
			--@WellID INT,
			@FixedWellCount INT =0,
			@PlateIDLast INT,
			@LastPlateName NVARCHAR(200) = '',
			@EmptyWellTypeID INT,
			@AssignedWellTypeID INT,
			@FixedWellTypeID INT,
			@DeadWellTypeID INT;

			--DECLARE @NewPlateCreated BIT = 0;
			DECLARE --@FixedOnlyMaterial TVP_TMDW,
			@FixedOnlyMaterialWithWell TVP_TMDW--,
			--@TempWellTable TVP_TempWellTable, 
			--@TempWellTable1 TVP_TempWellTable;--, @DeadWellTable TVP_TempWellTable;
			
			DECLARE @MaterialExceptFixed TVP_Material,
			@WellExceptFixed TVP_Material,
			--@MaterialAll TVP_Material,
			--@Well TVP_Material,
			@MaterialWithWell TVP_TMDW,
			@FixedOnlyWell TVP_Material;

			DECLARE @MaxMaterialRowNr INT;
			
			SELECT @FixedWellTypeID = WellTypeID
			FROM WellType
			WHERE WellTypeName = 'F'

			SELECT @EmptyWellTypeID = WellTypeID
			FROM WellType
			WHERE WellTypeName = 'E'
			
			SELECT @AssignedWellTypeID = WellTypeID
			FROM WellType
			WHERE WellTypeName = 'A'

			SELECT @DeadWellTypeID = WellTypeID
			FROM WellType
			WHERE WellTypeName = 'D'
			

			IF EXISTS( SELECT TOP 1 TMDW.MaterialID FROM TestMaterialDeterminationWell TMDW 
			JOIN Well W ON W.WellID = TMDW.WellID
			JOIN Plate P ON P.PlateID = W.PlateID
			WHERE P.TestID = @TestID 
			GROUP BY TMDW.MaterialID, W.WellTypeID HAVING COUNT(TMDW.MaterialID) > 1 AND TMDW.MaterialID = @Material AND W.WellTypeID != @FixedWellTypeID) BEGIN
				EXEC PR_ThrowError 'Fixed positon cannot be completed. Replicated material cannot be assinged to fixed position.';
				RETURN;
			END
	
			
		
			IF EXISTS(SELECT TOP 1 W.WellID FROM Well W
				JOIN Plate P ON P.PlateID = W.PlateID				
				WHERE P.TestID = @TestID AND W.WellTypeID = @FixedWellTypeID AND W.Position = @Position) BEGIN
					EXEC PR_ThrowError 'Fixed positon cannot be completed. Well position is already fixed.';
					RETURN;
			END

			IF EXISTS(SELECT TOP 1 W.WellID FROM Well W
				JOIN Plate P ON P.PlateID = W.PlateID				
				WHERE P.TestID = @TestID AND W.WellTypeID = @DeadWellTypeID AND W.Position = @Position) BEGIN
					DECLARE @Errormsg NVARCHAR(MAX);
					SET @Errormsg = 'Some plate on position '+@Position +' contains dead material which cannot be used for assigning fixed postiion.';
					EXEC PR_ThrowError @Errormsg;
					RETURN;
			END

			SELECT @FixedWellCount = COUNT(DISTINCT Position)
			FROM Well W			
			JOIN Plate P ON P.PlateID = W.PlateID
			WHERE P.TestID = @TestID AND W.WellTypeID = @FixedWellTypeID;
			
			IF(ISNULL(@Material,0)<>0 OR ISNULL(@Position,'')<>'') BEGIN	
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
					--if status is 200 or greater, plates are already reserved on LIMS so new plates created on UTM cannot be synced.
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
					--OUTPUT INSERTED.WellID INTO @TempInsertedWell(MaterialID) --inserted well is a material for this temptable
					SELECT WellTypeID,Position,@PlateID
					FROM Well W
					JOIN Plate P ON P.PlateID = W.PlateID
					WHERE P.PlateID = @PlateIDLast;

					SET @PlatesCreated = @PlatesCreated +1;					
						
				END
			END

			--this contains fixed only material (on our case dead material and already assigned fixed position's material are considered as fixed only material).
			INSERT INTO @FixedOnlyMaterialWithWell (MaterialID,WellID)
			SELECT TMDW.MaterialID, TMDW.WellID FROM TestMaterialDeterminationWell TMDW
			JOIN Well W ON W.WellID = TMDW.WellID
			JOIN Plate P ON P.PlateID = W.PlateID
			WHERE P.TestID =@TestID AND (W.WellTypeID = @FixedWellTypeID OR W.WellTypeID =@DeadWellTypeID)

			--this table is used to create new assigned position as fixed position (MaterialID will be wellID)
			INSERT INTO @FixedOnlyWell(MaterialID)
			SELECT WellID FROM Well W
			JOIN Plate P ON P.PlateID = W.PlateID
			WHERE P.TestID = @TestID AND W.Position = @Position;

			--new position which is going to be assigned as fixed position is also added on fixed only material table.
			INSERT INTO @FixedOnlyMaterialWithWell (MaterialID,WellID)
			SELECT @Material,MaterialID FROM @FixedOnlyWell;
			
			
			--insert non fixed position material
			INSERT INTO @MaterialExceptFixed(MaterialID)			
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
					WHERE P.TestID = @TestID 
					AND NOT EXISTS (SELECT DISTINCT MaterialID 
										FROM @FixedOnlyMaterialWithWell 
									WHERE MaterialID = TMDW.MaterialID
									)
					
				) T 
			) T1 ORDER BY PlateID, Position2, Position1	
			
			--insert non fixed position well just like non fixed material 
			INSERT INTO @WellExceptFixed(MaterialID)
			SELECT WellID
			FROM 
			(
				SELECT WellID
				,Position,Position2,Position1,PlateID
				FROM 
				(
					SELECT DISTINCT Position, W.WellID,W.PlateID,
					CAST(RIGHT(Position,LEN(Position)-1) AS INT) AS Position1, -- this is column number
					CAST(ASCII(LEFT(Position,1)) -65 AS INT) as Position2 -- this is row number
					FROM Well W
					LEFT JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID
					LEFT JOIN Plate P ON P.PlateID = W.PlateID
					WHERE P.TestID = @TestID 
					AND NOT EXISTS (SELECT DISTINCT WellID 
										FROM @FixedOnlyMaterialWithWell 
									WHERE WellID = TMDW.WellID
									)
					
				) T 
			) T1 ORDER BY PlateID, Position2, Position1	

			--merge non fixed position well and material
			INSERT INTO @MaterialWithWell(MaterialID, WellID)
			SELECT M.MaterialID, W.MaterialID FROM @MaterialExceptFixed M
			JOIN @WellExceptFixed W ON W.RowNr = M.RowNr

			--SELECT @MaxMaterialRowNr = MAX(RowNr) FROM @MaterialExceptFixed;

			--SELECT MaterialID FROM @WellExceptFixed WHERE RowNr >  @MaxMaterialRowNr

			--SELECT * FROM @FixedOnlyWell;

			--SELECT * FROM @FixedOnlyMaterialWithWell;

			--SELECT * FROM @MaterialExceptFixed;

			--SELECT * FROM @WellExceptFixed;

			--SELECT * FROM @MaterialWithWell M
			--JOIN Well W ON W.WellID = M.WellID;

			--SELECT * FROM @FixedOnlyMaterialWithWell M
			--JOIN Well W ON W.WellID = M.WellID
			
			--merge actual table with our temp (re-ordered material)
			MERGE TestMaterialDeterminationWell T
			USING @MaterialWithWell S
			ON T.WellID = S.WellID
			WHEN NOT MATCHED THEN 
			INSERT (MaterialID,WellID)
			VALUES (S.MaterialID,S.WellID)
			WHEN MATCHED AND T.MaterialID <> S.MaterialID THEN
			UPDATE SET T.MaterialID = S.MaterialID;

			--merge for fixed position material.
			MERGE TestMaterialDeterminationWell T
			USING @FixedOnlyMaterialWithWell S
			ON T.WellID = S.WellID
			WHEN NOT MATCHED THEN 
			INSERT (MaterialID,WellID)
			VALUES (S.MaterialID,S.WellID)
			WHEN MATCHED AND T.MaterialID <> S.MaterialID THEN
			UPDATE SET T.MaterialID = S.MaterialID;
			
			
			SELECT @MaxMaterialRowNr = MAX(RowNr) FROM @MaterialExceptFixed;

			--update welltype for non fixed based on re-ordered data
			UPDATE W
			SET W.WellTypeID = @EmptyWellTypeID
			FROM Well W	
			WHERE WellID IN (SELECT MaterialID FROM @WellExceptFixed WHERE RowNr >  @MaxMaterialRowNr) AND W.WellTypeID != @EmptyWellTypeID


			MERGE Well W
			USING @wellExceptFixed S
			ON W.WellID = S.MaterialID AND W.WellTypeID != @AssignedWellTypeID
			WHEN MATCHED THEN 
			UPDATE SET W.WellTypeID = @AssignedWellTypeID;

			--update welltype for fixed position
			UPDATE W
			SET W.WellTypeID = @FixedWellTypeID
			FROM Well W	
			JOIN @FixedOnlyMaterialWithWell T1 ON W.WellID = T1.WellID
			WHERE W.WellTypeID != @FixedWellTypeID AND W.WellTypeID != @DeadWellTypeID;
			
		COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK;
		THROW;
	END CATCH
END


GO
/****** Object:  StoredProcedure [dbo].[PR_AssignFixedPlants_Undo]    Script Date: 9/28/2018 12:38:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_AssignFixedPlants_Undo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_AssignFixedPlants_Undo] AS' 
END
GO


/*
============Example===============
EXEC PR_AssignFixedPlants_Undo 1058,3807
*/
ALTER PROCEDURE [dbo].[PR_AssignFixedPlants_Undo]
(
	@TestID INT,
	@MaterialID INT
) AS BEGIN

	SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @PlateIDFirst INT, @AssignedWellType INT, @EmptyWellType INT,@FixedWellType INT,@DeadWellType INT, @WellPosition NVARCHAR(MAX),@MaxRowNr INT;
		DECLARE @MaterialExceptFixedAndDead TVP_Material, @WellExceptFixedAndDead TVP_Material,@CurrentFixedWell TVP_Material, @MaterialWithWell TVP_TMDW;
		
		IF(ISNULL(@TestID,0)=0) BEGIN
				EXEC PR_ThrowError 'Requested Test does not exist.';
				RETURN;
		END

		--check status for validation of changed column
		IF EXISTS(SELECT StatusCode FROM Test WHERE StatusCode >= 400 AND TestID = @TestID) BEGIN
			EXEC PR_ThrowError 'Operation cannot be completed with this test because status is greater than or equals to 400.';
			RETURN;
		END

		IF(ISNULL(@MaterialID,0)=0) BEGIN
			EXEC PR_ThrowError 'Fixed positon cannot be completed. Invalid Material';
			RETURN;
		END

		BEGIN TRANSACTION;

			SELECT @AssignedWellType = WellTypeID
			FROM WellType WHERE WellTypeName = 'A';

			SELECT @EmptyWellType = WellTypeID
			FROM WellType WHERE WellTypeName = 'E';

			SELECT @FixedWellType = WellTypeID
			FROM WellType WHERE WellTypeName = 'F';

			SELECT @DeadWellType = WellTypeID
			FROM WellType WHERE WellTypeName = 'D';

			SELECT TOP 1 @PlateIDFirst = PlateID FROM Plate P 
			WHERE P.TestID = @TestID ORDER BY PlateID;

			SELECT TOP 1 @WellPosition = W.Position
			FROM Well W
			JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID
			WHERE TMDW.MaterialID = @MaterialID AND W.PlateID = @PlateIDFirst AND W.WellTypeID = @FixedWellType;
	

			--update current welltype postion from fixed welltype to assigned welltype postion.
			UPDATE W
				SET W.WellTypeID = @AssignedWellType
			FROM Well  W
			JOIN Plate P ON W.PlateID = P.PlateID
			WHERE TestID = @TestID AND W.Position = @WellPosition;

			--delete all fixedpostioned material from TMDW table present on all plates except first plate of current test.
			--DELETE TMDW 
			--FROM TestMaterialDeterminationWell TMDW
			--JOIN Well W ON W.WellID = TMDW.WellID
			--JOIN Plate P ON P.PlateID = W.PlateID
			--WHERE P.PlateID > @PlateIDFirst AND P.TestID = @TestID AND W.Position = @WellPosition AND TMDW.MaterialID = @MaterialID;
			INSERT INTO @CurrentFixedWell(MaterialID)
				SELECT TMDW.WellID
				FROM TestMaterialDeterminationWell TMDW
				JOIN Well W ON W.WellID = TMDW.WellID
				JOIN Plate P ON P.PlateID = W.PlateID
				WHERE P.PlateID > @PlateIDFirst AND P.TestID = @TestID AND W.Position = @WellPosition AND TMDW.MaterialID = @MaterialID
			
	
			--get all material without fixed and dead material
			INSERT INTO @MaterialExceptFixedAndDead(MaterialID)
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
					--JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
					JOIN Plate P ON P.PlateID = W.PlateID
					WHERE P.TestID = @TestID AND (W.WellTypeID !=@FixedWellType AND W.WellTypeID != @DeadWellType)
					AND NOT EXISTS (SELECT MaterialID FROM @CurrentFixedWell FW WHERE TMDW.WellID = FW.MaterialID)
					
				) T
			) T1
			ORDER BY PlateID, Position2, Position1

			--get ordered well without fixed and dead material
			INSERT INTO @WellExceptFixedAndDead(MaterialID)
			SELECT T.WellID
			FROM 
			(
				SELECT W.*, CAST(RIGHT(Position,LEN(Position)-1) AS INT) AS Position1
				,LEFT(Position,1) as Position2
				FROM Well W
				JOIN Plate P ON P.PlateID = W.PlateID
				--JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
				WHERE P.TestID = @TestID AND (W.WellTypeID !=@FixedWellType AND W.WellTypeID != @DeadWellType)
				
							
			) T
			ORDER BY PlateID,Position2,Position1

			--get last rownr to find total material that is actually present on current test
			SELECT @MaxRowNr = MAX(RowNr)
			FROM @MaterialExceptFixedAndDead;

			INSERT INTO @MaterialWithWell(MaterialID,WellID)
			SELECT M.MaterialID,W.MaterialID
			FROM @WellExceptFixedAndDead W
			JOIN @MaterialExceptFixedAndDead M ON M.RowNr = W.RowNr


			--SELECT MaterialID FROM @WellExceptFixedAndDead WHERE RowNr >= @MaxRowNr

			--apply merge statement to update and apply rearrange method.	
			MERGE TestMaterialDeterminationWell T
			USING @MaterialWithWell S
			ON T.WellID = S.WellID AND T.MaterialID <> S.MaterialID			
			WHEN MATCHED THEN
			UPDATE SET T.MaterialID = S.MaterialID;


			--Update all assigned well position to empty well for last shifted material
			UPDATE W
			SET W.WellTypeID = @EmptyWellType
			FROM Well W
			JOIN Plate P ON P.PlateID = W.PlateID
			WHERE P.TestID = @TestID AND W.WellID IN (SELECT MaterialID FROM @WellExceptFixedAndDead WHERE RowNr > @MaxRowNr)

			
			--delete material from TMDW table for last shifted material
			DELETE TMDW
			FROM TestMaterialDeterminationWell TMDW
			WHERE TMDW.WellID IN (SELECT MaterialID FROM @WellExceptFixedAndDead WHERE RowNr > @MaxRowNr)

			

		COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK;
		THROW;
	END CATCH
	

END
GO
/****** Object:  StoredProcedure [dbo].[PR_AssignLIMSPlate]    Script Date: 9/28/2018 12:38:31 PM ******/
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
	--@UserID		NVARCHAR(100),
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
/****** Object:  StoredProcedure [dbo].[PR_CalculatePlatesRequired]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_CreatePlateAndWell]    Script Date: 9/28/2018 12:38:31 PM ******/
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
	@TestID			INT
	
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
/****** Object:  StoredProcedure [dbo].[PR_DeleteDeadMaterial]    Script Date: 9/28/2018 12:38:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_DeleteDeadMaterial]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_DeleteDeadMaterial] AS' 
END
GO

/*
===========EXAMPLE=============
--This SP is used to remove all dead materials if no material is passed on parameter and if material and well id is passed then specific material is deleted.
EXEC PR_Delete_EmptyORDeadMaterial 56,'KATHMANDU\Krishna'

*/


ALTER PROCEDURE [dbo].[PR_DeleteDeadMaterial]
(
	@TestID INT
)
AS 
BEGIN
	DECLARE @ReturnValue INT,@Material TVP_Material,@Well TVP_Material, @AssignedWellType INT, @EmptyWellType INT,@MaterialWithWell TVP_TMDW, @MaxRowNr INT;--, @DeadMaterialCount INT;

	IF(ISNULL(@TestID,0)=0) BEGIN
		EXEC PR_ThrowError 'Test doesn''t exist.';
		RETURN;
	END

	----check valid test.
	--EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
	--IF(@ReturnValue <> 1) BEGIN
	--	RETURN;
	--END
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
			

			IF EXISTS(SELECT TOP 1 TMD.TestMaterialDeterminationID FROM TestMaterialDetermination TMD JOIN @Well W ON W.MaterialID = TMD.MaterialID WHERE W.RowNr > @MaxRowNr AND TMD.TestID = @TestID) BEGIN
				
				DELETE TMD FROM TestMaterialDetermination TMD
				JOIN @Well W ON W.MaterialID = TMD.MaterialID 
				WHERE W.RowNr > @MaxRowNr AND TMD.TestID = @TestID;
				
				IF EXISTS(SELECT StatusCode FROM Test WHERE StatusCode = 300 AND TestID = @TestID) BEGIN
						EXEC PR_Update_TestStatus @TestID, 350;
				END

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
/****** Object:  StoredProcedure [dbo].[PR_DeleteReplicatedMaterial]    Script Date: 9/28/2018 12:38:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_DeleteReplicatedMaterial]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_DeleteReplicatedMaterial] AS' 
END
GO
ALTER PROCEDURE [dbo].[PR_DeleteReplicatedMaterial]
(
	@TestID INT,
	@MaterialID INT,
	@WellID INT
	
) AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;

			DECLARE @ReturnValue INT,@Material TVP_Material,@Well TVP_Material, @AssignedWellType INT, @EmptyWellType INT,@MaterialWithWell TVP_TMDW, @MaxRowNr INT;

			IF EXISTS( SELECT TOP 1 W.WellID FROM WELL W
					JOIN Plate P ON P.PlateID = W.PlateID
					JOIN WellTYpe WT ON WT.WellTypeID = W.WellTypeID
					WHERE P.TestID = @TestID AND WT.WellTYpeName = 'D') BEGIN
						EXEC PR_ThrowError 'Remove dead material first.';
						RETURN;
				END

			IF EXISTS(SELECT * FROM TestMaterialDeterminationWell TMDW
				JOIN Well W ON W.WellID = TMDW.WellID 
				JOIN Plate P ON P.PlateID = W.PlateID
				JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
				WHERE WT.WellTypeName IN ('D','F','B') AND TMDW.MaterialID = @MaterialID AND W.WellID = @WellID AND P.TestID = @TestID) BEGIN

				EXEC PR_ThrowError 'Fixed position material cannot be deleted.';
				RETURN;
	
			END 

			IF EXISTS(SELECT TMDW.MaterialID FROM TestMaterialDeterminationWell TMDW
				JOIN Well W ON W.WellID = TMDW.WellID 
				JOIN Plate P ON P.PlateID = W.PlateID
				WHERE MaterialID = @MaterialID AND P.TestID = @TestID AND TMDW.WellID != @WellID) BEGIN
				--First Delete and rearrange material
				DELETE FROM TestMaterialDeterminationWell WHERE MaterialID = @MaterialID AND WellID = @WellID;
				EXEC PR_RearrangeMaterialOnWell @TestID;
				--select * from test
			END

			ELSE BEGIN
				EXEC PR_ThrowError 'Atleast one replica of material should be present on plate to delete replica of material.';
				RETURN;
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
/****** Object:  StoredProcedure [dbo].[PR_GET_3GBSelected_Data]    Script Date: 9/28/2018 12:38:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_GET_3GBSelected_Data]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_GET_3GBSelected_Data] AS' 
END
GO
/*
	EXEC PR_GET_3GBSelected_Data 2049,1,100
*/

ALTER PROCEDURE [dbo].[PR_GET_3GBSelected_Data]
(
	@TestID INT,
	--@User NVARCHAR(100),
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
		SELECT R.[RowNr], D_To3GB = R.To3GB, R.MaterialKey, ' + @Columns2 + ' 
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
					WHERE T2.FileID = @FileID 
					--AND T4.UserID = @User
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
	SELECT CTE.MaterialKey, CTE.D_To3GB , '+ @Columns2 + ', Count_CTE.[TotalRows] FROM CTE, COUNT_CTE
	ORDER BY CTE.[RowNr]
	OFFSET ' + CAST(@Offset AS NVARCHAR) + ' ROWS
	FETCH NEXT ' + CAST (@PageSize AS NVARCHAR) + ' ROWS ONLY';
					
	--PRINT @Query;
	--EXEC sp_executesql @Query, N'@FileID INT, @User NVARCHAR(100)', @FileID,@User;
	EXEC sp_executesql @Query, N'@FileID INT', @FileID;		
	SELECT CAST([TraitID] AS NVARCHAR(MAX)), [ColumLabel] as ColumnLabel, [DataType],[ColumnNr],CASE WHEN [TraitID] IS NULL THEN 0 ELSE 1 END AS IsTraitColumn,
	Fixed = CASE WHEN [ColumLabel] = 'Crop' OR [ColumLabel] = 'GID' OR [ColumLabel] = 'Plantnr' OR [ColumLabel] = 'Plant name' THEN 1 ELSE 0 END
	FROM [Column]  WHERE [FileID]= @FileID
	UNION ALL
	SELECT [TraitID] = 'D_to3GB', [ColumLabel] = 'To3GB', [DataType] = 'NVARCHAR(255)', [ColumnNr] = 0,IsTraitColumn = 0, Fixed = 1
	ORDER BY ColumnNr;



END
GO
/****** Object:  StoredProcedure [dbo].[PR_GET_Data]    Script Date: 9/28/2018 12:38:31 PM ******/
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
	--@User NVARCHAR(100),
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
		@Columns  = COALESCE(@Columns + ',', '') +'CAST('+ QUOTENAME(MAX(ColumnID)) +' AS '+ MAX(Datatype) +')' + ' AS ' + ISNULL(QUOTENAME(TraitID),QUOTENAME(ColumLabel)),
		@Columns2  = COALESCE(@Columns2 + ',', '') + ISNULL(QUOTENAME(TraitID),QUOTENAME(ColumLabel)),
		@ColumnIDs  = COALESCE(@ColumnIDs + ',', '') + QUOTENAME(MAX(ColumnID))
	FROM [Column]
	WHERE FileID = @FileID
	GROUP BY ColumLabel,TraitID
	--ORDER BY [ColumnNr] ASC;

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
					WHERE T2.FileID = @FileID 
					--AND T4.UserID = @User
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
	--EXEC sp_executesql @Query, N'@FileID INT, @User NVARCHAR(100)', @FileID,@User;
	EXEC sp_executesql @Query, N'@FileID INT', @FileID;		
	SELECT [TraitID], [ColumLabel] as ColumnLabel, DataType = MAX([DataType]),ColumnNr = MAX([ColumnNr]),CASE WHEN [TraitID] IS NULL THEN 0 ELSE 1 END AS IsTraitColumn,
	Fixed = CASE WHEN [ColumLabel] = 'Crop' OR [ColumLabel] = 'GID' OR [ColumLabel] = 'Plantnr' OR [ColumLabel] = 'Plant name' THEN 1 ELSE 0 END
	FROM [Column] 
	WHERE [FileID]= @FileID
	GROUP BY ColumLabel,TraitID
	ORDER BY ColumnNr;
	

END
GO
/****** Object:  StoredProcedure [dbo].[PR_GET_Determination_All]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_Get_Files]    Script Date: 9/28/2018 12:38:31 PM ******/
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
	--@UserID NVARCHAR(100),
	@CropCode NVARCHAR(10),
	@BreedingStationCode NVARCHAR(10),
	@TestID INT = NULL
) AS
BEGIN
	
	DECLARE @TotalWells INT,@BlockedWells INT;
	IF(ISNULL(@TestID,0)<> 0) BEGIN
		SELECT @BreedingStationCode = T.BreedingStationCode,@CropCode = F.CropCode FROM 
		[File] F 
		JOIN Test T ON T.FileID = F.FileID WHERE T.TestID = @TestID
	END

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
		WellsPerPlate = @TotalWells - ISNULL(T1.Blocked,0),
		T.BreedingStationCode,
		T.ExpectedDate,
		T.LabPlatePlanName
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
	WHERE --F.UserID = @UserID
	F.CropCode = @CropCode
	AND T.BreedingStationCode = @BreedingStationCode
	AND T.StatusCode <= 600 
	AND (ISNULL(@TestID, 0) = 0 OR T.TestID = @TestID)
	ORDER BY FileID DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[PR_Get_MaterialState]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_Get_MaterialType]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_Get_RelationTraitDetermination]    Script Date: 9/28/2018 12:38:31 PM ******/
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
 EXEC PR_Get_RelationTraitDetermination 200, 1, ''
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
 DECLARE @StatusTable TABLE(StatusCode INT, [Status] NVARCHAR(100));
 

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
			CT.CropCode,
			CT.CropTraitID,
			TraitLabel = T.ColumnLabel,
			D.DeterminationID,
			D.DeterminationName,
			D.DeterminationAlias,
			RTD.RelationID,
			[Status] = ST.[StatusName]
		FROM CropTrait CT
		JOIN Trait T ON T.TraitID = CT.TraitID
		LEFT JOIN RelationTraitDetermination RTD ON RTD.CropTraitID = CT.CropTraitID
		LEFT JOIN Determination D ON D.DeterminationID = RTD.DeterminationID
		LEFT JOIN [Status] ST ON ST.StatusCode = RTD.StatusCode AND  ST.StatusTable =  ''RelationTraitDetermination''
	
	) AS T '+ @Filter + '
		
), Count_CTE AS 
(	
	SELECT 
		COUNT(CropTraitID) AS [TotalRows] 
	FROM CTE
)  

SELECT 
	CropCode, 
	CropTraitID, 
	TraitLabel, 
	DeterminationID,	
	DeterminationName,
	DeterminationAlias, 
	RelationID,
	[Status],  
	Count_CTE.[TotalRows] 
FROM CTE, Count_CTE ' ;

--IF(ISNULL(@Filter,'') <> '') BEGIN
--	SET @SQL = @SQL + ' WHERE '+ @Filter;
--END
 

 SET @SQL = @SQL + ' ORDER BY CTE.CropCode, CTE.TraitLabel,CTE.CropTraitID 
 OFFSET @Offset ROWS  
 FETCH NEXT @PageSize ROWS ONLY'
 PRINT @SQL

 EXEC sp_executesql @SQL, N'@Offset INT, @PageSize INT', @Offset,@PageSize;	

 

   
END
GO
/****** Object:  StoredProcedure [dbo].[PR_Get_TraitDeterminationResult]    Script Date: 9/28/2018 12:38:31 PM ******/
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
EXEC PR_Get_TraitDeterminationResult 200, 1, ''
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
				TDR.TraitDeterminationResultID AS ID,
				CT.CropCode,
				CT.CropTraitID,
				TraitName = T.ColumnLabel,
				D.DeterminationID,
				D.DeterminationName,
				D.DeterminationAlias,
				TDR.DetResChar AS DeterminationValue,
				TDR.TraitResChar AS TraitValue,
				ListOfValues = CAST(ISNULL(T.ListOfValues, 0) AS BIT),
				RTD.RelationID
			FROM TraitDeterminationResult TDR
			JOIN RelationTraitDetermination RTD ON TDR.RelationID = RTD.RelationID
			JOIN CropTrait CT ON CT.CropTraitID = RTD.CropTraitID
			JOIN Determination D ON D.DeterminationID = RTD.DeterminationID
			JOIN Trait T ON T.TraitID = CT.TraitID
		) AS T ' +@Filter +' 
	), CTE_COUNT AS
	(
		SELECT COUNT(ID) AS TotalRows FROM CTE
	)

	SELECT * FROM CTE, CTE_COUNT'

	--IF(ISNULL(@Filter,'')<> '') BEGIN
	--	SET @SQL = @SQL + ' WHERE '+@Filter;
	--END

	SET @SQL = @SQL + '	ORDER BY CTE.CropCode, CTE.TraitName,CTE.CropTraitID
	OFFSET @Offset ROWS
	FETCH NEXT @PageSize ROWS ONLY';

	PRINT @SQL;
	EXEC sp_executesql @SQL, N'@Offset INT, @PageSize INT', @Offset,@PageSize;
END
GO
/****** Object:  StoredProcedure [dbo].[PR_GET_Traits_And_Determination]    Script Date: 9/28/2018 12:38:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_GET_Traits_And_Determination]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_GET_Traits_And_Determination] AS' 
END
GO

/*
	EXEC PR_GET_Determination_All 'r 0010'
*/
ALTER PROCEDURE [dbo].[PR_GET_Traits_And_Determination]
(
	@TraitName NVARCHAR(100),
	@CropCode NVARCHAR(10)
)
AS
BEGIN
	--SELECT TOP 200 TraitID, ColumnLabel AS TraitName,TraitDescription, CropCode, ListOfValues = CAST ( ISNULL(ListOfValues, 0) AS BIT )
	--FROM Trait
	--WHERE ColumnLabel like '%'+ @TraitName+'%'
	--AND CropCode = @CropCode
	--AND [Source] = @Source;

	SELECT TOP 200 CT.CropTraitID, 
		T.ColumnLabel AS TraitName,
		TraitDescription, 
		CT.CropCode, 
		ListOfValues = CAST ( ISNULL(ListOfValues, 0) AS BIT ),
		RTD.RelationID,
		D.DeterminationID,
		D.DeterminationName,
		D.DeterminationAlias
	FROM CropTrait CT 
	JOIN Trait T ON T.TraitID = CT.TraitID
	JOIN RelationTraitDetermination RTD ON RTD.CropTraitID = CT.CropTraitID
	JOIN Determination D ON D.DeterminationID = RTD.DeterminationID
	WHERE T.ColumnLabel like '%'+ @TraitName+'%'
	AND CT.CropCode = @CropCode
	ORDER BY ColumnLabel

END
GO
/****** Object:  StoredProcedure [dbo].[PR_Get_WellType]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_Get3GBMaterialsForUpload]    Script Date: 9/28/2018 12:38:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_Get3GBMaterialsForUpload]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_Get3GBMaterialsForUpload] AS' 
END
GO
--EXEC PR_Get3GBMaterialsForUpload 2061;
ALTER PROCEDURE [dbo].[PR_Get3GBMaterialsForUpload]
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
			TwoGBPlatePlanID = T.TestName,
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
/****** Object:  StoredProcedure [dbo].[PR_GetBreedingStation]    Script Date: 9/28/2018 12:38:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_GetBreedingStation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_GetBreedingStation] AS' 
END
GO
ALTER PROCEDURE [dbo].[PR_GetBreedingStation]
AS BEGIN
	SELECT BreedingStationCode, BreedingStationName FROM BreedingStation ORDER BY BreedingStationCode
END
GO
/****** Object:  StoredProcedure [dbo].[PR_GetCrop]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_GetCropTraitLOV]    Script Date: 9/28/2018 12:38:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_GetCropTraitLOV]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_GetCropTraitLOV] AS' 
END
GO
/*
	EXEC PR_GetCropTraitLOV 'TO', 230
*/
ALTER PROCEDURE [dbo].[PR_GetCropTraitLOV]
(
	@CropTraitID  INT
)
AS
BEGIN
	DECLARE @CropCode NVARCHAR(2);

	SELECT @CropCode = CropCode FROM CropTrait WHERE CropTraitID = @CropTraitID;

	
	SELECT TV.TraitValueCode,Tv.TraitValueName 
	FROM CropLov CLOV
	JOIN TraitValue TV ON TV.TraitValueID = Clov.TraitValueID
	JOIN Trait T ON T.TraitID = TV.TraitID
	JOIN CropTrait CT ON CT.TraitID = T.TraitID
	WHERE CT.CropTraitID = @CropTraitID
	AND CLOV.CropCode = @CropCode;
END
GO
/****** Object:  StoredProcedure [dbo].[PR_GetDataWithMarkers]    Script Date: 9/28/2018 12:38:31 PM ******/
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
	EXEC [PR_GetDataWithMarkers] 48, 1, 200, '[700] LIKE ''v%'''
	EXEC [PR_GetDataWithMarkers] 45, 1, 200, ''
	EXEC [PR_GetDataWithMarkers] 1030, 1, 200, ''
*/
ALTER PROCEDURE [dbo].[PR_GetDataWithMarkers]
(
	@TestID			INT,
	--@User			NVARCHAR(100),
	@Page			INT,
	@PageSize		INT,
	@Filter			NVARCHAR(MAX) = NULL
) AS BEGIN
	SET NOCOUNT ON;

	DECLARE @Offset INT, @FileID INT, @Total INT--, @SameTestCount INT =1;
	DECLARE @Source NVARCHAR(MAX);
	DECLARE @SQL NVARCHAR(MAX), @Columns NVARCHAR(MAX), @ColumnIDs NVARCHAR(MAX), @Columns2 NVARCHAR(MAX), @ColumnID2s NVARCHAR(MAX), @Columns3 NVARCHAR(MAX);
	DECLARE @TblColumns TABLE(ColumnID INT, TraitID VARCHAR(20), ColumnLabel NVARCHAR(50), ColumnType INT, ColumnNr INT, DataType NVARCHAR(15),MateriallblColumn BIT);
	DECLARE @PlateAndWellAssigned BIT = 0; --here we have to check whether well and plate is assigned previously or not.. for now we set it to false 
	DECLARE @FileName NVARCHAR(100) = '', @Crop NVARCHAR(10) = ''; -- ,@SameTestCount NVARCHAR(5);

	SELECT @FileID = F.FileID, @FileName = T.TestName, @Crop = CropCode, @Source = T.RequestingSystem
	FROM [File] F
	JOIN Test T ON T.FileID = F.FileID 
	WHERE T.TestID = @TestID AND T.RequestingUser = F.UserID;

	IF(ISNULL(@FileID, 0) = 0) BEGIN
		EXEC PR_ThrowError 'File or test doesn''t exist.';
		RETURN;
	END

	--CREATE PLATE AND WELLS IF REQUIRED
	--EXEC PR_CreatePlateAndWell @TestID,@User
	EXEC PR_CreatePlateAndWell @TestID;

	--Determination columns
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr, MateriallblColumn)
	SELECT DeterminationID, TraitID, ColumLabel, 1, ROW_NUMBER() OVER(ORDER BY ColumnNR),0
	FROM
	(	
		SELECT DISTINCT 
			T1.DeterminationID,
			CONCAT('D_', T1.DeterminationID) AS TraitID,
			ColumLabel = MAX(T4.ColumLabel),
			ColumnNR = MAX(T4.ColumnNR)
		FROM TestMaterialDetermination T1
		JOIN Determination T2 ON T2.DeterminationID = T1.DeterminationID
		JOIN RelationTraitDetermination T3 ON T3.DeterminationID = T1.DeterminationID
		JOIN CropTrait CT ON CT.CropTraitID = T3.CropTraitID
		JOIN Trait T ON T.TraitID = CT.TraitID
		JOIN [Column] T4 ON T4.TraitID = T.TraitID AND ISNULL(T4.TraitID, 0) <> 0
		WHERE T1.TestID = @TestID
		AND T4.FileID = @FileID
		GROUP BY T1.DeterminationID		
	) V1
	ORDER BY V1.ColumnNr;
	--get total rows inserted 
	SELECT @Total = (@@ROWCOUNT + 1);

	--Trait and Property columns
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr, DataType)
	SELECT Max(ColumnID), TraitID, ColumLabel, 2, (Max(ColumnNr) + @Total), Max(DataType)
	FROM [Column]	
	WHERE FileID = @FileID
	GROUP BY ColumLabel,TraitID
	--ORDER BY ColumnNr;
	
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
		V1.WellTypeID, V1.Fixed, --T01.ReplicaCount, 
		' + @Columns3 + N'
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
		--LEFT JOIN 
		--(
		--	SELECT
		--		TMDW.MaterialID , COUNT(TMDW.MaterialID) AS ReplicaCount
		--	FROM TestMaterialDeterminationWell TMDW
		--	JOIN Well W ON W.WellID = TMDW.WellID
		--	JOIN WellType WT ON WT.WellTypeID = W.WellTypeID			
		--	JOIN Plate P ON P.PlateID = W.PlateID
		--	WHERE P.TestID = @TestID AND WT.WellTypeName = ''A''
		--	GROUP BY TMDW.MaterialID
		--	HAVING COUNT(*) >1

		--) AS T01 ON T01.MaterialID = V1.MaterialID
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
				WHERE T2.FileID = @FileID --AND T4.UserID = @User
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
	
	SELECT CTE.MaterialID,CTE.WellTypeID, CTE.WellID, CTE.Fixed, CTE.Plate, CTE.Well, --[Replica] = CASE WHEN  ISNULL(CTE.ReplicaCount,0)> 0 THEN 1 ELSE 0 END, 
	' + @Columns3 + N', CTE_COUNT.TotalRows 
	FROM CTE, CTE_COUNT
	ORDER BY PlateID, Position2, Position1
	--Well
	OFFSET @Offset ROWS
	FETCH NEXT @PageSize ROWS ONLY;';

	PRINT @SQL
	
	SET @Offset = @PageSize * (@Page -1);

	--EXEC sp_executesql @SQL , N'@FileID INT, @User NVARCHAR(100), @Offset INT, @PageSize INT, @TestID INT', @FileID, @User, @Offset, @PageSize, @TestID;
	EXEC sp_executesql @SQL , N'@FileID INT, @Offset INT, @PageSize INT, @TestID INT', @FileID, @Offset, @PageSize, @TestID;

	--insert well and plate column
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr, DataType)
	VALUES(999991,NULL,'Plate',3,1,'NVARCHAR(255)'),(999992,NULL,'Well',3,2,'NVARCHAR(255)')
	--get columns information
	SELECT TraitID, ColumnLabel, ColumnType, ColumnNr, DataType,
	Fixed = CASE WHEN ColumnLabel = 'Crop' OR ColumnLabel = 'GID' OR ColumnLabel = 'Plantnr' OR ColumnLabel = 'Plant name' THEN 1 ELSE 0 END,
	MateriallblColumn = CASE WHEN (ColumnLabel = 'Plantnr' AND @Source = 'Breezys') OR (ColumnLabel = 'Plant name' AND @Source = 'Phenome') THEN 1 ELSE 0 END
	FROM @TblColumns T1
	order by ColumnNr;
END

GO
/****** Object:  StoredProcedure [dbo].[PR_GetDeterminations]    Script Date: 9/28/2018 12:38:31 PM ******/
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
	--@UserID		NVARCHAR(50),
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
			T.ColumnLabel,
			T2.ColumnNr
		FROM RelationTraitDetermination T1
		JOIN CropTrait CT ON CT.CropTraitID =T1.CropTraitID
		JOIN Trait T ON T.TraitID = CT.TraitID
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
			--AND F.UserID = @UserID			
		) T2 ON T2.TraitID = CT.TraitID --AND T2.RequestingSystem = T1.[Source] 
		AND T1.[StatusCode] = 100
	) T2 --ON T2.CropCode = T1.CropCode AND T2.DeterminationID = T1.DeterminationID
	ON T2.DeterminationID = T1.DeterminationID
	WHERE T1.CropCode = @CropCode AND T1.TestTypeID = @TestTypeID
	ORDER BY T2.ColumnNr;
END
GO
/****** Object:  StoredProcedure [dbo].[PR_GetMaterialWithMarker]    Script Date: 9/28/2018 12:38:31 PM ******/
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
	--@UserID NVARCHAR(100),
	@Page INT,
	@PageSize INT,
	@Filter NVARCHAR(MAX) = NULL
)
AS BEGIN
	SET NOCOUNT ON;

	DECLARE @ColumnIDs NVARCHAR(MAX), @Columns2 NVARCHAR(MAX), @ColumnID2s NVARCHAR(MAX), @Columns3 NVARCHAR(MAX);
	DECLARE @Offset INT, @Total INT, @FileID INT,@ReturnValue INT, @Query NVARCHAR(MAX),@Columns NVARCHAR(MAX);	
	DECLARE @TblColumns TABLE(ColumnID INT, TraitID VARCHAR(20), ColumnLabel NVARCHAR(50), ColumnType INT, ColumnNr INT, DataType NVARCHAR(15));

	--EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
	--IF(@ReturnValue <> 1) BEGIN
	--	RETURN;
	--END

	SELECT @FileID = F.FileID
	FROM [File] F
	JOIN Test T ON T.FileID = F.FileID 
	WHERE T.TestID = @TestID --AND F.UserID = @UserID;


	--Determination columns
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr)
	SELECT DeterminationID, TraitID, ColumLabel, 1, ROW_NUMBER() OVER(ORDER BY ColumnNR)
	FROM
	(	
		SELECT 
			T1.DeterminationID,
			CONCAT('D_', T1.DeterminationID) AS TraitID,
			MAX(T4.ColumLabel) AS ColumLabel,
			MAX(T4.ColumnNR) AS ColumnNR
		FROM TestMaterialDetermination T1
		JOIN Determination T2 ON T2.DeterminationID = T1.DeterminationID
		JOIN RelationTraitDetermination T3 ON T3.DeterminationID = T1.DeterminationID
		JOIN CropTrait CT ON CT.CropTraitID = T3.CropTraitID
		JOIN Trait T ON T.TraitID = CT.TraitID
		JOIN [Column] T4 ON T4.TraitID = T.TraitID AND ISNULL(T4.TraitID, 0) <> 0		
		WHERE T1.TestID = @TestID
		AND T4.FileID = @FileID			
		GROUP BY T1.DeterminationID	
	) V1
	ORDER BY V1.ColumnNr;
	--get total rows inserted 
	SELECT @Total = (@@ROWCOUNT + 1);

	

	--Trait and Property columns
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr, DataType)
	SELECT MAX(ColumnID), TraitID, ColumLabel, 2, (MAX(ColumnNr) + @Total), MAX(DataType)
	FROM [Column]
	WHERE FileID = @FileID
	GROUP BY ColumLabel,TraitID
	
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
					WHERE T4.FileID = @FileID --AND T4.UserID = @UserID
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
					WHERE T4.FileID = @FileID --AND T4.UserID = @UserID
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

		--EXEC sp_executesql @Query,N'@FileID INT, @UserID NVARCHAR(200), @Offset INT, @PageSize INT, @TestID INT', @FileID, @UserID, @Offset, @PageSize, @TestID;
		EXEC sp_executesql @Query,N'@FileID INT, @Offset INT, @PageSize INT, @TestID INT', @FileID, @Offset, @PageSize, @TestID;

		SELECT TraitID, ColumnLabel, ColumnType, ColumnNr, DataType,
		Fixed = CASE WHEN ColumnLabel = 'Crop' OR ColumnLabel = 'GID' OR ColumnLabel = 'Plantnr' OR ColumnLabel = 'Plant name' THEN 1 ELSE 0 END
		FROM @TblColumns T1
		ORDER BY ColumnNr;
	--END
END;
GO
/****** Object:  StoredProcedure [dbo].[PR_GetMaxWellPostionCreated]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_GetNextAvailableWellPostion]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_GetPlantsLookup]    Script Date: 9/28/2018 12:38:31 PM ******/
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
	--@UserID		NVARCHAR(100),
	@Query		NVARCHAR(1024) = NULL
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @Source NVARCHAR(MAX);
	DECLARE @Column NVARCHAR(MAX);

	SELECT @Source = [RequestingSystem] FROM Test WHERE TestID = @TestID

	
	IF(@Source = 'Breezys') BEGIN
		SET @Column = 'Plantnr';
	END
	ELSE BEGIN
		SET @Column = 'plant name';
	END

	SELECT DISTINCT TOP 20
		M.MaterialID, 
		MaterialKey = CE.Value 
	FROM Material M
	JOIN [Row] R ON R.MaterialKey = M.MaterialKey
	JOIN [Column] C ON C.FileID = R.FileID
	JOIN [Cell] CE ON CE.ColumnID = C.ColumnID AND CE.RowID = R.RowID
	JOIN Test T ON T.FileID = R.FileID

	WHERE T.TestID = @TestID AND C.ColumLabel = @Column AND CE.[Value] LIKE '%' + ISNULL(@Query, '') + '%'
	ORDER BY CE.Value;	
END
GO
/****** Object:  StoredProcedure [dbo].[PR_GetPlateLabels]    Script Date: 9/28/2018 12:38:31 PM ******/
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
	@TestID	INT--,
	--@UserID	NVARCHAR(100)
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @SyncCode NVARCHAR(4);

	--DECLARE @ReturnValue INT;
	--EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
	--IF(@ReturnValue <> 1) BEGIN
	--	RETURN;
	--END

	SELECT
		SyncCode = T.BreedingStationCode,
		F.CropCode, 		
		P.PlateName,
		P.LabPlateID
	FROM Plate P
	JOIN Test T ON T.TestID = P.TestID
	JOIN [File] F ON F.FileID = T.FileID AND F.UserID = T.RequestingUser
	WHERE T.TestID =  @TestID
	--AND T.RequestingUser = @UserID;
END
GO
/****** Object:  StoredProcedure [dbo].[PR_GetPlatesForLims]    Script Date: 9/28/2018 12:38:31 PM ******/
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
	@TestID	INT--,
	--@UserID	NVARCHAR(100)
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @Source NVARCHAR(100);
	DECLARE @ColumnLabel NVARCHAR(100) = 'plant name';

	DECLARE @ReturnValue INT;
	--EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
	--IF(@ReturnValue <> 1) BEGIN
	--	RETURN;
	--END


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

	SELECT @Source = RequestingSystem FROM Test WHERE TestID = @TestID;
	IF(ISNULL(@Source, '') = 'Breezys') BEGIN
		SET @ColumnLabel = 	'Plantnr';	
	END

	SELECT DISTINCT
		@PlantNrColumnID =  QUOTENAME(ColumnID)
	FROM [Column] C
	JOIN [File] F ON F.FileID = C.FileID
	JOIN Test T ON T.FileID = F.FileID
	WHERE C.ColumLabel = @ColumnLabel
	AND T.TestID = @TestID
	--AND T.RequestingUser = @UserID;

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
			WHERE C1.ColumLabel = @ColumnLabel
			AND T.TestID = @TestID
			--AND T.RequestingUser = @UserID
		) SRC
		PIVOT
		(
			MAX([Value])
			FOR [ColumnID] IN (' + @PlantNrColumnID + ')
		) PV';

	INSERT INTO @tbl(MaterialID, PlantNr) 
	--EXEC sp_executesql @SQL, N'@TestID INT, @UserID	NVARCHAR(100), @ColumnLabel NVARCHAR(100)', @TestID, @UserID, @ColumnLabel;
	EXEC sp_executesql @SQL, N'@TestID INT, @ColumnLabel NVARCHAR(100)', @TestID, @ColumnLabel;

	--GET Well and Material Information
	SELECT
		F.CropCode,
		LimsPlateplanID = T.LabPlatePlanID,0,
		RequestID = T.TestID,
		LimsPlateID = P.LabPlateID,0,
		LimsPlateName = P.PlateName,
		PlateColumn = SUBSTRING(W.Position, 2, LEN(W.Position) - 1),
		PlateRow = LEFT(W.Position, 1),
		PlantNr = CASE WHEN M.Source = 'Breezys' THEN  RIGHT(M.MaterialKey, LEN(M.MaterialKey) - 2) ELSE M.MaterialKey END,
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
	--AND T.RequestingUser = @UserID 
	AND WellTypeName !='D';


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
	--AND T.RequestingUser = @UserID
	ORDER BY P.LabPlateID, D.DeterminationID;
END
GO
/****** Object:  StoredProcedure [dbo].[PR_GetPunchList]    Script Date: 9/28/2018 12:38:31 PM ******/
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
	@PlatePlanName NVARCHAR(200) OUT,
	@SlotName NVARCHAR(MAX) OUT
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
	DECLARE @Columnlabel NVARCHAR(MAX),@Source NVARCHAR(MAX);
	--DECLARE @PlatePlanID INT, @PlatePlanName NVARCHAR(200);

	SELECT @PlatePlanID = LabPlatePlanID,
	@PlatePlanName = LabPlatePlanName,
	@SlotName = S.SlotName 
	FROM Test T
	LEFT JOIN SlotTest ST ON ST.TestID = T.TestID
	LEFT JOIN Slot S ON S.SlotID = ST.SlotID  WHERE T.TestID = @TestID;
			
	SELECT @TotalPlates = COUNT(PlateID)
	FROM Plate
	WHERE TestID = @TestID; 

	SELECT @TestType = TestTypeID,@Source = RequestingSystem 
	FROM Test
	WHERE TestID = @TestID;

	SELECT @FileID = T.FileID ,
		   @FileTitle = F.FileTitle
	FROM [File] F
	JOIN Test T on T.FileID = F.FileID
	WHERE T.TestID = @TestID;

	IF(@Source = 'Breezys') BEGIN
		SET @Columnlabel = 'Plantnr';
	END
	ELSE BEGIN
		SET @Columnlabel = 'plant name';
	END


	SELECT @PlantNrColumnID = QUOTENAME(ColumnID)
	FROM [Column] C
	JOIN [File] F ON F.FileID = C.FileID
	WHERE F.FileID = @FileID AND C.ColumLabel = @Columnlabel;

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
/****** Object:  StoredProcedure [dbo].[PR_GetSlot_ForTest]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_GetStatusList]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_GetTestDetail]    Script Date: 9/28/2018 12:38:31 PM ******/
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
	@TestID	INT--,
	--@UserID	NVARCHAR(100)
)
AS
BEGIN
	
	SET NOCOUNT ON;

	--DECLARE @ReturnValue INT;
	--EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
	--IF(@ReturnValue <> 1) BEGIN
	--	RETURN;
	--END

    SELECT
		TestID,
		StatusCode
	FROM Test 
	WHERE TestID =  @TestID
	--AND   RequestingUser = @UserID;

	IF(@@ROWCOUNT <= 0) BEGIN
		EXEC PR_ThrowError N'You are not authorized to use this test.';
		RETURN;
	END

END
GO
/****** Object:  StoredProcedure [dbo].[PR_GetTestInfoForLIMS]    Script Date: 9/28/2018 12:38:31 PM ******/
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
	--@UserID NVARCHAR(100),
	@MaxPlates INT
)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @SynCode CHAR(2), @CropCode CHAR(2), @TotalTests INT, @Isolated BIT, @ReturnValue INT, @RemarkRequired BIT, @DeterminationRequired INT,@DeadWellType INT,@TotalPlates INT;

	--Validate Test for corresponding user
	--EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
	--IF(@ReturnValue <> 1) BEGIN
	--	RETURN;
	--END

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


	--SELECT TOP 1 @SynCode = (LEFT(M.MaterialKey,2)) , 
	--			 @CropCode = M.CropCode
	--FROM Row R
	--JOIN Test T ON T.FileID = R.FileID
	--JOIN Material M ON M.MaterialKey = R.MaterialKey
	--WHERE T.TestID = @TestID
	--  AND T.RequestingUser = @UserID;
	SELECT TOP 1 @SynCode = T.SyncCode, 
				 @CropCode = F.CropCode
	FROM Test T 
	JOIN [File] F ON F.FileID = T.FileID
	WHERE T.TestID = @TestID
	  --AND T.RequestingUser = @UserID;

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
	  --AND T.RequestingUser = @UserID;

	--For Test type with Remarkrequired true is DNA Isolation type. For DNA Isolation type, Isolated value is true
	IF(@RemarkRequired = 1)
		SET @Isolated = 1

	--Determination should be used for Test type with DeterminatonRequired true
	IF(@TotalTests = 0 AND @DeterminationRequired = 1)
	BEGIN
		EXEC PR_ThrowError N'Please assign at least one Marker/Determination.';
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
	 --AND  T.RequestingUser = @UserID
	GROUP BY T.TestID, T.PlannedDate, T.Remark, MS.MaterialStateCode, MT.MaterialTypeCode, CT.ContainerTypeCode, T.Isolated,T.ExpectedDate;

END
GO
/****** Object:  StoredProcedure [dbo].[PR_GetTestsLookup]    Script Date: 9/28/2018 12:38:31 PM ******/
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
	--@UserID nvarchar(100)
	@CropCode NVARCHAR(10),
	@BreedingStationCode NVARCHAR(10)
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
		WellsPerPlate = @TotalWells - ISNULL(T3.Blocked,0),
		T.BreedingStationCode,
		F.CropCode,
		T.ExpectedDate,
		S1.SlotName,
		T.LabPlatePlanName
	FROM [File] F
	JOIN Test T ON T.FileID = F.FileID
	JOIN TestType TT ON T.TestTypeID = TT.TestTypeID
	LEFT JOIN [Status] ST ON ST.StatusCode = T.StatusCode AND ST.StatusTable = 'Test'
	LEFT JOIN
	(
		SELECT T.TestID, COUNT(WT.WellTypeID) AS TotalFixed
		FROM Well W
		JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
		JOIN Plate P ON P.PlateID = W.PlateID
		JOIN Test T ON T.TestID = P.TestID
		JOIN [File] F ON F.FileID = T.FileID
		WHERE WT.WellTypeName   = 'F' AND 
		       --T.RequestingUser = @UserID
			   T.BreedingStationCode = @BreedingStationCode AND F.CropCode = @CropCode
		GROUP BY T.TestID
	) T1 ON T1.TestID = T.TestID
	LEFT JOIN 
	(
		SELECT T.TestID, COUNT(MaterialID) AS ReplicatedCount FROM
		[File] F 
		JOIN Test T ON T.FileID = T.FileID
		JOIN Plate P ON P.TestID = T.TestID
		JOIN Well W ON W.PlateID = P.PlateID
		JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
		JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID		
		WHERE --T.RequestingUser = @UserID
			--AND 
			WT.WellTypeName <> 'F'
			AND F.CropCode = @CropCode AND T.BreedingStationCode = @BreedingStationCode
			GROUP BY T.TestID
			HAVING COUNT(MaterialID) > 1
	) T2 ON T2.TestID = T.TestID
	LEFT JOIN SlotTest ST1 ON ST1.TestID = T.TestID
	LEFT JOIN Slot S1 ON S1.SlotID = ST1.SlotID
	LEFT JOIN 
	(
		SELECT Blocked = COUNT(TT.TestTypeID),TT.TestTypeID
		FROM TestType TT
		LEFT JOIN WellTypePosition WTP ON TT.TestTypeID = WTP.TestTypeID
		LEFT JOIN WellType WT ON WT.WellTypeID = WTP.WellTypeID
		WHERE WT.WellTypeName = 'B'
		GROUP BY TT.TestTypeID,WTP.WellTypeID
	) T3 ON T3.TestTypeID = T.TestTypeID
	WHERE --T.RequestingUser = @UserID
	F.CropCode = @CropCode AND T.BreedingStationCode = @BreedingStationCode
	AND T.StatusCode <= 600
	ORDER BY TestID DESC;

END

GO
/****** Object:  StoredProcedure [dbo].[PR_GetTraitValues]    Script Date: 9/28/2018 12:38:31 PM ******/
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
	ORDER BY SortingOrder;
END
GO
/****** Object:  StoredProcedure [dbo].[PR_GetWellPositionsLookup]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_ImportFromPhenomeFor3GB]    Script Date: 9/28/2018 12:38:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_ImportFromPhenomeFor3GB]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_ImportFromPhenomeFor3GB] AS' 
END
GO
ALTER PROCEDURE [dbo].[PR_ImportFromPhenomeFor3GB]
(
	@CropCode				NVARCHAR(10),
	@BrStationCode			NVARCHAR(10),
	@SyncCode				NVARCHAR(2),
	@TestTypeID				INT,
	@TestName				NVARCHAR(200),	
	@Source					NVARCHAR(50),
	@ObjectID				NVARCHAR(100),
	@ThreeGBTaskID			INT,
	@UserID					NVARCHAR(100),
	@TVPColumns TVP_Column	READONLY,
	@TVPRow TVP_Row			READONLY,
	@TVPCell TVP_Cell		READONLY,
	@TestID					INT OUTPUT
)
AS BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;

		IF EXISTS(SELECT FileTitle FROM [File] F 
		JOIN Test T ON T.FileID = F.FileID WHERE T.BreedingStationCode = @BrStationCode AND F.CropCode = @CropCode AND F.FileTitle = @TestName) BEGIN
			EXEC PR_ThrowError 'File already exists.';
			RETURN;
		END

		IF(ISNULL(@TestTypeID,0)=0) BEGIN
			EXEC PR_ThrowError 'Invalid test type ID.';
			RETURN;
		END

		DECLARE @RowData TABLE([RowID] int,	[RowNr] int	);
		DECLARE @ColumnData TABLE([ColumnID] int,[ColumnNr] int);
		DECLARE @FileID INT;

		INSERT INTO [FILE] ([CropCode],[FileTitle],[UserID],[ImportDateTime], [RefExternal])
		VALUES(@CropCode, @TestName, @UserID, GETUTCDATE(), @ObjectID);
		--Get Last inserted fileid
		SELECT @FileID = SCOPE_IDENTITY();

		INSERT INTO [Row] ( [RowNr], [MaterialKey], [FileID])
		OUTPUT INSERTED.[RowID],INSERTED.[RowNr] INTO @RowData
		SELECT T.RowNr,T.MaterialKey,@FileID FROM @TVPRow T;

		INSERT INTO [Column] ([ColumnNr], [TraitID], [ColumLabel], [FileID], [DataType])
		OUTPUT INSERTED.[ColumnID], INSERTED.[ColumnNr] INTO @ColumnData
		SELECT T.[ColumnNr], T1.[TraitID], T.[ColumLabel], @FileID, T.[DataType] FROM @TVPColumns T
		LEFT JOIN Trait T1 ON T1.TraitName = T.ColumLabel
		LEFT JOIN CropTrait CT ON CT.TraitID = T.TraitID AND CT.CropCode = @CropCode
		
		

		INSERT INTO [Cell] ( [RowID], [ColumnID], [Value])
		SELECT [RowID], [ColumnID], [Value] 
		FROM @TVPCell T1
		JOIN @RowData T2 ON T2.RowNr = T1.RowNr
		JOIN @ColumnData T3 ON T3.ColumnNr = T1.ColumnNr;	

		--CREATE TEST
		INSERT INTO [Test]([TestTypeID],[FileID],[RequestingSystem],[RequestingUser],[TestName],[CreationDate],[StatusCode],[BreedingStationCode],[SyncCode], ThreeGBTaskID)
		VALUES(@TestTypeID, @FileID, @Source, @UserID, @TestName , GETUTCDATE(), 100,@BrStationCode,@SyncCode, @ThreeGBTaskID);
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
/****** Object:  StoredProcedure [dbo].[PR_ImportTraitDeterminationRelation]    Script Date: 9/28/2018 12:38:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_ImportTraitDeterminationRelation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_ImportTraitDeterminationRelation] AS' 
END
GO
/*
declare @p1 dbo.TVP_Trait_Determination_Relation
insert into @p1 values(N'CB LoV Int',N'CC',N'SLM0000001',N'R',N'0001')
insert into @p1 values(N'CLoVT 5',N'CC',N'SLM0000001',N'RS',N'0010')
insert into @p1 values(N'CLoVT 5',N'CC',N'SLM0000002',N'RR',N'0101')
insert into @p1 values(N'CB LoV Int',N'CC',N'SLM0000002',N'SR',N'1010')

exec PR_ImportTraitDeterminationRelation @TVP_Trait_Determination_Relation=@p1
*/
ALTER PROCEDURE [dbo].[PR_ImportTraitDeterminationRelation]
(
	@TVP_Trait_Determination_Relation TVP_Trait_Determination_Relation READONLY
) AS BEGIN
BEGIN TRY
		BEGIN TRAN
		DECLARE @RelationTraitDetermination AS TABLE
		(
			CropTraitID INT,
			DeterminationID INT,
			TraitValue NVARCHAR(MAX),
			DeterminationValue NVARCHAR(MAX)
		);

		INSERT INTO @RelationTraitDetermination(CropTraitID,DeterminationID,TraitValue, DeterminationValue)
		SELECT T.CropTraitID,D.DeterminationID,R.TraitValue,R.DeterminationValue FROM @TVP_Trait_Determination_Relation R
		JOIN 
		(
			SELECT CT.CropTraitID, CT.CropCode, CT.TraitID, T.ColumnLabel FROM Trait T
			JOIN CropTrait CT ON CT.TraitID = T.TraitID
		) T ON T.ColumnLabel = R.TraitName AND T.CropCode = R.CropCode
		JOIN Determination D ON D.DeterminationName = R.DeterminationName 
		

			SELECT CropTraitID,DeterminationID FROM @RelationTraitDetermination
			GROUP BY CropTraitID, DeterminationID

			SELECT R.RelationID,T1.TraitValue, T1.DeterminationValue FROM @RelationTraitDetermination T1
			JOIN RelationTraitDetermination R ON R.CropTraitID = T1.CropTraitID AND R.DeterminationID = T1.DeterminationID


		MERGE INTO RelationTraitDetermination T
		USING 
		(
			SELECT CropTraitID,DeterminationID FROM @RelationTraitDetermination
			GROUP BY CropTraitID, DeterminationID
		) S ON S.CropTraitID = T.CropTraitID
		WHEN NOT MATCHED THEN
		INSERT(CropTraitID,DeterminationID,StatusCode)
		VALUES (S.CropTraitID, S.DeterminationID,100);
		


		MERGE INTO TraitDeterminationResult T
		USING 
		(
			SELECT R.RelationID,T1.TraitValue, T1.DeterminationValue FROM @RelationTraitDetermination T1
			JOIN RelationTraitDetermination R ON R.CropTraitID = T1.CropTraitID AND R.DeterminationID = T1.DeterminationID
		) S ON S.RelationID = T.RelationID
		WHEN NOT MATCHED THEN
		INSERT(RelationID, DetResChar, TraitResChar)
		VALUES (S.RelationID, S.DeterminationValue, S.TraitValue)
		WHEN MATCHED AND T.DetResChar <> S.DeterminationValue THEN
		UPDATE SET T.DetResChar = S.DeterminationValue;


		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK;
		THROW;
	END CATCH
END


GO
/****** Object:  StoredProcedure [dbo].[PR_Insert_ExcelData]    Script Date: 9/28/2018 12:38:31 PM ******/
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
	@BreedingStationCode    NVARCHAR(10),
	@SyncCode				NVARCHAR(2),
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
	@ObjectID				NVARCHAR(100),
	@ExpectedDate			DATETIME
)
AS BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;

		IF EXISTS(SELECT FileTitle FROM [File] F 
		JOIN Test T ON T.FileID = F.FileID WHERE T.BreedingStationCode = @BreedingStationCode AND F.CropCode = @CropCode AND F.FileTitle =@FileTitle) BEGIN
			EXEC PR_ThrowError 'File already exists.';
			RETURN;
		END

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
		SELECT T.[ColumnNr], CT.[TraitID], T.[ColumLabel], @FileID, T.[DataType] FROM @TVPColumns T
		LEFT JOIN Trait T1 ON T1.TraitName = T.ColumLabel
		LEFT JOIN CropTrait CT ON CT.TraitID = T1.TraitID AND CT.CropCode = @CropCode
		
		

		INSERT INTO [Cell] ( [RowID], [ColumnID], [Value])
		SELECT [RowID], [ColumnID], [Value] 
		FROM @TVPCell T1
		JOIN @RowData T2 ON T2.RowNr = T1.RowNr
		JOIN @ColumnData T3 ON T3.ColumnNr = T1.ColumnNr;	

		--CREATE TEST
		INSERT INTO [Test]([TestTypeID],[FileID],[RequestingSystem],[RequestingUser],[TestName],[CreationDate],[StatusCode],[PlannedDate], [MaterialStateID],[MaterialTypeID], [ContainerTypeID],[Isolated],[BreedingStationCode],[ExpectedDate],[SyncCode])
		VALUES(@TestTypeID, @FileID, @Source, @UserID,@TestName , GETUTCDATE(), 100,@PlannedDate,@MaterialStateID, @MaterialTypeID, @ContainerTypeID, @Isolated,@BreedingStationCode, @ExpectedDate,@SyncCode);
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
/****** Object:  StoredProcedure [dbo].[PR_Material_MarkasDead]    Script Date: 9/28/2018 12:38:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_Material_MarkasDead]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_Material_MarkasDead] AS' 
END
GO

/*
==============EXAMPLE================

*/

ALTER PROCEDURE [dbo].[PR_Material_MarkasDead]
(	
	@TestID			INT,
	--@MaterialIDs	NVARCHAR(MAX)
	@WellIDS		NVARCHAR(MAX)
) AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ReturnValue INT;
	DECLARE @FixedWellType INT,@WellType INT;
		
	--EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
	--IF(@ReturnValue <> 1) BEGIN
	--	RETURN;
	--END
	IF(ISNULL(@WellIDS,'')= '' ) BEGIN
		EXEC PR_ThrowError 'Invalid Material';
		RETURN;
	END

	BEGIN TRY
		SELECT @WellType = WellTypeID 
		FROM WellType 
		WHERE WellTYpeName = 'D';

		SELECT @FixedWellType= WellTypeID 
		FROM WellType 
		WHERE WellTYpeName = 'F';

		BEGIN TRAN;

			IF EXISTS(SELECT  W.WellID 
								FROM TestMaterialDeterminationWell TMDW
								JOIN Well W ON W.WellID = TMDW.WellID
								JOIN Plate P ON P.PlateID = W.PlateID
								JOIN string_split(@WellIDS,',') M ON M.value = TMDW.WellID 
								WHERE P.TestID = @TestID AND W.WellTypeID = @FixedWellType) BEGIN
								
								EXEC PR_ThrowError 'Fixed Position Material cannot be marked as dead.';
								RETURN;

			END

			UPDATE Well 
			SET WellTypeID = @WellType
			WHERE WellID IN ( SELECT  W.WellID 
								FROM TestMaterialDeterminationWell TMDW
								JOIN Well W ON W.WellID = TMDW.WellID
								JOIN Plate P ON P.PlateID = W.PlateID
								JOIN string_split(@WellIDS,',') M ON M.value = TMDW.WellID 
								WHERE P.TestID = @TestID AND W.WellTypeID != @FixedWellType);

			--IF EXISTS(SELECT TOP 1 DeterminationID FROM TestMaterialDetermination TMD
			--			JOIN string_split(@MaterialIDs,',') M ON M.value = TMD.MaterialID
			--			WHERE TestID = @TestID) BEGIN
			--	DELETE FROM TestMaterialDetermination WHERE MaterialID = @MaterialID AND TestID = @TestID;			
			--Update status
			--	IF EXISTS(SELECT StatusCode FROM Test WHERE StatusCode = 300 AND TestID = @TestID) BEGIN
			--		EXEC PR_Update_TestStatus @TestID, 350
			--	END
			--END
			IF EXISTS(SELECT StatusCode FROM Test WHERE StatusCode = 300 AND TestID = @TestID) BEGIN
					EXEC PR_Update_TestStatus @TestID, 350
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
/****** Object:  StoredProcedure [dbo].[PR_PLAN_ApproveSlot]    Script Date: 9/28/2018 12:38:31 PM ******/
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
	DECLARE @PlannedDate DATETIME,@AdditionalMarker INT,@AdditionalPlates INT;
	BEGIN TRY
		BEGIN TRAN
			IF NOT EXISTS (SELECT SlotID FROM Slot WHERE SlotID = @SlotID) BEGIN	
				EXEC PR_ThrowError 'Invalid slot';
				RETURN;
			END
			SELECT @PlannedDate = PlannedDate from Slot WHERE SlotID = @SlotID;
			
			EXEC PR_Validate_Capacity_Period_Protocol @SlotID,@PlannedDate,@AdditionalMarker OUT,@AdditionalPlates OUT;

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
/****** Object:  StoredProcedure [dbo].[PR_PLAN_ChangeSlot]    Script Date: 9/28/2018 12:38:31 PM ******/
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

		DECLARE @ReturnValue INT, @AdditionalMarker INT, @AdditionalPlates INT;

		--begin transaction here
		BEGIN TRAN
		
			EXEC PR_Validate_Capacity_Period_Protocol @SlotID, @PlannedDate, @AdditionalMarker OUT,  @AdditionalPlates OUT;

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
/****** Object:  StoredProcedure [dbo].[PR_PLAN_Get_Avail_Plates_Tests]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_PLAN_Get_ReserveCapacity_LookUp]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetCapacity]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetCurrentPeriod]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetMaterialTypePerCrop_Lookup]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetPeriodDetail]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetPlanApprovalListBySlotForLAB]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetPlanApprovalListForLAB]    Script Date: 9/28/2018 12:38:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_PLAN_GetPlanApprovalListForLAB]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_PLAN_GetPlanApprovalListForLAB] AS' 
END
GO
--EXEC PR_PLAN_GetPlanApprovalListForLAB 91
ALTER PROCEDURE [dbo].[PR_PLAN_GetPlanApprovalListForLAB]
(
	@PeriodID	INT = NULL
) AS BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ARGS		NVARCHAR(MAX);
	DECLARE @SQL		NVARCHAR(MAX);

	--Prepare 8 periods to display
	DECLARE @Periods TVP_PLAN_Period;
	IF(ISNULL(@PeriodID, 0) <> 0) BEGIN
		INSERT INTO @Periods(PeriodID) 
		SELECT TOP 8 
			PeriodID
		FROM [Period] 
		WHERE PeriodID >= @PeriodID
		ORDER BY PeriodID;
	END

	
	ELSE BEGIN
		--get current period
		EXEC @PeriodID = PR_PLAN_GetCurrentPeriod;
		INSERT INTO @Periods(PeriodID) 
		SELECT TOP 8 
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
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetPlannedOverview]    Script Date: 9/28/2018 12:38:31 PM ******/
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
	@Year			INT,
	@PeriodID		INT				= NULL
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
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetPlanPeriods]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetSlotData]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_PLAN_GetSlotsForBreeder]    Script Date: 9/28/2018 12:38:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_PLAN_GetSlotsForBreeder]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_PLAN_GetSlotsForBreeder] AS' 
END
GO
-- EXEC PR_PLAN_GetSlotsForBreeder 'To', 'NLEN', 'KATHMANDU\Krishna', 1, 20, 'name=dibya'
ALTER PROCEDURE [dbo].[PR_PLAN_GetSlotsForBreeder]
(
	@CropCode		NVARCHAR(10),
	@BrStationCode	NVARCHAR(50),
	@RequestUser	NVARCHAR(100),
	@Page			INT,
	@PageSize		INT,
	@Filter			NVARCHAR(MAX) = NULL
)
AS BEGIN
	SET NOCOUNT ON;
	DECLARE @SQL NVARCHAR(MAX);
	DECLARE @Offset INT;
	DECLARE @WellType INT;

	SELECT @WellType = WelltypeID FROM WellType WHERE WellTypeName != 'D';

	SET @Offset = @PageSize * (@Page -1);
	
	SET @SQL = N'WITH CTE AS
	(
		SELECT 
			SlotID = S.SlotID,
			SlotName = MAX(S.SlotName),
			PeriodName = MAX(P.PeriodName2),
			CropCode = MAX(S.CropCode),
			BreedingStationCode = MAX(S.BreedingStationCode),
			MaterialTypeCode = MAX(MT.MaterialTypeCode),
			MaterialStateCode = MAX(MS.MaterialStateCode),
			RequestDate = MAX(S.RequestDate),
			PlannedDate = MAX(S.PlannedDate),
			ExpectedDate = MAX(S.ExpectedDate),
			Isolated = S.Isolated,
			StatusCode = MAX(S.StatusCode),
			StatusName = MAX(STA.StatusName),			
			[TotalPlates] =SUM(ISNULL(RC.NrOfPlates,0)),
			[TotalTests] =SUM(ISNULL(RC.NrOfTests,0)),
			[AvailablePlates] =SUM(ISNULL(RC.NrOfPlates,0)) - SUM(ISNULL(UsedPlates,0)),
			[AvailableTests] = SUM(ISNULL(RC.NrOfTests,0)) - SUM(ISNULL(UsedMarker,0)),
			UsedPlates = SUM(ISNULL(UsedPlates,0)),
			UsedMarker = SUM(ISNULL(UsedMarker,0))
		FROM Slot S
		JOIN VW_Period P ON P.PeriodID = S.PeriodID
		JOIN MaterialType MT ON MT.MaterialTypeID = S.MaterialTypeID
		JOIN MaterialState MS ON MS.MaterialStateID = S.MaterialStateID
		JOIN [Status] STA ON STA.StatusCode = S.StatusCode AND STA.StatusTable = ''Slot''
		LEFT JOIN
		(
			SELECT SlotID,NrOfTests = MAX(ISNULL(RC.NrOfTests,0)),
			NrOfPlates = MAX(ISNULL(RC.NrOfPlates,0)) FROM ReservedCapacity RC
			GROUP BY SlotID
		
		) RC ON RC.SlotID = S.SlotID
		LEFT JOIN 
		(

			SELECT SlotID, COUNT(DISTINCT P.PlateID) AS UsedPlates
			FROM SlotTest ST 
			JOIN Test T ON T.TestID = ST.TestID
			JOIN Plate P ON P.TestID = T.TestID
			GROUP BY SlotID
		) T1 ON T1.SlotID = S.SlotID
		LEFT JOIN 
		(
			SELECT SlotID, COUNT(DeterminationID) AS UsedMarker  FROM 
			(

				SELECT SlotID,T.TestID,P.PlateID,TMD.DeterminationID
				FROM SlotTest ST 
				JOIN Test T ON T.TestID = ST.TestID
				JOIN Plate P ON P.TestID = T.TestID			
				JOIN Well W ON W.PlateID = P.PlateID				
				JOIN TestMaterialDetermination TMD on TMD.TestID = T.TestID
				JOIN TestMaterialDeterminationWell TMDW oN Tmdw.MaterialID = TMD.MaterialID

				WHERE W.WellTypeID != @WellType
				GROUP BY ST.SlotID,T.TestID,P.PlateID,DeterminationID
			) V 
			GROUP BY SlotID
		) T2 ON T2.SlotID = S.SlotID
		WHERE S.CropCode = @CropCode
		AND S.BreedingStationCode = @BrStationCode
		 ' + CASE WHEN ISNULL(@Filter,'') <> '' THEN ' AND ' + @Filter ELSE '' END + N'
	
	GROUP BY S.SlotID, Isolated), CTE_COUNT AS (SELECT COUNT(SlotID) AS [TotalRows] FROM CTE)
	
	SELECT CTE.*, CTE_COUNT.TotalRows 
	FROM CTE, CTE_COUNT
	ORDER BY PlannedDate DESC
	OFFSET @Offset ROWS
	FETCH NEXT @PageSize ROWS ONLY';

	--PRINT @SQL;

	EXEC sp_executesql @SQL, N'@CropCode NVARCHAR(10), @BrStationCode NVARCHAR(50), @Offset INT, @PageSize INT, @WellType INT', @CropCode, @BrStationCode, @Offset, @PageSize, @WellType;
END
GO
/****** Object:  StoredProcedure [dbo].[PR_PLAN_RejectSlot]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_PLAN_Reserve_Capacity]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_PLAN_SaveCapacity]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_PLAN_Update_Slot_Period]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_PLAN_UpdateCapacitySlot]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_RearrangeMaterialOnWell]    Script Date: 9/28/2018 12:38:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_RearrangeMaterialOnWell]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_RearrangeMaterialOnWell] AS' 
END
GO
ALTER PROCEDURE [dbo].[PR_RearrangeMaterialOnWell]
(
	@TestID INT
)
AS BEGIN
	DECLARE @ReturnValue INT,@Material TVP_Material,@Well TVP_Material, @AssignedWellType INT, @EmptyWellType INT,@MaterialWithWell TVP_TMDW, @MaxRowNr INT;--, @DeadMaterialCount INT;

	SELECT @AssignedWellType = WellTypeID
			FROM WellType WHERE WellTypeName = 'A';
			
	SELECT @EmptyWellType = WellTypeID 
			FROM WellType WHERE WellTypeName = 'E';

	--Get ordered material withoud fixed position material (which will be replicated on each plates on specific position)
	INSERT INTO @Material (MaterialID)
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
				JOIN Plate P ON P.PlateID = W.PlateID
				JOIN WellType WT ON WT.WellTypeID = W.WEllTypeID		
				WHERE P.TestID = @TestID AND WT.WellTypeName = 'A' 
			) T
		) T1
		ORDER BY PlateID, Position2, Position1

		--get ordered well position without fixed position (which will be replicated on each plates on specific position).
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

			--delete last empty well which can be shifted forward on position.
			DELETE TMDW
			FROM TestMaterialDeterminationWell TMDW
			WHERE TMDW.WellID IN (SELECT MaterialID FROM @Well WHERE RowNr > @MaxRowNr)

			--Merge to rearrange all material after some action like create replica or delete.
			MERGE TestMaterialDeterminationWell T
			USING @MaterialWithWell S
			ON T.WellID = S.WellID --AND T.MaterialID <> S.MaterialID
			WHEN MATCHED AND T.MaterialID != S.MaterialID
			THEN UPDATE SET T.MaterialID = S.MaterialID
			WHEN NOT MATCHED 
			THEN INSERT (MaterialID,WellID)
			VALUES( S.MaterialID,S.WellID);
END
GO
/****** Object:  StoredProcedure [dbo].[PR_ReorderMaterial]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_Replicate_Material]    Script Date: 9/28/2018 12:38:31 PM ******/
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
	--@UserID NVARCHAR(200),
	@NrOfReplicate INT,
	@Collated BIT,
	@MaxPlates INT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ReturnValue INT,@MaterialToAdd INT,@ToReplicateMaterialCount INT, @TotalExistingMaterial INT,@TotalExistingMaterialExceptFixed INT,  @WellsCreated INT, @Count INT =0, @ReplicateCount INT =0, @MaterialID NVARCHAR(200), @Lastmaterial INT = 0, @TVP_Material_Copy TVP_Material_Rep;
	DECLARE @LastPlateName NVARCHAR(200), @CreatePlateAndWell BIT = 0, @PlateID INT=0, @PlateIDLast INT =0;
	DECLARE @MaterialAll TVP_Material,@ExistingMaterial TVP_Material,@Well TVP_Material,@MaterialWithWell TVP_TMDW;
	DECLARE @FixedOnlyMaterial TVP_Material, @FixedOnlyWell TVP_Material, @FixedMaterialWithWell TVP_TMDW;
	DECLARE @FixedWellTypeID INT, @AssignedWellTypeID INT, @DeadWellTypeID INT;
	DECLARE @WellsPerPlateWithoutFixed INT, @RequiredPlates INT, @CreatedPlates INT;
	BEGIN TRY
		IF(ISNULL(@TestID,0)=0) BEGIN
			EXEC PR_ThrowError 'Requested Test does not exist.';
			RETURN;
		END

		--check valid test.
		--EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
		--IF(@ReturnValue <> 1) BEGIN
		--	RETURN;
		--END
		--check status for validation of changed column
		IF EXISTS(SELECT StatusCode FROM Test WHERE StatusCode >= 400 AND TestID = @TestID) BEGIN
			EXEC PR_ThrowError 'Cannot change Status for this test.';
			RETURN;
		END

		--IF EXISTS( SELECT TOP 1 W.WellID FROM WELL W
		--	JOIN Plate P ON P.PlateID = W.PlateID
		--	JOIN WellTYpe WT ON WT.WellTypeID = W.WellTypeID
		--	WHERE P.TestID = @TestID AND WT.WellTYpeName = 'D') BEGIN
		--		EXEC PR_ThrowError 'Replica cannot be completed. Remove dead material first.';
		--		RETURN;
		--END

		IF EXISTS(	SELECT TOP 1 T1.MaterialID FROM TestMaterialDeterminationWell TMDW 
			JOIN @TVP_Material T1 ON T1.MaterialID = TMDW.MaterialID
			JOIN Well W ON W.WellID = TMDW.WellID
			JOIN Plate P ON P.PlateID = W.PlateID
			JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
			WHERE WT.WellTypeName IN ('F','D') AND P.TestID = @TestID) BEGIN

			EXEC PR_ThrowError 'Cannot create replica of dead or fixed positioned material.';
			RETURN;
		END

		IF EXISTS(SELECT MaterialID FROM @TVP_Material GROUP BY MaterialID Having COUNT(MaterialID) >1) BEGIN
			EXEC PR_ThrowError 'Duplicate material is selected.';
			RETURN;
		END

		SELECT @FixedWellTypeID = WelltypeID 
		FROM WellType WHERE WellTypeName = 'F';

		SELECT @AssignedWellTypeID = WelltypeID 
		FROM WellType WHERE WellTypeName = 'A';

		SELECT @DeadWellTypeID = WelltypeID 
		FROM WellType WHERE WellTypeName = 'D';


		SELECT @ToReplicateMaterialCount = COUNT(*) FROM @TVP_Material;
		SELECT @TotalExistingMaterial = COUNT(MaterialID) FROM TestMaterialDeterminationWell TMDW 
			JOIN Well W ON W.WellID = TMDW.WellID
			JOIN Plate P ON P.PlateID = W.PlateID
			WHERE P.TestID = @TestID;

		SELECT @TotalExistingMaterialExceptFixed = COUNT(MaterialID) FROM TestMaterialDeterminationWell TMDW 
		JOIN Well W ON W.WellID = TMDW.WellID
		JOIN Plate P ON P.PlateID = W.PlateID
		WHERE P.TestID = @TestID AND W.WellTypeID != @FixedWellTypeID;

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
				WHERE PlateID = @PlateIDLast AND W.WellTypeID != @FixedWellTypeID;


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
					WHERE W.PlateID = @PlateIDLast AND W.WellTypeID = @FixedWellTypeID
					ORDER BY W.Position;		

					DELETE FROM @FixedOnlyWell;
					--GET fixed only well id
					INSERT INTO @FixedOnlyWell(MaterialID)
					SELECT W.WellID
					FROM Well W 
					--JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID
					--JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
					WHERE W.WellTypeID = @FixedWellTypeID AND W.PlateID = @PlateID
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

			--get all material without fixed and dead material
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
					--JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
					JOIN Plate P ON P.PlateID = W.PlateID
					WHERE P.TestID = @TestID AND (W.WellTypeID !=@FixedWellTypeID AND W.WellTypeID != @DeadWellTypeID)
					
				) T
			) T1
			ORDER BY PlateID, Position2, Position1

			--get ordered well without fixed and dead well 
			INSERT INTO @Well(MaterialID)
			SELECT T.WellID
			FROM 
			(
				SELECT W.*, CAST(RIGHT(Position,LEN(Position)-1) AS INT) AS Position1
				,LEFT(Position,1) as Position2
				FROM Well W
				JOIN Plate P ON P.PlateID = W.PlateID
				--JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
				WHERE P.TestID = @TestID AND (W.WellTypeID !=@FixedWellTypeID AND W.WellTypeID != @DeadWellTypeID)		
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
				WHEN NOT MATCHED THEN
				INSERT (MaterialID,WellID)
				VALUES (S.MaterialID,S.WellID)
				WHEN MATCHED AND T.MaterialID <> S.MaterialID THEN
				UPDATE SET T.MaterialID = S.MaterialID;

				--MERGE TestMaterialDeterminationWell T
				--USING @MaterialWithWell S
				--ON T.WellID = S.WellID AND T.MaterialID <> S.MaterialID
				--WHEN MATCHED
				--THEN UPDATE SET T.MaterialID = S.MaterialID;

				----Update well type to assigned
				--SELECT @AssignedWellType = WellTypeID 
				--FROM WELLType WHERE WellTypeName = 'A'

				UPDATE W
				SET W.WellTypeID = @AssignedWellTypeID
				FROM Well W 
				JOIN @MaterialWithWell MW ON MW.WellID = W.WellID
				WHERE W.WellTypeID != @AssignedWellTypeID

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
				WHEN NOT MATCHED THEN 
				INSERT (MaterialID,WellID)
				VALUES (S.MaterialID,S.WellID)
				WHEN MATCHED AND T.MaterialID <> S.MaterialID THEN
				UPDATE SET T.MaterialID = S.MaterialID;

				--MERGE TestMaterialDeterminationWell T
				--USING @MaterialWithWell S
				--ON T.WellID = S.WellID AND T.MaterialID <> S.MaterialID
				--WHEN MATCHED
				--THEN UPDATE SET T.MaterialID = S.MaterialID;

				----Update well type to assigned
				--SELECT @AssignedWellType = WellTypeID 
				--FROM WELLType WHERE WellTypeName = 'A'

				UPDATE W
				SET W.WellTypeID = @AssignedWellTypeID
				FROM Well W 
				JOIN @MaterialWithWell MW ON MW.WellID = W.WellID
				WHERE W.WellTypeID != @AssignedWellTypeID
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
/****** Object:  StoredProcedure [dbo].[PR_Save_RelationTraitDetermination]    Script Date: 9/28/2018 12:38:31 PM ******/
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
	
	--validation on insert
	--EXEC PR_ThrowError 'test'
	--RETURN;

	

	IF EXISTS (SELECT R.RelationID 
		FROM RelationTraitDetermination R 
		JOIN  @TVP_RelationTraitDetermination T1
		ON R.CropTraitID = T1.TraitID AND R.DeterminationID = T1.DeterminationID
		WHERE  T1.[Action] = 'I') BEGIN
			EXEC PR_ThrowError 'Insert Failed. Relation already exists.';
			RETURN;
		RETURN;
	END

	--validation for update and delete.
	IF EXISTS(
		SELECT TSR.TraitDeterminationResultID FROM TraitDeterminationResult TSR
		JOIN @TVP_RelationTraitDetermination T1 ON T1.RelationID = TSR.RelationID
		JOIN RelationTraitDetermination RTS ON RTS.RelationID = TSR.RelationID
		WHERE T1.DeterminationID != RTS.DeterminationID AND T1.Action IN ('U','D')) BEGIN
		EXEC PR_ThrowError 'Trait result mapping(s) already present for this Trait - Determination. Please delete Trait Result first.';
		RETURN;
	END



	INSERT INTO RelationTraitDetermination(CropTraitID, DeterminationID, [StatusCode])
	SELECT T1.TraitID, D.DeterminationID, '100'
	FROM @TVP_RelationTraitDetermination T1
	JOIN Determination D ON D.DeterminationID = T1.DeterminationID
	WHERE ISNULL(T1.RelationID, 0) = 0 AND T1.[Action] = 'I';

	--UPdate Statement 
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
/****** Object:  StoredProcedure [dbo].[PR_Save_Score]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_Save_SlotTest]    Script Date: 9/28/2018 12:38:31 PM ******/
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
				UPDATE SlotTest SET SlotID = @SlotID WHERE TestID = @TestID;
			END
			ELSE BEGIN
				INSERT INTO SlotTest(SlotID, TestID)
				VALUES(@SlotID, @TestID)	
			END			
			--UPdate test status to 150 meaning status changed from created to slot consumed.
			EXEC PR_Update_TestStatus @TestID, 150;

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
/****** Object:  StoredProcedure [dbo].[PR_SavePlannedDate]    Script Date: 9/28/2018 12:38:31 PM ******/
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
	--@UserID	NVARCHAR(100),
	@PlannedDate DATETIME
) AS
BEGIN
	
	--DECLARE @ReturnValue INT;
	--EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
	--IF(@ReturnValue <> 1) BEGIN		
	--	RETURN;
	--END

	UPDATE Test
	SET PlannedDate = @PlannedDate
	WHERE TestID = @TestID
END
GO
/****** Object:  StoredProcedure [dbo].[PR_SaveRemark]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_SaveTestMaterialDetermination]    Script Date: 9/28/2018 12:38:31 PM ******/
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
	--@UserID								NVARCHAR(200),
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
		WHERE T.TestID = @TestID --AND F.UserID = @UserID;

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
			--EXEC  PR_SaveTestMaterialDeterminationWithQuery @FileID, @UserID, @CropCode, @TestID, @Columns, @Filter, @Determinations
			EXEC  PR_SaveTestMaterialDeterminationWithQuery @FileID, @CropCode, @TestID, @Columns, @Filter, @Determinations
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
/****** Object:  StoredProcedure [dbo].[PR_SaveTestMaterialDeterminationWithQuery]    Script Date: 9/28/2018 12:38:31 PM ******/
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
	--@UserID			NVARCHAR(50),
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
					WHERE T2.FileID = @FileID --AND T4.UserID = @UserID
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
		--EXEC sp_executesql @Query, N'@FileID INT, @UserID NVARCHAR(100)', @FileID,@UserID;
		EXEC sp_executesql @Query, N'@FileID INT', @FileID;
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
		CROSS JOIN 
		(
			SELECT DeterminationID  
			FROM @Determinations 
			GROUP BY DeterminationID
		) D 
		
	) S
	ON T.MaterialID = S.MaterialID AND T.TestID = @TestID AND T.DeterminationID = S.DeterminationID
	WHEN NOT MATCHED THEN 
	INSERT(TestID,MaterialID,DeterminationID) VALUES(@TestID,S.MaterialID,s.DeterminationID);
		
END
GO
/****** Object:  StoredProcedure [dbo].[PR_SaveTestMaterialDeterminationWithTVP]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_SaveTraitDeterminationResult]    Script Date: 9/28/2018 12:38:31 PM ******/
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

	--insert or delete operation
	MERGE INTO TraitDeterminationResult T
				USING
				(
					SELECT T1.RelationID,TraitResChar,DetResChar
					FROM @TVP T1	--get only data to insert otherwise it will not match for update and delete also.
					WHERE T1.Action in ('I','U')						
				) S	ON S.RelationID = T.RelationID AND S.TraitResChar = T.TraitResChar
				WHEN NOT MATCHED THEN
					INSERT(RelationID, DetResChar,TraitResChar)
					VALUES(S.RelationID, S.DetResChar,S.TraitResChar)
				WHEN MATCHED THEN
					UPDATE SET T.DetResChar = S.DetResChar;

			--DELETE Statement 
			DELETE R
			FROM @TVP T1 
			JOIN TraitDeterminationResult R ON R.TraitDeterminationResultID = T1.TraitDeterminationResultID
			WHERE T1.[Action] = 'D';

END
GO
/****** Object:  StoredProcedure [dbo].[PR_ThrowError]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_UndoDead]    Script Date: 9/28/2018 12:38:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_UndoDead]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_UndoDead] AS' 
END
GO
ALTER PROCEDURE [dbo].[PR_UndoDead]
(
	@TestID INT,
	@WellIDS NVARCHAR(MAX)
)
AS BEGIN
	DECLARE @AssignedWellType INT, @DeadWellType INT;

	SELECT @AssignedWellType = WellTypeID FROM WellType WHERE WellTypeName = 'A';

	SELECT @DeadWellType = WellTypeID FROM WellType WHERE WellTypeName = 'D';



	UPDATE  W 
	SET  W.WellTypeID = @AssignedWellType
	FROM TestMaterialDeterminationWell TMDW 
	JOIN string_split(@WellIDS,',') V ON V.[value] = TMDW.WellID
	JOIN Well W ON W.WellID = TMDW.WellID
	JOIN Plate P  ON P.PlateID = W.PlateID
	WHERE P.TestID = @TestID AND W.WellTypeID = @DeadWellType; 

	SELECT @AssignedWellType, TestID, StatusCode 
	FROM Test WHERE TestID = @TestID;

END
GO
/****** Object:  StoredProcedure [dbo].[PR_Update_Test]    Script Date: 9/28/2018 12:38:31 PM ******/
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
	--@UserID NVARCHAR(200),
	@ContainerTypeID INT,
	@Isolated BIT,
	@MaterialTypeID INT,
	@MaterialStateID INT,
	@PlannedDate DateTime,
	@TestTypeID INT,
	@ExpectedDate DATETIME,
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

	----check valid test.
	--EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
	--IF(@ReturnValue <> 1) BEGIN
	--	RETURN;
	--END
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
			ExpectedDate = @ExpectedDate
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
/****** Object:  StoredProcedure [dbo].[PR_Update_TestStatus]    Script Date: 9/28/2018 12:38:31 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PR_Update3GBMaterials]    Script Date: 9/28/2018 12:38:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_Update3GBMaterials]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_Update3GBMaterials] AS' 
END
GO
ALTER PROCEDURE [dbo].[PR_Update3GBMaterials]
(
	@TestID		INT,
	@TVP		TVP_3GBMaterials	READONLY
) AS BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN;

		UPDATE M SET 
			ThreeGBPlantID = T.ThreeGBPlantID
		FROM Material M
		JOIN @TVP T ON T.MaterialKey = M.MaterialKey;

		--change status of test
		UPDATE Test SET StatusCode = 700 /*Completed*/ WHERE TestID = @TestID;

		COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[PR_UpdateAndVerifyTraitDeterminationResult]    Script Date: 9/28/2018 12:38:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_UpdateAndVerifyTraitDeterminationResult]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_UpdateAndVerifyTraitDeterminationResult] AS' 
END
GO
--EXEC PR_UpdateAndVerifyTraitDeterminationResult 'Phenome'
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
		FROM TraitDeterminationResult TDR
		JOIN RelationTraitDetermination RTD ON RTD.RelationID = TDR.RelationID
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
/****** Object:  StoredProcedure [dbo].[PR_Validate_Capacity_Period_Protocol]    Script Date: 9/28/2018 12:38:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_Validate_Capacity_Period_Protocol]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_Validate_Capacity_Period_Protocol] AS' 
END
GO
/*
 DECLARE @ReturnValue INT, @AdditionalMarker INT, @AdditionalPlates INT;
 EXEC @ReturnValue = PR_Validate_Capacity_Period_Protocol 145, '10-04-2018', @AdditionalMarker OUT,  @AdditionalPlates OUT
 PRINT @ReturnValue
 PRINT @AdditionalMarker
 PRINT @AdditionalPlates
*/

ALTER PROCEDURE [dbo].[PR_Validate_Capacity_Period_Protocol]
(
	@SlotID INT,
	@PlannedDate DATETIME,
	@AdditionalMarker INT OUT,
	@AdditionalPlates INT OUT
)
AS BEGIN
	DECLARE @PeriodID INT,@ProtocolID INT, @CapacityMarker INT, @CapacityPlates INT,@ReservedMarker INT, @ReservedPlates INT;
	DECLARE @RequiredMarker INT, @RequiredPlates INT;
	DECLARE @PlateProtocolID INT,@MarkerProtocolID INT;

	--if plate is greater not null or greater than 0 then it is plateprotocolid.
	SELECT @PlateProtocolID = TestProtocolID 
	FROM ReservedCapacity WHERE ISNULL(NrOFPlates,0) <> 0 AND SlotID = @SlotID;

	--IF Plate is null then this is marker protocol
	SELECT @MarkerProtocolID = TestProtocolID 
	FROM ReservedCapacity WHERE ISNULL(NrOFPlates,0) = 0 AND SlotID = @SlotID; 

	SELECT @PeriodID = PeriodID
	FROM [Period] WHERE CAST(@PlannedDate AS DATE) BETWEEN CAST(StartDate AS DATE) AND CAST(EndDate AS DATE);

	SELECT 
		@CapacityMarker =SUM(ISNULL(NrOfTests,0)),
		@CapacityPlates = SUM(ISNULL(NrOfPlates,0))
	FROM AvailCapacity 
	WHERE PeriodID = @PeriodID AND TestProtocolID IN (SELECT TestProtocolID FROM ReservedCapacity WHERE SlotID = @SlotID)

	SELECT 
		@ReservedMarker =SUM(ISNULL(NrOfTests,0)),
		@ReservedPlates = SUM(ISNULL(NrOfPlates,0))
	FROM ReservedCapacity RC
	JOIN Slot S ON  S.SlotID = RC.SlotID
	WHERE PeriodID = @PeriodID AND TestProtocolID IN (SELECT TestProtocolID FROM ReservedCapacity WHERE SlotID = @SlotID)
	AND S.StatusCode = 200


	SELECT 
		@RequiredMarker = SUM(ISNULL(NrOfTests,0)),
		@RequiredPlates = SUM(ISNULL(NrOfPlates,0))
	FROM ReservedCapacity Where SlotID = @SlotID;
	
	SET @ReservedMarker = ISNULL(@ReservedMarker,0);
	SET @ReservedPlates = ISNULL(@ReservedPlates,0);

	SET @RequiredMarker = ISNULL(@RequiredMarker,0);
	SET @RequiredPlates = ISNULL(@RequiredPlates,0);

	SET @CapacityMarker = ISNULL(@CapacityMarker,0);
	SET @CapacityPlates = ISNULL(@CapacityPlates,0);
	
	IF( @RequiredMarker + @ReservedMarker > @CapacityMarker OR @RequiredPlates + @ReservedPlates > @CapacityPlates) BEGIN
		SET @AdditionalMarker = (@ReservedMarker + @RequiredMarker) - @CapacityMarker;
		SET @AdditionalPlates = (@RequiredPlates + @ReservedPlates) - @CapacityPlates;		

		IF (@AdditionalPlates > 0) BEGIN		
			UPDATE AvailCapacity
			SET NrOfPlates = NrOfPlates + ISNULL(@AdditionalPlates,0)
			WHERE PeriodID = @PeriodID AND TestProtocolID = @PlateProtocolID;
		END

		IF(@AdditionalMarker > 0) BEGIN
			UPDATE AvailCapacity
			SET NrOfTests = NrOfTests + ISNULL(@AdditionalMarker,0)
			WHERE PeriodID = @PeriodID AND TestProtocolID = @MarkerProtocolID;
		END

		

	END
	
END
GO
/****** Object:  StoredProcedure [dbo].[PR_Validate_Columns_Determination]    Script Date: 9/28/2018 12:38:31 PM ******/
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

	DECLARE @TVPCol TVP_Column;

	IF(@Source = 'Phenome') BEGIN
		INSERT INTO @TVPCol(ColumnNr,ColumLabel,DataType,TraitID)
		SELECT T1.ColumnNr, T1.ColumLabel,T1.DataType,T.TraitID FROM @TVPColumns T1
		JOIN Trait T ON T.TraitName = T1.ColumLabel
	END
	--We should fetch trait id from traitcolumn for source Breezys
	--ELSE BEGIN
	--	INSERT INTO @TVPCol(ColumnNr,ColumLabel,DataType,TraitID)
	--	SELECT T1.ColumnNr, T1.ColumLabel,T1.DataType,T.TraitID FROM @TVPColumns T1
	--	JOIN Trait T ON T.TraitName = T1.ColumLabel
	--END

	SELECT t.DeterminationID, STUFF(
		(SELECT ',' + CAST(T1.TraitID AS NVARCHAR(100))
			FROM RelationTraitDetermination s
			JOIN CropTrait CT ON CT.CropTraitID = S.CropTraitID
			JOIN Trait T1 ON T1.TraitID = CT.TraitID
			--JOIN @TVPColumns T1 ON T1.TraitID = S.TraitID AND S.CropCode = @Crop 
			--WHERE s.DeterminationID = t.DeterminationID AND S.Source = @Source AND s.[Status] = 'ACT'
			JOIN 
			(
				SELECT CT.CropTraitID FROM Trait T
				JOIN CropTrait CT ON CT.TraitID = T.TraitID
				JOIN @TVPCol T1 ON T1.TraitID = T.TraitID
				WHERE CT.CropCode = @Crop
			) T12
			ON T12.CropTraitID = S.CropTraitID
			WHERE S.DeterminationID = T.DeterminationID AND S.[StatusCode] = 100
		FOR XML PATH('')),1,1,'') AS Traits
		FROM RelationTraitDetermination AS T 
		--JOIN @TVPColumns T1 ON T1.TraitID = T.TraitID WHERE t.CropCode = @Crop  AND t.[Source] = @Source and T.[Status] = 'ACT'
		JOIN 
			(
				SELECT CT.CropTraitID FROM Trait T
				JOIN CropTrait CT ON CT.TraitID = T.TraitID 
				JOIN @TVPCol T1 ON T1.TraitID = T.TraitID
				WHERE CT.CropCode = @Crop
			) T1
			ON T1.CropTraitID = T.CropTraitID
			WHERE T.[StatusCode] = 100
		GROUP BY t.DeterminationID Having Count(t.DeterminationID) > 1
END
GO
/****** Object:  StoredProcedure [dbo].[PR_ValidateTest]    Script Date: 9/28/2018 12:38:31 PM ******/
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
	--@UserID	NVARCHAR(100)
	@BreedingStationCode NVARCHAR(10),
	@CropCode NVARCHAR(10)
) AS BEGIN
	--IF NOT EXISTS(SELECT TestID FROM Test WHERE TestID = @TestID AND RequestingUser = @UserID) BEGIN
	--	EXEC PR_ThrowError N'Test is either not valid or you are not authorized to access it.';
	--	RETURN 0;
	--END
	--RETURN 1;

	IF NOT EXISTS
	(
		SELECT TestID FROM Test T
		JOIN [File] F ON F.FileID = T.FileID
		WHERE TestID = @TestID 
		--AND RequestingUser = @UserID
		AND F.CropCode = @CropCode AND T.BreedingStationCode = @BreedingStationCode
		) BEGIN
			EXEC PR_ThrowError N'Test is either not valid or you are not authorized to access it.';
		RETURN 0;
	END
	RETURN 1;

END
GO
