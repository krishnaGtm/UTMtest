CREATE TABLE [dbo].[TraitDeterminationResult](
	[TraitDeterminationResultID] [int] IDENTITY(1,1) NOT NULL,
	[CropCode] [nchar](2) NULL,
	[DeterminationID] [int] NULL,
	[TraitID] [int] NULL,
	[DeterminationValue] [nvarchar](max) NULL,
	[TraitValue] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[TraitDeterminationResultID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


