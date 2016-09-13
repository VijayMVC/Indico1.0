USE [Indico]
GO

--**-**--**--**-**--**--**-**--**--**-**--** Add the new column to the Quote Table Contact Name --**-**--**--**-**--**--**-**--**--**-**--**
ALTER TABLE [dbo].[Quote]
ADD [ContactName] [nvarchar] (128)
GO
--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

UPDATE [dbo].[Quote] SET [ContactName] = 'Test'


--**-**--**--**-**--**--**-**--** Change the NULL to NOTNULL COLUMN ContactName --**-**--**--**-**--**--**-**--**--**-**--**
ALTER TABLE [dbo].[Quote]
ALTER COLUMN [ContactName] [nvarchar] (128) NOT NULL
GO
--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

--**-**--**--**-**--**--**-**--**--**-**--** Add New Column to Quote [Creater]--**-**--**--**-**--**--**-**--**--**-**--**

ALTER TABLE [dbo].[Quote]
ADD [Creator] [int] NULL
GO 
--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

UPDATE [dbo].[Quote] SET [Creator] = 5 

--**-**--**--**-**--**--**-**--** Change the NULL to NOTNULL COLUMN Creator --**-**--**--**-**--**--**-**--**--**-**--**
ALTER TABLE [dbo].[Quote]
ALTER COLUMN [Creator] [int] NOT NULL
GO

ALTER TABLE [dbo].[Quote]  WITH CHECK ADD  CONSTRAINT [FK_Quote_Creator] FOREIGN KEY([Creator])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[Quote] CHECK CONSTRAINT [FK_Quote_Creator]
GO
--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**


--**-**--**--**-**--**--**-**--**--**-**--** Add New Column to Quote [CreatedDate]--**-**--**--**-**--**--**-**--**--**-**--**

ALTER TABLE [dbo].[Quote]
ADD [CreatedDate] [DATETIME2](7) NULL
GO 
--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**


UPDATE [dbo].[Quote] SET [CreatedDate] = (SELECT GETDATE())

--**--**--**--**--**--**--**--**--**--**--** Alter Column CreatedDate in Quote Table--**--**--**--**--**--**--**--**--**
ALTER TABLE [dbo].[Quote]
ALTER COLUMN [CreatedDate] [DATETIME2](7) NOT NULL
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**-**--**--**-**--**--**-**--**--**-**--** Add New Column to Quote [CreatedDate]--**-**--**--**-**--**--**-**--**--**-**--**

ALTER TABLE [dbo].[Quote]
ADD [Modifier] [int] NULL
GO 
--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

UPDATE [dbo].[Quote] SET [Modifier] = 5 

--**-**--**--**-**--**--**-**--** Change the NULL to NOTNULL COLUMN Modifier --**-**--**--**-**--**--**-**--**--**-**--**
ALTER TABLE [dbo].[Quote]
ALTER COLUMN [Modifier] [int] NOT NULL
GO

ALTER TABLE [dbo].[Quote]  WITH CHECK ADD  CONSTRAINT [FK_Quote_Modifier] FOREIGN KEY([Modifier])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[Quote] CHECK CONSTRAINT [FK_Quote_Modifier]
GO
--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

--**-**--**--**-**--**--**-**--**--**-**--** Add New Column to Quote [ModifiedDate]--**-**--**--**-**--**--**-**--**--**-**--**

ALTER TABLE [dbo].[Quote]
ADD [ModifiedDate] [DATETIME2](7) NULL
GO 
--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**


UPDATE [dbo].[Quote] SET [ModifiedDate] = (SELECT GETDATE())

--**--**--**--**--**--**--**--**--**--**--** Alter Column ModifiedDate in Quote Table--**--**--**--**--**--**--**--**--**
ALTER TABLE [dbo].[Quote]
ALTER COLUMN [ModifiedDate] [DATETIME2](7) NOT NULL
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**