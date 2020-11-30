USE MASTER 
GO
--DROP DATABASE [NORTHWIND_MART]
IF EXISTS (SELECT NAME FROM sys.databases where name = 'NORTHWIND_MART')
 DROP DATABASE [NORTHWIND_MART]
GO

-- CREACION DE LA BASE DE DATOS
CREATE DATABASE [NORTHWIND_MART]
GO
USE [NORTHWIND_MART]
GO

-- CREACION DE LAS DIMESIONES
-- CREACION DE LA DIMENSION FECHA
--DROP TABLE dbo.Dim_Fecha
SET DATEFORMAT ymd
CREATE TABLE
dbo.Dim_Fecha(
  IDFecha int NOT NULL IDENTITY(1, 1) ,
  [Fecha] datetime NOT NULL,
  [Año] int NOT NULL,
  [Mes] int NOT NULL,
  [Dia] int NOT NULL,
  [Trimestre] int NOT NULL,
CONSTRAINT PK_Fechas PRIMARY KEY CLUSTERED (Fecha)
)

DECLARE @FechaInicio datetime
DECLARE @FechaFin datetime

SET @FechaInicio = '01/01/1995'
SET @FechaFin = '12/31/2020'
DECLARE @FechaCiclo datetime
SET @FechaCiclo = @FechaInicio
WHILE @FechaCiclo <= @FechaFin
BEGIN

--Insertar un registro en la dimensión Fecha
INSERT INTO Dim_Fecha VALUES (
@FechaCiclo,
Year(@FechaCiclo),
Month(@FechaCiclo),
Day(@FechaCiclo),
CASE
WHEN Month(@FechaCiclo) IN (1, 2, 3) THEN 1
WHEN Month(@FechaCiclo) IN (4, 5, 6) THEN 2
WHEN Month(@FechaCiclo) IN (7, 8, 9) THEN 3
WHEN Month(@FechaCiclo) IN (10, 11, 12) THEN 4
END
)
-- Incrementar la FechaCiclo 1 día antes
-- Comienza el ciclo nuevamente
SET @FechaCiclo = DateAdd(d, 1, @FechaCiclo)
END
--Consultamos la tabla
SELECT * FROM Dim_Fecha



-- CREACION DE LA DIMENSION CLIENTES
SELECT 
--Row_Number() OVER (Order by ContactName ASC) Clientes_SKey,
CustomerId, 
ContactName,
Country
INTO Dim_Clientes FROM [NORTHWIND].[dbo].[Customers]
ALTER TABLE Dim_Clientes
ADD PRIMARY KEY NONCLUSTERED (CustomerId)
GO

--CREACION DE LA DIMENISON EMPLEADOS

SELECT 
EmployeeID, 
([LastName] + ' ' +  [FirstName]) AS Nombre_Completo
INTO Dim_Empleados_tmp FROM [NORTHWIND].[dbo].[Employees]
GO

SELECT 
--Row_Number() OVER (Order by Nombre_Completo ASC) Empleados_SKey,
EmployeeID, 
Nombre_Completo
INTO Dim_Empleados FROM [NORTHWIND_MART].[dbo].[Dim_Empleados_tmp]
GO
DROP TABLE [NORTHWIND_MART].[dbo].[Dim_Empleados_tmp]
GO
ALTER TABLE Dim_Empleados
ADD PRIMARY KEY NONCLUSTERED (EmployeeID)
GO

-- CREACION DE LA DIMENSION PRODUCTO
SELECT 
--Row_Number() OVER (Order by [ProductName] ASC) Products_SKey,
[ProductID],
[ProductName],
[UnitPrice],
[CategoryID]
INTO Dim_Productos FROM [NORTHWIND].[dbo].[Products]
GO
ALTER TABLE Dim_Productos
ADD PRIMARY KEY NONCLUSTERED (ProductID)
GO

-- CREACION DE TABLA DE HECHOS 
SELECT 
A.[OrderDate] as Fecha,
A.[CustomerID],
A.[EmployeeID],
B.[ProductID],
B.[UnitPrice],
B.[Quantity]
INTO Fac_Ventas 
FROM [NORTHWIND].[dbo].[Orders] AS A
INNER JOIN [NORTHWIND].[dbo].[Order Details] AS B ON A.[OrderID] = B.[OrderID]
GO

ALTER TABLE Fac_Ventas
ADD FOREIGN KEY (CustomerID) REFERENCES Dim_Clientes
ALTER TABLE Fac_Ventas
ADD FOREIGN KEY (EmployeeID) REFERENCES Dim_Empleados
ALTER TABLE Fac_Ventas
ADD FOREIGN KEY (ProductID) REFERENCES Dim_Productos
ALTER TABLE Fac_Ventas
ADD FOREIGN KEY (Fecha) REFERENCES Dim_Fecha