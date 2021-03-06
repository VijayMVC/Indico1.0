USE [Indico]
GO

/****** Object:  Table [dbo].[PatternSupplier]    Script Date: 12-Feb-16 5:13:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dbo].[PatternSupplier](
	[ID] [int] IDENTITY(1,1) NOT NULL,	
	[Name] [nvarchar](64) NOT NULL,
	[Address1] [nvarchar] (128) NULL,
	[Address2] [nvarchar] (128) NULL,
	[City] [nvarchar](68) NULL,
	[State] [nvarchar](20) NULL,
	[Postcode] [nvarchar](20) NULL,
	[Country] [int] NULL,
	[EmailAddress] [nvarchar](128) NULL,
	[TelephoneNumber] [nvarchar](20) NULL,
	[Creator] [int] NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[Modifier] [int] NOT NULL,
	[ModifiedDate] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_PatternSupplier] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[PatternSupplier]  WITH CHECK ADD  CONSTRAINT [FK_PatternSupplier_Country] FOREIGN KEY([Country])
REFERENCES [dbo].[Country] ([ID])
GO

ALTER TABLE [dbo].[PatternSupplier] CHECK CONSTRAINT [FK_PatternSupplier_Country]
GO

ALTER TABLE [dbo].[PatternSupplier]  WITH CHECK ADD  CONSTRAINT [FK_PatternSupplier_Creator] FOREIGN KEY([Creator])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[PatternSupplier] CHECK CONSTRAINT [FK_PatternSupplier_Creator]
GO

ALTER TABLE [dbo].[PatternSupplier]  WITH CHECK ADD  CONSTRAINT [FK_PatternSupplier_Modifier] FOREIGN KEY([Modifier])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[PatternSupplier] CHECK CONSTRAINT [FK_PatternSupplier_Modifier]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternSupplier', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of the pattern supplier' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternSupplier', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Address1 of the pattern supplier' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternSupplier', @level2type=N'COLUMN',@level2name=N'Address1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Address2 of the pattern supplier' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternSupplier', @level2type=N'COLUMN',@level2name=N'Address2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'City of the pattern supplier' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternSupplier', @level2type=N'COLUMN',@level2name=N'City'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'State of the pattern supplier' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternSupplier', @level2type=N'COLUMN',@level2name=N'State'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Postcode of the pattern supplier' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternSupplier', @level2type=N'COLUMN',@level2name=N'Postcode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Country of the pattern supplier' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternSupplier', @level2type=N'COLUMN',@level2name=N'Country'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Email address of the pattern supplier' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternSupplier', @level2type=N'COLUMN',@level2name=N'EmailAddress'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Telephononumber of the pattern supplier' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternSupplier', @level2type=N'COLUMN',@level2name=N'TelephoneNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Creator' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternSupplier', @level2type=N'COLUMN',@level2name=N'Creator'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Created date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternSupplier', @level2type=N'COLUMN',@level2name=N'CreatedDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Modifier' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternSupplier', @level2type=N'COLUMN',@level2name=N'Modifier'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Modified date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternSupplier', @level2type=N'COLUMN',@level2name=N'ModifiedDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternSupplier'
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

ALTER TABLE [dbo].[Pattern]
	ADD [PatternSupplier] int NULL
GO

DECLARE @id int

-- Insert to PatternSupplier for JK garmnents
INSERT INTO [dbo].[PatternSupplier]
           ([Name]
		   ,[Address1]
		   ,[City]
		   ,[State]
		   ,[Postcode]
           ,[Country]
		   ,[EmailAddress]
		   ,[TelephoneNumber]
           ,[Creator]
           ,[CreatedDate]
           ,[Modifier]
           ,[ModifiedDate])
     VALUES
           ('J.K. GARMENTS (PVT) LTD'
		   ,'LIYANAGAMULLA'
		   ,'SEEDUWA'
		   ,'Western'
		   ,'11410'
           ,7
		   ,'info@jkgmnt.com'
		   ,'+94112259610'
           ,1
           ,GETDATE()
           ,1
           ,GETDATE())

SET @id = SCOPE_IDENTITY()

UPDATE [dbo].[Pattern] 
	SET PatternSupplier = @id
GO

ALTER TABLE [dbo].[Pattern]
	ALTER COLUMN [PatternSupplier] int NOT NULL
GO

ALTER TABLE [dbo].[Pattern]  WITH CHECK ADD  CONSTRAINT [FK_Pattern_PatternSupplier] FOREIGN KEY([PatternSupplier])
REFERENCES [dbo].[PatternSupplier] ([ID])
GO

ALTER TABLE [dbo].[Pattern] CHECK CONSTRAINT [FK_Pattern_PatternSupplier]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

-- Pattern Suppliers page

DECLARE @PageId int
DECLARE @MenuItemMenuId int
DECLARE @MenuItemId int

--DECLARE @FactoryAdministrator int
DECLARE @IndimanAdministrator int

--SET @FactoryAdministrator = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Factory Administrator')
SET @IndimanAdministrator = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')

INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/ViewPatternSuppliers.aspx','Pattern Suppliers','Pattern Suppliers')	 
SET @PageId = SCOPE_IDENTITY()

--Indiman menu item

SET @MenuItemMenuId =  (SELECT Parent FROM [dbo].[MenuItem] WHERE 
						(Page = (SELECT ID FROM [dbo].Page WHERE Name = '/ViewGender.aspx')
						)
						)
						
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Pattern Suppliers', 'Pattern Suppliers', 1, @MenuItemMenuId, 16, 1)
SET @MenuItemId = SCOPE_IDENTITY()

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndimanAdministrator)

GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

