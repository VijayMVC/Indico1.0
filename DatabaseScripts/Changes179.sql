USE [Indico]
GO

ALTER TABLE [dbo].[Company]
	ADD IsEnableBackOrderReporting bit NOT NULL DEFAULT(0)
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

/****** Object:  Table [dbo].[DistributorType]    Script Date: 12-Feb-16 5:13:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dbo].[DistributorType](
[ID] int NOT NULL IDENTITY(1,1),
[Name] nvarchar(32) NULL,
CONSTRAINT [PK_DistributorType] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON 
[PRIMARY]
) ON [PRIMARY]

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

ALTER TABLE [dbo].[Company]
	ADD DistributorType int NULL 
GO

ALTER TABLE [dbo].[Company]  WITH CHECK ADD  CONSTRAINT [FK_Company_DistributorType] FOREIGN KEY(DistributorType)
REFERENCES [dbo].[DistributorType] ([ID])
GO

ALTER TABLE [dbo].[Company] CHECK CONSTRAINT [FK_Company_DistributorType]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

INSERT INTO [dbo].[DistributorType]
           ([Name])
     VALUES
           ('DIRECT')
GO

INSERT INTO [dbo].[DistributorType]
           ([Name])
     VALUES
           ('WHOLESALE')
GO
 
UPDATE [dbo].[Company]
	SET DistributorType = 2
FROM [Indico].[dbo].[Company]
WHERE Type = 4 AND name NOT LIKE '%BLACKCHROME -%'
GO

UPDATE [dbo].[Company]
	SET DistributorType = 1
FROM [Indico].[dbo].[Company]
WHERE Type = 4 AND name LIKE '%BLACKCHROME -%'
GO
  	  

