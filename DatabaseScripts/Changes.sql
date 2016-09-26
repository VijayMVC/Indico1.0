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
			UPDATE [dbo].[Client] SET Distributor = @ToDistributor
				WHERE Distributor = @Distributor
		END
	END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--