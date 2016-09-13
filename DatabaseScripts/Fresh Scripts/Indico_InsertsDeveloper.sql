USE [Indico]
GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

DECLARE @CompanyId int
DECLARE @UserId int
DECLARE @CordinatorUserId int 

-- Indico Factory --
INSERT INTO [dbo].[Company]
            ([Type],[IsDistributor],[Name],[Number],[Address1],[Address2],[City],[Postcode],[State],[Phone1],[Phone2],[Country],
            [Coordinator],[Owner],[Creator],[CreatedDate],[Modifier],[ModifiedDate])
     VALUES (1,0,'Factory','No 121','Address Line One','Address Line Two','City','101 010','State','+61 111 1112',NULL,7,
			1,1,1,CAST(GETDATE() AS datetime2(7)),1,CAST(GETDATE() AS datetime2(7)))
SET @CompanyId = SCOPE_IDENTITY()

-- Indico Factory Administrator --
INSERT INTO [dbo].[User]
            ([Company],[IsDistributor],[Status],[Username],[Password],[GivenName],[FamilyName],[EmailAddress],[PhotoPath],
            [Creator],[CreatedDate],[Modifier],[ModifiedDate],[IsActive],[IsDeleted],
            [Guid],[MobileTelephoneNumber],[HomeTelephoneNumber],[OfficeTelephoneNumber],[DateLastLogin])
     VALUES (@CompanyId,0,1,'f_admin',CONVERT(varchar(255), HashBytes('SHA1', 'password')),'Factory','Administrator','fadministrator@indico.com','indiman_administrator.png',
			1,CAST(GETDATE() AS datetime2(7)),1,CAST(GETDATE() AS datetime2(7)),1,0,
			'db5d649b-9a97-4f40-b1b8-a7d50a479141','+61 111 1112',NULL,'+61 111 1113',NULL)
SET @UserId = SCOPE_IDENTITY()

UPDATE	[dbo].[Company]
	SET	[Owner] = @UserId
WHERE	[ID] = @CompanyId

-- User Role --
INSERT INTO [dbo].[UserRole]
            ([User],[Role])
     VALUES (@UserId,2)

-- Indico Factory Coordinator --
INSERT INTO [dbo].[User]
            ([Company],[IsDistributor],[Status],[Username],[Password],[GivenName],[FamilyName],[EmailAddress],[PhotoPath],
            [Creator],[CreatedDate],[Modifier],[ModifiedDate],[IsActive],[IsDeleted],
            [Guid],[MobileTelephoneNumber],[HomeTelephoneNumber],[OfficeTelephoneNumber],[DateLastLogin])
     VALUES (@CompanyId,0,1,'FCoordinator',CONVERT(varchar(255), HashBytes('SHA1', 'password')),'Factory','Coordinator','fcoordinator@indico.com','indiman_administrator.png',
			1,CAST(GETDATE() AS datetime2(7)),1,CAST(GETDATE() AS datetime2(7)),1,0,
			'db5d649b-9a97-4f40-b1b8-a7d50a479141','+61 111 1112',NULL,'+61 111 1113',NULL)
SET @UserId = SCOPE_IDENTITY()

-- User Role --
INSERT INTO [dbo].[UserRole]
            ([User],[Role])
     VALUES (@UserId,3)

-- Indico Factory Pattern Developer --
INSERT INTO [dbo].[User]
            ([Company],[IsDistributor],[Status],[Username],[Password],[GivenName],[FamilyName],[EmailAddress],[PhotoPath],
            [Creator],[CreatedDate],[Modifier],[ModifiedDate],[IsActive],[IsDeleted],
            [Guid],[MobileTelephoneNumber],[HomeTelephoneNumber],[OfficeTelephoneNumber],[DateLastLogin])
     VALUES (@CompanyId,0,1,'FPattern',CONVERT(varchar(255), HashBytes('SHA1', 'password')),'Factory','Pattern Developer','fpatterndeveloper@indico.com','indiman_administrator.png',
			1,CAST(GETDATE() AS datetime2(7)),1,CAST(GETDATE() AS datetime2(7)),1,0,
			'db5d649b-9a97-4f40-b1b8-a7d50a479141','+61 111 1112',NULL,'+61 111 1113',NULL)
SET @UserId = SCOPE_IDENTITY()

-- User Role --
INSERT INTO [dbo].[UserRole]
            ([User],[Role])
     VALUES (@UserId,4)
----------------------------------------------------------------------------------------------------------------------
     
-- Indico Manufacturer --
INSERT INTO [dbo].[Company]
            ([Type],[IsDistributor],[Name],[Number],[Address1],[Address2],[City],[Postcode],[State],[Phone1],[Phone2],[Country],
            [Coordinator],[Owner],[Creator],[CreatedDate],[Modifier],[ModifiedDate])
     VALUES (2,0,'Indiman','No 121','Address Line One','Address Line Two','City','101 010','State','+61 111 1112',NULL,7,
			2,2,2,CAST(GETDATE() AS datetime2(7)),2,CAST(GETDATE() AS datetime2(7)))
SET @CompanyId = SCOPE_IDENTITY()

-- Indico Manufacturer Administrator --
INSERT INTO [dbo].[User]
            ([Company],[IsDistributor],[Status],[Username],[Password],[GivenName],[FamilyName],[EmailAddress],[PhotoPath],
            [Creator],[CreatedDate],[Modifier],[ModifiedDate],[IsActive],[IsDeleted],
            [Guid],[MobileTelephoneNumber],[HomeTelephoneNumber],[OfficeTelephoneNumber],[DateLastLogin])
     VALUES (@CompanyId,0,1,'m_admin',CONVERT(varchar(255), HashBytes('SHA1', 'password')),'Indiman','Administrator','madministrator@indico.com','indiman_administrator.png',
			1,CAST(GETDATE() AS datetime2(7)),1,CAST(GETDATE() AS datetime2(7)),1,0,
			'32494092-e226-4208-be7f-993421ce8bd0','+61 111 1112',NULL,'+61 111 1113',NULL)
SET @UserId = SCOPE_IDENTITY()

UPDATE	[dbo].[Company]
	SET	[Owner] = @UserId
WHERE	[ID] = @CompanyId

-- User Role --
INSERT INTO [dbo].[UserRole]
            ([User],[Role])
     VALUES (@UserId,5)

-- Indico Manufacturer Cordinator --
INSERT INTO [dbo].[User]
            ([Company],[IsDistributor],[Status],[Username],[Password],[GivenName],[FamilyName],[EmailAddress],[PhotoPath],
            [Creator],[CreatedDate],[Modifier],[ModifiedDate],[IsActive],[IsDeleted],
            [Guid],[MobileTelephoneNumber],[HomeTelephoneNumber],[OfficeTelephoneNumber],[DateLastLogin])
     VALUES (@CompanyId,0,1,'MCoordinator',CONVERT(varchar(255), HashBytes('SHA1', 'password')),'Indiman','Coordinator','mcoordinator@indico.com','indiman_administrator.png',
			1,CAST(GETDATE() AS datetime2(7)),1,CAST(GETDATE() AS datetime2(7)),1,0,
			'32494092-e226-4208-be7f-993421ce8bd0','+61 111 1112',NULL,'+61 111 1113',NULL)
SET @UserId = SCOPE_IDENTITY()

-- User Role --
INSERT INTO [dbo].[UserRole]
            ([User],[Role])
     VALUES (@UserId,6)   
----------------------------------------------------------------------------------------------------------------------

-- Indico Sales --
INSERT INTO [dbo].[Company]
            ([Type],[IsDistributor],[Name],[Number],[Address1],[Address2],[City],[Postcode],[State],[Phone1],[Phone2],[Country],
            [Coordinator],[Owner],[Creator],[CreatedDate],[Modifier],[ModifiedDate])
     VALUES (3,0,'Indico','No 121','Address Line One','Address Line Two','City','101 010','State','+61 111 1112',NULL,7,
			2,2,2,CAST(GETDATE() AS datetime2(7)),2,CAST(GETDATE() AS datetime2(7)))
