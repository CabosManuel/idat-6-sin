/* https://www.sqldatadictionary.com/AdventureWorks2014/Person.Person.html
SC = contacto de la tienda
IN = cliente individual (minorista)
SP = vendedor
EM = empleado (no ventas)
VC = contacto con el proveedor
GC = contacto general
*/

/*
cliente
	apellido
	nombres
	correo
	telefono
	tipo_telefono
	pais
	estado
	direccion
	tipo_direccion
	codigo_postal
*/

-- CLIENTE
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
order by correo.EmailAddress
go


/*BORRADOR
select /*top 10*/ * from Person.BusinessEntityAddress
select top 10 * from Person.AddressType
select top 10 * from Person.Address
select top 10 * from Person.StateProvince
select top 10 * from Person.CountryRegion

select * from Person.Person pp
inner join Person.BusinessEntity pb
on pp.BusinessEntityID = pb.BusinessEntityID
	where pp.PersonType like 'IN'--pp.BusinessEntityID = 

select top 10 * from Person.BusinessEntity
select top 1000 * from Person.Person
	-- correo
	select * from Person.EmailAddress
	-- telefono	
	select * from Person.PhoneNumberType
	select * from Person.PersonPhone
	select * from Person.ContactType
	select * from Person.BusinessEntityContact order by ContactTypeID
*/

-- VENDEDOR ------------------------------------------------------------------------------
/*
https://www.sqldatadictionary.com/AdventureWorks2014/HumanResources.Employee.html
https://www.sqldatadictionary.com/AdventureWorks2014/HumanResources.EmployeeDepartmentHistory.html

https://www.sqldatadictionary.com/AdventureWorks2014/Sales.SalesOrderHeader.html#Sales.uSalesOrderHeader
https://www.sqldatadictionary.com/AdventureWorks2014/Sales.SalesOrderDetail.html
*/

/* 
vendedor
	dni

	apellido
	nombres
	correo
	telefono
	tipo_telefono
	
	genero
	fecha_nacimiento
	edad

	departamento
	titulo_trabajo
	fecha_contratacion
	ordenes_enviadas
	salario_aprox
*/

select distinct vendedor.BusinessEntityID,
vendedor.NationalIDNumber as dni,
	persona.LastName as apellido,
	concat(persona.FirstName,' ',persona.MiddleName) as nombres,
	correo.EmailAddress as correo, 
	telefono.PhoneNumber as telefono,
	tipo_telefono.Name as tipo_telefono,
	vendedor.Gender as genero,
	vendedor.BirthDate as fecha_nacimiento,
	year(getdate()) - year(vendedor.BirthDate) as edad,
	departamento.Name as departamento,
	vendedor.JobTitle as titulo_trabajo,
	vendedor.HireDate as fecha_contratacion,
	count(orden_cabecera.SalesPersonID) as ordenes_enviadas,
	round(pago.Rate*48,2) as salario_aprox
from Person.Person persona
	inner join HumanResources.Employee vendedor
	on vendedor.BusinessEntityID = persona.BusinessEntityID

	inner join Person.EmailAddress correo
	on correo.BusinessEntityID = persona.BusinessEntityID
		
	inner join Person.PersonPhone telefono 
	on telefono.BusinessEntityID = persona.BusinessEntityID
	inner join Person.PhoneNumberType tipo_telefono
	on tipo_telefono.PhoneNumberTypeID = telefono.PhoneNumberTypeID

	inner join Sales.SalesOrderHeader orden_cabecera
	on orden_cabecera.SalesPersonID = vendedor.BusinessEntityID

	inner join HumanResources.EmployeeDepartmentHistory departamento_historial
	on departamento_historial.BusinessEntityID = vendedor.BusinessEntityID
	inner join HumanResources.Department departamento
	on departamento.DepartmentID = departamento_historial.DepartmentID

	inner join HumanResources.EmployeePayHistory pago
	on pago.BusinessEntityID = vendedor.BusinessEntityID
where vendedor.JobTitle like '%Sales%'
	and vendedor.JobTitle not like '%President%'
	and orden_cabecera.Status = 5
