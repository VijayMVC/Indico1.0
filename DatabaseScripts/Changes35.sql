USE [Indico]
GO

UPDATE [dbo].[OrderStatus] SET [Name] = 'New' WHERE [Name] = 'Not Started'
GO