UPDATE TestType SET PlateTypeID = NULL WHERE TestTypeName IN ('3GB','GMAS')
GO
INSERT INTO TestType(TestTypeID,TestTypeCode,TestTypeName,[Status],DeterminationRequired,RemarkRequired)
VALUES(6,'S2S','S2S','ACT',0,0)
GO
