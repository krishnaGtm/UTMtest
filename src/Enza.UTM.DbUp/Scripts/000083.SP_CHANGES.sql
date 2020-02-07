
DROP PROCEDURE IF EXISTS [dbo].[PR_AssignFixedPlants_Undo]
GO


/*
============Example===============
EXEC PR_AssignFixedPlants_Undo 1058,3807
*/
CREATE PROCEDURE [dbo].[PR_AssignFixedPlants_Undo]
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


