
/*
============Example===============
EXEC PR_AssignFixedPlants_Undo 1058,3807,'A01'
*/
ALTER PROCEDURE [dbo].[PR_AssignFixedPlants_Undo]
(
	@TestID INT,
	@MaterialID INT,
	@Position NVARCHAR(MAX)
) AS BEGIN

	SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @PlateIDFirst INT, @AssignedWellType INT, @EmptyWellType INT,@FixedWellType INT,@DeadWellType INT,@MaxRowNr INT;
		DECLARE @MaterialExceptFixedAndDead TVP_Material, @WellExceptFixedAndDead TVP_Material,@CurrentFixedWell TVP_Material, @MaterialWithWell TVP_TMDW;
		DECLARE @RemoveMaterialFromAllPlates BIT = 0;
		
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
		
		IF(ISNULL(@Position,'')='') BEGIN
			EXEC PR_ThrowError 'Fixed positon cannot be completed. Invalid Material.';
			RETURN;
		END
				



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



		IF NOT EXISTS(SELECT TOP 1 * FROM TestMaterialDeterminationWell TMDW
					JOIN Well W ON W.WellID = TMDW.WellID 
					JOIN Plate P ON P.PlateID = W.PlateID
					WHERE MaterialID = @MaterialID AND W.Position = @Position AND w.WellTypeID = @FixedWellType AND P.TestID = @TestID) BEGIN
			
				EXEC PR_ThrowError 'Invalid fixed position well. Please select well which is used for fixed position material.';
				RETURN;
		END

		BEGIN TRANSACTION;
			--this is checked if same material is used for fixed position for other well type also, 
			--if used then we have to delete all material from that fixed position,	otherwise we have to remove material from all plates except one which we used a first plate		
			IF EXISTS(SELECT * FROM TestMaterialDeterminationWell TMDW 
			JOIN Well W ON W.WellID = TMDW.WellID
			WHERE TMDW.MaterialID = @MaterialID AND W.WellTypeID = @FixedWellType AND W.Position <> @Position) BEGIN
				SET @RemoveMaterialFromAllPlates =1;				
			END
			
			--update current welltype postion from fixed welltype to assigned welltype postion.
			UPDATE W
				SET W.WellTypeID = @AssignedWellType
			FROM Well  W
			JOIN Plate P ON W.PlateID = P.PlateID
			WHERE TestID = @TestID AND W.Position = @Position;

			IF(ISNULL(@RemoveMaterialFromAllPlates ,0) = 0) BEGIN
				INSERT INTO @CurrentFixedWell(MaterialID)
					SELECT TMDW.WellID
					FROM TestMaterialDeterminationWell TMDW
					JOIN Well W ON W.WellID = TMDW.WellID
					JOIN Plate P ON P.PlateID = W.PlateID
					WHERE P.PlateID > @PlateIDFirst AND P.TestID = @TestID AND W.Position = @Position AND TMDW.MaterialID = @MaterialID
			END
			ELSE BEGIN
				INSERT INTO @CurrentFixedWell(MaterialID)
					SELECT TMDW.WellID
					FROM TestMaterialDeterminationWell TMDW
					JOIN Well W ON W.WellID = TMDW.WellID
					JOIN Plate P ON P.PlateID = W.PlateID
					WHERE P.TestID = @TestID AND W.Position = @Position AND TMDW.MaterialID = @MaterialID

			END
			 
			
			
	
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