SET @CompanyId = SCOPE_IDENTITY()
    
-- Indico Sales Administrator --
INSERT INTO [dbo].[User]
            ([Company],[IsDistributor],[Status],[Username],[Password],[GivenName],[FamilyName],[EmailAddress],[PhotoPath],
            [Creator],[CreatedDate],[Modifier],[ModifiedDate],[IsActive],[IsDeleted],
            [Guid],[MobileTelephoneNumber],[HomeTelephoneNumber],[OfficeTelephoneNumber],[DateLastLogin])
     VALUES (@CompanyId,0,1,'s_admin',CONVERT(varchar(255), HashBytes('SHA1', 'password')),'Indico','Administrator','sadministrator@indico.com','pattern_developer.png',
			2,CAST(GETDATE() AS datetime2(7)),2,CAST(GETDATE() AS datetime2(7)),1,0,
			'a031a081-d25d-445c-84ed-d121f8e9190e','+61 111 1112',NULL,'+61 111 1113',NULL)
SET @UserId = SCOPE_IDENTITY()
SET @CordinatorUserId = @UserId

UPDATE	[dbo].[Company]
	SET	[Owner] = @UserId
WHERE	[ID] = @CompanyId

-- User Role --
INSERT INTO [dbo].[UserRole]
            ([User],[Role])
     VALUES (@UserId,7) 

-- Indico Sales Coordinator --
INSERT INTO [dbo].[User]
            ([Company],[IsDistributor],[Status],[Username],[Password],[GivenName],[FamilyName],[EmailAddress],[PhotoPath],
            [Creator],[CreatedDate],[Modifier],[ModifiedDate],[IsActive],[IsDeleted],
            [Guid],[MobileTelephoneNumber],[HomeTelephoneNumber],[OfficeTelephoneNumber],[DateLastLogin])
     VALUES (@CompanyId,0,1,'SCoordinator',CONVERT(varchar(255), HashBytes('SHA1', 'password')),'Indico','Coordinator','scoordinator@indico.com','pattern_developer.png',
			2,CAST(GETDATE() AS datetime2(7)),2,CAST(GETDATE() AS datetime2(7)),1,0,
			'a031a081-d25d-445c-84ed-d121f8e9190e','+61 111 1112',NULL,'+61 111 1113',NULL)
SET @UserId = SCOPE_IDENTITY()

-- User Role --
INSERT INTO [dbo].[UserRole]
            ([User],[Role])
     VALUES (@UserId,8)
     
-- Indico Sales Pattern Developer --
INSERT INTO [dbo].[User]
            ([Company],[IsDistributor],[Status],[Username],[Password],[GivenName],[FamilyName],[EmailAddress],[PhotoPath],
            [Creator],[CreatedDate],[Modifier],[ModifiedDate],[IsActive],[IsDeleted],
            [Guid],[MobileTelephoneNumber],[HomeTelephoneNumber],[OfficeTelephoneNumber],[DateLastLogin])
     VALUES (@CompanyId,0,1,'SPattern',CONVERT(varchar(255), HashBytes('SHA1', 'password')),'Indico','Pattern Developer','spatterndeveloper@indico.com','pattern_developer.png',
			2,CAST(GETDATE() AS datetime2(7)),2,CAST(GETDATE() AS datetime2(7)),1,0,
			'a031a081-d25d-445c-84ed-d121f8e9190e','+61 111 1112',NULL,'+61 111 1113',NULL)
SET @UserId = SCOPE_IDENTITY()

-- User Role --
INSERT INTO [dbo].[UserRole]
            ([User],[Role])
     VALUES (@UserId,9)
----------------------------------------------------------------------------------------------------------------------

-- Indico Distributor --
INSERT INTO [dbo].[Company]
            ([Type],[IsDistributor],[Name],[Number],[Address1],[Address2],[City],[Postcode],[State],[Phone1],[Phone2],[Country],
            [Coordinator],[Owner],[Creator],[CreatedDate],[Modifier],[ModifiedDate])
     VALUES (4,1,'Distributor','No 121','Address Line One','Address Line Two','City','101 010','State','+61 111 1112',NULL,7,
			@CordinatorUserId,2,2,CAST(GETDATE() AS datetime2(7)),2,CAST(GETDATE() AS datetime2(7)))
SET @CompanyId = SCOPE_IDENTITY()

-- Indico Distributor Administrator --
INSERT INTO [dbo].[User]
            ([Company],[IsDistributor],[Status],[Username],[Password],[GivenName],[FamilyName],[EmailAddress],[PhotoPath],
            [Creator],[CreatedDate],[Modifier],[ModifiedDate],[IsActive],[IsDeleted],
            [Guid],[MobileTelephoneNumber],[HomeTelephoneNumber],[OfficeTelephoneNumber],[DateLastLogin])
     VALUES (@CompanyId,1,1,'d_admin',CONVERT(varchar(255), HashBytes('SHA1', 'password')),'Distributor','Administrator','dadministrator@indico.com','indiman_distributor.png',
			2,CAST(GETDATE() AS datetime2(7)),2,CAST(GETDATE() AS datetime2(7)),1,0,
			'92ac004b-05a5-4bce-a2a0-12a63d73a35b','+61 111 1112',NULL,'+61 111 1113',NULL)
SET @UserId = SCOPE_IDENTITY()

UPDATE	[dbo].[Company]
	SET	[Owner] = @UserId
WHERE	[ID] = @CompanyId

-- User Role --
INSERT INTO [dbo].[UserRole]
            ([User],[Role])
     VALUES (@UserId,10)

-- Indico Distributor Cordinator --
INSERT INTO [dbo].[User]
            ([Company],[IsDistributor],[Status],[Username],[Password],[GivenName],[FamilyName],[EmailAddress],[PhotoPath],
            [Creator],[CreatedDate],[Modifier],[ModifiedDate],[IsActive],[IsDeleted],
            [Guid],[MobileTelephoneNumber],[HomeTelephoneNumber],[OfficeTelephoneNumber],[DateLastLogin])
     VALUES (@CompanyId,1,1,'DCoordinator',CONVERT(varchar(255), HashBytes('SHA1', 'password')),'Distributor','Coordinator','dcoordinator@indico.com','indiman_distributor.png',
			2,CAST(GETDATE() AS datetime2(7)),2,CAST(GETDATE() AS datetime2(7)),1,0,
			'92ac004b-05a5-4bce-a2a0-12a63d73a35b','+61 111 1112',NULL,'+61 111 1113',NULL)
SET @UserId = SCOPE_IDENTITY()

-- User Role --
INSERT INTO [dbo].[UserRole]
            ([User],[Role])
     VALUES (@UserId,11) 
GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

-- Age Group --
--INSERT INTO [dbo].[AgeGroup] ([Name],[Description])
--	 VALUES	('ADULT','ADULT')
--INSERT INTO [dbo].[AgeGroup] ([Name],[Description])
--	 VALUES	('FULL RANGE','FULL RANGE')
--INSERT INTO [dbo].[AgeGroup] ([Name],[Description])
--	 VALUES	('INFANTS','INFANTS')
--INSERT INTO [dbo].[AgeGroup] ([Name],[Description])
--	 VALUES	('N/A','N/A')
--INSERT INTO [dbo].[AgeGroup] ([Name],[Description])
--	 VALUES	('YOUTH','YOUTH')
--GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

