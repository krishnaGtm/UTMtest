--EXEC PR_PLAN_GetCurrentPeriod
ALTER PROCEDURE [dbo].[PR_PLAN_GetCurrentPeriod]
(
	@DetailAlso BIT = 0
)
AS BEGIN
	SET NOCOUNT ON;
	DECLARE @PeriodID INT;
	DECLARE @today DATE = GETUTCDATE();
	SELECT 
		@PeriodID = [PeriodID]
	FROM [Period] 
	WHERE @today BETWEEN StartDate AND EndDate;

	IF(ISNULL(@PeriodID, 0) = 0) BEGIN
		EXEC PR_ThrowError N'Couldn''t find period information in database.';
		RETURN 0;
	END

	IF (@DetailAlso = 1) BEGIN
		SELECT 
			[PeriodID], [PeriodName], [StartDate], [EndDate], [Remark]
		FROM [Period] 
		WHERE @today BETWEEN StartDate AND EndDate;
	END
	RETURN @PeriodID;
END
GO