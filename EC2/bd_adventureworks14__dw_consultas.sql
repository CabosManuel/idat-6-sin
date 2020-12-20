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

-- PROVEEDOR ------------------------------------------------------------------------------
select proveedor.AccountNumber as numero_cuenta,
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
	order by producto_id
go

-- VENDEDOR ------------------------------------------------------------------------------
select distinct vendedor.NationalIDNumber as dni,
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
group by pago.Rate, departamento.Name, vendedor.NationalIDNumber,persona.LastName,persona.FirstName,persona.MiddleName, correo.EmailAddress, telefono.PhoneNumber, tipo_telefono.Name, vendedor.Gender,	vendedor.BirthDate,	vendedor.BirthDate,	vendedor.JobTitle,	vendedor.HireDate
order by persona.LastName

-- VENTAS ------------------------------------------------------------------------------
select cliente_dw.id_cliente as id_cliente,
	fecha_dw.id_fecha as id_fecha,
	producto_dw.id_producto as id_producto,
	proveedor_dw.id_proveedor as id_proveedor,
	vendedor_dw.id_vendedor as id_vendedor,
	o_detalle_bd.UnitPrice as precio,
	o_detalle_bd.OrderQty as cantidad
from AdventureWorks2014.Production.Product producto_bd
	inner join AdventureWorks2014.Sales.SalesOrderDetail o_detalle_bd
	on o_detalle_bd.ProductID = producto_bd.ProductID
	inner join AdventureWorks2014.Sales.SalesOrderHeader o_cabecera_bd
	on o_cabecera_bd.SalesOrderID = o_detalle_bd.SalesOrderID
	inner join AdventureWorks2014.Person.Person cliente_bd
	on cliente_bd.BusinessEntityID = o_cabecera_bd.CustomerID
	inner join AdventureWorks2014.Purchasing.ProductVendor prod_proveedor_bd
	on prod_proveedor_bd.ProductID = producto_bd.ProductID
	inner join AdventureWorks2014.Purchasing.Vendor proveedor_bd
	on proveedor_bd.BusinessEntityID = prod_proveedor_bd.BusinessEntityID
	inner join AdventureWorks2014.HumanResources.Employee vendedor_bd
	on vendedor_bd.BusinessEntityID = o_cabecera_bd.SalesPersonID

	inner join AdventureWorks2014.Person.EmailAddress cliente_correo_bd
	on cliente_correo_bd.BusinessEntityID = cliente_bd.BusinessEntityID

	inner join bd_ec2_aventureworks14_dw.dbo.dim_cliente cliente_dw
	on cliente_dw.correo COLLATE Modern_Spanish_CI_AS like cliente_correo_bd.EmailAddress COLLATE Modern_Spanish_CI_AS
	inner join bd_ec2_aventureworks14_dw.dbo.dim_fecha fecha_dw
	on fecha_dw.fecha like o_cabecera_bd.OrderDate
	inner join bd_ec2_aventureworks14_dw.dbo.dim_producto producto_dw
	on producto_dw.nombre COLLATE Modern_Spanish_CI_AS = producto_bd.Name COLLATE Modern_Spanish_CI_AS
	inner join bd_ec2_aventureworks14_dw.dbo.dim_proveedor proveedor_dw
	on proveedor_dw.nombre COLLATE Modern_Spanish_CI_AS = proveedor_bd.Name COLLATE Modern_Spanish_CI_AS
	inner join bd_ec2_aventureworks14_dw.dbo.dim_vendedor vendedor_dw
	on vendedor_dw.dni COLLATE Modern_Spanish_CI_AS like vendedor_bd.NationalIDNumber COLLATE Modern_Spanish_CI_AS
go


/* -- ELIMIANAR DATOS --
delete from bd_ec2_aventureworks14_dw.dbo.ventas;
delete from bd_ec2_aventureworks14_dw.dbo.dim_cliente;
delete from bd_ec2_aventureworks14_dw.dbo.dim_fecha;
delete from bd_ec2_aventureworks14_dw.dbo.dim_producto;
delete from bd_ec2_aventureworks14_dw.dbo.dim_proveedor;
delete from bd_ec2_aventureworks14_dw.dbo.dim_vendedor;
*/
