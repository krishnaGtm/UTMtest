IF  EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'Row', N'COLUMN',N'MaterialKey'))
EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Row', @level2type=N'COLUMN',@level2name=N'MaterialKey'

GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WellTypePosition]') AND type in (N'U'))
ALTER TABLE [dbo].[WellTypePosition] DROP CONSTRAINT IF EXISTS [FK_WellTypePosition_WellType]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WellTypePosition]') AND type in (N'U'))
ALTER TABLE [dbo].[WellTypePosition] DROP CONSTRAINT IF EXISTS [FK_WellTypePosition_TestType]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Well]') AND type in (N'U'))
ALTER TABLE [dbo].[Well] DROP CONSTRAINT IF EXISTS [FK_Well_WellType]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Well]') AND type in (N'U'))
ALTER TABLE [dbo].[Well] DROP CONSTRAINT IF EXISTS [FK_Well_Plate]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TestType]') AND type in (N'U'))
ALTER TABLE [dbo].[TestType] DROP CONSTRAINT IF EXISTS [FK_TestType_PlateType1]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TestResult]') AND type in (N'U'))
ALTER TABLE [dbo].[TestResult] DROP CONSTRAINT IF EXISTS [FK_TestResult_Well]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TestResult]') AND type in (N'U'))
ALTER TABLE [dbo].[TestResult] DROP CONSTRAINT IF EXISTS [FK_TestResult_Determination]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TestProtocol]') AND type in (N'U'))
ALTER TABLE [dbo].[TestProtocol] DROP CONSTRAINT IF EXISTS [FK_TestProtocol_TestType]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TestMaterialDeterminationWell]') AND type in (N'U'))
ALTER TABLE [dbo].[TestMaterialDeterminationWell] DROP CONSTRAINT IF EXISTS [FK_TestMaterialDeterminationWell_Well]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TestMaterialDeterminationWell]') AND type in (N'U'))
ALTER TABLE [dbo].[TestMaterialDeterminationWell] DROP CONSTRAINT IF EXISTS [FK_TestMaterialDeterminationWell_Material]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TestMaterialDetermination]') AND type in (N'U'))
ALTER TABLE [dbo].[TestMaterialDetermination] DROP CONSTRAINT IF EXISTS [FK_TestMaterialDetermination_Test]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TestMaterialDetermination]') AND type in (N'U'))
ALTER TABLE [dbo].[TestMaterialDetermination] DROP CONSTRAINT IF EXISTS [FK_TestMaterialDetermination_Material]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TestMaterialDetermination]') AND type in (N'U'))
ALTER TABLE [dbo].[TestMaterialDetermination] DROP CONSTRAINT IF EXISTS [FK_TestMaterialDetermination_Determination]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Test]') AND type in (N'U'))
ALTER TABLE [dbo].[Test] DROP CONSTRAINT IF EXISTS [FK_Test_TestType]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Test]') AND type in (N'U'))
ALTER TABLE [dbo].[Test] DROP CONSTRAINT IF EXISTS [FK_Test_TestProtocol]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Test]') AND type in (N'U'))
ALTER TABLE [dbo].[Test] DROP CONSTRAINT IF EXISTS [FK_Test_MaterialType]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Test]') AND type in (N'U'))
ALTER TABLE [dbo].[Test] DROP CONSTRAINT IF EXISTS [FK_Test_MaterialState]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Test]') AND type in (N'U'))
ALTER TABLE [dbo].[Test] DROP CONSTRAINT IF EXISTS [FK_Test_File]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Test]') AND type in (N'U'))
ALTER TABLE [dbo].[Test] DROP CONSTRAINT IF EXISTS [FK_Test_ContainerType]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SlotTest]') AND type in (N'U'))
ALTER TABLE [dbo].[SlotTest] DROP CONSTRAINT IF EXISTS [FK_SlotTest_Test]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SlotTest]') AND type in (N'U'))
ALTER TABLE [dbo].[SlotTest] DROP CONSTRAINT IF EXISTS [FK_SlotTest_Slot]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Slot]') AND type in (N'U'))
ALTER TABLE [dbo].[Slot] DROP CONSTRAINT IF EXISTS [FK_Slot_Period]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Slot]') AND type in (N'U'))
ALTER TABLE [dbo].[Slot] DROP CONSTRAINT IF EXISTS [FK_Slot_MaterialType]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Slot]') AND type in (N'U'))
ALTER TABLE [dbo].[Slot] DROP CONSTRAINT IF EXISTS [FK_Slot_MaterialState]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Row]') AND type in (N'U'))
ALTER TABLE [dbo].[Row] DROP CONSTRAINT IF EXISTS [FK_Row_File]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReservedCapacity]') AND type in (N'U'))
ALTER TABLE [dbo].[ReservedCapacity] DROP CONSTRAINT IF EXISTS [FK_ReservedCapacity_TestProtocol]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReservedCapacity]') AND type in (N'U'))
ALTER TABLE [dbo].[ReservedCapacity] DROP CONSTRAINT IF EXISTS [FK_ReservedCapacity_Slot]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RelationTraitDetermination]') AND type in (N'U'))
ALTER TABLE [dbo].[RelationTraitDetermination] DROP CONSTRAINT IF EXISTS [FK_RelationTraitDetermination_Determination]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Plate]') AND type in (N'U'))
ALTER TABLE [dbo].[Plate] DROP CONSTRAINT IF EXISTS [FK_Plate_Test]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MaterialTypeTestProtocol]') AND type in (N'U'))
ALTER TABLE [dbo].[MaterialTypeTestProtocol] DROP CONSTRAINT IF EXISTS [FK_MaterialTypeTestProtocol_TestProtocol]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MaterialTypeTestProtocol]') AND type in (N'U'))
ALTER TABLE [dbo].[MaterialTypeTestProtocol] DROP CONSTRAINT IF EXISTS [FK_MaterialTypeTestProtocol_MaterialType]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Determination]') AND type in (N'U'))
ALTER TABLE [dbo].[Determination] DROP CONSTRAINT IF EXISTS [FK_Determination_TestType]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Column]') AND type in (N'U'))
ALTER TABLE [dbo].[Column] DROP CONSTRAINT IF EXISTS [FK_Column_File]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cell]') AND type in (N'U'))
ALTER TABLE [dbo].[Cell] DROP CONSTRAINT IF EXISTS [FK_Cell_Row]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cell]') AND type in (N'U'))
ALTER TABLE [dbo].[Cell] DROP CONSTRAINT IF EXISTS [FK_Cell_Column]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AvailCapacity]') AND type in (N'U'))
ALTER TABLE [dbo].[AvailCapacity] DROP CONSTRAINT IF EXISTS [FK_Capacity_TestProtocol]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AvailCapacity]') AND type in (N'U'))
ALTER TABLE [dbo].[AvailCapacity] DROP CONSTRAINT IF EXISTS [FK_Capacity_Period]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WellTypePosition]') AND type in (N'U'))
ALTER TABLE [dbo].[WellTypePosition] DROP CONSTRAINT IF EXISTS [DF_WellTypePosition_PlateInTest]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TestType]') AND type in (N'U'))
ALTER TABLE [dbo].[TestType] DROP CONSTRAINT IF EXISTS [DF_TestType_DeterminationRequired]
GO
/****** Object:  Index [IX_Row_RowID_RowNr_MaterialKey]    Script Date: 4/11/2018 5:35:21 PM ******/
DROP INDEX IF EXISTS [IX_Row_RowID_RowNr_MaterialKey] ON [dbo].[Row]
GO
/****** Object:  Index [IX_Row]    Script Date: 4/11/2018 5:35:21 PM ******/
DROP INDEX IF EXISTS [IX_Row] ON [dbo].[Row]
GO
/****** Object:  Index [IDX_Material_MaterialKey]    Script Date: 4/11/2018 5:35:21 PM ******/
DROP INDEX IF EXISTS [IDX_Material_MaterialKey] ON [dbo].[Material]
GO
/****** Object:  Index [IX_Column_FileID>]    Script Date: 4/11/2018 5:35:21 PM ******/
DROP INDEX IF EXISTS [IX_Column_FileID>] ON [dbo].[Column]
GO
/****** Object:  Index [IX_Cell_RowID]    Script Date: 4/11/2018 5:35:21 PM ******/
DROP INDEX IF EXISTS [IX_Cell_RowID] ON [dbo].[Cell]
GO
/****** Object:  Index [IX_Cell_ColumnID_Value]    Script Date: 4/11/2018 5:35:21 PM ******/
DROP INDEX IF EXISTS [IX_Cell_ColumnID_Value] ON [dbo].[Cell]
GO
/****** Object:  Table [dbo].[WellTypePosition]    Script Date: 4/11/2018 5:35:21 PM ******/
DROP TABLE IF EXISTS [dbo].[WellTypePosition]
GO
/****** Object:  Table [dbo].[WellType]    Script Date: 4/11/2018 5:35:22 PM ******/
DROP TABLE IF EXISTS [dbo].[WellType]
GO
/****** Object:  Table [dbo].[Well]    Script Date: 4/11/2018 5:35:22 PM ******/
DROP TABLE IF EXISTS [dbo].[Well]
GO
/****** Object:  Table [dbo].[TestType]    Script Date: 4/11/2018 5:35:22 PM ******/
DROP TABLE IF EXISTS [dbo].[TestType]
GO
/****** Object:  Table [dbo].[TestResult]    Script Date: 4/11/2018 5:35:22 PM ******/
DROP TABLE IF EXISTS [dbo].[TestResult]
GO
/****** Object:  Table [dbo].[TestProtocol]    Script Date: 4/11/2018 5:35:22 PM ******/
DROP TABLE IF EXISTS [dbo].[TestProtocol]
GO
/****** Object:  Table [dbo].[TestMaterialDeterminationWell]    Script Date: 4/11/2018 5:35:22 PM ******/
DROP TABLE IF EXISTS [dbo].[TestMaterialDeterminationWell]
GO
/****** Object:  Table [dbo].[TestMaterialDetermination]    Script Date: 4/11/2018 5:35:22 PM ******/
DROP TABLE IF EXISTS [dbo].[TestMaterialDetermination]
GO
/****** Object:  Table [dbo].[Test]    Script Date: 4/11/2018 5:35:23 PM ******/
DROP TABLE IF EXISTS [dbo].[Test]
GO
/****** Object:  Table [dbo].[Status]    Script Date: 4/11/2018 5:35:23 PM ******/
DROP TABLE IF EXISTS [dbo].[Status]
GO
/****** Object:  Table [dbo].[SlotTest]    Script Date: 4/11/2018 5:35:23 PM ******/
DROP TABLE IF EXISTS [dbo].[SlotTest]
GO
/****** Object:  Table [dbo].[Slot]    Script Date: 4/11/2018 5:35:23 PM ******/
DROP TABLE IF EXISTS [dbo].[Slot]
GO
/****** Object:  Table [dbo].[SchemaVersions]    Script Date: 4/11/2018 5:35:23 PM ******/
DROP TABLE IF EXISTS [dbo].[SchemaVersions]
GO
/****** Object:  Table [dbo].[Row]    Script Date: 4/11/2018 5:35:23 PM ******/
DROP TABLE IF EXISTS [dbo].[Row]
GO
/****** Object:  Table [dbo].[ReservedCapacity]    Script Date: 4/11/2018 5:35:23 PM ******/
DROP TABLE IF EXISTS [dbo].[ReservedCapacity]
GO
/****** Object:  Table [dbo].[RelationTraitDetermination]    Script Date: 4/11/2018 5:35:23 PM ******/
DROP TABLE IF EXISTS [dbo].[RelationTraitDetermination]
GO
/****** Object:  Table [dbo].[PlateType]    Script Date: 4/11/2018 5:35:24 PM ******/
DROP TABLE IF EXISTS [dbo].[PlateType]
GO
/****** Object:  Table [dbo].[Plate]    Script Date: 4/11/2018 5:35:24 PM ******/
DROP TABLE IF EXISTS [dbo].[Plate]
GO
/****** Object:  Table [dbo].[Period]    Script Date: 4/11/2018 5:35:24 PM ******/
DROP TABLE IF EXISTS [dbo].[Period]
GO
/****** Object:  Table [dbo].[MaterialTypeTestProtocol]    Script Date: 4/11/2018 5:35:24 PM ******/
DROP TABLE IF EXISTS [dbo].[MaterialTypeTestProtocol]
GO
/****** Object:  Table [dbo].[MaterialType]    Script Date: 4/11/2018 5:35:24 PM ******/
DROP TABLE IF EXISTS [dbo].[MaterialType]
GO
/****** Object:  Table [dbo].[MaterialState]    Script Date: 4/11/2018 5:35:24 PM ******/
DROP TABLE IF EXISTS [dbo].[MaterialState]
GO
/****** Object:  Table [dbo].[Material]    Script Date: 4/11/2018 5:35:24 PM ******/
DROP TABLE IF EXISTS [dbo].[Material]
GO
/****** Object:  Table [dbo].[File]    Script Date: 4/11/2018 5:35:24 PM ******/
DROP TABLE IF EXISTS [dbo].[File]
GO
/****** Object:  Table [dbo].[Determination]    Script Date: 4/11/2018 5:35:24 PM ******/
DROP TABLE IF EXISTS [dbo].[Determination]
GO
/****** Object:  Table [dbo].[CropRD]    Script Date: 4/11/2018 5:35:25 PM ******/
DROP TABLE IF EXISTS [dbo].[CropRD]
GO
/****** Object:  Table [dbo].[ContainerType]    Script Date: 4/11/2018 5:35:25 PM ******/
DROP TABLE IF EXISTS [dbo].[ContainerType]
GO
/****** Object:  Table [dbo].[Column]    Script Date: 4/11/2018 5:35:25 PM ******/
DROP TABLE IF EXISTS [dbo].[Column]
GO
/****** Object:  Table [dbo].[Cell]    Script Date: 4/11/2018 5:35:25 PM ******/
DROP TABLE IF EXISTS [dbo].[Cell]
GO
/****** Object:  Table [dbo].[BreedingStation]    Script Date: 4/11/2018 5:35:25 PM ******/
DROP TABLE IF EXISTS [dbo].[BreedingStation]
GO
/****** Object:  Table [dbo].[AvailCapacity]    Script Date: 4/11/2018 5:35:25 PM ******/
DROP TABLE IF EXISTS [dbo].[AvailCapacity]
GO
/****** Object:  Table [dbo].[AvailCapacity]    Script Date: 4/11/2018 5:35:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AvailCapacity]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[AvailCapacity](
	[AvailCapacityID] [int] IDENTITY(1,1) NOT NULL,
	[PeriodID] [int] NULL,
	[TestProtocolID] [int] NULL,
	[NrOfPlates] [int] NULL,
	[NrOfTests] [int] NULL,
 CONSTRAINT [PK_Capacity] PRIMARY KEY CLUSTERED 
(
	[AvailCapacityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[BreedingStation]    Script Date: 4/11/2018 5:35:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BreedingStation]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[BreedingStation](
	[BreedingStationCode] [nvarchar](4) NOT NULL,
	[BreedingStationName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_BreedingStation] PRIMARY KEY CLUSTERED 
(
	[BreedingStationCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[Cell]    Script Date: 4/11/2018 5:35:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cell]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Cell](
	[CellID] [int] IDENTITY(1,1) NOT NULL,
	[RowID] [int] NOT NULL,
	[ColumnID] [int] NOT NULL,
	[Value] [nvarchar](max) NULL,
 CONSTRAINT [PK_Cell] PRIMARY KEY CLUSTERED 
(
	[CellID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[Column]    Script Date: 4/11/2018 5:35:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Column]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Column](
	[ColumnID] [int] IDENTITY(1,1) NOT NULL,
	[ColumnNr] [int] NOT NULL,
	[TraitID] [int] NULL,
	[ColumLabel] [nvarchar](50) NOT NULL,
	[FileID] [int] NOT NULL,
	[DataType] [varchar](15) NOT NULL,
 CONSTRAINT [PK_Column] PRIMARY KEY CLUSTERED 
(
	[ColumnID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ContainerType]    Script Date: 4/11/2018 5:35:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ContainerType]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ContainerType](
	[ContainerTypeID] [int] NOT NULL,
	[ContainerTypeCode] [nvarchar](50) NOT NULL,
	[ContainerTypeName] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[ContainerTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[CropRD]    Script Date: 4/11/2018 5:35:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CropRD]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[CropRD](
	[CropCode] [nchar](2) NOT NULL,
	[CropName] [nvarchar](32) NOT NULL,
 CONSTRAINT [PK_CropRD] PRIMARY KEY CLUSTERED 
(
	[CropCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[Determination]    Script Date: 4/11/2018 5:35:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Determination]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Determination](
	[DeterminationID] [int] NOT NULL,
	[CropCode] [nvarchar](10) NOT NULL,
	[TestTypeID] [int] NOT NULL,
	[SrcSysDeterminationID] [int] NULL,
	[DeterminationName] [nvarchar](100) NOT NULL,
	[DeterminationAlias] [nvarchar](50) NULL,
	[Status] [nvarchar](20) NULL,
	[DataType] [varchar](3) NULL,
 CONSTRAINT [PK_Determination] PRIMARY KEY CLUSTERED 
(
	[DeterminationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[File]    Script Date: 4/11/2018 5:35:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[File]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[File](
	[FileID] [int] IDENTITY(1,1) NOT NULL,
	[CropCode] [nvarchar](10) NOT NULL,
	[FileTitle] [nvarchar](100) NOT NULL,
	[UserID] [nvarchar](50) NOT NULL,
	[ImportDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_File] PRIMARY KEY CLUSTERED 
(
	[FileID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[Material]    Script Date: 4/11/2018 5:35:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Material]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Material](
	[MaterialID] [int] IDENTITY(1,1) NOT NULL,
	[MaterialType] [nvarchar](20) NOT NULL,
	[MaterialKey] [nvarchar](50) NOT NULL,
	[Source] [nvarchar](50) NOT NULL,
	[CropCode] [nvarchar](2) NOT NULL,
	[StatusCode] [int] NULL,
 CONSTRAINT [PK_Material] PRIMARY KEY CLUSTERED 
(
	[MaterialID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[MaterialState]    Script Date: 4/11/2018 5:35:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MaterialState]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[MaterialState](
	[MaterialStateID] [int] IDENTITY(1,1) NOT NULL,
	[MaterialStateCode] [varchar](8) NOT NULL,
	[MaterialStateDescription] [varchar](20) NULL,
 CONSTRAINT [PK_MaterialState] PRIMARY KEY CLUSTERED 
(
	[MaterialStateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MaterialType]    Script Date: 4/11/2018 5:35:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MaterialType]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[MaterialType](
	[MaterialTypeID] [int] IDENTITY(1,1) NOT NULL,
	[MaterialTypeCode] [varchar](8) NOT NULL,
	[MaterialTypeDescription] [varchar](20) NULL,
 CONSTRAINT [PK_MaterialType_MaterialTypeID] PRIMARY KEY CLUSTERED 
(
	[MaterialTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MaterialTypeTestProtocol]    Script Date: 4/11/2018 5:35:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MaterialTypeTestProtocol]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[MaterialTypeTestProtocol](
	[MaterialTypeID] [int] NOT NULL,
	[TestProtocolID] [int] NOT NULL,
	[CropCode] [nchar](2) NOT NULL,
 CONSTRAINT [PK_MaterialTypeTestProtocol] PRIMARY KEY CLUSTERED 
(
	[MaterialTypeID] ASC,
	[TestProtocolID] ASC,
	[CropCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[Period]    Script Date: 4/11/2018 5:35:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Period]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Period](
	[PeriodID] [int] IDENTITY(1,1) NOT NULL,
	[PeriodName] [nvarchar](50) NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NOT NULL,
	[Remark] [nvarchar](255) NULL,
 CONSTRAINT [PK_Period] PRIMARY KEY CLUSTERED 
(
	[PeriodID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[Plate]    Script Date: 4/11/2018 5:35:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Plate]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Plate](
	[PlateID] [int] IDENTITY(1,1) NOT NULL,
	[TempID] [int] NULL,
	[LabPlateID] [int] NULL,
	[PlateName] [nvarchar](255) NOT NULL,
	[TestID] [int] NOT NULL,
 CONSTRAINT [PK_Plate] PRIMARY KEY CLUSTERED 
(
	[PlateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[PlateType]    Script Date: 4/11/2018 5:35:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PlateType]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PlateType](
	[PlateTypeID] [int] IDENTITY(1,1) NOT NULL,
	[PlateTypeName] [varchar](25) NOT NULL,
	[StartRow] [varchar](2) NOT NULL,
	[EndRow] [nvarchar](2) NOT NULL,
	[StartColumn] [int] NOT NULL,
	[EndColumn] [int] NOT NULL,
 CONSTRAINT [PK_PlateType] PRIMARY KEY CLUSTERED 
(
	[PlateTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RelationTraitDetermination]    Script Date: 4/11/2018 5:35:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RelationTraitDetermination]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RelationTraitDetermination](
	[RelationID] [int] IDENTITY(1,1) NOT NULL,
	[CropCode] [nvarchar](10) NOT NULL,
	[TraitID] [int] NULL,
	[ColumnLabel] [nvarchar](50) NOT NULL,
	[ScrFieldDetermination] [int] NULL,
	[DeterminationID] [int] NOT NULL,
	[Source] [nvarchar](50) NULL,
	[Status] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_RelationTraitDetermination] PRIMARY KEY CLUSTERED 
(
	[RelationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[ReservedCapacity]    Script Date: 4/11/2018 5:35:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReservedCapacity]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ReservedCapacity](
	[ReservedCapacityID] [int] IDENTITY(1,1) NOT NULL,
	[SlotID] [int] NULL,
	[TestProtocolID] [int] NULL,
	[NrOfPlates] [int] NULL,
	[NrOfTests] [int] NULL,
 CONSTRAINT [PK_ReservedCapacity] PRIMARY KEY CLUSTERED 
(
	[ReservedCapacityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[Row]    Script Date: 4/11/2018 5:35:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Row]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Row](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[RowNr] [int] NOT NULL,
	[MaterialKey] [nvarchar](50) NOT NULL,
	[FileID] [int] NOT NULL,
 CONSTRAINT [PK_Row] PRIMARY KEY CLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[SchemaVersions]    Script Date: 4/11/2018 5:35:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SchemaVersions]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SchemaVersions](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ScriptName] [nvarchar](255) NOT NULL,
	[Applied] [datetime] NOT NULL,
 CONSTRAINT [PK_SchemaVersions_Id] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[Slot]    Script Date: 4/11/2018 5:35:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Slot]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Slot](
	[SlotID] [int] IDENTITY(1,1) NOT NULL,
	[SlotName] [nvarchar](50) NOT NULL,
	[PeriodID] [int] NOT NULL,
	[StatusCode] [int] NOT NULL,
	[CropCode] [nchar](2) NOT NULL,
	[MaterialTypeID] [int] NOT NULL,
	[MaterialStateID] [int] NOT NULL,
	[RequestUser] [nvarchar](50) NOT NULL,
	[RequestDate] [date] NOT NULL,
	[PlannedDate] [date] NULL,
	[ExpectedDate] [date] NULL,
	[Isolated] [bit] NULL,
	[BreedingStationCode] [nvarchar](4) NULL,
 CONSTRAINT [PK_Slot] PRIMARY KEY CLUSTERED 
(
	[SlotID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[SlotTest]    Script Date: 4/11/2018 5:35:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SlotTest]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SlotTest](
	[SlotID] [int] NOT NULL,
	[TestID] [int] NOT NULL,
 CONSTRAINT [PK_SlotTest] PRIMARY KEY CLUSTERED 
(
	[SlotID] ASC,
	[TestID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[Status]    Script Date: 4/11/2018 5:35:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Status]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Status](
	[StatusID] [int] NOT NULL,
	[StatusTable] [nvarchar](50) NOT NULL,
	[StatusCode] [int] NOT NULL,
	[StatusName] [nvarchar](50) NOT NULL,
	[StatusDescription] [nvarchar](255) NULL,
 CONSTRAINT [PK_Status] PRIMARY KEY CLUSTERED 
(
	[StatusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[Test]    Script Date: 4/11/2018 5:35:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Test]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Test](
	[TestID] [int] IDENTITY(1,1) NOT NULL,
	[TestTypeID] [int] NOT NULL,
	[FileID] [int] NOT NULL,
	[TestName] [nvarchar](200) NOT NULL,
	[RequestingSystem] [nvarchar](50) NULL,
	[RequestingUser] [nvarchar](75) NOT NULL,
	[LabPlatePlanID] [int] NULL,
	[CreationDate] [datetime] NOT NULL,
	[PlannedDate] [datetime] NULL,
	[StatusCode] [int] NOT NULL,
	[Remark] [nvarchar](255) NULL,
	[MaterialTypeID] [int] NULL,
	[MaterialStateID] [int] NULL,
	[ContainerTypeID] [int] NULL,
	[Isolated] [bit] NULL,
	[LabPlatePlanName] [nvarchar](200) NULL,
	[TestProtocolID] [int] NULL,
	[BreedingStationCode] [nvarchar](10) NULL,
 CONSTRAINT [PK_Test] PRIMARY KEY CLUSTERED 
(
	[TestID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[TestMaterialDetermination]    Script Date: 4/11/2018 5:35:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TestMaterialDetermination]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[TestMaterialDetermination](
	[TestMaterialDeterminationID] [int] IDENTITY(1,1) NOT NULL,
	[TestID] [int] NOT NULL,
	[MaterialID] [int] NOT NULL,
	[DeterminationID] [int] NOT NULL,
 CONSTRAINT [PK_TestMaterialDetermination] PRIMARY KEY CLUSTERED 
(
	[TestMaterialDeterminationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[TestMaterialDeterminationWell]    Script Date: 4/11/2018 5:35:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TestMaterialDeterminationWell]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[TestMaterialDeterminationWell](
	[TestMaterialDeterminationWellID] [int] IDENTITY(1,1) NOT NULL,
	[MaterialID] [int] NOT NULL,
	[WellID] [int] NOT NULL,
 CONSTRAINT [PK_TestMaterialDeterminationWell] PRIMARY KEY CLUSTERED 
(
	[TestMaterialDeterminationWellID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[TestProtocol]    Script Date: 4/11/2018 5:35:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TestProtocol]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[TestProtocol](
	[TestProtocolID] [int] IDENTITY(1,1) NOT NULL,
	[TestTypeID] [int] NOT NULL,
	[TestProtocolName] [nvarchar](50) NOT NULL,
	[Isolated] [bit] NULL,
 CONSTRAINT [PK_TestProtocol] PRIMARY KEY CLUSTERED 
(
	[TestProtocolID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[TestResult]    Script Date: 4/11/2018 5:35:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TestResult]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[TestResult](
	[TestResultID] [int] IDENTITY(1,1) NOT NULL,
	[WellID] [int] NOT NULL,
	[DeterminationID] [int] NOT NULL,
	[ObsValueChar] [nvarchar](255) NULL,
	[ObsValueInt] [int] NULL,
	[ObsValueDate] [datetime] NULL,
	[ObsValueDec] [decimal](14, 4) NULL,
PRIMARY KEY CLUSTERED 
(
	[TestResultID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[TestType]    Script Date: 4/11/2018 5:35:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TestType]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[TestType](
	[TestTypeID] [int] NOT NULL,
	[TestTypeCode] [nvarchar](20) NOT NULL,
	[TestTypeName] [nvarchar](255) NOT NULL,
	[Status] [nvarchar](50) NOT NULL,
	[DeterminationRequired] [bit] NOT NULL,
	[RemarkRequired] [bit] NOT NULL,
	[PlateTypeID] [int] NULL,
 CONSTRAINT [PK_TestType] PRIMARY KEY CLUSTERED 
(
	[TestTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[Well]    Script Date: 4/11/2018 5:35:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Well]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Well](
	[WellID] [int] IDENTITY(1,1) NOT NULL,
	[WellTypeID] [int] NOT NULL,
	[Position] [varchar](3) NOT NULL,
	[PlateID] [int] NOT NULL,
 CONSTRAINT [PK_Well] PRIMARY KEY CLUSTERED 
(
	[WellID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WellType]    Script Date: 4/11/2018 5:35:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WellType]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[WellType](
	[WellTypeID] [int] IDENTITY(1,1) NOT NULL,
	[WellTypeName] [nvarchar](20) NOT NULL,
	[BGColor] [nvarchar](14) NULL,
	[FGColor] [nvarchar](14) NULL,
	[WellTypeDescription] [nvarchar](50) NULL,
 CONSTRAINT [PK_WellType] PRIMARY KEY CLUSTERED 
(
	[WellTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[WellTypePosition]    Script Date: 4/11/2018 5:35:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WellTypePosition]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[WellTypePosition](
	[WellTypePositionID] [int] IDENTITY(1,1) NOT NULL,
	[WellTypeID] [int] NOT NULL,
	[TestTypeID] [int] NOT NULL,
	[PositionOnPlate] [nvarchar](6) NULL,
	[PlateInTest] [int] NULL,
 CONSTRAINT [PK_WellTypePosition] PRIMARY KEY CLUSTERED 
(
	[WellTypePositionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Cell_ColumnID_Value]    Script Date: 4/11/2018 5:35:30 PM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Cell]') AND name = N'IX_Cell_ColumnID_Value')
CREATE NONCLUSTERED INDEX [IX_Cell_ColumnID_Value] ON [dbo].[Cell]
(
	[RowID] ASC
)
INCLUDE ( 	[ColumnID],
	[Value]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Cell_RowID]    Script Date: 4/11/2018 5:35:30 PM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Cell]') AND name = N'IX_Cell_RowID')
CREATE NONCLUSTERED INDEX [IX_Cell_RowID] ON [dbo].[Cell]
(
	[ColumnID] ASC
)
INCLUDE ( 	[RowID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Column_FileID>]    Script Date: 4/11/2018 5:35:30 PM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Column]') AND name = N'IX_Column_FileID>')
CREATE NONCLUSTERED INDEX [IX_Column_FileID>] ON [dbo].[Column]
(
	[FileID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IDX_Material_MaterialKey]    Script Date: 4/11/2018 5:35:30 PM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Material]') AND name = N'IDX_Material_MaterialKey')
CREATE UNIQUE NONCLUSTERED INDEX [IDX_Material_MaterialKey] ON [dbo].[Material]
(
	[MaterialKey] ASC
)
INCLUDE ( 	[MaterialID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Row]    Script Date: 4/11/2018 5:35:30 PM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Row]') AND name = N'IX_Row')
CREATE UNIQUE NONCLUSTERED INDEX [IX_Row] ON [dbo].[Row]
(
	[FileID] ASC,
	[RowNr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Row_RowID_RowNr_MaterialKey]    Script Date: 4/11/2018 5:35:30 PM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Row]') AND name = N'IX_Row_RowID_RowNr_MaterialKey')
CREATE NONCLUSTERED INDEX [IX_Row_RowID_RowNr_MaterialKey] ON [dbo].[Row]
(
	[FileID] ASC
)
INCLUDE ( 	[RowID],
	[RowNr],
	[MaterialKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TestType_DeterminationRequired]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TestType] ADD  CONSTRAINT [DF_TestType_DeterminationRequired]  DEFAULT ((0)) FOR [DeterminationRequired]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WellTypePosition_PlateInTest]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WellTypePosition] ADD  CONSTRAINT [DF_WellTypePosition_PlateInTest]  DEFAULT ((0)) FOR [PlateInTest]
END

GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Capacity_Period]') AND parent_object_id = OBJECT_ID(N'[dbo].[AvailCapacity]'))
ALTER TABLE [dbo].[AvailCapacity]  WITH CHECK ADD  CONSTRAINT [FK_Capacity_Period] FOREIGN KEY([PeriodID])
REFERENCES [dbo].[Period] ([PeriodID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Capacity_Period]') AND parent_object_id = OBJECT_ID(N'[dbo].[AvailCapacity]'))
ALTER TABLE [dbo].[AvailCapacity] CHECK CONSTRAINT [FK_Capacity_Period]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Capacity_TestProtocol]') AND parent_object_id = OBJECT_ID(N'[dbo].[AvailCapacity]'))
ALTER TABLE [dbo].[AvailCapacity]  WITH CHECK ADD  CONSTRAINT [FK_Capacity_TestProtocol] FOREIGN KEY([TestProtocolID])
REFERENCES [dbo].[TestProtocol] ([TestProtocolID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Capacity_TestProtocol]') AND parent_object_id = OBJECT_ID(N'[dbo].[AvailCapacity]'))
ALTER TABLE [dbo].[AvailCapacity] CHECK CONSTRAINT [FK_Capacity_TestProtocol]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Cell_Column]') AND parent_object_id = OBJECT_ID(N'[dbo].[Cell]'))
ALTER TABLE [dbo].[Cell]  WITH CHECK ADD  CONSTRAINT [FK_Cell_Column] FOREIGN KEY([ColumnID])
REFERENCES [dbo].[Column] ([ColumnID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Cell_Column]') AND parent_object_id = OBJECT_ID(N'[dbo].[Cell]'))
ALTER TABLE [dbo].[Cell] CHECK CONSTRAINT [FK_Cell_Column]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Cell_Row]') AND parent_object_id = OBJECT_ID(N'[dbo].[Cell]'))
ALTER TABLE [dbo].[Cell]  WITH CHECK ADD  CONSTRAINT [FK_Cell_Row] FOREIGN KEY([RowID])
REFERENCES [dbo].[Row] ([RowID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Cell_Row]') AND parent_object_id = OBJECT_ID(N'[dbo].[Cell]'))
ALTER TABLE [dbo].[Cell] CHECK CONSTRAINT [FK_Cell_Row]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Column_File]') AND parent_object_id = OBJECT_ID(N'[dbo].[Column]'))
ALTER TABLE [dbo].[Column]  WITH CHECK ADD  CONSTRAINT [FK_Column_File] FOREIGN KEY([FileID])
REFERENCES [dbo].[File] ([FileID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Column_File]') AND parent_object_id = OBJECT_ID(N'[dbo].[Column]'))
ALTER TABLE [dbo].[Column] CHECK CONSTRAINT [FK_Column_File]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Determination_TestType]') AND parent_object_id = OBJECT_ID(N'[dbo].[Determination]'))
ALTER TABLE [dbo].[Determination]  WITH CHECK ADD  CONSTRAINT [FK_Determination_TestType] FOREIGN KEY([TestTypeID])
REFERENCES [dbo].[TestType] ([TestTypeID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Determination_TestType]') AND parent_object_id = OBJECT_ID(N'[dbo].[Determination]'))
ALTER TABLE [dbo].[Determination] CHECK CONSTRAINT [FK_Determination_TestType]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_MaterialTypeTestProtocol_MaterialType]') AND parent_object_id = OBJECT_ID(N'[dbo].[MaterialTypeTestProtocol]'))
ALTER TABLE [dbo].[MaterialTypeTestProtocol]  WITH CHECK ADD  CONSTRAINT [FK_MaterialTypeTestProtocol_MaterialType] FOREIGN KEY([MaterialTypeID])
REFERENCES [dbo].[MaterialType] ([MaterialTypeID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_MaterialTypeTestProtocol_MaterialType]') AND parent_object_id = OBJECT_ID(N'[dbo].[MaterialTypeTestProtocol]'))
ALTER TABLE [dbo].[MaterialTypeTestProtocol] CHECK CONSTRAINT [FK_MaterialTypeTestProtocol_MaterialType]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_MaterialTypeTestProtocol_TestProtocol]') AND parent_object_id = OBJECT_ID(N'[dbo].[MaterialTypeTestProtocol]'))
ALTER TABLE [dbo].[MaterialTypeTestProtocol]  WITH CHECK ADD  CONSTRAINT [FK_MaterialTypeTestProtocol_TestProtocol] FOREIGN KEY([TestProtocolID])
REFERENCES [dbo].[TestProtocol] ([TestProtocolID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_MaterialTypeTestProtocol_TestProtocol]') AND parent_object_id = OBJECT_ID(N'[dbo].[MaterialTypeTestProtocol]'))
ALTER TABLE [dbo].[MaterialTypeTestProtocol] CHECK CONSTRAINT [FK_MaterialTypeTestProtocol_TestProtocol]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Plate_Test]') AND parent_object_id = OBJECT_ID(N'[dbo].[Plate]'))
ALTER TABLE [dbo].[Plate]  WITH CHECK ADD  CONSTRAINT [FK_Plate_Test] FOREIGN KEY([TestID])
REFERENCES [dbo].[Test] ([TestID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Plate_Test]') AND parent_object_id = OBJECT_ID(N'[dbo].[Plate]'))
ALTER TABLE [dbo].[Plate] CHECK CONSTRAINT [FK_Plate_Test]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_RelationTraitDetermination_Determination]') AND parent_object_id = OBJECT_ID(N'[dbo].[RelationTraitDetermination]'))
ALTER TABLE [dbo].[RelationTraitDetermination]  WITH CHECK ADD  CONSTRAINT [FK_RelationTraitDetermination_Determination] FOREIGN KEY([DeterminationID])
REFERENCES [dbo].[Determination] ([DeterminationID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_RelationTraitDetermination_Determination]') AND parent_object_id = OBJECT_ID(N'[dbo].[RelationTraitDetermination]'))
ALTER TABLE [dbo].[RelationTraitDetermination] CHECK CONSTRAINT [FK_RelationTraitDetermination_Determination]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ReservedCapacity_Slot]') AND parent_object_id = OBJECT_ID(N'[dbo].[ReservedCapacity]'))
ALTER TABLE [dbo].[ReservedCapacity]  WITH CHECK ADD  CONSTRAINT [FK_ReservedCapacity_Slot] FOREIGN KEY([SlotID])
REFERENCES [dbo].[Slot] ([SlotID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ReservedCapacity_Slot]') AND parent_object_id = OBJECT_ID(N'[dbo].[ReservedCapacity]'))
ALTER TABLE [dbo].[ReservedCapacity] CHECK CONSTRAINT [FK_ReservedCapacity_Slot]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ReservedCapacity_TestProtocol]') AND parent_object_id = OBJECT_ID(N'[dbo].[ReservedCapacity]'))
ALTER TABLE [dbo].[ReservedCapacity]  WITH CHECK ADD  CONSTRAINT [FK_ReservedCapacity_TestProtocol] FOREIGN KEY([TestProtocolID])
REFERENCES [dbo].[TestProtocol] ([TestProtocolID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ReservedCapacity_TestProtocol]') AND parent_object_id = OBJECT_ID(N'[dbo].[ReservedCapacity]'))
ALTER TABLE [dbo].[ReservedCapacity] CHECK CONSTRAINT [FK_ReservedCapacity_TestProtocol]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Row_File]') AND parent_object_id = OBJECT_ID(N'[dbo].[Row]'))
ALTER TABLE [dbo].[Row]  WITH CHECK ADD  CONSTRAINT [FK_Row_File] FOREIGN KEY([FileID])
REFERENCES [dbo].[File] ([FileID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Row_File]') AND parent_object_id = OBJECT_ID(N'[dbo].[Row]'))
ALTER TABLE [dbo].[Row] CHECK CONSTRAINT [FK_Row_File]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Slot_MaterialState]') AND parent_object_id = OBJECT_ID(N'[dbo].[Slot]'))
ALTER TABLE [dbo].[Slot]  WITH CHECK ADD  CONSTRAINT [FK_Slot_MaterialState] FOREIGN KEY([MaterialStateID])
REFERENCES [dbo].[MaterialState] ([MaterialStateID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Slot_MaterialState]') AND parent_object_id = OBJECT_ID(N'[dbo].[Slot]'))
ALTER TABLE [dbo].[Slot] CHECK CONSTRAINT [FK_Slot_MaterialState]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Slot_MaterialType]') AND parent_object_id = OBJECT_ID(N'[dbo].[Slot]'))
ALTER TABLE [dbo].[Slot]  WITH CHECK ADD  CONSTRAINT [FK_Slot_MaterialType] FOREIGN KEY([MaterialTypeID])
REFERENCES [dbo].[MaterialType] ([MaterialTypeID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Slot_MaterialType]') AND parent_object_id = OBJECT_ID(N'[dbo].[Slot]'))
ALTER TABLE [dbo].[Slot] CHECK CONSTRAINT [FK_Slot_MaterialType]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Slot_Period]') AND parent_object_id = OBJECT_ID(N'[dbo].[Slot]'))
ALTER TABLE [dbo].[Slot]  WITH CHECK ADD  CONSTRAINT [FK_Slot_Period] FOREIGN KEY([PeriodID])
REFERENCES [dbo].[Period] ([PeriodID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Slot_Period]') AND parent_object_id = OBJECT_ID(N'[dbo].[Slot]'))
ALTER TABLE [dbo].[Slot] CHECK CONSTRAINT [FK_Slot_Period]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_SlotTest_Slot]') AND parent_object_id = OBJECT_ID(N'[dbo].[SlotTest]'))
ALTER TABLE [dbo].[SlotTest]  WITH CHECK ADD  CONSTRAINT [FK_SlotTest_Slot] FOREIGN KEY([SlotID])
REFERENCES [dbo].[Slot] ([SlotID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_SlotTest_Slot]') AND parent_object_id = OBJECT_ID(N'[dbo].[SlotTest]'))
ALTER TABLE [dbo].[SlotTest] CHECK CONSTRAINT [FK_SlotTest_Slot]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_SlotTest_Test]') AND parent_object_id = OBJECT_ID(N'[dbo].[SlotTest]'))
ALTER TABLE [dbo].[SlotTest]  WITH CHECK ADD  CONSTRAINT [FK_SlotTest_Test] FOREIGN KEY([TestID])
REFERENCES [dbo].[Test] ([TestID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_SlotTest_Test]') AND parent_object_id = OBJECT_ID(N'[dbo].[SlotTest]'))
ALTER TABLE [dbo].[SlotTest] CHECK CONSTRAINT [FK_SlotTest_Test]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Test_ContainerType]') AND parent_object_id = OBJECT_ID(N'[dbo].[Test]'))
ALTER TABLE [dbo].[Test]  WITH CHECK ADD  CONSTRAINT [FK_Test_ContainerType] FOREIGN KEY([ContainerTypeID])
REFERENCES [dbo].[ContainerType] ([ContainerTypeID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Test_ContainerType]') AND parent_object_id = OBJECT_ID(N'[dbo].[Test]'))
ALTER TABLE [dbo].[Test] CHECK CONSTRAINT [FK_Test_ContainerType]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Test_File]') AND parent_object_id = OBJECT_ID(N'[dbo].[Test]'))
ALTER TABLE [dbo].[Test]  WITH CHECK ADD  CONSTRAINT [FK_Test_File] FOREIGN KEY([FileID])
REFERENCES [dbo].[File] ([FileID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Test_File]') AND parent_object_id = OBJECT_ID(N'[dbo].[Test]'))
ALTER TABLE [dbo].[Test] CHECK CONSTRAINT [FK_Test_File]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Test_MaterialState]') AND parent_object_id = OBJECT_ID(N'[dbo].[Test]'))
ALTER TABLE [dbo].[Test]  WITH CHECK ADD  CONSTRAINT [FK_Test_MaterialState] FOREIGN KEY([MaterialStateID])
REFERENCES [dbo].[MaterialState] ([MaterialStateID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Test_MaterialState]') AND parent_object_id = OBJECT_ID(N'[dbo].[Test]'))
ALTER TABLE [dbo].[Test] CHECK CONSTRAINT [FK_Test_MaterialState]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Test_MaterialType]') AND parent_object_id = OBJECT_ID(N'[dbo].[Test]'))
ALTER TABLE [dbo].[Test]  WITH CHECK ADD  CONSTRAINT [FK_Test_MaterialType] FOREIGN KEY([MaterialTypeID])
REFERENCES [dbo].[MaterialType] ([MaterialTypeID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Test_MaterialType]') AND parent_object_id = OBJECT_ID(N'[dbo].[Test]'))
ALTER TABLE [dbo].[Test] CHECK CONSTRAINT [FK_Test_MaterialType]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Test_TestProtocol]') AND parent_object_id = OBJECT_ID(N'[dbo].[Test]'))
ALTER TABLE [dbo].[Test]  WITH CHECK ADD  CONSTRAINT [FK_Test_TestProtocol] FOREIGN KEY([TestProtocolID])
REFERENCES [dbo].[TestProtocol] ([TestProtocolID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Test_TestProtocol]') AND parent_object_id = OBJECT_ID(N'[dbo].[Test]'))
ALTER TABLE [dbo].[Test] CHECK CONSTRAINT [FK_Test_TestProtocol]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Test_TestType]') AND parent_object_id = OBJECT_ID(N'[dbo].[Test]'))
ALTER TABLE [dbo].[Test]  WITH CHECK ADD  CONSTRAINT [FK_Test_TestType] FOREIGN KEY([TestTypeID])
REFERENCES [dbo].[TestType] ([TestTypeID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Test_TestType]') AND parent_object_id = OBJECT_ID(N'[dbo].[Test]'))
ALTER TABLE [dbo].[Test] CHECK CONSTRAINT [FK_Test_TestType]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TestMaterialDetermination_Determination]') AND parent_object_id = OBJECT_ID(N'[dbo].[TestMaterialDetermination]'))
ALTER TABLE [dbo].[TestMaterialDetermination]  WITH CHECK ADD  CONSTRAINT [FK_TestMaterialDetermination_Determination] FOREIGN KEY([DeterminationID])
REFERENCES [dbo].[Determination] ([DeterminationID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TestMaterialDetermination_Determination]') AND parent_object_id = OBJECT_ID(N'[dbo].[TestMaterialDetermination]'))
ALTER TABLE [dbo].[TestMaterialDetermination] CHECK CONSTRAINT [FK_TestMaterialDetermination_Determination]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TestMaterialDetermination_Material]') AND parent_object_id = OBJECT_ID(N'[dbo].[TestMaterialDetermination]'))
ALTER TABLE [dbo].[TestMaterialDetermination]  WITH CHECK ADD  CONSTRAINT [FK_TestMaterialDetermination_Material] FOREIGN KEY([MaterialID])
REFERENCES [dbo].[Material] ([MaterialID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TestMaterialDetermination_Material]') AND parent_object_id = OBJECT_ID(N'[dbo].[TestMaterialDetermination]'))
ALTER TABLE [dbo].[TestMaterialDetermination] CHECK CONSTRAINT [FK_TestMaterialDetermination_Material]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TestMaterialDetermination_Test]') AND parent_object_id = OBJECT_ID(N'[dbo].[TestMaterialDetermination]'))
ALTER TABLE [dbo].[TestMaterialDetermination]  WITH CHECK ADD  CONSTRAINT [FK_TestMaterialDetermination_Test] FOREIGN KEY([TestID])
REFERENCES [dbo].[Test] ([TestID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TestMaterialDetermination_Test]') AND parent_object_id = OBJECT_ID(N'[dbo].[TestMaterialDetermination]'))
ALTER TABLE [dbo].[TestMaterialDetermination] CHECK CONSTRAINT [FK_TestMaterialDetermination_Test]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TestMaterialDeterminationWell_Material]') AND parent_object_id = OBJECT_ID(N'[dbo].[TestMaterialDeterminationWell]'))
ALTER TABLE [dbo].[TestMaterialDeterminationWell]  WITH CHECK ADD  CONSTRAINT [FK_TestMaterialDeterminationWell_Material] FOREIGN KEY([MaterialID])
REFERENCES [dbo].[Material] ([MaterialID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TestMaterialDeterminationWell_Material]') AND parent_object_id = OBJECT_ID(N'[dbo].[TestMaterialDeterminationWell]'))
ALTER TABLE [dbo].[TestMaterialDeterminationWell] CHECK CONSTRAINT [FK_TestMaterialDeterminationWell_Material]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TestMaterialDeterminationWell_Well]') AND parent_object_id = OBJECT_ID(N'[dbo].[TestMaterialDeterminationWell]'))
ALTER TABLE [dbo].[TestMaterialDeterminationWell]  WITH CHECK ADD  CONSTRAINT [FK_TestMaterialDeterminationWell_Well] FOREIGN KEY([WellID])
REFERENCES [dbo].[Well] ([WellID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TestMaterialDeterminationWell_Well]') AND parent_object_id = OBJECT_ID(N'[dbo].[TestMaterialDeterminationWell]'))
ALTER TABLE [dbo].[TestMaterialDeterminationWell] CHECK CONSTRAINT [FK_TestMaterialDeterminationWell_Well]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TestProtocol_TestType]') AND parent_object_id = OBJECT_ID(N'[dbo].[TestProtocol]'))
ALTER TABLE [dbo].[TestProtocol]  WITH CHECK ADD  CONSTRAINT [FK_TestProtocol_TestType] FOREIGN KEY([TestTypeID])
REFERENCES [dbo].[TestType] ([TestTypeID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TestProtocol_TestType]') AND parent_object_id = OBJECT_ID(N'[dbo].[TestProtocol]'))
ALTER TABLE [dbo].[TestProtocol] CHECK CONSTRAINT [FK_TestProtocol_TestType]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TestResult_Determination]') AND parent_object_id = OBJECT_ID(N'[dbo].[TestResult]'))
ALTER TABLE [dbo].[TestResult]  WITH CHECK ADD  CONSTRAINT [FK_TestResult_Determination] FOREIGN KEY([DeterminationID])
REFERENCES [dbo].[Determination] ([DeterminationID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TestResult_Determination]') AND parent_object_id = OBJECT_ID(N'[dbo].[TestResult]'))
ALTER TABLE [dbo].[TestResult] CHECK CONSTRAINT [FK_TestResult_Determination]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TestResult_Well]') AND parent_object_id = OBJECT_ID(N'[dbo].[TestResult]'))
ALTER TABLE [dbo].[TestResult]  WITH CHECK ADD  CONSTRAINT [FK_TestResult_Well] FOREIGN KEY([WellID])
REFERENCES [dbo].[Well] ([WellID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TestResult_Well]') AND parent_object_id = OBJECT_ID(N'[dbo].[TestResult]'))
ALTER TABLE [dbo].[TestResult] CHECK CONSTRAINT [FK_TestResult_Well]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TestType_PlateType1]') AND parent_object_id = OBJECT_ID(N'[dbo].[TestType]'))
ALTER TABLE [dbo].[TestType]  WITH CHECK ADD  CONSTRAINT [FK_TestType_PlateType1] FOREIGN KEY([PlateTypeID])
REFERENCES [dbo].[PlateType] ([PlateTypeID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TestType_PlateType1]') AND parent_object_id = OBJECT_ID(N'[dbo].[TestType]'))
ALTER TABLE [dbo].[TestType] CHECK CONSTRAINT [FK_TestType_PlateType1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Well_Plate]') AND parent_object_id = OBJECT_ID(N'[dbo].[Well]'))
ALTER TABLE [dbo].[Well]  WITH CHECK ADD  CONSTRAINT [FK_Well_Plate] FOREIGN KEY([PlateID])
REFERENCES [dbo].[Plate] ([PlateID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Well_Plate]') AND parent_object_id = OBJECT_ID(N'[dbo].[Well]'))
ALTER TABLE [dbo].[Well] CHECK CONSTRAINT [FK_Well_Plate]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Well_WellType]') AND parent_object_id = OBJECT_ID(N'[dbo].[Well]'))
ALTER TABLE [dbo].[Well]  WITH CHECK ADD  CONSTRAINT [FK_Well_WellType] FOREIGN KEY([WellTypeID])
REFERENCES [dbo].[WellType] ([WellTypeID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Well_WellType]') AND parent_object_id = OBJECT_ID(N'[dbo].[Well]'))
ALTER TABLE [dbo].[Well] CHECK CONSTRAINT [FK_Well_WellType]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_WellTypePosition_TestType]') AND parent_object_id = OBJECT_ID(N'[dbo].[WellTypePosition]'))
ALTER TABLE [dbo].[WellTypePosition]  WITH CHECK ADD  CONSTRAINT [FK_WellTypePosition_TestType] FOREIGN KEY([TestTypeID])
REFERENCES [dbo].[TestType] ([TestTypeID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_WellTypePosition_TestType]') AND parent_object_id = OBJECT_ID(N'[dbo].[WellTypePosition]'))
ALTER TABLE [dbo].[WellTypePosition] CHECK CONSTRAINT [FK_WellTypePosition_TestType]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_WellTypePosition_WellType]') AND parent_object_id = OBJECT_ID(N'[dbo].[WellTypePosition]'))
ALTER TABLE [dbo].[WellTypePosition]  WITH CHECK ADD  CONSTRAINT [FK_WellTypePosition_WellType] FOREIGN KEY([WellTypeID])
REFERENCES [dbo].[WellType] ([WellTypeID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_WellTypePosition_WellType]') AND parent_object_id = OBJECT_ID(N'[dbo].[WellTypePosition]'))
ALTER TABLE [dbo].[WellTypePosition] CHECK CONSTRAINT [FK_WellTypePosition_WellType]
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'Row', N'COLUMN',N'MaterialKey'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PlantNr from excel file' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Row', @level2type=N'COLUMN',@level2name=N'MaterialKey'
GO
