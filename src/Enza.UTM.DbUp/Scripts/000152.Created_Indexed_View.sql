SET NUMERIC_ROUNDABORT OFF;  
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT,  
    QUOTED_IDENTIFIER, ANSI_NULLS ON;  
GO 

IF OBJECT_ID ('dbo.VW_IX_Cell_Material', 'view') IS NOT NULL  
DROP VIEW dbo.VW_IX_Cell_Material;  
GO 

CREATE VIEW VW_IX_Cell_Material
WITH SCHEMABINDING
AS
	SELECT 
		R.FileID, 
		R.[RowID],
		R.MaterialKey,
		R.NrOfSamples,
		R.RowNr,
		C.ColumnID,
		C1.[Value]
	FROM [dbo].[Row] R  
	JOIN [dbo].[Cell] C1 ON C1.RowID = R.RowID
	JOIN [dbo].[Column] C ON C.ColumnID = C1.ColumnID AND  C.FileID = R.FileID     

GO