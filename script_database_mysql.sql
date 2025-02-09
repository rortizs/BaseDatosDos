--DATA BASE MYSQL
CREATE DATABASE IF NOT EXISTS `Central Bank` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

USE `Central Bank`;

-- Table structure for table Centrals
--Tabel strcucture for centrals
CREATE TABLE centrals(
id_central INT NOT NULL IDENTITY(1,1) PRIMARY KEY, --PRIMARY KEY OF TABLE CENTRALS
name_central VARCHAR(50) NOT NULL, --name of central (Guastatoya_tigo)
address_central VARCHAR(50) NOT NULL, --address of central (Barrio la Democracia)
);

--Table strcuture Branchs is a relationship with central
CREATE TABLE branches(
id_branch INT NOT NULL IDENTITY(1,1) PRIMARY KEY, --Primary key of table branches
name_branch VARCHAR(50) NOT NULL, --name of branch (Sanarate_tigo)
address_branch VARCHAR(50) NOT NULL, --address of branch (Avenida Arriaza)
id_central_branch INT NOT NULL, --forening key of table central
id_central INT FOREIGN KEY REFERENCES centrals(id_central) -- foreign key central
);