-- Category --
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('ACTIVE','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('AQUATIC','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('ATHLETICS','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('AUSSIE RULES','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('BASEBALL','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('BASKETBALL','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('BESPOKE','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('BMX','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('BOWLS','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('BUTTON-UP CREW SHIRTS','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('CRICKET','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('EQUESTRIAN','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('GRID IRON','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('HEADWEAR','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('HOCKEY','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('ICE HOCKEY','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('LA CROSSE','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('LEISURE','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('MISCELLANEOUS','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('MOTOR RACING','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('NETBALL','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('NON SUBLIMATED','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('OUTER','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('POLO SHIRTS','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('ROWING','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('RUGBY','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('SCHOOL UNIFORM','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('SHORTS','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('SINGLETS','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('SOCCER','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('TENNIS','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('TRIATHLON','.')
--INSERT INTO [dbo].[Category] ([Name],[Description])
--	 VALUES	('T-SHIRTS','.')
--GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

-- Client Type --
INSERT INTO [dbo].[ClientType] ([Name] , [Description] )
	 VALUES	('Ordinary','Ordinary Client.')
INSERT INTO [dbo].[ClientType]([Name], [Description] )
	 VALUES	('Platinum','Platinum Client.')
GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

-- Client --
--DECLARE @Distributor int
--SET @Distributor = (SELECT [ID] FROM [dbo].[Company] WHERE [IsDistributor] = 1)

--INSERT INTO [dbo].[Client] ([Distributor],[Type] ,[Name],[Title] ,[FirstName] ,[LastName],[Address1],[Address2] ,[City],[State],[PostalCode],[Country],[Phone1],[Phone2],[Mobile],[Fax] ,[Email] ,[Web],[NickName] ,[EmailSent] ,[Creator] ,[CreatedDate],[Modifier],[ModifiedDate])
--	 VALUES	(@Distributor,1,'Client 1','Mr.','Client','One','Kottawa','Rukmalgama','Colombo','asdfs','10230','Srilanka','01123657','0112365478','077456985','0112456987','hondaputha@gmail.com','www.google.com','hondaputha','true',1,'2012/01/27',1,'2012/01/27')
--INSERT INTO [dbo].[Client] ([Distributor],[Type] ,[Name],[Title] ,[FirstName] ,[LastName],[Address1],[Address2] ,[City],[State],[PostalCode],[Country],[Phone1],[Phone2],[Mobile],[Fax] ,[Email] ,[Web],[NickName] ,[EmailSent] ,[Creator] ,[CreatedDate],[Modifier],[ModifiedDate])
--	 VALUES	(@Distributor,1,'Client 2','Mr.','Client','Two','Kottawa','Rukmalgama','Colombo','asdfs','10230','Srilanka','01123657','0112365478','077456985','0112456987','hondaputha@gmail.com','www.google.com','hondaputha','true',1,'2012/01/27',1,'2012/01/27')
--INSERT INTO [dbo].[Client] ([Distributor],[Type] ,[Name],[Title] ,[FirstName] ,[LastName],[Address1],[Address2] ,[City],[State],[PostalCode],[Country],[Phone1],[Phone2],[Mobile],[Fax] ,[Email] ,[Web],[NickName] ,[EmailSent] ,[Creator] ,[CreatedDate],[Modifier],[ModifiedDate])
--	 VALUES	(@Distributor,1,'Client 3','Mr.','Client','Three','Kottawa','Rukmalgama','Colombo','asdfs','10230','Srilanka','01123657','0112365478','077456985','0112456987','hondaputha@gmail.com','www.google.com','hondaputha','true',1,'2012/01/27',1,'2012/01/27')
--GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

-- ColourProfile --
--INSERT INTO [dbo].[ColourProfile] ([Name],[Description])
--	 VALUES	('CMYK','CMYK')
--INSERT INTO [dbo].[ColourProfile] ([Name],[Description])
--	 VALUES	('CMYK OB','CMYK OB')
--INSERT INTO [dbo].[ColourProfile] ([Name],[Description])
--	 VALUES	('FLUORO ORANGE','FLUORO ORANGE')
--INSERT INTO [dbo].[ColourProfile] ([Name],[Description])
--	 VALUES	('FLUORO YELLOW','FLUORO YELLOW')
--GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

-- Delivery Method --
INSERT INTO [dbo].[DeliveryMethod] ([Name] , [Description] )
	 VALUES	('Deliver to address mentioned above.<em class="ihelper">(Chargers Apply)</em>','.')
INSERT INTO [dbo].[DeliveryMethod] ([Name] , [Description] )
	 VALUES	('Pick up from Indico adelaide office','.')
INSERT INTO [dbo].[DeliveryMethod] ([Name] , [Description] )
	 VALUES	('Deliver to alternate address.<em class="ihelper">(Chargers Apply)<em>','.')
GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

-- Destination Port --
--INSERT INTO [dbo].[DestinationPort] ([Name],[Description])
--	 VALUES	('ADELAIDE','ADELAIDE')
--INSERT INTO [dbo].[Printer] ([Name],[Description])
--	 VALUES	('ALICE SPRINGS','ALICE SPRINGS')
--INSERT INTO [dbo].[DestinationPort] ([Name],[Description])
--	 VALUES	('AUCKLAND','AUCKLAND')
--INSERT INTO [dbo].[DestinationPort] ([Name],[Description])
--	 VALUES	('BAYSWATER','BAYSWATER')
--INSERT INTO [dbo].[DestinationPort] ([Name],[Description])
--	 VALUES	('BRISBANE','BRISBANE')
--INSERT INTO [dbo].[Printer] ([Name],[Description])
--	 VALUES	('CAIRNS','CAIRNS')
--INSERT INTO [dbo].[DestinationPort] ([Name],[Description])
--	 VALUES	('CLEVELAND','CLEVELAND')
--GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

-- Distributor Label --
--INSERT INTO [dbo].[Label]([Name],[LabelImagePath],[IsSample])
--     VALUES ('Label', 'Description','True')
GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/
--DECLARE @Material int
--SET @Material = 1

---- Fabric Code --
--INSERT INTO [dbo].[FabricCode] ([Code], [Name], [Material], [GSM], [Supplier], [Country], [DenierCount], [Filaments], [NickName], [SerialOrder], [LandedCost], [LandedCurrency] )
--	 VALUES	('F001','COTTON BACK',@Material,'GSM','SUP',14,'DEN','FILA','COTTON BACK',123,0,1)
--INSERT INTO [dbo].[FabricCode] ([Code], [Name], [Material], [GSM], [Supplier], [Country], [DenierCount], [Filaments], [NickName], [SerialOrder], [LandedCost], [LandedCurrency] )
--	 VALUES	('F004','INTERLOCK 170 GSM',@Material,'GSM','SUP',14,'DEN','FILA','INTERLOCK 170 GSM',123,0,1)
--INSERT INTO [dbo].[FabricCode] ([Code], [Name], [Material], [GSM], [Supplier], [Country], [DenierCount], [Filaments], [NickName], [SerialOrder], [LandedCost], [LandedCurrency] )
--	 VALUES	('F004A','INTERLOCK 170 + TRI MESH',@Material,'GSM','SUP',14,'DEN','FILA','INTERLOCK 170 + TRI MESH',123,0,1)
--INSERT INTO [dbo].[FabricCode] ([Code], [Name], [Material], [GSM], [Supplier], [Country], [DenierCount], [Filaments], [NickName], [SerialOrder], [LandedCost], [LandedCurrency] )
--	 VALUES	('F016','POLYESTER MICROMESH (100D/144F)',@Material,'GSM','SUP',14,'DEN','FILA','MICROMESH',123,0,1)
--INSERT INTO [dbo].[FabricCode] ([Code], [Name], [Material], [GSM], [Supplier], [Country], [DenierCount], [Filaments], [NickName], [SerialOrder], [LandedCost], [LandedCurrency] )
--	 VALUES	('F018','COTTON TWILL',@Material,'GSM','SUP',14,'DEN','FILA','COTTON TWILL',123,0,1)
--INSERT INTO [dbo].[FabricCode] ([Code], [Name], [Material], [GSM], [Supplier], [Country], [DenierCount], [Filaments], [NickName], [SerialOrder], [LandedCost], [LandedCurrency] )
--	 VALUES	('F021','TASLON',@Material,'GSM','SUP',14,'DEN','FILA','TASLON',123,0,1)
--INSERT INTO [dbo].[FabricCode] ([Code], [Name], [Material], [GSM], [Supplier], [Country], [DenierCount], [Filaments], [NickName], [SerialOrder], [LandedCost], [LandedCurrency] )
--	 VALUES	('F031','BLACK NYLON SPANDEX',@Material,'GSM','SUP',14,'DEN','FILA','BLACK NYLON SPANDEX',123,0,1)
-- GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

-- Gender --
--INSERT INTO [dbo].[Gender] ([Name])
--	 VALUES	('LADIES')
--INSERT INTO [dbo].[Gender] ([Name])
--	 VALUES	('MENS')
--INSERT INTO [dbo].[Gender] ([Name])
--	 VALUES	('N/A')
--INSERT INTO [dbo].[Gender] ([Name])
--	 VALUES	('UNISEX')
--GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

-- Order Type --
--INSERT INTO [dbo].[OrderType]([Name], [Description] )
--	 VALUES	('Free Sample','FREE SAMPLE')
--INSERT INTO [dbo].[OrderType]([Name], [Description] )
--	 VALUES	('Order','ORDER')
--INSERT INTO [dbo].[OrderType]([Name], [Description] )
--	 VALUES	('Replacement','REPLACEMENT')
--INSERT INTO [dbo].[OrderType]([Name], [Description] )
--	 VALUES	('Sample','SAMPLE')
--GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

-- Order Status --
INSERT INTO [dbo].[OrderStatus] ([Name],[Description])
	 VALUES	('Not Submitted','Order has not submitted')
INSERT INTO [dbo].[OrderStatus] ([Name],[Description])
	 VALUES	('Submitted','Order has been submitted')
INSERT INTO [dbo].[OrderStatus] ([Name],[Description])
	 VALUES	('Approved','Order has been approved')
INSERT INTO [dbo].[OrderStatus] ([Name],[Description])
	 VALUES	('Scheduled','Order has been scheduled')
INSERT INTO [dbo].[OrderStatus] ([Name],[Description])
	 VALUES	('Completed','Order has been completed')
INSERT INTO [dbo].[OrderStatus] ([Name],[Description])
	 VALUES	('In Production','Order is in production')
INSERT INTO [dbo].[OrderStatus] ([Name],[Description])
	 VALUES	('Shipped','Order has been shipped')
INSERT INTO [dbo].[OrderStatus] ([Name],[Description])
	 VALUES	('In Transit','Order is in transit')
INSERT INTO [dbo].[OrderStatus] ([Name],[Description])
	 VALUES	('Out for Delivery','OrderoOut for Delivery')
INSERT INTO [dbo].[OrderStatus] ([Name],[Description])
	 VALUES	('Cancelled','Order has been cancelled')
INSERT INTO [dbo].[OrderStatus] ([Name],[Description])
	 VALUES	('On Hold','Order is on hold')
INSERT INTO [dbo].[OrderStatus] ([Name],[Description])
	 VALUES	('Ods Printed','Order is Ods Printed')
GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

-- Payment Method --
--INSERT INTO [dbo].[PaymentMethod] ([Name],[Description])
--	 VALUES	('CIF','CIF')
--INSERT INTO [dbo].[PaymentMethod] ([Name],[Description])
--	 VALUES	('DDP','DDP')
--INSERT INTO [dbo].[PaymentMethod] ([Name],[Description])
--	 VALUES	('FOB','FOB')	
--GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

--DECLARE @PriceLevel int

---- PRICE LEVEL & DISTRIBUTOR PRICE MARKUP -
--INSERT INTO [dbo].[PriceLevel]([Name],[Volume])
--     VALUES ('Level 1','001 - 005')
--SET @PriceLevel = SCOPE_IDENTITY()

--INSERT INTO [dbo].[DistributorPriceMarkup]([Distributor],[PriceLevel],[Markup])
--     VALUES (NULL, @PriceLevel, 50.00)
     
--INSERT INTO [dbo].[PriceLevel]([Name],[Volume])
--     VALUES ('Level 2','006 - 009')
--SET @PriceLevel = SCOPE_IDENTITY()

--INSERT INTO [dbo].[DistributorPriceMarkup]([Distributor],[PriceLevel],[Markup])
--     VALUES (NULL, @PriceLevel, 44.00)
     
--INSERT INTO [dbo].[PriceLevel]([Name],[Volume])
--     VALUES ('Level 3','010 - 019')
--SET @PriceLevel = SCOPE_IDENTITY()

--INSERT INTO [dbo].[DistributorPriceMarkup]([Distributor],[PriceLevel],[Markup])
--     VALUES (NULL, @PriceLevel, 35.00)
     
--INSERT INTO [dbo].[PriceLevel]([Name],[Volume])
--     VALUES ('Level 4','020 - 049')
--SET @PriceLevel = SCOPE_IDENTITY()

--INSERT INTO [dbo].[DistributorPriceMarkup]([Distributor],[PriceLevel],[Markup])
--     VALUES (NULL, @PriceLevel, 29.00)
     
--INSERT INTO [dbo].[PriceLevel]([Name],[Volume])
--     VALUES ('Level 5','050 - 099')
--SET @PriceLevel = SCOPE_IDENTITY()

--INSERT INTO [dbo].[DistributorPriceMarkup]([Distributor],[PriceLevel],[Markup])
--     VALUES (NULL, @PriceLevel, 26.00)
     
--INSERT INTO [dbo].[PriceLevel]([Name],[Volume])
--     VALUES ('Level 6','100 - 249')
--SET @PriceLevel = SCOPE_IDENTITY()

--INSERT INTO [dbo].[DistributorPriceMarkup]([Distributor],[PriceLevel],[Markup])
--     VALUES (NULL, @PriceLevel, 23.00)
     
--INSERT INTO [dbo].[PriceLevel]([Name],[Volume])
--     VALUES ('Level 7','250 - 499')
--SET @PriceLevel = SCOPE_IDENTITY()

--INSERT INTO [dbo].[DistributorPriceMarkup]([Distributor],[PriceLevel],[Markup])
--     VALUES (NULL, @PriceLevel, 20.00)
     
--INSERT INTO [dbo].[PriceLevel]([Name],[Volume])
--     VALUES ('Level 8','500 +')     
--SET @PriceLevel = SCOPE_IDENTITY()

--INSERT INTO [dbo].[DistributorPriceMarkup]([Distributor],[PriceLevel],[Markup])
--     VALUES (NULL, @PriceLevel, 16.00)
--GO
--/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/
	
---- Printer -
--INSERT INTO [dbo].[Printer] ([Name],[Description])
--	 VALUES	('Printer 01','Printer 01')
--INSERT INTO [dbo].[Printer] ([Name],[Description])
--	 VALUES	('Printer 02','Printer 02')
--INSERT INTO [dbo].[Printer] ([Name],[Description])
--	 VALUES	('Printer 03','Printer 03')
--INSERT INTO [dbo].[Printer] ([Name],[Description])
--	 VALUES	('Printer 04','Printer 04')
--INSERT INTO [dbo].[Printer] ([Name],[Description])
--	 VALUES	('Printer 05','Printer 05')
--INSERT INTO [dbo].[Printer] ([Name],[Description])
--	 VALUES	('Printer 06','Printer 06')
--GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

-- Printer Type --
--INSERT INTO [dbo].[PrinterType]  ([Name],[Description])
--	 VALUES	('DYED','DYED.')
--INSERT INTO [dbo].[PrinterType]  ([Name],[Description])
--	 VALUES	('N/A','.N/A')
--INSERT INTO [dbo].[PrinterType]  ([Name],[Description])
--	 VALUES	('SUBLIMATED','SUBLIMATED.')
--GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

-- Reservation Status --
INSERT INTO [dbo].[ReservationStatus] ([Name],[Description])
	 VALUES	('Submitted','Order has been submitted')
INSERT INTO [dbo].[ReservationStatus] ([Name],[Description])
	 VALUES	('Approved','Order has been approved')
INSERT INTO [dbo].[ReservationStatus] ([Name],[Description])
	 VALUES	('Cancelled','Order has been submitted')
INSERT INTO [dbo].[ReservationStatus] ([Name],[Description])
	 VALUES	('On Hold','Order is on hold')
INSERT INTO [dbo].[ReservationStatus] ([Name],[Description])
	 VALUES	('Completed','Order has been submitted')
GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

-- Resolution Profile --
--INSERT INTO [dbo].[ResolutionProfile] ([Name],[Description])
--	 VALUES	('High Res','High Res')
--INSERT INTO [dbo].[ResolutionProfile] ([Name],[Description])
--	 VALUES	('Low Res','Low Res')
--GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

-- Shipment Mode --
--INSERT INTO [dbo].[ShipmentMode] ([Name],[Description])
--	 VALUES	('AIR','AIR')
--INSERT INTO [dbo].[ShipmentMode] ([Name],[Description])
--	 VALUES	('DHL','DHL')
--INSERT INTO [dbo].[ShipmentMode] ([Name],[Description])
--	 VALUES	('FEDEX','FEDEX')
--INSERT INTO [dbo].[ShipmentMode] ([Name],[Description])
--	 VALUES	('TNT','TNT')
--GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/
--DECLARE @SizeSet int

---- Size Set --
--INSERT INTO [dbo].[SizeSet] ([Name],[Description])
--	 VALUES	('00000 - 2','00000 - 2 ')
--SET @SizeSet = SCOPE_IDENTITY()

---- Size --
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, 'SMALL NEW BORN / 00000', 1)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, 'NEW BORN / 0000', 2)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, 'MONTH 0 TO 3 / 000', 3)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, 'MONTH 3 TO 6 / 00', 4)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, 'MONTH 6 TO 12 / 0', 5)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, 'MONTH 12 TO 18 / 1', 6)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, 'MONTH 18 TO 24 / 2', 7)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, 'OTHER', 8)
	 
--INSERT INTO [dbo].[SizeSet] ([Name],[Description])
--	 VALUES	('0-22 MONTHS','0-22 MONTHS.')
	 
--INSERT INTO [dbo].[SizeSet] ([Name],[Description])
--	 VALUES	('1 SIZE FITS ALL','1 SIZE FITS ALL.')
--SET @SizeSet = SCOPE_IDENTITY()

---- Size --	 
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, 'ALL', 1)
	 	 
--INSERT INTO [dbo].[SizeSet] ([Name],[Description])
--	 VALUES	('26-40','1 26-40.')
--SET @SizeSet = SCOPE_IDENTITY()

---- Size --
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, '26', 1)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, '27', 2)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, '28', 3)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, '29', 4)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, '30', 5)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, '32', 6)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, '34', 7)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, '36', 8)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, '38', 9)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, '40', 10)

