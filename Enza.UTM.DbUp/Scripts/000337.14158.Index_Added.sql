DROP INDEX IF EXISTS IX_Material_Include_Well ON dbo.TestMaterialDeterminationWell 
GO

CREATE NONCLUSTERED INDEX IX_Material_Include_Well ON dbo.TestMaterialDeterminationWell 
(
	[MaterialID] DESC
) 
INCLUDE ([WellID])