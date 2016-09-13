USE [Indico]
GO

SP_RENAME '[dbo].[InvoiceOrder].[Order]', 'OrderDetail'
GO

ALTER TABLE [dbo].[InvoiceOrder]
DROP CONSTRAINT [FK_InvoiceOrder_Order]
GO

ALTER TABLE [dbo].[InvoiceOrder]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceOrder_OrderDetail] FOREIGN KEY([OrderDetail])
REFERENCES [dbo].[OrderDetail] ([ID])
GO

ALTER TABLE [dbo].[InvoiceOrder] CHECK CONSTRAINT [FK_InvoiceOrder_OrderDetail]
GO

--BEGIN TRAN

--DELETE FROM [dbo].[InvoiceOrder]
--FROM [dbo].[InvoiceOrder] ino
--	JOIN [dbo].[Invoice] i
--		ON ino.[Invoice] = i.[ID]

--DELETE FROM [dbo].[Invoice]

--ROLLBACK TRAN