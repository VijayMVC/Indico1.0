USE Indico
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

-- Cost sheet inserts

  INSERT INTO [dbo].PatternSupportFabric (Fabric, FabConstant, CostSheet)
  VALUES (167, 0.20, 458)
  GO

  INSERT INTO [dbo].PatternSupportFabric (Fabric, FabConstant, CostSheet)
  VALUES (3, 1.40, 458)
  GO

  INSERT INTO [dbo].PatternSupportAccessory (Accessory, AccConstant, Pattern, CostSheet)
  VALUES (68, 4.00, 290, 458)
  GO

  INSERT INTO [dbo].PatternSupportAccessory (Accessory, AccConstant, Pattern, CostSheet)
  VALUES (83, 0.65, 290, 458)
  GO

  INSERT INTO [dbo].PatternSupportAccessory (Accessory, AccConstant, Pattern, CostSheet)
  VALUES (115, 0.65, 290, 458)
  GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

