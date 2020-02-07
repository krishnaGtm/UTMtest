DROP TABLE  IF EXISTS [dbo].[TraitValue]
GO

CREATE TABLE [dbo].[TraitValue](
	[TraitValueID] [int] PRIMARY KEY NOT NULL,
	[TraitID] [int] NOT NULL,
	[TraitValueCode] [nvarchar](50) NOT NULL,
	[TraitValueName] [nvarchar](50) NOT NULL,
	[SortingOrder] [int] NULL
)
GO