--INSERT INTO [dbo].[SizeSet] ([Name],[Description])
--	 VALUES	('2XS-3XL','2XS-3XL')
--SET @SizeSet = SCOPE_IDENTITY()

---- Size --
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, '2XS', 1)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, 'XS', 2)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, 'S', 3)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, 'M', 4)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, 'L', 5)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, 'XL', 6)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, '2XL', 7)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, '3XL', 8)

--INSERT INTO [dbo].[SizeSet] ([Name],[Description])
--	 VALUES	('4 - 30','4 - 30.')
--INSERT INTO [dbo].[SizeSet] ([Name],[Description])
--	 VALUES	('4Y-14Y','4Y-14Y.')
--INSERT INTO [dbo].[SizeSet] ([Name],[Description])
--	 VALUES	('4Y-16Y **','4Y-16Y **.')
--INSERT INTO [dbo].[SizeSet] ([Name],[Description])
--	 VALUES	('77-132','77-132.')
--INSERT INTO [dbo].[SizeSet] ([Name],[Description])
--	 VALUES	('8-24 **','8-24 **.')
--INSERT INTO [dbo].[SizeSet] ([Name],[Description])
--	 VALUES	('8-26','8-26.')
--INSERT INTO [dbo].[SizeSet] ([Name],[Description])
--	 VALUES	('BESPOKE','BESPOKE.')
--INSERT INTO [dbo].[SizeSet] ([Name],[Description])
--	 VALUES	('N/A','N/A.')
--INSERT INTO [dbo].[SizeSet] ([Name],[Description])
--	 VALUES	('OTHER','OTHER.')
	 
