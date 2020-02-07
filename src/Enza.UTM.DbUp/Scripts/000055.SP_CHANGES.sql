DROP PROCEDURE IF EXISTS [dbo].[PR_GET_Traits_All]
GO


DROP PROCEDURE IF EXISTS [dbo].[PR_SaveTraitDeterminationResult]
GO

DROP TYPE IF EXISTS [dbo].[TVP_TraitDeterminationResult]
GO

INSERT INTO [Status](StatusID,StatusTable,StatusCode,StatusName,StatusDescription)
SELECT ISNULL(MAX(StatusID),0) +1, 'RelationTraitDetermination', 100,'ACT','Active' FROM [Status];
GO


INSERT INTO [Status](StatusID,StatusTable,StatusCode,StatusName,StatusDescription)
SELECT ISNULL(MAX(StatusID),0) +1, 'RelationTraitDetermination', 200,'DEl','Deleted' FROM [Status];
GO


