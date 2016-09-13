USE [Indico]
GO


DELETE [dbo].[SizeChart] 
FROM [dbo].[SizeChart] sc
JOIN [dbo].[MeasurementLocation] ml
	ON sc.[MeasurementLocation] = ml.[ID] 
JOIN [dbo].[Pattern] p
	ON p.[ID] = sc.[Pattern] 
WHERE ml.[Item] NOT IN (p.[Item])
GO


--**--** CREATE TABLE PriceChangeEmailList --**--**--**--**--**--**--**--**--**--**

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Price_User]') AND parent_object_id = OBJECT_ID(N'[dbo].[PriceChangeEmailList]'))
ALTER TABLE [dbo].[PriceChangeEmailList] DROP CONSTRAINT [FK_Price_User]
GO

/****** Object:  Table [dbo].[PriceChangeEmailList]    Script Date: 01/31/2013 15:16:23 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PriceChangeEmailList]') AND type in (N'U'))
DROP TABLE [dbo].[PriceChangeEmailList]
GO

/****** Object:  Table [dbo].[PriceChangeEmailList]    Script Date: 01/31/2013 15:16:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PriceChangeEmailList](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[User] [int] NULL,
 CONSTRAINT [PK_PriceChangeEmailList] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[PriceChangeEmailList]  WITH CHECK ADD  CONSTRAINT [FK_Price_User] FOREIGN KEY([User])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[PriceChangeEmailList] CHECK CONSTRAINT [FK_Price_User]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
