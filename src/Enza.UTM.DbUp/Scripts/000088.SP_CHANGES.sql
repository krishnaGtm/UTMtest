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

			DECLARE 
			@PlateID INT =0,
			@TotalPlatesRequired INT =0,
			@PlatesCreated INT =0,			
			@FixedWellCount INT =0,
			@PlateIDLast INT,
			@LastPlateName NVARCHAR(200) = '',
			@EmptyWellTypeID INT,
			@AssignedWellTypeID INT,
			@FixedWellTypeID INT,
			@TotalPlates INT =0,
			@DeadWellTypeID INT;

			--DECLARE @NewPlateCreated BIT = 0;
			DECLARE --@FixedOnlyMaterial TVP_TMDW,
			@FixedOnlyMaterialWithWell TVP_TMDW--,
			
			
			DECLARE @MaterialExceptFixed TVP_Material,
			@WellExceptFixed TVP_Material,			
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

			--this delete should be called in one condition when there is single plate and fixed position is assigned to position other than last filled position
			--eg: when plate is filled to position B12 and fixed position is assigned to position greater than B12 i.e (C02 to H12) then last material shifted upwards fixed position is applied to new well so original last position material is never deleted)
			--DELETE FROM TestMaterialDeterminationWell
			SELECT @TotalPlates = COUNT(PlateID)
			FROM Plate
			WHERE TestID = @TestID;

			IF(ISNULL(@TotalPlates,0) =1 ) BEGIN

				DELETE TMDW
				FROM TestMaterialDeterminationWell TMDW 
				JOIN Well W ON W.WellID = TMDW.WellID
				JOIN Plate P ON P.PlateID = W.PlateID
				WHERE TMDW.WellID NOT IN ( SELECT Wellid FROM @MaterialWithWell)
				AND W.WellTypeID != @FixedWellTypeID
				AND P.TestID = @TestID
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
			EXEC PR_ThrowError 'Fixed positon cannot be completed. Invalid Material.';
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
			ON T.WellID = S.WellID 			
			WHEN MATCHED AND T.MaterialID <> S.MaterialID THEN
			UPDATE SET T.MaterialID = S.MaterialID
			WHEN NOT MATCHED THEN
			INSERT (MaterialID,WellID)
			VALUES (S.MaterialID,S.WellID);


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

