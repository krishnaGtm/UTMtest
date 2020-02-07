DELETE TR
FROM TestResult TR
JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = TR.WellID
JOIN Well W ON W.WellID = TMDW.WellID
Join Plate P ON P.PlateID = W.PlateID
JOIN Test T ON T.TestID = P.TestID
JOIN TestType TT ON TT.TestTypeID = T.TestTypeID
WHERE TT.TestTypeCode = 'CH'

DELETE TR
FROM TestResult TR
JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = TR.WellID
JOIN Well W ON W.WellID = TMDW.WellID
Join Plate P ON P.PlateID = W.PlateID
JOIN Test T ON T.TestID = P.TestID
JOIN TestType TT ON TT.TestTypeID = T.TestTypeID
WHERE TT.TestTypeCode = 'CH'

DELETE TMDW
FROM TestMaterialDeterminationWell TMDW
JOIN Well W ON W.WellID = TMDW.WellID
Join Plate P ON P.PlateID = W.PlateID
JOIN Test T ON T.TestID = P.TestID
JOIN TestType TT ON TT.TestTypeID = T.TestTypeID
WHERE TT.TestTypeCode = 'CH'

DELETE W
FROM Well W
Join Plate P ON P.PlateID = W.PlateID
JOIN Test T ON T.TestID = P.TestID
JOIN TestType TT ON TT.TestTypeID = T.TestTypeID
WHERE TT.TestTypeCode = 'CH'

DELETE P
FROM  Plate P
JOIN Test T ON T.TestID = P.TestID
JOIN TestType TT ON TT.TestTypeID = T.TestTypeID
WHERE TT.TestTypeCode = 'CH'

DELETE TMD
FROM TestMaterialDetermination TMD
JOIN Test T ON T.TestID = TMD.TestID
JOIN TestType TT ON TT.TestTypeID = T.TestTypeID
WHERE TT.TestTypeCode = 'CH'

DELETE ST
FROM SlotTest ST
JOIN Test T ON T.TestID = ST.TestID
JOIN TestType TT ON TT.TestTypeID = T.TestTypeID
WHERE TT.TestTypeCode = 'CH'

DELETE T
FROM Test T
JOIN TestType TT ON TT.TestTypeID = T.TestTypeID
WHERE TT.TestTypeCode = 'CH'

DELETE WTP
FROM WellTypePosition WTP
JOIN TestType TT ON TT.TestTypeID = WTP.TestTypeID
WHERE TT.TestTypeCode = 'CH'

DELETE TP
FROM TestProtocol TP
JOIN TestType TT ON TT.TestTypeID = TP.TestTypeID
WHERE TT.TestTypeCode = 'CH'


DELETE FROM TestType WHERE TestTypeCode = 'CH'