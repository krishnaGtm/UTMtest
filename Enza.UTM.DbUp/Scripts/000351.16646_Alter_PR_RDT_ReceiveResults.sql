IF TYPE_ID(N'TVP_RDTScore') IS NULL
BEGIN

	CREATE TYPE [dbo].[TVP_RDTScore] AS TABLE(
		[DeterminationID] [int] NULL,
		[MaterialID] [int] NULL,
		[Score] [nvarchar](255) NULL
	)

END
GO

IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'Source'
          AND Object_ID = Object_ID(N'Determination'))
BEGIN

	ALTER TABLE Determination
	ADD [Source] NVARCHAR(50)

END
GO


IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'OriginID'
          AND Object_ID = Object_ID(N'Determination'))
BEGIN

	ALTER TABLE Determination
	ADD OriginID INT

END
GO


