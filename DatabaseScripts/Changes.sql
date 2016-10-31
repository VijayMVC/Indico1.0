USE Indico
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

--Correction for order transferring --

UPDATE [dbo].[Order] SET BillingAddress = '1506' WHERE BillingAddress = '1069'
GO

UPDATE [dbo].[Order] SET DespatchToAddress = '1506' WHERE DespatchToAddress = '905'
GO

UPDATE [dbo].[Order] SET  DespatchToAddress = '1506' WHERE DespatchToAddress = '1069'
GO

UPDATE [dbo].[Order] SET BillingAddress = '1506' WHERE BillingAddress = '905'
GO

DELETE FROM [dbo].[DistributorClientAddress] WHERE ID = '1069'
GO

DELETE FROM [dbo].[DistributorClientAddress] WHERE ID = '905'
GO


--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--