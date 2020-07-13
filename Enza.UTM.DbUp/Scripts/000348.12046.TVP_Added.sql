CREATE TYPE [dbo].[TVP_TMD_WithDate] AS TABLE(
	[MaterialID] [int] NOT NULL,
	[DeterminationID] [int] NOT NULL,
	[Selected] [bit] NULL,
	[ExpectedDate] [datetime] NULL
)
GO




