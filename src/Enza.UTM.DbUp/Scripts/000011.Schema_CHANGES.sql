/****** Object:  Table [dbo].[Trait]    Script Date: 4/25/2018 1:19:59 PM ******/
DROP TABLE IF EXISTS [dbo].[Trait]
GO
/****** Object:  Table [dbo].[Trait]    Script Date: 4/25/2018 1:19:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Trait]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Trait](
	[TraitID] [int] NOT NULL,
	[TraitName] [nvarchar](100) NULL,
	[TraitDescription] [nvarchar](200) NULL,
	[CropCode] [nvarchar](4) NULL
) ON [PRIMARY]
END
GO
