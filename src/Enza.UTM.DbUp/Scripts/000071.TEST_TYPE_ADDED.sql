UPDATE TestType SET TestTypeCode = '3GB' WHERE TestTypeID=4;
GO

INSERT TestType(TestTypeID, TestTypeCode, TestTypeName, [Status], DeterminationRequired, RemarkRequired, PlateTypeID)
VALUES(5, 'GMAS', 'GMAS', 'ACT', 0, 0, 1)
GO