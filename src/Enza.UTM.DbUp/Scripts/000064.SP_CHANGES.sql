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
