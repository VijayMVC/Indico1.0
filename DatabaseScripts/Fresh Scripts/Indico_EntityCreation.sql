USE [Indico]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
-- Tables
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[AgeGroup] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AgeGroup](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](255) NULL,
CONSTRAINT [PK_AgeGroup] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AgeGroup', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the Age Group' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AgeGroup', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The description of the Age Group' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AgeGroup', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AgeGroup'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[Category] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Category](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](256) NULL,
CONSTRAINT [PK_Category] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Category', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the Role' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Category', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The description of the Role' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Category', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Category'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[Client] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Client](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Distributor] [int] NOT NULL,
	[Type][int] NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Title] [nvarchar](64) NOT NULL,
	[FirstName] [nvarchar](255) NOT NULL,
	[LastName] [nvarchar](255) NOT NULL,
	[Address1] [nvarchar](255) NOT NULL,
	[Address2] [nvarchar](255) NULL,
	[City] [nvarchar](255) NOT NULL,
	[State] [nvarchar](255) NOT NULL,
	[PostalCode] [nvarchar](255) NOT NULL,
	[Country] [nvarchar](255) NOT NULL,
	[Phone1] [nvarchar](255) NOT NULL,
	[Phone2] [nvarchar](255) NULL,
	[Mobile] [nvarchar](255) NULL,
	[Fax] [nvarchar](255) NULL,
	[Email] [nvarchar](255) NOT NULL,
	[Web] [nvarchar](255) NULL,	
	[NickName] [nvarchar](255) NULL,	
	[EmailSent] [bit] NULL,
	[Creator] [int] NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,	
	[Modifier] [int] NOT NULL,
	[ModifiedDate] [datetime2](7) NOT NULL,
CONSTRAINT [PK_Contact] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Client', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Distributor of this client' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Client', @level2type=N'COLUMN',@level2name=N'Distributor'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Client', @level2type=N'COLUMN',@level2name=N'Type'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of this client' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Client', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Title of this client' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Client', @level2type=N'COLUMN',@level2name=N'Title'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'First name of this client' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Client', @level2type=N'COLUMN',@level2name=N'FirstName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Last name of this client' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Client', @level2type=N'COLUMN',@level2name=N'LastName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Address line 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Client', @level2type=N'COLUMN',@level2name=N'Address1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Address line 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Client', @level2type=N'COLUMN',@level2name=N'Address2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'City' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Client', @level2type=N'COLUMN',@level2name=N'City'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'State' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Client', @level2type=N'COLUMN',@level2name=N'State'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Postal code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Client', @level2type=N'COLUMN',@level2name=N'PostalCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Country' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Client', @level2type=N'COLUMN',@level2name=N'Country'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Telephone1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Client', @level2type=N'COLUMN',@level2name=N'Phone1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Telephone2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Client', @level2type=N'COLUMN',@level2name=N'Phone2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Mobile' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Client', @level2type=N'COLUMN',@level2name=N'Mobile'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fax' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Client', @level2type=N'COLUMN',@level2name=N'Fax'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Client', @level2type=N'COLUMN',@level2name=N'Email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Client', @level2type=N'COLUMN',@level2name=N'Web'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Client', @level2type=N'COLUMN',@level2name=N'NickName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Client', @level2type=N'COLUMN',@level2name=N'EmailSent'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ID of the user who created this client' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Client', @level2type=N'COLUMN',@level2name=N'Creator'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'the DateTime this client was created' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Client', @level2type=N'COLUMN',@level2name=N'CreatedDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ID of the user who last modified this client' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Client', @level2type=N'COLUMN',@level2name=N'Modifier'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The DateTime this client was last updated' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Client', @level2type=N'COLUMN',@level2name=N'ModifiedDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Client'
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[DeliveryMethod] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DeliveryMethod](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](512) NOT NULL,
CONSTRAINT [PK_DeliveryMethod] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DeliveryMethod', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Delivery method name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DeliveryMethod', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description of the delivery method' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DeliveryMethod', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DeliveryMethod'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[ClientType] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ClientType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](255) NULL,
CONSTRAINT [PK_ContactType] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientType', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the Contact Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientType', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The description of the Contact Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientType', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientType'
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[ColourProfile] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ColourProfile](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](255) NULL,
CONSTRAINT [PK_ColourProfile] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ColourProfile', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the Colour Profile' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ColourProfile', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The description of the Colour Profile' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ColourProfile', @level2type=N'COLUMN',@level2name=N'Description'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[Company] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Company](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Type] [int] NOT NULL,
	[IsDistributor] [bit] NOT NULL,
	[Name] [nvarchar](128) NULL,
	[Number] [nvarchar](32) NULL,
	[Address1] [nvarchar](128) NOT NULL,
	[Address2] [nvarchar](128) NULL,
	[City] [nvarchar](64) NOT NULL,
	[State] [nvarchar](20) NOT NULL,
	[Postcode] [nvarchar](20) NOT NULL,	
	[Country] [int] NOT NULL,
	[Phone1] [nvarchar](20) NOT NULL,
	[Phone2] [nvarchar](20) NULL,
	--[Mobile] [nvarchar](20) NULL,
	--[Email] [nvarchar](64) NOT NULL,
	[Fax] [nvarchar](64) NULL,
	[NickName] [nvarchar](128) NULL,	
	[Coordinator] [int] NULL,
	[Owner] [int] NULL,
	[Creator] [int] NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[Modifier] [int] NOT NULL,
	[ModifiedDate] [datetime2](7) NOT NULL,
CONSTRAINT [PK_Company] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Company', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The type of the Company' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Company', @level2type=N'COLUMN',@level2name=N'Type'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The company is distributor comany' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Company', @level2type=N'COLUMN',@level2name=N'IsDistributor'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The Name of the Company' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Company', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ABN/ACN or similar of the Company' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Company', @level2type=N'COLUMN',@level2name=N'Number'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The address1 of the Company' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Company', @level2type=N'COLUMN',@level2name=N'Address1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The address2 of the Company' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Company', @level2type=N'COLUMN',@level2name=N'Address2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The city of the Company' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Company', @level2type=N'COLUMN',@level2name=N'City'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The state of the Company' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Company', @level2type=N'COLUMN',@level2name=N'State'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The postcode of eh Company' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Company', @level2type=N'COLUMN',@level2name=N'Postcode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The country of eh Company' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Company', @level2type=N'COLUMN',@level2name=N'Country'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The phone number of the company' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Company', @level2type=N'COLUMN',@level2name=N'Phone1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The phone number of the company' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Company', @level2type=N'COLUMN',@level2name=N'Phone2'
GO
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The mobile number of the company' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Company', @level2type=N'COLUMN',@level2name=N'Mobile'
--GO
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The email address of the company' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Company', @level2type=N'COLUMN',@level2name=N'Email'
--GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The fax address of the company' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Company', @level2type=N'COLUMN',@level2name=N'Fax'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The nick name address of the company' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Company', @level2type=N'COLUMN',@level2name=N'NickName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Company', @level2type=N'COLUMN',@level2name=N'Coordinator'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Company', @level2type=N'COLUMN',@level2name=N'Owner'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The User who created the account' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Company', @level2type=N'COLUMN',@level2name=N'Creator'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The Date the Account was created' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Company', @level2type=N'COLUMN',@level2name=N'CreatedDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The User who last modified this Account' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Company', @level2type=N'COLUMN',@level2name=N'Modifier'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The date the Account was last modified' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Company', @level2type=N'COLUMN',@level2name=N'ModifiedDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Company'
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[CompanyType] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CompanyType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](256) NULL,
CONSTRAINT [PK_CompanyType] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CompanyType', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the company type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CompanyType', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The description of the company type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CompanyType', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CompanyType'
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[Label] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Label](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[LabelImagePath] [nvarchar](256) NULL,
	[IsSample] [bit] NOT NULL,
CONSTRAINT [PK_Label] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Label', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the label' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Label', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The label image path' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Label', @level2type=N'COLUMN',@level2name=N'LabelImagePath'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is this sample label?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Label', @level2type=N'COLUMN',@level2name=N'IsSample'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Label'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[DistributorPriceMarkup] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DistributorPriceMarkup](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Distributor] [int] NULL,
	[PriceLevel] [int] NOT NULL,
	[Markup] [decimal] (4,2) NOT NULL,
CONSTRAINT [PK_DistributorPriceMarkup] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[Country] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Country](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Iso2] [nvarchar](2) NOT NULL,
	[Iso3] [nvarchar](3) NOT NULL,
	[IsoCountryNumber] [int] NOT NULL,
	[DialingPrefix] [int] NULL,
	[Name] [nvarchar](50) NOT NULL,
	[ShortName] [nvarchar](50) NOT NULL,
	[HasLocationData] [bit] NOT NULL,
CONSTRAINT [PK_Country] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Country', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ISO2 code for the country' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Country', @level2type=N'COLUMN',@level2name=N'Iso2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ISO3 code for the Country' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Country', @level2type=N'COLUMN',@level2name=N'Iso3'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ISO Country number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Country', @level2type=N'COLUMN',@level2name=N'IsoCountryNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The dialing prefix for the Company' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Country', @level2type=N'COLUMN',@level2name=N'DialingPrefix'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The Country''s name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Country', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The Country''s short name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Country', @level2type=N'COLUMN',@level2name=N'ShortName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'true if the country has location data in the Location table' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Country', @level2type=N'COLUMN',@level2name=N'HasLocationData'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Country'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

--/****** Object:  Table [dbo].[DashBoard] ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

--CREATE TABLE [dbo].[DashBoard](
--	[ID] [int] IDENTITY(1,1) NOT NULL,
--	[WeekOfYear] [nvarchar](64) NOT NULL,
--	[FridayOfWeek] [datetime2](7) NOT NULL,
--	[Capacity] [nvarchar](64) NOT NULL,
--	[Notes] [nvarchar](255) NOT NULL,
--CONSTRAINT [PK_DashBoard] PRIMARY KEY CLUSTERED 
--([ID] ASC)
--WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
--ON [PRIMARY]
--GO

--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DashBoard', @level2type=N'COLUMN',@level2name=N'ID'
--GO
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DashBoard', @level2type=N'COLUMN',@level2name=N'WeekOfYear'
--GO
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DashBoard', @level2type=N'COLUMN',@level2name=N'FridayOfWeek'
--GO
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DashBoard', @level2type=N'COLUMN',@level2name=N'Capacity'
--GO
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DashBoard', @level2type=N'COLUMN',@level2name=N'Notes'
--GO
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DashBoard'
--GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[DestinationPort] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DestinationPort](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](512) NOT NULL,
CONSTRAINT [PK_DestinationPort] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DestinationPort', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of the destination port' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DestinationPort', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description of the destination port' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DestinationPort', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DestinationPort'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[DistributorLabel] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DistributorLabel](
	[Distributor] [int] NOT NULL,
	[Label] [int] NOT NULL,
CONSTRAINT [PK_DistributorLabel] PRIMARY KEY CLUSTERED 
([Distributor] ASC,[Label] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ID of the distributor' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DistributorLabel', @level2type=N'COLUMN',@level2name=N'Distributor'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ID of the label' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DistributorLabel', @level2type=N'COLUMN',@level2name=N'Label'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DistributorLabel'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[Currency]    Script Date: 04/02/2012 20:23:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Currency](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Code] [nvarchar](4) NOT NULL,
	[Symbol] [nvarchar](5) NULL,
	[Country] [int] NULL,
 CONSTRAINT [PK_Currency] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the Currency' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The code of the Currency' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'Code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The symbol of the Currency' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'Symbol'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The country of the Currency' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'Country'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency'
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[FabricCode] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[FabricCode](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](64) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Material] [nvarchar](255) NULL,
	[GSM] [nvarchar](255) NULL,
	[Supplier] [nvarchar](255) NULL,
	[Country] [int] NOT NULL,
	[DenierCount] [nvarchar](255) NULL,
	[Filaments] [nvarchar](255) NULL,
	[NickName] [nvarchar](255) NULL,
	[SerialOrder] [nvarchar](32) NULL,
	[LandedCost] [decimal](8,2) NULL,
	[LandedCurrency] [int] NULL,
CONSTRAINT [PK_FabricCode] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FabricCode', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code of the fabric' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FabricCode', @level2type=N'COLUMN',@level2name=N'Code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of the fabric' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FabricCode', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Material of the fabric' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FabricCode', @level2type=N'COLUMN',@level2name=N'Material'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FabricCode', @level2type=N'COLUMN',@level2name=N'GSM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Supplier of this fabric' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FabricCode', @level2type=N'COLUMN',@level2name=N'Supplier'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Country of the made of this fabric' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FabricCode', @level2type=N'COLUMN',@level2name=N'Country'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FabricCode', @level2type=N'COLUMN',@level2name=N'DenierCount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FabricCode', @level2type=N'COLUMN',@level2name=N'Filaments'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FabricCode', @level2type=N'COLUMN',@level2name=N'NickName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FabricCode', @level2type=N'COLUMN',@level2name=N'SerialOrder'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FabricCode', @level2type=N'COLUMN',@level2name=N'LandedCost'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FabricCode', @level2type=N'COLUMN',@level2name=N'LandedCurrency'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FabricCode'
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[Gender] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Gender](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
CONSTRAINT [PK_Gender] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Gender', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the Gender' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Gender', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Gender'
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[InvoiceStatus]    Script Date: 05/07/2012 16:04:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[InvoiceStatus](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Key] [nvarchar](64) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
 CONSTRAINT [PK_InvoiceStatus] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceStatus', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The key of the status' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceStatus', @level2type=N'COLUMN',@level2name=N'Key'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the status' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceStatus', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceStatus'
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[Invoice] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Invoice](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Status] [int] NOT NULL,
	[InvoiceNo] [nvarchar](64) NOT NULL,
	[InvoiceDate] [datetime2](7) NOT NULL,
	[ShipTo] [nvarchar] (512) NOT NULL,
	[Value] [decimal] (8,2) NULL,
	[Freight] [decimal] (8,2) NULL,
	[OtherCost] [decimal] (8,2) NULL,
	[Discount] [decimal] (8,2) NULL,
	[NetValue] [decimal] (8,2) NULL,
	[BillTo] [int] NOT NULL,
	[AWBNo] [nvarchar](255) NULL,
CONSTRAINT [PK_Invoice] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[InvoiceOrder]    Script Date: 05/07/2012 15:44:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[InvoiceOrder](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Invoice] [int] NOT NULL,
	[Order] [int] NOT NULL,
	[NewPrice] [decimal](8, 2) NOT NULL,
CONSTRAINT [PK_InvoiceOrder] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO
/*CREATE TABLE [dbo].[InvoiceOrder](
	[Invoice] [int] NOT NULL,
	[Order] [int] NOT NULL,
 CONSTRAINT [PK_InvoiceOrder] PRIMARY KEY CLUSTERED 
(
	[Invoice] ASC,
	[Order] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO */
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceOrder', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ID of the menu item' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceOrder', @level2type=N'COLUMN',@level2name=N'Invoice'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ID of the Role' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceOrder', @level2type=N'COLUMN',@level2name=N'Order'
GO 
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'New price of the invoice order' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceOrder', @level2type=N'COLUMN',@level2name=N'NewPrice'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceOrder'
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[Item] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Item](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](512) NOT NULL,
	[Parent] [int] NULL,
