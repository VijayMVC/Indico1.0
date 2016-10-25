USE Indico
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_UpdateOrderStatusToShipped]') AND type in (N'P', N'PC'))
      DROP PROCEDURE [dbo].[SPC_UpdateOrderStatusToShipped]
GO

CREATE PROC [dbo].[SPC_UpdateOrderStatusToShipped]
	@P_OrderDetailIds nvarchar(max)
AS
BEGIN
	DECLARE @ODs TABLE ( ID int )
	INSERT INTO @ODs (ID) SELECT DATA FROM [dbo].Split(@P_OrderDetailIds,',')
	
	UPDATE od
	SET od.[Status] = 16 --Shipped
	FROM [dbo].[OrderDetail] od
		INNER JOIN @ODs ods
			ON ods.ID = od.ID

	UPDATE o
	SET o.[Status] = 21 --Completed
	FROM [dbo].[OrderDetail] od
		INNER JOIN @ODs ods
			ON ods.ID = od.ID
		INNER JOIN [dbo].[Order] o
			ON od.[Order] = o.ID

END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--