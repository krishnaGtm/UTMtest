IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__S2SDonorM__TestI__1471E42F]') AND parent_object_id = OBJECT_ID(N'[dbo].[S2SDonorMarkerScore]'))
ALTER TABLE [dbo].[S2SDonorMarkerScore] DROP CONSTRAINT [FK__S2SDonorM__TestI__1471E42F]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__S2SDonorM__Mater__15660868]') AND parent_object_id = OBJECT_ID(N'[dbo].[S2SDonorMarkerScore]'))
ALTER TABLE [dbo].[S2SDonorMarkerScore] DROP CONSTRAINT [FK__S2SDonorM__Mater__15660868]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__S2SDonorM__Deter__165A2CA1]') AND parent_object_id = OBJECT_ID(N'[dbo].[S2SDonorMarkerScore]'))
ALTER TABLE [dbo].[S2SDonorMarkerScore] DROP CONSTRAINT [FK__S2SDonorM__Deter__165A2CA1]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__S2SDonorI__RowID__11957784]') AND parent_object_id = OBJECT_ID(N'[dbo].[S2SDonorInfo]'))
ALTER TABLE [dbo].[S2SDonorInfo] DROP CONSTRAINT [FK__S2SDonorI__RowID__11957784]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__S2SCapaci__TestI__0EB90AD9]') AND parent_object_id = OBJECT_ID(N'[dbo].[S2SCapacitySlot]'))
ALTER TABLE [dbo].[S2SCapacitySlot] DROP CONSTRAINT [FK__S2SCapaci__TestI__0EB90AD9]
GO
/****** Object:  Index [idx_markerscore_testid_materialid_determinationid]    Script Date: 4/16/2019 5:24:20 PM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[S2SDonorMarkerScore]') AND name = N'idx_markerscore_testid_materialid_determinationid')
DROP INDEX [idx_markerscore_testid_materialid_determinationid] ON [dbo].[S2SDonorMarkerScore]
GO
/****** Object:  Index [idx_rowid]    Script Date: 4/16/2019 5:24:20 PM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[S2SDonorInfo]') AND name = N'idx_rowid')
DROP INDEX [idx_rowid] ON [dbo].[S2SDonorInfo]
GO
/****** Object:  Index [idx_testid]    Script Date: 4/16/2019 5:24:20 PM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[S2SCapacitySlot]') AND name = N'idx_testid')
DROP INDEX [idx_testid] ON [dbo].[S2SCapacitySlot]
GO
/****** Object:  Table [dbo].[S2SDonorMarkerScore]    Script Date: 4/16/2019 5:24:20 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[S2SDonorMarkerScore]') AND type in (N'U'))
DROP TABLE [dbo].[S2SDonorMarkerScore]
GO
/****** Object:  Table [dbo].[S2SDonorInfo]    Script Date: 4/16/2019 5:24:20 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[S2SDonorInfo]') AND type in (N'U'))
DROP TABLE [dbo].[S2SDonorInfo]
GO
/****** Object:  Table [dbo].[S2SCapacitySlot]    Script Date: 4/16/2019 5:24:20 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[S2SCapacitySlot]') AND type in (N'U'))
DROP TABLE [dbo].[S2SCapacitySlot]
GO
/****** Object:  Table [dbo].[S2SCapacitySlot]    Script Date: 4/16/2019 5:24:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[S2SCapacitySlot](
	[TestID] [int] NOT NULL,
	[CapacitySlotID] [int] NOT NULL,
	[MaxPlants] [int] NULL,
	[CordysStatus] [nvarchar](20) NULL,
	[DH0Location] [nvarchar](100) NULL,
	[AvailPlants] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[CapacitySlotID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[S2SDonorInfo]    Script Date: 4/16/2019 5:24:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[S2SDonorInfo](
	[S2SDonorID] [int] IDENTITY(1,1) NOT NULL,
	[RowID] [int] NOT NULL,
	[DonorNumber] [nvarchar](20) NULL,
	[DH0Net] [int] NULL,
	[Requested] [int] NULL,
	[Transplant] [int] NULL,
	[ToBeSown] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[S2SDonorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[S2SDonorMarkerScore]    Script Date: 4/16/2019 5:24:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[S2SDonorMarkerScore](
	[S2SScoreID] [int] IDENTITY(1,1) NOT NULL,
	[TestID] [int] NOT NULL,
	[MaterialID] [int] NULL,
	[DeterminationID] [int] NULL,
	[Score] [nvarchar](8) NULL,
PRIMARY KEY CLUSTERED 
(
	[S2SScoreID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [idx_testid]    Script Date: 4/16/2019 5:24:20 PM ******/
CREATE NONCLUSTERED INDEX [idx_testid] ON [dbo].[S2SCapacitySlot]
(
	[TestID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_rowid]    Script Date: 4/16/2019 5:24:20 PM ******/
CREATE NONCLUSTERED INDEX [idx_rowid] ON [dbo].[S2SDonorInfo]
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_markerscore_testid_materialid_determinationid]    Script Date: 4/16/2019 5:24:20 PM ******/
CREATE NONCLUSTERED INDEX [idx_markerscore_testid_materialid_determinationid] ON [dbo].[S2SDonorMarkerScore]
(
	[TestID] ASC,
	[MaterialID] ASC,
	[DeterminationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S2SCapacitySlot]  WITH CHECK ADD FOREIGN KEY([TestID])
REFERENCES [dbo].[Test] ([TestID])
GO
ALTER TABLE [dbo].[S2SDonorInfo]  WITH CHECK ADD FOREIGN KEY([RowID])
REFERENCES [dbo].[Row] ([RowID])
GO
ALTER TABLE [dbo].[S2SDonorMarkerScore]  WITH CHECK ADD FOREIGN KEY([DeterminationID])
REFERENCES [dbo].[Determination] ([DeterminationID])
GO
ALTER TABLE [dbo].[S2SDonorMarkerScore]  WITH CHECK ADD FOREIGN KEY([MaterialID])
REFERENCES [dbo].[Material] ([MaterialID])
GO
ALTER TABLE [dbo].[S2SDonorMarkerScore]  WITH CHECK ADD FOREIGN KEY([TestID])
REFERENCES [dbo].[Test] ([TestID])
GO
