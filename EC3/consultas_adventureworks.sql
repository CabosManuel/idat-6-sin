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
	,"Color" = CASE WHEN producto.Color IS NULL THEN 'NA' ELSE producto.Color END
	,producto.SafetyStockLevel
	,producto.ReorderPoint
	,"ListPrice" = CASE WHEN producto.ListPrice = 0.0 THEN NULL ELSE producto.ListPrice END
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
	,"DealerPrice" = CASE WHEN (producto.ListPrice * 60) / 100 = 0.0 THEN NULL ELSE (producto.ListPrice * 60) / 100 END
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