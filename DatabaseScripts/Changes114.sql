USE [Indico]
GO


UPDATE [dbo].[Invoice] SET [WeeklyProductionCapacity] = 95 WHERE [ID] = 44
GO


UPDATE [dbo].[OrderDetail] SET [ShipmentDate] = '2014-10-25 00:00:00.0000000', [SheduledDate] = '2014-10-25 00:00:00.0000000' WHERE [ID] IN (14637, 14638, 14639, 14640, 14641, 14642)
GO