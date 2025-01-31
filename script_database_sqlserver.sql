--CREATE DABASE ON MSSQL SERVER 2022
CREATE DATABASE [BANKING]
GO


--USE DATABASE
USE [BANKING]

--CREATE TABLES
--CREATE TABLE CENTRAL BANK
CREATE TABLE CENTRALS
(
    id_central INT PRIMARY KEY IDENTITY(1,1),
    name_central NVARCHAR(100) NOT NULL,
    address_centrral NVARCHAR(100) NOT NULL,
    phone_central NVARCHAR(20) NOT NULL,
    email_central NVARCHAR(100) NOT NULL,
    CREATED_DATE DATETIME NOT NULL,
    UPDATED_DATE DATETIME NOT NULL
);

--CREATE TABLE BRANCHES
CREATE TABLE BRANCHES
(
    id_branch INT PRIMARY KEY IDENTITY(1,1),
    code_branch NVARCHAR(10) UNIQUE NOT NULL,
    name_branch NVARCHAR(100) NOT NULL,
    address_branch NVARCHAR(100) NOT NULL,
    phone_branch NVARCHAR(20) NOT NULL,
    email_branch NVARCHAR(100) NOT NULL,
    id_central_branch INT NOT NULL, --FOREIGN KEY REFERENCES CENTRALS
    CREATED_DATE DATETIME NOT NULL,
    UPDATED_DATE DATETIME NOT NULL,
    FOREIGN KEY (id_central_branch) REFERENCES CENTRALS(id_central) --FOREIGN KEY REFERENCES CENTRALS
);

--CREATE TABLE ATMS
CREATE TABLE ATMS
(
    id_atm INT PRIMARY KEY IDENTITY(1,1),
    code_atm NVARCHAR(10) UNIQUE NOT NULL,
    name_atm NVARCHAR(100) NOT NULL,
    address_atm NVARCHAR(100) NOT NULL,
    phone_atm NVARCHAR(20) NOT NULL,
    email_atm NVARCHAR(100) NOT NULL,
    id_branch_atm INT NOT NULL, --FOREIGN KEY REFERENCES BRANCHES
    CREATED_DATE DATETIME NOT NULL,
    UPDATED_DATE DATETIME NOT NULL,
    FOREIGN KEY (id_branch_atm) REFERENCES BRANCHES(id_branch) --FOREIGN KEY REFERENCES BRANCHES
);

--CREATE TABLE ACCOUNTS HOLDERS
CREATE TABLE ACCOUNTS_HOLDERS
(
    id_account_holder INT PRIMARY KEY IDENTITY(1,1),
    name_account_holder NVARCHAR(100) NOT NULL,
    address_account_holder NVARCHAR(100) NOT NULL,
    phone_account_holder NVARCHAR(20) NOT NULL,
    email_account_holder NVARCHAR(100) NOT NULL,
    CREATED_DATE DATETIME NOT NULL,
    UPDATED_DATE DATETIME NOT NULL
);

--CREATE TABLE ACCOUNTS
CREATE TABLE ACCOUNTS
(
    id_account INT PRIMARY KEY IDENTITY(1,1),
    number_account NVARCHAR(10) UNIQUE NOT NULL,
    type_account NVARCHAR(10) CHECK (TYPE IN ('AHORRO', 'MONETARIA')),
    currency_account NVARCHAR(10) CHECK(CURRENCY IN ('USD', 'GTQ')),
    balance_account DECIMAL(18,2) DEFAULT 0.00 NOT NULL,
    id_account_holder_account INT NOT NULL, --FOREIGN KEY REFERENCES ACCOUNTS HOLDERS
    id_branch_account INT NOT NULL, --FOREIGN KEY REFERENCES BRANCHES
    CREATED_DATE DATETIME NOT NULL,
    UPDATED_DATE DATETIME NOT NULL,
    FOREIGN KEY (id_account_holder_account) REFERENCES ACCOUNTS_HOLDERS(id_account_holder) --FOREIGN KEY REFERENCES ACCOUNTS HOLDERS
    FOREIGN KEY (id_branch_account) REFERENCES BRANCHES(id_branch) --FOREIGN KEY REFERENCES BRANCHES
);

--CREATE TABLE TRANSACTIONS
CREATE TABLE Transacctions
(
    id_transaction INT PRIMARY KEY IDENTITY(1,1),
    type_transaction NVARCHAR(10) CHECK(TYPE IN ('DEPOSITO', 'RETIRO')),
    amount_transaction DECIMAL(18,2) DEFAULT 0.00 NOT NULL,
    id_account_transaction INT NOT NULL, --FOREIGN KEY REFERENCES ACCOUNTS
    id_atm_transaction INT NOT NULL, --FOREIGN KEY REFERENCES ATMS
    CREATED_DATE DATETIME NOT NULL,
    UPDATED_DATE DATETIME NOT NULL,
    FOREIGN KEY (id_account_transaction) REFERENCES ACCOUNTS(id_account) --FOREIGN KEY REFERENCES ACCOUNTS
    FOREIGN KEY (id_atm_transaction) REFERENCES ATMS(id_atm) --FOREIGN KEY REFERENCES ATMS
);
