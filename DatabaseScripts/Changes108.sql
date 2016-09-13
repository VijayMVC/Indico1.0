USE [Indico]
GO

DELETE FROM [dbo].[InvoiceOrder] WHERE [Invoice] = (SELECT [ID] FROM [dbo].[Invoice] WHERE [InvoiceNo] = '358/IM/14')
GO

DELETE FROM [dbo].[Invoice] WHERE [InvoiceNo] = '358/IM/14'
GO