SET IDENTITY_INSERT [dbo].[PlateType] ON 
GO
INSERT [dbo].[PlateType] ([PlateTypeID], [PlateTypeName], [StartRow], [EndRow], [StartColumn], [EndColumn]) VALUES (1, N'2GB', N'A', N'H', 1, 12)
GO
SET IDENTITY_INSERT [dbo].[PlateType] OFF
GO
INSERT [dbo].[TestType] ([TestTypeID], [TestTypeCode], [TestTypeName], [Status], [DeterminationRequired], [RemarkRequired], [PlateTypeID]) VALUES (1, N'MT', N'Marker/2GB Test', N'A1', 1, 0, 1)
GO
INSERT [dbo].[TestType] ([TestTypeID], [TestTypeCode], [TestTypeName], [Status], [DeterminationRequired], [RemarkRequired], [PlateTypeID]) VALUES (2, N'DI', N'DNA Isolation', N'A2', 0, 1, 1)
GO
SET IDENTITY_INSERT [dbo].[TestProtocol] ON 
GO
INSERT [dbo].[TestProtocol] ([TestProtocolID], [TestTypeID], [TestProtocolName], [Isolated]) VALUES (1, 2, N'CTAB', 0)
GO
INSERT [dbo].[TestProtocol] ([TestProtocolID], [TestTypeID], [TestProtocolName], [Isolated]) VALUES (2, 2, N'Beads', 0)
GO
INSERT [dbo].[TestProtocol] ([TestProtocolID], [TestTypeID], [TestProtocolName], [Isolated]) VALUES (3, 2, N'A+B', 0)
GO
INSERT [dbo].[TestProtocol] ([TestProtocolID], [TestTypeID], [TestProtocolName], [Isolated]) VALUES (4, 2, N'TE', 1)
GO
INSERT [dbo].[TestProtocol] ([TestProtocolID], [TestTypeID], [TestProtocolName], [Isolated]) VALUES (5, 1, N'2 GB Markers', 0)
GO
SET IDENTITY_INSERT [dbo].[TestProtocol] OFF
GO
SET IDENTITY_INSERT [dbo].[WellType] ON 
GO
INSERT [dbo].[WellType] ([WellTypeID], [WellTypeName], [BGColor], [FGColor], [WellTypeDescription]) VALUES (1, N'E', N'#ff5454', N'#fff', N'Empty')
GO
INSERT [dbo].[WellType] ([WellTypeID], [WellTypeName], [BGColor], [FGColor], [WellTypeDescription]) VALUES (2, N'B', N'#c5c5c5', N'#000', N'Blocked')
GO
INSERT [dbo].[WellType] ([WellTypeID], [WellTypeName], [BGColor], [FGColor], [WellTypeDescription]) VALUES (3, N'F', N'#03A9F4', N'#fff', N'Fixed')
GO
INSERT [dbo].[WellType] ([WellTypeID], [WellTypeName], [BGColor], [FGColor], [WellTypeDescription]) VALUES (4, N'D', N'#ff5454', N'#fff', N'Dead')
GO
INSERT [dbo].[WellType] ([WellTypeID], [WellTypeName], [BGColor], [FGColor], [WellTypeDescription]) VALUES (5, N'A', N'#fff', N'#000', N'Assigned')
GO
SET IDENTITY_INSERT [dbo].[WellType] OFF
GO
SET IDENTITY_INSERT [dbo].[WellTypePosition] ON 
GO
INSERT [dbo].[WellTypePosition] ([WellTypePositionID], [WellTypeID], [TestTypeID], [PositionOnPlate], [PlateInTest]) VALUES (52, 2, 1, N'B01', 1)
GO
INSERT [dbo].[WellTypePosition] ([WellTypePositionID], [WellTypeID], [TestTypeID], [PositionOnPlate], [PlateInTest]) VALUES (55, 2, 1, N'D01', 1)
GO
INSERT [dbo].[WellTypePosition] ([WellTypePositionID], [WellTypeID], [TestTypeID], [PositionOnPlate], [PlateInTest]) VALUES (56, 2, 1, N'F01', 1)
GO
INSERT [dbo].[WellTypePosition] ([WellTypePositionID], [WellTypeID], [TestTypeID], [PositionOnPlate], [PlateInTest]) VALUES (57, 2, 1, N'H01', 3)
GO
SET IDENTITY_INSERT [dbo].[WellTypePosition] OFF
GO
INSERT [dbo].[Status] ([StatusID], [StatusTable], [StatusCode], [StatusName], [StatusDescription]) VALUES (1, N'Test', 100, N'Created', N'Test gets status Created')
GO
INSERT [dbo].[Status] ([StatusID], [StatusTable], [StatusCode], [StatusName], [StatusDescription]) VALUES (2, N'Test', 200, N'Requested', N'Call to WS to create the plateplan')
GO
INSERT [dbo].[Status] ([StatusID], [StatusTable], [StatusCode], [StatusName], [StatusDescription]) VALUES (3, N'Test', 300, N'Reserved', N'plateplan is being reserved and the plates are being created in StarLIMS. STarLIMS gives back DTC the plateplan/plates ID''s and names. If there is a failure in this WS, user should be able to press this button again')
GO
INSERT [dbo].[Status] ([StatusID], [StatusTable], [StatusCode], [StatusName], [StatusDescription]) VALUES (4, N'Test', 400, N'Confirmed', N'Point of no return.  May not be sent more than once. Must be inactive after being pressed once. Status allways go to 300 when clicked once')
GO
INSERT [dbo].[Status] ([StatusID], [StatusTable], [StatusCode], [StatusName], [StatusDescription]) VALUES (5, N'Test', 500, N'InLIMS', N'Send to LIMS')
GO
INSERT [dbo].[Status] ([StatusID], [StatusTable], [StatusCode], [StatusName], [StatusDescription]) VALUES (6, N'Test', 600, N'Received', N'Synced with LIMS')
GO
INSERT [dbo].[Status] ([StatusID], [StatusTable], [StatusCode], [StatusName], [StatusDescription]) VALUES (7, N'Test', 700, N'Completed', N'Completed')
GO
INSERT [dbo].[Status] ([StatusID], [StatusTable], [StatusCode], [StatusName], [StatusDescription]) VALUES (8, N'Material', 100, N'Created', N'Material Created')
GO
INSERT [dbo].[Status] ([StatusID], [StatusTable], [StatusCode], [StatusName], [StatusDescription]) VALUES (9, N'Material', 200, N'Dead', N'Material Dead')
GO
INSERT [dbo].[Status] ([StatusID], [StatusTable], [StatusCode], [StatusName], [StatusDescription]) VALUES (10, N'Slot', 100, N'Requested', N'Requested')
GO
INSERT [dbo].[Status] ([StatusID], [StatusTable], [StatusCode], [StatusName], [StatusDescription]) VALUES (11, N'Slot', 200, N'Approved', N'Approved')
GO
INSERT [dbo].[Status] ([StatusID], [StatusTable], [StatusCode], [StatusName], [StatusDescription]) VALUES (12, N'Slot', 300, N'Denied', N'Denied')
GO
INSERT [dbo].[Status] ([StatusID], [StatusTable], [StatusCode], [StatusName], [StatusDescription]) VALUES (13, N'Slot', 400, N'Cancelled', N'Cancelled')
GO
INSERT [dbo].[Status] ([StatusID], [StatusTable], [StatusCode], [StatusName], [StatusDescription]) VALUES (14, N'Test', 150, N'SlotAssigned', N'Slot Assigned')
GO
INSERT [dbo].[Status] ([StatusID], [StatusTable], [StatusCode], [StatusName], [StatusDescription]) VALUES (15, N'Test', 350, N'SlotUpdated', N'Slot Updated')
GO
