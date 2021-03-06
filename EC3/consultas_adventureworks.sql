-- DIM 

-- DIM PRODUCT
-- DIM CUSTOMER
-- DIM DATE
-- DIM PROMOTION


-- DIM CURRENCY
CREATE TABLE DIM_Currency(
	[CurrencyKey] [int] IDENTITY(1,1) NOT NULL,
	[CurrencyAlternateKey] [nchar](3) NOT NULL,
	[CurrencyName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_DimCurrency_CurrencyKey] PRIMARY KEY CLUSTERED 
(
	[CurrencyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

-- HECHOS
CREATE TABLE [HEC_InternetSales](
	[ProductKey] [int] NOT NULL,
	[OrderDateKey] [int] NOT NULL,
	[DueDateKey] [int] NOT NULL,
	[ShipDateKey] [int] NOT NULL,
	[CustomerKey] [int] NOT NULL,
	[PromotionKey] [int] NOT NULL,
	[CurrencyKey] [int] NOT NULL,
	[SalesTerritoryKey] [int] NOT NULL,
	[SalesOrderNumber] [nvarchar](20) NOT NULL,
	[OrderQuantity] [smallint] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[UnitPriceDiscountPct] [float] NOT NULL,
	[TotalProductCost] [money] NOT NULL,
	[OrderDate] [datetime] NULL,
	[DueDate] [datetime] NULL,
	[ShipDate] [datetime] NULL,
 CONSTRAINT [PK_FactInternetSales_SalesOrderNumber_SalesOrderLineNumber] PRIMARY KEY CLUSTERED 
(
	[SalesOrderNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[FactInternetSales]  WITH CHECK ADD  CONSTRAINT [FK_FactInternetSales_DimCurrency] FOREIGN KEY([CurrencyKey])
REFERENCES [dbo].[DimCurrency] ([CurrencyKey])
GO

ALTER TABLE [dbo].[FactInternetSales] CHECK CONSTRAINT [FK_FactInternetSales_DimCurrency]
GO

ALTER TABLE [dbo].[FactInternetSales]  WITH CHECK ADD  CONSTRAINT [FK_FactInternetSales_DimCustomer] FOREIGN KEY([CustomerKey])
REFERENCES [dbo].[DimCustomer] ([CustomerKey])
GO

ALTER TABLE [dbo].[FactInternetSales] CHECK CONSTRAINT [FK_FactInternetSales_DimCustomer]
GO

ALTER TABLE [dbo].[FactInternetSales]  WITH CHECK ADD  CONSTRAINT [FK_FactInternetSales_DimDate] FOREIGN KEY([OrderDateKey])
REFERENCES [dbo].[DimDate] ([DateKey])
GO

ALTER TABLE [dbo].[FactInternetSales] CHECK CONSTRAINT [FK_FactInternetSales_DimDate]
GO

ALTER TABLE [dbo].[FactInternetSales]  WITH CHECK ADD  CONSTRAINT [FK_FactInternetSales_DimDate1] FOREIGN KEY([DueDateKey])
REFERENCES [dbo].[DimDate] ([DateKey])
GO

ALTER TABLE [dbo].[FactInternetSales] CHECK CONSTRAINT [FK_FactInternetSales_DimDate1]
GO

ALTER TABLE [dbo].[FactInternetSales]  WITH CHECK ADD  CONSTRAINT [FK_FactInternetSales_DimDate2] FOREIGN KEY([ShipDateKey])
REFERENCES [dbo].[DimDate] ([DateKey])
GO

ALTER TABLE [dbo].[FactInternetSales] CHECK CONSTRAINT [FK_FactInternetSales_DimDate2]
GO

ALTER TABLE [dbo].[FactInternetSales]  WITH CHECK ADD  CONSTRAINT [FK_FactInternetSales_DimProduct] FOREIGN KEY([ProductKey])
REFERENCES [dbo].[DimProduct] ([ProductKey])
GO

ALTER TABLE [dbo].[FactInternetSales] CHECK CONSTRAINT [FK_FactInternetSales_DimProduct]
GO

ALTER TABLE [dbo].[FactInternetSales]  WITH CHECK ADD  CONSTRAINT [FK_FactInternetSales_DimPromotion] FOREIGN KEY([PromotionKey])
REFERENCES [dbo].[DimPromotion] ([PromotionKey])
GO

ALTER TABLE [dbo].[FactInternetSales] CHECK CONSTRAINT [FK_FactInternetSales_DimPromotion]
GO

ALTER TABLE [dbo].[FactInternetSales]  WITH CHECK ADD  CONSTRAINT [FK_FactInternetSales_DimSalesTerritory] FOREIGN KEY([SalesTerritoryKey])
REFERENCES [dbo].[DimSalesTerritory] ([SalesTerritoryKey])
GO

ALTER TABLE [dbo].[FactInternetSales] CHECK CONSTRAINT [FK_FactInternetSales_DimSalesTerritory]
GO


-- -------------------------
-- FactInternetSales
-- -------------------------

SELECT
PROD_D.ProductKey,
DATE_ORD_D.DateKey AS OrderDateKey,
DATE_DUE_D.DateKey AS DueDateKey,
DATE_SHP_D.DateKey AS ShipDateKey,
CUST_D.CustomerKey,
PROM_D.PromotionKey,
CURR_D.CurrencyKey,
TERR_D.SalesTerritoryKey,
ORD_O.SalesOrderNumber,
DET_O.OrderQty AS OrderQuantity,
DET_O.UnitPrice,
PROM_D.DiscountPct AS UnitPriceDiscountPct,
((DET_O.UnitPrice * DET_O.OrderQty) - ((DET_O.UnitPrice * DET_O.OrderQty) * PROM_D.DiscountPct)) AS TotalProductCost,
CONVERT(DATETIME,DATE_ORD_D.FullDateAlternateKey) AS OrderDate,
CONVERT(DATETIME,DATE_DUE_D.FullDateAlternateKey) AS DueDate,
CONVERT(DATETIME,DATE_SHP_D.FullDateAlternateKey) AS ShipDate
FROM AdventureWorks2014.Production.Product PROD_O
INNER JOIN AdventureWorks2014.Production.ProductSubCategory SUBCAT_O ON (PROD_O.ProductSubcategoryID = SUBCAT_O.ProductSubcategoryID)
INNER JOIN AdventureWorks2014.Production.ProductCategory CAT_O ON (SUBCAT_O.ProductCategoryID = CAT_O.ProductCategoryID)
INNER JOIN AdventureWorks2014.Sales.SalesOrderDetail DET_O ON (PROD_O.ProductID=DET_O.ProductID)
INNER JOIN AdventureWorks2014.Sales.SalesOrderHeader ORD_O ON (ORD_O.SalesOrderID=DET_O.SalesOrderID)
INNER JOIN AdventureWorks2014.Sales.Customer CUST_O ON (ORD_O.CustomerID = CUST_O.CustomerID)
INNER JOIN AdventureWorks2014.Person.Person PERS_O ON (PERS_O.BusinessEntityID = CUST_O.PersonID)
INNER JOIN AdventureWorks2014.Sales.SpecialOffer OFFE_O ON (OFFE_O.SpecialOfferID = DET_O.SpecialOfferID)
INNER JOIN AdventureWorks2014.Sales.CurrencyRate CURR_O ON (CURR_O.CurrencyRateID = ORD_O.CurrencyRateID)
INNER JOIN AdventureWorks2014.Sales.SalesTerritory TERR_O ON (ORD_O.TerritoryID = TERR_O.TerritoryID)

INNER JOIN AdventureWorksDW2014.dbo.DimProduct PROD_D ON PROD_D.EnglishProductName = PROD_O.Name
INNER JOIN AdventureWorksDW2014.dbo.DimDate DATE_ORD_D ON (DATE_ORD_D.FullDateAlternateKey = CONVERT(DATE,ORD_O.OrderDate))
INNER JOIN AdventureWorksDW2014.dbo.DimDate DATE_DUE_D ON (DATE_DUE_D.FullDateAlternateKey = CONVERT(DATE,ORD_O.DueDate))
INNER JOIN AdventureWorksDW2014.dbo.DimDate DATE_SHP_D ON (DATE_SHP_D.FullDateAlternateKey = CONVERT(DATE,ORD_O.ShipDate))
INNER JOIN AdventureWorksDW2014.dbo.DimCustomer CUST_D ON (CONCAT(PERS_O.FirstName, PERS_O.LastName) = CONCAT(CUST_D.FirstName,CUST_D.LastName))
INNER JOIN AdventureWorksDW2014.dbo.DimPromotion PROM_D ON PROM_D.EnglishPromotionName = OFFE_O.Description
INNER JOIN AdventureWorksDW2014.dbo.DimCurrency CURR_D ON CURR_D.CurrencyAlternateKey = CURR_O.ToCurrencyCode
INNER JOIN AdventureWorksDW2014.dbo.DimSalesTerritory TERR_D ON TERR_O.Name = TERR_D.SalesTerritoryRegion
go

select * from FactInternetSales

select top 10 * from AdventureWorks2014.Sales.SalesOrderHeader
select top 10 * from AdventureWorks2014.Sales.SalesOrderDetail


--Query para Venta
SELECT PRODD.idProducto AS ProductoId,
CLID.idCliente AS ClienteId,
EMPD.idEmpleado AS EmpleadoId,
TID.idFecha AS TiempoId,
TER.idTerritorio AS TerritorioId,
DETN.UnitPrice AS Precio,
DETN.OrderQty AS Cantidad
FROM AdventureWorks2014.Production.Product PRODN
INNER JOIN AdventureWorks2014.Production.ProductSubCategory SUBCATN ON (PRODN.ProductSubcategoryID = SUBCATN.ProductSubcategoryID)
INNER JOIN AdventureWorks2014.Production.ProductCategory CATN ON (SUBCATN.ProductCategoryID = CATN.ProductCategoryID)
INNER JOIN AdventureWorks2014.Sales.SalesOrderDetail DETN ON (PRODN.ProductID=DETN.ProductID)
INNER JOIN AdventureWorks2014.Sales.SalesOrderHeader ORDN ON (ORDN.SalesOrderID=DETN.SalesOrderID)
INNER JOIN AdventureWorks2014.Sales.SalesTerritory SALTER ON (ORDN.TerritoryID=SALTER.TerritoryID)
INNER JOIN AdventureWorks2014.Sales.Customer CUSN ON (ORDN.CustomerID = CUSN.CustomerID)
INNER JOIN AdventureWorks2014.Person.Person PERR ON (CUSN.PersonID = PERR.BusinessEntityID)
INNER JOIN AdventureWorks2014.Sales.SalesPerson SALPER ON (SALPER.BusinessEntityID = ORDN.SalesPersonID)
INNER JOIN AdventureWorks2014.Person.Person PER ON (PER.BusinessEntityID = SALPER.BusinessEntityID)
INNER JOIN AW_DM.dbo.Dim_Producto PRODD ON (PRODD.Nombre = PRODN.Name collate Modern_Spanish_CI_AS)
INNER JOIN AW_DM.dbo.Dim_Cliente CLID ON (CLID.Nombre = PERR.FirstName collate Modern_Spanish_CI_AS)
INNER JOIN AW_DM.dbo.Dim_Empleado EMPD ON (EMPD.Nombre = PER.FirstName collate Modern_Spanish_CI_AS)
INNER JOIN AW_DM.dbo.Dim_Fecha TID ON (TID.Fecha=CONVERT(DATE,ORDN.OrderDate))
INNER JOIN AW_DM.dbo.Dim_Territorio TER ON (TER.Nombre = SALTER.Name collate Modern_Spanish_CI_AS);
 go





-- -------------------------
-- DimPromotion
-- -------------------------
/*SELECT 
	oferta.Description AS EnglishPromotionName
	,CONVERT(DOUBLE PRECISION, oferta.DiscountPct) AS DiscountPct
	,oferta.Type AS EnglishPromotionType
	,oferta.Category AS EnglishPromotionCategory
	,oferta.StartDate
	,oferta.EndDate
	,oferta.MinQty
	,oferta.MaxQty
FROM Sales.SpecialOffer oferta
GO*/

SELECT distinct p.EnglishPromotionName FROM AdventureWorksDW2014.dbo.DimPromotion p
GO
-- Special Offfert

-- -------------------------
-- DimDate
-- -------------------------
/*
WITH fechas AS (
    SELECT fecha = CONVERT(DATETIME,'01/01/2005')
    UNION ALL 
        SELECT fecha = DATEADD(DAY, 1, fecha) 
        FROM fechas
        WHERE fecha < '10/10/2005' --'12/31/2014'
) SELECT 
    CONCAT(YEAR(fecha),FORMAT(fecha,'MM'), FORMAT(fecha,'dd')) AS DateKey
    ,CONVERT(DATE, fecha) as FullDateAlternateKey
    ,DATEPART(WEEKDAY,fecha) AS DayNumberOfWeek
    ,FORMAT(fecha, 'dddd') AS EnglishDayNameOfWeek
    ,UPPER(LEFT(FORMAT(fecha, 'dddd', 'es'),1))+LOWER(SUBSTRING(FORMAT(fecha, 'dddd', 'es'),2,LEN(FORMAT(fecha, 'dddd', 'es')))) AS SpanishDayNameOfWeek
    ,UPPER(LEFT(FORMAT(fecha, 'dddd', 'fr'),1))+LOWER(SUBSTRING(FORMAT(fecha, 'dddd', 'fr'),2,LEN(FORMAT(fecha, 'dddd', 'fr')))) AS FrenchDayNameOfWeek
    ,DAY(fecha) AS DayNumberOfMonth
    ,DATEPART(DAYOFYEAR, fecha) AS DayNumberOfYear
    ,DATEPART(WEEK, fecha) AS WeekNumberOfYear
    ,FORMAT(fecha, 'MMMM') AS EnglishMonthName
    ,UPPER(LEFT(FORMAT(fecha, 'MMMM', 'es'),1))+LOWER(SUBSTRING(FORMAT(fecha, 'MMMM', 'es'),2,LEN(FORMAT(fecha, 'MMMM', 'es')))) AS SpanishMonthName
    ,UPPER(LEFT(FORMAT(fecha, 'MMMM', 'fr'),1))+LOWER(SUBSTRING(FORMAT(fecha, 'MMMM', 'fr'),2,LEN(FORMAT(fecha, 'MMMM', 'fr')))) AS FrenchMonthName
    ,MONTH(fecha) AS MonthNumberOfYear
    ,DATEPART(QUARTER,fecha) AS CalendarQuarter
    ,YEAR(fecha) AS CalendarYear
    ,"CalendarSemester" = 
        CASE 
            WHEN DATEPART(QUARTER,fecha) >= 3 
            THEN 2 
            ELSE 1 
        END
    ,"FiscalQuarter" =
        CASE
            WHEN MONTH(fecha) BETWEEN 1  AND 3  THEN 3
            WHEN MONTH(fecha) BETWEEN 4  AND 6  THEN 4
            WHEN MONTH(fecha) BETWEEN 7  AND 9  THEN 1
            WHEN MONTH(fecha) BETWEEN 10 AND 12 THEN 2
        END
    ,"FiscalYear" =
        CASE
            WHEN MONTH(fecha) BETWEEN 1  AND  6 THEN convert(char(4), YEAR(fecha))
            ELSE convert(char(4), YEAR(fecha) + 1)
        END
    ,"FiscalSemester" =
        CASE 
            WHEN DATEPART(QUARTER,fecha) >= 3 
            THEN 1
            ELSE 2
        END
FROM fechas
OPTION (MAXRECURSION 3652)
GO
*/

-- -------------------------
-- DimProduct
-- -------------------------
SELECT producto.ProductNumber AS ProductAlternateKey
	,producto.ProductSubcategoryID AS ProductSubcategoryKey
	,producto.WeightUnitMeASureCode
	,producto.SizeUnitMeASureCode
	,producto.Name AS EnglishProductName
	-- [SpanishProductName]
	-- [FrenchProductName]
	,"StandardCost" = 
		CASE
			WHEN producto.StandardCost = 0.0
			THEN NULL
			ELSE producto.StandardCost
		END
	,producto.FinishedGoodsFlag
	,"Color" = 
		CASE 
			WHEN producto.Color IS NULL 
			THEN 'NA' 
			ELSE producto.Color 
		END
	,producto.SafetyStockLevel
	,producto.ReorderPoint
	,"ListPrice" = 
		CASE 
			WHEN producto.ListPrice = 0.0 
			THEN NULL 
			ELSE producto.ListPrice 
		END
	,producto.Size
	,"SizeRange" = 
		CASE
			WHEN TRY_CONVERT(int, producto.Size) IS NOT NULL
			THEN CASE
					WHEN producto.Size <= 40
					THEN '38-40 CM'
					WHEN producto.Size <= 46
					THEN '42-46 CM'
					WHEN producto.Size <= 52
					THEN '48-52 CM'
					WHEN producto.Size <= 58
					THEN '54-58 CM'
					WHEN producto.Size <= 62
					THEN '60-62 CM'
					WHEN producto.Size = 70
					THEN '70'
				END
			ELSE 'NA'
		END
	, CONVERT(DOUBLE PRECISION, producto.Weight) as Weight
	,producto.DaysToManufacture
	,producto.ProductLine
	,"DealerPrice" = 
		CASE 
			WHEN (producto.ListPrice * 60) / 100 = 0.0 
			THEN NULL 
			ELSE (producto.ListPrice * 60) / 100 
		END
	,producto.Class
	,producto.Style
	,modelo.Name AS ModelName
	,foto.LargePhoto
	,desc_en.Description AS EnglishDescription
	,desc_fr.Description AS FrenchDescription
	,desc_ch.Description AS ChineseDescription
	,desc_ar.Description AS ArabicDescription
	,desc_he.Description AS HebrewDescription
	,desc_th.Description AS ThaiDescription
	--,[GermanDescription]
	--,[JapaneseDescription]
	--,[TurkishDescription]
	,producto.SellStartDate AS StartDate
	,producto.SellEndDate AS EndDate
	-- Status
FROM Production.Product producto
	LEFT JOIN Production.ProductModel modelo ON modelo.ProductModelID = producto.ProductModelID
	INNER JOIN Production.ProductProductPhoto producto_foto ON producto_foto.ProductID = producto.ProductID
	INNER JOIN Production.ProductPhoto foto ON foto.ProductPhotoID = producto_foto.ProductPhotoID
	-- EnglishDescription / en
	LEFT JOIN Production.ProductModelProductDescriptionCulture dm_en ON dm_en.ProductModelID = modelo.ProductModelID AND dm_en.CultureID = 'en'
	LEFT JOIN Production.ProductDescription desc_en ON desc_en.ProductDescriptionID = dm_en.ProductDescriptionID
	-- FrenchDescription / fr
	LEFT JOIN Production.ProductModelProductDescriptionCulture dm_fr ON dm_fr.ProductModelID = modelo.ProductModelID AND dm_fr.CultureID = 'fr'
	LEFT JOIN Production.ProductDescription desc_fr ON desc_fr.ProductDescriptionID = dm_fr.ProductDescriptionID
	-- ChineseDescription / zh-cht (ch)
	LEFT JOIN Production.ProductModelProductDescriptionCulture dm_ch ON dm_ch.ProductModelID = modelo.ProductModelID AND dm_ch.CultureID = 'zh-cht'
	LEFT JOIN Production.ProductDescription desc_ch ON desc_ch.ProductDescriptionID = dm_ch.ProductDescriptionID
	-- ArabicDescription / ar
	LEFT JOIN Production.ProductModelProductDescriptionCulture dm_ar ON dm_ar.ProductModelID = modelo.ProductModelID AND dm_ar.CultureID = 'ar'
	LEFT JOIN Production.ProductDescription desc_ar ON desc_ar.ProductDescriptionID = dm_ar.ProductDescriptionID
	-- HebrewDescription / he
	LEFT JOIN Production.ProductModelProductDescriptionCulture dm_he ON dm_he.ProductModelID = modelo.ProductModelID AND dm_he.CultureID = 'he'
	LEFT JOIN Production.ProductDescription desc_he ON desc_he.ProductDescriptionID = dm_he.ProductDescriptionID
	-- ThaiDescription / th
	LEFT JOIN Production.ProductModelProductDescriptionCulture dm_th ON dm_th.ProductModelID = modelo.ProductModelID AND dm_th.CultureID = 'th'
	LEFT JOIN Production.ProductDescription desc_th ON desc_th.ProductDescriptionID = dm_th.ProductDescriptionID
	-- GermanDescription
	-- JapaneseDescription
	-- TurkishDescription
ORDER BY producto.ProductNumber DESC
;

/*
select p.ProductID
  ,p.ProductNumber
  ,p.ProductModelID
  ,desc_model.CultureID
  ,desc_model.ProductModelID
  ,desc_model.ProductDescriptionID
  ,descripcion.Description
  ,desc_model1.CultureID
  ,desc_model1.ProductModelID
  ,desc_model1.ProductDescriptionID
  ,descripcion1.Description
from Production.Product p
  inner JOIN Production.ProductModel m on m.ProductModelID = p.ProductModelID
  -- he, zh-cht, en, ar, th, fr
  left JOIN Production.ProductModelProductDescriptionCulture desc_model ON desc_model.ProductModelID = m.ProductModelID and desc_model.CultureID = 'en'
  left JOIN Production.ProductDescription descripcion ON descripcion.ProductDescriptionID = desc_model.ProductDescriptionID

  left JOIN Production.ProductModelProductDescriptionCulture desc_model1
    ON desc_model1.ProductModelID = m.ProductModelID and desc_model1.CultureID = 'fr'
  left JOIN Production.ProductDescription descripcion1 ON descripcion1.ProductDescriptionID = desc_model1.ProductDescriptionID
order by p.ProductID ASC
;*/

/*
select * from Production.Product
--where ProductNumber like 'FR-R92R-62'
;
select top 100 * from Production.ProductCategory;
select top 100 * from Production.ProductSubcategory;
select * from Production.ProductProductPhoto;
select * from Production.ProductPhoto;

select * from Production.ProductModel;
select * from Production.ProductDescription;
select distinct CultureID from Production.ProductModelProductDescriptionCulture

select distinct CultureID from Production.vProductAndDescription where CultureID = 'en'order by ProductID; -- he, zh-cht, en, ar, th, fr
select * from Production.UnitMeASure;
*/