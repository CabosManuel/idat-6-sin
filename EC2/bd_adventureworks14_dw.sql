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
