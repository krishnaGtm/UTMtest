DELETE FROM [EmailConfig]
GO

--SEED DEFAULT GROUPS
INSERT [dbo].[EmailConfig] ([ConfigGroup], [CropCode], [Recipients]) VALUES (N'SEND_RESULT_MAPPING_MISSING', N'TO', NULL)
GO
INSERT [dbo].[EmailConfig] ([ConfigGroup], [CropCode], [Recipients]) VALUES (N'EXE_ERROR', N'*', NULL)
GO
INSERT [dbo].[EmailConfig] ([ConfigGroup], [CropCode], [Recipients]) VALUES (N'DEFAULT_EMAIL_GROUP', '*', N'bassupport@enzazaden.nl')
GO