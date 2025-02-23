--CREATE DABASE ON MSSQL SERVER 2022
CREATE DATABASE [BANKING]
GO


--USE DATABASE
USE [BANKING]

--CREATE TABLES
--CREATE TABLE CENTRAL BANK
CREATE TABLE centrals
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
CREATE TABLE branches
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
CREATE TABLE atms
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
CREATE TABLE accounts_holders
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
CREATE TABLE accounts
(
    id_account INT PRIMARY KEY IDENTITY(1,1),
    number_account NVARCHAR(10) UNIQUE NOT NULL,
    type_account NVARCHAR(10) CHECK (type_account IN ('AHORRO', 'MONETARIA')), --type accounts 
    currency_account NVARCHAR(10) CHECK(currency_account IN ('USD', 'GTQ')),
    balance_account DECIMAL(18,2) DEFAULT 0.00 NOT NULL,
    id_account_holder_account INT NOT NULL, --FOREIGN KEY REFERENCES ACCOUNTS HOLDERS
    id_branch_account INT NOT NULL, --FOREIGN KEY REFERENCES BRANCHES
    CREATED_DATE DATETIME NOT NULL,
    UPDATED_DATE DATETIME NOT NULL,
    FOREIGN KEY (id_account_holder_account) REFERENCES ACCOUNTS_HOLDERS(id_account_holder) --FOREIGN KEY REFERENCES ACCOUNTS HOLDERS
    FOREIGN KEY (id_branch_account) REFERENCES BRANCHES(id_branch) --FOREIGN KEY REFERENCES BRANCHES
);

--CREATE TABLE TRANSACTIONS
CREATE TABLE transacctions
(
    id_transaction INT PRIMARY KEY IDENTITY(1,1),
    type_transaction NVARCHAR(10) CHECK(type_transaction IN ('DEPOSITO', 'RETIRO')), --type_transaction this deposite or retorno = 
    amount_transaction DECIMAL(18,2) DEFAULT 0.00 NOT NULL,
    id_account_transaction INT NOT NULL, --FOREIGN KEY REFERENCES ACCOUNTS
    id_atm_transaction INT NOT NULL, --FOREIGN KEY REFERENCES ATMS
    CREATED_DATE DATETIME NOT NULL,
    UPDATED_DATE DATETIME NOT NULL,
    FOREIGN KEY (id_account_transaction) REFERENCES ACCOUNTS(id_account) --FOREIGN KEY REFERENCES ACCOUNTS
FOREIGN KEY (id_atm_transaction) REFERENCES ATMS(id_atm) --FOREIGN KEY REFERENCES ATMS
);

--NOW CREATED CONCEPTS ACID USING STORE PROCEDURES
----INSERT TABLE BRANCHES
-- Procedimiento almacenado para insertar una sucursal en la tabla branches
-- que implementa transacciones y manejo de errores (ACID)
CREATE PROCEDURE InsertBranch
    @code_branch       VARCHAR(50),   -- Código de la sucursal
    @name_branch       VARCHAR(100),  -- Nombre de la sucursal
    @address_branch    VARCHAR(200),  -- Dirección de la sucursal
    @phone_branch      VARCHAR(50),   -- Teléfono de la sucursal
    @email_branch      VARCHAR(100),  -- Email de la sucursal
    @id_central_branch INT           -- ID de la central (clave foránea)
AS
BEGIN
    SET NOCOUNT ON;  -- Evita el retorno de mensajes innecesarios de filas afectadas

    BEGIN TRY
        -- Inicia la transacción para garantizar que la operación sea atómica
        BEGIN TRANSACTION;

        -- Sentencia INSERT para agregar un registro en la tabla branches
        INSERT INTO [Central Bank].dbo.branches (
            code_branch,
            name_branch,
            address_branch,
            phone_branch,
            email_branch,
            id_central_branch,
            CREATED_DATE,
            UPDATED_DATE
        )
        VALUES (
            @code_branch,
            @name_branch,
            @address_branch,
            @phone_branch,
            @email_branch,
            @id_central_branch,
            GETDATE(),  -- Fecha de creación
            GETDATE()  -- Fecha de actualización
        );

        -- Si no hay errores, se confirma la transacción
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- En caso de error, se revierte la transacción
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Se capturan los detalles del error para ser enviados al cliente
        DECLARE @ErrorMessage NVARCHAR(4000),
                @ErrorSeverity INT,
                @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        -- Se lanza el error para que la aplicación que lo llamó pueda manejarlo
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;

