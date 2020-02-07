
DROP INDEX IF EXISTS [IX_Cell_ColumnID_RowID_Value] ON [dbo].[Cell]
GO

DROP INDEX IF EXISTS [IX_Cell_RowID_ColumnID_Value] ON [dbo].[Cell]
GO

DROP INDEX IF EXISTS [IX_Cell_WIth_value] ON [dbo].[Cell]
GO

DROP INDEX IF EXISTS [IX_Row_Column] ON [dbo].[Cell]
GO

DROP INDEX IF EXISTS [IX_ColID_RowID_WithValue] ON [dbo].[Cell]
GO

CREATE NONCLUSTERED INDEX [IX_ColID_RowID_WithValue] ON [dbo].[Cell]
(
	[ColumnID] ASC,
	[RowID] ASC
)
INCLUDE ([Value]) 
GO