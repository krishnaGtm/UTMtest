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
EXEC PR_Get_PlatePlanOverview null, 0, 'ON,TO','','',1,211
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
							RequestedMarkers = STUFF((SELECT DISTINCT '','', + CAST(TRT.ColumnLabel AS NVARCHAR(50) )
										FROM
										Test TT 
										JOIN [File] F ON F.FileID = TT.FIleID
										JOIN TestMaterialDetermination TMD On TMD.TestID = TT.TestID
										JOIN TestMaterialDeterminationWell TMDW ON TMD.MaterialID = TMDW.MaterialID
										JOIN RelationTraitDetermination RTD ON RTD.DeterminationID = TMD.DeterminationID
										JOIN CropTrait CT ON CT.CropTraitID = RTD.CropTraitID
										JOIN Trait TRT ON TRT.TraitID = CT.TraitID
										JOIN [Column] C ON C.FileID = F.FileID AND C.TraitID = TRT.TraitID
										WHERE TT.TestID = T.TestID AND CT.CropCode = F.CropCode
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
								RequestedMarkers = STUFF((SELECT DISTINCT '','', + CAST(TRT.ColumnLabel AS NVARCHAR(50) )
										FROM
										Test TT 
										JOIN [File] F ON F.FileID = TT.FIleID
										JOIN TestMaterialDetermination TMD On TMD.TestID = TT.TestID
										JOIN TestMaterialDeterminationWell TMDW ON TMD.MaterialID = TMDW.MaterialID
										JOIN RelationTraitDetermination RTD ON RTD.DeterminationID = TMD.DeterminationID
										JOIN CropTrait CT ON CT.CropTraitID = RTD.CropTraitID
										JOIN Trait TRT ON TRT.TraitID = CT.TraitID
										JOIN [Column] C ON C.FileID = F.FileID AND C.TraitID = TRT.TraitID
										WHERE TT.TestID = T.TestID AND CT.CropCode = F.CropCode
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


DROP PROCEDURE IF EXISTS [dbo].[PR_Import_ExternalData]
GO



/*
	Author					Date			Description
	Dibya					2020-01-30		Import external excel file into UTM
	Krishna Gautam			2020-03-12		#11373: Automatically assign marker based on marker name on columns (marker01, marker02, marker03,.....)
	Krishna Gautam			2020-05-04		#13094: Issue while importing fixed.
*/
CREATE PROCEDURE [dbo].[PR_Import_ExternalData]
(
	@CropCode				NVARCHAR(10),
	@BreedingStationCode    NVARCHAR(10),
	@SyncCode				NVARCHAR(10),
	@CountryCode			NVARCHAR(10),
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
	@ExpectedDate			DATETIME,
	@Cumulate				BIT,
	@ImportLevel			NVARCHAR(20),
	@ExcludeControlPosition BIT,
	@BTR					BIT,
	@ResearcherName			NVARCHAR(50)
)
AS BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;

		DECLARE @2GBTestType INT =0;
		DECLARE @TVPTMD TVP_TMD;

		DECLARE @FileID INT;

		--import data as new test/file
		  IF EXISTS(SELECT FileTitle 
				    FROM [File] F 
				    JOIN Test T ON T.FileID = F.FileID 
				    WHERE T.BreedingStationCode = @BreedingStationCode 
				    AND F.CropCode = @CropCode 
				    AND F.FileTitle =@FileTitle) 
		  BEGIN
			 EXEC PR_ThrowError 'File already exists.';
			 RETURN;
		  END

		  IF(ISNULL(@TestTypeID,0)=0) BEGIN
			 EXEC PR_ThrowError 'Invalid test type ID.';
			 RETURN;
		  END

		  SELECT @2GBTestType = TestTypeID FROM TestType WHERE TestTypeCode = 'MT';

		  DECLARE @RowData TABLE([RowID] int, [RowNr] int);
		  DECLARE @ColumnData TABLE([ColumnID] int,[ColumnNr] int);

		  INSERT INTO [FILE] ([CropCode],[FileTitle],[UserID],[ImportDateTime])
		  VALUES(@CropCode, @FileTitle, @UserID, GETUTCDATE());
		  --Get Last inserted fileid
		  SELECT @FileID = SCOPE_IDENTITY();

		  INSERT INTO [Row] ([RowNr], [MaterialKey], [FileID], NrOfSamples)
		  OUTPUT INSERTED.[RowID], INSERTED.[RowNr] INTO @RowData
		  SELECT T.RowNr, T.MaterialKey, @FileID, 1 FROM @TVPRow T;
		  --Update MaterialKey with RowID since it is not coming from excel file for this external import
		  UPDATE R SET 
			 R.MaterialKey = R.RowID
		  FROM [Row] R
		  JOIN @RowData R2 ON R2.RowID = R.RowID;

		  INSERT INTO [Column] ([ColumnNr], [TraitID], [ColumLabel], [FileID], [DataType])
		  OUTPUT INSERTED.[ColumnID], INSERTED.[ColumnNr] INTO @ColumnData
		  SELECT T.[ColumnNr], T1.[TraitID], T.[ColumLabel], @FileID, T.[DataType] FROM @TVPColumns T
		  LEFT JOIN 
		  (
			 SELECT CT.TraitID,T.TraitName, T.ColumnLabel
			 FROM Trait T 
			 JOIN CropTrait CT ON CT.TraitID = T.TraitID
			 WHERE CT.CropCode = @CropCode AND T.Property = 0
		  )
		  T1 ON T1.ColumnLabel = T.ColumLabel;		

		  INSERT INTO [Cell] ( [RowID], [ColumnID], [Value])
		  SELECT [RowID], [ColumnID], [Value] 
		  FROM @TVPCell T1
		  JOIN @RowData T2 ON T2.RowNr = T1.RowNr
		  JOIN @ColumnData T3 ON T3.ColumnNr = T1.ColumnNr
		  WHERE ISNULL(T1.[Value],'') <> '';	

		  --CREATE TEST
		  INSERT INTO [Test]([TestTypeID],[FileID],[RequestingSystem],[RequestingUser],[TestName],[CreationDate],[StatusCode],[PlannedDate], [MaterialStateID],
			 [MaterialTypeID], [ContainerTypeID],[Isolated],[BreedingStationCode],[ExpectedDate],[SyncCode],[Cumulate], [ImportLevel], CountryCode, ExcludeControlPosition, BTR, Researcher)
		  VALUES(@TestTypeID, @FileID, @Source, @UserID,@TestName , GETUTCDATE(), 100,@PlannedDate,@MaterialStateID, @MaterialTypeID, @ContainerTypeID, 
			 @Isolated,@BreedingStationCode, @ExpectedDate,@SyncCode, @Cumulate, @ImportLevel, @CountryCode, @ExcludeControlPosition, @BTR, @ResearcherName);
		  --Get Last inserted testid
		  SELECT @TestID = SCOPE_IDENTITY();

		  --CREATE Materials if not already created
		  MERGE INTO Material T 
		  USING
		  (
				SELECT 
				    R.MaterialKey
				FROM [Row] R
				WHERE FileID = @FileID		
		  ) S	ON S.MaterialKey = T.MaterialKey
		  WHEN NOT MATCHED THEN 
			 INSERT(MaterialType, MaterialKey, [Source], CropCode, BreedingStationCode)
			 VALUES (@ImportLevel, S.MaterialKey, @Source, @CropCode, @BreedingStationCode);


		--change of #11373 starts here
		IF(@2GBTestType = @TestTypeID)
		BEGIN

			INSERT INTO @TVPTMD(MaterialID,DeterminationID,Selected)
			SELECT 
				M.MaterialID,
				D.DeterminationID,
				1 
			FROM [File] F
			JOIN [Row] R ON R.FileID = F.FileID
			JOIN Material M ON M.MaterialKey = R.MaterialKey
			JOIN [Column] C ON C.FileID = F.FileID
			JOIN [Cell] C1 ON C1.RowID = R.RowID AND C1.ColumnID = C.ColumnID
			JOIN Determination D ON D.DeterminationName = C1.[Value] AND D.CropCode = F.CropCode
			JOIN TestTypeDetermination TTD ON TTD.DeterminationID = D.DeterminationID AND TTD.TestTypeID = @TestTypeID
			WHERE F.FileID = @FileID AND C.ColumLabel LIKE 'Marker%';

			
			EXEC  PR_SaveTestMaterialDeterminationWithTVP @CropCode, @TestID, @TVPTMD

			--set rearrange to true 
			UPDATE Test SET RearrangePlateFilling = 1 WHERE TestID = @TestID;

		END
		
		COMMIT;
	END TRY
	BEGIN CATCH
	   IF @@TRANCOUNT >0
		  ROLLBACK;
	   THROW;
	END CATCH
END
GO


DROP PROCEDURE IF EXISTS [dbo].[PR_Insert_ExcelData]
GO


CREATE PROCEDURE [dbo].[PR_Insert_ExcelData]
(
	@CropCode				NVARCHAR(10),
	@BreedingStationCode    NVARCHAR(10),
	@SyncCode				NVARCHAR(10),
	@CountryCode			NVARCHAR(10),
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
	@ExpectedDate			DATETIME,
	@Cumulate				BIT,
	@ImportLevel			NVARCHAR(20),
	@TVPList TVP_List		READONLY,
	@ExcludeControlPosition BIT,
	@SiteID					INT = NULL,
	@FileID					INT,
	@BTR					BIT,
	@ResearcherName			NVARCHAR(50)
)
AS BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;

		--import data as new test/file
		IF(ISNULL(@FileID,0) = 0) 
		BEGIN
			IF EXISTS(SELECT FileTitle FROM [File] F 
			JOIN Test T ON T.FileID = F.FileID WHERE T.BreedingStationCode = @BreedingStationCode AND F.CropCode = @CropCode AND F.FileTitle =@FileTitle) BEGIN
				EXEC PR_ThrowError 'File already exists.';
				RETURN;
			END

			IF(ISNULL(@TestTypeID,0)=0) BEGIN
				EXEC PR_ThrowError 'Invalid test type ID.';
				RETURN;
			END

			IF(ISNULL(@SiteID,0)=0 AND @TestTypeID = 8)
			BEGIN
				EXEC PR_ThrowError N'Site Location can not be empty.';
				RETURN;
			END

			DECLARE @RowData TABLE([RowID] int,	[RowNr] int	);
			DECLARE @ColumnData TABLE([ColumnID] int,[ColumnNr] int);
			--DECLARE @FileID INT;

			INSERT INTO [FILE] ([CropCode],[FileTitle],[UserID],[ImportDateTime])
			VALUES(@CropCode, @FileTitle, @UserID, GETUTCDATE());
			--Get Last inserted fileid
			SELECT @FileID = SCOPE_IDENTITY();

			INSERT INTO [Row] ( [RowNr], [MaterialKey], [FileID], NrOfSamples)
			OUTPUT INSERTED.[RowID],INSERTED.[RowNr] INTO @RowData
			SELECT T.RowNr,T.MaterialKey,@FileID, 1 FROM @TVPRow T;

			INSERT INTO [Column] ([ColumnNr], [TraitID], [ColumLabel], [FileID], [DataType])
			OUTPUT INSERTED.[ColumnID], INSERTED.[ColumnNr] INTO @ColumnData
			SELECT T.[ColumnNr], T1.[TraitID], T.[ColumLabel], @FileID, T.[DataType] FROM @TVPColumns T
			LEFT JOIN 
			(
				SELECT CT.TraitID,T.TraitName, T.ColumnLabel
				FROM Trait T 
				JOIN CropTrait CT ON CT.TraitID = T.TraitID
				WHERE CT.CropCode = @CropCode AND T.Property = 0
			)
			T1 ON T1.ColumnLabel = T.ColumLabel
		
		

			INSERT INTO [Cell] ( [RowID], [ColumnID], [Value])
			SELECT [RowID], [ColumnID], [Value] 
			FROM @TVPCell T1
			JOIN @RowData T2 ON T2.RowNr = T1.RowNr
			JOIN @ColumnData T3 ON T3.ColumnNr = T1.ColumnNr
			WHERE ISNULL(T1.[Value],'')<>'';	

			
			--CREATE TEST
			INSERT INTO [Test]([TestTypeID],[FileID],[RequestingSystem],[RequestingUser],[TestName],[CreationDate],[StatusCode],[PlannedDate], [MaterialStateID],
				[MaterialTypeID], [ContainerTypeID],[Isolated],[BreedingStationCode],[ExpectedDate],[SyncCode],[Cumulate], [ImportLevel], CountryCode, ExcludeControlPosition, SiteID, BTR, Researcher)
			VALUES(@TestTypeID, @FileID, @Source, @UserID,@TestName , GETUTCDATE(), 100,@PlannedDate,@MaterialStateID, @MaterialTypeID, @ContainerTypeID, 
				@Isolated,@BreedingStationCode, @ExpectedDate,@SyncCode, @Cumulate, @ImportLevel, @CountryCode, @ExcludeControlPosition, @SiteID, @BTR, @ResearcherName);


			--Get Last inserted testid
			SELECT @TestID = SCOPE_IDENTITY();

			--CREATE Materials if not already created

			IF(@Source = 'Phenome') BEGIN
				MERGE INTO Material T 
				USING
				(
					SELECT R.MaterialKey,Max(L.RowID) as RowID
					FROM @TVPRow R
					JOIN @TVPList L ON R.GID = L.GID --AND R.EntryCode = L.EntryCode
					GROUP BY R.MaterialKey
				) S	ON S.MaterialKey = T.MaterialKey
				WHEN NOT MATCHED THEN 
					INSERT(MaterialType, MaterialKey, [Source], CropCode,Originrowid,RefExternal,BreedingStationCode)
					VALUES (@ImportLevel, S.MaterialKey, @Source, @CropCode,S.RowID,@ObjectID,@BreedingStationCode)
				WHEN MATCHED AND ISNULL(S.RowID,0) <> ISNULL(T.OriginrowID,0) THEN 
					UPDATE  SET T.OriginrowID = S.RowID,T.RefExternal = @ObjectID ,BreedingStationCode = @BreedingStationCode;

			END
			ELSE BEGIN
				MERGE INTO Material T 
				USING
				(
					SELECT R.MaterialKey
					FROM [Row] R
					WHERE FileID = @FileID		
				) S	ON S.MaterialKey = T.MaterialKey
				WHEN NOT MATCHED THEN 
					INSERT(MaterialType, MaterialKey, [Source], CropCode)
					VALUES (@ImportLevel, S.MaterialKey, @Source, @CropCode);

			END

			IF(@TestTypeID = 8)
			BEGIN
				INSERT INTO TestMaterial(TestID, MaterialID)
				SELECT @TestID, M.MaterialID FROM Material M 
				JOIN [Row] R ON R.MaterialKey = M.Materialkey
				WHERE R.FileId = @FileID
			END

		END

		--import data to existing test/file
		ELSE 
			BEGIN
			--SELECT * FROM Test
			DECLARE @TempTVP_Cell TVP_Cell, @TempTVP_Column TVP_Column, @TempTVP_Row TVP_Row, @TVP_Material TVP_Material, @TVP_Well TVP_Material,@TVP_MaterialWithWell TVP_TMDW;
			DECLARE @LastRowNr INT =0, @LastColumnNr INT = 0,@PlatesCreated INT,@PlatesRequired INT,@WellsPerPlate INT,@LastPlateID INT,@PlateID INT,@TotalRows INT,@TotalMaterial INT;
			DECLARE @NewColumns TABLE([ColumnNr] INT,[TraitID] INT,[ColumLabel] NVARCHAR(100),[DataType] VARCHAR(15),[NewColumnNr] INT);
			DECLARE @TempRow TABLE (RowNr INT IDENTITY(1,1),MaterialKey NVARCHAR(MAX));
			DECLARE @BridgeColumnTable AS TABLE(OldColNr INT, NewColNr INT);
			DECLARE @RowData1 TABLE(RowNr INT,RowID INT,MaterialKey NVARCHAR(MAX));
			DECLARE @BridgeRowTable AS TABLE(OldRowNr INT, NewRowNr INT);
			DECLARE @StatusCode INT;

			DECLARE @CropCode1 NVARCHAR(10),@BreedingStationCode1 NVARCHAR(10),@SyncCode1 NVARCHAR(2), @CountryCode1 NVARCHAR(10);

			SELECT 
				@CropCode1 = F.CropCode,
				@BreedingStationCode1 = T.BreedingStationCode,
				@SyncCode1 = T.SyncCode,
				@CountryCode1 = T.CountryCode,
				@TestTypeID = T.TestTypeID,
				@UserID = T.RequestingUser,
				@FileTitle = F.FileTitle,
				@TestName = T.TestName,
				@PlannedDate = T.PlannedDate,
				@MaterialStateID = T.MaterialStateID,
				@MaterialTypeID = T.MaterialTypeID,
				@ContainerTypeID = T.ContainerTypeID,
				@Isolated = T.Isolated,
				@Source = T.RequestingSystem,
				@ExpectedDate = T.ExpectedDate,
				@Cumulate = T.Cumulate,
				@TestID = T.TestID
			FROM [File] F
			JOIN Test T ON T.FileID = F.FileID
			WHERE F.FileID = @FileID

			SELECT @StatusCode = Statuscode FROM Test WHERE TestID = @TestID

			IF(@StatusCode >=200) BEGIN
				EXEC PR_ThrowError 'Cannot import material to this test after plate is requested on LIMS.';
				RETURN;
			END
	
			IF(ISNULL(@CropCode1,'')<> ISNULL(@CropCode,'')) BEGIN
				EXEC PR_ThrowError 'Cannot import material with different crop  to this test.';
				RETURN;
			END
			IF(ISNULL(@BreedingStationCode1,'')<> ISNULL(@BreedingStationCode,'')) BEGIN
				EXEC PR_ThrowError 'Cannot import material with different breeding station to this test.';
				RETURN;
			END
			IF(ISNULL(@SyncCode1,'')<> ISNULL(@SyncCode,'')) BEGIN
				EXEC PR_ThrowError 'Cannot import material with different sync code to this test.';
				RETURN;
			END
			IF(ISNULL(@CountryCode1,'') <> ISNULL(@CountryCode,'')) BEGIN
				EXEC PR_ThrowError 'Cannot import material with different country to this test.';
				RETURN;
			END
			
			INSERT INTO @TempTVP_Cell(RowNr,ColumnNr,[Value])
			SELECT RowNr,ColumnNr,[Value] FROM @TVPCell

			INSERT INTO @TempTVP_Column(ColumnNr,ColumLabel,DataType,TraitID)
			SELECT ColumnNr,ColumLabel,DataType,TraitID FROM @TVPColumns;

			INSERT INTO @TempTVP_Row(RowNr,MaterialKey)
			SELECT RowNr,Materialkey FROM @TVPRow;

			--get maximum column number inserted in column table.
			SELECT @LastColumnNr = ISNULL(MAX(ColumnNr), 0)
			FROM [Column] 
			WHERE FileID = @FileID;


			--get maximum row number inserted on row table.
			SELECT @LastRowNr = ISNULL(MAX(RowNr),0)
			FROM [Row] R 
			WHERE FileID = @FileID;

			SET @LastRowNr = @LastRowNr + 1;
			SET @LastColumnNr = @LastColumnNr + 1;
			--get only new columns which are not imported already
			INSERT INTO @NewColumns (ColumnNr, TraitID, ColumLabel, DataType, NewColumnNr)
			SELECT 
				ColumnNr,
				TraitID, 
				ColumLabel, 
				DataType,
				ROW_NUMBER() OVER(ORDER BY ColumnNr) + @LastColumnNr
			FROM @TVPColumns T1
			WHERE NOT EXISTS
			(
				SELECT ColumnID 
				FROM [Column] C 
				WHERE C.ColumLabel = T1.ColumLabel AND C.FileID = @FileID
			)
			ORDER BY T1.ColumnNr;


				--insert into new temp row table
				INSERT INTO @TempRow(MaterialKey)
				SELECT T1.MaterialKey FROM @TempTVP_Row T1
				WHERE NOT EXISTS
				(
					SELECT R1.MaterialKey FROM [Row] R1 
					WHERE R1.FileID = @FileID AND T1.MaterialKey = R1.MaterialKey
				)
				ORDER BY T1.RowNr;

				--now insert into row table if material is not availale 
				INSERT INTO [Row] ( [RowNr], [MaterialKey], [FileID], NrOfSamples)
				OUTPUT INSERTED.[RowID],INSERTED.[RowNr],INSERTED.MaterialKey INTO @RowData1(RowID,RowNr,MaterialKey)
				SELECT T.RowNr+ @LastRowNr,T.MaterialKey,@FileID, 1 FROM @TempRow T
				ORDER BY T.RowNr;

				--now insert new columns if available which are not already available on table
				INSERT INTO [Column] ([ColumnNr], [TraitID], [ColumLabel], [FileID], [DataType])
				--OUTPUT INSERTED.[ColumnID], INSERTED.[ColumnNr] INTO @ColumnData
				SELECT T1.[NewColumnNr], T.[TraitID], T1.[ColumLabel], @FileID, T1.[DataType] 
				FROM @NewColumns T1
				LEFT JOIN 
				(
					SELECT CT.TraitID,T.TraitName, T.ColumnLabel
					FROM Trait T 
					JOIN CropTrait CT ON CT.TraitID = T.TraitID
					WHERE CT.CropCode = @CropCode AND T.Property = 0
				)
				T ON T.ColumnLabel = T1.ColumLabel


				INSERT INTO @BridgeColumnTable(OldColNr,NewColNr)
				SELECT T.ColumnNr,C.ColumnNr FROM 
				[Column] C
				JOIN @TempTVP_Column T ON T.ColumLabel = C.ColumLabel
				WHERE C.FileID = @FileID

				INSERT INTO @ColumnData(ColumnID,ColumnNr)
				SELECT ColumnID, ColumnNr FROM [Column] 
				WHERE FileID = @FileID;

				--update this to match previous column with new one if column order changed or new columns inserted.
				UPDATE T1 SET 
					 T1.ColumnNr = T2.NewColNr
				FROM @TempTVP_Cell T1
				JOIN @BridgeColumnTable T2 ON T1.ColumnNr = T2.OldColNr;

				--update row number if new row added which are already present for that file or completely new row are available on  SP Parameter TVP_ROw
				INSERT INTO @BridgeRowTable(NewRowNr,OldRowNr)
				SELECT T1.RowNr,T2.RowNr FROM @RowData1 T1
				JOIN @TVPRow T2 ON T1.MaterialKey = T2.MaterialKey

				--DELETE T FROM @TempTVP_Cell T
				--WHERE NOT EXISTS
				--(
				--	SELECT T1.OldRowNr FROM @BridgeRowTable T1
				--	WHERE T1.OldRowNr = T.RowNr
				--)


				UPDATE T1 SET
					T1.RowNr = T2.NewRowNr
				FROM @TempTVP_Cell T1
				JOIN @BridgeRowTable T2 ON T1.RowNr = T2.OldRowNr;


				INSERT INTO [Cell] ( [RowID], [ColumnID], [Value])
				SELECT T2.[RowID], T3.[ColumnID], T1.[Value] 
				FROM @TempTVP_Cell T1
				JOIN @RowData1 T2 ON T2.RowNr = T1.RowNr
				JOIN @ColumnData T3 ON T3.ColumnNr = T1.ColumnNr
				WHERE ISNULL(T1.[Value],'')<>'';
								

				IF(@Source = 'Phenome') BEGIN
					MERGE INTO Material T 
					USING
					(
						SELECT R.MaterialKey,Max(L.RowID) as RowID
						FROM @TVPRow R
						LEFT JOIN @TVPList L ON R.GID = L.GID --AND R.EntryCode = L.EntryCode
						GROUP BY R.MaterialKey
					) S	ON S.MaterialKey = T.MaterialKey
					WHEN NOT MATCHED THEN 
						INSERT(MaterialType, MaterialKey, [Source], CropCode,Originrowid,RefExternal, BreedingStationCode)
						VALUES (@ImportLevel, S.MaterialKey, @Source, @CropCode,S.RowID,@ObjectID, @BreedingStationCode)
					WHEN MATCHED AND ISNULL(S.RowID,0) <> ISNULL(T.OriginrowID,0) THEN 
						UPDATE  SET T.OriginrowID = S.RowID,T.RefExternal = @ObjectID, BreedingStationCode= @BreedingStationCode;
					

				END
				ELSE BEGIN
					MERGE INTO Material T 
					USING
					(
						SELECT R.MaterialKey
						FROM [Row] R
						WHERE FileID = @FileID		
					) S	ON S.MaterialKey = T.MaterialKey
					WHEN NOT MATCHED THEN 
						INSERT(MaterialType, MaterialKey, [Source], CropCode)
						VALUES (@ImportLevel, S.MaterialKey, @Source, @CropCode);

				END

				IF(@TestTypeID = 8)
				BEGIN
					MERGE INTO TestMaterial T
					USING
					(
						SELECT M.MaterialID FROM Material M 
						JOIN [Row] R ON R.MaterialKey = M.Materialkey
						WHERE R.FileId = @FileID
					) S ON T.TestID = @TestID AND S.MaterialID = T.MaterialID
					WHEN NOT MATCHED THEN
						INSERT(TestID, MaterialID)
						VALUES(@TestID, S.MaterialID);
				
				END
			END
		COMMIT;

	END TRY
	BEGIN CATCH
		ROLLBACK;
		THROW;
	END CATCH
END
GO


