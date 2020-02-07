DROP PROCEDURE IF EXISTS  MarkSentResult
GO

DROP PROCEDURE IF EXISTS  PR_MarkSentResult
GO

CREATE PROCEDURE PR_MarkSentResult
(
	@WellID NVARCHAR(MAX),
	@TestID INT
)
AS 
BEGIN
	UPDATE T  SET T. IsResultSent = 1
	FROM TestResult T
	JOIN String_Split(@WellID,',') T1 ON T.WellID =CAST(T1.[value] AS INT)

	IF NOT EXISTS(
		SELECT T.TestID FROM Test T 
		JOIN Plate P ON P.TestID = P.TestID
		JOIN Well W ON W.PlateID = P.PlateID
		JOIN TestResult TR ON TR.WellID = W.WellID
		WHERE T.TestID = @TestID AND ISNULL(TR.IsResultSent,0) = 0
	) BEGIN

		UPDATE Test SET StatusCode = 700
		WHERE TestID = @TestID
	END
END

GO

