ALTER TABLE S2SDonorMarkerScore
ADD [Source] NVARCHAR(20);
GO

DROP PROCEDURE IF EXISTS PR_S2S_StoreDH0Details
GO
/*
    DECLARE @DataAsJson NVARCHAR(MAX) = N'
    [
	   {"ProposedName":"P1","Markers":[{"MarkerNumber":695,"Score":"0101"},{"MarkerNumber":740,"Score":"0201"}]},
	   {"ProposedName":"P2","Markers":[{"MarkerNumber":88221,"Score":"0102"},{"MarkerNumber":88222,"Score":"0202"}]}
    ]';
    EXEC PR_S2S_StoreDH0Details 4463, 10295, @DataAsJson;
*/
CREATE PROCEDURE PR_S2S_StoreDH0Details
(
    @TestID		INT,
    @MaterialID	INT,
    @DataAsJson NVARCHAR(MAX)
) AS BEGIN
    SET NOCOUNT ON;
    --Validation
    IF NOT EXISTS(SELECT TestID FROM Test WHERE TestID = @TestID) BEGIN
	   EXEC PR_ThrowError N'Requested TestID is not valid.';
	   RETURN;
    END
    IF NOT EXISTS(SELECT MaterialID FROM Material WHERE MaterialID = @MaterialID) BEGIN
	   EXEC PR_ThrowError N'Requested MaterialID is not valid.';
	   RETURN;
    END

    --Update RelationDonorDH0 table first
    MERGE RelationDonorDH0 T
    USING
    (
	   SELECT 
		  T1.ProposedName,
		  F.CropCode
	   FROM
	   OPENJSON(@DataAsJson) WITH
	   (
		  ProposedName    NVARCHAR(100)		  
	   ) T1
	   JOIN Test T ON T.TestID = @TestID
	   JOIN [File] F ON F.FileID = T.FileID
    ) S ON S.ProposedName = T.ProposedName
    WHEN NOT MATCHED THEN
	   INSERT(MaterialID, CropCode, ProposedName, StatusCode, TestID)
	   VALUES(@MaterialID, S.CropCode, S.ProposedName, 100, @TestID);

    --Validations
    DECLARE @InvalidMarkers NVARCHAR(MAX);
    DECLARE @Markers TABLE(DeterminationID INT, Score NVARCHAR(100));
    INSERT INTO @Markers(DeterminationID, Score)
    SELECT DISTINCT
	   T2.DeterminationID,
	   T2.Score	  
    FROM
    OPENJSON(@DataAsJson) WITH
    (
	   ProposedName NVARCHAR(100),
	   Markers NVARCHAR(MAX) AS JSON
    ) T1
    CROSS APPLY OPENJSON(T1.Markers) WITH
    (
	   DeterminationID INT '$.MarkerNumber',
	   Score			NVARCHAR(100)
    ) T2
    
    SELECT
	   @InvalidMarkers = COALESCE(@InvalidMarkers + ',', '') + CAST(M.DeterminationID AS NVARCHAR(20))
    FROM @Markers M
    LEFT JOIN Determination D ON D.DeterminationID = M.DeterminationID
    WHERE D.DeterminationID IS NULL;  
    
    IF(ISNULL(@InvalidMarkers, '') <> '') BEGIN
	   SET @InvalidMarkers = N'Following Marker numbers are not valid: ' + @InvalidMarkers;
	   EXEC PR_ThrowError @InvalidMarkers;
	   RETURN;
    END

    --Update S2SDonorMarkerScore table
    MERGE S2SDonorMarkerScore T
    USING
    (
	   SELECT
		  M.DeterminationID, 
		  M.Score,
		  TestID = @TestID,
		  MaterialID = @MaterialID
	   FROM @Markers M  
    ) S ON S.TestID = T.TestID AND S.MaterialID = T.MaterialID AND S.DeterminationID = T.DeterminationID AND S.Score = T.Score AND T.[Source] = 'S2S'
    WHEN NOT MATCHED THEN
	   INSERT(TestID, MaterialID, DeterminationID, Score, [Source])
	   VALUES(S.TestID, S.MaterialID, S.DeterminationID, S.Score, 'S2S');
END
GO

--EXEC PR_S2S_GetMarkerTestData 4378, 34277;
ALTER PROCEDURE [dbo].[PR_S2S_GetMarkerTestData]
(
	@TestID				INT,
	@MaterialID			INT
) AS BEGIN
	SET NOCOUNT ON;

	SELECT
		DI.DonorNumber,
		MarkerNumber = DMS.DeterminationID,
		MarkerName = D.DeterminationName,
		DonorMarkerUse = 'Sel',
		HaploidMarkerUse = 'Sel',
		AutoSelectScore = DMS.Score
	FROM S2SCapacitySlot CS
	JOIN Test T ON T.CapacitySlotID = CS.CapacitySlotID
	JOIN [File] F ON F.FileID = T.FileID
	JOIN [Row] R ON R.FileID = F.FileID
	JOIN Material M ON M.MaterialKey = R.MaterialKey
	JOIN S2SDonorInfo DI ON DI.RowID = R.RowID
	JOIN S2SDonorMarkerScore DMS ON DMS.TestID = T.TestID AND DMS.MaterialID = M.MaterialID
	JOIN Determination D ON D.DeterminationID = DMS.DeterminationID
	WHERE T.StatusCode >= 700
	AND T.TestID = @TestID
	AND M.MaterialID = @MaterialID
	AND ISNULL(DMS.Score,'') <> ''
	AND DMS.[Source] <> 'S2S';
END
GO

