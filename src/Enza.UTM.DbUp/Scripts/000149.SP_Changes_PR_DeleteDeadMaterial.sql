
/*
===========EXAMPLE=============

EXEC PR_Delete_EmptyORDeadMaterial 56

*/


ALTER PROCEDURE [dbo].[PR_DeleteDeadMaterial]
(
	@TestID INT
)
AS 
BEGIN
	DECLARE @ReturnValue INT,@Material TVP_Material,@Well TVP_Material, @AssignedWellType INT, @EmptyWellType INT,@FixedWellType INT,@DeadWellType INT,@MaterialWithWell TVP_TMDW, @MaxRowNr INT,@WellsPerPlate INT;--, @DeadMaterialCount INT;

	IF(ISNULL(@TestID,0)=0) BEGIN
		EXEC PR_ThrowError 'Test doesn''t exist.';
		RETURN;
	END

	DECLARE @FirstPlate INT;
	DECLARE @PlateToDelete TABLE (PlateID INT);
	SELECT TOP 1 @FirstPlate = PlateID FROM Plate WHERE TestID = @TestID;



	SELECT @WellsPerPlate = COUNT(WellID)
	FROM Well WHERE PlateID = @FirstPlate

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

			SELECT @FixedWellType = WellTypeID
			FROM WellType WHERE WellTypeName = 'F';
			SELECT @DeadWellType = WellTypeID 
			FROM WellType WHERE WellTypeName = 'D';
			
			--Get all material of well without fixed, empty and dead.
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
						WHERE P.TestID = @TestID AND W.WellTypeID = @AssignedWellType 
					) T
				) T1
				ORDER BY PlateID, Position2, Position1

			--Update all dead material well position to assigned well position
			UPDATE W
			SET W.WellTypeID = @AssignedWellType
			FROM Well W
			JOIN Plate P ON P.PlateID = W.PlateID			
			WHERE P.TestID = @TestID AND W.WellTypeID = @DeadWellType

			--Get all well postion without fixed, empty and dead.
			INSERT INTO @Well(MaterialID)
			SELECT T.WellID
			FROM 
			(
				SELECT W.*, CAST(RIGHT(Position,LEN(Position)-1) AS INT) AS Position1
				,LEFT(Position,1) as Position2
				FROM Well W
				JOIN Plate P ON P.PlateID = W.PlateID
				WHERE P.TestID = @TestID AND W.WellTypeID = @AssignedWellType 			
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

			--delete unused well and plates if there is empty plage after removing dead materials
			IF EXISTS(SELECT StatusCode FROM Test WHERE StatusCode < 200 AND TestID = @TestID) BEGIN
			
				INSERT INTO @PlateToDelete(PlateID)
				SELECT PlateID FROM
				(
					SELECT T.PlateID,SUM([Count]) AS [Count] FROM 
					(
						SELECT P.PlateID,WellTypeID,Count(WelltypeID) AS [Count] FROM Well W
									JOIN Plate P ON P.PlateID = W.PlateID
									WHERE P.TestID = @TestID
									GROUP BY P.PlateID,W.WellTypeID
					)T WHERE T.WellTypeID IN (@EmptyWellType,@FixedWellType)
					GROUP BY PlateID
				)T1 WHERE [Count] = @WellsPerPlate

				--delete from TestMaterialDeterminationWell if material present
				DELETE TMDW FROM TestMaterialDeterminationWell TMDW
				JOIN Well W ON W.WellID = TMDW.WellID
				JOIN @PlateToDelete P on P.PlateID = W.PlateID;

				--delete from well if all well are empty or fixed position
				DELETE W FROM Well W
				JOIN @PlateToDelete P ON P.PlateID = W.PlateID
				
				--delete plate no well is found
				DELETE P FROM Plate P 
				JOIN @PlateToDelete PD ON Pd.PlateID = P.PlateID;
			END
			

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