--INSERT INTO [dbo].[SizeSet] ([Name],[Description])
--	 VALUES	('XS-5XL **','XS-5XL **.')
--SET @SizeSet = SCOPE_IDENTITY()

---- Size --
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, 'M', 2)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, 'L', 3)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, 'XL', 4)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, '2XL', 5)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, '3XL', 6)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, '4XL', 7)
--INSERT INTO [dbo].[Size] ([SizeSet], [SizeName], [SeqNo] )
--	 VALUES	(@SizeSet, '5XL', 8)
--GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

-- Item, Sub Item and Measurement Location --
--DECLARE @ParentItem int

---- Item --
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('A-LINE DRESS','A-LINE DRESS')
--SET @ParentItem = SCOPE_IDENTITY()

---- Sub Item --
--INSERT INTO [dbo].[Item]([Name],[Description], [Parent])
--     VALUES ('GRID GIRL DRESS','GRID GIRL DRESS', @ParentItem)
--INSERT INTO [dbo].[Item]([Name],[Description], [Parent])
--     VALUES ('GRID GIRL DRESS','GRID GIRL DRESS', @ParentItem)

---- Measurement Location --
--INSERT INTO [dbo].[MeasurementLocation] ([Item], [Key] ,[Name])
--	 VALUES	(@ParentItem, 'A','SHOULDER')
--INSERT INTO [dbo].[MeasurementLocation] ([Item], [Key] ,[Name])
--	 VALUES	(@ParentItem, 'B','CHEST WIDTH')
--INSERT INTO [dbo].[MeasurementLocation] ([Item], [Key] ,[Name])
--	 VALUES	(@ParentItem, 'C','HIP WIDTH')
--INSERT INTO [dbo].[MeasurementLocation] ([Item], [Key] ,[Name])
--	 VALUES	(@ParentItem, 'D','HEM WIDTH')
--INSERT INTO [dbo].[MeasurementLocation] ([Item], [Key] ,[Name])
--	 VALUES	(@ParentItem, 'E','ARM OPENING')
--INSERT INTO [dbo].[MeasurementLocation] ([Item], [Key] ,[Name])
--	 VALUES	(@ParentItem, 'F','CENTRE BACK')
--INSERT INTO [dbo].[MeasurementLocation] ([Item], [Key] ,[Name])
--	 VALUES	(@ParentItem, 'G','NECK OPENING (CIRC)')
--INSERT INTO [dbo].[MeasurementLocation] ([Item], [Key] ,[Name])
--	 VALUES	(@ParentItem, 'H','NECK DROP')
------------------------------------------------------------------------------------------------------------------------

---- Item --	 
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('ATHLETICS BODYSUIT','ATHLETICS BODYSUIT')
--SET @ParentItem = SCOPE_IDENTITY()

---- Sub Item --    
--INSERT INTO [dbo].[Item]([Name],[Description], [Parent])
--     VALUES ('ATHLETICS BODYSUIT','ATHLETICS BODYSUIT', @ParentItem)
--INSERT INTO [dbo].[Item]([Name],[Description], [Parent])
--     VALUES ('ATHLETICS BODYSUIT( FULL LENGTH)','ATHLETICS BODYSUIT( FULL LENGTH)', @ParentItem)
 