CONSTRAINT [PK_Item] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Item', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the Item' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Item', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The description of the Item' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Item', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The parent of the Item, if this is a sub item' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Item', @level2type=N'COLUMN',@level2name=N'Parent'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Item'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[ItemAttribute] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ItemAttribute](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Parent] [int] NULL,
	[Item] [int] NOT NULL,	
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](255) NULL,	
CONSTRAINT [PK_ItemAttribute] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ItemAttribute', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The parent attribute of this item attribute' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ItemAttribute', @level2type=N'COLUMN',@level2name=N'Parent'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The item that belongs to this item attribute' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ItemAttribute', @level2type=N'COLUMN',@level2name=N'Item'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the Item Attribute' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ItemAttribute', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The description of the Item Attribute' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ItemAttribute', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ItemAttribute'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[JobTitle] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[JobTitle](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](512) NOT NULL,
CONSTRAINT [PK_JobTitle] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'JobTitle', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of the Job Title' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'JobTitle', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description of the Job Title' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'JobTitle', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'JobTitle'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[Keyword] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Keyword](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](512) NOT NULL,
CONSTRAINT [PK_Keyword] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Keyword', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of the Keyword' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Keyword', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description of the Keyword' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Keyword', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Keyword'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[MeasurementLocation] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[MeasurementLocation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Item] [int] NOT NULL,
	[Key] [nvarchar](64) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
CONSTRAINT [PK_MeasurementLocation] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MeasurementLocation', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of the Measurement Location' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MeasurementLocation', @level2type=N'COLUMN',@level2name=N'Item'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description of the Measurement Location' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MeasurementLocation', @level2type=N'COLUMN',@level2name=N'Key'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description of the Measurement Location' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MeasurementLocation', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MeasurementLocation'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[MenuItem] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[MenuItem](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	--[Account] [int] NOT NULL,
	[Page] [int] NOT NULL,
	[Name] [nvarchar](64) NULL,
	[Description] [nvarchar](255) NULL,
	[IsActive] [bit] NULL,
	[Parent] [int] NULL,
	[Position] [int] NOT NULL,	
	[IsVisible] [bit] NOT NULL,
CONSTRAINT [PK_MenuItem] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MenuItem', @level2type=N'COLUMN',@level2name=N'ID'
GO
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ID of the account' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MenuItem', @level2type=N'COLUMN',@level2name=N'Account'
--GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The page' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MenuItem', @level2type=N'COLUMN',@level2name=N'Page'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the menu item' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MenuItem', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The description of the menu item' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MenuItem', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'If true, the Campaign is Active, if false, the Campaign should not be available for use by normal users' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MenuItem', @level2type=N'COLUMN',@level2name=N'IsActive'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Parent of the Menu item' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MenuItem', @level2type=N'COLUMN',@level2name=N'Parent'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu item position' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MenuItem', @level2type=N'COLUMN',@level2name=N'Position'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu item visible?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MenuItem', @level2type=N'COLUMN',@level2name=N'IsVisible'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MenuItem'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[MenuItemRole] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[MenuItemRole](
	[MenuItem] [int] NOT NULL,
	[Role] [int] NOT NULL,
CONSTRAINT [PK_MenuItemRole] PRIMARY KEY CLUSTERED 
([MenuItem] ASC,[Role] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ID of the menu item' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MenuItemRole', @level2type=N'COLUMN',@level2name=N'MenuItem'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ID of the Role' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MenuItemRole', @level2type=N'COLUMN',@level2name=N'Role'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MenuItemRole'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[ModifiedDistributorPriceMarkup] ******/
/** SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ModifiedDistributorPriceMarkup](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DistributorPriceMarkup] [int] NOT NULL,
	[Distributor] [int] NOT NULL,	
	[ModifiedCost] [decimal](4,2) NOT NULL,
CONSTRAINT [PK_ModifiedDistributorPriceMarkup] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO  **/

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[NickName] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[NickName](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL
CONSTRAINT [PK_NickName] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[OrderDetail] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[OrderDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[OrderType] [int] NOT NULL,
	[VisualLayout] [int] NOT NULL,
	[Pattern] [int] NOT NULL,
	[FabricCode] [int] NOT NULL,
	[VisualLayoutNotes] [nvarchar](255) NULL,
	[NameAndNumbersFilePath] [nvarchar](255) NULL,
	[Order] [int] NOT NULL,
	[Label] [int] NULL,
CONSTRAINT [PK_OrderDetail] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderDetail', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Order type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderDetail', @level2type=N'COLUMN',@level2name=N'OrderType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'VL number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderDetail', @level2type=N'COLUMN',@level2name=N'VisualLayout'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Pattern of the order' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderDetail', @level2type=N'COLUMN',@level2name=N'Pattern'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fabric of the order' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderDetail', @level2type=N'COLUMN',@level2name=N'FabricCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'VL notes' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderDetail', @level2type=N'COLUMN',@level2name=N'VisualLayoutNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'NNP file path' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderDetail', @level2type=N'COLUMN',@level2name=N'NameAndNumbersFilePath'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Order ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderDetail', @level2type=N'COLUMN',@level2name=N'Order'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Distributor label of the order' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderDetail', @level2type=N'COLUMN',@level2name=N'Label'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderDetail'
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[OrderDetailQty] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[OrderDetailQty](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[OrderDetail][int] NOT NULL,
	[Size][int] NOT NULL,
	[Qty]  [int] NOT NULL,
CONSTRAINT [PK_OrderDetailQty] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderDetailQty', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Order detail id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderDetailQty', @level2type=N'COLUMN',@level2name=N'OrderDetail'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Size selected for this order' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderDetailQty', @level2type=N'COLUMN',@level2name=N'Size'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Quantity inserted for this order' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderDetailQty', @level2type=N'COLUMN',@level2name=N'Qty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderDetailQty'
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[ClientOrderHeader] ******/
/** SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ClientOrderHeader](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Date] [datetime2](7) NOT NULL,
	[OrderNumber] [nvarchar](64) NOT NULL,
	[DesiredDeliveryDate] [datetime2](7) NOT NULL,
	[Client][int] NOT NULL,
	[Company][int] NOT NULL,
	[ContactCompanyName] [nvarchar](255) NOT NULL,
	[ContactName] [nvarchar](255) NOT NULL,
	[ContactNumber] [nvarchar](255) NOT NULL,
	[AltContactName] [nvarchar](255) NULL,
	[AltContactNumber] [nvarchar](255) NULL,
	[Notes] [nvarchar](25) NOT NULL,
	[DeliveryMethod] [int] NOT NULL,
	[DeliveryAddress] [nvarchar](255) NOT NULL,
	[DeliveryCity][nvarchar](255) NOT NULL,
	[DeliveryPostCode][nvarchar](255) NOT NULL,
	[IsTemporary][bit] NOT NULL,
CONSTRAINT [PK_ClientOrderHeader] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientOrderHeader', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Order date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientOrderHeader', @level2type=N'COLUMN',@level2name=N'Date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Order number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientOrderHeader', @level2type=N'COLUMN',@level2name=N'OrderNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Desired delivery date of the order' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientOrderHeader', @level2type=N'COLUMN',@level2name=N'DesiredDeliveryDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client id of the order' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientOrderHeader', @level2type=N'COLUMN',@level2name=N'Client'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Company id of the order' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientOrderHeader', @level2type=N'COLUMN',@level2name=N'Company'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of the contact company name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientOrderHeader', @level2type=N'COLUMN',@level2name=N'ContactCompanyName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contact name of this order' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientOrderHeader', @level2type=N'COLUMN',@level2name=N'ContactName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contact number of this order' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientOrderHeader', @level2type=N'COLUMN',@level2name=N'ContactNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Alternative contact name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientOrderHeader', @level2type=N'COLUMN',@level2name=N'AltContactName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Alternative contact number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientOrderHeader', @level2type=N'COLUMN',@level2name=N'AltContactNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Notes to the order' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientOrderHeader', @level2type=N'COLUMN',@level2name=N'Notes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Delivery method of the order' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientOrderHeader', @level2type=N'COLUMN',@level2name=N'DeliveryMethod'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Delivery address of this order' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientOrderHeader', @level2type=N'COLUMN',@level2name=N'DeliveryAddress'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Delivery city of this order' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientOrderHeader', @level2type=N'COLUMN',@level2name=N'DeliveryCity'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Delivery post code of this order' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientOrderHeader', @level2type=N'COLUMN',@level2name=N'DeliveryPostCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Order is temporary?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientOrderHeader', @level2type=N'COLUMN',@level2name=N'IsTemporary'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientOrderHeader'
GO   **/

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[Order] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Order](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[OrderNumber] [nvarchar](64) NULL,
	[Date] [datetime2](7) NOT NULL,
	[DesiredDeliveryDate] [datetime2](7) NOT NULL,
	[Client][int] NOT NULL,
	[Distributor][int] NOT NULL,
	[OrderSubmittedDate] [datetime2](7) NOT NULL,
	[EstimatedCompletionDate] [datetime2](7) NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[ModifiedDate] [datetime2](7) NOT NULL,
	[DestinationPort] [int] NULL,
	[ShipmentMode] [int] NULL,
	[ShipmentDate] [datetime2](7) NULL,
	[Status] [int] NOT NULL,
	[Creator] [int] NOT NULL,
	[Modifier] [int] NOT NULL,
	[PaymentMethod] [int] NULL,
	[OrderUsage] [nvarchar](255) NULL,
	[ShippingAddress] [nvarchar](255) NULL,
	[PurchaseOrderNo] [int] NULL,
	[ShipTo] [nvarchar] (512) NULL,
	[Converted] [bit] NULL,
	[OldPONo] [nvarchar](255) NULL,
	[PhotoApprovalReq] [bit] NULL,
	[Invoice] [int] NULL,
	[Printer] [int] NULL,
	[IsTemporary][bit] NOT NULL,
	[ContactCompanyName] [nvarchar](255) NULL,
	[ContactName] [nvarchar](255) NULL,
	[ContactNumber] [nvarchar](255) NULL,
	[AltContactName] [nvarchar](255) NULL,
	[AltContactNumber] [nvarchar](255) NULL,
	[DeliveryMethod] [int] NULL,
	[DeliveryAddress] [nvarchar](255) NULL,
	[DeliveryCity][nvarchar](255) NULL,
	[DeliveryPostCode][nvarchar](255) NULL,
	[IsRepeat][bit] NOT NULL,
	[Reservation] [int] NULL,
CONSTRAINT [PK_Order] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[OrderQty] ******/
/** SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[OrderQty](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Order] [int] NOT NULL,
	[Size] [int] NOT NULL,
	[Qty] [int] NOT NULL,	
CONSTRAINT [PK_OrderQty] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO **/

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[OrderStatus] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[OrderStatus](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](512) NOT NULL,
CONSTRAINT [PK_OrderStatus] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[OrderType] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[OrderType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](512) NOT NULL,
CONSTRAINT [PK_OrderType] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderType', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the order type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderType', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The description of the order type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderType', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderType'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[ReservationStatus]    Script Date: 02/27/2012 19:33:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ReservationStatus](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](512) NOT NULL,
 CONSTRAINT [PK_ReservationStatus] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[Reservation] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO	

CREATE TABLE [dbo].[Reservation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ReservationNo] [int] NOT NULL,
	[IsRepeat] [bit] NOT NULL,
	[OrderDate] [datetime2](7) NOT NULL,
	[Pattern] [int] NOT NULL,
	[Coordinator] [int] NOT NULL,
	[Distributor] [int] NOT NULL,
	[Client] [int] NOT NULL,
	[ShipTo] [nvarchar] (512) NULL,
	[DestinationPort] [int] NULL,
	[ShipmentMode] [int] NULL,
	[ShipmentDate][datetime2](7) NOT NULL,
	[Qty] [int] NOT NULL DEFAULT(0),
	[Notes] [nvarchar](255) NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateModified][datetime2](7) NOT NULL,
	[Creator] [int] NOT NULL,
	[Modifier] [int] NOT NULL,
	[Status] [int] NOT NULL,
CONSTRAINT [PK_Reservation] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[Page] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Page](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[Title] [nvarchar](128) NOT NULL,
	[Heading] [nvarchar](128) NOT NULL,
	--[CanEdit] [bit] NOT NULL,
	--[CanDelete] [bit] NOT NULL,
	--[CanPrint] [bit] NOT NULL,
CONSTRAINT [TBL_Page] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Page', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The Name of the Page' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Page', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The Title of the Page' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Page', @level2type=N'COLUMN',@level2name=N'Title'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The Heading of the Page' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Page', @level2type=N'COLUMN',@level2name=N'Heading'
GO
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Can be edited information in the page' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Page', @level2type=N'COLUMN',@level2name=N'CanEdit'
--GO
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Can be deleted information in the page' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Page', @level2type=N'COLUMN',@level2name=N'CanDelete'
--GO
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Can be printed information in the page' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Page', @level2type=N'COLUMN',@level2name=N'CanPrint'
--GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Page'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[Pattern] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Pattern](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Item] [int] NOT NULL,
	[SubItem] [int] NULL,
	--[ItemAttribute] [int] NULL,
	[Gender] [int] NOT NULL,
	[AgeGroup] [int] NULL,
	[SizeSet] [int] NOT NULL,	
	[CoreCategory] [int] NOT NULL,
	[PrinterType] [int] NOT NULL,	
	[Number] [nvarchar](64) NOT NULL,
	[OriginRef] [nvarchar](64) NULL,
	[NickName] [nvarchar](255) NOT NULL,
	[Keywords] [nvarchar](255) NULL,
	[CorePattern] [nvarchar](255) NULL,
	[FactoryDescription] [nvarchar](255) NULL,
	[Consumption] [nvarchar](255) NULL,
	[ConvertionFactor] [decimal](4,2) NOT NULL DEFAULT (2.00),
	[SpecialAttributes] [nvarchar](255) NULL,
	[PatternNotes] [nvarchar](255) NULL,
	[PriceRemarks] [nvarchar](255) NULL,	
	[IsActive][bit] NOT NULL,
	[Creator] [int] NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[Modifier] [int] NOT NULL,
	[ModifiedDate] [datetime2](7) NOT NULL,
	[Remarks] [nvarchar](255) NULL,
	[IsTemplate][bit] NOT NULL,
	[Parent] [int] NULL,
	[GarmentSpecStatus] [nvarchar](64) NOT NULL,
CONSTRAINT [PK_Pattern] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The item' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'Item'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The sub item' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'SubItem'
GO
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Item attribute' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'ItemAttribute'
--GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Gender pattern available for' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'Gender'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Age group this pattern for' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'AgeGroup'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The size set' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'SizeSet'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Other category' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'CoreCategory'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Printer type for this pattern' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'PrinterType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The pattern number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'Number'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The original reference' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'OriginRef'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nick name of this pattern' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'NickName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Keywords for this pattern' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'Keywords'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cor pattern' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'CorePattern'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Factory description for thsi pattern' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'FactoryDescription'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Consumption' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'Consumption'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Convertion factor of this pattern' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'ConvertionFactor'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Special attributes of this pattern' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'SpecialAttributes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Pattern related notes' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'PatternNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Pattern price remarks' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'PriceRemarks'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is interactive pattern' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'IsActive'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The creator of this pattern' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'Creator'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The created date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'CreatedDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The modifier of this pattern' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'Modifier'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The modified date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'ModifiedDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Remarks for the price' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'Remarks'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is this template pattern' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'IsTemplate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'If this created from a template' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'Parent'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Garment specification status' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern', @level2type=N'COLUMN',@level2name=N'GarmentSpecStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pattern'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[PatternItemAttributeSub] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PatternItemAttributeSub](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Pattern] [int] NOT NULL,
	[ItemAttribute] [int] NOT NULL,
CONSTRAINT [PK_PatternItemAttributeSub] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[PatternOtherCategory] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PatternOtherCategory](
	[Pattern] [int] NOT NULL,
	[Category] [int] NOT NULL,
CONSTRAINT [PK_PatternOtherCategory] PRIMARY KEY CLUSTERED 
([Pattern] ASC,[Category] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ID of the menu item' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternOtherCategory', @level2type=N'COLUMN',@level2name=N'Pattern'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ID of the Role' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternOtherCategory', @level2type=N'COLUMN',@level2name=N'Category'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternOtherCategory'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[Accessory] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Accessory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	--[Pattern] [int] NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Code] [nvarchar](8) NOT NULL,
	--[AccessoryCategory] [int] NULL,
	--[AccessoryColor] [int] NULL,
	--[Price] [decimal](8,2) NULL,
CONSTRAINT [PK_Accessory] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[AccessoryCategory] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AccessoryCategory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[Code] [nvarchar](8) NOT NULL,
	[Accessory] [int] NOT NULL,
CONSTRAINT [PK_AccessoryCategory] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[AccessoryColor] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AccessoryColor](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Code] [nvarchar](8) NOT NULL,
	[ColorValue] [nvarchar](8) NOT NULL,
CONSTRAINT [PK_AccessoryColor] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[PatternAccessory] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PatternAccessory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Pattern] [int] NOT NULL,
	[Accessory] [int] NOT NULL,
	[AccessoryCategory] [int] NULL,
	--[AccessoryColor] [int] NULL,
CONSTRAINT [PK_PatternAccessory] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[VisualLayoutAccessory] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[VisualLayoutAccessory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[VisualLayout] [int] NOT NULL,
	[Accessory] [int] NOT NULL,
	[AccessoryCategory] [int] NULL,
	[AccessoryColor] [int] NULL,
CONSTRAINT [PK_VisualLayoutAccessory] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[VisualLayout] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[VisualLayout](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](512) NULL,
	[Pattern] [int] NOT NULL,
	[FabricCode] [int] NOT NULL,
	[Client] [int] NOT NULL,
	[Coordinator] [int] NOT NULL,
	[Distributor] [int] NOT NULL,
	[NNPFilePath] [nvarchar](512) NULL,
	--[LayoutImagePath]  [nvarchar](512) NULL,
CONSTRAINT [PK_VisualLayout] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisualLayout', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the payment type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisualLayout', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The description of the payment type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisualLayout', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The Pattern associated with this VL Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisualLayout', @level2type=N'COLUMN',@level2name=N'Pattern'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The Fabric code associated with this VL Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisualLayout', @level2type=N'COLUMN',@level2name=N'FabricCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The Client associated with this VL Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisualLayout', @level2type=N'COLUMN',@level2name=N'Client'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Coordinator of this visual layout' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisualLayout', @level2type=N'COLUMN',@level2name=N'Coordinator'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Distributor of this visual layout' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisualLayout', @level2type=N'COLUMN',@level2name=N'Distributor'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The names and numbers' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisualLayout', @level2type=N'COLUMN',@level2name=N'NNPFilePath'
GO
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Layout image path' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisualLayout', @level2type=N'COLUMN',@level2name=N'LayoutImagePath'
--GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisualLayout'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[Image]    Script Date: 03/05/2012 23:36:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO

CREATE TABLE [dbo].[Image](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[VisualLayout] [int] NOT NULL,
	[Size] [int] NOT NULL,
	[Filename] [nvarchar](255) NULL,
	[Extension] [varchar](10) NULL,
	[IsHero] [bit] NOT NULL,
 CONSTRAINT [PK_Image] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Image', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ID of the Visual layout' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Image', @level2type=N'COLUMN',@level2name=N'VisualLayout'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The size in bytes of the image' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Image', @level2type=N'COLUMN',@level2name=N'Size'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The filename of the image' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Image', @level2type=N'COLUMN',@level2name=N'Filename'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The file extension of the image' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Image', @level2type=N'COLUMN',@level2name=N'Extension'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is this is the hero image?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Image', @level2type=N'COLUMN',@level2name=N'IsHero'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Image'
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[PatternTemplateImage]    Script Date: 03/05/2012 23:36:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO

CREATE TABLE [dbo].[PatternTemplateImage](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Pattern] [int] NOT NULL,
	[Size] [int] NOT NULL,
	[Filename] [nvarchar](255) NULL,
	[Extension] [varchar](10) NULL,
	[IsHero] [bit] NOT NULL,
 CONSTRAINT [PK_PatternTemplateImage] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternTemplateImage', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ID of the Pattern' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternTemplateImage', @level2type=N'COLUMN',@level2name=N'Pattern'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The size in bytes of the image' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternTemplateImage', @level2type=N'COLUMN',@level2name=N'Size'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The filename of the image' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternTemplateImage', @level2type=N'COLUMN',@level2name=N'Filename'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The file extension of the image' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternTemplateImage', @level2type=N'COLUMN',@level2name=N'Extension'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is this is the hero image?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternTemplateImage', @level2type=N'COLUMN',@level2name=N'IsHero'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternTemplateImage'
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[PaymentMethod] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PaymentMethod](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](512) NULL,
CONSTRAINT [PK_PaymentMethod] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentMethod', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the payment type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentMethod', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The description of the payment type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentMethod', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentMethod'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[Price] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Price](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Pattern] [int] NOT NULL,
	[FabricCode] [int] NOT NULL,
	[Remarks] [nvarchar](255) NULL,
	[Creator] [int] NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[Modifier] [int] NOT NULL,
	[ModifiedDate] [datetime2](7) NOT NULL,
CONSTRAINT [PK_Price] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[PriceHistroy] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PriceHistroy](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Price] [int] NOT NULL,
	[Pattern] [int] NOT NULL,
	[FabricCode] [int] NOT NULL,
	[PriceLevel] [int] NOT NULL,
	[PriceLevelCost] [int] NOT NULL,
	[FactoryCost] [decimal](8,2) NOT NULL,
	[IndimanCost] [decimal](8,2) NOT NULL,	
	[ConvertionFactor] [decimal](4,2) NOT NULL,
	[Remarks] [nvarchar](255) NOT NULL,
	[Creator] [int] NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
CONSTRAINT [PK_PriceHistroy] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[PriceLevelCost] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PriceLevelCost](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Price] [int] NOT NULL,
	[PriceLevel] [int] NOT NULL,
	[FactoryCost] [decimal](8,2) NOT NULL,
	[IndimanCost] [decimal](8,2) NOT NULL,
	--[IndicoCost] [decimal](8,2) NULL,
