USE [Indico]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_VisualLayoutAccessory_Accessory]') AND parent_object_id = OBJECT_ID(N'[dbo].[VisualLayoutAccessory]'))
ALTER TABLE [dbo].[VisualLayoutAccessory] DROP CONSTRAINT [FK_VisualLayoutAccessory_Accessory]
GO


ALTER TABLE [dbo].[VisualLayoutAccessory]  WITH CHECK ADD  CONSTRAINT [FK_VisualLayoutAccessory_Accessory] FOREIGN KEY([Accessory])
REFERENCES [dbo].[Accessory] ([ID])
GO

ALTER TABLE [dbo].[VisualLayoutAccessory] CHECK CONSTRAINT [FK_VisualLayoutAccessory_Accessory]
GO
