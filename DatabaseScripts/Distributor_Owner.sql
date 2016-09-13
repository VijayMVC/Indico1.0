USE [Indico] 
GO


DECLARE @Company AS int
DECLARE @User AS int
DECLARE @Role As int 

SET @Company = (SELECT [ID] FROM [dbo].[Company] WHERE [Name] = 'BUD CLOTHING')
SET @User = (SELECT [ID] FROM [dbo].[User] WHERE [GivenName] = 'BUD CLOTHING')
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Distributor Administrator')

UPDATE [dbo].[Company] SET [Owner] = @User WHERE [ID] = @Company

INSERT INTO [Indico].[dbo].[UserRole] ([User], [Role]) VALUES (@User, @Role)
GO

DECLARE @Company AS int
DECLARE @User AS int
DECLARE @Role As int 

SET @Company = (SELECT [ID] FROM [dbo].[Company] WHERE [Name] = 'BMC')
SET @User = (SELECT [ID] FROM [dbo].[User] WHERE [GivenName] = 'BMC')
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Distributor Administrator')

UPDATE [dbo].[Company] SET [Owner] = @User WHERE [ID] = @Company

INSERT INTO [Indico].[dbo].[UserRole] ([User], [Role]) VALUES (@User, @Role)
GO

DECLARE @Company AS int
DECLARE @User AS int
DECLARE @Role As int 

SET @Company = (SELECT [ID] FROM [dbo].[Company] WHERE [Name] = 'BRAND SUCCESS')
SET @User = (SELECT [ID] FROM [dbo].[User] WHERE [GivenName] = 'BRAND SUCCESS')
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Distributor Administrator')

UPDATE [dbo].[Company] SET [Owner] = @User WHERE [ID] = @Company

INSERT INTO [Indico].[dbo].[UserRole] ([User], [Role]) VALUES (@User, @Role)
GO

DECLARE @Company AS int
DECLARE @User AS int
DECLARE @Role As int 

SET @Company = (SELECT [ID] FROM [dbo].[Company] WHERE [Name] = 'A1 APPAREL')
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Distributor Administrator')

INSERT INTO [Indico].[dbo].[User]
           ([Company]
           ,[IsDistributor]
           ,[Status]
           ,[Username]
           ,[Password]
           ,[GivenName]
           ,[FamilyName]
           ,[EmailAddress]
           ,[PhotoPath]
           ,[Creator]
           ,[CreatedDate]
           ,[Modifier]
           ,[ModifiedDate]
           ,[IsActive]
           ,[IsDeleted]
           ,[Guid]
           ,[OfficeTelephoneNumber]
           ,[MobileTelephoneNumber]
           ,[HomeTelephoneNumber]
           ,[DateLastLogin]
           ,[HaveAccessForHTTPPost]
           ,[Designation])
     VALUES
           (@Company
           ,1
           ,1
           ,'admin_' + CONVERT(NVARCHAR(255),@Company)
           ,CONVERT(varchar(255), HashBytes('SHA1', 'password'))
           ,'Test'
           ,'User'
           ,'noreply@indico.com'
           ,NULL
           ,1
           ,GETDATE()
           ,1
           ,GETDATE()
           ,1
           ,0
           , NEWID()
           ,123456
           ,NULL
           ,NULL
           ,NULL
           ,0
           ,NULL)

SET @User = SCOPE_IDENTITY()
UPDATE [dbo].[Company] SET [Owner] = @User WHERE [ID] = @Company

INSERT INTO [Indico].[dbo].[UserRole] ([User], [Role]) VALUES (@User, @Role)
GO

DECLARE @Company AS int
DECLARE @User AS int
DECLARE @Role As int 

SET @Company = (SELECT [ID] FROM [dbo].[Company] WHERE [Name] = 'INDICO PTY LTD')
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Distributor Administrator')

INSERT INTO [Indico].[dbo].[User]
           ([Company]
           ,[IsDistributor]
           ,[Status]
           ,[Username]
           ,[Password]
           ,[GivenName]
           ,[FamilyName]
           ,[EmailAddress]
           ,[PhotoPath]
           ,[Creator]
           ,[CreatedDate]
           ,[Modifier]
           ,[ModifiedDate]
           ,[IsActive]
           ,[IsDeleted]
           ,[Guid]
           ,[OfficeTelephoneNumber]
           ,[MobileTelephoneNumber]
           ,[HomeTelephoneNumber]
           ,[DateLastLogin]
           ,[HaveAccessForHTTPPost]
           ,[Designation])
     VALUES
           (@Company
           ,1
           ,1
           ,'admin_' + CONVERT(NVARCHAR(255),@Company)
           ,CONVERT(varchar(255), HashBytes('SHA1', 'password'))
           ,'Test'
           ,'User'
           ,'noreply@indico.com'
           ,NULL
           ,1
           ,GETDATE()
           ,1
           ,GETDATE()
           ,1
           ,0
           , NEWID()
           ,123456
           ,NULL
           ,NULL
           ,NULL
           ,0
           ,NULL)

SET @User = SCOPE_IDENTITY()
UPDATE [dbo].[Company] SET [Owner] = @User WHERE [ID] = @Company

INSERT INTO [Indico].[dbo].[UserRole] ([User], [Role]) VALUES (@User, @Role)
GO

DECLARE @Company AS int
DECLARE @User AS int
DECLARE @Role As int 

SET @Company = (SELECT [ID] FROM [dbo].[Company] WHERE [Name] = 'AUSSIE CLOBBER')
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Distributor Administrator')

INSERT INTO [Indico].[dbo].[User]
           ([Company]
           ,[IsDistributor]
           ,[Status]
           ,[Username]
           ,[Password]
           ,[GivenName]
           ,[FamilyName]
           ,[EmailAddress]
           ,[PhotoPath]
           ,[Creator]
           ,[CreatedDate]
           ,[Modifier]
           ,[ModifiedDate]
           ,[IsActive]
           ,[IsDeleted]
           ,[Guid]
           ,[OfficeTelephoneNumber]
           ,[MobileTelephoneNumber]
           ,[HomeTelephoneNumber]
           ,[DateLastLogin]
           ,[HaveAccessForHTTPPost]
           ,[Designation])
     VALUES
           (@Company
           ,1
           ,1
           ,'admin_' + CONVERT(NVARCHAR(255),@Company)
           ,CONVERT(varchar(255), HashBytes('SHA1', 'password'))
           ,'Test'
           ,'User'
           ,'noreply@indico.com'
           ,NULL
           ,1
           ,GETDATE()
           ,1
           ,GETDATE()
           ,1
           ,0
           , NEWID()
           ,123456
           ,NULL
           ,NULL
           ,NULL
           ,0
           ,NULL)

SET @User = SCOPE_IDENTITY()
UPDATE [dbo].[Company] SET [Owner] = @User WHERE [ID] = @Company

INSERT INTO [Indico].[dbo].[UserRole] ([User], [Role]) VALUES (@User, @Role)
GO

