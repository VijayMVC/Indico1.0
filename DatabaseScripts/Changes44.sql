USE [Indico]
GO
--**-**--**--**-**--**--**-**--** ADD New Currency For the Currency Table --**-**--**--**-**--**--**-**--**--**-**--**
    GO
INSERT INTO [dbo].[Currency]([Name], [Code], [Symbol])
     VALUES ('British Pound', 'GBP', '£')     
     Go
INSERT INTO [dbo].[Currency]([Name], [Code], [Symbol])
     VALUES ('EURO', 'EUR', '€')
     GO
INSERT INTO [dbo].[Currency]([Name], [Code], [Symbol])
     VALUES ('Japanese Yen', 'JPY', '¥')
     Go


--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

/****** Object:  Table [dbo].[EmailLogo]    Script Date: 05/09/2013 16:18:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EmailLogo]') AND type in (N'U'))
DROP TABLE [dbo].[EmailLogo]
GO

/****** Object:  Table [dbo].[EmailLogo]    Script Date: 05/09/2013 16:18:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[EmailLogo](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[EmailLogoPath] [nvarchar](256) NULL,
 CONSTRAINT [PK_EmailLogo] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmailLogo', @level2type=N'COLUMN',@level2name=N'ID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The email logo path' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmailLogo', @level2type=N'COLUMN',@level2name=N'EmailLogoPath'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmailLogo'
GO


--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**



--**-**--**--**--**-**--**--**--**-**--**--** DROP COLUMN VL Number in Quote Table --**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Quote_VLNumber]') AND parent_object_id = OBJECT_ID(N'[dbo].[Quote]'))
ALTER TABLE [dbo].[Quote] DROP CONSTRAINT [FK_Quote_VLNumber]
GO

ALTER TABLE [dbo].[Quote]
DROP COLUMN [VLNumber]
GO
--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

--**-**--**--**-**--**--**-**--**--**-**--** DROP COLUMN Client in Quote Table--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Quote_Client]') AND parent_object_id = OBJECT_ID(N'[dbo].[Quote]'))
ALTER TABLE [dbo].[Quote] DROP CONSTRAINT [FK_Quote_Client]
GO

ALTER TABLE [dbo].[Quote]
DROP COLUMN [Client]
GO
--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**

--**--**-**--**--**--**-**--**--**--**-**--** DROP COLUMN Distributor In Quote Table --**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Quote_Distributor]') AND parent_object_id = OBJECT_ID(N'[dbo].[Quote]'))
ALTER TABLE [dbo].[Quote] DROP CONSTRAINT [FK_Quote_Distributor]
GO


ALTER TABLE [dbo].[Quote]
DROP COLUMN [Distributor]
GO
--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**


--**--**-**--**--**--**-**--**--**--**-**--** Add new Column Currency for Quote Table --**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**

ALTER TABLE [dbo].[Quote]
ADD [Currency] [int] NULL
GO


ALTER TABLE [dbo].[Quote]  WITH CHECK ADD  CONSTRAINT [FK_Quote_Currency] FOREIGN KEY([Currency])
REFERENCES [dbo].[Currency] ([ID])
GO

ALTER TABLE [dbo].[Quote] CHECK CONSTRAINT [FK_Quote_Currency]
GO

--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**


--**--**-**--**--**--**-**--**--**--**-**--** Add new Column ShipmentDate for OrderDetail Table --**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**

ALTER TABLE [dbo].[OrderDetail]
ADD [ShipmentDate] [DateTime2](7) NULL
GO
--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**

--**--**-**--**--**--**-**--**--**--**-**--** Add new Column ShipmentDate for Shedula Date Table --**--**-**--**--**--**-**--**--**--**-**--**--**--**-

ALTER TABLE [dbo].[OrderDetail]
ADD [SheduleDate] [DateTime2](7) NULL
GO
--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**

--**--**-**--**--**--**-**--**--**--**-**--** Add new Column IsRepeat for Shedula Date Table --**--**-**--**--**--**-**--**--**--**-**--**--**--**-

ALTER TABLE [dbo].[OrderDetail]
ADD [IsRepeat] [bit] NOT NULL DEFAULT(0)
GO
--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**

--**-**--**--**--**-**--**--**--**-**--**--** DROP COLUMN IsRepeat Order Table--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**

ALTER TABLE [dbo].[Order]
DROP COLUMN [IsRepeat]
GO
--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**


--**-**--**--**--**-**--**--**--**-**--**--** Add EmailLogo Page to the Page table --**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**

INSERT INTO [Indico].[dbo].[Page]
           ([Name]
           ,[Title]
           ,[Heading])
     VALUES
           ('/EmailLogo.aspx'
            ,'Email Logo'
            ,'Email Logo')
GO

--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**


--**-**--**--**--**-**--**--**--**-**--**--** Add EmailLogo Page to MenuItemTab --**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**

DECLARE @MSATERTAB AS int
DECLARE @POSITION AS int
DECLARE @PAGE AS int

SET @MSATERTAB = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Name] = 'Master Data' AND [Parent] IS NULL)
SET @POSITION =  (SELECT MAX(Position)+1 FROM [dbo].[MenuItem] WHERE [Parent] = @MSATERTAB)
SET @PAGE =		 (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/EmailLogo.aspx') 

INSERT INTO [Indico].[dbo].[MenuItem]
           ([Page]
           ,[Name]
           ,[Description]
           ,[IsActive]
           ,[Parent]
           ,[Position]
           ,[IsVisible])
     VALUES
           (@PAGE
           ,'Email Logo'
           ,'Email Logo'
           ,1
           ,@MSATERTAB
           ,@POSITION
           ,1)
GO

--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**

--**-**--**--**--**-**--**--**--**-**--**--** Add MenuItemRole for EmailLogo Page Indico Administrator  --**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**
DECLARE @ROLE AS int
DECLARE @MENUITEM AS int
DECLARE @PAGE AS int
DECLARE @MSATERTAB AS int

SET @PAGE =		 (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/EmailLogo.aspx') 
SET @MSATERTAB = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Name] = 'Master Data' AND [Parent] IS NULL)
SET @MENUITEM =  (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Parent] = @MSATERTAB AND [Page] = @PAGE)
SET @ROLE =      (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indico Administrator')

INSERT INTO [Indico].[dbo].[MenuItemRole]
           ([MenuItem]
           ,[Role])
     VALUES
           (@MENUITEM
           ,@ROLE)
GO
--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**

--**-**--**--**--**-**--**--**--**-**--**--** Add MenuItemRole for EmailLogo Page Indiman Administrator  --**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**

DECLARE @ROLE AS int
DECLARE @MENUITEM AS int
DECLARE @PAGE AS int
DECLARE @MSATERTAB AS int

SET @PAGE =		 (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/EmailLogo.aspx') 
SET @MSATERTAB = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Name] = 'Master Data' AND [Parent] IS NULL)
SET @MENUITEM =  (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Parent] = @MSATERTAB AND [Page] = @PAGE)
SET @ROLE =      (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')

INSERT INTO [Indico].[dbo].[MenuItemRole]
           ([MenuItem]
           ,[Role])
     VALUES
           (@MENUITEM
           ,@ROLE)
GO
--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**

--**-**--**--**--**-**--**--**--**-**--**--** Change MenuItem Position --**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**

DECLARE @MAINMENUITEM AS int
DECLARE @MENUITEM AS int

SET @MAINMENUITEM = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Name] = 'Master Data' AND [Parent] IS NULL)
SET @MENUITEM = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Name] = 'Email Logo' AND [Parent] = @MAINMENUITEM)


UPDATE [dbo].[MenuItem] SET [Position] = 3 WHERE [ID] = @MENUITEM
GO

DECLARE @MAINMENUITEM AS int
DECLARE @MENUITEM AS int

SET @MAINMENUITEM = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Name] = 'Master Data' AND [Parent] IS NULL)
SET @MENUITEM = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Name] = 'Gender' AND [Parent] = @MAINMENUITEM)


UPDATE [dbo].[MenuItem] SET [Position] = 4 WHERE [ID] = @MENUITEM
GO

DECLARE @MAINMENUITEM AS int
DECLARE @MENUITEM AS int

SET @MAINMENUITEM = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Name] = 'Master Data' AND [Parent] IS NULL)
SET @MENUITEM = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Name] = 'Printers' AND [Parent] = @MAINMENUITEM)


UPDATE [dbo].[MenuItem] SET [Position] = 5 WHERE [ID] = @MENUITEM
GO

DECLARE @MAINMENUITEM AS int
DECLARE @MENUITEM AS int

SET @MAINMENUITEM = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Name] = 'Master Data' AND [Parent] IS NULL)
SET @MENUITEM = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Name] = 'Print Types' AND [Parent] = @MAINMENUITEM)


UPDATE [dbo].[MenuItem] SET [Position] = 6 WHERE [ID] = @MENUITEM
GO

DECLARE @MAINMENUITEM AS int
DECLARE @MENUITEM AS int

SET @MAINMENUITEM = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Name] = 'Master Data' AND [Parent] IS NULL)
SET @MENUITEM = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Name] = 'Production Lines' AND [Parent] = @MAINMENUITEM)


UPDATE [dbo].[MenuItem] SET [Position] = 7 WHERE [ID] = @MENUITEM
GO

DECLARE @MAINMENUITEM AS int
DECLARE @MENUITEM AS int

SET @MAINMENUITEM = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Name] = 'Master Data' AND [Parent] IS NULL)
SET @MENUITEM = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Name] = 'Resolution Profiles' AND [Parent] = @MAINMENUITEM)


UPDATE [dbo].[MenuItem] SET [Position] = 8 WHERE [ID] = @MENUITEM
GO

DECLARE @MAINMENUITEM AS int
DECLARE @MENUITEM AS int

SET @MAINMENUITEM = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Name] = 'Master Data' AND [Parent] IS NULL)
SET @MENUITEM = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Name] = 'Sizes' AND [Parent] = @MAINMENUITEM)


UPDATE [dbo].[MenuItem] SET [Position] = 9 WHERE [ID] = @MENUITEM
GO

DECLARE @MAINMENUITEM AS int
DECLARE @MENUITEM AS int

SET @MAINMENUITEM = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Name] = 'Master Data' AND [Parent] IS NULL)
SET @MENUITEM = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Name] = 'Size Sets' AND [Parent] = @MAINMENUITEM)


UPDATE [dbo].[MenuItem] SET [Position] = 10 WHERE [ID] = @MENUITEM
GO

--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**

--**-**--**--**--**-**--**--**--**-**--**--** Change MenuItem Name --**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**

DECLARE @MENUITEM AS int
DECLARE @PAGE AS int

SET @PAGE =		 (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewFabricCodes.aspx') 
SET @MENUITEM = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Name] = 'Fabric Codes' AND [Page] = @PAGE)

UPDATE [dbo].[MenuItem] SET [Name] = 'Fabrics' WHERE [ID] = @MENUITEM
GO

DECLARE @MENUITEM AS int
DECLARE @PAGE AS int

SET @PAGE =		 (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewFabricCodes.aspx') 
SET @MENUITEM = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Name] = 'Fabric Codes' AND [Page] = @PAGE)
UPDATE [dbo].[MenuItem] SET [Description] = 'Fabrics' WHERE [ID] = @MENUITEM
GO

--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**--**--**-**--**
