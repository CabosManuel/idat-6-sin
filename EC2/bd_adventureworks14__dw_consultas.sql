use bd_adventureworks14
go

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
order by persona.LastName
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
