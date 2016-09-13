USE [Indico]
GO

-- Update Order detail status to Senanayake..

  UPDATE [dbo].[OrderDetail]
  SET [Status] = 1
  WHERE ShipmentDate < '2016-05-03' AND [Status] IS NULL

  GO