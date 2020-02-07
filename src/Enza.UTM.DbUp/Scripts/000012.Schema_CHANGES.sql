/****** Object:  Table [dbo].[Trait]    Script Date: 4/27/2018 10:30:22 AM ******/
DROP TABLE [dbo].[Trait]
GO

/****** Object:  Table [dbo].[Trait]    Script Date: 4/27/2018 10:30:22 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Trait](
	[TraitID] [int] NOT NULL,
	[TraitName] [nvarchar](100) NOT NULL,
	[TraitDescription] [nvarchar](200) NOT NULL,
	[CropCode] [nvarchar](4) NULL,
 CONSTRAINT [PK_Trait] PRIMARY KEY CLUSTERED 
(
	[TraitID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