CONSTRAINT [PK_PriceLevelCost] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[PriceTerm] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PriceTerm](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Key] [nvarchar](8) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
CONSTRAINT [PK_PriceTerm] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PriceTerm', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The key of the PriceTerm' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PriceTerm', @level2type=N'COLUMN',@level2name=N'Key'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the PriceTerm' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PriceTerm', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PriceTerm'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[DistributorPriceLevelCost] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DistributorPriceLevelCost](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Distributor] [int] NULL,
	[PriceTerm] [int] NULL,
	[PriceLevelCost] [int] NOT NULL,
	[IndicoCost] [decimal](8,2) NOT NULL DEFAULT(0.00),
	[ModifiedDate] [datetime2](7) NOT NULL,
	[Modifier] [int] NOT NULL,
CONSTRAINT [PK_DistributorPriceLevelCost] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[DistributorPriceLevelCostHistory] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DistributorPriceLevelCostHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Distributor] [int] NULL,
	[PriceTerm] [int] NULL,
	[PriceLevelCost] [int] NOT NULL,
	[IndicoCost] [decimal](8,2) NOT NULL DEFAULT(0.00),
	[ModifiedDate] [datetime2](7) NOT NULL,
	[Modifier] [int] NOT NULL,
CONSTRAINT [PK_DistributorPriceLevelCostHistory] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[PriceLevel] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PriceLevel](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Volume] [nvarchar](255) NOT NULL,
CONSTRAINT [PK_PriceLevel] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PriceLevel', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the price level' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PriceLevel', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The volume of the price level' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PriceLevel', @level2type=N'COLUMN',@level2name=N'Volume'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PriceLevel'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[Printer] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Printer](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](512) NOT NULL,
CONSTRAINT [PK_Printer] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Printer', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the Printer' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Printer', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The description of the Printer' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Printer', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Printer'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[PrinterType] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PrinterType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](512) NOT NULL,
CONSTRAINT [PK_PrinterType] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PrinterType', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the Printer Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PrinterType', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The description of the Printer Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PrinterType', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PrinterType'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[Product] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Product](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProductNumber] [nvarchar](64) NOT NULL,
	[Pattern] [int] NOT NULL,
	[ResolutionProfile] [int] NOT NULL,
	[ColourProfile] [int] NOT NULL,
	[Client] [int] NOT NULL,
	[Notes] [nvarchar](255) NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[FabricCodes] [nvarchar](255) NOT NULL,
	[DistributorLabel] [int] NOT NULL,
	--[Employee] [int] NOT NULL,
	[Label] [nvarchar](255) NOT NULL,
	[Printer] [int] NOT NULL,
CONSTRAINT [PK_Product] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[ProductionLine] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ProductionLine](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](255) NULL,
CONSTRAINT [PK_ProductionLine] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProductionLine', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the production line' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProductionLine', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The description of the production line' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProductionLine', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProductionLine'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[ProductSequence] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO	

CREATE TABLE [dbo].[ProductSequence](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Number] [int] NOT NULL,
	[Description] [nvarchar](255) NULL,
CONSTRAINT [PK_ProductSequence] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProductSequence', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the Product Sequence' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProductSequence', @level2type=N'COLUMN',@level2name=N'Number'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The description of the Product Sequence' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProductSequence', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProductSequence'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[ReservationQty] ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

--CREATE TABLE [dbo].[ReservationQty](
--	[ID] [int] IDENTITY(1,1) NOT NULL,
--	[Reservation] [int] NOT NULL,
--	[Size] [int] NOT NULL,
--	[Qty] [nvarchar](255) NOT NULL,
--CONSTRAINT [PK_ReservationQty] PRIMARY KEY CLUSTERED 
--([ID] ASC)
--WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
--ON [PRIMARY]
--GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[ResolutionProfile] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ResolutionProfile](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](255) NULL,
CONSTRAINT [PK_ResolutionProfile] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ResolutionProfile', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the Resolution Profile' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ResolutionProfile', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The description of the Resolution Profile' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ResolutionProfile', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ResolutionProfile'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[Role] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Role](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](256) NULL,
CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the Role' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The description of the Role' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Role'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[ShipmentMode] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ShipmentMode](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](255) NULL,
CONSTRAINT [PK_ShipmentMode] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ShipmentMode', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the Shipment Mode' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ShipmentMode', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The description of the Shipment Mode' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ShipmentMode', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ShipmentMode'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[Size] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Size](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SizeSet] [int] NOT NULL,
	[SizeName] [nvarchar](255) NOT NULL,
	[SeqNo] [int] NOT NULL,
CONSTRAINT [PK_Size] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[SizeChart] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SizeChart](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Pattern] [int] NOT NULL,
	[MeasurementLocation] [int] NOT NULL,
	[Size] [int] NOT NULL,
	[Val] [decimal] (6,2) NOT NULL DEFAULT (0.00),
CONSTRAINT [PK_SizeChart] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[SizeSet] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO	

CREATE TABLE [dbo].[SizeSet](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](255) NULL,
CONSTRAINT [PK_SizeSet] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SizeSet', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the Size Set' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SizeSet', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The description of the Size Set' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SizeSet', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SizeSet'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[SportsCategory] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SportsCategory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](255) NULL,
CONSTRAINT [PK_SportsCategory] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SportsCategory', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the Sports Category' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SportsCategory', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The description of the Sports Category' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SportsCategory', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SportsCategory'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

