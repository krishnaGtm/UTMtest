CREATE TABLE RDTTestResult
(
	RDTTestResultID INT IDENTITY(1,1) PRIMARY KEY,
	TestID INT NOT NULL,
	DeterminationID INT NOT NULL,
	MaterialID INT NOT NULL,
	Score NVARCHAR(100),
	IsResultSent BIT
)
GO

CREATE INDEX IDX_RTDTestResult ON RDTTestResult
(
	TestID DESC,
	DeterminationID,
	MaterialID
)
GO

ALTER TABLE Testmaterial
ADD PhenomeObsID INT NULL
GO