group by vendedor.BusinessEntityID, pago.Rate, departamento.Name, vendedor.NationalIDNumber,persona.LastName,persona.FirstName,persona.MiddleName, correo.EmailAddress, telefono.PhoneNumber, tipo_telefono.Name, vendedor.Gender,	vendedor.BirthDate,	vendedor.BirthDate,	vendedor.JobTitle,	vendedor.HireDate
order by persona.LastName

/*
select top 1000 * /*BusinessEntityID, JobTitle*/
from HumanResources.Employee 
where JobTitle like '%Sales%'
	and JobTitle not like '%President%'
order by BusinessEntityID--JobTitle

-- sales person x ventas hechas
select /**/ SalesPersonID, count(SalesPersonID) as n
from Sales.SalesOrderHeader 
where SalesPersonID is not null
	and Status = 5
--group by SalesPersonID
order by SalesPersonID 

select top 100 * from HumanResources.EmployeeDepartmentHistory dh
where dh.DepartmentID = 3 --BusinessEntityID = 275
	and dh.BusinessEntityID != 273
order by dh.DepartmentID

select top 100 * from HumanResources.Department 
*/


-- FECHA ------------------------------------------------------------------------------
select distinct convert(date,orden_cabecera.OrderDate) as fecha,
	convert(int,datepart(year,orden_cabecera.OrderDate)) as anio,
	convert(int,datepart(quarter,orden_cabecera.OrderDate)) as trimestre,
	convert(varchar,datepart(month,orden_cabecera.OrderDate)) as mes,
	convert(int,datepart(day,orden_cabecera.OrderDate)) as dia
from Sales.SalesOrderHeader orden_cabecera

-- PRODUCTOS ------------------------------------------------------------------------------
/*
producto
	nombre
	numero_producto
	categoria
	subcategoria
	modelo
*/

select producto.Name as nombre,
	producto.ProductNumber as numero_producto
	,ISNULL(categoria.Name,'-') as categoria
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


/*
select * from Production.Product 
select top 100 * from Production.ProductCategory
select top 100 * from Production.ProductSubcategory
select top 100 * from Production.ProductModel
select * from Production.UnitMeasure
*/


-- PROVEEDOR ------------------------------------------------------------------------------
/*
proveedor
	numero_cuenta
	nombre
	producto_id
	producto
	precio_estandar
	orden_min
	orden_max
*/
/*
select distinct proveedor.AccountNumber as numero_cuenta,
	proveedor.Name as nombre,
	producto.ProductID as producto_id,
	producto.Name as producto,
	producto_proveedor.StandardPrice as precio_estandar,
	producto_proveedor.MinOrderQty as orden_min,
	producto_proveedor.MaxOrderQty as orden_max
from Purchasing.Vendor proveedor
	inner join Purchasing.ProductVendor producto_proveedor
	on producto_proveedor.BusinessEntityID = proveedor.BusinessEntityID
	inner join Production.Product producto
	on producto.ProductID = producto_proveedor.ProductID
order by producto_id*/

/*
select top 100 * from Purchasing.Vendor
select top 100 * from Purchasing.ProductVendor
*/


-- VENTA ------------------------------------------------------------------------------
select cliente_dw.id_cliente as id_cliente
	,fecha_dw.id_fecha as id_fecha
	,producto_dw.id_producto as id_producto
	/*,vendedor_bd.BusinessEntityID
	,o_cabecera_bd.SalesPersonID
	,vendedor_dw.dni
	,vendedor_bd.NationalIDNumber 
	,vendedor_dw.id_vendedor as id_vendedor*/
	,o_detalle_bd.UnitPrice as precio
	,o_detalle_bd.OrderQty as cantidad
