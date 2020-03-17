/*
	Author					Date			Description
-------------------------------------------------------------------
	Krishna Gautam							SP Created
	Krishna Gautam			2020-03-12		#11253: Allow to delete slot if user is super user (i.e having role managemasterdatautm)
-------------------------------------------------------------------
*/
ALTER PROCEDURE [dbo].[PR_PLAN_Remove_Slot]
(
	@SlotID INT,
	@User NVARCHAR(MAX),
	@Crops NVARCHAR(MAX),
	@IsSuperUser BIT
)
AS BEGIN
	DECLARE @CreatedBy NVARCHAR(MAX),@CropCode NVARCHAR(100);
	IF NOT EXISTS (SELECT SlotID FROM Slot WHERE SlotID = @SlotID) 
	BEGIN	
		EXEC PR_ThrowError 'Invalid slot.';
		RETURN;
	END
	SELECT @CreatedBy = RequestUser FROM Slot WHERE SlotID = @SlotID;

	
	IF(ISNULL(@IsSuperUser,0) = 0 AND ISNULL(@User,'') <> ISNULL(@CreatedBy,'')) 
	BEGIN
		EXEC PR_ThrowError 'You are not allowed to remove this slot.';
		RETURN;
	END

	SELECT @CropCode = CropCode FROM Slot WHERE SlotID = @SlotID;
	IF(ISNULL(@CropCode,'') = '')
	BEGIN
		EXEC PR_ThrowError 'Invalid crop code of created slot.';
		RETURN;
	END
	IF NOT EXISTS (SELECT * FROM Slot S JOIN string_split(@Crops,',') ON S.CropCode = [value] WHERE S.SlotID = @SlotID)
	BEGIN
		DECLARE @MSG NVARCHAR(MAX) = 'You do not have permission to delete slot created for Crop ' + COALESCE(@CropCode,'');
		EXEC PR_ThrowError @MSG;
		RETURN;		
	END
	
	IF EXISTS(SELECT SlotID FROM SlotTest WHERE SlotID = @SlotID) 
	BEGIN
		EXEC PR_ThrowError 'Slot is already assigned to some tests. Cannot remove this slot.';
		RETURN;
	END

	DELETE RC FROM ReservedCapacity RC 
	JOIN Slot S ON S.SlotID = RC.SlotID
	WHERE S.SlotID = @SlotID;

	DELETE FROM Slot WHERE SlotID = @SlotID;

	
END