--/****** Object:  Table [dbo].[SubItem] ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

--CREATE TABLE [dbo].[SubItem](
--	[ID] [int] IDENTITY(1,1) NOT NULL,
--	[Item] [int] NOT NULL,
--	[Name] [nvarchar](64) NOT NULL,
--	[Description] [nvarchar](255) NULL,
--CONSTRAINT [PK_SubItem] PRIMARY KEY CLUSTERED 
--([ID] ASC)
--WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
--ON [PRIMARY]
--GO

--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SubItem', @level2type=N'COLUMN',@level2name=N'ID'
--GO
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The item of the sub item' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SubItem', @level2type=N'COLUMN',@level2name=N'Item'
--GO
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the sub item' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SubItem', @level2type=N'COLUMN',@level2name=N'Name'
--GO
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The description of the sub item' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SubItem', @level2type=N'COLUMN',@level2name=N'Description'
--GO
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SubItem'
--GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[User] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[User](
	[ID] [int] IDENTITY(1,1) NOT NULL,	
	[Company] [int] NOT NULL,
	[IsDistributor] [bit] NOT NULL,	
	[Status] [int] NOT NULL,
	[Username] [nvarchar](32) NOT NULL,
	[Password] [varchar](255) NOT NULL,
	[GivenName] [nvarchar](32) NOT NULL,
	[FamilyName] [nvarchar](32) NOT NULL,
	[EmailAddress] [nvarchar](128) NOT NULL,
	[PhotoPath] [nvarchar](255) NULL,	
	[Creator] [int] NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,	
	[Modifier] [int] NOT NULL,
	[ModifiedDate] [datetime2](7) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[Guid] [nvarchar](36) NULL,
	[OfficeTelephoneNumber] [nvarchar](20) NOT NULL,
	[MobileTelephoneNumber] [nvarchar](20) NULL,
	[HomeTelephoneNumber] [nvarchar](20) NULL,
	[DateLastLogin] [datetime2](7) NULL,
	--[Credits] [nvarchar](255) NOT NULL,
	--[DistributorLabel] [int] NULL,
CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'User', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Company that belongs to this user' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'User', @level2type=N'COLUMN',@level2name=N'Company'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'User', @level2type=N'COLUMN',@level2name=N'IsDistributor'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The username used for authentication', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'User', @level2type=N'COLUMN',@level2name=N'Username'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The password used for authentication', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'User', @level2type=N'COLUMN',@level2name=N'Password'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The user''s given name', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'User', @level2type=N'COLUMN',@level2name=N'GivenName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'the user''s family, or surname', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'User', @level2type=N'COLUMN',@level2name=N'FamilyName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'the email address associated with this user - all correspondence is directed to this address', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'User', @level2type=N'COLUMN',@level2name=N'EmailAddress'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Photo of the user', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'User', @level2type=N'COLUMN',@level2name=N'PhotoPath'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ID of the user who created this user', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'User', @level2type=N'COLUMN',@level2name=N'Creator'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'the DateTime this user was created', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'User', @level2type=N'COLUMN',@level2name=N'CreatedDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ID of the user who last modified this user', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'User', @level2type=N'COLUMN',@level2name=N'Modifier'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'the DateTime this user was last updated', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'User', @level2type=N'COLUMN',@level2name=N'ModifiedDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'If true, this user is active and is able to authenticate with the system', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'User', @level2type=N'COLUMN',@level2name=N'IsActive'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'If true, this user is deleted and is no longer available to the system', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'User', @level2type=N'COLUMN',@level2name=N'IsDeleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The guid associated with this user that can be used instead of authentication under certain circumstances' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'User', @level2type=N'COLUMN',@level2name=N'Guid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The mobile telephone number number associated with the user', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'User', @level2type=N'COLUMN',@level2name=N'OfficeTelephoneNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The home telephone number associated with the user', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'User', @level2type=N'COLUMN',@level2name=N'MobileTelephoneNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The office telephone number associated with the user', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'User', @level2type=N'COLUMN',@level2name=N'HomeTelephoneNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The DateTime this user last authenticated with the system', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'User', @level2type=N'COLUMN',@level2name=N'DateLastLogin'
GO
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The notification frequency' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'User', @level2type=N'COLUMN',@level2name=N'Credits'
--GO
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The notification level' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'User', @level2type=N'COLUMN',@level2name=N'DistributorLabel'
--GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'User'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[UserHistory] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[UserHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[User] [int] NOT NULL,
	[Company] [int] NOT NULL,
	[Username] [nvarchar](32) NOT NULL,
	[Password] [varchar](255) NULL,
	[GivenName] [nvarchar](32) NULL,
	[FamilyName] [nvarchar](32) NOT NULL,
	[EmailAddress] [nvarchar](64) NOT NULL,
	[DateCreated] [datetime2](7) NULL,
	[Creator] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[Guid] [varchar](36) NOT NULL,
CONSTRAINT [PK_UserHistory] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserHistory', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ID of the User to which this History pertains' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserHistory', @level2type=N'COLUMN',@level2name=N'User'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The company that this User belongs to' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserHistory', @level2type=N'COLUMN',@level2name=N'Company'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The username used for authentication' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserHistory', @level2type=N'COLUMN',@level2name=N'Username'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The password used for authentication' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserHistory', @level2type=N'COLUMN',@level2name=N'Password'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The user''s given name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserHistory', @level2type=N'COLUMN',@level2name=N'GivenName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'the user''s family, or surname' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserHistory', @level2type=N'COLUMN',@level2name=N'FamilyName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'the email address associated with this user - all correspondence is directed to this address' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserHistory', @level2type=N'COLUMN',@level2name=N'EmailAddress'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'the DateTime this user was created' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserHistory', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ID of the user who created this user' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserHistory', @level2type=N'COLUMN',@level2name=N'Creator'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'If true, this user is active and is able to authenticate with the system' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserHistory', @level2type=N'COLUMN',@level2name=N'IsActive'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'If true, this user is deleted and is no longer available to the system' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserHistory', @level2type=N'COLUMN',@level2name=N'IsDeleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The guid associated with this user that can be used instead of authentication under certain circumstances' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserHistory', @level2type=N'COLUMN',@level2name=N'Guid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserHistory'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[UserLogin] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[UserLogin](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[User] [int] NOT NULL,
	[IpAddress] [nvarchar](15) NOT NULL,
	[Success] [bit] NOT NULL,
	[DateLogin] [datetime2](7) NOT NULL,
	[DateLogout] [datetime2](7) NULL,
	[SessionId] [nvarchar](50) NOT NULL,
CONSTRAINT [PK_UserLogin] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserLogin', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ID of the User who created this UserLogin' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserLogin', @level2type=N'COLUMN',@level2name=N'User'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The IP address that the User logged in from' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserLogin', @level2type=N'COLUMN',@level2name=N'IpAddress'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Whether or not the login attempt was successful' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserLogin', @level2type=N'COLUMN',@level2name=N'Success'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The DateTime the user attempted to login' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserLogin', @level2type=N'COLUMN',@level2name=N'DateLogin'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The DateTime the user logged out (if any)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserLogin', @level2type=N'COLUMN',@level2name=N'DateLogout'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserLogin'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[UserRole] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[UserRole](
	[User] [int] NOT NULL,
	[Role] [int] NOT NULL,
CONSTRAINT [PK_UserRole] PRIMARY KEY CLUSTERED 
([Role] ASC,[User] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ID of the User' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserRole', @level2type=N'COLUMN',@level2name=N'User'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ID of the Role' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserRole', @level2type=N'COLUMN',@level2name=N'Role'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserRole'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[UserStatus] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[UserStatus](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Key] [nvarchar](64) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
CONSTRAINT [PK_UserStatus] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserStatus', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The key of the status' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserStatus', @level2type=N'COLUMN',@level2name=N'Key'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the status' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserStatus', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserStatus'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[WeeklyProductionCapacity] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WeeklyProductionCapacity](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WeekNo] [int] NOT NULL,
	[WeekendDate] [datetime2](7) NOT NULL,
	[Capacity] [int] NOT NULL DEFAULT (0),
	[Notes] [nvarchar](512) NULL, 
	[NoOfHolidays] [int] NOT NULL DEFAULT (0),
CONSTRAINT [PK_WeeklyProductionCapacity] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WeeklyProductionCapacity', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Week no of the year' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WeeklyProductionCapacity', @level2type=N'COLUMN',@level2name=N'WeekNo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Week end date of the week period' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WeeklyProductionCapacity', @level2type=N'COLUMN',@level2name=N'WeekendDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The capacity for this period' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WeeklyProductionCapacity', @level2type=N'COLUMN',@level2name=N'Capacity'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Notes if available for this period' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WeeklyProductionCapacity', @level2type=N'COLUMN',@level2name=N'Notes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Number of holidays for this period' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WeeklyProductionCapacity', @level2type=N'COLUMN',@level2name=N'NoOfHolidays'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WeeklyProductionCapacity'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[RequestedQuoteStatus] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RequestedQuoteStatus](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Key] [nvarchar](64) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
CONSTRAINT [PK_RequestedQuoteStatus] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RequestedQuoteStatus', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The key of the status' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RequestedQuoteStatus', @level2type=N'COLUMN',@level2name=N'Key'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the status' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RequestedQuoteStatus', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RequestedQuoteStatus'
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[RequestedQuote] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RequestedQuote](
	[ID] [int] IDENTITY(1,1) NOT NULL,	
	[RequestedDate] [datetime2](7) NULL,
	[Company] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[ContactGivenName] [nvarchar](32) NOT NULL,
	[ContactFamilyName] [nvarchar](32) NOT NULL,
	[ContactTelephone1] [nvarchar](20) NOT NULL,
	[ContactTelephone2] [nvarchar](20) NULL,
	[ContactEmailAddress] [nvarchar](128) NOT NULL,
	[ModifiedDate] [datetime2](7) NOT NULL,
	[Coordinator] [int] NOT NULL,
	[Notes] [nvarchar](MAX) NULL,
	[IsDeleted] [bit] NULL,
CONSTRAINT [PK_RequestedQuote] PRIMARY KEY CLUSTERED 
([ID] ASC)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY])
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RequestedQuote', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The requested date of the quote' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RequestedQuote', @level2type=N'COLUMN',@level2name=N'RequestedDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The company requested the quote' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RequestedQuote', @level2type=N'COLUMN',@level2name=N'Company'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The status of the quote' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RequestedQuote', @level2type=N'COLUMN',@level2name=N'Status'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RequestedQuote', @level2type=N'COLUMN',@level2name=N'ContactGivenName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RequestedQuote', @level2type=N'COLUMN',@level2name=N'ContactFamilyName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RequestedQuote', @level2type=N'COLUMN',@level2name=N'ContactTelephone1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RequestedQuote', @level2type=N'COLUMN',@level2name=N'ContactTelephone2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RequestedQuote', @level2type=N'COLUMN',@level2name=N'ContactEmailAddress'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RequestedQuote', @level2type=N'COLUMN',@level2name=N'ModifiedDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RequestedQuote', @level2type=N'COLUMN',@level2name=N'Coordinator'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RequestedQuote', @level2type=N'COLUMN',@level2name=N'Notes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RequestedQuote', @level2type=N'COLUMN',@level2name=N'IsDeleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RequestedQuote'
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
-- Constraints
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

-- Client

ALTER TABLE [dbo].[Client]  WITH CHECK ADD CONSTRAINT [FK_Client_Distributor] FOREIGN KEY([Distributor])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[Client] CHECK CONSTRAINT [FK_Client_Distributor]
GO

ALTER TABLE [dbo].[Client]  WITH CHECK ADD CONSTRAINT [FK_Client_Type] FOREIGN KEY([Type])
REFERENCES [dbo].[ClientType] ([ID])
GO
ALTER TABLE [dbo].[Client] CHECK CONSTRAINT [FK_Client_Type]
GO

ALTER TABLE [dbo].[Client]  WITH CHECK ADD CONSTRAINT [FK_Client_Creator] FOREIGN KEY([Creator])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[Client] CHECK CONSTRAINT [FK_Client_Creator]
GO

ALTER TABLE [dbo].[Client]  WITH CHECK ADD CONSTRAINT [FK_Client_Modifier] FOREIGN KEY([Modifier])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[Client] CHECK CONSTRAINT [FK_Client_Modifier]
GO

------------------------------------------------------------------------------------------------------------------------------------------

-- Company

ALTER TABLE [dbo].[Company]  WITH CHECK ADD CONSTRAINT [FK_Company_Type] FOREIGN KEY([Type])
REFERENCES [dbo].[CompanyType] ([ID])
GO
ALTER TABLE [dbo].[Company] CHECK CONSTRAINT [FK_Company_Type]
GO

ALTER TABLE [dbo].[Company]  WITH CHECK ADD CONSTRAINT [FK_Company_Country] FOREIGN KEY([Country])
REFERENCES [dbo].[Country] ([ID])
GO
ALTER TABLE [dbo].[Company] CHECK CONSTRAINT [FK_Company_Country]
GO

ALTER TABLE [dbo].[Company]  WITH CHECK ADD CONSTRAINT [FK_Company_Owner] FOREIGN KEY([Owner])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[Company] CHECK CONSTRAINT [FK_Company_Owner]
GO

ALTER TABLE [dbo].[Company]  WITH CHECK ADD CONSTRAINT [FK_Company_Coordinator] FOREIGN KEY([Coordinator])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[Company] CHECK CONSTRAINT [FK_Company_Coordinator]
GO

ALTER TABLE [dbo].[Company]  WITH CHECK ADD CONSTRAINT [FK_Company_Creator] FOREIGN KEY([Creator])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[Company] CHECK CONSTRAINT [FK_Company_Creator]
GO

ALTER TABLE [dbo].[Company]  WITH CHECK ADD CONSTRAINT [FK_Company_Modifier] FOREIGN KEY([Modifier])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[Company] CHECK CONSTRAINT [FK_Company_Modifier]
GO
------------------------------------------------------------------------------------------------------------------------------------------

-- DistributorLabel

ALTER TABLE [dbo].[DistributorLabel]  WITH CHECK ADD CONSTRAINT [FK_DistributorLabel_Distributor] FOREIGN KEY([Distributor])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[DistributorLabel] CHECK CONSTRAINT [FK_DistributorLabel_Distributor]
GO

ALTER TABLE [dbo].[DistributorLabel]  WITH CHECK ADD CONSTRAINT [FK_DistributorLabel_Label] FOREIGN KEY([Label])
REFERENCES [dbo].[Label] ([ID])
GO
ALTER TABLE [dbo].[DistributorLabel] CHECK CONSTRAINT [FK_DistributorLabel_Label]
GO
------------------------------------------------------------------------------------------------------------------------------------------

-- DistributorPriceMarkup

ALTER TABLE [dbo].[DistributorPriceMarkup]  WITH CHECK ADD CONSTRAINT [FK_DistributorPriceMarkup_Company] FOREIGN KEY([Distributor])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[DistributorPriceMarkup] CHECK CONSTRAINT [FK_DistributorPriceMarkup_Company]
GO

ALTER TABLE [dbo].[DistributorPriceMarkup]  WITH CHECK ADD CONSTRAINT [FK_DistributorPriceMarkup_PriceLevel] FOREIGN KEY([PriceLevel])
REFERENCES [dbo].[PriceLevel] ([ID])
GO
ALTER TABLE [dbo].[DistributorPriceMarkup] CHECK CONSTRAINT [FK_DistributorPriceMarkup_PriceLevel]
GO

------------------------------------------------------------------------------------------------------------------------------------------

-- Item

ALTER TABLE [dbo].[Item]  WITH CHECK ADD CONSTRAINT [FK_Item_Parent] FOREIGN KEY([Parent])
REFERENCES [dbo].[Item] ([ID])
GO
ALTER TABLE [dbo].[Item] CHECK CONSTRAINT [FK_Item_Parent]
GO
------------------------------------------------------------------------------------------------------------------------------------------

-- ItemAttribute

ALTER TABLE [dbo].[ItemAttribute]  WITH CHECK ADD CONSTRAINT [FK_ItemAttribute_Parent] FOREIGN KEY([Parent])
REFERENCES [dbo].[ItemAttribute] ([ID])
GO
ALTER TABLE [dbo].[ItemAttribute] CHECK CONSTRAINT [FK_ItemAttribute_Parent]
GO

ALTER TABLE [dbo].[ItemAttribute]  WITH CHECK ADD CONSTRAINT [FK_ItemAttribute_Item] FOREIGN KEY([Item])
REFERENCES [dbo].[Item] ([ID])
GO
ALTER TABLE [dbo].[ItemAttribute] CHECK CONSTRAINT [FK_ItemAttribute_Item]
GO
------------------------------------------------------------------------------------------------------------------------------------------

-- MeasurementLocation

ALTER TABLE [dbo].[MeasurementLocation]  WITH CHECK ADD CONSTRAINT [FK_MeasurementLocation_Item] FOREIGN KEY([Item])
REFERENCES [dbo].[Item] ([ID])
GO
ALTER TABLE [dbo].[MeasurementLocation] CHECK CONSTRAINT [FK_MeasurementLocation_Item]
GO
------------------------------------------------------------------------------------------------------------------------------------------

-- MenuItem

ALTER TABLE [dbo].[MenuItem]  WITH CHECK ADD CONSTRAINT [FK_MenuItem_Page] FOREIGN KEY([Page])
REFERENCES [dbo].[Page] ([ID])
GO
ALTER TABLE [dbo].[MenuItem] CHECK CONSTRAINT [FK_MenuItem_Page]
GO

ALTER TABLE [dbo].[MenuItem]  WITH CHECK ADD CONSTRAINT [FK_MenuItem_Parent] FOREIGN KEY([Parent])
REFERENCES [dbo].[MenuItem] ([ID])
GO
ALTER TABLE [dbo].[MenuItem] CHECK CONSTRAINT [FK_MenuItem_Parent]
GO
------------------------------------------------------------------------------------------------------------------------------------------

-- MenuItemRole

ALTER TABLE [dbo].[MenuItemRole]  WITH CHECK ADD CONSTRAINT [FK_MenuItemRole_MenuItem] FOREIGN KEY([MenuItem])
REFERENCES [dbo].[MenuItem] ([ID])
GO
ALTER TABLE [dbo].[MenuItemRole] CHECK CONSTRAINT [FK_MenuItemRole_MenuItem]
GO

ALTER TABLE [dbo].[MenuItemRole]  WITH CHECK ADD CONSTRAINT [FK_MenuItemRole_Role] FOREIGN KEY([Role])
REFERENCES [dbo].[Role] ([ID])
GO
ALTER TABLE [dbo].[MenuItemRole] CHECK CONSTRAINT [FK_MenuItemRole_Role]
GO
------------------------------------------------------------------------------------------------------------------------------------------

-- ModifiedDistributorPriceMarkup

/** ALTER TABLE [dbo].[ModifiedDistributorPriceMarkup]  WITH CHECK ADD CONSTRAINT [FK_ModifiedDistributorPriceMarkup_Price] FOREIGN KEY([DistributorPriceMarkup])
REFERENCES [dbo].[DistributorPriceMarkup] ([ID])
GO
ALTER TABLE [dbo].[ModifiedDistributorPriceMarkup] CHECK CONSTRAINT [FK_ModifiedDistributorPriceMarkup_Price]
GO

ALTER TABLE [dbo].[ModifiedDistributorPriceMarkup]  WITH CHECK ADD CONSTRAINT [FK_ModifiedDistributorPriceMarkup_Distributor] FOREIGN KEY([Distributor])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[ModifiedDistributorPriceMarkup] CHECK CONSTRAINT [FK_ModifiedDistributorPriceMarkup_Distributor]
GO  **/
------------------------------------------------------------------------------------------------------------------------------------------

