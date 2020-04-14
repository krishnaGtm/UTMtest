DROP PROCEDURE IF EXISTS PR_PLAN_GetApprovedSlots
GO

--EXEC PR_PLAN_GetApprovedSlots 'JAVRA\dsuvedi', '57'
CREATE PROCEDURE [dbo].[PR_PLAN_GetApprovedSlots]
(
    @UserName	 NVARCHAR(100) = NULL,
    @SlotName	 NVARCHAR(200) = NULL
) AS BEGIN
    SET NOCOUNT ON;

    SELECT TOP 200
	   S.SlotID,
	   S.SlotName,
	   S.CropCode,
	   S.PlannedDate,
	   S.ExpectedDate,
	   S.MaterialTypeID,
	   S.MaterialStateID,
	   S.Isolated
    FROM Slot S
    WHERE S.StatusCode = 200
    AND (ISNULL(@UserName, '') = '' OR S.RequestUser = @UserName)
    AND (ISNULL(@SlotName, '') = '' OR S.SlotName LIKE CONCAT('%', @SlotName, '%'))
    ORDER BY S.PlannedDate DESC;
END
GO