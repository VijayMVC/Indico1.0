USE [Indico]
GO
IF  EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF__Distribut__Indic__095F58DF]') AND parent_object_id = OBJECT_ID(N'[dbo].[DistributorPriceLevelCost]'))
Begin
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__Distribut__Indic__095F58DF]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DistributorPriceLevelCost] DROP CONSTRAINT [DF__Distribut__Indic__095F58DF]
END


End
GO
IF  EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF__Distribut__Indic__0C3BC58A]') AND parent_object_id = OBJECT_ID(N'[dbo].[DistributorPriceLevelCostHistory]'))
Begin
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__Distribut__Indic__0C3BC58A]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DistributorPriceLevelCostHistory] DROP CONSTRAINT [DF__Distribut__Indic__0C3BC58A]
END


End
GO
IF  EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF__Pattern__Convert__69E6AD86]') AND parent_object_id = OBJECT_ID(N'[dbo].[Pattern]'))
Begin
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__Pattern__Convert__69E6AD86]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Pattern] DROP CONSTRAINT [DF__Pattern__Convert__69E6AD86]
END


End
GO
IF  EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF_Pattern_IsTemplate]') AND parent_object_id = OBJECT_ID(N'[dbo].[Pattern]'))
Begin
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_Pattern_IsTemplate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Pattern] DROP CONSTRAINT [DF_Pattern_IsTemplate]
END


End
GO
IF  EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF_PriceLevelCost_FactoryCost]') AND parent_object_id = OBJECT_ID(N'[dbo].[PriceLevelCost]'))
Begin
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_PriceLevelCost_FactoryCost]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[PriceLevelCost] DROP CONSTRAINT [DF_PriceLevelCost_FactoryCost]
END


End
GO
IF  EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF_PriceLevelCost_IndimanCost]') AND parent_object_id = OBJECT_ID(N'[dbo].[PriceLevelCost]'))
Begin
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_PriceLevelCost_IndimanCost]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[PriceLevelCost] DROP CONSTRAINT [DF_PriceLevelCost_IndimanCost]
END


End
GO
IF  EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF__Reservation__Qty__6521F869]') AND parent_object_id = OBJECT_ID(N'[dbo].[Reservation]'))
Begin
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__Reservation__Qty__6521F869]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Reservation] DROP CONSTRAINT [DF__Reservation__Qty__6521F869]
END


End
GO
IF  EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF__SizeChart__Val__222B06A9]') AND parent_object_id = OBJECT_ID(N'[dbo].[SizeChart]'))
Begin
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__SizeChart__Val__222B06A9]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[SizeChart] DROP CONSTRAINT [DF__SizeChart__Val__222B06A9]
END


End
GO
IF  EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF__WeeklyPro__Capac__32616E72]') AND parent_object_id = OBJECT_ID(N'[dbo].[WeeklyProductionCapacity]'))
Begin
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__WeeklyPro__Capac__32616E72]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WeeklyProductionCapacity] DROP CONSTRAINT [DF__WeeklyPro__Capac__32616E72]
END


End
GO
IF  EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF__WeeklyPro__NoOfH__335592AB]') AND parent_object_id = OBJECT_ID(N'[dbo].[WeeklyProductionCapacity]'))
Begin
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__WeeklyPro__NoOfH__335592AB]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WeeklyProductionCapacity] DROP CONSTRAINT [DF__WeeklyPro__NoOfH__335592AB]
END


