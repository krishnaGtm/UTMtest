DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_GetApprovedSlots]
GO

/*
Author					Date			Remarks
-------------------------------------------------------------------------------
Dibya Suvedi			2020-Apr-02		#11245: Sp Created
Krishna Gautam			2020-Apr-03		#11245: Change request for showing only crops that user have access and date greater than today

==================================Example======================================
--EXEC PR_PLAN_GetApprovedSlots 'JAVRA\dsuvedi', '57','TO'

*/


CREATE PROCEDURE [dbo].[PR_PLAN_GetApprovedSlots]
(
    @UserName	 NVARCHAR(100) = NULL,
    @SlotName	 NVARCHAR(200) = NULL,
	@Crops		 NVARCHAR(MAX)
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
	   S.Isolated,
	   S.BreedingStationCode
    FROM Slot S
	JOIN string_split(@Crops,',') T ON T.[value] = S.CropCode
    WHERE S.StatusCode = 200
    AND (ISNULL(@UserName, '') = '' OR S.RequestUser = @UserName)
    AND (ISNULL(@SlotName, '') = '' OR S.SlotName LIKE CONCAT('%', @SlotName, '%'))
	AND S.PlannedDate > GETUTCDATE()
    ORDER BY S.PlannedDate DESC;
END
GO


