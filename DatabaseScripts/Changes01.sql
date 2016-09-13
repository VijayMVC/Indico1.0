USE [Indico]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

DELETE FROM Indico.dbo.DistributorPriceLevelCost 
WHERE Distributor != 199 AND Distributor IS NOT NULL
GO