End
GO
/****** Object:  ForeignKey [FK_AccessoryCategory_Accessory]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_AccessoryCategory_Accessory]') AND parent_object_id = OBJECT_ID(N'[dbo].[AccessoryCategory]'))
ALTER TABLE [dbo].[AccessoryCategory] DROP CONSTRAINT [FK_AccessoryCategory_Accessory]
GO
/****** Object:  ForeignKey [FK_Client_Creator]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Client_Creator]') AND parent_object_id = OBJECT_ID(N'[dbo].[Client]'))
ALTER TABLE [dbo].[Client] DROP CONSTRAINT [FK_Client_Creator]
GO
/****** Object:  ForeignKey [FK_Client_Distributor]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Client_Distributor]') AND parent_object_id = OBJECT_ID(N'[dbo].[Client]'))
ALTER TABLE [dbo].[Client] DROP CONSTRAINT [FK_Client_Distributor]
GO
/****** Object:  ForeignKey [FK_Client_Modifier]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Client_Modifier]') AND parent_object_id = OBJECT_ID(N'[dbo].[Client]'))
ALTER TABLE [dbo].[Client] DROP CONSTRAINT [FK_Client_Modifier]
GO
/****** Object:  ForeignKey [FK_Client_Type]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Client_Type]') AND parent_object_id = OBJECT_ID(N'[dbo].[Client]'))
ALTER TABLE [dbo].[Client] DROP CONSTRAINT [FK_Client_Type]
GO
/****** Object:  ForeignKey [FK_Company_Coordinator]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Company_Coordinator]') AND parent_object_id = OBJECT_ID(N'[dbo].[Company]'))
ALTER TABLE [dbo].[Company] DROP CONSTRAINT [FK_Company_Coordinator]
GO
/****** Object:  ForeignKey [FK_Company_Country]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Company_Country]') AND parent_object_id = OBJECT_ID(N'[dbo].[Company]'))
ALTER TABLE [dbo].[Company] DROP CONSTRAINT [FK_Company_Country]
GO
/****** Object:  ForeignKey [FK_Company_Creator]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Company_Creator]') AND parent_object_id = OBJECT_ID(N'[dbo].[Company]'))
ALTER TABLE [dbo].[Company] DROP CONSTRAINT [FK_Company_Creator]
GO
/****** Object:  ForeignKey [FK_Company_Modifier]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Company_Modifier]') AND parent_object_id = OBJECT_ID(N'[dbo].[Company]'))
ALTER TABLE [dbo].[Company] DROP CONSTRAINT [FK_Company_Modifier]
GO
/****** Object:  ForeignKey [FK_Company_Owner]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Company_Owner]') AND parent_object_id = OBJECT_ID(N'[dbo].[Company]'))
ALTER TABLE [dbo].[Company] DROP CONSTRAINT [FK_Company_Owner]
GO
/****** Object:  ForeignKey [FK_Company_Type]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Company_Type]') AND parent_object_id = OBJECT_ID(N'[dbo].[Company]'))
ALTER TABLE [dbo].[Company] DROP CONSTRAINT [FK_Company_Type]
GO
/****** Object:  ForeignKey [FK_DistributorLabel_Distributor]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DistributorLabel_Distributor]') AND parent_object_id = OBJECT_ID(N'[dbo].[DistributorLabel]'))
ALTER TABLE [dbo].[DistributorLabel] DROP CONSTRAINT [FK_DistributorLabel_Distributor]
GO
/****** Object:  ForeignKey [FK_DistributorLabel_Label]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DistributorLabel_Label]') AND parent_object_id = OBJECT_ID(N'[dbo].[DistributorLabel]'))
ALTER TABLE [dbo].[DistributorLabel] DROP CONSTRAINT [FK_DistributorLabel_Label]
GO
/****** Object:  ForeignKey [FK_DistributorPriceLevelCost_Distributor]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DistributorPriceLevelCost_Distributor]') AND parent_object_id = OBJECT_ID(N'[dbo].[DistributorPriceLevelCost]'))
ALTER TABLE [dbo].[DistributorPriceLevelCost] DROP CONSTRAINT [FK_DistributorPriceLevelCost_Distributor]
GO
/****** Object:  ForeignKey [FK_DistributorPriceLevelCost_Modifier]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DistributorPriceLevelCost_Modifier]') AND parent_object_id = OBJECT_ID(N'[dbo].[DistributorPriceLevelCost]'))
ALTER TABLE [dbo].[DistributorPriceLevelCost] DROP CONSTRAINT [FK_DistributorPriceLevelCost_Modifier]
GO
/****** Object:  ForeignKey [FK_DistributorPriceLevelCost_PriceLevelCost]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DistributorPriceLevelCost_PriceLevelCost]') AND parent_object_id = OBJECT_ID(N'[dbo].[DistributorPriceLevelCost]'))
ALTER TABLE [dbo].[DistributorPriceLevelCost] DROP CONSTRAINT [FK_DistributorPriceLevelCost_PriceLevelCost]
GO
/****** Object:  ForeignKey [FK_DistributorPriceLevelCost_PriceTerm]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DistributorPriceLevelCost_PriceTerm]') AND parent_object_id = OBJECT_ID(N'[dbo].[DistributorPriceLevelCost]'))
ALTER TABLE [dbo].[DistributorPriceLevelCost] DROP CONSTRAINT [FK_DistributorPriceLevelCost_PriceTerm]
GO
/****** Object:  ForeignKey [FK_DistributorPriceMarkup_Company]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DistributorPriceMarkup_Company]') AND parent_object_id = OBJECT_ID(N'[dbo].[DistributorPriceMarkup]'))
ALTER TABLE [dbo].[DistributorPriceMarkup] DROP CONSTRAINT [FK_DistributorPriceMarkup_Company]
GO
/****** Object:  ForeignKey [FK_DistributorPriceMarkup_PriceLevel]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DistributorPriceMarkup_PriceLevel]') AND parent_object_id = OBJECT_ID(N'[dbo].[DistributorPriceMarkup]'))
ALTER TABLE [dbo].[DistributorPriceMarkup] DROP CONSTRAINT [FK_DistributorPriceMarkup_PriceLevel]
GO
/****** Object:  ForeignKey [FK_FabricCode_Country]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_FabricCode_Country]') AND parent_object_id = OBJECT_ID(N'[dbo].[FabricCode]'))
ALTER TABLE [dbo].[FabricCode] DROP CONSTRAINT [FK_FabricCode_Country]
GO
/****** Object:  ForeignKey [FK_FabricCode_Currency]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_FabricCode_Currency]') AND parent_object_id = OBJECT_ID(N'[dbo].[FabricCode]'))
ALTER TABLE [dbo].[FabricCode] DROP CONSTRAINT [FK_FabricCode_Currency]
GO
/****** Object:  ForeignKey [FK_Image_VisualLayout]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Image_VisualLayout]') AND parent_object_id = OBJECT_ID(N'[dbo].[Image]'))
ALTER TABLE [dbo].[Image] DROP CONSTRAINT [FK_Image_VisualLayout]
GO
/****** Object:  ForeignKey [FK_Invoice_Status]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Invoice_Status]') AND parent_object_id = OBJECT_ID(N'[dbo].[Invoice]'))
ALTER TABLE [dbo].[Invoice] DROP CONSTRAINT [FK_Invoice_Status]
GO
/****** Object:  ForeignKey [FK_InvoiceOrder_Invoice]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_InvoiceOrder_Invoice]') AND parent_object_id = OBJECT_ID(N'[dbo].[InvoiceOrder]'))
ALTER TABLE [dbo].[InvoiceOrder] DROP CONSTRAINT [FK_InvoiceOrder_Invoice]
GO
/****** Object:  ForeignKey [FK_InvoiceOrder_Order]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_InvoiceOrder_Order]') AND parent_object_id = OBJECT_ID(N'[dbo].[InvoiceOrder]'))
ALTER TABLE [dbo].[InvoiceOrder] DROP CONSTRAINT [FK_InvoiceOrder_Order]
GO
/****** Object:  ForeignKey [FK_Item_Parent]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Item_Parent]') AND parent_object_id = OBJECT_ID(N'[dbo].[Item]'))
ALTER TABLE [dbo].[Item] DROP CONSTRAINT [FK_Item_Parent]
GO
/****** Object:  ForeignKey [FK_ItemAttribute_Item]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ItemAttribute_Item]') AND parent_object_id = OBJECT_ID(N'[dbo].[ItemAttribute]'))
ALTER TABLE [dbo].[ItemAttribute] DROP CONSTRAINT [FK_ItemAttribute_Item]
GO
/****** Object:  ForeignKey [FK_ItemAttribute_Parent]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ItemAttribute_Parent]') AND parent_object_id = OBJECT_ID(N'[dbo].[ItemAttribute]'))
ALTER TABLE [dbo].[ItemAttribute] DROP CONSTRAINT [FK_ItemAttribute_Parent]
GO
/****** Object:  ForeignKey [FK_MeasurementLocation_Item]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_MeasurementLocation_Item]') AND parent_object_id = OBJECT_ID(N'[dbo].[MeasurementLocation]'))
ALTER TABLE [dbo].[MeasurementLocation] DROP CONSTRAINT [FK_MeasurementLocation_Item]
GO
/****** Object:  ForeignKey [FK_MenuItem_Page]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_MenuItem_Page]') AND parent_object_id = OBJECT_ID(N'[dbo].[MenuItem]'))
ALTER TABLE [dbo].[MenuItem] DROP CONSTRAINT [FK_MenuItem_Page]
GO
/****** Object:  ForeignKey [FK_MenuItem_Parent]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_MenuItem_Parent]') AND parent_object_id = OBJECT_ID(N'[dbo].[MenuItem]'))
ALTER TABLE [dbo].[MenuItem] DROP CONSTRAINT [FK_MenuItem_Parent]
GO
/****** Object:  ForeignKey [FK_MenuItemRole_MenuItem]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_MenuItemRole_MenuItem]') AND parent_object_id = OBJECT_ID(N'[dbo].[MenuItemRole]'))
ALTER TABLE [dbo].[MenuItemRole] DROP CONSTRAINT [FK_MenuItemRole_MenuItem]
GO
/****** Object:  ForeignKey [FK_MenuItemRole_Role]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_MenuItemRole_Role]') AND parent_object_id = OBJECT_ID(N'[dbo].[MenuItemRole]'))
ALTER TABLE [dbo].[MenuItemRole] DROP CONSTRAINT [FK_MenuItemRole_Role]
GO
/****** Object:  ForeignKey [FK_Order_Client]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Order_Client]') AND parent_object_id = OBJECT_ID(N'[dbo].[Order]'))
ALTER TABLE [dbo].[Order] DROP CONSTRAINT [FK_Order_Client]
GO
/****** Object:  ForeignKey [FK_Order_Creator]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Order_Creator]') AND parent_object_id = OBJECT_ID(N'[dbo].[Order]'))
ALTER TABLE [dbo].[Order] DROP CONSTRAINT [FK_Order_Creator]
GO
/****** Object:  ForeignKey [FK_Order_DeliveryMethod]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Order_DeliveryMethod]') AND parent_object_id = OBJECT_ID(N'[dbo].[Order]'))
ALTER TABLE [dbo].[Order] DROP CONSTRAINT [FK_Order_DeliveryMethod]
GO
/****** Object:  ForeignKey [FK_Order_DestinationPort]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Order_DestinationPort]') AND parent_object_id = OBJECT_ID(N'[dbo].[Order]'))
ALTER TABLE [dbo].[Order] DROP CONSTRAINT [FK_Order_DestinationPort]
GO
/****** Object:  ForeignKey [FK_Order_Distributor]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Order_Distributor]') AND parent_object_id = OBJECT_ID(N'[dbo].[Order]'))
ALTER TABLE [dbo].[Order] DROP CONSTRAINT [FK_Order_Distributor]
GO
/****** Object:  ForeignKey [FK_Order_Invoice]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Order_Invoice]') AND parent_object_id = OBJECT_ID(N'[dbo].[Order]'))
ALTER TABLE [dbo].[Order] DROP CONSTRAINT [FK_Order_Invoice]
GO
/****** Object:  ForeignKey [FK_Order_Modifier]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Order_Modifier]') AND parent_object_id = OBJECT_ID(N'[dbo].[Order]'))
ALTER TABLE [dbo].[Order] DROP CONSTRAINT [FK_Order_Modifier]
GO
/****** Object:  ForeignKey [FK_Order_OrderStatus]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Order_OrderStatus]') AND parent_object_id = OBJECT_ID(N'[dbo].[Order]'))
ALTER TABLE [dbo].[Order] DROP CONSTRAINT [FK_Order_OrderStatus]
GO
/****** Object:  ForeignKey [FK_Order_PaymentMethod]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Order_PaymentMethod]') AND parent_object_id = OBJECT_ID(N'[dbo].[Order]'))
ALTER TABLE [dbo].[Order] DROP CONSTRAINT [FK_Order_PaymentMethod]
GO
/****** Object:  ForeignKey [FK_Order_Printer]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Order_Printer]') AND parent_object_id = OBJECT_ID(N'[dbo].[Order]'))
ALTER TABLE [dbo].[Order] DROP CONSTRAINT [FK_Order_Printer]
GO
/****** Object:  ForeignKey [FK_Order_Reservation]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Order_Reservation]') AND parent_object_id = OBJECT_ID(N'[dbo].[Order]'))
ALTER TABLE [dbo].[Order] DROP CONSTRAINT [FK_Order_Reservation]
GO
/****** Object:  ForeignKey [FK_Order_ShipmentMode]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Order_ShipmentMode]') AND parent_object_id = OBJECT_ID(N'[dbo].[Order]'))
ALTER TABLE [dbo].[Order] DROP CONSTRAINT [FK_Order_ShipmentMode]
GO
/****** Object:  ForeignKey [FK_OrderDetail_FabricCode]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OrderDetail_FabricCode]') AND parent_object_id = OBJECT_ID(N'[dbo].[OrderDetail]'))
ALTER TABLE [dbo].[OrderDetail] DROP CONSTRAINT [FK_OrderDetail_FabricCode]
GO
/****** Object:  ForeignKey [FK_OrderDetail_Label]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OrderDetail_Label]') AND parent_object_id = OBJECT_ID(N'[dbo].[OrderDetail]'))
ALTER TABLE [dbo].[OrderDetail] DROP CONSTRAINT [FK_OrderDetail_Label]
GO
/****** Object:  ForeignKey [FK_OrderDetail_Order]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OrderDetail_Order]') AND parent_object_id = OBJECT_ID(N'[dbo].[OrderDetail]'))
ALTER TABLE [dbo].[OrderDetail] DROP CONSTRAINT [FK_OrderDetail_Order]
GO
/****** Object:  ForeignKey [FK_OrderDetail_OrderType]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OrderDetail_OrderType]') AND parent_object_id = OBJECT_ID(N'[dbo].[OrderDetail]'))
ALTER TABLE [dbo].[OrderDetail] DROP CONSTRAINT [FK_OrderDetail_OrderType]
GO
/****** Object:  ForeignKey [FK_OrderDetail_Pattern]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OrderDetail_Pattern]') AND parent_object_id = OBJECT_ID(N'[dbo].[OrderDetail]'))
ALTER TABLE [dbo].[OrderDetail] DROP CONSTRAINT [FK_OrderDetail_Pattern]
GO
/****** Object:  ForeignKey [FK_OrderDetail_VisualLayout]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OrderDetail_VisualLayout]') AND parent_object_id = OBJECT_ID(N'[dbo].[OrderDetail]'))
ALTER TABLE [dbo].[OrderDetail] DROP CONSTRAINT [FK_OrderDetail_VisualLayout]
GO
/****** Object:  ForeignKey [FK_OrderDetailQty_OrderDetail]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OrderDetailQty_OrderDetail]') AND parent_object_id = OBJECT_ID(N'[dbo].[OrderDetailQty]'))
ALTER TABLE [dbo].[OrderDetailQty] DROP CONSTRAINT [FK_OrderDetailQty_OrderDetail]
GO
/****** Object:  ForeignKey [FK_OrderDetailQty_Size]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OrderDetailQty_Size]') AND parent_object_id = OBJECT_ID(N'[dbo].[OrderDetailQty]'))
ALTER TABLE [dbo].[OrderDetailQty] DROP CONSTRAINT [FK_OrderDetailQty_Size]
GO
/****** Object:  ForeignKey [FK_Pattern_AgeGroup]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Pattern_AgeGroup]') AND parent_object_id = OBJECT_ID(N'[dbo].[Pattern]'))
ALTER TABLE [dbo].[Pattern] DROP CONSTRAINT [FK_Pattern_AgeGroup]
GO
/****** Object:  ForeignKey [FK_Pattern_Category]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Pattern_Category]') AND parent_object_id = OBJECT_ID(N'[dbo].[Pattern]'))
ALTER TABLE [dbo].[Pattern] DROP CONSTRAINT [FK_Pattern_Category]
GO
/****** Object:  ForeignKey [FK_Pattern_Creator]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Pattern_Creator]') AND parent_object_id = OBJECT_ID(N'[dbo].[Pattern]'))
ALTER TABLE [dbo].[Pattern] DROP CONSTRAINT [FK_Pattern_Creator]
GO
/****** Object:  ForeignKey [FK_Pattern_Gender]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Pattern_Gender]') AND parent_object_id = OBJECT_ID(N'[dbo].[Pattern]'))
ALTER TABLE [dbo].[Pattern] DROP CONSTRAINT [FK_Pattern_Gender]
GO
/****** Object:  ForeignKey [FK_Pattern_Item]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Pattern_Item]') AND parent_object_id = OBJECT_ID(N'[dbo].[Pattern]'))
ALTER TABLE [dbo].[Pattern] DROP CONSTRAINT [FK_Pattern_Item]
GO
/****** Object:  ForeignKey [FK_Pattern_ItemAttribute]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Pattern_ItemAttribute]') AND parent_object_id = OBJECT_ID(N'[dbo].[Pattern]'))
ALTER TABLE [dbo].[Pattern] DROP CONSTRAINT [FK_Pattern_ItemAttribute]
GO
/****** Object:  ForeignKey [FK_Pattern_Modifier]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Pattern_Modifier]') AND parent_object_id = OBJECT_ID(N'[dbo].[Pattern]'))
ALTER TABLE [dbo].[Pattern] DROP CONSTRAINT [FK_Pattern_Modifier]
GO
/****** Object:  ForeignKey [FK_Pattern_Parent]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Pattern_Parent]') AND parent_object_id = OBJECT_ID(N'[dbo].[Pattern]'))
ALTER TABLE [dbo].[Pattern] DROP CONSTRAINT [FK_Pattern_Parent]
GO
/****** Object:  ForeignKey [FK_Pattern_PrinterType]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Pattern_PrinterType]') AND parent_object_id = OBJECT_ID(N'[dbo].[Pattern]'))
ALTER TABLE [dbo].[Pattern] DROP CONSTRAINT [FK_Pattern_PrinterType]
GO
/****** Object:  ForeignKey [FK_Pattern_SizeSet]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Pattern_SizeSet]') AND parent_object_id = OBJECT_ID(N'[dbo].[Pattern]'))
ALTER TABLE [dbo].[Pattern] DROP CONSTRAINT [FK_Pattern_SizeSet]
GO
/****** Object:  ForeignKey [FK_Pattern_SubItem]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Pattern_SubItem]') AND parent_object_id = OBJECT_ID(N'[dbo].[Pattern]'))
ALTER TABLE [dbo].[Pattern] DROP CONSTRAINT [FK_Pattern_SubItem]
GO
/****** Object:  ForeignKey [FK_PatternAccessory_Accessory]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PatternAccessory_Accessory]') AND parent_object_id = OBJECT_ID(N'[dbo].[PatternAccessory]'))
ALTER TABLE [dbo].[PatternAccessory] DROP CONSTRAINT [FK_PatternAccessory_Accessory]
GO
/****** Object:  ForeignKey [FK_PatternAccessory_AccessoryCategory]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PatternAccessory_AccessoryCategory]') AND parent_object_id = OBJECT_ID(N'[dbo].[PatternAccessory]'))
ALTER TABLE [dbo].[PatternAccessory] DROP CONSTRAINT [FK_PatternAccessory_AccessoryCategory]
GO
/****** Object:  ForeignKey [FK_PatternAccessory_Pattern]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PatternAccessory_Pattern]') AND parent_object_id = OBJECT_ID(N'[dbo].[PatternAccessory]'))
ALTER TABLE [dbo].[PatternAccessory] DROP CONSTRAINT [FK_PatternAccessory_Pattern]
GO
/****** Object:  ForeignKey [FK_PatternItemAttributeSub_ItemAttribute]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PatternItemAttributeSub_ItemAttribute]') AND parent_object_id = OBJECT_ID(N'[dbo].[PatternItemAttributeSub]'))
ALTER TABLE [dbo].[PatternItemAttributeSub] DROP CONSTRAINT [FK_PatternItemAttributeSub_ItemAttribute]
GO
/****** Object:  ForeignKey [FK_PatternItemAttributeSub_Pattern]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PatternItemAttributeSub_Pattern]') AND parent_object_id = OBJECT_ID(N'[dbo].[PatternItemAttributeSub]'))
ALTER TABLE [dbo].[PatternItemAttributeSub] DROP CONSTRAINT [FK_PatternItemAttributeSub_Pattern]
GO
/****** Object:  ForeignKey [FK_PatternOtherCategory_Category]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PatternOtherCategory_Category]') AND parent_object_id = OBJECT_ID(N'[dbo].[PatternOtherCategory]'))
ALTER TABLE [dbo].[PatternOtherCategory] DROP CONSTRAINT [FK_PatternOtherCategory_Category]
GO
/****** Object:  ForeignKey [FK_PatternOtherCategory_Pattern]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PatternOtherCategory_Pattern]') AND parent_object_id = OBJECT_ID(N'[dbo].[PatternOtherCategory]'))
ALTER TABLE [dbo].[PatternOtherCategory] DROP CONSTRAINT [FK_PatternOtherCategory_Pattern]
GO
/****** Object:  ForeignKey [FK_Image_Pattern]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Image_Pattern]') AND parent_object_id = OBJECT_ID(N'[dbo].[PatternTemplateImage]'))
ALTER TABLE [dbo].[PatternTemplateImage] DROP CONSTRAINT [FK_Image_Pattern]
GO
/****** Object:  ForeignKey [FK_Price_Creator]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Price_Creator]') AND parent_object_id = OBJECT_ID(N'[dbo].[Price]'))
ALTER TABLE [dbo].[Price] DROP CONSTRAINT [FK_Price_Creator]
GO
/****** Object:  ForeignKey [FK_Price_Fabric]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Price_Fabric]') AND parent_object_id = OBJECT_ID(N'[dbo].[Price]'))
ALTER TABLE [dbo].[Price] DROP CONSTRAINT [FK_Price_Fabric]
GO
/****** Object:  ForeignKey [FK_Price_Modifier]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Price_Modifier]') AND parent_object_id = OBJECT_ID(N'[dbo].[Price]'))
ALTER TABLE [dbo].[Price] DROP CONSTRAINT [FK_Price_Modifier]
GO
/****** Object:  ForeignKey [FK_Price_Pattern]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Price_Pattern]') AND parent_object_id = OBJECT_ID(N'[dbo].[Price]'))
ALTER TABLE [dbo].[Price] DROP CONSTRAINT [FK_Price_Pattern]
GO
/****** Object:  ForeignKey [FK_PriceHistroy_Price]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PriceHistroy_Price]') AND parent_object_id = OBJECT_ID(N'[dbo].[PriceHistroy]'))
ALTER TABLE [dbo].[PriceHistroy] DROP CONSTRAINT [FK_PriceHistroy_Price]
GO
/****** Object:  ForeignKey [FK_PriceLevelCost_Price]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PriceLevelCost_Price]') AND parent_object_id = OBJECT_ID(N'[dbo].[PriceLevelCost]'))
ALTER TABLE [dbo].[PriceLevelCost] DROP CONSTRAINT [FK_PriceLevelCost_Price]
GO
/****** Object:  ForeignKey [FK_PriceLevelCost_PriceLevel]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PriceLevelCost_PriceLevel]') AND parent_object_id = OBJECT_ID(N'[dbo].[PriceLevelCost]'))
ALTER TABLE [dbo].[PriceLevelCost] DROP CONSTRAINT [FK_PriceLevelCost_PriceLevel]
GO
/****** Object:  ForeignKey [FK_Product_ColourProfile]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Product_ColourProfile]') AND parent_object_id = OBJECT_ID(N'[dbo].[Product]'))
ALTER TABLE [dbo].[Product] DROP CONSTRAINT [FK_Product_ColourProfile]
GO
/****** Object:  ForeignKey [FK_Product_Contact]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Product_Contact]') AND parent_object_id = OBJECT_ID(N'[dbo].[Product]'))
ALTER TABLE [dbo].[Product] DROP CONSTRAINT [FK_Product_Contact]
GO
/****** Object:  ForeignKey [FK_Product_Pattern]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Product_Pattern]') AND parent_object_id = OBJECT_ID(N'[dbo].[Product]'))
ALTER TABLE [dbo].[Product] DROP CONSTRAINT [FK_Product_Pattern]
GO
/****** Object:  ForeignKey [FK_Product_Printer]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Product_Printer]') AND parent_object_id = OBJECT_ID(N'[dbo].[Product]'))
ALTER TABLE [dbo].[Product] DROP CONSTRAINT [FK_Product_Printer]
GO
/****** Object:  ForeignKey [FK_Product_ResolutionProfile]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Product_ResolutionProfile]') AND parent_object_id = OBJECT_ID(N'[dbo].[Product]'))
ALTER TABLE [dbo].[Product] DROP CONSTRAINT [FK_Product_ResolutionProfile]
GO
/****** Object:  ForeignKey [FK_RequestedQuote_Company]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_RequestedQuote_Company]') AND parent_object_id = OBJECT_ID(N'[dbo].[RequestedQuote]'))
ALTER TABLE [dbo].[RequestedQuote] DROP CONSTRAINT [FK_RequestedQuote_Company]
GO
/****** Object:  ForeignKey [FK_RequestedQuote_Status]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_RequestedQuote_Status]') AND parent_object_id = OBJECT_ID(N'[dbo].[RequestedQuote]'))
ALTER TABLE [dbo].[RequestedQuote] DROP CONSTRAINT [FK_RequestedQuote_Status]
GO
/****** Object:  ForeignKey [FK_Reservation_Client]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Reservation_Client]') AND parent_object_id = OBJECT_ID(N'[dbo].[Reservation]'))
ALTER TABLE [dbo].[Reservation] DROP CONSTRAINT [FK_Reservation_Client]
GO
/****** Object:  ForeignKey [FK_Reservation_Coordinator]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Reservation_Coordinator]') AND parent_object_id = OBJECT_ID(N'[dbo].[Reservation]'))
ALTER TABLE [dbo].[Reservation] DROP CONSTRAINT [FK_Reservation_Coordinator]
GO
/****** Object:  ForeignKey [FK_Reservation_Creator]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Reservation_Creator]') AND parent_object_id = OBJECT_ID(N'[dbo].[Reservation]'))
ALTER TABLE [dbo].[Reservation] DROP CONSTRAINT [FK_Reservation_Creator]
GO
/****** Object:  ForeignKey [FK_Reservation_DestinationPort]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Reservation_DestinationPort]') AND parent_object_id = OBJECT_ID(N'[dbo].[Reservation]'))
ALTER TABLE [dbo].[Reservation] DROP CONSTRAINT [FK_Reservation_DestinationPort]
GO
/****** Object:  ForeignKey [FK_Reservation_Distributor]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Reservation_Distributor]') AND parent_object_id = OBJECT_ID(N'[dbo].[Reservation]'))
ALTER TABLE [dbo].[Reservation] DROP CONSTRAINT [FK_Reservation_Distributor]
GO
/****** Object:  ForeignKey [FK_Reservation_Modifier]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Reservation_Modifier]') AND parent_object_id = OBJECT_ID(N'[dbo].[Reservation]'))
ALTER TABLE [dbo].[Reservation] DROP CONSTRAINT [FK_Reservation_Modifier]
GO
/****** Object:  ForeignKey [FK_Reservation_Pattern]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Reservation_Pattern]') AND parent_object_id = OBJECT_ID(N'[dbo].[Reservation]'))
ALTER TABLE [dbo].[Reservation] DROP CONSTRAINT [FK_Reservation_Pattern]
GO
/****** Object:  ForeignKey [FK_Reservation_ShipmentMode]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Reservation_ShipmentMode]') AND parent_object_id = OBJECT_ID(N'[dbo].[Reservation]'))
ALTER TABLE [dbo].[Reservation] DROP CONSTRAINT [FK_Reservation_ShipmentMode]
GO
/****** Object:  ForeignKey [FK_Reservation_Status]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Reservation_Status]') AND parent_object_id = OBJECT_ID(N'[dbo].[Reservation]'))
ALTER TABLE [dbo].[Reservation] DROP CONSTRAINT [FK_Reservation_Status]
GO
/****** Object:  ForeignKey [FK_Size_SizeSet]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Size_SizeSet]') AND parent_object_id = OBJECT_ID(N'[dbo].[Size]'))
ALTER TABLE [dbo].[Size] DROP CONSTRAINT [FK_Size_SizeSet]
GO
/****** Object:  ForeignKey [FK_SizeChart_MeasurementLocation]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_SizeChart_MeasurementLocation]') AND parent_object_id = OBJECT_ID(N'[dbo].[SizeChart]'))
ALTER TABLE [dbo].[SizeChart] DROP CONSTRAINT [FK_SizeChart_MeasurementLocation]
GO
/****** Object:  ForeignKey [FK_SizeChart_Pattern]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_SizeChart_Pattern]') AND parent_object_id = OBJECT_ID(N'[dbo].[SizeChart]'))
ALTER TABLE [dbo].[SizeChart] DROP CONSTRAINT [FK_SizeChart_Pattern]
GO
/****** Object:  ForeignKey [FK_SizeChart_Size]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_SizeChart_Size]') AND parent_object_id = OBJECT_ID(N'[dbo].[SizeChart]'))
ALTER TABLE [dbo].[SizeChart] DROP CONSTRAINT [FK_SizeChart_Size]
GO
/****** Object:  ForeignKey [FK_User_Company]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_User_Company]') AND parent_object_id = OBJECT_ID(N'[dbo].[User]'))
ALTER TABLE [dbo].[User] DROP CONSTRAINT [FK_User_Company]
GO
/****** Object:  ForeignKey [FK_User_Creator]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_User_Creator]') AND parent_object_id = OBJECT_ID(N'[dbo].[User]'))
ALTER TABLE [dbo].[User] DROP CONSTRAINT [FK_User_Creator]
GO
/****** Object:  ForeignKey [FK_User_Modifier]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_User_Modifier]') AND parent_object_id = OBJECT_ID(N'[dbo].[User]'))
ALTER TABLE [dbo].[User] DROP CONSTRAINT [FK_User_Modifier]
GO
/****** Object:  ForeignKey [FK_User_Status]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_User_Status]') AND parent_object_id = OBJECT_ID(N'[dbo].[User]'))
ALTER TABLE [dbo].[User] DROP CONSTRAINT [FK_User_Status]
GO
/****** Object:  ForeignKey [FK_UserHistory_Creator]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_UserHistory_Creator]') AND parent_object_id = OBJECT_ID(N'[dbo].[UserHistory]'))
ALTER TABLE [dbo].[UserHistory] DROP CONSTRAINT [FK_UserHistory_Creator]
GO
/****** Object:  ForeignKey [FK_UserHistory_User]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_UserHistory_User]') AND parent_object_id = OBJECT_ID(N'[dbo].[UserHistory]'))
ALTER TABLE [dbo].[UserHistory] DROP CONSTRAINT [FK_UserHistory_User]
GO
/****** Object:  ForeignKey [FK_UserLogin_User]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_UserLogin_User]') AND parent_object_id = OBJECT_ID(N'[dbo].[UserLogin]'))
ALTER TABLE [dbo].[UserLogin] DROP CONSTRAINT [FK_UserLogin_User]
GO
/****** Object:  ForeignKey [FK_UserRole_Role]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_UserRole_Role]') AND parent_object_id = OBJECT_ID(N'[dbo].[UserRole]'))
ALTER TABLE [dbo].[UserRole] DROP CONSTRAINT [FK_UserRole_Role]
GO
/****** Object:  ForeignKey [FK_UserRole_User]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_UserRole_User]') AND parent_object_id = OBJECT_ID(N'[dbo].[UserRole]'))
ALTER TABLE [dbo].[UserRole] DROP CONSTRAINT [FK_UserRole_User]
GO
/****** Object:  ForeignKey [FK_VisualLayout_Client]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_VisualLayout_Client]') AND parent_object_id = OBJECT_ID(N'[dbo].[VisualLayout]'))
ALTER TABLE [dbo].[VisualLayout] DROP CONSTRAINT [FK_VisualLayout_Client]
GO
/****** Object:  ForeignKey [FK_VisualLayout_Coordinator]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_VisualLayout_Coordinator]') AND parent_object_id = OBJECT_ID(N'[dbo].[VisualLayout]'))
ALTER TABLE [dbo].[VisualLayout] DROP CONSTRAINT [FK_VisualLayout_Coordinator]
GO
/****** Object:  ForeignKey [FK_VisualLayout_Distributor]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_VisualLayout_Distributor]') AND parent_object_id = OBJECT_ID(N'[dbo].[VisualLayout]'))
ALTER TABLE [dbo].[VisualLayout] DROP CONSTRAINT [FK_VisualLayout_Distributor]
GO
/****** Object:  ForeignKey [FK_VisualLayout_FabricCode]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_VisualLayout_FabricCode]') AND parent_object_id = OBJECT_ID(N'[dbo].[VisualLayout]'))
ALTER TABLE [dbo].[VisualLayout] DROP CONSTRAINT [FK_VisualLayout_FabricCode]
GO
/****** Object:  ForeignKey [FK_VisualLayout_Pattern]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_VisualLayout_Pattern]') AND parent_object_id = OBJECT_ID(N'[dbo].[VisualLayout]'))
ALTER TABLE [dbo].[VisualLayout] DROP CONSTRAINT [FK_VisualLayout_Pattern]
GO
/****** Object:  ForeignKey [FK_VisualLayoutAccessory_Accessory]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_VisualLayoutAccessory_Accessory]') AND parent_object_id = OBJECT_ID(N'[dbo].[VisualLayoutAccessory]'))
ALTER TABLE [dbo].[VisualLayoutAccessory] DROP CONSTRAINT [FK_VisualLayoutAccessory_Accessory]
GO
/****** Object:  ForeignKey [FK_VisualLayoutAccessory_AccessoryCategory]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_VisualLayoutAccessory_AccessoryCategory]') AND parent_object_id = OBJECT_ID(N'[dbo].[VisualLayoutAccessory]'))
ALTER TABLE [dbo].[VisualLayoutAccessory] DROP CONSTRAINT [FK_VisualLayoutAccessory_AccessoryCategory]
GO
/****** Object:  ForeignKey [FK_VisualLayoutAccessory_AccessoryColor]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_VisualLayoutAccessory_AccessoryColor]') AND parent_object_id = OBJECT_ID(N'[dbo].[VisualLayoutAccessory]'))
ALTER TABLE [dbo].[VisualLayoutAccessory] DROP CONSTRAINT [FK_VisualLayoutAccessory_AccessoryColor]
GO
/****** Object:  ForeignKey [FK_VisualLayoutAccessory_VisualLayout]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_VisualLayoutAccessory_VisualLayout]') AND parent_object_id = OBJECT_ID(N'[dbo].[VisualLayoutAccessory]'))
ALTER TABLE [dbo].[VisualLayoutAccessory] DROP CONSTRAINT [FK_VisualLayoutAccessory_VisualLayout]
GO
/****** Object:  View [dbo].[UserMenuItemRoleView]    Script Date: 08/02/2012 17:55:59 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[UserMenuItemRoleView]'))
DROP VIEW [dbo].[UserMenuItemRoleView]
GO
/****** Object:  Table [dbo].[MenuItemRole]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MenuItemRole]') AND type in (N'U'))
DROP TABLE [dbo].[MenuItemRole]
GO
/****** Object:  Table [dbo].[MeasurementLocation]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MeasurementLocation]') AND type in (N'U'))
DROP TABLE [dbo].[MeasurementLocation]
GO
/****** Object:  Table [dbo].[SizeChart]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SizeChart]') AND type in (N'U'))
DROP TABLE [dbo].[SizeChart]
GO
/****** Object:  Table [dbo].[MenuItem]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MenuItem]') AND type in (N'U'))
DROP TABLE [dbo].[MenuItem]
GO
/****** Object:  Table [dbo].[AccessoryCategory]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AccessoryCategory]') AND type in (N'U'))
DROP TABLE [dbo].[AccessoryCategory]
GO
/****** Object:  Table [dbo].[PatternAccessory]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PatternAccessory]') AND type in (N'U'))
DROP TABLE [dbo].[PatternAccessory]
GO
/****** Object:  Table [dbo].[VisualLayoutAccessory]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[VisualLayoutAccessory]') AND type in (N'U'))
DROP TABLE [dbo].[VisualLayoutAccessory]
GO
/****** Object:  View [dbo].[ClientOrderDetailsView]    Script Date: 08/02/2012 17:55:59 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ClientOrderDetailsView]'))
DROP VIEW [dbo].[ClientOrderDetailsView]
GO
/****** Object:  View [dbo].[OrderDetailsView]    Script Date: 08/02/2012 17:55:59 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[OrderDetailsView]'))
DROP VIEW [dbo].[OrderDetailsView]
GO
/****** Object:  Table [dbo].[OrderDetail]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OrderDetail]') AND type in (N'U'))
DROP TABLE [dbo].[OrderDetail]
GO
/****** Object:  View [dbo].[PriceLevelCostView]    Script Date: 08/02/2012 17:55:59 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[PriceLevelCostView]'))
DROP VIEW [dbo].[PriceLevelCostView]
GO
/****** Object:  Table [dbo].[Price]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Price]') AND type in (N'U'))
DROP TABLE [dbo].[Price]
GO
/****** Object:  Table [dbo].[FabricCode]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FabricCode]') AND type in (N'U'))
DROP TABLE [dbo].[FabricCode]
GO
/****** Object:  Table [dbo].[VisualLayout]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[VisualLayout]') AND type in (N'U'))
DROP TABLE [dbo].[VisualLayout]
GO
/****** Object:  Table [dbo].[Invoice]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Invoice]') AND type in (N'U'))
DROP TABLE [dbo].[Invoice]
GO
/****** Object:  Table [dbo].[InvoiceOrder]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InvoiceOrder]') AND type in (N'U'))
DROP TABLE [dbo].[InvoiceOrder]
GO
/****** Object:  Table [dbo].[Order]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Order]') AND type in (N'U'))
DROP TABLE [dbo].[Order]
GO
/****** Object:  Table [dbo].[ItemAttribute]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ItemAttribute]') AND type in (N'U'))
DROP TABLE [dbo].[ItemAttribute]
GO
/****** Object:  Table [dbo].[Pattern]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Pattern]') AND type in (N'U'))
DROP TABLE [dbo].[Pattern]
GO
/****** Object:  Table [dbo].[PatternItemAttributeSub]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PatternItemAttributeSub]') AND type in (N'U'))
DROP TABLE [dbo].[PatternItemAttributeSub]
GO
/****** Object:  Table [dbo].[Size]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Size]') AND type in (N'U'))
DROP TABLE [dbo].[Size]
GO
/****** Object:  Table [dbo].[OrderDetailQty]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OrderDetailQty]') AND type in (N'U'))
DROP TABLE [dbo].[OrderDetailQty]
GO
/****** Object:  Table [dbo].[SizeSet]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SizeSet]') AND type in (N'U'))
DROP TABLE [dbo].[SizeSet]
GO
/****** Object:  StoredProcedure [dbo].[SPC_EncryptedPassword]    Script Date: 08/02/2012 17:55:54 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_EncryptedPassword]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_EncryptedPassword]
GO
/****** Object:  Table [dbo].[UserStatus]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserStatus]') AND type in (N'U'))
DROP TABLE [dbo].[UserStatus]
GO
/****** Object:  Table [dbo].[SportsCategory]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SportsCategory]') AND type in (N'U'))
DROP TABLE [dbo].[SportsCategory]
GO
/****** Object:  Table [dbo].[WeeklyProductionCapacity]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WeeklyProductionCapacity]') AND type in (N'U'))
DROP TABLE [dbo].[WeeklyProductionCapacity]
GO
/****** Object:  Table [dbo].[JobTitle]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[JobTitle]') AND type in (N'U'))
DROP TABLE [dbo].[JobTitle]
GO
/****** Object:  Table [dbo].[Keyword]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Keyword]') AND type in (N'U'))
DROP TABLE [dbo].[Keyword]
GO
/****** Object:  Table [dbo].[Label]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Label]') AND type in (N'U'))
DROP TABLE [dbo].[Label]
GO
/****** Object:  Table [dbo].[DistributorLabel]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DistributorLabel]') AND type in (N'U'))
DROP TABLE [dbo].[DistributorLabel]
GO
/****** Object:  Table [dbo].[Accessory]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Accessory]') AND type in (N'U'))
DROP TABLE [dbo].[Accessory]
GO
/****** Object:  Table [dbo].[Gender]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Gender]') AND type in (N'U'))
DROP TABLE [dbo].[Gender]
GO
/****** Object:  Table [dbo].[CompanyType]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CompanyType]') AND type in (N'U'))
DROP TABLE [dbo].[CompanyType]
GO
/****** Object:  Table [dbo].[Company]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Company]') AND type in (N'U'))
DROP TABLE [dbo].[Company]
GO
/****** Object:  Table [dbo].[Country]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Country]') AND type in (N'U'))
DROP TABLE [dbo].[Country]
GO
/****** Object:  Table [dbo].[Currency]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Currency]') AND type in (N'U'))
DROP TABLE [dbo].[Currency]
GO
/****** Object:  Table [dbo].[DeliveryMethod]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DeliveryMethod]') AND type in (N'U'))
DROP TABLE [dbo].[DeliveryMethod]
GO
/****** Object:  Table [dbo].[DestinationPort]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DestinationPort]') AND type in (N'U'))
DROP TABLE [dbo].[DestinationPort]
GO
/****** Object:  Table [dbo].[Reservation]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Reservation]') AND type in (N'U'))
DROP TABLE [dbo].[Reservation]
GO
/****** Object:  Table [dbo].[AccessoryColor]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AccessoryColor]') AND type in (N'U'))
DROP TABLE [dbo].[AccessoryColor]
GO
/****** Object:  Table [dbo].[AgeGroup]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AgeGroup]') AND type in (N'U'))
DROP TABLE [dbo].[AgeGroup]
GO
/****** Object:  Table [dbo].[Category]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Category]') AND type in (N'U'))
DROP TABLE [dbo].[Category]
GO
/****** Object:  Table [dbo].[PatternOtherCategory]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PatternOtherCategory]') AND type in (N'U'))
DROP TABLE [dbo].[PatternOtherCategory]
GO
/****** Object:  Table [dbo].[ClientType]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ClientType]') AND type in (N'U'))
DROP TABLE [dbo].[ClientType]
GO
/****** Object:  Table [dbo].[Client]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Client]') AND type in (N'U'))
DROP TABLE [dbo].[Client]
GO
/****** Object:  Table [dbo].[ColourProfile]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ColourProfile]') AND type in (N'U'))
DROP TABLE [dbo].[ColourProfile]
GO
/****** Object:  Table [dbo].[Product]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Product]') AND type in (N'U'))
DROP TABLE [dbo].[Product]
GO
/****** Object:  Table [dbo].[InvoiceStatus]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InvoiceStatus]') AND type in (N'U'))
DROP TABLE [dbo].[InvoiceStatus]
GO
/****** Object:  Table [dbo].[Item]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Item]') AND type in (N'U'))
DROP TABLE [dbo].[Item]
GO
/****** Object:  Table [dbo].[NickName]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[NickName]') AND type in (N'U'))
DROP TABLE [dbo].[NickName]
GO
/****** Object:  Table [dbo].[OrderStatus]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OrderStatus]') AND type in (N'U'))
DROP TABLE [dbo].[OrderStatus]
GO
/****** Object:  Table [dbo].[OrderType]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OrderType]') AND type in (N'U'))
DROP TABLE [dbo].[OrderType]
GO
/****** Object:  Table [dbo].[Page]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Page]') AND type in (N'U'))
DROP TABLE [dbo].[Page]
GO
/****** Object:  Table [dbo].[PaymentMethod]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PaymentMethod]') AND type in (N'U'))
DROP TABLE [dbo].[PaymentMethod]
GO
/****** Object:  Table [dbo].[PriceLevel]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PriceLevel]') AND type in (N'U'))
DROP TABLE [dbo].[PriceLevel]
GO
/****** Object:  Table [dbo].[DistributorPriceMarkup]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DistributorPriceMarkup]') AND type in (N'U'))
DROP TABLE [dbo].[DistributorPriceMarkup]
GO
/****** Object:  Table [dbo].[PriceLevelCost]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PriceLevelCost]') AND type in (N'U'))
DROP TABLE [dbo].[PriceLevelCost]
GO
/****** Object:  Table [dbo].[PriceTerm]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PriceTerm]') AND type in (N'U'))
DROP TABLE [dbo].[PriceTerm]
GO
/****** Object:  Table [dbo].[DistributorPriceLevelCost]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DistributorPriceLevelCost]') AND type in (N'U'))
DROP TABLE [dbo].[DistributorPriceLevelCost]
GO
/****** Object:  Table [dbo].[Printer]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Printer]') AND type in (N'U'))
DROP TABLE [dbo].[Printer]
GO
/****** Object:  Table [dbo].[PrinterType]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PrinterType]') AND type in (N'U'))
DROP TABLE [dbo].[PrinterType]
GO
/****** Object:  Table [dbo].[DistributorPriceLevelCostHistory]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DistributorPriceLevelCostHistory]') AND type in (N'U'))
DROP TABLE [dbo].[DistributorPriceLevelCostHistory]
GO
/****** Object:  Table [dbo].[ProductionLine]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProductionLine]') AND type in (N'U'))
DROP TABLE [dbo].[ProductionLine]
GO
/****** Object:  Table [dbo].[ProductSequence]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProductSequence]') AND type in (N'U'))
DROP TABLE [dbo].[ProductSequence]
GO
/****** Object:  Table [dbo].[RequestedQuoteStatus]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RequestedQuoteStatus]') AND type in (N'U'))
DROP TABLE [dbo].[RequestedQuoteStatus]
GO
/****** Object:  Table [dbo].[RequestedQuote]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RequestedQuote]') AND type in (N'U'))
DROP TABLE [dbo].[RequestedQuote]
GO
/****** Object:  Table [dbo].[ReservationStatus]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReservationStatus]') AND type in (N'U'))
DROP TABLE [dbo].[ReservationStatus]
GO
/****** Object:  Table [dbo].[ResolutionProfile]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ResolutionProfile]') AND type in (N'U'))
DROP TABLE [dbo].[ResolutionProfile]
GO
/****** Object:  View [dbo].[ReturnStringView]    Script Date: 08/02/2012 17:55:59 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnStringView]'))
DROP VIEW [dbo].[ReturnStringView]
GO
/****** Object:  Table [dbo].[Role]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Role]') AND type in (N'U'))
DROP TABLE [dbo].[Role]
GO
/****** Object:  Table [dbo].[UserRole]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserRole]') AND type in (N'U'))
DROP TABLE [dbo].[UserRole]
GO
/****** Object:  Table [dbo].[ShipmentMode]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ShipmentMode]') AND type in (N'U'))
DROP TABLE [dbo].[ShipmentMode]
GO
/****** Object:  Table [dbo].[PriceHistroy]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PriceHistroy]') AND type in (N'U'))
DROP TABLE [dbo].[PriceHistroy]
GO
/****** Object:  Table [dbo].[PatternTemplateImage]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PatternTemplateImage]') AND type in (N'U'))
DROP TABLE [dbo].[PatternTemplateImage]
GO
/****** Object:  Table [dbo].[Image]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Image]') AND type in (N'U'))
DROP TABLE [dbo].[Image]
GO
/****** Object:  StoredProcedure [dbo].[SPC_ReturnUserLogin]    Script Date: 08/02/2012 17:55:54 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ReturnUserLogin]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ReturnUserLogin]
GO
/****** Object:  Table [dbo].[User]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[User]') AND type in (N'U'))
DROP TABLE [dbo].[User]
GO
/****** Object:  Table [dbo].[UserHistory]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserHistory]') AND type in (N'U'))
DROP TABLE [dbo].[UserHistory]
GO
/****** Object:  Table [dbo].[UserLogin]    Script Date: 08/02/2012 17:55:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserLogin]') AND type in (N'U'))
DROP TABLE [dbo].[UserLogin]
GO