---- Measurement Location --
--INSERT INTO [dbo].[MeasurementLocation] ([Item], [Key] ,[Name])
--	 VALUES	(@ParentItem, 'A','SHOULDER')
--INSERT INTO [dbo].[MeasurementLocation] ([Item], [Key] ,[Name])
--	 VALUES	(@ParentItem, 'B','HALF CHEST')
--INSERT INTO [dbo].[MeasurementLocation] ([Item], [Key] ,[Name])
--	 VALUES	(@ParentItem, 'C','CENTRE BACK')
--INSERT INTO [dbo].[MeasurementLocation] ([Item], [Key] ,[Name])
--	 VALUES	(@ParentItem, 'D','SIDE SEAM')
--INSERT INTO [dbo].[MeasurementLocation] ([Item], [Key] ,[Name])
--	 VALUES	(@ParentItem, 'E','ARM OPENING')
--INSERT INTO [dbo].[MeasurementLocation] ([Item], [Key] ,[Name])
--	 VALUES	(@ParentItem, 'F','LEG OPENING')    
------------------------------------------------------------------------------------------------------------------------

---- Item --	         
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('BAG','BAG')
--SET @ParentItem = SCOPE_IDENTITY()

---- Sub Item --      
--INSERT INTO [dbo].[Item]([Name],[Description], [Parent])
--     VALUES ('SAMPLES KIT BAG','SAMPLES KIT BAG', @ParentItem)
--INSERT INTO [dbo].[Item]([Name],[Description], [Parent])
--     VALUES ('SPORTS BAG','SPORTS BAG', @ParentItem)
------------------------------------------------------------------------------------------------------------------------

---- Item --	          
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('BIBS','BIBS')
--SET @ParentItem = SCOPE_IDENTITY()

---- Sub Item --   
--INSERT INTO [dbo].[Item]([Name],[Description], [Parent])
--     VALUES ('SPORTS PACK','SPORTS PACK', @ParentItem)
------------------------------------------------------------------------------------------------------------------------

---- Item --	      
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('BRIEFS','BRIEFS')     
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('CAP','CAP')     
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('CORSET','CORSET')
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('CROP TOP','CROP TOP')
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('CURTAIN','CURTAIN')
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('CYCLING BIB','CYCLING BIB')
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('CYCLING SUIT','CYCLING SUIT')
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('GRID GIRL BODYSUIT','GRID GIRL BODYSUIT')
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('HOODIE','HOODIE')
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('HORSE BLANKET','HORSE BLANKET')
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('JACKET','JACKET')
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('MISCELLANEOUS','MISCELLANEOUS')
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('NETBALL BODYSUIT','NETBALL BODYSUIT')
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('OVERALLS','OVERALLS')
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('PANT','PANT')
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('RACE SUIT','RACE SUIT')
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('ROWING SUIT','ROWING SUIT')
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('SHIRT BUTTON UP','SHIRT BUTTON UP')
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('SHIRT CLOSED NECK','SHIRT CLOSED NECK')
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('SHIRT PLACKET NECK','SHIRT PLACKET NECK')
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('SHIRT RAGLAN','SHIRT RAGLAN')
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('SHIRT ZIP FRONT','SHIRT ZIP FRONT')
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('SHORTS','SHORTS')
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('SKIRT','SKIRT')
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('SKIRT WITH BRIEFS','SKIRT WITH BRIEFS')
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('SLEEVELESS TOP','SLEEVELESS TOP')
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('TRIATHLON BODYSUIT','TRIATHLON BODYSUIT')
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('VISOR','VISOR')
--INSERT INTO [dbo].[Item]([Name],[Description])
--     VALUES ('WINDCHEATER','WINDCHEATER')
--GO
--/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/
--DECLARE @Item int
--DECLARE @ParentAttribute int

---- Item Attribute --
--SET @Item = 1
--INSERT INTO [dbo].[ItemAttribute] ([Parent], [Item], [Name] ,[Description])
--	 VALUES	(NULL,@Item,'NECKLINE','NECKLINE.')
--SET @ParentAttribute = SCOPE_IDENTITY()
	
--INSERT INTO [dbo].[ItemAttribute] ([Parent], [Item], [Name] ,[Description])
--	 VALUES	(@ParentAttribute,@Item,'ROUND NECK','ROUND NECK.')
--INSERT INTO [dbo].[ItemAttribute] ([Parent], [Item], [Name] ,[Description])
--	 VALUES	(@ParentAttribute,@Item,'V NECK','V NECK.')
--INSERT INTO [dbo].[ItemAttribute] ([Parent], [Item], [Name] ,[Description])
--	 VALUES	(@ParentAttribute,@Item,'V NECK WITH COLLAR','V NECK WITH COLLAR.')

--SET @Item = 17	
--INSERT INTO [dbo].[ItemAttribute] ([Parent], [Item], [Name] ,[Description])
--	 VALUES	(NULL,@Item,'NECKLINE','NECKLINE.')
--SET @ParentAttribute = SCOPE_IDENTITY()

--INSERT INTO [dbo].[ItemAttribute] ([Parent], [Item], [Name] ,[Description])
--	 VALUES	(@ParentAttribute,@Item,'ROUND NECK','ROUND NECK.')
--INSERT INTO [dbo].[ItemAttribute] ([Parent], [Item], [Name] ,[Description])
--	 VALUES	(@ParentAttribute,@Item,'V NECK','V NECK.')

--SET @Item = 22	
--INSERT INTO [dbo].[ItemAttribute] ([Parent], [Item], [Name] ,[Description])
--	 VALUES	(NULL,@Item,'SLEEVE LENGTH','SLEEVE LENGTH.')
--SET @ParentAttribute = SCOPE_IDENTITY()

--INSERT INTO [dbo].[ItemAttribute] ([Parent], [Item], [Name] ,[Description])
--	 VALUES	(@ParentAttribute,@Item,'LONG SLEEVE','LONG SLEEVE.')
--INSERT INTO [dbo].[ItemAttribute] ([Parent], [Item], [Name] ,[Description])
--	 VALUES	(@ParentAttribute,@Item,'SHORT SLEEVE','SHORT SLEEVE.')	
	 	 
--INSERT INTO [dbo].[ItemAttribute] ([Parent], [Item], [Name] ,[Description])
--	 VALUES	(NULL,@Item,'SLEEVE TYPE','SLEEVE TYPE.')
--SET @ParentAttribute = SCOPE_IDENTITY()	 

--INSERT INTO [dbo].[ItemAttribute] ([Parent], [Item], [Name] ,[Description])
--	 VALUES	(@ParentAttribute,@Item,'RAGLAN','RAGLAN.')
--INSERT INTO [dbo].[ItemAttribute] ([Parent], [Item], [Name] ,[Description])
--	 VALUES	(@ParentAttribute,@Item,'SET IN','SET IN.')

--SET @Item = 23
--INSERT INTO [dbo].[ItemAttribute] ([Parent], [Item], [Name] ,[Description])
--	 VALUES	(NULL,@Item,'NECKLINE','NECKLINE.')
--INSERT INTO [dbo].[ItemAttribute] ([Parent], [Item], [Name] ,[Description])
--	 VALUES	(NULL,@Item,'SIDE SEAM','SIDE SEAM.')
--INSERT INTO [dbo].[ItemAttribute] ([Parent], [Item], [Name] ,[Description])
--	 VALUES	(NULL,@Item,'SLEEVE LENGTH','SLEEVE LENGTH.')
--INSERT INTO [dbo].[ItemAttribute] ([Parent], [Item], [Name] ,[Description])
--	 VALUES	(NULL,@Item,'SLEEVE TYPE','SLEEVE TYPE.')
	 
--SET @Item = 24
--INSERT INTO [dbo].[ItemAttribute] ([Parent], [Item], [Name] ,[Description])
--	 VALUES	(NULL,@Item,'SLEEVE LENGTH','SLEEVE LENGTH.')
--INSERT INTO [dbo].[ItemAttribute] ([Parent], [Item], [Name] ,[Description])
--	 VALUES	(NULL,@Item,'SLEEVE TYPE','SLEEVE TYPE.')

