USE [Indico] 
GO
/*****ALTER TABLE Fabric Code******/

ALTER TABLE [Indico].[dbo].[FabricCode]
ALTER COLUMN[NickName] NVARCHAR(255) NOT NULL

GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

/*****ALTER TABLE Order******/

ALTER TABLE [Indico].[dbo].[Order]
ALTER COLUMN [DesiredDeliveryDate] DATETIME2(7) NULL

GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**