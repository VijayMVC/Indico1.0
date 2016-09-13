USE [Indico]
GO

ALTER TABLE [dbo].[PriceLevelCost]
ADD [Creator] [int] NULL
GO

ALTER TABLE [dbo].[PriceLevelCost]
ADD [CreatedDate] [datetime2] (7) NULL
GO

ALTER TABLE [dbo].[PriceLevelCost]  WITH CHECK ADD  CONSTRAINT [FK_PriceLevelCost_Creator] FOREIGN KEY([Creator])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[PriceLevelCost] CHECK CONSTRAINT [FK_PriceLevelCost_Creator]
GO


ALTER TABLE [dbo].[PriceLevelCost]
ADD [Modifier] [int] NULL
GO

ALTER TABLE [dbo].[PriceLevelCost]
ADD [ModifiedDate] [datetime2] (7) NULL
GO

ALTER TABLE [dbo].[PriceLevelCost]  WITH CHECK ADD  CONSTRAINT [FK_PriceLevelCost_Modifier] FOREIGN KEY([Modifier])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[PriceLevelCost] CHECK CONSTRAINT [FK_PriceLevelCost_Modifier]
GO


UPDATE [dbo].[PriceLevelCost] SET [Creator] = 1


UPDATE [dbo].[PriceLevelCost] SET [CreatedDate] = GETDATE()


UPDATE [dbo].[PriceLevelCost] SET [Modifier] = 1


UPDATE [dbo].[PriceLevelCost] SET [ModifiedDate] = GETDATE()



ALTER TABLE [dbo].[PriceLevelCost]
ALTER COLUMN [Creator] [int] NOT NULL
GO

ALTER TABLE [dbo].[PriceLevelCost]
ALTER COLUMN [CreatedDate] [datetime2] (7) NOT NULL
GO

ALTER TABLE [dbo].[PriceLevelCost]
ALTER COLUMN [Modifier] [int] NOT NULL
GO

ALTER TABLE [dbo].[PriceLevelCost]
ALTER COLUMN [ModifiedDate] [datetime2] (7) NOT NULL
GO

