DROP PROCEDURE IF EXISTS PR_S2S_ManageMarkers
GO

CREATE PROCEDURE PR_S2S_ManageMarkers
(
    @TestID	 INT,
    @DataAsJson NVARCHAR(MAX)
) AS BEGIN
    SET NOCOUNT ON;

    MERGE INTO S2SDonorMarkerScore T 
    USING 
    (
	   SELECT 
		  DeterminationID,
		  MaterialID
	   FROM OPENJSON(@DataAsJson) WITH
	   (
		  DeterminationID INT,
		  MaterialID	    INT
	   )			
    ) S
    ON T.MaterialID = S.MaterialID  AND T.DeterminationID = S.DeterminationID AND T.TestID = @TestID
    WHEN NOT MATCHED THEN 
	   INSERT(TestID, MaterialID, DeterminationID) VALUES(@TestID, S.MaterialID, S.DeterminationID);
END
GO