-- OrderDetail

ALTER TABLE [dbo].[OrderDetail]  WITH CHECK ADD CONSTRAINT [FK_OrderDetail_OrderType] FOREIGN KEY([OrderType])
REFERENCES [dbo].[OrderType] ([ID])
GO
ALTER TABLE [dbo].[OrderDetail] CHECK CONSTRAINT [FK_OrderDetail_OrderType]
GO

ALTER TABLE [dbo].[OrderDetail]  WITH CHECK ADD CONSTRAINT [FK_OrderDetail_Pattern] FOREIGN KEY([Pattern])
REFERENCES [dbo].[Pattern] ([ID])
GO
ALTER TABLE [dbo].[OrderDetail] CHECK CONSTRAINT [FK_OrderDetail_Pattern]
GO

ALTER TABLE [dbo].[OrderDetail]  WITH CHECK ADD CONSTRAINT [FK_OrderDetail_FabricCode] FOREIGN KEY([FabricCode])
REFERENCES [dbo].[FabricCode] ([ID])
GO
ALTER TABLE [dbo].[OrderDetail] CHECK CONSTRAINT [FK_OrderDetail_FabricCode]
GO

ALTER TABLE [dbo].[OrderDetail]  WITH CHECK ADD CONSTRAINT [FK_OrderDetail_Order] FOREIGN KEY([Order])
REFERENCES [dbo].[Order] ([ID])
GO
ALTER TABLE [dbo].[OrderDetail] CHECK CONSTRAINT [FK_OrderDetail_Order]
GO

ALTER TABLE [dbo].[OrderDetail]  WITH CHECK ADD CONSTRAINT [FK_OrderDetail_VisualLayout] FOREIGN KEY([VisualLayout])
REFERENCES [dbo].[VisualLayout] ([ID])
GO
ALTER TABLE [dbo].[OrderDetail] CHECK CONSTRAINT [FK_OrderDetail_VisualLayout]
GO

ALTER TABLE [dbo].[OrderDetail]  WITH CHECK ADD CONSTRAINT [FK_OrderDetail_Label] FOREIGN KEY([Label])
REFERENCES [dbo].[Label] ([ID])
GO
ALTER TABLE [dbo].[OrderDetail] CHECK CONSTRAINT [FK_OrderDetail_Label]
GO

------------------------------------------------------------------------------------------------------------------------------------------

-- OrderDetailQty

ALTER TABLE [dbo].[OrderDetailQty]  WITH CHECK ADD CONSTRAINT [FK_OrderDetailQty_Size] FOREIGN KEY([Size])
REFERENCES [dbo].[Size] ([ID])
GO
ALTER TABLE [dbo].[OrderDetailQty] CHECK CONSTRAINT [FK_OrderDetailQty_Size]
GO

ALTER TABLE [dbo].[OrderDetailQty]  WITH CHECK ADD CONSTRAINT [FK_OrderDetailQty_OrderDetail] FOREIGN KEY([OrderDetail])
REFERENCES [dbo].[OrderDetail] ([ID])
GO
ALTER TABLE [dbo].[OrderDetailQty] CHECK CONSTRAINT [FK_OrderDetailQty_OrderDetail]
GO

------------------------------------------------------------------------------------------------------------------------------------------

-- Order

ALTER TABLE [dbo].[Order]  WITH CHECK ADD CONSTRAINT [FK_Order_Creator] FOREIGN KEY([Creator])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_Creator]
GO

ALTER TABLE [dbo].[Order]  WITH CHECK ADD CONSTRAINT [FK_Order_PaymentMethod] FOREIGN KEY([PaymentMethod])
REFERENCES [dbo].[PaymentMethod] ([ID])
GO
ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_PaymentMethod]
GO

ALTER TABLE [dbo].[Order]  WITH CHECK ADD CONSTRAINT [FK_Order_Modifier] FOREIGN KEY([Modifier])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_Modifier]
GO 

ALTER TABLE [dbo].[Order]  WITH CHECK ADD CONSTRAINT [FK_Order_OrderStatus] FOREIGN KEY([Status])
REFERENCES [dbo].[OrderStatus] ([ID])
GO
ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_OrderStatus]
GO

ALTER TABLE [dbo].[Order]  WITH CHECK ADD CONSTRAINT [FK_Order_ShipmentMode] FOREIGN KEY([ShipmentMode])
REFERENCES [dbo].[ShipmentMode] ([ID])
GO
ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_ShipmentMode]
GO

ALTER TABLE [dbo].[Order]  WITH CHECK ADD CONSTRAINT [FK_Order_DestinationPort] FOREIGN KEY([DestinationPort])
REFERENCES [dbo].[DestinationPort] ([ID])
GO
ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_DestinationPort]
GO

ALTER TABLE [dbo].[Order]  WITH CHECK ADD CONSTRAINT [FK_Order_Printer] FOREIGN KEY([Printer])
REFERENCES [dbo].[Printer] ([ID])
GO
ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_Printer]
GO

ALTER TABLE [dbo].[Order]  WITH CHECK ADD CONSTRAINT [FK_Order_Invoice] FOREIGN KEY([Invoice])
REFERENCES [dbo].[Invoice] ([ID])
GO
ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_Invoice]
GO

ALTER TABLE [dbo].[Order]  WITH CHECK ADD CONSTRAINT [FK_Order_Client] FOREIGN KEY([Client])
REFERENCES [dbo].[Client] ([ID])
GO
ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_Client]
GO

ALTER TABLE [dbo].[Order]  WITH CHECK ADD CONSTRAINT [FK_Order_Distributor] FOREIGN KEY([Distributor])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_Distributor]
GO

ALTER TABLE [dbo].[Order]  WITH CHECK ADD CONSTRAINT [FK_Order_DeliveryMethod] FOREIGN KEY([DeliveryMethod])
REFERENCES [dbo].[DeliveryMethod] ([ID])
GO
ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_DeliveryMethod]
GO

ALTER TABLE [dbo].[Order]  WITH CHECK ADD CONSTRAINT [FK_Order_Reservation] FOREIGN KEY([Reservation])
REFERENCES [dbo].[Reservation] ([ID])
GO
ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_Reservation]
GO

------------------------------------------------------------------------------------------------------------------------------------------

-- RequestedQuote

ALTER TABLE [dbo].[RequestedQuote]  WITH CHECK ADD CONSTRAINT [FK_RequestedQuote_Status] FOREIGN KEY([Status])
REFERENCES [dbo].[RequestedQuoteStatus] ([ID])
GO
ALTER TABLE [dbo].[RequestedQuote] CHECK CONSTRAINT [FK_RequestedQuote_Status]
GO

ALTER TABLE [dbo].[RequestedQuote]  WITH CHECK ADD CONSTRAINT [FK_RequestedQuote_Company] FOREIGN KEY([Company])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[RequestedQuote] CHECK CONSTRAINT [FK_RequestedQuote_Company]
GO

------------------------------------------------------------------------------------------------------------------------------------------

-- Pattern

ALTER TABLE [dbo].[Pattern]  WITH CHECK ADD CONSTRAINT [FK_Pattern_Item] FOREIGN KEY([Item])
REFERENCES [dbo].[Item] ([ID])
GO
ALTER TABLE [dbo].[Pattern] CHECK CONSTRAINT [FK_Pattern_Item]
GO

ALTER TABLE [dbo].[Pattern]  WITH CHECK ADD CONSTRAINT [FK_Pattern_SubItem] FOREIGN KEY([SubItem])
REFERENCES [dbo].[Item] ([ID])
GO
ALTER TABLE [dbo].[Pattern] CHECK CONSTRAINT [FK_Pattern_SubItem]
GO

ALTER TABLE [dbo].[Pattern]  WITH CHECK ADD CONSTRAINT [FK_Pattern_Gender] FOREIGN KEY([Gender])
REFERENCES [dbo].[Gender] ([ID])
GO
ALTER TABLE [dbo].[Pattern] CHECK CONSTRAINT [FK_Pattern_Gender]
GO

ALTER TABLE [dbo].[Pattern]  WITH CHECK ADD CONSTRAINT [FK_Pattern_AgeGroup] FOREIGN KEY([AgeGroup])
REFERENCES [dbo].[AgeGroup] ([ID])
GO
ALTER TABLE [dbo].[Pattern] CHECK CONSTRAINT [FK_Pattern_AgeGroup]
GO

ALTER TABLE [dbo].[Pattern]  WITH CHECK ADD CONSTRAINT [FK_Pattern_PrinterType] FOREIGN KEY([PrinterType])
REFERENCES [dbo].[PrinterType] ([ID])
GO
ALTER TABLE [dbo].[Pattern] CHECK CONSTRAINT [FK_Pattern_PrinterType]
GO

--ALTER TABLE [dbo].[Pattern]  WITH CHECK ADD CONSTRAINT [FK_Pattern_ItemAttribute] FOREIGN KEY([ItemAttribute])
--REFERENCES [dbo].[ItemAttribute] ([ID])
--GO
--ALTER TABLE [dbo].[Pattern] CHECK CONSTRAINT [FK_Pattern_ItemAttribute]
--GO

