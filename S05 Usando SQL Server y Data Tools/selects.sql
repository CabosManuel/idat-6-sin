USE NORTHWIND
GO

-- CLIENTES
SELECT DISTINCT ContactName,cus.Country,cus.City
FROM Customers cus

-- PROVEEDORES
SELECT DISTINCT sup.CompanyName,sup.Country 
FROM Suppliers sup

-- FECHAS
SELECT DISTINCT 
	d.OrderDate,
	d.Anio,
	DATEPART(QUARTER,d.OrderDate) as trimestre,
	d.Mes,
	d.Dia
FROM Dates d

-- PRODUCTOS
SELECT DISTINCT p.ProductName,c.CategoryName
FROM Products p INNER JOIN Categories c
	ON	p.CategoryID=c.CategoryID

-- EMPLEADO
SELECT DISTINCT
	CONCAT(e.LastName,', ',e.FirstName) as nombre,
	(select CONCAT(e1.LastName,', ',e1.FirstName) from Employees e1 where e1.Title LIKE 'Sales Manager') as jefe
FROM Employees e
WHERE e.Title LIKE 'Sales Representative'