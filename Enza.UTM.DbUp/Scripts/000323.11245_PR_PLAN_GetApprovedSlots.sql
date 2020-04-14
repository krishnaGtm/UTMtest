DROP PROCEDURE IF EXISTS PR_PLAN_GetApprovedSlots
GO

--EXEC PR_PLAN_GetApprovedSlots '57'
CREATE PROCEDURE PR_PLAN_GetApprovedSlots
(
    @SlotName	 NVARCHAR(200) = NULL
) AS BEGIN
    SET NOCOUNT ON;

    SELECT TOP 200
	   S.SlotID,
	   S.SlotName,
	   S.CropCode,
	   T.TestTypeID,
	   S.PlannedDate,
	   S.ExpectedDate,
	   S.MaterialTypeID,
	   S.MaterialStateID,
	   T.ContainerTypeID,
	   S.Isolated,
	   T.ImportLevel
    FROM Slot S
    JOIN SlotTest ST ON ST.SlotID = S.SlotID
    JOIN Test T ON T.TestID = ST.TestID
    WHERE S.StatusCode = 200
    AND (ISNULL(@SlotName, '') = '' OR S.SlotName LIKE CONCAT('%', @SlotName, '%'))
    ORDER BY S.PlannedDate DESC;
END
GO