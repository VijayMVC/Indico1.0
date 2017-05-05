-------------------------------------------------------- ALTER


ALTER TABLE [dbo].[Reservation]
DROP CONSTRAINT FK_Reservation_ShipTo
GO

ALTER TABLE [dbo].[Reservation]
DROP CONSTRAINT FK_Reservation_ShipmentMode
GO

ALTER TABLE [dbo].[Reservation]
DROP COLUMN ShipTo
GO

ALTER TABLE [dbo].[Reservation]
DROP COLUMN ShipmentMode
GO

ALTER TABLE [dbo].[Reservation]
DROP COLUMN ReservationNo
GO

ALTER TABLE [dbo].[Reservation]
ADD QtyPolo INT NULL
GO

ALTER TABLE [dbo].[Reservation]
ADD QtyOutwear INT NULL
GO



-----------------------------------------------------------TABLE AND VIEWS

IF OBJECT_ID('dbo.OrderReservationMapping', 'U') IS NOT NULL 
  DROP TABLE  dbo.[OrderReservationMapping]
GO



CREATE TABLE [dbo].[OrderReservationMapping](
 [Id] [int] IDENTITY(1,1) NOT NULL,
 [Order] [int] NOT NULL,
 [Reservation] [int] NOT NULL,
 [Qty] [int] NOT NULL,
 CONSTRAINT [PK_OrderReservationMapping] PRIMARY KEY CLUSTERED 
(
 [Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[OrderReservationMapping]  WITH CHECK ADD  CONSTRAINT [FK_OrderReservationMapping_Order] FOREIGN KEY([Order])
REFERENCES [dbo].[Order] ([ID])
GO

ALTER TABLE [dbo].[OrderReservationMapping] CHECK CONSTRAINT [FK_OrderReservationMapping_Order]
GO

ALTER TABLE [dbo].[OrderReservationMapping]  WITH CHECK ADD  CONSTRAINT [FK_OrderReservationMapping_Reservation] FOREIGN KEY([Reservation])
REFERENCES [dbo].[Reservation] ([ID])
GO

ALTER TABLE [dbo].[OrderReservationMapping] CHECK CONSTRAINT [FK_OrderReservationMapping_Reservation]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Active Status ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderReservationMapping', @level2type=N'COLUMN',@level2name=N'Id'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Active Status ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderReservationMapping', @level2type=N'COLUMN',@level2name=N'Order'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Active Status ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderReservationMapping', @level2type=N'COLUMN',@level2name=N'Reservation'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Active Status ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderReservationMapping', @level2type=N'COLUMN',@level2name=N'Qty'
GO

----------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[NewReservationTotalUsedView]'))
	DROP VIEW [dbo].[NewReservationTotalUsedView]
GO


CREATE VIEW [dbo].[NewReservationTotalUsedView]
AS
       SELECT Reservation,
           SUM(Qty) AS Total
    FROM [dbo].[OrderReservationMapping]
    GROUP BY Reservation

GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[NewFinalReservationBalanceView]'))
	DROP VIEW [dbo].[NewFinalReservationBalanceView]
GO

CREATE VIEW [dbo].[NewFinalReservationBalanceView]
AS
      SELECT   re.ID,
         re.OrderDate AS ReservationDate,
         p.NickName AS "Pattern",
         u.Username AS "Coordinator",
         c.Name AS "Distributor",
         re.Client,
         re.ShipmentDate,
      re.QtyPolo,
      re.QtyOutwear,
      rst.Name AS [Status],
         re.Qty,
      re.Notes,
      ISNULL(rs.Total,0) AS Total,
         ISNULL((re.Qty-rs.Total),re.Qty) AS Balance
    FROM Reservation re
          LEFT OUTER JOIN [NewReservationTotalUsedView] rs
                     ON rs.Reservation=re.ID
          INNER JOIN [dbo].[Pattern] p
                     ON p.ID=re.Pattern
       INNER JOIN [dbo].[User] u
                  ON u.ID=re.Coordinator
       INNER JOIN [dbo].[Company] c
                 ON c.ID=re.Distributor
    INNER JOIN [dbo].[ReservationStatus] rst
              ON rst.ID=re.[Status]

GO


--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[OrderDetailQtyView]'))
	DROP VIEW [dbo].[OrderDetailQtyView]

/****** Object:  View [dbo].[OrderDetailQtyView]    Script Date: 06/23/2015 14:34:02 ******/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
Go

CREATE VIEW [dbo].[OrderDetailQtyView]
AS
		SELECT OrderDetail,
		       SUM(Qty) AS Total
        FROM [dbo].[OrderDetailQty]
        GROUP BY OrderDetail

Go

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[OrderDetailQty_OrderView]'))
	DROP VIEW [dbo].[OrderDetailQty_OrderView]

/****** Object:  View [dbo].[OrderDetailQty_OrderView]    Script Date: 06/23/2015 14:34:02 ******/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
Go

CREATE VIEW [dbo].[OrderDetailQty_OrderView]
 AS
		SELECT od.Reservation,
		       odqv.OrderDetail, 
		       odqv.Total
	    FROM  [dbo].[OrderDetail] od
		  LEFT OUTER JOIN [dbo].[OrderDetailQtyView] odqv
			       ON od.ID=odqv.OrderDetail

Go

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[reservation_sumView]'))
	DROP VIEW [dbo].[reservation_sumView]

/****** Object:  View [dbo].[reservation_sumView]    Script Date: 06/23/2015 14:34:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
Go

CREATE VIEW [dbo].[reservation_sumView]
AS
	    SELECT odqo.[Reservation],
		       sum(odqo.Total) as total
		FROM [dbo].[OrderDetailQty_OrderView] odqo
		group by odqo.[Reservation]

Go

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[reservation_balanceView]'))
	DROP VIEW [dbo].[reservation_balanceView]


/****** Object:  View [dbo].[reservation_balanceView]    Script Date: 06/23/2015 14:34:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
Go

CREATE VIEW [dbo].[reservation_balanceView]
AS
		SELECT re.ID,
		       re.OrderDate AS ReservationDate,
		       p.NickName AS "Pattern",
		       u.Username AS "Coordinator",
		       c.Name AS "Distributor",
		       re.Client,
		       re.ShipmentDate,
			   re.QtyPolo,
			   re.QtyOutwear,
			   rst.Name AS [Status],
		       re.Qty,
			   re.Notes,
			   ISNULL(rs.Total,0) AS Total,
		       ISNULL((re.Qty-rs.Total),re.Qty) AS Balance
	   FROM Reservation re
	         LEFT OUTER JOIN [dbo].[reservation_sumView] rs
	                    ON rs.Reservation=re.ID
	         INNER JOIN [dbo].[Pattern] p
	                    ON p.ID=re.Pattern
		     INNER JOIN [dbo].[User] u
		                ON u.ID=re.Coordinator
		     INNER JOIN [dbo].[Company] c
		               ON c.ID=re.Distributor
			 INNER JOIN [dbo].[ReservationStatus] rst
			           ON rst.ID=re.[Status]
	Go

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[reservation_balancePositiveView]'))
	DROP VIEW [dbo].[reservation_balancePositiveView]


/****** Object:  View [dbo].[reservation_balancePositiveView]    Script Date: 06/23/2015 14:34:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
Go

CREATE VIEW [dbo].[reservation_balancePositiveView]
AS
		SELECT ID,
		       ReservationDate,
			   [Pattern],
			   [Coordinator],
			   [Distributor],
               Client,
			   ShipmentDate,
			   QtyPolo,
			   QtyOutwear,
			   [Status],
			   Qty,
			   Notes,
			   Total,
			   Balance
	   FROM  [dbo].[reservation_balanceView]
	   WHERE Balance>=0
Go

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[reservation_balanceNegativeView]'))
	DROP VIEW [dbo].[reservation_balanceNegativeView]
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
Go

CREATE VIEW [dbo].[reservation_balanceNegativeView]
AS
		SELECT ID,
		       ReservationDate,
			   [Pattern],
			   [Coordinator],
			   [Distributor],
               Client,
			   ShipmentDate,
			   QtyPolo,
			   QtyOutwear,
			   [Status],
			   Qty,
			   Notes,
			   Qty AS Total,
			   '0' AS Balance
	   FROM  [dbo].[reservation_balanceView]
	   WHERE Balance<0
Go

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[FinalReservationView]'))
	DROP VIEW [dbo].[FinalReservationView]
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
Go

CREATE VIEW [dbo].[FinalReservationView]
AS
		SELECT * 
		FROM [dbo].[reservation_balancePositiveView]
		UNION ALL
		SELECT * 
		FROM [dbo].[reservation_balanceNegativeView]
Go
