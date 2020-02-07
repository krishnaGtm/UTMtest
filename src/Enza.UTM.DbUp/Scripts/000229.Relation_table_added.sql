DROP TABLE IF EXISTS [dbo].[RelationDonorDH0]
GO

CREATE TABLE [dbo].[RelationDonorDH0](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MaterialID] [int] NULL,
	[CropCode] [nvarchar](10) NULL,
	[ProposedName] [nvarchar](100) NULL,
	[GID] [int] NULL,
	[StatusCode] [int] NULL,
	[TestID] [int] NULL,
 CONSTRAINT [PK_RelationDonarDHO] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO