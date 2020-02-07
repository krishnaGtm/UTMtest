
ALTER PROCEDURE [dbo].[PR_MarkSentResult]
(
	@WellID NVARCHAR(MAX),
	@TestID INT
)
AS 
BEGIN

	UPDATE T  SET T. IsResultSent = 1
	FROM TestResult T
	JOIN String_Split(@WellID,',') T1 ON T.WellID =CAST(T1.[value] AS INT)

	IF EXISTS(
		SELECT T.TestID FROM Test T 
		JOIN Plate P ON P.TestID = T.TestID
		JOIN Well W ON W.PlateID = P.PlateID
		JOIN TestResult TR ON TR.WellID = W.WellID
		WHERE T.TestID = @TestID AND ISNULL(TR.IsResultSent,0) = 0 AND ISNULL(TR.ObsValueChar,'') <> '-'
		
	) BEGIN

	--DO NOTHING
		PRINT 'Nothing to do if unsent result present';
	END
	ELSE BEGIN
	UPDATE Test SET StatusCode = 700
		WHERE TestID = @TestID
	END
END