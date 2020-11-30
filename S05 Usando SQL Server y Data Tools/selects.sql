USE NORTHWIND
GO

-- CLIENTES -------------------------------------------------------------
SELECT DISTINCT ContactName,cus.Country,cus.City
FROM Customers cus

-- PROVEEDORES ----------------------------------------------------------
SELECT DISTINCT sup.CompanyName,sup.Country 
FROM Suppliers sup

-- FECHAS ---------------------------------------------------------------
SELECT DISTINCT CONVERT(Date, o.OrderDate) As Fecha,
CONVERT(Int,Datepart(Year,o.OrderDate)) As Anio,
CONVERT(Int,Datepart(Quarter,o.OrderDate)) As Trimestre,
CONVERT(Varchar,Datepart(Month,o.OrderDate)) As Mes,
CONVERT(Int,Datepart(Day,o.OrderDate)) As Dia
FROM Orders o

/*
SELECT DISTINCT
	d.OrderDate,
	d.Anio,
	DATEPART(QUARTER,d.OrderDate) as trimestre,
	d.Mes,
	d.Dia
FROM Dates d
*/

-- PRODUCTOS -----------------------------------------------------------
SELECT DISTINCT p.ProductName,c.CategoryName
FROM Products p INNER JOIN Categories c
	ON	p.CategoryID=c.CategoryID
GO

-- EMPLEADO ------------------------------------------------------------
SELECT DISTINCT emp.LastName, emp.ReportsTo
FROM Employees emp
WHERE emp.ReportsTo IS NOT NULL

/*
SELECT DISTINCT
	CONCAT(e.LastName,', ',e.FirstName) as nombre,
	(select CONCAT(e1.LastName,', ',e1.FirstName) from Employees e1 where e1.Title LIKE 'Sales Manager') as jefe
FROM Employees e
WHERE e.Title LIKE 'Sales Representative'
*/

-- VENTAS -------------------------------------------------------------
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


-- Limpiar BD destino
delete from NW_DM.dbo.ventas;
delete from NW_DM.dbo.dim_clientes;
delete from NW_DM.dbo.dim_empleado;
delete from NW_DM.dbo.dim_proveedor;
delete from NW_DM.dbo.dim_fecha;
delete from NW_DM.dbo.dim_productos;

-- final, debería lista la misma cantidad (1914)
select * from NW_DM.dbo.ventas