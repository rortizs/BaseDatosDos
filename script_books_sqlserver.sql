CREATE PROCEDURE RecordSale(
    IN book_id INT, --book_id(10)
    IN copies INT,
    IN sale_date DATE
)
BEGIN
	---DECLARE IS A FUNCTION 
    DECLARE current_stock INT;  --STOCK
    DECLARE unit_price DECIMAL(10,2); --PRICE FOR BOOK
    DECLARE final_price DECIMAL(10,2); --FINAL PRICE 

    -- Validar que el libro existe y obtener stock y precio
    SELECT units_in_stock, price INTO current_stock, unit_price FROM books WHERE id = book_id;
    
    IF current_stock IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El libro no existe';
    END IF;
    
    IF current_stock < copies THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente';
    END IF;
    
    -- Aplicar descuento del 10% si se compran más de 5 copias
    SET final_price = IF(copies > 5, unit_price * 0.90, unit_price);
    
    -- Actualizar stock
    UPDATE books SET units_in_stock = units_in_stock - copies WHERE id = book_id;
    
    -- Insertar venta
    INSERT INTO sales (book_id, copies, sale_price, sale_date)
    VALUES (book_id, copies, final_price, sale_date);
END

CREATE TABLE books (
    id INT PRIMARY KEY IDENTITY(1,1),
    title VARCHAR(100),
    author_id INT,
    editorial_id INT,
    price DECIMAL(10,2),
    units_in_stock INT
);

-- Creación de la tabla de autores
CREATE TABLE authors (
    id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(50),
    nationality VARCHAR(50)
);

-- Creación de la tabla de editoriales
CREATE TABLE editorials (
    id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100),
    country VARCHAR(50)
);

-- Creación de la tabla de ventas
CREATE TABLE sales (
    id INT PRIMARY KEY IDENTITY(1,1),
    book_id INT,
    copies INT,
    sale_price DECIMAL(10,2),
    sale_date DATE,
    FOREIGN KEY (book_id) REFERENCES books(id)
);

-- Inserción de datos de prueba en autores
INSERT INTO authors (name, nationality) VALUES 
('Gabriel García Márquez', 'Colombiana'),
('J.K. Rowling', 'Británica'),
('George Orwell', 'Británica');

-- Inserción de datos de prueba en editoriales
INSERT INTO editorials (name, country) VALUES 
('Penguin Random House', 'EE.UU'),
('Planeta', 'España'),
('Alfaguara', 'México');

-- Inserción de datos de prueba en libros
INSERT INTO books (title, author_id, editorial_id, price, units_in_stock) VALUES 
('Cien Años de Soledad', 1, 1, 15.99, 20),
('Harry Potter y la Piedra Filosofal', 2, 2, 12.99, 10),
('1984', 3, 3, 18.50, 15);



-- Prueba del procedimiento almacenado
CALL RecordSale(1, 6, '2025-03-09');
CALL RecordSale(2, 3, '2025-03-09');
CALL RecordSale(3, 10, '2025-03-09');