--INSERT TABLE CENTRALS FROM STORE PROCEDURE CONEPCT ACID
-- Procedimiento almacenado para insertar un registro en la tabla 'centrals'
-- que implementa transacciones y manejo de errores (ACID)
CREATE PROCEDURE InsertCentral
    @name_central   VARCHAR(100),  -- Nombre del central
    @addess_central VARCHAR(200),  -- Dirección del central
    @phone_central  VARCHAR(50),   -- Teléfono del central
    @email_central  VARCHAR(100)  -- Email del central
AS
/*asegura la transacción para su insertar*/
BEGIN
    SET NOCOUNT ON;  -- Evita la generación de mensajes de filas afectadas

    BEGIN TRY
        -- Inicia una transacción para asegurar que la operación sea atómica
        BEGIN TRANSACTION;

        -- Inserta un nuevo registro en la tabla 'centrals'
        INSERT INTO [Central Bank].dbo.centrals (
            name_central,
            addess_central,
            phone_central,
            email_central,
            created_date,
            updated_date
        )
        VALUES (
            @name_central,
            @addess_central,
            @phone_central,
            @email_central,
            GETDATE(),  -- Fecha de creación
            GETDATE()   -- Fecha de actualización
        );

        -- Si la inserción es exitosa, confirma la transacción
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- En caso de error, revierte la transacción
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Captura y almacena los detalles del error
        DECLARE @ErrorMessage NVARCHAR(4000),
                @ErrorSeverity INT,
                @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        -- Lanza el error capturado para que la aplicación lo maneje
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;

--INSERT TABLE ATMS FROM STORE PROCEDURE CONCEPT ACID
---- Procedimiento almacenado para insertar un registro en la tabla 'atms'
-- que garantiza las propiedades ACID (Atomicidad, Consistencia, Aislamiento y Durabilidad)
-- Procedimiento almacenado para insertar un registro en la tabla 'atms'
-- con la asignación automática de las fechas de creación y actualización (GETDATE())
CREATE PROCEDURE InsertATM_AutoDate
    @code_atm      VARCHAR(50),   -- Código del cajero automático (ATM)
    @name_atm      VARCHAR(100),  -- Nombre del cajero automático
    @address_atm   VARCHAR(200),  -- Dirección del cajero automático
    @phone_atm     VARCHAR(50),   -- Teléfono del cajero automático
    @email_atm     VARCHAR(100),  -- Email del cajero automático
    @id_branch_atm INT            -- ID de la sucursal a la que pertenece el cajero (clave foránea)
AS
BEGIN
    SET NOCOUNT ON;  -- Evita el retorno de mensajes innecesarios de filas afectadas

    BEGIN TRY
        -- Inicia una transacción para asegurar que la operación se realice de forma atómica
        BEGIN TRANSACTION;

        -- Inserta un nuevo registro en la tabla 'atms'
        -- Se asigna automáticamente la fecha actual a los campos CREATED_DATE y UPDATED_DATE
        INSERT INTO [Central Bank].dbo.atms (
            code_atm,
            name_atm,
            address_atm,
            phone_atm,
            email_atm,
            id_branch_atm,
            CREATED_DATE,
            UPDATED_DATE
        )
        VALUES (
            @code_atm,
            @name_atm,
            @address_atm,
            @phone_atm,
            @email_atm,
            @id_branch_atm,
            GETDATE(),  -- Fecha de creación asignada automáticamente
            GETDATE()   -- Fecha de actualización asignada automáticamente
        );

        -- Si no se produce ningún error, confirma la transacción
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- En caso de error, revierte la transacción
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Captura y almacena los detalles del error para su posterior manejo
        DECLARE @ErrorMessage NVARCHAR(4000),
                @ErrorSeverity INT,
                @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        -- Lanza el error para que la aplicación que llama al procedimiento pueda manejarlo
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;