ALTER TABLE [dbo].[Pattern]  WITH CHECK ADD CONSTRAINT [FK_Pattern_Category] FOREIGN KEY([CoreCategory])
REFERENCES [dbo].[Category] ([ID])
GO
ALTER TABLE [dbo].[Pattern] CHECK CONSTRAINT [FK_Pattern_Category]
GO

ALTER TABLE [dbo].[Pattern]  WITH CHECK ADD CONSTRAINT [FK_Pattern_SizeSet] FOREIGN KEY([SizeSet])
REFERENCES [dbo].[SizeSet] ([ID])
GO
ALTER TABLE [dbo].[Pattern] CHECK CONSTRAINT [FK_Pattern_SizeSet]
GO

ALTER TABLE [dbo].[Pattern]  WITH CHECK ADD CONSTRAINT [FK_Pattern_Creator] FOREIGN KEY([Creator])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[Pattern] CHECK CONSTRAINT [FK_Pattern_Creator]
GO

ALTER TABLE [dbo].[Pattern]  WITH CHECK ADD CONSTRAINT [FK_Pattern_Modifier] FOREIGN KEY([Modifier])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[Pattern] CHECK CONSTRAINT [FK_Pattern_Modifier]
GO

ALTER TABLE [dbo].[Pattern]  WITH CHECK ADD CONSTRAINT [FK_Pattern_Parent] FOREIGN KEY([Parent])
REFERENCES [dbo].[Pattern] ([ID])
GO
ALTER TABLE [dbo].[Pattern] CHECK CONSTRAINT [FK_Pattern_Parent]
GO

ALTER TABLE [dbo].[Pattern] ADD  CONSTRAINT [DF_Pattern_IsTemplate]  DEFAULT ((0)) FOR [IsTemplate]
GO

------------------------------------------------------------------------------------------------------------------------------------------

-- VisualLayout

ALTER TABLE [dbo].[VisualLayout]  WITH CHECK ADD CONSTRAINT [FK_VisualLayout_Client] FOREIGN KEY([Client])
REFERENCES [dbo].[Client] ([ID])
GO
ALTER TABLE [dbo].[VisualLayout] CHECK CONSTRAINT [FK_VisualLayout_Client]
GO

ALTER TABLE [dbo].[VisualLayout]  WITH CHECK ADD CONSTRAINT [FK_VisualLayout_Pattern] FOREIGN KEY([Pattern])
REFERENCES [dbo].[Pattern] ([ID])
GO
ALTER TABLE [dbo].[VisualLayout] CHECK CONSTRAINT [FK_VisualLayout_Pattern]
GO

ALTER TABLE [dbo].[VisualLayout]  WITH CHECK ADD CONSTRAINT [FK_VisualLayout_FabricCode] FOREIGN KEY([FabricCode])
REFERENCES [dbo].[FabricCode] ([ID])
GO
ALTER TABLE [dbo].[VisualLayout] CHECK CONSTRAINT [FK_VisualLayout_FabricCode]
GO

ALTER TABLE [dbo].[VisualLayout]  WITH CHECK ADD CONSTRAINT [FK_VisualLayout_Coordinator] FOREIGN KEY([Coordinator])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[VisualLayout] CHECK CONSTRAINT [FK_VisualLayout_Coordinator]
GO

ALTER TABLE [dbo].[VisualLayout]  WITH CHECK ADD CONSTRAINT [FK_VisualLayout_Distributor] FOREIGN KEY([Distributor])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[VisualLayout] CHECK CONSTRAINT [FK_VisualLayout_Distributor]
GO
------------------------------------------------------------------------------------------------------------------------------------------

-- Image

ALTER TABLE [dbo].[Image]  WITH CHECK ADD  CONSTRAINT [FK_Image_VisualLayout] FOREIGN KEY([VisualLayout])
REFERENCES [dbo].[VisualLayout] ([ID])
GO

ALTER TABLE [dbo].[Image] CHECK CONSTRAINT [FK_Image_VisualLayout]
GO

------------------------------------------------------------------------------------------------------------------------------------------

-- PatternLayoutImage

ALTER TABLE [dbo].[PatternTemplateImage]  WITH CHECK ADD  CONSTRAINT [FK_Image_Pattern] FOREIGN KEY([Pattern])
REFERENCES [dbo].[Pattern] ([ID])
GO

ALTER TABLE [dbo].[PatternTemplateImage] CHECK CONSTRAINT [FK_Image_Pattern]
GO

------------------------------------------------------------------------------------------------------------------------------------------

-- PatternItemAttributeSub

ALTER TABLE [dbo].[PatternItemAttributeSub]  WITH CHECK ADD CONSTRAINT [FK_PatternItemAttributeSub_Pattern] FOREIGN KEY([Pattern])
REFERENCES [dbo].[Pattern] ([ID])
GO
ALTER TABLE [dbo].[PatternItemAttributeSub] CHECK CONSTRAINT [FK_PatternItemAttributeSub_Pattern]
GO

ALTER TABLE [dbo].[PatternItemAttributeSub]  WITH CHECK ADD CONSTRAINT [FK_PatternItemAttributeSub_ItemAttribute] FOREIGN KEY([ItemAttribute])
REFERENCES [dbo].[ItemAttribute] ([ID])
GO
ALTER TABLE [dbo].[PatternItemAttributeSub] CHECK CONSTRAINT [FK_PatternItemAttributeSub_ItemAttribute]
GO
------------------------------------------------------------------------------------------------------------------------------------------

-- PatternOtherCategory

ALTER TABLE [dbo].[PatternOtherCategory]  WITH CHECK ADD CONSTRAINT [FK_PatternOtherCategory_Pattern] FOREIGN KEY([Pattern])
REFERENCES [dbo].[Pattern] ([ID])
GO
ALTER TABLE [dbo].[PatternOtherCategory] CHECK CONSTRAINT [FK_PatternOtherCategory_Pattern]
GO

ALTER TABLE [dbo].[PatternOtherCategory]  WITH CHECK ADD CONSTRAINT [FK_PatternOtherCategory_Category] FOREIGN KEY([Category])
REFERENCES [dbo].[Category] ([ID])
GO
ALTER TABLE [dbo].[PatternOtherCategory] CHECK CONSTRAINT [FK_PatternOtherCategory_Category]
GO
------------------------------------------------------------------------------------------------------------------------------------------

-- Price

ALTER TABLE [dbo].[Price]  WITH CHECK ADD CONSTRAINT [FK_Price_Pattern] FOREIGN KEY([Pattern])
REFERENCES [dbo].[Pattern] ([ID])
GO
ALTER TABLE [dbo].[Price] CHECK CONSTRAINT [FK_Price_Pattern]
GO

ALTER TABLE [dbo].[Price]  WITH CHECK ADD CONSTRAINT [FK_Price_Fabric] FOREIGN KEY([FabricCode])
REFERENCES [dbo].[FabricCode] ([ID])
GO
ALTER TABLE [dbo].[Price] CHECK CONSTRAINT [FK_Price_Fabric]
GO

ALTER TABLE [dbo].[Price]  WITH CHECK ADD CONSTRAINT [FK_Price_Creator] FOREIGN KEY([Creator])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[Price] CHECK CONSTRAINT [FK_Price_Creator]
GO

ALTER TABLE [dbo].[Price]  WITH CHECK ADD CONSTRAINT [FK_Price_Modifier] FOREIGN KEY([Modifier])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[Price] CHECK CONSTRAINT [FK_Price_Modifier]
GO
------------------------------------------------------------------------------------------------------------------------------------------

-- PriceLevelCost

ALTER TABLE [dbo].[PriceLevelCost]  WITH CHECK ADD CONSTRAINT [FK_PriceLevelCost_Price] FOREIGN KEY([Price])
REFERENCES [dbo].[Price] ([ID])
GO
ALTER TABLE [dbo].[PriceLevelCost] CHECK CONSTRAINT [FK_PriceLevelCost_Price]
GO

ALTER TABLE [dbo].[PriceLevelCost]  WITH CHECK ADD CONSTRAINT [FK_PriceLevelCost_PriceLevel] FOREIGN KEY([PriceLevel])
REFERENCES [dbo].[PriceLevel] ([ID])
GO
ALTER TABLE [dbo].[PriceLevelCost] CHECK CONSTRAINT [FK_PriceLevelCost_PriceLevel]
GO

ALTER TABLE [dbo].[PriceLevelCost] ADD  CONSTRAINT [DF_PriceLevelCost_FactoryCost]  DEFAULT ((0.0)) FOR [FactoryCost]
GO

ALTER TABLE [dbo].[PriceLevelCost] ADD  CONSTRAINT [DF_PriceLevelCost_IndimanCost]  DEFAULT ((0.0)) FOR [IndimanCost]
GO
------------------------------------------------------------------------------------------------------------------------------------------

-- PriceHistroy

ALTER TABLE [dbo].[PriceHistroy]  WITH CHECK ADD CONSTRAINT [FK_PriceHistroy_Price] FOREIGN KEY([Price])
REFERENCES [dbo].[Price] ([ID])
GO
ALTER TABLE [dbo].[PriceHistroy] CHECK CONSTRAINT [FK_PriceHistroy_Price]
GO
------------------------------------------------------------------------------------------------------------------------------------------

-- DistributorPriceLevelCost

ALTER TABLE [dbo].[DistributorPriceLevelCost]  WITH CHECK ADD CONSTRAINT [FK_DistributorPriceLevelCost_Distributor] FOREIGN KEY([Distributor])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[DistributorPriceLevelCost] CHECK CONSTRAINT [FK_DistributorPriceLevelCost_Distributor]
GO

ALTER TABLE [dbo].[DistributorPriceLevelCost]  WITH CHECK ADD CONSTRAINT [FK_DistributorPriceLevelCost_PriceLevelCost] FOREIGN KEY([PriceLevelCost])
REFERENCES [dbo].[PriceLevelCost] ([ID])
GO
ALTER TABLE [dbo].[DistributorPriceLevelCost] CHECK CONSTRAINT [FK_DistributorPriceLevelCost_PriceLevelCost]
GO

ALTER TABLE [dbo].[DistributorPriceLevelCost]  WITH CHECK ADD CONSTRAINT [FK_DistributorPriceLevelCost_PriceTerm] FOREIGN KEY([PriceTerm])
REFERENCES [dbo].[PriceTerm] ([ID])
GO
ALTER TABLE [dbo].[DistributorPriceLevelCost] CHECK CONSTRAINT [FK_DistributorPriceLevelCost_PriceTerm]
GO

ALTER TABLE [dbo].[DistributorPriceLevelCost]  WITH CHECK ADD CONSTRAINT [FK_DistributorPriceLevelCost_Modifier] FOREIGN KEY([Modifier])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[DistributorPriceLevelCost] CHECK CONSTRAINT [FK_DistributorPriceLevelCost_Modifier]
GO
------------------------------------------------------------------------------------------------------------------------------------------

-- Product

ALTER TABLE [dbo].[Product]  WITH CHECK ADD CONSTRAINT [FK_Product_Pattern] FOREIGN KEY([Pattern])
REFERENCES [dbo].[Pattern] ([ID])
GO
ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [FK_Product_Pattern]
GO

ALTER TABLE [dbo].[Product]  WITH CHECK ADD CONSTRAINT [FK_Product_ResolutionProfile] FOREIGN KEY([ResolutionProfile])
REFERENCES [dbo].[ResolutionProfile] ([ID])
GO
ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [FK_Product_ResolutionProfile]
GO

ALTER TABLE [dbo].[Product]  WITH CHECK ADD CONSTRAINT [FK_Product_ColourProfile] FOREIGN KEY([ColourProfile])
REFERENCES [dbo].[ColourProfile] ([ID])
GO
ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [FK_Product_ColourProfile]
GO

ALTER TABLE [dbo].[Product]  WITH CHECK ADD CONSTRAINT [FK_Product_Contact] FOREIGN KEY([Client])
REFERENCES [dbo].[Client] ([ID])
GO
ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [FK_Product_Contact]
GO

ALTER TABLE [dbo].[Product]  WITH CHECK ADD CONSTRAINT [FK_Product_Printer] FOREIGN KEY([Printer])
REFERENCES [dbo].[Printer] ([ID])
GO
ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [FK_Product_Printer]
GO 
------------------------------------------------------------------------------------------------------------------------------------------

-- Reservation

--ALTER TABLE [dbo].[Reservation]  WITH CHECK ADD CONSTRAINT [FK_Reservation_OrderType] FOREIGN KEY([OrderType])
--REFERENCES [dbo].[OrderType] ([ID])
--GO
--ALTER TABLE [dbo].[Reservation] CHECK CONSTRAINT [FK_Reservation_OrderType]
--GO

ALTER TABLE [dbo].[Reservation]  WITH CHECK ADD CONSTRAINT [FK_Reservation_Pattern] FOREIGN KEY([Pattern])
REFERENCES [dbo].[Pattern] ([ID])
GO
ALTER TABLE [dbo].[Reservation] CHECK CONSTRAINT [FK_Reservation_Pattern]
GO

ALTER TABLE [dbo].[Reservation]  WITH CHECK ADD CONSTRAINT [FK_Reservation_Coordinator] FOREIGN KEY([Coordinator])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[Reservation] CHECK CONSTRAINT [FK_Reservation_Coordinator]
GO

ALTER TABLE [dbo].[Reservation]  WITH CHECK ADD CONSTRAINT [FK_Reservation_Distributor] FOREIGN KEY([Distributor])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[Reservation] CHECK CONSTRAINT [FK_Reservation_Distributor]
GO

ALTER TABLE [dbo].[Reservation]  WITH CHECK ADD CONSTRAINT [FK_Reservation_Client] FOREIGN KEY([Client])
REFERENCES [dbo].[Client] ([ID])
GO
ALTER TABLE [dbo].[Reservation] CHECK CONSTRAINT [FK_Reservation_Client]
GO

ALTER TABLE [dbo].[Reservation]  WITH CHECK ADD CONSTRAINT [FK_Reservation_DestinationPort] FOREIGN KEY([DestinationPort])
REFERENCES [dbo].[DestinationPort] ([ID])
GO
ALTER TABLE [dbo].[Reservation] CHECK CONSTRAINT [FK_Reservation_DestinationPort]
GO

