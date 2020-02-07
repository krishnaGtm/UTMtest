
ALTER PROCEDURE [dbo].[PR_UndoDead]
(
	@TestID INT,
	@WellIDS NVARCHAR(MAX)
)
AS BEGIN
	DECLARE @AssignedWellType INT, @DeadWellType INT;

	SELECT @AssignedWellType = WellTypeID FROM WellType WHERE WellTypeName = 'A';

	SELECT @DeadWellType = WellTypeID FROM WellType WHERE WellTypeName = 'D';

	IF EXISTS(
		SELECT W.WellID FROM Well W 
		JOIN string_split(@WellIDS,',') V ON V.[value] = W.WellID
		WHERE WellTypeID != @DeadWellType) BEGIN
		EXEC PR_ThrowError 'Cannot complete operation. Please select dead well position only.';
		RETURN;
	END

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