from AdventureWorks2014.Production.Product producto_bd
	inner join AdventureWorks2014.Sales.SalesOrderDetail o_detalle_bd
	on o_detalle_bd.ProductID = producto_bd.ProductID
	inner join AdventureWorks2014.Sales.SalesOrderHeader o_cabecera_bd
	on o_cabecera_bd.SalesOrderID = o_detalle_bd.SalesOrderID
	inner join AdventureWorks2014.Person.Person persona_bd
	on persona_bd.BusinessEntityID = o_cabecera_bd.CustomerID
	

	-- no encontré la forma de conectarlo con vendedor
	/*left join AdventureWorks2014.HumanResources.Employee vendedor_bd
	on vendedor_bd.BusinessEntityID = o_cabecera_bd.SalesPersonID*/

	inner join bd_ec2_aventureworks14_dw.dbo.dim_cliente cliente_dw
	on cliente_dw.nombres COLLATE Modern_Spanish_CI_AS like concat(persona_bd.FirstName,' ',persona_bd.MiddleName) COLLATE Modern_Spanish_CI_AS
	
	--fecha
	inner join bd_ec2_aventureworks14_dw.dbo.dim_fecha fecha_dw
	on fecha_dw.fecha like convert(date,o_cabecera_bd.OrderDate)
	

	-- producto
	inner join bd_ec2_aventureworks14_dw.dbo.dim_producto producto_dw
	on producto_dw.numero_producto COLLATE Modern_Spanish_CI_AS like producto_bd.ProductNumber COLLATE Modern_Spanish_CI_AS

	-- no encontré la forma de conectarlo con vendedor
	/*left join bd_ec2_aventureworks14_dw.dbo.dim_vendedor vendedor_dw
	on vendedor_dw.dni COLLATE Modern_Spanish_CI_AS = vendedor_bd.NationalIDNumber COLLATE Modern_Spanish_CI_AS*/
	order by fecha_dw.id_fecha
go

	-- CustomerID 29825 SalesPersonID 279 OrderDate

	select top 500 * from AdventureWorks2014.Sales.SalesOrderHeader o
	inner join AdventureWorks2014.Sales.SalesOrderDetail d
	on d.SalesOrderID = o.SalesOrderID


	select top 500 * from AdventureWorks2014.HumanResources.Employee

	select top 500 * from AdventureWorks2014.Sales.SalesOrderDetail

	select * from AdventureWorks2014.Production.Product p
	order by p.Name
	
	select p.Name, count(p.Name) as n from AdventureWorks2014.Purchasing.Vendor p
	group by p.Name
	order by p.Name

	select p.EmailAddress, count(EmailAddressID) as n from AdventureWorks2014.Person.EmailAddress p
	group by p.EmailAddress
	--having count(EmailAddressID) >1
	order by p.EmailAddress



SELECT
PRODD.ID_PRODUCTO AS ProductoId
,CLID.ID_CLIENTE AS ClienteId
,EMPD.ID_EMPLEADO AS EmpleadoId
,TID.ID_FECHA AS TiempoId
,PROVD.ID_PROVEEDOR AS ProveedorId,
DETN.UnitPrice AS Precio,
DETN.Quantity AS Cantidad
FROM NORTHWIND.DBO.Products PRODN
INNER JOIN NORTHWIND.DBO.Categories CATN ON (PRODN.CategoryID = CATN.CategoryID)
INNER JOIN NORTHWIND.DBO.Suppliers SUPN ON (PRODN.SupplierID=SUPN.SupplierID)
INNER JOIN NORTHWIND.DBO.[Order Details] DETN ON (PRODN.ProductID=DETN.ProductID)
INNER JOIN NORTHWIND.DBO.Orders ORDN ON (ORDN.OrderID=DETN.OrderID)
INNER JOIN NORTHWIND.DBO.Customers CUSN ON (CUSN.CustomerID = ORDN.CustomerID)
INNER JOIN NORTHWIND.DBO.Employees EMPN ON (EMPN.EmployeeID = ORDN.EmployeeID)
INNER JOIN NW_DM.dbo.dim_Productos PRODD ON (PRODD.NOMBRE = PRODN.ProductName)
INNER JOIN NW_DM.DBO.dim_Clientes CLID ON (CLID.NOMBRES=CUSN.ContactName)
INNER JOIN NW_DM.DBO.dim_Empleado EMPD ON (EMPD.NOMBRE=EMPN.LastName)
INNER JOIN NW_DM.DBO.dim_FECHA TID ON (TID.Fecha=CONVERT(DATE,ORDN.OrderDate))
INNER JOIN NW_DM.DBO.dim_Proveedor PROVD ON (PROVD.NOMBRE=SUPN.CompanyName);
