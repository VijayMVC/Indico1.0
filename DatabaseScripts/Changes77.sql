USE [Indico]
GO


DECLARE @Page As int 
DECLARE @Parent AS int
DECLARE @MenuItem As int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewProductionCapacities.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)

UPDATE [dbo].[MenuItem] SET [Name] = 'Production Capacities' WHERE [ID] = @MenuItem
GO

---**-**-**---**-**-**---**-**-**---**-**-**---**-**-**---**-**-**---**-**-**---**-**-**---**-**-**---**-**-**---**-**-**