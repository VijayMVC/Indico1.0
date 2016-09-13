USE [Indico]
GO

/****** Object:  StoredProcedure [dbo].[SPC_UpdateDutyRateExchnageRateCostSheet]    Script Date: 12/09/2014 14:29:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_UpdateDutyRateExchnageRateCostSheet]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_UpdateDutyRateExchnageRateCostSheet]
GO

USE [Indico]
GO

/****** Object:  StoredProcedure [dbo].[SPC_UpdateDutyRateExchnageRateCostSheet]    Script Date: 12/09/2014 14:29:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SPC_UpdateDutyRateExchnageRateCostSheet]
(
	@P_DutyRate AS decimal(8,2),
	@P_ExchangeRate AS decimal(8,2)
)
AS
BEGIN

DECLARE @RetVal int

	BEGIN TRY

		IF(@P_DutyRate !=0)
			BEGIN
				UPDATE [dbo].[CostSheet] SET [DutyRate] = @P_DutyRate
			END
		IF(@P_ExchangeRate !=0)
			BEGIN
				UPDATE [dbo].[CostSheet] SET [ExchangeRate] = @P_ExchangeRate
			END
			
		
		SET @RetVal = 1
		
	END TRY
	BEGIN CATCH
	
		SET @RetVal = 0
	
	END CATCH

SELECT @RetVal AS RetVal		

END

GO


