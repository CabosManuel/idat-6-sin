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
	tipo_tel.Name as tipo_telefono, 
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
	inner join Person.PhoneNumberType tipo_tel
	on tipo_tel.PhoneNumberTypeID = telefono.PhoneNumberTypeID

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