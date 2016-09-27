USE Indico
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_TransferDistributor]') AND type in (N'P', N'PC'))
      DROP PROCEDURE [dbo].[SPC_TransferDistributor]
GO

CREATE PROCEDURE [dbo].[SPC_TransferDistributor]
	@P_FromDistributor int,
	@P_ToDistributor int
AS
	BEGIN
		DECLARE @Distributor int 
		DECLARE @ToDistributor int

		SET @Distributor = (SELECT TOP 1 ID FROM [dbo].[Company] WHERE ID = @P_FromDistributor)
		SET @ToDistributor = (SELECT TOP 1 ID FROM [dbo].[Company] WHERE ID = @P_ToDistributor)

		IF (@Distributor > 0 AND @ToDistributor > 0)
		BEGIN
			DECLARE @Label int
			SET @Label=(SELECT TOP 1 dl.Label 
						FROM [dbo].[DistributorLabel] dl WHERE dl.Distributor = @ToDistributor)

			UPDATE od SET Label = @Label
			FROM [dbo].[Order] o
				INNER JOIN [dbo].[OrderDetail] od
					ON od.[Order] = o.ID
			WHERE Distributor = @Distributor

			UPDATE [dbo].[Client] SET Distributor = @ToDistributor
			WHERE Distributor = @Distributor
		END
	END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_TransferJobName]') AND type in (N'P', N'PC'))
      DROP PROCEDURE [dbo].[SPC_TransferJobName]
GO

CREATE PROC [dbo].[SPC_TransferJobName]
	@P_JobName int,
	@P_Distributor int
AS
BEGIN
	DECLARE @Client int 
	DECLARE @ClientDistributor int 
	DECLARE @ClientName nvarchar(64)

	SET @Client = (SELECT TOP 1 cl.ID FROM [dbo].[Client] cl 
						INNER JOIN [dbo].[JobName] jn
							ON cl.ID = jn.Client
				   WHERE jn.ID = @P_JobName)

	SET @ClientDistributor = (SELECT TOP 1 d.ID 
							FROM [dbo].[Client] c
								INNER JOIN [dbo].[Company] d
									ON c.Distributor = d.ID
							WHERE c.ID = @Client)

	SET @ClientName = (SELECT TOP 1 cl.Name FROM [dbo].[Client] cl 
						    WHERE cl.ID = @Client)



	IF NOT EXISTS (SELECT cl.ID FROM [dbo].[Company] di
							INNER JOIN  [dbo].[Client] cl
								ON cl.Distributor = di.ID
			   WHERE cl.Name = @ClientName AND di.ID = @P_Distributor)
	BEGIN
		INSERT INTO [dbo].[Client] (Name,Distributor,[Description],FOCPenalty)
			SELECT TOP 1 Name,@P_Distributor,[Description],FOCPenalty 
			FROM [dbo].[Client] 
			WHERE ID = @Client
		SET @Client = SCOPE_IDENTITY()
	END
	ELSE 
	BEGIN
		SET @Client = (SELECT TOP 1 cl.ID FROM [dbo].[Company] di
							INNER JOIN  [dbo].[Client] cl
								ON cl.Distributor = di.ID
			   WHERE cl.Name = @ClientName AND di.ID = @P_Distributor)
	END

	DECLARE @Label int

	SET @Label=(SELECT TOP 1 dl.Label 
					FROM [dbo].[DistributorLabel] dl WHERE dl.Distributor = @P_Distributor)

	UPDATE  od SET Label = @Label
	FROM [dbo].[JobName] jn
		INNER JOIN [dbo].[Order] o
			ON o.Client = jn.ID
		INNER JOIN [dbo].[OrderDetail] od
			ON od.[Order] = o.ID
	WHERE jn.ID = @P_JobName

	UPDATE [dbo].[JobName] SET Client = @Client WHERE ID = @P_JobName
END
GO


--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--