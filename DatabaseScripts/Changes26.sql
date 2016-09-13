USE [Indico] 
GO
------ DELETE dbo].[AcquiredVisulaLayoutName] ----------------
--DELETE FROM [dbo].[AcquiredVisulaLayoutName]
--GO
--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

------ UPDATE VISUALlAYOUT TABLE ------------------------
DECLARE @VLID AS int

SET @VLID = (SELECT [ID] FROM [dbo].[VisualLayout] WHERE [NamePrefix] = 'VL' AND [NameSuffix] = 15493)
UPDATE [dbo].[VisualLayout] SET [NamePrefix] = 'VL15493', [NameSuffix] = NULL WHERE [ID] = @VLID
GO

--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

------ DELETE [dbo].[SizeChart] ----------------
DECLARE @PID AS int
SET @PID = (SELECT [ID] FROM [dbo].[Pattern] WHERE [Number] = '3040')

DELETE FROM [dbo].[SizeChart]
      WHERE [Pattern] = @PID AND [MeasurementLocation] IN(54, 55, 56, 57, 99, 103)
GO

--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**


