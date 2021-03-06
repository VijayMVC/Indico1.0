USE [Indico]
GO

-- Production Capacity changes -----------------

ALTER TABLE [dbo].[WeeklyProductionCapacity]
ADD HoursPerDay  DECIMAL(8,2),
OrderCutOffDate DATETIME NULL, 
EstimatedDateOfDespatch DATETIME NULL, 
EstimatedDateOfArrival DATETIME NULL

/****** Object:  Table [dbo].[WeeklyProductionCapacityDetails]    Script Date: 05/13/2015 15:03:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WeeklyProductionCapacityDetails](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WeeklyProductionCapacity] INT NOT NULL,
	[ItemType] INT NOT NULL,
	[TotalCapacity] DECIMAL(8,2),
	[FivePcsCapacity] DECIMAL(8,2),
	[SampleCapacity] DECIMAL(8,2),
	[Workers] INT,
	[Efficiency] DECIMAL(8,2)
 CONSTRAINT [PK_WeeklyProductionCapacityDetails] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[WeeklyProductionCapacityDetails]  WITH CHECK ADD  CONSTRAINT [FK_WeeklyProductionCapacityDetails_WeeklyProductionCapacity] FOREIGN KEY([WeeklyProductionCapacity])
REFERENCES [dbo].[WeeklyProductionCapacity] ([ID])
GO

ALTER TABLE [dbo].[WeeklyProductionCapacityDetails] CHECK CONSTRAINT [FK_WeeklyProductionCapacityDetails_WeeklyProductionCapacity]
GO

ALTER TABLE [dbo].[WeeklyProductionCapacityDetails]  WITH CHECK ADD  CONSTRAINT [FK_WeeklyProductionCapacityDetails_ItemType] FOREIGN KEY([ItemType])
REFERENCES [dbo].[ItemType] ([ID])
GO

ALTER TABLE [dbo].[WeeklyProductionCapacityDetails] CHECK CONSTRAINT [FK_WeeklyProductionCapacityDetails_ItemType]
GO

-------------- Price Updating -----------------------------------

-- Feb 2015 Price --
UPDATE   [dbo].[PriceLevelCost]
SET [IndimanCost] =  CEILING(([IndimanCost]/0.96) / 0.25)*0.25

-- Mar 2015 Price --  
 UPDATE   [dbo].[PriceLevelCost]
SET [IndimanCost] =  CEILING(([IndimanCost]/0.95) / 0.1)*0.1

-------------- Adding new Column to Order -----------------------------------


ALTER TABLE [dbo].[Order] 
ADD IsBrandingKit BIT NOT NULL 
DEFAULT 0

GO

ALTER TABLE [dbo].[Order] 
ADD AddressType INT NULL 

GO








 

