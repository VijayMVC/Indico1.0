USE [Indico]
Go

--**--**--**--**--**--**--**--**--**--**Add New Page to the View Indiman Invoice --**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

DECLARE @Page AS int
DECLARE @ParentPage AS int 
DECLARE @Parent AS int
DECLARE @Role AS int
DECLARE @MenuItem AS int 
DECLARE @Position AS int 

INSERT INTO [Indico].[dbo].[Page] ([Name], [Title], [Heading]) VALUES ('/ViewIndimanInvoices.aspx', 'Indiman Invoices', 'Indiman Invoices')

SET @Page = SCOPE_IDENTITY();


SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewInvoices.aspx')

SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)

SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')

SET @Position = (SELECT MAX([Position])+1 FROM [dbo].[MenuItem] WHERE [Parent] = @Parent)

INSERT INTO [Indico].[dbo].[MenuItem] ([Page], [Name], [Description], [IsActive], [Parent], [Position], [IsVisible])
     VALUES (@Page, 'Indiman Invoices', 'Indiman Invoices', 1, @Parent, @Position, 1)

SET @MenuItem = SCOPE_IDENTITY()


INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem ,@Role)
GO


--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


--**--**--**--**--**--**--**--**--**--**Add New Page to the AddEdit Indiman Invoice --**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

DECLARE @Page AS int
DECLARE @ParentPage AS int 
DECLARE @Parent AS int
DECLARE @Role AS int
DECLARE @MenuItem AS int 
DECLARE @Position AS int 
DECLARE @P as Int 
DECLARE @CPage AS int

INSERT INTO [Indico].[dbo].[Page] ([Name], [Title], [Heading]) VALUES ('/AddEditIndimanInvoice.aspx', 'Indiman Invoice', 'Indiman Invoice')

SET @Page = SCOPE_IDENTITY();


SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewInvoices.aspx')

SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)

SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')

SET @CPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewIndimanInvoices.aspx')

SET @P = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @CPage AND [Parent] = @Parent)

SET @Position = (SELECT [Position] FROM [dbo].[MenuItem] WHERE [Page] = @CPage)


INSERT INTO [Indico].[dbo].[MenuItem] ([Page], [Name], [Description], [IsActive], [Parent], [Position], [IsVisible])
     VALUES (@Page, 'Indiman Invoice', 'Indiman Invoice', 1, @P, @Position, 0)

SET @MenuItem = SCOPE_IDENTITY()


INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem ,@Role)
GO


--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--**--**Add Update AddEdit Indiman Invoice --**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

DECLARE @Page AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewInvoices.aspx')

UPDATE [Indico].[dbo].[Page] SET [Title] = 'Factory Invoices', [Heading] = 'Factory Invoices' WHERE [ID] = @Page

UPDATE [dbo].[MenuItem] SET [Name] = 'Factory Invoices', [Description] = 'Factory Invoices' WHERE [Page] = @Page AND [Parent] IS NOT NULL
GO

DECLARE @Page AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/AddEditInvoice.aspx')

UPDATE [Indico].[dbo].[Page] SET [Title] = 'Factory Invoice', [Heading] = 'Factory Invoice' WHERE [ID] = @Page

UPDATE [dbo].[MenuItem] SET [Name] = 'Factory Invoice', [Description] = 'Factory Invoice' WHERE [Page] = @Page AND [Parent] IS NOT NULL
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**-**-**-**--**-**-**-**--**-**-**-** Create Sp for Get Cartons Details --**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**

/****** Object:  StoredProcedure [dbo].[SPC_GetCartonsDetails]    Script Date: 01/30/2014 10:21:22 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetCartonsDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetCartonsDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetCartonsDetails]    Script Date: 01/30/2014 10:21:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPC_GetCartonsDetails] (	
@P_WeekEndDate datetime2(7) 
)	
AS 
BEGIN

	  SELECT pl.[CartonNo] AS 'Carton' 
		    ,ISNULL((SELECT SUM(plci.[Count]) FROM [dbo].[PackingListCartonItem] plci WHERE plci.[PackingList] = pl.[ID]),0) AS 'FillQty'
		    ,ISNULL((SELECT SUM(plsq.[Qty]) FROM [dbo].[PackingListSizeQty] plsq WHERE plsq.[PackingList] = pl.[ID]), 0) AS 'TotalQty'
	  FROM [Indico].[dbo].[PackingList] pl
	  JOIN [dbo].[OrderDetail] od 
		ON pl.[OrderDetail] = od.[ID]
	  WHERE (od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate)
  
 END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**-**-**-**--**-**-**-**--**-**-**-** Create View for Return Cartons Details --**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**

/****** Object:  View [dbo].[ReturnCartonsDetailsView]    Script Date: 01/30/2014 10:28:35 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnCartonsDetailsView]'))
DROP VIEW [dbo].[ReturnCartonsDetailsView]
GO


/****** Object:  View [dbo].[ReturnCartonsDetailsView]    Script Date: 01/30/2014 10:28:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ReturnCartonsDetailsView]
AS
			SELECT 0 AS 'Carton'
				  ,0 AS 'FillQty'
				  ,0 AS 'TotalQty'
				  

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
