USE [Indico]
GO

ALTER TABLE [dbo].[OrderDetail]
	ADD PaymentMethod [int] NULL,
        ShipmentMode [int] NULL,
		IsWeeklyShipment [bit] NULL,
		IsCourierDelivery [bit] NULL,
		DespatchTo [int] NULL

ALTER TABLE [dbo].[OrderDetail]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetail_PaymentMethod] FOREIGN KEY([PaymentMethod])
REFERENCES [dbo].[PaymentMethod] ([ID])
GO

ALTER TABLE [dbo].[OrderDetail] CHECK CONSTRAINT [FK_OrderDetail_PaymentMethod]
GO

ALTER TABLE [dbo].[OrderDetail]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetail_ShipmentMode] FOREIGN KEY([ShipmentMode])
REFERENCES [dbo].[ShipmentMode] ([ID])
GO

ALTER TABLE [dbo].[OrderDetail] CHECK CONSTRAINT [FK_OrderDetail_ShipmentMode]
GO

ALTER TABLE [dbo].[OrderDetail]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetail_DespatchTo] FOREIGN KEY([DespatchTo])
REFERENCES [dbo].[Company] ([ID])
GO

ALTER TABLE [dbo].[OrderDetail] CHECK CONSTRAINT [FK_OrderDetail_DespatchTo]
GO

-- correction for [FK_OrderDetail_DespatchTo] key -------------

ALTER TABLE [dbo].[OrderDetail] DROP CONSTRAINT [FK_OrderDetail_DespatchTo]
GO

ALTER TABLE [dbo].[OrderDetail]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetail_DespatchTo] FOREIGN KEY([DespatchTo])
REFERENCES [dbo].[DistributorClientAddress] ([ID])
GO

ALTER TABLE [dbo].[OrderDetail] CHECK CONSTRAINT [FK_OrderDetail_DespatchTo]
GO