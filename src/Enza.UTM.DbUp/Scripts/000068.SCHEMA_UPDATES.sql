ALTER TABLE Test
ADD ThreeGBTaskID INT
GO

ALTER TABLE Material
ADD ThreeGBPlantID	INT
GO

INSERT TestType(TestTypeID, TestTypeCode, TestTypeName, [Status], DeterminationRequired, RemarkRequired, PlateTypeID)
VALUES(4, '', '3GB', 'ACT', 0, 0, 1)
GO