--SET @Item = 26	 
--INSERT INTO [dbo].[ItemAttribute] ([Parent], [Item], [Name] ,[Description])
--	 VALUES	(NULL,@Item,'SLEEVE LENGTH','SLEEVE LENGTH.')

--SET @Item = 27	 
--INSERT INTO [dbo].[ItemAttribute] ([Parent], [Item], [Name] ,[Description])
--	 VALUES	(NULL,@Item,'SIDE SEAM','SIDE SEAM.')

--SET @Item = 30
--INSERT INTO [dbo].[ItemAttribute] ([Parent], [Item], [Name] ,[Description])
--	 VALUES	(NULL,@Item,'ARM HOLE','ARM HOLE.')
--INSERT INTO [dbo].[ItemAttribute] ([Parent], [Item], [Name] ,[Description])
--	 VALUES	(NULL,@Item,'NECKLINE','NECKLINE.')
--GO

------------------------------------------------------------------------------------------------------------------------
--Accessory
INSERT INTO [dbo].[Accessory] ([Name] ,[Code] )
	 VALUES	('Button','B')
INSERT INTO [dbo].[Accessory] ([Name] ,[Code] )
	 VALUES	('Zip','Z')

-----------------------------------------------------------------------------------------------------------------------
--AccessoryCategory
INSERT INTO [dbo].[AccessoryCategory] ([Name] ,[Code],[Accessory] )
	 VALUES	('Two Hall','2H',1)
INSERT INTO [dbo].[AccessoryCategory] ([Name] ,[Code],[Accessory] )
	 VALUES	('Three Hall','3H',1)
INSERT INTO [dbo].[AccessoryCategory] ([Name] ,[Code],[Accessory] )
	 VALUES	('Four Hall','4H',1)

INSERT INTO [dbo].[AccessoryCategory] ([Name] ,[Code],[Accessory] )
	 VALUES	('Single Length','SL',2)
INSERT INTO [dbo].[AccessoryCategory] ([Name] ,[Code],[Accessory] )
	 VALUES	('Double Length','DL',2)
------------------------------------------------------------------------------------------------------------------------
--AccessoryColor
INSERT INTO [dbo].[AccessoryColor] ([Name] ,[Code],[ColorValue] )
	 VALUES	('Red','R','#AAAAAA')
INSERT INTO [dbo].[AccessoryColor] ([Name] ,[Code],[ColorValue] )
	 VALUES	('Blue','B','#BBBBBB')
INSERT INTO [dbo].[AccessoryColor] ([Name] ,[Code],[ColorValue] )
	 VALUES	('Green','G','#AACCCC')

----------------------------------------------------------------------------------------------------------------------
----PatternAccessory
--INSERT INTO [dbo].[PatternAccessory] ([Pattern] ,[Accessory] ,[AccessoryCategory] )
--	 VALUES	(1,1,1)
--INSERT INTO [dbo].[PatternAccessory] ([Pattern] ,[Accessory] ,[AccessoryCategory] )
--	 VALUES	(2,2,2)

/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

-- PATTERN --
--INSERT INTO [dbo].[Pattern] ([Number], [IsActive], [OriginRef], [Item], [SubItem], [Gender], [AgeGroup], [SizeSet], [NickName], [CoreCategory], [PrinterType], [Keywords], [CorePattern], [FactoryDescription], [Consumption], [Notes], [CreatedDate], [ModifiedDate], [Creator], [Modifier], [SpecialAttributes], [ItemAttribute])
--	 VALUES	('001','false','123',24,10,4,1,15,'POLO SHIRT UNISEX ADULT SHORT SLEEVE SET IN',24,1,'keyword','corPattern','desc','cons','notes','2012/01/27','2012/01/27',1,1,' SHORT SLEEVE SET IN',1)
--INSERT INTO [dbo].[Pattern] ([Number], [IsActive], [OriginRef], [Item], [SubItem], [Gender], [AgeGroup], [SizeSet], [NickName], [CoreCategory], [PrinterType], [Keywords], [CorePattern], [FactoryDescription], [Consumption], [Notes], [CreatedDate], [ModifiedDate], [Creator], [Modifier], [SpecialAttributes], [ItemAttribute])
--	 VALUES	('002','false','456',23,11,1,1,4,'POLO SHIRT LADIES ADULT SHORT SLEEVE SET IN V-NECK AND COLLAR',33,1,'keyword','corPattern','desc','cons','notes','2012/01/27','2012/01/27',1,1,' V-NECK AND COLLAR',1)
--INSERT INTO [dbo].[Pattern] ([Number], [IsActive], [OriginRef], [Item], [SubItem], [Gender], [AgeGroup], [SizeSet], [NickName], [CoreCategory], [PrinterType], [Keywords], [CorePattern], [FactoryDescription], [Consumption], [Notes], [CreatedDate], [ModifiedDate], [Creator], [Modifier], [SpecialAttributes], [ItemAttribute])
--	 VALUES	('003','false','123',23,12,2,5,3,'RUGBY JERSEY MENS YOUTH LONG SLEEVE SET IN SQUARE SHOULDER',26,1,'keyword','corPattern','desc','cons','notes','2012/01/27','2012/01/27',1,1,'SQUARE SHOULDER',1)
--INSERT INTO [dbo].[Pattern] ([Number], [IsActive], [OriginRef], [Item], [SubItem], [Gender], [AgeGroup], [SizeSet], [NickName], [CoreCategory], [PrinterType], [Keywords], [CorePattern], [FactoryDescription], [Consumption], [Notes], [CreatedDate], [ModifiedDate], [Creator], [Modifier], [SpecialAttributes], [ItemAttribute])
--	 VALUES	('004','false','123',23,12,2,1,15,'RUGBY JERSEY MENS ADULT LONG SLEEVE SET IN SQUARE SHOULDER',26,1,'keyword','corPattern','desc','cons','notes','2012/01/27','2012/01/27',1,1,'SQUARE SHOULDER',1)
--INSERT INTO [dbo].[Pattern] ([Number], [IsActive], [OriginRef], [Item], [SubItem], [Gender], [AgeGroup], [SizeSet], [NickName], [CoreCategory], [PrinterType], [Keywords], [CorePattern], [FactoryDescription], [Consumption], [Notes], [CreatedDate], [ModifiedDate], [Creator], [Modifier], [SpecialAttributes], [ItemAttribute])
--	 VALUES	('005','false','123',24,10,4,1,15,'POLO SHIRT UNISEX ADULT SLEEVELESS',24,1,'keyword','corPattern','desc','cons','notes','2012/01/27','2012/01/27',1,1,'spc',1)
--GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

-- SizeChart --

--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,1 ,1 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,1 ,2 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,1 ,3 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,1 ,4 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,1 ,5 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,1 ,6 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,1 ,7 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,1 ,8 ,0 )

--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,2 ,1 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,2 ,2 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,2 ,3 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,2 ,4 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,2 ,5 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,2 ,6 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,2 ,7 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,2 ,8 ,0 )
	
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,3 ,1 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,3 ,2 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,3 ,3 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,3 ,4 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,3 ,5 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,3 ,6 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,3 ,7 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,3 ,8 ,0 )
	
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,4 ,1 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,4 ,2 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,4 ,3 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,4 ,4 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,4 ,5 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,4 ,6 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,4 ,7 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,4 ,8 ,0 )
	
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,5 ,1 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,5 ,2 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,5 ,3 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,5 ,4 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,5 ,5 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,5 ,6 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,5 ,7 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,5 ,8 ,0 )
	
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,6 ,1 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,6 ,2 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,6 ,3 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,6 ,4 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,6 ,5 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,6 ,6 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,6 ,7 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,6 ,8 ,0 )
	
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,7 ,1 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,7 ,2 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,7 ,3 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,7 ,4 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,7 ,5 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,7 ,6 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,7 ,7 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,7 ,8 ,0 )
	
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,8 ,1 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,8 ,2 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,8 ,3 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,8 ,4 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,8 ,5 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,8 ,6 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,8 ,7 ,0 )
--INSERT INTO dbo.[SizeChart] ([Pattern] , [MeasurementLocation], [Size], [Val])
--	VALUES(1 ,8 ,8 ,0 )
--GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