ALTER TABLE [dbo].[Reservation]  WITH CHECK ADD CONSTRAINT [FK_Reservation_ShipmentMode] FOREIGN KEY([ShipmentMode])
REFERENCES [dbo].[ShipmentMode] ([ID])
GO
ALTER TABLE [dbo].[Reservation] CHECK CONSTRAINT [FK_Reservation_ShipmentMode]
GO

ALTER TABLE [dbo].[Reservation]  WITH CHECK ADD CONSTRAINT [FK_Reservation_Creator] FOREIGN KEY([Creator])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[Reservation] CHECK CONSTRAINT [FK_Reservation_Creator]
GO

ALTER TABLE [dbo].[Reservation]  WITH CHECK ADD CONSTRAINT [FK_Reservation_Modifier] FOREIGN KEY([Modifier])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[Reservation] CHECK CONSTRAINT [FK_Reservation_Modifier]
GO

ALTER TABLE [dbo].[Reservation]  WITH CHECK ADD CONSTRAINT [FK_Reservation_Status] FOREIGN KEY([Status])
REFERENCES [dbo].[ReservationStatus] ([ID])
GO
ALTER TABLE [dbo].[Reservation] CHECK CONSTRAINT [FK_Reservation_Status]
GO

------------------------------------------------------------------------------------------------------------------------------------------

-- Invoice

ALTER TABLE [dbo].[Invoice]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_Status] FOREIGN KEY([Status])
REFERENCES [dbo].[InvoiceStatus] ([ID])
GO
ALTER TABLE [dbo].[Invoice] CHECK CONSTRAINT [FK_Invoice_Status]
GO
------------------------------------------------------------------------------------------------------------------------------------------

-- InvoiceOrder

ALTER TABLE [dbo].[InvoiceOrder]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceOrder_Invoice] FOREIGN KEY([Invoice])
REFERENCES [dbo].[Invoice] ([ID])
GO
ALTER TABLE [dbo].[InvoiceOrder] CHECK CONSTRAINT [FK_InvoiceOrder_Invoice]
GO

ALTER TABLE [dbo].[InvoiceOrder]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceOrder_Order] FOREIGN KEY([Order])
REFERENCES [dbo].[Order] ([ID])
GO
ALTER TABLE [dbo].[InvoiceOrder] CHECK CONSTRAINT [FK_InvoiceOrder_Order]
GO
------------------------------------------------------------------------------------------------------------------------------------------

-- Size

ALTER TABLE [dbo].[Size]  WITH CHECK ADD CONSTRAINT [FK_Size_SizeSet] FOREIGN KEY([SizeSet])
REFERENCES [dbo].[SizeSet] ([ID])
GO
ALTER TABLE [dbo].[Size] CHECK CONSTRAINT [FK_Size_SizeSet]
GO
------------------------------------------------------------------------------------------------------------------------------------------

-- SizeChart

ALTER TABLE [dbo].[SizeChart]  WITH CHECK ADD CONSTRAINT [FK_SizeChart_MeasurementLocation] FOREIGN KEY([MeasurementLocation])
REFERENCES [dbo].[MeasurementLocation] ([ID])
GO
ALTER TABLE [dbo].[SizeChart] CHECK CONSTRAINT [FK_SizeChart_MeasurementLocation]
GO

ALTER TABLE [dbo].[SizeChart]  WITH CHECK ADD CONSTRAINT [FK_SizeChart_Pattern] FOREIGN KEY([Pattern])
REFERENCES [dbo].[Pattern] ([ID])
GO
ALTER TABLE [dbo].[SizeChart] CHECK CONSTRAINT [FK_SizeChart_Pattern]
GO

ALTER TABLE [dbo].[SizeChart]  WITH CHECK ADD CONSTRAINT [FK_SizeChart_Size] FOREIGN KEY([Size])
REFERENCES [dbo].[Size] ([ID])
GO
ALTER TABLE [dbo].[SizeChart] CHECK CONSTRAINT [FK_SizeChart_Size]
GO
------------------------------------------------------------------------------------------------------------------------------------------

-- SpecialPriceLevel

--ALTER TABLE [dbo].[SpecialPriceLevel]  WITH CHECK ADD CONSTRAINT [FK_SpecialPriceLevel_SpecialPrice] FOREIGN KEY([SpecialPrice])
--REFERENCES [dbo].[SpecialPrice] ([ID])
--GO
--ALTER TABLE [dbo].[SpecialPriceLevel] CHECK CONSTRAINT [FK_SpecialPriceLevel_SpecialPrice]
--GO

--ALTER TABLE [dbo].[SpecialPriceLevel]  WITH CHECK ADD CONSTRAINT [FK_SpecialPriceLevel_PriceLevel] FOREIGN KEY([PriceLevel])
--REFERENCES [dbo].[PriceLevel] ([ID])
--GO
--ALTER TABLE [dbo].[SpecialPriceLevel] CHECK CONSTRAINT [FK_SpecialPriceLevel_PriceLevel]
--GO
------------------------------------------------------------------------------------------------------------------------------------------

-- SubItem

--ALTER TABLE [dbo].[SubItem]  WITH CHECK ADD CONSTRAINT [FK_SubItem_Item] FOREIGN KEY([Item])
--REFERENCES [dbo].[Item] ([ID])
--GO
--ALTER TABLE [dbo].[SubItem] CHECK CONSTRAINT [FK_SubItem_Item]
--GO
------------------------------------------------------------------------------------------------------------------------------------------

-- User

ALTER TABLE [dbo].[User]  WITH CHECK ADD CONSTRAINT [FK_User_Company] FOREIGN KEY([Company])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_Company]
GO

ALTER TABLE [dbo].[User]  WITH CHECK ADD CONSTRAINT [FK_User_Status] FOREIGN KEY([Status])
REFERENCES [dbo].[UserStatus] ([ID])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_Status]
GO

ALTER TABLE [dbo].[User]  WITH CHECK ADD CONSTRAINT [FK_User_Creator] FOREIGN KEY([Creator])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_Creator]
GO

ALTER TABLE [dbo].[User]  WITH CHECK ADD CONSTRAINT [FK_User_Modifier] FOREIGN KEY([Modifier])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_Modifier]
GO
------------------------------------------------------------------------------------------------------------------------------------------

-- UserHistory

ALTER TABLE [dbo].[UserHistory]  WITH CHECK ADD CONSTRAINT [FK_UserHistory_User] FOREIGN KEY([User])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[UserHistory] CHECK CONSTRAINT [FK_UserHistory_User]
GO

ALTER TABLE [dbo].[UserHistory]  WITH CHECK ADD CONSTRAINT [FK_UserHistory_Creator] FOREIGN KEY([Creator])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[UserHistory] CHECK CONSTRAINT [FK_UserHistory_Creator]
GO
------------------------------------------------------------------------------------------------------------------------------------------

-- UserLogin

ALTER TABLE [dbo].[UserLogin]  WITH CHECK ADD CONSTRAINT [FK_UserLogin_User] FOREIGN KEY([User])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[UserLogin] CHECK CONSTRAINT [FK_UserLogin_User]
GO
------------------------------------------------------------------------------------------------------------------------------------------

-- UserRole

ALTER TABLE [dbo].[UserRole]  WITH CHECK ADD CONSTRAINT [FK_UserRole_User] FOREIGN KEY([User])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[UserRole] CHECK CONSTRAINT [FK_UserRole_User]
GO

ALTER TABLE [dbo].[UserRole]  WITH CHECK ADD CONSTRAINT [FK_UserRole_Role] FOREIGN KEY([Role])
REFERENCES [dbo].[Role] ([ID])
GO
ALTER TABLE [dbo].[UserRole] CHECK CONSTRAINT [FK_UserRole_Role]
GO

------------------------------------------------------------------------------------------------------------------------------------------

-- AccessoryCategory

ALTER TABLE [dbo].[AccessoryCategory]  WITH CHECK ADD CONSTRAINT [FK_AccessoryCategory_Accessory] FOREIGN KEY([Accessory])
REFERENCES [dbo].[Accessory] ([ID])
GO
ALTER TABLE [dbo].[AccessoryCategory] CHECK CONSTRAINT [FK_AccessoryCategory_Accessory]
GO

-- PatternAccessory

ALTER TABLE [dbo].[PatternAccessory]  WITH CHECK ADD CONSTRAINT [FK_PatternAccessory_Pattern] FOREIGN KEY([Pattern])
REFERENCES [dbo].[Pattern] ([ID])
GO
ALTER TABLE [dbo].[PatternAccessory] CHECK CONSTRAINT [FK_PatternAccessory_Pattern]
GO

ALTER TABLE [dbo].[PatternAccessory]  WITH CHECK ADD CONSTRAINT [FK_PatternAccessory_Accessory] FOREIGN KEY([Accessory])
REFERENCES [dbo].[Accessory] ([ID])
GO
ALTER TABLE [dbo].[PatternAccessory] CHECK CONSTRAINT [FK_PatternAccessory_Accessory]
GO

--ALTER TABLE [dbo].[PatternAccessory]  WITH CHECK ADD CONSTRAINT [FK_PatternAccessory_AccessoryColor] FOREIGN KEY([AccessoryColor])
--REFERENCES [dbo].[AccessoryColor] ([ID])
--GO
--ALTER TABLE [dbo].[PatternAccessory] CHECK CONSTRAINT [FK_PatternAccessory_AccessoryColor]
--GO

ALTER TABLE [dbo].[PatternAccessory]  WITH CHECK ADD CONSTRAINT [FK_PatternAccessory_AccessoryCategory] FOREIGN KEY([AccessoryCategory])
REFERENCES [dbo].[AccessoryCategory] ([ID])
GO
ALTER TABLE [dbo].[PatternAccessory] CHECK CONSTRAINT [FK_PatternAccessory_AccessoryCategory]
GO

-- VisualLayoutAccessory

ALTER TABLE [dbo].[VisualLayoutAccessory]  WITH CHECK ADD CONSTRAINT [FK_VisualLayoutAccessory_VisualLayout] FOREIGN KEY([VisualLayout])
REFERENCES [dbo].[VisualLayout] ([ID])
GO
ALTER TABLE [dbo].[VisualLayoutAccessory] CHECK CONSTRAINT [FK_VisualLayoutAccessory_VisualLayout]
GO

ALTER TABLE [dbo].[VisualLayoutAccessory]  WITH CHECK ADD CONSTRAINT [FK_VisualLayoutAccessory_Accessory] FOREIGN KEY([Accessory])
REFERENCES [dbo].[Accessory] ([ID])
GO
ALTER TABLE [dbo].[VisualLayoutAccessory] CHECK CONSTRAINT [FK_VisualLayoutAccessory_Accessory]
GO

ALTER TABLE [dbo].[VisualLayoutAccessory]  WITH CHECK ADD CONSTRAINT [FK_VisualLayoutAccessory_AccessoryColor] FOREIGN KEY([AccessoryColor])
REFERENCES [dbo].[AccessoryColor] ([ID])
GO
ALTER TABLE [dbo].[VisualLayoutAccessory] CHECK CONSTRAINT [FK_VisualLayoutAccessory_AccessoryColor]
GO

ALTER TABLE [dbo].[VisualLayoutAccessory]  WITH CHECK ADD CONSTRAINT [FK_VisualLayoutAccessory_AccessoryCategory] FOREIGN KEY([AccessoryCategory])
REFERENCES [dbo].[AccessoryCategory] ([ID])
GO
ALTER TABLE [dbo].[VisualLayoutAccessory] CHECK CONSTRAINT [FK_VisualLayoutAccessory_AccessoryCategory]
GO

-- FabricCode
ALTER TABLE [dbo].[FabricCode]  WITH CHECK ADD CONSTRAINT [FK_FabricCode_Currency] FOREIGN KEY([LandedCurrency])
REFERENCES [dbo].[Currency] ([ID])
GO
ALTER TABLE [dbo].[FabricCode] CHECK CONSTRAINT [FK_FabricCode_Currency]
GO

ALTER TABLE [dbo].[FabricCode]  WITH CHECK ADD CONSTRAINT [FK_FabricCode_Country] FOREIGN KEY([Country])
REFERENCES [dbo].[Country] ([ID])
GO
ALTER TABLE [dbo].[FabricCode] CHECK CONSTRAINT [FK_FabricCode_Country]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
-- Stored Procedures
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_EncryptedPassword] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[SPC_EncryptedPassword] (
	@P_Password varchar(64)
)
AS
	SELECT CONVERT(varchar(255),HashBytes('SHA1', @P_Password)) as RetVal
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_ReturnUserLogin] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPC_ReturnUserLogin] (	
	@P_Username varchar(255),
	@P_Password varchar(255)
)
AS
BEGIN
	SELECT	DISTINCT
			u.[ID],
			u.[Company],
			u.[IsDistributor],
			u.[Status],
			u.[Username],
			u.[Password],
			u.[GivenName],
			u.[FamilyName],
			u.[EmailAddress],
			u.[PhotoPath],
			u.[Creator],
			u.[CreatedDate],
			u.[Modifier],
			u.[ModifiedDate],
			u.[IsActive],
			u.[IsDeleted],
			u.[Guid],
			u.[MobileTelephoneNumber],
			u.[HomeTelephoneNumber],
			u.[OfficeTelephoneNumber],
			u.[DateLastLogin]--,
			--u.[Credits]--, 
			--u.[DistributorLabel]
	FROM	[dbo].[User] u
	WHERE 	u.Username = @P_Username 
			AND u.[Password] = CONVERT(varchar(255), HashBytes('SHA1', @P_Password))
			AND u.IsDeleted != 1
END
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
-- Views
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  View [dbo].[ReturnStringView] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ReturnStringView] 
AS 
	SELECT  '' as RetVal
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  View [dbo].[UserMenuItemRoleView] ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[UserMenuItemRoleView]'))
DROP VIEW [dbo].[UserMenuItemRoleView]
GO

