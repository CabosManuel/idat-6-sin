-- CLIENTE ------------------------------------------------------------------------------
select distinct persona.LastName as apellido, 
	concat(persona.FirstName,' ',persona.MiddleName) as nombres, 
	correo.EmailAddress as correo, 
	telefono.PhoneNumber as telefono, 
	tipo_telefono.Name as tipo_telefono, 
	pais.Name as pais, 
	estado.Name as estado,
	concat(direccion.AddressLine1,' ',direccion.AddressLine2) as direccion, 
	direccion_tipo.Name as tipo_direccion, 
	direccion.PostalCode as codigo_postal
from Person.Person persona
	inner join Person.EmailAddress correo
	on correo.BusinessEntityID = persona.BusinessEntityID
		
	inner join Person.PersonPhone telefono 
	on telefono.BusinessEntityID = persona.BusinessEntityID
	inner join Person.PhoneNumberType tipo_telefono
	on tipo_telefono.PhoneNumberTypeID = telefono.PhoneNumberTypeID

	inner join Person.BusinessEntityAddress direccion_bus
	on direccion_bus.BusinessEntityID = persona.BusinessEntityID
	inner join Person.AddressType direccion_tipo
	on direccion_tipo.AddressTypeID = direccion_bus.AddressTypeID
	inner join Person.Address direccion
	on direccion.AddressID = direccion_bus.AddressID
	inner join Person.StateProvince estado
	on estado.StateProvinceID = direccion.StateProvinceID
	inner join Person.CountryRegion pais
	on pais.CountryRegionCode = estado.CountryRegionCode
where persona.PersonType like 'IN'
order by persona.LastName
go

-- FECHA ------------------------------------------------------------------------------
select distinct convert(date,orden_cabecera.OrderDate) as fecha,
	convert(int,datepart(year,orden_cabecera.OrderDate)) as anio,
	convert(int,datepart(quarter,orden_cabecera.OrderDate)) as trimestre,
	convert(varchar,datepart(month,orden_cabecera.OrderDate)) as mes,
	convert(int,datepart(day,orden_cabecera.OrderDate)) as dia
from Sales.SalesOrderHeader orden_cabecera
go

-- PRODUCTO ------------------------------------------------------------------------------
select producto.Name as nombre
	,producto.ProductNumber as numero_producto
	,isnull(categoria.Name,'-') as categoria
	,isnull(subcategoria.Name,'-') as subcategoria
	,isnull(modelo.Name,'-') as modelo
from Production.Product producto
	left join Production.ProductSubcategory subcategoria
	on subcategoria.ProductSubcategoryID = producto.ProductSubcategoryID
	left join Production.ProductCategory categoria
	on categoria.ProductCategoryID = subcategoria.ProductSubcategoryID
	left join Production.ProductModel modelo
	on modelo.ProductModelID = producto.ProductModelID
go

-- VENTAS ------------------------------------------------------------------------------
select cliente_dw.id_cliente as id_cliente
	,fecha_dw.id_fecha as id_fecha
	,producto_dw.id_producto as id_producto
	,o_detalle_bd.UnitPrice as precio
	,o_detalle_bd.OrderQty as cantidad
from AdventureWorks2014.Production.Product producto_bd
	inner join AdventureWorks2014.Sales.SalesOrderDetail o_detalle_bd
	on o_detalle_bd.ProductID = producto_bd.ProductID
	inner join AdventureWorks2014.Sales.SalesOrderHeader o_cabecera_bd
	on o_cabecera_bd.SalesOrderID = o_detalle_bd.SalesOrderID
	inner join AdventureWorks2014.Person.Person persona_bd
	on persona_bd.BusinessEntityID = o_cabecera_bd.CustomerID
	inner join bd_ec2_aventureworks14_dw.dbo.dim_cliente cliente_dw
	on cliente_dw.nombres COLLATE Modern_Spanish_CI_AS like concat(persona_bd.FirstName,' ',persona_bd.MiddleName) COLLATE Modern_Spanish_CI_AS
	inner join bd_ec2_aventureworks14_dw.dbo.dim_fecha fecha_dw
	on fecha_dw.fecha like convert(date,o_cabecera_bd.OrderDate)
	inner join bd_ec2_aventureworks14_dw.dbo.dim_producto producto_dw
	on producto_dw.numero_producto COLLATE Modern_Spanish_CI_AS like producto_bd.ProductNumber COLLATE Modern_Spanish_CI_AS
	order by fecha_dw.id_fecha
go



/* -- ELIMIANAR DATOS --
delete from bd_ec2_aventureworks14_dw.dbo.ventas;
delete from bd_ec2_aventureworks14_dw.dbo.dim_cliente;
delete from bd_ec2_aventureworks14_dw.dbo.dim_fecha;
delete from bd_ec2_aventureworks14_dw.dbo.dim_producto;
