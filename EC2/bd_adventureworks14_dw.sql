USE master
GO

IF EXISTS(SELECT * FROM sys.sysdatabases WHERE name='bd_ec2_aventureworks14_dw')
BEGIN
	ALTER DATABASE bd_ec2_aventureworks14_dw SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE bd_ec2_aventureworks14_dw
END
GO

CREATE DATABASE bd_ec2_aventureworks14_dw
GO

USE bd_ec2_aventureworks14_dw
GO


CREATE TABLE dim_cliente(
	id_cliente int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	apellido nvarchar(45) NOT NULL,
	nombres nvarchar(45) NOT NULL,
	correo nvarchar(45) NOT NULL,
	telefono nvarchar(20) NOT NULL,
	tipo_telefono nvarchar(20) NOT NULL,
	pais nvarchar(20) NOT NULL,
	estado nvarchar(20) NOT NULL,
	direccion nvarchar(50) NOT NULL,
	tipo_direccion nvarchar(20) NOT NULL,
	codigo_postal nvarchar(45) NOT NULL)
GO

CREATE TABLE dim_fecha(
	id_fecha int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	fecha date NOT NULL,
	anio int NOT NULL,
	trimestr int NOT NULL,
	mes int NOT NULL,
	dia int NOT NULL)
GO

CREATE TABLE dim_producto(
	id_producto int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	nombre nvarchar(45) NOT NULL,
	numero_producto varchar(10) NOT NULL,
	categoria nvarchar(20) NOT NULL,
	subcategoria nvarchar(20) NOT NULL,
	modelo nvarchar(30) NOT NULL)
GO

CREATE TABLE ventas(
	id_cliente int FOREIGN KEY REFERENCES dim_cliente(id_cliente) NOT NULL,
	id_fecha int FOREIGN KEY REFERENCES dim_fecha(id_fecha) NOT NULL,
	id_producto int FOREIGN KEY REFERENCES dim_producto(id_producto) NOT NULL,
	precio decimal(8,2) NOT NULL,
	cantidad int NOT NULL)
GO