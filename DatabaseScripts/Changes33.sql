USE[Indico]
GO

--**--**--**--**--**--**--**--** Delete OrderDetailQty records --**--**--**--**--**--**--**--**--**--**--**--**

DELETE FROM	[dbo].[OrderDetailQty] 
FROM [dbo].[OrderDetailQty] odq
	JOIN [dbo].[OrderDetail] od
		ON odq.[OrderDetail] = od.[ID]
	JOIN [dbo].[Order] o
		ON od.[Order] = o.[ID]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--** Delete OrderDetail--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
		
DELETE FROM	[dbo].[OrderDetail] 
FROM [dbo].[OrderDetail] od
		JOIN [dbo].[Order] o
			ON od.[Order] = o.[ID]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--** Delete Orders Recors --**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

DELETE FROM	[dbo].[Order]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--**--**--**--** Delete Order Status --**--**--**--**--**--**--**--**--**--**--**--**--**

DELETE FROM [dbo].[OrderStatus]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--** Delete AutoOrderNumber --**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

DELETE FROM [dbo].[AutoOrderNumber]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**Insert records Order Status Table --**--**--**--**--**--**--**--**--**--**--**

INSERT INTO [dbo].[OrderStatus] 
					([Name],
					 [Description])
				VALUES('Not Started',
					   'Order still not started')
GO

INSERT INTO [dbo].[OrderStatus] 
					([Name],
					 [Description])
				VALUES('In Progress',
					   'Order in progress')
GO

INSERT INTO [dbo].[OrderStatus] 
					([Name],
					 [Description])
				VALUES('Partialy Completed',
					   'Order Partialy Completed')
GO

INSERT INTO [dbo].[OrderStatus] 
					([Name],
					 [Description])
				VALUES('Completed',
					   'Order Completed')
GO

INSERT INTO [dbo].[OrderStatus] 
					([Name],
					 [Description])
				VALUES('Distributor Submitted',
					   'Distributor Submitted')
GO

INSERT INTO [dbo].[OrderStatus] 
					([Name],
					 [Description])
				VALUES('Indico Hold',
					   'Indico Hold')
GO

INSERT INTO [dbo].[OrderStatus] 
					([Name],
					 [Description])
				VALUES('Indico Submitted',
					   'Indico Submitted')
GO

INSERT INTO [dbo].[OrderStatus] 
					([Name],
					 [Description])
				VALUES('Indiman Hold',
					   'Indiman Hold')
GO

INSERT INTO [dbo].[OrderStatus] 
					([Name],
					 [Description])
				VALUES('Indiman Submitted',
					   'Indiman Submitted')
GO

INSERT INTO [dbo].[OrderStatus] 
					([Name],
					 [Description])
				VALUES('Factory Hold',
					   'Factory Hold')
GO



--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OrderDetail_Status]') AND parent_object_id = OBJECT_ID(N'[dbo].[OrderDetail]'))
ALTER TABLE [dbo].[OrderDetail] DROP CONSTRAINT [FK_OrderDetail_Status]
GO

/****** Object:  Table [dbo].[OrderDetailStatus]    Script Date: 03/05/2013 14:34:59 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OrderDetailStatus_Company]') AND parent_object_id = OBJECT_ID(N'[dbo].[OrderDetailStatus]'))
ALTER TABLE [dbo].[OrderDetailStatus] DROP CONSTRAINT [FK_OrderDetailStatus_Company]
GO


/****** Object:  Table [dbo].[OrderDetailStatus]    Script Date: 03/05/2013 15:07:34 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OrderDetailStatus]') AND type in (N'U'))
DROP TABLE [dbo].[OrderDetailStatus]
GO


/****** Object:  Table [dbo].[OrderDetailStatus]    Script Date: 03/05/2013 15:07:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[OrderDetailStatus](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](512) NOT NULL,
	[Company] [int] NULL,
 CONSTRAINT [PK_OrderDetailStatus] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[OrderDetailStatus]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetailStatus_Company] FOREIGN KEY([Company])
REFERENCES [dbo].[Company] ([ID])
GO

ALTER TABLE [dbo].[OrderDetailStatus] CHECK CONSTRAINT [FK_OrderDetailStatus_Company]
GO


--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--**--** Insert Records to the OrderDetailStatus Table --**--**--**--**--**--**--**--**--**--**
	
INSERT INTO [dbo].[OrderDetailStatus] 
				  ([Name],
				   [Description],
				   [Company])
			VALUES( 'Submitted',
					'Factory Submitted',
					(SELECT [ID] FROM [dbo].[Company] WHERE [Name] = 'Factory'))	 
GO

INSERT INTO [dbo].[OrderDetailStatus] 
				  ([Name],
				   [Description],
				   [Company])
			VALUES( 'Printing',
					'Factory Printing',
					(SELECT [ID] FROM [dbo].[Company] WHERE [Name] = 'Factory'))
GO

INSERT INTO [dbo].[OrderDetailStatus] 
				  ([Name],
				   [Description],
				   [Company])
			VALUES( 'HeatPress',
					'Factory HeatPress',
					(SELECT [ID] FROM [dbo].[Company] WHERE [Name] = 'Factory'))
GO
					
INSERT INTO [dbo].[OrderDetailStatus] 
				  ([Name],
				   [Description],
				   [Company])
			VALUES( 'Sewing',
					'Factory Sewing',
					(SELECT [ID] FROM [dbo].[Company] WHERE [Name] = 'Factory'))
GO

INSERT INTO [dbo].[OrderDetailStatus] 
				  ([Name],
				   [Description],
				   [Company])
			VALUES( 'Packing',
					'Factory Packing',
					(SELECT [ID] FROM [dbo].[Company] WHERE [Name] = 'Factory'))					
GO

INSERT INTO [dbo].[OrderDetailStatus] 
				  ([Name],
				   [Description],
				   [Company])
			VALUES( 'Shipped',
					'Factory Shipped',
					(SELECT [ID] FROM [dbo].[Company] WHERE [Name] = 'Factory'))
GO

INSERT INTO [dbo].[OrderDetailStatus] 
				  ([Name],
				   [Description],
				   [Company])
			VALUES( 'Completed',
					'Factory Completed',
					(SELECT [ID] FROM [dbo].[Company] WHERE [Name] = 'Factory'))
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


--**--**--**--**--**--**--**--**Add Column to the OrderDetail Table --**--**--**--**--**--**--**--**--**--**--**--**--**

ALTER TABLE [dbo].[OrderDetail]
ADD [Status] [int] NULL
GO

ALTER TABLE [dbo].[OrderDetail] WITH CHECK ADD CONSTRAINT [FK_OrderDetail_Status] FOREIGN KEY([Status])
REFERENCES [dbo].[OrderDetailStatus] ([ID])
GO

ALTER TABLE [dbo].[OrderDetail] CHECK CONSTRAINT [FK_OrderDetail_Status]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
