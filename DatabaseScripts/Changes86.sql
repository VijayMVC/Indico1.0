USE [Indico]
GO

--**--***-**--**--***-**--**--***-** ADD Column Port in to the [DistributorClientAddress]--**--***-**--**--***-**--**--***-**

ALTER TABLE [dbo].[DistributorClientAddress]
ADD [Port] [nvarchar] (100) NULL
GO

--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**

--**--***-**--**--***-**--**--***-** ADD two column to the CostSheet Table --**--***-**--**--***-**--**--***-**

ALTER TABLE [dbo].[CostSheet]
ADD [IndimanModifier] [int] NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [IndimanModifiedDate] [datetime2](7) NULL
GO

--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**


--**--***-**--**--***-**--**--***-** Update Two columns in Above --**--***-**--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**

UPDATE [dbo].[CostSheet] SET [IndimanModifier] = 1 
GO


UPDATE [dbo].[CostSheet] SET [IndimanModifiedDate] = GETDATE()
GO

--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**

--**--***-**--**--***-**--**--***-** ALTER Two columns in Above --**--***-**--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**

ALTER TABLE [dbo].[CostSheet]
ALTER COLUMN [IndimanModifier] [int] NULL
GO

ALTER TABLE [dbo].[CostSheet]
ALTER COLUMN [IndimanModifiedDate] [datetime2](7) NULL
GO

ALTER TABLE [dbo].[CostSheet]  WITH CHECK ADD  CONSTRAINT [FK_CostSheet_IndimanModifier] FOREIGN KEY([IndimanModifier])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[CostSheet] CHECK CONSTRAINT [FK_CostSheet_IndimanModifier]
GO


--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**

--**--***-**--**--***-**--**--***-** ALTER Two columns in Modifier and ModifiedDate --**--***-**--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**

ALTER TABLE [dbo].[CostSheet]
ALTER COLUMN [Modifier] [int] NULL
GO

ALTER TABLE [dbo].[CostSheet]
ALTER COLUMN [ModifiedDate] [datetime2](7) NULL
GO

--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**--**--***-**