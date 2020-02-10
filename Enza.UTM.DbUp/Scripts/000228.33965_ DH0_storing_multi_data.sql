/*
    DECLARE @DataAsJson NVARCHAR(MAX) = N'
    [
	    {
		    "TestID": 4463,
		    "MaterialID": 10295,
		    "DH0List": [
			    {
				    "ProposedName": "P1",
				    "Markers": [
					    {
						    "MarkerNumber": 695,
						    "Score": "0101"
					    },
					    {
						    "MarkerNumber": 740,
						    "Score": "0201"
					    }
				    ]
			    },
			    {
				    "ProposedName": "P2",
				    "Markers": [
					    {
						    "MarkerNumber": 88221,
						    "Score": "0102"
					    },
					    {
						    "MarkerNumber": 88222,
						    "Score": "0202"
					    }
				    ]
			    }
		    ]
	    }
    ]';
    EXEC PR_S2S_StoreDH0Details @DataAsJson;
*/
ALTER PROCEDURE [dbo].[PR_S2S_StoreDH0Details]
(
    @DataAsJson NVARCHAR(MAX)
) AS BEGIN
    SET NOCOUNT ON;

    DECLARE @IDs NVARCHAR(MAX);
    DECLARE @Tbl TABLE(TestID INT, MaterialID INT, ProposedName NVARCHAR(100), DeterminationID INT, Score NVARCHAR(20));
    
    INSERT INTO @Tbl(TestID, MaterialID, ProposedName, DeterminationID, Score)
    SELECT T1.TestID, T1.MaterialID, T2.ProposedName, T3.DeterminationID, T3.Score
    FROM OPENJSON(@DataAsJson) WITH
    (
	   TestID		INT,
	   MaterialID	INT,
	   DH0List	NVARCHAR(MAX) AS JSON	  
    ) T1
    CROSS APPLY OPENJSON(T1.DH0List) WITH
    (
	   ProposedName    NVARCHAR(100),
	   Markers	    NVARCHAR(MAX) AS JSON
    ) T2
    CROSS APPLY OPENJSON(T2.Markers) WITH
    (
	   DeterminationID	   INT '$.MarkerNumber',
	   Score			   NVARCHAR(100)
    ) T3;

    --TestID validation
    SELECT DISTINCT
	   @IDs = COALESCE(@IDs + ',', '') + CAST(T.TestID AS NVARCHAR(20))
    FROM @Tbl T
    LEFT JOIN Test T2 ON T2.TestID = T.TestID
    WHERE T2.TestID IS NULL;

    IF(ISNULL(@IDs, '') <> '') BEGIN
	   SET @IDs = N'Invalid Test ID(s): ' + @IDs;
	   EXEC PR_ThrowError @IDs;
	   RETURN;
    END

    --MaterialID validation
    SET @IDs = NULL;
    SELECT DISTINCT
	   @IDs = COALESCE(@IDs + ',', '') + CAST(M.MaterialID AS NVARCHAR(20))
    FROM @Tbl M
    LEFT JOIN Material T ON T.MaterialID = M.MaterialID
    WHERE T.MaterialID IS NULL;;
    
    IF(ISNULL(@IDs, '') <> '') BEGIN
	   SET @IDs = N'Invalid Material ID(s): ' + @IDs;
	   EXEC PR_ThrowError @IDs;
	   RETURN;
    END

    --MarkerNumber validation
    SET @IDs = NULL;
    SELECT
	   @IDs = COALESCE(@IDs + ',', '') + CAST(M.DeterminationID AS NVARCHAR(20))
    FROM @Tbl M
    LEFT JOIN Determination D ON D.DeterminationID = M.DeterminationID
    WHERE D.DeterminationID IS NULL;  
    
    IF(ISNULL(@IDs, '') <> '') BEGIN
	   SET @IDs = N'Invalid Marker Number(s): ' + @IDs;
	   EXEC PR_ThrowError @IDs;
	   RETURN;
    END
    
    --Update RelationDonorDH0 table first
    MERGE RelationDonorDH0 T
    USING
    (
	   SELECT DISTINCT
		  T1.TestID, 
		  T1.MaterialID,
		  T1.ProposedName,
		  F.CropCode
	   FROM @Tbl T1
	   JOIN Test T ON T.TestID = T1.TestID
	   JOIN [File] F ON F.FileID = T.FileID
    ) S ON S.ProposedName = T.ProposedName
    WHEN NOT MATCHED THEN
	   INSERT(MaterialID, CropCode, ProposedName, StatusCode, TestID)
	   VALUES(S.MaterialID, S.CropCode, S.ProposedName, 100, S.TestID);

    --Update S2SDonorMarkerScore table
    MERGE S2SDonorMarkerScore T
    USING 
    (
	   SELECT DISTINCT
		  M.DeterminationID, 
		  M.Score,
		  M.TestID,
		  M.MaterialID
	   FROM @Tbl M  
    ) S ON S.TestID = T.TestID AND S.MaterialID = T.MaterialID AND S.DeterminationID = T.DeterminationID AND S.Score = T.Score AND T.[Source] = 'S2S'
    WHEN NOT MATCHED THEN
	   INSERT(TestID, MaterialID, DeterminationID, Score, [Source])
	   VALUES(S.TestID, S.MaterialID, S.DeterminationID, S.Score, 'S2S');
END
GO