/*
    DECLARE @MaterialsAsJson NVARCHAR(MAX) = N'[{"MaterialID":3748,"DeterminationID":1,"Selected":true},{"MaterialID":3749,"DeterminationID":1,"Selected":true}]';
    EXEC PR_CNT_ManageMarkers 4562, @MaterialsAsJson;
*/
ALTER PROCEDURE [dbo].[PR_CNT_ManageMarkers]
(
    @TestID		    INT,
    @MaterialsAsJson NVARCHAR(MAX)
) AS BEGIN
    SET NOCOUNT ON;

    MERGE INTO TestMaterialDetermination T
    USING 
    ( 
	   SELECT MaterialID, DeterminationID, Selected
	   FROM OPENJSON(@MaterialsAsJson) WITH
	   (
		  MaterialID	   INT,
		  DeterminationID INT,
		  Selected	   BIT
	   )		
    ) S
    ON T.MaterialID = S.MaterialID AND T.DeterminationID = S.DeterminationID AND T.TestID = @TestID
    WHEN NOT MATCHED AND ISNULL(S.Selected, 0) = 1 THEN 
	   INSERT(TestID, MaterialID, DeterminationID) VALUES(@TestID, S.MaterialID, S.DeterminationID)
    WHEN MATCHED AND ISNULL(S.Selected, 0) = 0 THEN 
	    DELETE;    
END
GO