USE [Indico]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_EmbroideryDetails_Status]') AND parent_object_id = OBJECT_ID(N'[dbo].[EmbroideryDetails]'))
ALTER TABLE [dbo].[EmbroideryDetails] DROP CONSTRAINT [FK_EmbroideryDetails_Status]
GO

ALTER TABLE [dbo].[EmbroideryDetails]  WITH CHECK ADD  CONSTRAINT [FK_EmbroideryDetails_Status] FOREIGN KEY([Status])
REFERENCES [dbo].[EmbroideryStatus] ([ID])
GO

ALTER TABLE [dbo].[EmbroideryDetails] CHECK CONSTRAINT [FK_EmbroideryDetails_Status]
GO


--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

--**-**-**--**-**-**--**-**-**RENAME THE PACKINGLIST TO PACKINGPLAN --**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

DECLARE @Page AS int
DECLARE @MenuItem AS int


SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/PackingList.aspx')

UPDATE [dbo].[Page] SET [Title] = 'Packing Plan', [Heading] = 'Packing Plan' WHERE [ID] = @Page

SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page)

UPDATE [dbo].[MenuItem] SET [Name] = 'Packing Plan', [Description] = 'Packing Plan' WHERE [ID] = @MenuItem
GO


--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

--**-**-**--**-**-**--**-**-**RENAME THE WEEKKLY CAPACITIES TO WEEKKLY SUMMARY --**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

DECLARE @Page AS int
DECLARE @MenuItem AS int


SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewWeeklyCapacities.aspx')

UPDATE [dbo].[Page] SET [Title] = 'Weekly Summaries', [Heading] = 'Weekly Summaries' WHERE [ID] = @Page

SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page)

UPDATE [dbo].[MenuItem] SET [Name] = 'Weekly Summaries', [Description] = 'Weekly Summaries' WHERE [ID] = @MenuItem
GO

--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

--**-**-**-**--**-**-**-**--**-**-**-**DROP COLUMN Invoice Table --**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**
DELETE [dbo].[InvoiceOrder]
FROM [dbo].[InvoiceOrder] ino
	JOIN [dbo].[Invoice] i
		ON ino.[Invoice] = i.[ID]
		
DELETE [dbo].[Invoice]
GO

ALTER TABLE [dbo].[Invoice]
DROP COLUMN [Value]
GO

ALTER TABLE [dbo].[Invoice]
DROP COLUMN [Freight]
GO

ALTER TABLE [dbo].[Invoice]
DROP COLUMN [OtherCost]
GO

ALTER TABLE [dbo].[Invoice]
DROP COLUMN [Discount]
GO

ALTER TABLE [dbo].[Invoice]
DROP COLUMN [NetValue]
GO

ALTER TABLE [dbo].[Invoice]
DROP COLUMN [BillTo]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Invoice_Status]') AND parent_object_id = OBJECT_ID(N'[dbo].[Invoice]'))
ALTER TABLE [dbo].[Invoice] DROP CONSTRAINT [FK_Invoice_Status]
GO

ALTER TABLE [dbo].[Invoice]
DROP COLUMN [Status]
GO

ALTER TABLE [dbo].[Invoice]
ALTER COLUMN [ShipTo] [int] NOT NULL

ALTER TABLE [dbo].[Invoice]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_ShipTo] FOREIGN KEY([ShipTo])
REFERENCES [dbo].[DistributorClientAddress] ([ID])
GO

ALTER TABLE [dbo].[Invoice] CHECK CONSTRAINT [FK_Invoice_ShipTo]
GO

ALTER TABLE [dbo].[InvoiceOrder]
DROP COLUMN [NewPrice]
GO

ALTER TABLE [dbo].[InvoiceOrder]
ADD FactoryPrice [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[InvoiceOrder]
ADD IndimanPrice [decimal] (8,2) NULL
GO

-- MUST BE GENERATE
ALTER TABLE [dbo].[Invoice]
ADD [WeeklyProductionCapacity] [int] NOT NULL
GO


ALTER TABLE [dbo].[Invoice]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_WeeklyProductionCapacity] FOREIGN KEY([WeeklyProductionCapacity])
REFERENCES [dbo].[WeeklyProductionCapacity] ([ID])
GO

ALTER TABLE [dbo].[Invoice] CHECK CONSTRAINT [FK_Invoice_WeeklyProductionCapacity]
GO

--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**
/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklySummary]    Script Date: 01/02/2014 16:15:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklySummary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklySummary]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklySummary]    Script Date: 01/02/2014 16:15:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SPC_GetWeeklySummary] (	
@P_WeekEndDate datetime2(7) 
)	
AS 
BEGIN
		SELECT 
				ISNULL(dca.CompanyName, '') AS 'CompanyName', 
				ISNULL(SUM(odq.Qty), 0) AS  'Qty' , 
				ISNULL(sm.[Name], 'AIR') AS 'ShipmentMode',
				ISNULL(sm.[ID], 0) AS 'ShipmentModeID',
				ISNULL(dca.[ID], 0) AS 'DistributorClientAddress'
		  FROM [Indico].[dbo].[DistributorClientAddress] dca
		 JOIN [dbo].[ORDER] o
			ON o.[DespatchToExistingClient] = dca.ID
		 JOIN [dbo].[OrderDetail] od
			ON od.[Order] = o.ID
		 JOIN [dbo].[OrderDetailQty] odq
			ON odq.[OrderDetail] = od.ID
		 JOIN [dbo].[ShipmentMode] sm
			ON o.[ShipmentMode] = sm.[ID]
		WHERE (od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate)
		GROUP BY dca.CompanyName, sm.[Name], sm.[ID],dca.[ID]
END

GO
--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

/****** Object:  View [dbo].[ReturnWeeklySummaryView]    Script Date: 01/02/2014 16:18:00 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnWeeklySummaryView]'))
DROP VIEW [dbo].[ReturnWeeklySummaryView]
GO


/****** Object:  View [dbo].[ReturnWeeklySummaryView]    Script Date: 01/02/2014 16:18:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[ReturnWeeklySummaryView]
AS
			SELECT			  
				  '' AS 'CompanyName',				  
				  0 AS 'Qty',
				  '' AS 'ShipmentMode',
				  0 AS 'ShipmentModeID',
				  0 AS 'DistributorClientAddress'				 


GO

--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

