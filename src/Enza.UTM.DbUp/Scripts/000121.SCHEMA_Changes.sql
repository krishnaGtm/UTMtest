
ALTER TABLE [Material]
ADD RefExternal NVARCHAR(100)
GO

UPDATE M SET M.RefExternal = F.RefExternal
FROM [File] F 
JOIN [Row] R ON R.FileID = F.FileID
JOIN Material M ON M.MaterialKey = R.MaterialKey WHERE ISNULL(F.RefExternal,'')<> '' 