-- VL --
--INSERT INTO [dbo].[VisualLayout] ([Name] , [Description] , [Pattern] , [FabricCode] , [Client] , [Coordinator], [Distributor] , [NNPFilePath] )
--	 VALUES	('VL001','.',1,1,1,1,1,'test Path')
--INSERT INTO [dbo].[VisualLayout] ([Name] , [Description] , [Pattern] , [FabricCode] , [Client] , [Coordinator] , [Distributor] ,[NNPFilePath] )
--	 VALUES	('VL002','.',1,2,2,1,1,'test Path')
--INSERT INTO [dbo].[VisualLayout] ([Name] , [Description] , [Pattern] , [FabricCode] , [Client] , [Coordinator] ,[Distributor] , [NNPFilePath] )
--	 VALUES	('VL003','.',2,1,3,1,1,'test Path')
--INSERT INTO [dbo].[VisualLayout] ([Name] , [Description] , [Pattern] , [FabricCode] , [Client] , [Coordinator] ,[Distributor] , [NNPFilePath] )
--	 VALUES	('VL004','.',2,2,1,1,1,'test Path')
--INSERT INTO [dbo].[VisualLayout] ([Name] , [Description] , [Pattern] , [FabricCode] , [Client] , [Coordinator] , [Distributor] ,[NNPFilePath] )
--	 VALUES	('VL005','.',1,1,2,1,1,'test Path')
--INSERT INTO [dbo].[VisualLayout] ([Name] , [Description] , [Pattern] , [FabricCode] , [Client] , [Coordinator] ,[Distributor] , [NNPFilePath] )
--	 VALUES	('VL006','.',2,3,3,1,1,'test Path')
--INSERT INTO [dbo].[VisualLayout] ([Name] , [Description] , [Pattern] , [FabricCode] , [Client] , [Coordinator] , [Distributor] ,[NNPFilePath] )
--	 VALUES	('VL007','.',1,4,2,1,1,'test Path')
--INSERT INTO [dbo].[VisualLayout] ([Name] , [Description] , [Pattern] , [FabricCode] , [Client] , [Coordinator] ,[Distributor] , [NNPFilePath] )
--	 VALUES	('VL008','.',2,5,1,1,1,'test Path')
--INSERT INTO [dbo].[VisualLayout] ([Name] , [Description] , [Pattern] , [FabricCode] , [Client] , [Coordinator] , [Distributor] ,[NNPFilePath] )
--	 VALUES	('VL009','.',1,6,3,1,1,'test Path')
--INSERT INTO [dbo].[VisualLayout] ([Name] , [Description] , [Pattern] , [FabricCode] , [Client] , [Coordinator] , [Distributor] ,[NNPFilePath] )
--	 VALUES	('VL010','.',5,4,3,1,1,'test Path')
--INSERT INTO [dbo].[VisualLayout] ([Name] , [Description] , [Pattern] , [FabricCode] , [Client] , [Coordinator] ,[Distributor] , [NNPFilePath] )
--	 VALUES	('VL011','.',5,7,2,1,1,'test Path')
--GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

-- Product --
--INSERT INTO [Indico].[dbo].[Product]([ProductNumber],[Pattern] ,[ResolutionProfile] ,[ColourProfile] ,[Client] ,[Notes] ,[DateCreated] ,[FabricCodes] ,[DistributorLabel] ,[Label] ,[Printer]) 
--    VALUES ('VL01001',1,1,1,1,'.' ,'2012-02-16' ,'.',1,'.',1)
--INSERT INTO [Indico].[dbo].[Product]([ProductNumber],[Pattern] ,[ResolutionProfile] ,[ColourProfile] ,[Client] ,[Notes] ,[DateCreated] ,[FabricCodes] ,[DistributorLabel] ,[Label] ,[Printer]) 
--    VALUES ('VL01002',2,1,1,2,'.' ,'2012-02-16' ,'.',1,'.',1)
--INSERT INTO [Indico].[dbo].[Product]([ProductNumber],[Pattern] ,[ResolutionProfile] ,[ColourProfile] ,[Client] ,[Notes] ,[DateCreated] ,[FabricCodes] ,[DistributorLabel] ,[Label] ,[Printer]) 
--    VALUES ('VL01003',3,1,1,2,'.' ,'2012-02-16' ,'.',1,'.',1)
--INSERT INTO [Indico].[dbo].[Product]([ProductNumber],[Pattern] ,[ResolutionProfile] ,[ColourProfile] ,[Client] ,[Notes] ,[DateCreated] ,[FabricCodes] ,[DistributorLabel] ,[Label] ,[Printer]) 
--    VALUES ('VL01004',2,1,1,1,'.' ,'2012-02-16' ,'.',1,'.',1)
--INSERT INTO [Indico].[dbo].[Product]([ProductNumber],[Pattern] ,[ResolutionProfile] ,[ColourProfile] ,[Client] ,[Notes] ,[DateCreated] ,[FabricCodes] ,[DistributorLabel] ,[Label] ,[Printer]) 
--    VALUES ('VL01005',1,1,1,1,'.' ,'2012-02-16' ,'.',1,'.',1)
--INSERT INTO [Indico].[dbo].[Product]([ProductNumber],[Pattern] ,[ResolutionProfile] ,[ColourProfile] ,[Client] ,[Notes] ,[DateCreated] ,[FabricCodes] ,[DistributorLabel] ,[Label] ,[Printer]) 
--    VALUES ('VL01006',3,1,1,1,'.' ,'2012-02-16' ,'.',1,'.',1)
--INSERT INTO [Indico].[dbo].[Product]([ProductNumber],[Pattern] ,[ResolutionProfile] ,[ColourProfile] ,[Client] ,[Notes] ,[DateCreated] ,[FabricCodes] ,[DistributorLabel] ,[Label] ,[Printer]) 
--    VALUES ('VL01007',1,1,1,1,'.' ,'2012-02-16' ,'.',1,'.',1)
--INSERT INTO [Indico].[dbo].[Product]([ProductNumber],[Pattern] ,[ResolutionProfile] ,[ColourProfile] ,[Client] ,[Notes] ,[DateCreated] ,[FabricCodes] ,[DistributorLabel] ,[Label] ,[Printer]) 
--    VALUES ('VL01008',1,1,1,1,'.' ,'2012-02-16' ,'.',1,'.',1)
--GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

-- Sub Item --

--INSERT INTO [dbo].[Item]([Name],[Description], [Parent])
--     VALUES ('CYCLING JACKET','CYCLING JACKET', 15)
--INSERT INTO [dbo].[Item]([Name],[Description], [Parent])
--     VALUES ('RAIN JACKET','RAIN JACKET', 15)
--INSERT INTO [dbo].[Item]([Name],[Description], [Parent])
--     VALUES ('POLO SHIRT','POLO SHIRT', 23)
--INSERT INTO [dbo].[Item]([Name],[Description], [Parent])
--     VALUES ('T-SHIRT','T-SHIRT', 23)
--INSERT INTO [dbo].[Item]([Name],[Description], [Parent])
--     VALUES ('RUGBY JERSEY','RUGBY JERSEY', 23)
--INSERT INTO [dbo].[Item]([Name],[Description], [Parent])
--     VALUES ('POLO SHIRT','POLO SHIRT', 24)
--INSERT INTO [dbo].[Item]([Name],[Description], [Parent])
--     VALUES ('BUTTON UP SHIRTS','BUTTON UP SHIRTS', 24)
--GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/