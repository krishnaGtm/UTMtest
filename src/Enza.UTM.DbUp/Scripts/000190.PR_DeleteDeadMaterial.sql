/*
===========EXAMPLE=============

EXEC PR_DeleteDeadMaterial 56

*/


ALTER PROCEDURE [dbo].[PR_DeleteDeadMaterial]
(
	@TestID INT
)
AS 
BEGIN
	DECLARE @ReturnValue INT,@Material TVP_Material,@DeadMaterial TVP_Material,@Well TVP_Material, @AssignedWellType INT, @EmptyWellType INT,@FixedWellType INT,@DeadWellType INT,@MaterialWithWell TVP_TMDW, @MaxRowNr INT,@WellsPerPlate INT,@DeterminationRequired BIT;--, @DeadMaterialCount INT;

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

	SELECT @DeterminationRequired = TT.DeterminationRequired FROM Test T 
	JOIN TestType TT ON TT.TestTypeID = T.TestTypeID
	WHERE T.TestID = @TestID

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

			--insert dead material temp table
			INSERT INTO @DeadMaterial(MaterialID)
			SELECT TMDW.MaterialID FROM Plate P
			JOIN Well W ON W.PlateID = P.PlateID
			JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID
			WHERE P.TestID = @TestID AND W.WellTypeID= @DeadWellType;


			
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

			--remove from Testmaterialdetermination or uncheck selected based on testtype.
			IF(ISNULL(@DeterminationRequired,0)=1) 
			BEGIN				
				--remove material for deleted material if same material again present on platefilling with welltype not equals to dead
				DELETE DM FROM @DeadMaterial DM
				JOIN TestMaterialDeterminationWell TMDW ON TMDW.MaterialID = DM.MaterialID
				JOIN Well W ON W.WellID = TMDW.WellID
				JOIN Plate P ON P.PlateID= W.PlateID
				WHERE P.TestID = @TestID

				--now remove from TMDW
				DELETE TMD FROM TestMaterialDetermination TMD
				JOIn @DeadMaterial DM ON DM.MaterialID = TMD.MaterialID
				WHERE TMD.TestID = @TestID;
			END
			ELSE
			BEGIN
				
				--remove material for deleted material if same material again present on platefilling with welltype not equals to dead
				DELETE DM FROM @DeadMaterial DM
				JOIN TestMaterialDeterminationWell TMDW ON TMDW.MaterialID = DM.MaterialID
				JOIN Well W ON W.WellID = TMDW.WellID
				JOIN Plate P ON P.PlateID= W.PlateID
				WHERE P.TestID = @TestID

				--update selected to false so that it will re not appear on platefilling again
				UPDATE R SET R.Selected = 0 FROM Test T 
				JOIN [File] F ON F.FileID = T.FileID
				JOIN [Row] R ON R.FileID = F.FileID
				JOIN Material M ON M.MaterialKey = R.MaterialKey
				JOIN @DeadMaterial DM ON DM.MaterialID = M.MaterialID
				WHERE T.TestID = @TestID
			END


			IF EXISTS(SELECT StatusCode FROM Test WHERE StatusCode = 300 AND TestID = @TestID) BEGIN
						EXEC PR_Update_TestStatus @TestID, 350;
			END

		COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK;
		THROW;
	END CATCH
	
END