/****** Object:  View [dbo].[UserMenuItemRoleView] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[UserMenuItemRoleView]
AS
SELECT DISTINCT TOP 100 PERCENT
			u.[ID] AS [User], 
			p.[ID] AS [Page], 
			mi.[ID] AS [MenuItem],
			mi.Name AS MenuName, 
			ISNULL(mi.Parent, 0) AS Parent,
			mi.Position,
			mi.IsVisible,
			p.Name AS PageName, 
			p.Title,
			p.Heading
FROM		[dbo].[User] u 
			JOIN [dbo].[UserRole] ur 
				ON u.[ID] = ur.[User]
			JOIN [dbo].[Role] r 
				ON ur.[Role] = r.[ID] 
			JOIN [dbo].[MenuItemRole] mir 
				ON r.[ID] = mir.[Role]
			JOIN [dbo].[MenuItem] mi 
				ON mir.[MenuItem] = mi.[ID]
			LEFT OUTER JOIN [dbo].[Page] p 
				ON mi.Page = p.ID
ORDER BY	mi.ID ASC, Parent, mi.Position
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  View [dbo].[ClientOrderDetailsView] ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ClientOrderDetailsView]'))
DROP VIEW [dbo].[ClientOrderDetailsView]
GO

/****** Object:  View [dbo].[ClientOrderDetailsView] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ClientOrderDetailsView]
AS
	SELECT --DISTINCT TOP 100 PERCENT
		od.[ID] AS OrderDetailId,
		co.[ID] AS CompanyId,
		co.[Name] AS CompanyName,
		o.[ID] AS OrderId,
		o.[Date],
		o.[DesiredDeliveryDate],
		o.[OrderNumber],
		o.[IsTemporary],
		cl.[ID] AS ClientId,
		cl.[Name] AS ClientName,
		ot.[ID] AS OrderTypeId,
		ot.[Name] AS OrderType,
		vl.[ID] AS VisualLayoutId,
		vl.[Name] AS VisualLayout,
		p.[ID] AS PatternId,
		p.[Number] AS PatternNumber,
		fc.[ID] AS FabricId,
		fc.[Name] AS Fabric,
		fc.[NickName] AS FabricNickName,
		os.[ID] AS [StatusId],
		os.[Name] AS [Status]
	FROM dbo.[Order] o
		INNER JOIN dbo.[OrderStatus] os
			ON  os.[ID] = o.[Status]
		INNER JOIN dbo.[OrderDetail] od
			ON o.ID = od.[Order] 
		INNER JOIN dbo.[OrderType] ot
			ON ot.[ID] = od.[OrderType]
		INNER JOIN dbo.[VisualLayout] vl
			ON vl.[ID] = od.[VisualLayout]
		INNER JOIN dbo.[Pattern] p
			ON p.[ID] = vl.[Pattern]
		INNER JOIN dbo.[FabricCode] fc
			ON fc.[ID] = vl.[FabricCode]
		INNER JOIN dbo.[Company] co   
			ON co.[ID] = o.[Distributor]
		INNER JOIN dbo.[Client] cl
			ON cl.[ID] = o.[Client]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--			

/****** Object:  View [dbo].[OrderDetailsView] ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[OrderDetailsView]'))
DROP VIEW [dbo].[OrderDetailsView]
GO

/****** Object:  View [dbo].[OrderDetailsView] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OrderDetailsView]
AS
	SELECT --DISTINCT TOP 100 PERCENT
			od.[ID] AS OrderDetailId,
			co.[ID] AS CompanyId,
			co.[Name] AS CompanyName,
			o.[ID] AS OrderId,
			o.[Date],
			o.[CreatedDate] AS OrderCreatedDate,
			o.[DesiredDeliveryDate],
			o.[EstimatedCompletionDate],
			o.[OrderSubmittedDate],
			o.[ModifiedDate] AS OrderModifiedDate,
			o.[ShipmentDate] AS OrderShipmentDate,
			o.[IsTemporary],
			o.[OrderNumber],
			o.[PurchaseOrderNo],
			o.[OldPONo] AS OldPurchaseOrderNo,
			o.[ShipTo] ShipToClientAddress,
			o.[Reservation] AS ReservationId,
			shm.[ID] AS OrderShipmentModeId,
			shm.[Name] AS OrderShipmentMode,
			cl.[ID] AS ClientId,
			cl.[Name] AS ClientName,
			u.[ID] AS UserId,
			u.[Username] AS Username,
			u.[GivenName] AS UserGivenName,
			u.[FamilyName] AS UserFamilyName,
			ot.[ID] AS OrderTypeId,
			ot.[Name] AS OrderType,
			vl.[ID] AS VisualLayoutId,
			vl.[Name] AS VisualLayout,
			p.[ID] AS PatternId,
			p.[Number] AS PatternNumber,
			fc.[ID] AS FabricId,
			fc.[Name] AS Fabric,
			fc.[NickName] AS FabricNickName,
			os.[ID] AS [StatusId],
			os.[Name] AS [Status],
			l.[ID] AS LabelID,
			l.[Name] AS LabelName,
			l.[LabelImagePath]
		FROM dbo.[Order] o
			INNER JOIN dbo.[OrderStatus] os
				ON  os.[ID] = o.[Status]
			INNER JOIN dbo.[OrderDetail] od
				ON o.[ID] = od.[Order] 
			INNER JOIN dbo.[OrderType] ot
				ON ot.[ID] = od.[OrderType]
			INNER JOIN dbo.[VisualLayout] vl
				ON vl.[ID] = od.[VisualLayout]
			INNER JOIN dbo.[Pattern] p
				ON p.[ID] = vl.[Pattern]
			INNER JOIN dbo.[FabricCode] fc
				ON fc.[ID] = vl.[FabricCode]
			INNER JOIN dbo.[Company] co
				ON co.[ID] = o.[Distributor]
			INNER JOIN dbo.[Client] cl
				ON cl.[ID] = o.[Client]
			INNER JOIN dbo.[User] u
				ON u.[ID] = o.[Creator]
			LEFT OUTER JOIN dbo.[ShipmentMode] shm
				ON shm.[ID] = o.[ShipmentMode] 
			LEFT OUTER JOIN dbo.[Label] l
				ON l.[ID]  = od.[Label]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--			

/****** Object:  View [dbo].[PriceLevelCostView]    Script Date: 07/30/2012 19:05:47 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[PriceLevelCostView]'))
DROP VIEW [dbo].[PriceLevelCostView]
GO

/****** Object:  View [dbo].[PriceLevelCostView]    Script Date: 07/30/2012 18:55:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[PriceLevelCostView]
AS
	SELECT	p.ID,
			p.[Pattern],
			p.[FabricCode],
			pt.[Number],
			pt.[NickName],
			pt.[Item],
			pt.[SubItem],
			pt.[CoreCategory],
			fc.[Name] AS FabricCodeName,
			i.Name AS ItemSubCategory,
			(	SELECT c.Name + ',' AS [text()] 
				FROM Pattern p WITH (NOLOCK)
					JOIN PatternOtherCategory poc 
						ON poc.Pattern = p.ID 
					JOIN Category c WITH (NOLOCK)
						ON poc.Category = c.ID	
				WHERE Number = pt.Number FOR XML PATH('')) AS OtherCategories,
			pt.ConvertionFactor	
	FROM	Indico.dbo.Price p WITH (NOLOCK)
			JOIN Indico.dbo.Pattern pt WITH (NOLOCK)
				ON p.Pattern = pt.ID
			JOIN Indico.dbo.FabricCode fc WITH (NOLOCK)
				ON p.FabricCode = fc.ID
			JOIN Indico.dbo.Item i WITH (NOLOCK)
				ON i.ID = pt.[SubItem]	
	INNER JOIN (
		SELECT p.[Pattern] AS PatternId,
				p.[FabricCode] AS FaricCodeId
		FROM	Indico.dbo.Price p WITH (NOLOCK)
				JOIN Indico.dbo.PriceLevelCost plc WITH (NOLOCK)
					ON p.ID	= plc.Price
		GROUP BY p.[Pattern], p.[FabricCode]) G			
			ON p.[Pattern] = G.PatternId
			AND p.[FabricCode] = G.FaricCodeId		
		
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--		
	
/****** Object:  View [dbo].[PatternCoreCategoriesView]    Script Date: 08/02/2012 18:34:38 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[PatternCoreCategoriesView]'))
DROP VIEW [dbo].[PatternCoreCategoriesView]
GO

/****** Object:  View [dbo].[PatternCoreCategoriesView]    Script Date: 08/02/2012 18:22:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
	GO

CREATE VIEW [dbo].[PatternCoreCategoriesView]
AS
	SELECT DISTINCT c.[ID], p.[CoreCategory], c1.[Name]
	FROM Category c
		JOIN PatternOtherCategory poc WITH (NOLOCK)
			ON poc.Category = c.ID
		JOIN Pattern p WITH (NOLOCK)
			ON poc.Pattern = p.ID
		JOIN Price pr WITH (NOLOCK)
			ON p.ID = pr.Pattern
		JOIN Category c1 WITH (NOLOCK)
			ON c1.ID = p.CoreCategory
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--		

/****** Object:  View [dbo].[DistributorPatternPriceLevelCostView]    Script Date: 08/03/2012 11:20:38 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[DistributorPatternPriceLevelCostView]'))
DROP VIEW [dbo].[DistributorPatternPriceLevelCostView]
GO

/****** Object:  View [dbo].[DistributorPatternPriceLevelCostView]    Script Date: 08/03/2012 10:30:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DistributorPatternPriceLevelCostView]
AS
	SELECT	plc.ID,
			plc.Price,
			plc.PriceLevel,
			plc.FactoryCost,
			plc.IndimanCost,
			dpm.Distributor,
			dpm.Markup,
			(	SELECT	dplc.IndicoCost 
				FROM	DistributorPriceLevelCost dplc WITH (NOLOCK)
				WHERE	dplc.Distributor = dpm.Distributor
						AND dplc.PriceTerm = 1
						AND dplc.PriceLevelCost = plc.ID) AS EditedCIFPrice,
			(	SELECT	dplc.IndicoCost 
				FROM	DistributorPriceLevelCost dplc WITH (NOLOCK)
				WHERE	dplc.Distributor = dpm.Distributor
						AND dplc.PriceTerm = 2
						AND dplc.PriceLevelCost = plc.ID) AS EditedFOBPrice,
			(	SELECT	CONVERT(VARCHAR(12), dplc.ModifiedDate, 113)
				FROM	DistributorPriceLevelCost dplc WITH (NOLOCK)
				WHERE	dplc.Distributor = dpm.Distributor
						AND dplc.PriceTerm = 1
						AND dplc.PriceLevelCost = plc.ID) AS ModifiedDate
	FROM PriceLevelCost plc WITH (NOLOCK)
		 JOIN DistributorPriceMarkup dpm WITH (NOLOCK)
			ON plc.PriceLevel = dpm.PriceLevel	
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--		

/****** Object:  View [dbo].[DistributorNullPatternPriceLevelCostView]    Script Date: 08/03/2012 11:20:38 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[DistributorNullPatternPriceLevelCostView]'))
DROP VIEW [dbo].[DistributorNullPatternPriceLevelCostView]
GO

/****** Object:  View [dbo].[DistributorNullPatternPriceLevelCostView]    Script Date: 08/03/2012 10:30:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DistributorNullPatternPriceLevelCostView]
AS
	SELECT	plc.ID,
			plc.Price,
			plc.PriceLevel,
			plc.FactoryCost,
			plc.IndimanCost,
			dpm.Distributor,
			dpm.Markup,
			(	SELECT	dplc.IndicoCost 
				FROM	DistributorPriceLevelCost dplc WITH (NOLOCK)
				WHERE	dplc.Distributor is null
						AND dplc.PriceTerm = 1
						AND dplc.PriceLevelCost = plc.ID) AS EditedCIFPrice,
			(	SELECT	dplc.IndicoCost 
				FROM	DistributorPriceLevelCost dplc WITH (NOLOCK)
				WHERE	dplc.Distributor is null
						AND dplc.PriceTerm = 2
						AND dplc.PriceLevelCost = plc.ID) AS EditedFOBPrice,
			(	SELECT	CONVERT(VARCHAR(12), dplc.ModifiedDate, 113)
				FROM	DistributorPriceLevelCost dplc WITH (NOLOCK)
				WHERE	dplc.Distributor is null
						AND dplc.PriceTerm = 1
						AND dplc.PriceLevelCost = plc.ID) AS ModifiedDate
	FROM PriceLevelCost plc WITH (NOLOCK)
		 JOIN DistributorPriceMarkup dpm WITH (NOLOCK)
			ON plc.PriceLevel = dpm.PriceLevel
	WHERE dpm.Distributor IS NULL	
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--	

/****** Object:  View [dbo].[ExcelPriceLevelCostView]    Script Date: 08/06/2012 12:55:31 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ExcelPriceLevelCostView]'))
DROP VIEW [dbo].[ExcelPriceLevelCostView]
GO

/****** Object:  View [dbo].[ExcelPriceLevelCostView]    Script Date: 08/06/2012 10:29:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[ExcelPriceLevelCostView]
AS

SELECT		p.ID AS 'PriceID',
			c.Name AS 'SportsCategory',
			(	SELECT c.Name + ',' AS [text()] 
				FROM Pattern p
					JOIN PatternOtherCategory poc 
						ON poc.Pattern = p.ID 
					JOIN Category c
						ON poc.Category = c.ID	
				WHERE Number = pt.Number FOR XML PATH('')) AS 'OtherCategories',
			p.[Pattern] AS 'PatternID',
			(	SELECT  i.Name
				FROM Item i  
				WHERE i.ID = SubItem) AS ItemSubCategoris,
			pt.[NickName],
			fc.[Name] AS FabricCodeName,			
			pt.[Number],	
			pt.ConvertionFactor	
	FROM	Indico.dbo.Price p
			JOIN Indico.dbo.Pattern pt
				ON p.Pattern = pt.ID
			JOIN Indico.dbo.FabricCode fc
				ON p.FabricCode = fc.ID
			JOIN Indico.dbo.Item i
				ON i.ID = pt.[SubItem]
			JOIN Indico.dbo.Category c
				ON pt.CoreCategory = C.ID
	INNER JOIN (
		SELECT p.[Pattern] AS PatternId,
				p.[FabricCode] AS FaricCodeId
		FROM	Indico.dbo.Price p
				JOIN Indico.dbo.PriceLevelCost plc
					ON p.ID	= plc.Price
		GROUP BY p.[Pattern], p.[FabricCode]) G			
			ON p.[Pattern] = G.PatternId
			AND p.[FabricCode] = G.FaricCodeId	
		--ORDER BY C.Name		

GO


