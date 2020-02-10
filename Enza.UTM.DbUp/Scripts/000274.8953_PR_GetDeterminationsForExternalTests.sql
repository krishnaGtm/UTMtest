/*
Author					Date				Description
KRIAHNA GAUTAM			2019-Apr-25			Change of query after implementation of new table TestTypeDetermination for marker of testtype s2s.
Krishna Gautam			2019-Dec-09			Changes for external file import

=================Example===============
EXEC PR_GetDeterminationsForExternalTests 'LT', 1, 62

*/
ALTER PROCEDURE [dbo].[PR_GetDeterminationsForExternalTests]
(
	@CropCode NVARCHAR(10),
	@TestTypeID INT
) AS BEGIN
	SET NOCOUNT ON;
	SELECT 
		D.DeterminationID,
		DeterminationName = MAX(D.DeterminationName),
		DeterminationAlias = MAX(D.DeterminationAlias),
		ColumnLabel = MAX(D.DeterminationName)
	FROM Determination D	
	JOIN TestTypeDetermination TTD ON TTD.DeterminationID = D.DeterminationID
	JOIN RelationTraitDetermination RTD ON RTD.DeterminationID = D.DeterminationID	
	WHERE D.CropCode = @CropCode 
	AND TTD.TestTypeID = @TestTypeID
	GROUP BY D.DeterminationID;

END