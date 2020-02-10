ALTER PROCEDURE [dbo].[PR_S2S_UpdateRelationDonorStatus]
(
    @ProposedName NVARCHAR(MAX),
    @StatusCode INT
) AS BEGIN
    SET NOCOUNT ON;

    UPDATE RD SET
	   StatusCode = @StatusCode
		FROM RelationDonorDH0 RD 
		JOIN string_split(@ProposedName,',') T
		ON T.[value] = RD.ProposedName
END