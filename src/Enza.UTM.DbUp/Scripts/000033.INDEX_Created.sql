
DROP INDEX IF EXISTS [IX_Row_RowID_RowNr_MaterialKey] ON [dbo].[Row]
GO

SET ANSI_PADDING ON
GO

/***** Object:  Index [IX_Row_RowID_RowNr_MaterialKey]    Script Date: 6/20/2018 4:15:36 PM *****/
CREATE NONCLUSTERED INDEX [IX_Row_RowID_RowNr_MaterialKey] ON [dbo].[Row]
(
 [RowID] ASC
)
INCLUDE (FileID) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO