DROP TABLE IF EXISTS Trait
GO

CREATE TABLE Trait
(
	[TraitID] [int] NOT NULL PRIMARY KEY,
	[TraitName] [nvarchar](100) NOT NULL,
	[TraitDescription] [nvarchar](500) NULL,
	[ListOfValues] [bit] NOT NULL DEFAULT 0,
	[DataType] [nvarchar](15) NOT NULL,
	[ColumnLabel] [nvarchar](10) NULL,
	[Property] [bit] NOT NULL DEFAULT 0

)

GO

DROP TABLE IF EXISTS CropTrait
GO

CREATE TABLE CropTrait
(
	[CropTraitID] INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[TraitID] INT,
	[CropCode] NVARCHAR(2) NOT NULL,
	CONSTRAINT [UC_CropTrait] UNIQUE
	(
		[TraitID],
		[CropCode]
	)
)
GO

DROP TABLE IF EXISTS TraitValue
GO

CREATE TABLE TraitValue
(
	TraitValueID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	TraitID INT,
	TraitValueCode [nvarchar](10) NOT NULL,
	TraitValueName [nvarchar](50) NULL,
	SortingOrder INT NULL
)
GO

DROP TABLE IF EXISTS CropLov
GO
 
CREATE TABLE CropLov
(
	CropLovID [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[TraitValueID] [int] NOT NULL,
	[CropCode] [nchar](2) NOT NULL, 
	CONSTRAINT [UC_CropLov] UNIQUE
	(
		[TraitValueID],
		[CropCode]
	)
) 
GO


DROP TABLE IF EXISTS RelationTraitDetermination
GO

CREATE TABLE RelationTraitDetermination
(
	RelationID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	CropTraitID INT NOT NULL,
	DeterminationID INT NOT NULL,
	StatusCode INT NOT NULL
)
GO

DROP TABLE IF EXISTS TraitDeterminationResult
GO

CREATE TABLE TraitDeterminationResult
(
	TraitDeterminationResultID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	RelationID INT NOT NULL,
	DetResChar NVARCHAR(200) NOT NULL,
	TraitResChar NVARCHAR(200) NOT NULL
)
GO
