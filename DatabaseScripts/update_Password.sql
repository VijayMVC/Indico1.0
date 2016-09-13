USE [Indico] 
GO

UPDATE [Indico] .[dbo].[User] SET [Password] = CONVERT(varchar(255), HashBytes('SHA1', 'password'))
GO

UPDATE [Indico] .[dbo].[User] SET [EmailAddress] = 'danesh@bourketechnologies.com'
GO

UPDATE [Indico] .[dbo].[Settings] SET [Value] = 'danesh@bourketechnologies.com' WHERE [Key] = 'DSOCC'
GO

UPDATE [Indico] .[dbo].[Settings] SET [Value] = 'danesh@bourketechnologies.com' WHERE [Key] = 'CSOTO'
GO

UPDATE [Indico] .[dbo].[Settings] SET [Value] = 'danesh@bourketechnologies.com' WHERE [Key] = 'CSOCC'
GO

UPDATE [Indico] .[dbo].[Settings] SET [Value] = 'danesh@bourketechnologies.com' WHERE [Key] = 'ISOTO'
GO

