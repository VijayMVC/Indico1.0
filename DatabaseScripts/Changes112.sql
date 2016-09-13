USE [Indico]
GO

/****** Object:  Table [dbo].[DesignType]    Script Date: 10/03/2014 14:39:46 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DesignType]') AND type in (N'U'))
DROP TABLE [dbo].[DesignType]
GO

/****** Object:  Table [dbo].[DesignType]    Script Date: 10/03/2014 14:39:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DesignType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](255) NULL,
CONSTRAINT [PK_DesignType] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**
DELETE FROM [dbo].[Quote]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Quote_Pattern]') AND parent_object_id = OBJECT_ID(N'[dbo].[Quote]'))
ALTER TABLE [dbo].[Quote] DROP CONSTRAINT [FK_Quote_Pattern]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Quote_Fabric]') AND parent_object_id = OBJECT_ID(N'[dbo].[Quote]'))
ALTER TABLE [dbo].[Quote] DROP CONSTRAINT [FK_Quote_Fabric]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Quote_PriceTerm]') AND parent_object_id = OBJECT_ID(N'[dbo].[Quote]'))
ALTER TABLE [dbo].[Quote] DROP CONSTRAINT [FK_Quote_PriceTerm]
GO


ALTER TABLE [dbo].[Quote]
DROP COLUMN [Pattern]
GO 

ALTER TABLE [dbo].[Quote]
DROP COLUMN [Fabric]
GO

ALTER TABLE [dbo].[Quote]
DROP COLUMN [Qty]
GO

ALTER TABLE [dbo].[Quote]
DROP COLUMN [DeliveryDate]
GO

ALTER TABLE [dbo].[Quote]
DROP COLUMN [PriceTerm]
GO


ALTER TABLE [dbo].[Quote]
DROP COLUMN [Notes]
GO

CREATE TABLE [dbo].[QuoteDetail](
[ID] [int] IDENTITY(1,1) NOT NULL,
[Pattern] [int] NOT NULL,
[Fabric] [int] NOT NULL,
[PriceTerm] [int] NULL,
[DesignType] [int] NULL,
[Unit] [int] NULL,
[IsGST] [bit] NULL,
[GST] decimal(8,2) NULL,
[IndimanPrice] decimal(8,2) NULL,
[Notes] [nvarchar] (255) NULL,
[DelivaryDate] [datetime2] (7)NULL,
[Qty] [int] NOT NULL,
CONSTRAINT [PK_QuoteDetail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[QuoteDetail] WITH CHECK ADD CONSTRAINT [FK_QuoteDetail_Pattern] FOREIGN KEY ([Pattern])
REFERENCES [dbo].[Pattern] ([ID])
GO

ALTER TABLE [dbo].[QuoteDetail] CHECK CONSTRAINT [FK_QuoteDetail_Pattern]
GO

ALTER TABLE [dbo].[QuoteDetail] WITH CHECK ADD CONSTRAINT [FK_QuoteDetail_Fabric] FOREIGN KEY([Fabric])
REFERENCES [dbo].[FabricCode] ([ID])
GO

ALTER TABLE [dbo].[QuoteDetail] CHECK CONSTRAINT [FK_QuoteDetail_Fabric]
GO


ALTER TABLE [dbo].[QuoteDetail] WITH CHECK ADD CONSTRAINT [FK_QuoteDetail_PriceTerm] FOREIGN KEY ([PriceTerm])
REFERENCES [dbo].[PriceTerm] ([ID])
GO

ALTER TABLE [dbo].[QuoteDetail] CHECK CONSTRAINT [FK_QuoteDetail_PriceTerm]
GO

ALTER TABLE [dbo].[QuoteDetail] WITH CHECK ADD CONSTRAINT [FK_QuoteDetail_DesignType] FOREIGN KEY ([DesignType])
REFERENCES [dbo].[DesignType] ([ID])
GO

ALTER TABLE [dbo].[QuoteDetail] CHECK CONSTRAINT [FK_QuoteDetail_DesignType]
GO

ALTER TABLE [dbo].[QuoteDetail] WITH CHECK ADD CONSTRAINT [FK_QuoteDetail_Unit] FOREIGN KEY ([Unit])
REFERENCES [dbo].[Unit] ([ID])
GO

ALTER TABLE [dbo].[QuoteDetail] CHECK CONSTRAINT [FK_QuoteDetail_Unit]
GO

--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**

INSERT INTO [Indico].[dbo].[DesignType] ([Name], [Description]) VALUES ('Creative Design', 'Creative Design')
GO

INSERT INTO [Indico].[dbo].[DesignType] ([Name], [Description]) VALUES ('Studio Design', 'Studio Design')
GO

INSERT INTO [Indico].[dbo].[DesignType] ([Name], [Description]) VALUES ('Third Party Design', 'Third Party Design')
GO
--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**


ALTER TABLE [dbo].[Pattern]
ADD [Description] [nvarchar](700) NULL
GO

--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**

/****** Object:  View [dbo].[QuotesDetailsView]    Script Date: 10/20/2014 11:22:01 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[QuotesDetailsView]'))
DROP VIEW [dbo].[QuotesDetailsView]
GO

/****** Object:  View [dbo].[QuotesDetailsView]    Script Date: 10/20/2014 11:22:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[QuotesDetailsView]
AS

SELECT q.[ID] AS Quote
      ,q.[DateQuoted] AS DateQuoted
      ,q.[QuoteExpiryDate] AS QuoteExpiryDate
      ,q.[ClientEmail] AS ClietEMail
      ,q.[JobName] AS JobName      
      ,qs.[Name] AS [Status]
      ,q.[ContactName] AS ContactName
      ,u.[GivenName] + ' ' + u.[FamilyName] AS Creator      
      ,ISNULL(c.[Name], '') AS Distributor
  FROM [Indico].[dbo].[Quote] q		
	JOIN [dbo].[QuoteStatus] qs
		ON q.[Status] = qs.[ID]
	JOIN [dbo].[User] u
		ON q.[Creator] = u.[ID] 
	LEFT OUTER JOIN [dbo].[Company] c
		ON q.[Distributor] = c.[ID]
		


GO

--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**
ALTER TABLE [dbo].[Quote]
DROP COLUMN [IndimanPrice]
GO
--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**

ALTER TABLE [dbo].[QuoteDetail]
ADD [DesignFee] [decimal](8,2) NULL
GO

--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**

ALTER TABLE [dbo].[QuoteDetail]
ADD [Quote] [int] NOT NULL;
GO

ALTER TABLE [dbo].[QuoteDetail] WITH CHECK ADD CONSTRAINT [FK_QuoteDetail_Quote] FOREIGN KEY ([Quote])
REFERENCES [dbo].[Quote] ([ID])
GO

ALTER TABLE [dbo].[QuoteDetail] CHECK CONSTRAINT [FK_QuoteDetail_Quote]
GO
--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**

ALTER TABLE [dbo].[Pattern]
ALTER COLUMN [PatternNotes] [nvarchar](1024) NULL
GO

--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**

ALTER TABLE [dbo].[QuoteDetail]
ADD [VisualLayout] [int] NULL
GO

ALTER TABLE [dbo].[QuoteDetail] WITH CHECK ADD CONSTRAINT [FK_QuoteDetail_VisualLayout] FOREIGN KEY ([VisualLayout])
REFERENCES [dbo].[VisualLayout] ([ID])
GO

ALTER TABLE [dbo].[QuoteDetail] CHECK CONSTRAINT [FK_QuoteDetail_VisualLayout]
GO
--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**
	DECLARE @RetVal int
	DECLARE @OrderDetailID INT
	DECLARE @PackingListID INT
	DECLARE @WeeklyProductionCapacityID INT
	DECLARE @CartonNo INT	
	DECLARE @OrderDetailStatus INT
	DECLARE @TempOrderDetail TABLE 
	(
		ID INT NOT NULL
	)
	
	DECLARE @TempOrderDetailQty TABLE 
	(
		ID INT NOT NULL,
		Size INT NOT NULL,
		Qty INT NOT NULL
	)
	
	--SET @OrderDetailStatus = ( SELECT ID FROM [dbo].[OrderDetailStatus] WHERE [Name] = 'ODS Printed' OR [Name] = 'Pre Shipped')
	
	BEGIN TRY
		
		SET @CartonNo = 0
	
		INSERT INTO @TempOrderDetail (ID)
		SELECT ID FROM [dbo].[OrderDetail] od
		WHERE (od.[Status] IS NULL 
			OR od.[Status] IN (( SELECT ID FROM [dbo].[OrderDetailStatus] WHERE [Name] = 'ODS Printed' OR [Name] = 'Pre Shipped')))
			AND od.[Order] IN (13340,13341,13342,13343,13344,13345,13346,13347,13348,13349,13350)
			AND (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, '10-24-2014'), 0) AS DATE) 
			AND DATEADD(day, 2, CONVERT (date, '10-24-2014')))			 
	
		WHILE EXISTS(SELECT * FROM @TempOrderDetail )
			BEGIN	
				
				SET @CartonNo = @CartonNo + 1
				SET @OrderDetailID = (SELECT TOP 1 ID FROM @TempOrderDetail)				
				
				DELETE FROM @TempOrderDetailQty
				
				INSERT INTO @TempOrderDetailQty (ID, Size, Qty)
				SELECT ID, Size, Qty FROM [dbo].OrderDetailQty 
				WHERE OrderDetail = @OrderDetailID AND Qty > 0
				
				IF ((SELECT COUNT(ID) FROM @TempOrderDetailQty)> 0)
					BEGIN					
						SET @WeeklyProductionCapacityID = (SELECT ID FROM [dbo].WeeklyProductionCapacity WHERE WeekendDate = '10-24-2014')
					
						INSERT INTO [dbo].[PackingList]
								   ([CartonNo]
								   ,[WeeklyProductionCapacity]
								   ,[OrderDetail]
								   ,[PackingQty]
								   ,[Carton]
								   ,[Remarks]
								   ,[Creator]
								   ,[CreatedDate]
								   ,[Modifier]
								   ,[ModifiedDate])
						VALUES
						   (0
						   ,@WeeklyProductionCapacityID
						   ,@OrderDetailID
						   ,0
						   ,1
						   ,''
						   ,1
						   , (SELECT (GETDATE()))
						   ,1
						   , (SELECT (GETDATE())))						   					
						
						SET @PackingListID = SCOPE_IDENTITY()
						
						WHILE EXISTS(SELECT * FROM @TempOrderDetailQty )
							BEGIN	
								
								INSERT INTO [Indico].[dbo].[PackingListSizeQty]
									   ([PackingList]
									   ,[Size]
									   ,[Qty])
								 VALUES
									    (@PackingListID
									   ,(SELECT TOP 1 Size FROM @TempOrderDetailQty)
									   ,(SELECT TOP 1 Qty FROM @TempOrderDetailQty))
																							
								DELETE TOP(1) FROM @TempOrderDetailQty				
							END							
				END				
				
			DELETE TOP(1) FROM @TempOrderDetail
		END	
			
		SET @RetVal = 1	
	END TRY
	BEGIN CATCH
		SET @RetVal = 0
	END CATCH
	
--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**
/****** Object:  StoredProcedure [dbo].[SPC_CreatePackingList]    Script Date: 10/22/2014 14:02:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_CreatePackingList]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_CreatePackingList]
GO

/****** Object:  StoredProcedure [dbo].[SPC_CreatePackingList]    Script Date: 10/22/2014 14:02:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SPC_CreatePackingList]
(
	@P_WeekEndDate Datetime,
	@P_Creator INT
)
AS BEGIN
	
	DECLARE @RetVal int
	DECLARE @OrderDetailID INT
	DECLARE @PackingListID INT
	DECLARE @WeeklyProductionCapacityID INT
	DECLARE @CartonNo INT	
	DECLARE @OrderDetailStatus INT
	DECLARE @TempOrderDetail TABLE 
	(
		ID INT NOT NULL
	)
	
	DECLARE @TempOrderDetailQty TABLE 
	(
		ID INT NOT NULL,
		Size INT NOT NULL,
		Qty INT NOT NULL
	)
	
	--SET @OrderDetailStatus = ( SELECT ID FROM [dbo].[OrderDetailStatus] WHERE [Name] = 'ODS Printed' )
	
	BEGIN TRY
		
		SET @CartonNo = 0
	
		INSERT INTO @TempOrderDetail (ID)
		SELECT ID FROM [dbo].[OrderDetail] od
		WHERE (od.[Status] IS NULL 
			OR od.[Status] IN (( SELECT ID FROM [dbo].[OrderDetailStatus] WHERE [Name] = 'ODS Printed' OR [Name] = 'Pre Shipped')))
			AND (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) 
			AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))			 
	
		WHILE EXISTS(SELECT * FROM @TempOrderDetail )
			BEGIN	
				
				SET @CartonNo = @CartonNo + 1
				SET @OrderDetailID = (SELECT TOP 1 ID FROM @TempOrderDetail)				
				
				DELETE FROM @TempOrderDetailQty
				
				INSERT INTO @TempOrderDetailQty (ID, Size, Qty)
				SELECT ID, Size, Qty FROM [dbo].OrderDetailQty 
				WHERE OrderDetail = @OrderDetailID AND Qty > 0
				
				IF ((SELECT COUNT(ID) FROM @TempOrderDetailQty)> 0)
					BEGIN					
						SET @WeeklyProductionCapacityID = (SELECT ID FROM [dbo].WeeklyProductionCapacity WHERE WeekendDate = @P_WeekendDate)
					
						INSERT INTO [dbo].[PackingList]
								   ([CartonNo]
								   ,[WeeklyProductionCapacity]
								   ,[OrderDetail]
								   ,[PackingQty]
								   ,[Carton]
								   ,[Remarks]
								   ,[Creator]
								   ,[CreatedDate]
								   ,[Modifier]
								   ,[ModifiedDate])
						VALUES
						   (0
						   ,@WeeklyProductionCapacityID
						   ,@OrderDetailID
						   ,0
						   ,1
						   ,''
						   ,@P_Creator
						   , (SELECT (GETDATE()))
						   ,@P_Creator
						   , (SELECT (GETDATE())))						   					
						
						SET @PackingListID = SCOPE_IDENTITY()
						
						WHILE EXISTS(SELECT * FROM @TempOrderDetailQty )
							BEGIN	
								
								INSERT INTO [Indico].[dbo].[PackingListSizeQty]
									   ([PackingList]
									   ,[Size]
									   ,[Qty])
								 VALUES
									    (@PackingListID
									   ,(SELECT TOP 1 Size FROM @TempOrderDetailQty)
									   ,(SELECT TOP 1 Qty FROM @TempOrderDetailQty))
																							
								DELETE TOP(1) FROM @TempOrderDetailQty				
							END							
				END				
				
			DELETE TOP(1) FROM @TempOrderDetail
		END	
			
		SET @RetVal = 1	
	END TRY
	BEGIN CATCH
		SET @RetVal = 0
	END CATCH
	
	SELECT @RetVal AS RetVal
END
GO

--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**



