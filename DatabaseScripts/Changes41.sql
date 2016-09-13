USE [Indico]
GO
--**--**--**--**--**--**--**--**--** Change the Brett User Role --**--**--**--**--**--**--**--**--**--**--**--**

DECLARE @USERID AS int 
DECLARE @ROLEID AS INT

SET @USERID = (SELECT [ID] FROM [dbo].[User] WHERE [Username] = 'brettm')
SET @ROLEID = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indico Administrator')

UPDATE [dbo].[UserRole] SET [Role] = @ROLEID WHERE [User] = @USERID
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Rename the RequestedQuoteStatus table to QuoteStatus --**--**--**--**--**

SP_RENAME '[Indico].[dbo].[RequestedQuoteStatus]', 'QuoteStatus'
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--**--**--**--** Insert New Records to QuotesStatus Table --**--**--**--**--**--**--**--**

INSERT INTO [dbo].[QuoteStatus] ([Key], [Name]) 
VALUES ( 'I',
		 'In Progress'
	   )
GO

INSERT INTO [dbo].[QuoteStatus] ([Key], [Name]) 
VALUES ( 'O',
		 'On Hold'
	   )
GO

INSERT INTO [dbo].[QuoteStatus] ([Key], [Name]) 
VALUES ( 'C',
		 'Cancelled'
	   )
GO

INSERT INTO [dbo].[QuoteStatus] ([Key], [Name]) 
VALUES ( 'E',
		 'Expired'
	   )
GO

INSERT INTO [dbo].[QuoteStatus] ([Key], [Name]) 
VALUES ( 'CO',
		 'Completed'
	   )
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--**--**--**--** Add [status] Column to the Quote Table --**--**--**--**--**--**--**--**

ALTER TABLE [dbo].[Quote]
ADD [Status] [int] NULL 
GO



ALTER TABLE [dbo].[Quote]  WITH CHECK ADD  CONSTRAINT [FK_Quote_Status] FOREIGN KEY([Status])
REFERENCES [dbo].[QuoteStatus] ([ID])
GO

ALTER TABLE [dbo].[Quote] CHECK CONSTRAINT [FK_Quote_Status]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--** Update the status column for all records --**--**--**--**--**--**--**--**--**--**--**--**

UPDATE [dbo].[Quote] SET [Status] = 1 
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--** Quote table status column change to the Not NUll column --**--**--**--**--**--**--**--**--**--**--**--**

ALTER TABLE [dbo].[Quote]
ALTER COLUMN [Status] [int] NOT NULL 
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--** Drop the [RequestedQuote] Table--**--**--**--**--**--**--**--**--**--**--**--**

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_RequestedQuote_Company]') AND parent_object_id = OBJECT_ID(N'[dbo].[RequestedQuote]'))
ALTER TABLE [dbo].[RequestedQuote] DROP CONSTRAINT [FK_RequestedQuote_Company]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_RequestedQuote_Status]') AND parent_object_id = OBJECT_ID(N'[dbo].[RequestedQuote]'))
ALTER TABLE [dbo].[RequestedQuote] DROP CONSTRAINT [FK_RequestedQuote_Status]
GO

USE [Indico]
GO

/****** Object:  Table [dbo].[RequestedQuote]    Script Date: 05/06/2013 15:44:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RequestedQuote]') AND type in (N'U'))
DROP TABLE [dbo].[RequestedQuote]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--** DROP Column Accessory  from PatternAccessory table --**--**--**--**--**--**--**--**--**--**--**--**

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PatternAccessory_Accessory]') AND parent_object_id = OBJECT_ID(N'[dbo].[PatternAccessory]'))
ALTER TABLE [dbo].[PatternAccessory] DROP CONSTRAINT [FK_PatternAccessory_Accessory]
GO

ALTER TABLE [dbo].[PatternAccessory] 
DROP COLUMN [Accessory]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--** DROP Column Accessory  from VisualLayoutAccessory Table --**--**--**--**--**--**--**--**--**--**--**--**
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_VisualLayoutAccessory_Accessory]') AND parent_object_id = OBJECT_ID(N'[dbo].[VisualLayoutAccessory]'))
ALTER TABLE [dbo].[VisualLayoutAccessory] DROP CONSTRAINT [FK_VisualLayoutAccessory_Accessory]
GO

ALTER TABLE [dbo].[VisualLayoutAccessory] 
DROP COLUMN [Accessory]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


INSERT INTO [Indico].[dbo].[AccessoryColor]
           ([Name]
           ,[Code]
           ,[ColorValue])
     VALUES
           ('White',
           'W', 
           '#FFFFFF')
GO


INSERT INTO [Indico].[dbo].[AccessoryColor]
           ([Name]
           ,[Code]
           ,[ColorValue])
     VALUES
           ('Yellow',
           'Y', 
           '#FFFF00')
GO

INSERT INTO [Indico].[dbo].[AccessoryColor]
           ([Name]
           ,[Code]
           ,[ColorValue])
     VALUES
           ('Fuchsia',
           'F', 
           '#FF00FF')
GO

INSERT INTO [Indico].[dbo].[AccessoryColor]
           ([Name]
           ,[Code]
           ,[ColorValue])
     VALUES
           ('Silver',
           'S', 
           '#C0C0C0')
GO

INSERT INTO [Indico].[dbo].[AccessoryColor]
           ([Name]
           ,[Code]
           ,[ColorValue])
     VALUES
           ('Gray',
           'GR', 
           '#808080')
GO

INSERT INTO [Indico].[dbo].[AccessoryColor]
           ([Name]
           ,[Code]
           ,[ColorValue])
     VALUES
           ('Olive',
           'OL', 
           '#808000')
GO

INSERT INTO [Indico].[dbo].[AccessoryColor]
           ([Name]
           ,[Code]
           ,[ColorValue])
     VALUES
           ('Purple',
           'P', 
           '#800080')
GO

INSERT INTO [Indico].[dbo].[AccessoryColor]
           ([Name]
           ,[Code]
           ,[ColorValue])
     VALUES
           ('Maroon',
           'M', 
           '#800000')
GO

INSERT INTO [Indico].[dbo].[AccessoryColor]
           ([Name]
           ,[Code]
           ,[ColorValue])
     VALUES
           ('Aqua',
           'A', 
           '#00FFFF')
GO

INSERT INTO [Indico].[dbo].[AccessoryColor]
           ([Name]
           ,[Code]
           ,[ColorValue])
     VALUES
           ('Lime',
           'L', 
           '#00FF00')
GO

INSERT INTO [Indico].[dbo].[AccessoryColor]
           ([Name]
           ,[Code]
           ,[ColorValue])
     VALUES
           ('Teal',
           'T', 
           '#008080')
GO

INSERT INTO [Indico].[dbo].[AccessoryColor]
           ([Name]
           ,[Code]
           ,[ColorValue])
     VALUES
           ('Navy',
           'N', 
           '#000080')
GO

INSERT INTO [Indico].[dbo].[AccessoryColor]
           ([Name]
           ,[Code]
           ,[ColorValue])
     VALUES
           ('Black',
           'BL', 
           '#000000')
GO

UPDATE [dbo].[AccessoryColor] SET [ColorValue] = '#FF0000' WHERE [Name] = 'Red'
GO

UPDATE [dbo].[AccessoryColor] SET [ColorValue] = '#008000' WHERE [Name] = 'Green'
GO

UPDATE [dbo].[AccessoryColor] SET [ColorValue] = '#0000FF' WHERE [Name] = 'Blue'
GO