--INSERT TABLE ACCOUNTS HOLDERS FROM STORE PROCEDURE CONCEPT ACID
-- Procedimiento almacenado para insertar un registro en la tabla 'accounts_holders'
-- Procedimiento almacenado para insertar un registro en la tabla 'accounts_holders'
-- Se asignan automáticamente las fechas de creación y actualización con GETDATE()
CREATE PROCEDURE InsertAccountHolder
    @name_account_holder    NVARCHAR(100),  -- Nombre del titular de la cuenta
    @address_account_holder NVARCHAR(100),  -- Dirección del titular
    @phone_account_holder   NVARCHAR(20),   -- Teléfono del titular
    @email_account_holder   NVARCHAR(100)   -- Email del titular
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO accounts_holders (
            name_account_holder,
            address_account_holder,
            phone_account_holder,
            email_account_holder,
            CREATED_DATE,
            UPDATED_DATE
        )
        VALUES (
            @name_account_holder,
            @address_account_holder,
            @phone_account_holder,
            @email_account_holder,
            GETDATE(), -- Fecha de creación asignada automáticamente
            GETDATE()  -- Fecha de actualización asignada automáticamente
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000),
                @ErrorSeverity INT,
                @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;

--INSERT TABLE ACCOUNTS FROM STORE PROCEDURE CONCEPT ACID
-- Procedimiento almacenado para insertar un registro en la tabla 'accounts'
-- Procedimiento almacenado para insertar un registro en la tabla 'accounts'
-- Se asignan automáticamente las fechas de creación y actualización con GETDATE()
CREATE PROCEDURE InsertAccount
    @number_account                 NVARCHAR(10),   -- Número de cuenta (único)
    @type_account                   NVARCHAR(10),   -- Tipo de cuenta ('AHORRO' o 'MONETARIA')
    @currency_account               NVARCHAR(10),   -- Moneda ('USD' o 'GTQ')
    @balance_account                DECIMAL(18,2),   -- Saldo inicial de la cuenta
    @id_account_holder_account      INT,            -- ID del titular de la cuenta (clave foránea)
    @id_branch_account              INT             -- ID de la sucursal a la que pertenece la cuenta (clave foránea)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO accounts (
            number_account,
            type_account,
            currency_account,
            balance_account,
            id_account_holder_account,
            id_branch_account,
            CREATED_DATE,
            UPDATED_DATE
        )
        VALUES (
            @number_account,
            @type_account,
            @currency_account,
            @balance_account,
            @id_account_holder_account,
            @id_branch_account,
            GETDATE(), -- Fecha de creación asignada automáticamente
            GETDATE()  -- Fecha de actualización asignada automáticamente
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000),
                @ErrorSeverity INT,
                @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;

--INSERT TABLE TRANSACTIONS FROM STORE PROCEDURE CONCEPT ACID
-- Procedimiento almacenado para insertar un registro en la tabla 'transactions'
-- Procedimiento almacenado para insertar un registro en la tabla 'transacctions'
-- Se asignan automáticamente las fechas de creación y actualización con GETDATE()
CREATE PROCEDURE InsertTransaction
    @type_transaction        NVARCHAR(10),   -- Tipo de transacción ('DEPOSITO' o 'RETIRO')
    @amount_transaction      DECIMAL(18,2),   -- Monto de la transacción
    @id_account_transaction  INT,             -- ID de la cuenta relacionada (clave foránea)
    @id_atm_transaction      INT              -- ID del cajero automático relacionado (clave foránea)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO transacctions (
            type_transaction,
            amount_transaction,
            id_account_transaction,
            id_atm_transaction,
            CREATED_DATE,
            UPDATED_DATE
        )
        VALUES (
            @type_transaction,
            @amount_transaction,
            @id_account_transaction,
            @id_atm_transaction,
            GETDATE(), -- Fecha de creación asignada automáticamente
            GETDATE()  -- Fecha de actualización asignada automáticamente
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000),
                @ErrorSeverity INT,
                @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;


