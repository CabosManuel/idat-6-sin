USE master
GO

IF EXISTS(SELECT * FROM sys.sysdatabases WHERE name='bd_rent4you')
BEGIN
	ALTER DATABASE bd_rent4you SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE bd_rent4you
END
GO

CREATE DATABASE bd_rent4you
GO

USE bd_rent4you
GO

CREATE TABLE dim_cliente(
	id_cliente int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	nombre nvarchar(45) NOT NULL,
	direccion nvarchar(45) NOT NULL,
	provincia nvarchar(45) NOT NULL,
	ciudad nvarchar(45) NOT NULL,
	pais nvarchar(45) NOT NULL,
	codigo_postal nvarchar(45) NOT NULL, -- ?
	telefono char(9) NOT NULL -- ?
)
GO

CREATE TABLE dim_sucursal(
	id_sucursal int IDENTITY (1,1) NOT NULL PRIMARY KEY,
	nombre nvarchar(45) NOT NULL,
	provincia nvarchar(45) NOT NULL,
	ciudad nvarchar(45) NOT NULL,
	director nvarchar(45) NOT NULL,
	direccion nvarchar(45) NOT NULL,
	codigo_postal nvarchar(45) NOT NULL, -- ?
	telefono nchar(9) NOT NULL, -- ?
	direccion_web nvarchar(45) NOT NULL
)
GO

CREATE TABLE dim_vehiculos(
	id_vehiculo int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	matricula nvarchar(10) NOT NULL, -- ?
	modelo nvarchar(45) NOT NULL,
	categoria nvarchar(45) NOT NULL,
	num_seguro nvarchar(45) NOT NULL, -- ?
	precio decimal(8,2) NOT NULL,
	cod_sucursal int NOT NULL, -- ?
)
GO

CREATE TABLE dim_tiempo(
	id_fecha int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	dia int NOT NULL,
	mes int NOT NULL,
	anio int NOT NULL,
	dia_semana int NOT NULL,
	dia_anio int NOT NULL,
	vacaciones bit NOT NULL, -- ?
	fin_semana bit NOT NULL, -- ?
	mes_anio int NOT NULL,
	semana_anio int
)
GO

CREATE TABLE dim_empleado(
	id_empleado int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	cod_sucursal int NOT NULL,
	nombre nvarchar(45) NOT NULL,
	fecha_antiguedad date NOT NULL -- ?
)
GO

CREATE TABLE ventas(
	id_fecha int FOREIGN KEY REFERENCES dim_tiempo(id_fecha) NOT NULL,
	id_vehiculo int FOREIGN KEY REFERENCES dim_vehiculos(id_vehiculo) NOT NULL,
	id_cliente int FOREIGN KEY REFERENCES dim_cliente(id_cliente) NOT NULL,
	id_sucursal int FOREIGN KEY REFERENCES dim_sucursal(id_sucursal) NOT NULL,
	id_empleado int FOREIGN KEY REFERENCES dim_empleado(id_empleado) NOT NULL,
	precio decimal(8,2) NOT NULL
)
GO