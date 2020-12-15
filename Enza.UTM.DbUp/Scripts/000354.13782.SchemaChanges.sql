
Create TABLE TestMaterialStatus
(
	TestMaterialStatusID INT IDENTITY(1,1) PRIMARY KEY,
	TestID INT,
	MaterialID INT,
	MaterialStatus NVARCHAR(MAX)
)
GO


CREATE INDEX IDX_TestMaterialStatus_TestMaterialID ON TestMaterialStatus
(
	TestID DESC,
	MaterialID
)
GO

ALTER TABLE Material
DROP COLUMN MaterialStatus
GO