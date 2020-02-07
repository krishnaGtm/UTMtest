DELETE TMDW FROM TestMaterialDeterminationWell TMDW
JOIN Well W ON W.WellID = TMDW.WellID
JOIN Plate P on P.PlateID = W.PlateID
JOIN test T on T.TestID = P.TestID
WHERE T.RequestingSystem = 'Phenome'

DELETE TMD FROM TestMaterialDetermination TMD
JOIN test T on T.TestID = TMD.TestID
WHERE T.RequestingSystem = 'Phenome'

DELETE TR FROM TestResult TR 
JOIN Well W ON W.WellID = TR.WellID
JOIN Plate P on P.PlateID = W.PlateID
JOIN test T on T.TestID = P.TestID
WHERE T.RequestingSystem = 'Phenome'


DELETE W FROM Well W
JOIN Plate P on P.PlateID = W.PlateID
JOIN test T on T.TestID = P.TestID
WHERE T.RequestingSystem = 'Phenome'


DELETE P FROM Plate P 
JOIN test T on T.TestID = P.TestID
WHERE T.RequestingSystem = 'Phenome'

DELETE ST FROM SlotTest ST
JOIN Test T ON T.TestID = ST.TestID where RequestingSystem='Phenome'

DELETE FROM Test where RequestingSystem='Phenome'

DELETE FROM Material WHERE Source = 'Phenome'

DELETE C FROM Cell C 
JOIN Row R ON R.RowID = C.RowID
JOIN [File] F on F.FileID = R.FileID
WHERE F.FileTitle NOT LIKE '%.xlsx'

DELETE R FROM Row R 
JOIN [File] F on F.FileID = R.FileID
WHERE F.FileTitle NOT LIKE '%.xlsx'

DELETE C1 FROM [Column] C1
JOIN [File] F on F.FileID = C1.FileID
WHERE F.FileTitle NOT LIKE '%.xlsx'

DELETE F FROM [File] F
WHERE F.FileTitle NOT LIKE '%.xlsx'