USE [Indico]
GO

ALTER TABLE [dbo].[DistributorClientAddress]
	ADD [IsAdelaideWarehouse] [bit] NOT NULL CONSTRAINT [DF_DistributorClientAddress_IsAdelaideWarehouse] DEFAULT ((0))
GO

UPDATE [dbo].[DistributorClientAddress]
	SET [IsAdelaideWarehouse] = 1 
FROM [dbo].[DistributorClientAddress]
WHERE [ID] = 105
GO 

ALTER TABLE [dbo].[DistributorClientAddress]
	ADD [Distributor] [int] NULL 
GO

ALTER TABLE [dbo].[DistributorClientAddress]  WITH CHECK ADD  CONSTRAINT [FK_DistributorClientAddress_Distributor] FOREIGN KEY([Distributor])
REFERENCES [dbo].[Company] ([ID])
GO

ALTER TABLE [dbo].[DistributorClientAddress] CHECK CONSTRAINT [FK_DistributorClientAddress_Distributor]
GO

UPDATE [dbo].[DistributorClientAddress]
	SET [Distributor] = c.[ID]
FROM [dbo].[DistributorClientAddress] d
		JOIN [dbo].[Company] c
			ON c.Name = d.CompanyName
GO