DROP TABLE IF EXISTS [dbo].[S2SCapacitySlot]
GO

CREATE TABLE [dbo].[S2SCapacitySlot](
	[CapacitySlotID] [int] PRIMARY KEY NOT NULL,
	[MaxPlants] [int] NULL,
	[CordysStatus] [nvarchar](20) NULL,
	[DH0Location] [nvarchar](100) NULL,
	[AvailPlants] [int] NULL
)
GO


ALTER TABLE Test
ADD CapacitySlotID INT
GO