-- Procedimiento almacenado para realizar un retiro validando fondos
CREATE PROCEDURE WithdrawFromAccount
    @id_account INT,                   -- ID de la cuenta origen
    @withdraw_amount DECIMAL(18,2),      -- Monto a retirar
    @id_atm INT                        -- ID del cajero que procesa la transacción
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @current_balance DECIMAL(18,2);

        -- Bloquear la fila de la cuenta para evitar que otros procesos la modifiquen simultáneamente
        SELECT @current_balance = balance_account
        FROM accounts WITH (UPDLOCK, ROWLOCK)
        WHERE id_account = @id_account;

        -- Verificar que la cuenta existe
        IF @current_balance IS NULL
        BEGIN
            RAISERROR('La cuenta especificada no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar que el saldo sea suficiente para el retiro
        IF @current_balance < @withdraw_amount
        BEGIN
            RAISERROR('Fondos insuficientes para realizar el retiro.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Actualizar el saldo descontando el monto del retiro
        UPDATE accounts
        SET balance_account = balance_account - @withdraw_amount,
            UPDATED_DATE = GETDATE()
        WHERE id_account = @id_account;

        -- Registrar la transacción de retiro
        INSERT INTO transacctions (
            type_transaction,
            amount_transaction,
            id_account_transaction,
            id_atm_transaction,
            CREATED_DATE,
            UPDATED_DATE
        )
        VALUES (
            'RETIRO',          -- Tipo de transacción
            @withdraw_amount,
            @id_account,
            @id_atm,
            GETDATE(),         -- Fecha de creación automática
            GETDATE()          -- Fecha de actualización automática
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000),
                @ErrorSeverity INT,
                @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;

--
/*Explicación:
	•	Bloqueo y Lectura del Saldo:
La instrucción SELECT ... WITH (UPDLOCK, ROWLOCK) asegura que la fila de la cuenta se bloquee para escritura mientras se valida el saldo, evitando que otros procesos modifiquen el saldo al mismo tiempo.
	•	Validación del Saldo:
Se verifica si el saldo actual (@current_balance) es menor que el monto a retirar (@withdraw_amount). Si es así, se lanza un error y se revierte la transacción.
	•	Actualización y Registro de la Transacción:
Si el saldo es suficiente, se actualiza la cuenta restando el monto y se inserta un registro en la tabla transacctions para documentar la operación.
	•	Transacción y Manejo de Errores:
La transacción se inicia con BEGIN TRANSACTION y, en caso de error, se revierte con ROLLBACK TRANSACTION dentro del bloque CATCH. Si todo sale bien, se confirma con COMMIT TRANSACTION.

Esta estrategia garantiza que la validación y la actualización del saldo se realicen de manera atómica, manteniendo la integridad de los datos y evitando inconsistencias en entornos concurrentes.
*/


/*
Stored Procedures
	•	Control Explícito:
Se invocan de forma explícita desde la aplicación o desde otro procedimiento, lo que permite controlar exactamente cuándo y cómo se ejecuta la lógica.
	•	Manejo de Lógica de Negocio:
Es ideal para operaciones que involucran lógica de negocio compleja, validaciones, cálculos y manejo de transacciones de forma explícita.
	•	Depuración y Mantenimiento:
Al ser llamados de manera controlada, su depuración es generalmente más sencilla y su mantenimiento resulta más predecible.
	•	Seguridad:
Permiten encapsular la lógica y restringir el acceso directo a las tablas, de modo que la aplicación interactúa únicamente a través de la API definida.

Triggers
	•	Automatización:
Se ejecutan automáticamente en respuesta a eventos (INSERT, UPDATE, DELETE) sobre una tabla, lo que es útil para auditorías, validaciones automáticas o propagación de cambios.
	•	Transparencia para la Aplicación:
No requieren cambios en la lógica de la aplicación, ya que se ejecutan en segundo plano cuando se produce un evento en la tabla.
	•	Cuidado en la Lógica:
Pueden generar efectos secundarios inesperados si no se diseñan cuidadosamente, especialmente en operaciones masivas, ya que se ejecutan para cada fila afectada.
	•	Impacto en el Rendimiento:
Si se utilizan para lógica compleja o para registrar muchas operaciones, pueden impactar el rendimiento, ya que se disparan automáticamente en cada operación.

Recomendación General
	•	Lógica de Negocio y Operaciones Controladas:
Si la operación (por ejemplo, un retiro validando saldo o actualizando registros de forma controlada) requiere una secuencia de pasos con manejo explícito de errores y transacciones, un stored procedure es generalmente la mejor opción.
	•	Auditoría y Validaciones Complementarias:
Los triggers pueden ser útiles para tareas transversales, como auditorías o para asegurar que ciertos cambios se registren automáticamente, pero no deben usarse como la única fuente de la lógica de negocio principal.

En resumen, para casos donde se requiere un control preciso de la lógica y manejo de transacciones (por ejemplo, la validación de saldo en un retiro), lo más recomendable es utilizar stored procedures. Los triggers son útiles para tareas complementarias y automáticas, pero pueden complicar el mantenimiento y la trazabilidad de la lógica si se usan en exceso.
*/
