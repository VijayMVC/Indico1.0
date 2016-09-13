USE [Indico] 
GO


--**--**--**--**--**--**--**--**--**--**--**--** UPDATE COORDINATOR --**--**--**--**--**--**--**--**--**--**--**--**
DECLARE @USERID AS int

SET @USERID = (SELECT [ID]  FROM [Indico].[dbo].[User]  WHERE [GivenName] = 'Mark' AND [FamilyName] = 'Ingram') 

UPDATE [Indico].[dbo].[Company] SET [Coordinator] = @USERID WHERE [IsDistributor] = 1
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


--**--**--**--**--**--**--**--**--**--**--**--**DROP DISTRIBUTOR COLUMN IN VISUALLAYOUT--**--**--**--**--**--**--**--**--**--**--**--**

ALTER TABLE [dbo].[VisualLayout] DROP CONSTRAINT [FK_VisualLayout_Distributor]
GO
ALTER TABLE [dbo].[VisualLayout]
DROP COLUMN [Distributor]

GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--**--**--**--**DROP DISTRIBUTOR COLUMN IN VISUALLAYOUT--**--**--**--**--**--**--**--**--**--**--**--**
ALTER TABLE [dbo].[VisualLayout] DROP CONSTRAINT [FK_VisualLayout_Coordinator]
GO
ALTER TABLE [dbo].[VisualLayout]
DROP COLUMN [Coordinator]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

