USE Indico
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

	UPDATE [dbo].[OrderDetail]
	SET [DespatchTo] = 105
	WHERE ID = 33023 OR ID = 33070 OR ID = 52144
	GO

	UPDATE [dbo].[Order]
	SET BillingAddress = 984
	WHERE BillingAddress = 1466
	GO
	
	DELETE FROM [dbo].[DistributorClientAddress]
	WHERE ID > 1465
	GO
	
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--