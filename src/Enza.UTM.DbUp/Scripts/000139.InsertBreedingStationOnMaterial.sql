UPDATE M
SET M.BreedingStationCode = T.BreedingStationCode
FROM Material M 
JOIN [Row] R ON R.MaterialKey = M.MaterialKey
JOIN [File] F ON F.FileID = R.FileID
JOIN [Test] T ON T.FileID = F.FileID
