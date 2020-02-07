
DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_Move_Capacity_Slot]
GO

CREATE PROCEDURE [dbo].[PR_PLAN_Move_Capacity_Slot]
(
	@SlotID INT,
	@PlannedDate DATETIME,
	@ExpectedDate DATETIME
)
AS BEGIN

	IF NOT EXISTS (SELECT SlotID FROM Slot WHERE SlotID = @SlotID) BEGIN	
		EXEC PR_ThrowError 'Invalid slot';
		RETURN;
	END
	IF EXISTS(SELECT SlotID FROM SlotTest WHERE SlotID = @SlotID) BEGIN
		EXEC PR_ThrowError 'Slot is already assigned to some tests. Cannot move slot to new planned date.';
		RETURN;
	END

	IF( @ExpectedDate < @PlannedDate) BEGIN
		EXEC PR_ThrowError 'Expected date should not be earlier than planned date.';
		RETURN;
	END

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
		EXEC PR_ThrowError 'Reservation quota is already occupied. Cannot move slot new planned date.';
		RETURN;
	END
	ELSE BEGIN
		UPDATE Slot 
				SET PlannedDate = CAST(@PlannedDate AS DATE), 
				ExpectedDate = CAST(@ExpectedDate AS DATE),
				PeriodID = @PeriodID,
				StatusCode = 200
			WHERE SlotID = @SlotID;	
	END

END
GO



DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_Remove_Slot]
GO

CREATE PROCEDURE [dbo].[PR_PLAN_Remove_Slot]
(
	@SlotID INT,
	@User NVARCHAR(MAX)
)
AS BEGIN
	DECLARE @CreatedBy NVARCHAR(MAX)
	IF NOT EXISTS (SELECT SlotID FROM Slot WHERE SlotID = @SlotID) BEGIN	
		EXEC PR_ThrowError 'Invalid slot.';
		RETURN;
	END
	SELECT @CreatedBy = RequestUser FROM Slot WHERE SlotID = @SlotID;

	IF(ISNULL(@User,'') <> ISNULL(@CreatedBy,'')) BEGIN
		EXEC PR_ThrowError 'You are not allowed to remove this slot.';
		RETURN;
	END
	
	IF EXISTS(SELECT SlotID FROM SlotTest WHERE SlotID = @SlotID) BEGIN
		EXEC PR_ThrowError 'Slot is already assigned to some tests. Cannot remove this slot.';
		RETURN;
	END

	DELETE RC FROM ReservedCapacity RC 
	JOIN Slot S ON S.SlotID = RC.SlotID
	WHERE S.SlotID = @SlotID;

	DELETE FROM Slot WHERE SlotID = @SlotID;

	
END
GO





