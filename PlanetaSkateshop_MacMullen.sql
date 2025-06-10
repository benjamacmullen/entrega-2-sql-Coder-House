
/*CREACION DE BASE DE DATOS Y DARLE USO A LA MISMA */

Create database PlanetaSkateshop;
use PlanetaSkateshop;


/*CREACION DE TABLA CATEGORIA*/

CREATE TABLE Categoria (
    Id_cat INT PRIMARY KEY AUTO_INCREMENT,
    Name_cat VARCHAR(255),
    Description varchar(255)
);




/*CREACION TABLA PRODUCTO*/

create table Producto (

Id_product int primary key auto_increment,
Name_product varchar(255),
Description varchar(255),
precio float,
Stock_dispo int,
Id_cat int,
foreign key (Id_cat) references Categoria(Id_cat)

);

/*CREACION TABLA CLIENTES*/


create table Clientes (
Id_cliente int primary key auto_increment,
Nombre text,
Last_Name text,
Email text,
direct text,
Phone text,
sexo text,
Fecha_Registro date


);


/* CORRECION A LA MISMA TABLA*/
ALTER TABLE Clientes
MODIFY COLUMN Nombre VARCHAR(255) ,
MODIFY COLUMN Last_Name VARCHAR(255),
MODIFY COLUMN Direct VARCHAR(255), 
MODIFY COLUMN Phone VARCHAR(20),  
MODIFY COLUMN Sexo ENUM('Masculino', 'Femenino', 'Otro');  

ALTER TABLE Clientes
MODIFY COLUMN Email varchar(255);

ALTER TABLE Clientes
MODIFY COLUMN Id_cliente int  NOT NULL  auto_increment,
MODIFY COLUMN Nombre VARCHAR(255) NOT NULL,
MODIFY COLUMN Last_Name VARCHAR(255) NOT NULL,
MODIFY COLUMN Direct VARCHAR(255) NOT NULL, 
MODIFY COLUMN Phone VARCHAR(20) NOT NULL,  
MODIFY COLUMN Sexo ENUM('Masculino', 'Femenino', 'Otro') NOT NULL, 
MODIFY COLUMN Email varchar(255) NOT NULL;

/*CREACION TABLA VENTAS*/

create table ventas (
Id_venta int primary key auto_increment,
Id_cliente int,
total float,
Fecha_venta date,
foreign key (Id_cliente) references Clientes(Id_cliente)
);


/*CREACION TABLA DETALLE DE VENTAS*/

create table Detalle_Ventas (
Id_detalle int primary key auto_increment,
Id_venta int,
Id_product int,
Cant int,
P_unitario float,
Sub float,
foreign key (Id_venta) references Ventas(Id_venta),
foreign key (Id_product) references Producto(Id_product)


);

use planetaskateshop;


/*creacion  tabla empleados*/

create table empleados (
Id_empleado int primary key auto_increment,
nombre varchar(255),
rol enum('Administrador', 'vendedor'),
email varchar (255),
clave varchar (255)
);
/*modificacion de la misma */
alter table empleados 
modify column Id_empleado int not null auto_increment,
modify column  nombre varchar(255) not null,
modify column  rol enum('Administrador', 'vendedor') not null,
modify column email varchar (255) not null,
modify column clave varchar (255) not null;

/* modificacion tabla ventas*/
alter table ventas
add column Id_empleado int,
add foreign key (Id_empleado) references empleados(Id_empleado);

/*creacion tabla de metodo de pago*/
create table Metodo_Pago(
Id_pago int primary key auto_increment,
tipo_pago varchar (50) not null -- efectivo, tarjeta , transferencia.--
);
/*nueva modificacion tabla ventas*/
alter table ventas 
add Id_pago int,
add foreign key (Id_pago) references metodo_pago(Id_pago);
/*creacion tabla direcciones*/
create table direcciones(
id_direccion int primary key not null auto_increment,
id_cliente int,
direccion varchar(255) not null,
departamento varchar (100) not null,
barrio varchar(100) not null,
nombre_casa varchar(100),
piso_depto varchar(100),
foreign key (id_cliente) references clientes(id_cliente)
);
/*creacion tabla Logacciones*/
create table LogAcciones (

Id_log int primary key not null auto_increment,
tabla_afectada varchar(50),
tipo_operacion enum('insert','update','delete'),
fecha datetime default current_timestamp,
descripcion text

);


/*vistas*/

/*vista 'PRODUCTOS'  utilizando todos los campos de la tabla producto*/
create view productos as 
      select * from producto;
      
drop view productos;


/*vista 'productos_con_categoria' utilizando campos tanto  como producto y categoria*/

create view productos_con_categoria as 
	select  
    producto.Id_product, 
    producto.name_product, 
    producto.description, 
    producto.precio, 
    producto.stock_dispo, 
    categoria.name_cat as categoria 
    from producto
    join categoria on producto.Id_cat = categoria.Id_cat;
    
/* vista Ventas_Empleado esta es para el total de ventas de cada empleados utilizando campos de ventas y empleado */

create view Ventas_Empleado as 
	select
    ventas.Id_venta,
    ventas.total,
    ventas.fecha_venta,
    empleados.nombre as empleado
    from ventas 
    join empleados on ventas.Id_empleado = empleados.Id_empleado;
    
    
    CREATE OR REPLACE VIEW Ventas_Empleado AS 
SELECT
    ventas.Id_venta,
    ventas.total,
    ventas.fecha_venta,
    empleados.nombre AS empleado
FROM ventas 
JOIN empleados ON ventas.Id_empleado = empleados.Id_empleado;

    
    
/* vista StockBajo utiliza campos de producto*/

create view Stock_Bajo as 
	select 
    id_product,
    name_product,
    stock_dispo
    from producto
    where stock_dispo <=3;
    
    
    
    /*triggers*/
    
DELIMITER //
CREATE TRIGGER LogInsertClientes
AFTER INSERT ON Clientes
FOR EACH ROW
BEGIN
    INSERT INTO LogAcciones (tabla_afectada, tipo_operacion, fecha, descripcion)
    VALUES (
        'Clientes',
        'insert',
        NOW(),
        CONCAT('Cliente con id: ', NEW.Id_cliente, ' fue agregado')
    );
END //
DELIMITER ;

    
    




DELIMITER //

CREATE TRIGGER LogUpdateProducto
AFTER UPDATE ON producto
FOR EACH ROW
BEGIN
    INSERT INTO LogAcciones (tabla_afectada, tipo_operacion, fecha, descripcion)
    VALUES (
        'Producto',
        'update',
        NOW(),
        CONCAT('Producto con ID: ', OLD.id_product, ' fue actualizado. Precio anterior: ', OLD.precio, ', Precio nuevo: ', NEW.precio)
    );
END //

DELIMITER ;


/*funciones*/


DELIMITER //
CREATE FUNCTION fn_total_venta(p_venta INT)
RETURNS FLOAT
READS SQL DATA
NOT DETERMINISTIC
BEGIN
    DECLARE Total_Venta FLOAT;

    SELECT SUM(Sub)
    INTO Total_Venta
    FROM Detalle_Ventas 
    WHERE Id_venta = p_venta;

    RETURN IFNULL(Total_Venta, 0);
END //
DELIMITER ;

SELECT fn_total_venta(4);

DELIMITER //

CREATE FUNCTION fn_stock_disponible(p_id_product INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE stock INT DEFAULT 0;

    SELECT stock_dispo
    INTO stock
    FROM producto
    WHERE id_product = p_id_product;

    RETURN IFNULL(stock, 0);
END //

DELIMITER ;



SELECT fn_stock_disponible(1);

 use planetaskateshop;
/*proceudure*/
DELIMITER //
CREATE PROCEDURE sp_insertar_producto (
    IN p_name VARCHAR(255),
    IN p_description VARCHAR(255),
    IN p_precio FLOAT,
    IN p_stock INT,
    IN p_id_cat INT
)
BEGIN
    INSERT INTO Producto (Name_product, Description, precio, Stock_dispo, Id_cat)
    VALUES (p_name, p_description, p_precio, p_stock, p_id_cat);
END //
DELIMITER ;

/*prueba*/

CALL sp_insertar_producto(
    'Tabla Test Skate 8.0"',
    'Tabla de prueba para test del  procedure',
    3700,
    7,
    1 
);

    
    
SELECT * FROM Producto WHERE Name_product = 'Tabla Test Skate 8.0"';




/*insert into algunos guardados*/ 

insert into ventas (Id_cliente,total,Fecha_Venta,Id_empleado,Id_pago)
values
(1, 5000.00, '2023-06-20', 1, 2),  /* ejemplo: Cliente 1, empleado 1, pago con tarjeta*/
(2, 4200.00, '2025-05-21', 2, 1),  
(3, 3500.00, '2024-07-22', 3, 3),  
(4, 6000.00, '2025-05-23', 4, 2),  
(5, 2900.00, '2024-08-24', 5, 1),
(6, 8000.00, '2025-05-25', 6, 2),
(7, 4500.00, '2023-09-26', 1, 3),
(8, 5500.00, '2025-05-27', 2, 1),
(9, 7000.00, '2024-03-28', 3, 2),
(10, 3100.00, '2025-05-29', 4, 3); 

/*Tablas importadas*/
insert into producto(name_product,description,precio,stock_dispo,Id_cat)
values
/*Baker*/
('Tabla Baker 8.0"', 'Tabla Baker profesional 8.0 pulgadas con lija incluida', 4000, 5, 1),
('Tabla Baker 8.25"', 'Tabla Baker 8.25 pulgadas con lija incluida', 4000, 4, 1),
('Tabla Baker 8.33"', 'Tabla Baker 8.33 pulgadas con lija incluida', 4000, 3, 1),
('Tabla Baker 8.5"', 'Tabla Baker 8.5 pulgadas con lija incluida', 4000, 2, 1),

/*Primitive*/
('Tabla Primitive 8.0"', 'Tabla Primitive 8.0 pulgadas con lija incluida', 3800, 5, 1),
('Tabla Primitive 8.25"', 'Tabla Primitive 8.25 pulgadas con lija incluida', 3800, 4, 1),
('Tabla Primitive 8.33"', 'Tabla Primitive 8.33 pulgadas con lija incluida', 3800, 3, 1),
('Tabla Primitive 8.5"', 'Tabla Primitive 8.5 pulgadas con lija incluida', 3800, 2, 1),

/*Real*/
('Tabla Real 8.0"', 'Tabla Real 8.0 pulgadas con lija incluida', 3900, 5, 1),
('Tabla Real 8.25"', 'Tabla Real 8.25 pulgadas con lija incluida', 3900, 4, 1),
('Tabla Real 8.33"', 'Tabla Real 8.33 pulgadas con lija incluida', 3900, 3, 1),
('Tabla Real 8.5"', 'Tabla Real 8.5 pulgadas con lija incluida', 3900, 2, 1),

/*Flip*/
('Tabla Flip 8.0"', 'Tabla Flip 8.0 pulgadas con lija incluida', 4000, 5, 1),
('Tabla Flip 8.25"', 'Tabla Flip 8.25 pulgadas con lija incluida', 4000, 4, 1),
('Tabla Flip 8.33"', 'Tabla Flip 8.33 pulgadas con lija incluida', 4000, 3, 1),
('Tabla Flip 8.5"', 'Tabla Flip 8.5 pulgadas con lija incluida', 4000, 2, 1),

/*Zero*/
('Tabla Zero 8.0"', 'Tabla Zero 8.0 pulgadas con lija incluida', 3500, 5, 1),
('Tabla Zero 8.25"', 'Tabla Zero 8.25 pulgadas con lija incluida', 3500, 4, 1),
('Tabla Zero 8.33"', 'Tabla Zero 8.33 pulgadas con lija incluida', 3500, 3, 1),
('Tabla Zero 8.5"', 'Tabla Zero 8.5 pulgadas con lija incluida', 3500, 2, 1),

/*April*/
('Tabla April 8.0"', 'Tabla April 8.0 pulgadas con lija incluida', 4200, 5, 1),
('Tabla April 8.25"', 'Tabla April 8.25 pulgadas con lija incluida', 4200, 4, 1),
('Tabla April 8.33"', 'Tabla April 8.33 pulgadas con lija incluida', 4200, 3, 1),
('Tabla April 8.5"', 'Tabla April 8.5 pulgadas con lija incluida', 4200, 2, 1);


/*Tablas nacionales*/
INSERT INTO Producto (name_product,description,precio,stock_dispo,Id_cat)
VALUES 
 /*Play Skateboarding*/
('Tabla Play Skateboards 8.0"', 'Tabla Play Skateboards 8.0 pulgadas 100% uruguayo con lija incluida', 2900, 5, 2),
('Tabla Play Skateboards 8.25"', 'Tabla Play Skateboards 8.25 pulgadas 100% uruguayo con lija incluida', 2900, 4, 2),
('Tabla Play Skateboards 8.33"', 'Tabla Play Skateboards 8.33 pulgadas 100% uruguayo con lija incluida', 2900, 3, 2),
('Tabla Play Skateboards 8.5"', 'Tabla Play Skateboards 8.5 pulgadas 100% uruguayo con lija incluida', 2900, 2, 2);


/*Kids*/
INSERT INTO Producto (name_product,description,precio,stock_dispo,Id_cat)
VALUES 
/*kids element*/
('Tabla Element Kids 7.75"', 'Tabla Element Kids 7.75 pulgadas, ideal para niños, con lija incluida', 2200, 10, 3);


/*trucks*/
insert into producto (name_product,description,precio,stock_dispo,Id_cat)
values
/* Independent Trucks*/
('Truck Independent 139', 'Truck Independent medida 139mm, ideal para tablas entre 7.75” y 8.25”', 4000, 10, 4),
('Truck Independent 149', 'Truck Independent medida 149mm, ideal para tablas de 8.25” a 8.5”', 4000, 10, 4),
('Truck Independent 159', 'Truck Independent medida 159mm, ideal para tablas de 8.5” a 8.75”', 4000, 10, 4),

/* ACE Trucks*/
('Truck ACE 139', 'Truck ACE Classic 139mm, estabilidad y control para tablas de 7.75” a 8.25”', 3500, 10, 4),
('Truck ACE 149', 'Truck ACE Classic 149mm, ideal para tablas de 8.25” a 8.5”', 3500, 10, 4),
('Truck ACE 159', 'Truck ACE Classic 159mm, perfecto para tablas de 8.5” a 8.75”', 3500, 10, 4);

/*Ruedas*/
insert into producto (name_product,description,precio,stock_dispo,Id_cat)
values
/*Spitfire Wheels*/
('Ruedas Spitfire Formula Four 99D 52mm', 'Ruedas Spitfire Formula Four 99D, 52mm, dureza 99A, ideales para skatepark y calle', 2000, 10, 5),
('Ruedas Spitfire Formula Four 101D 54mm', 'Ruedas Spitfire Formula Four 101D, 54mm, dureza 101A, para velocidad y control', 2000, 10, 5),

/*Bones Wheels*/
('Ruedas Bones STF V5 52mm 99A', 'Ruedas Bones STF V5, 52mm, dureza 99A, excelente para calle y skatepark', 1900, 10, 5),
('Ruedas Bones STF V5 54mm 103A', 'Ruedas Bones STF V5, 54mm, dureza 103A, para velocidad y resistencia', 2300, 10, 5);



insert into producto (name_product,description,precio,stock_dispo,Id_cat)
values
/*Thrasher*/
('Camiseta Thrasher Flame', 'Camiseta de manga corta con estampa Flame de Thrasher, 100% algodón', 1850, 15, 6),
('Buzo Thrasher Skate Magazine', 'Buzo con capucha de Thrasher, diseño clásico Skate Magazine', 2500, 10, 6),

/*Delivery Buenos Aires*/
('Camiseta Delivery Buenos Aires', 'Camiseta de manga corta con diseño exclusivo Delivery Buenos Aires', 1999, 10, 6),
('Buzo Delivery Buenos Aires', 'Buzo con capucha de Delivery Buenos Aires, diseño urbano', 2999, 8, 6),

/*RVCA*/
('Camiseta RVCA Classic', 'Camiseta de manga corta RVCA con logo frontal', 1999, 12, 6),
('Buzo RVCA Balance', 'Buzo con capucha RVCA, diseño Balance', 2500, 10, 6),

/*Planeta Skateshop (Nacional)*/
('Camiseta Planeta Skateshop', 'Camiseta de manga corta Planeta Skateshop, diseño exclusivo', 1500, 20, 6),
('Buzo Planeta Skateshop', 'Buzo con capucha Planeta Skateshop, diseño nacional', 1500, 15, 6);

/*Pantalones Levi’s*/
('Pantalón Levi’s 501 Original', 'Pantalón Levi’s modelo 501, corte recto clásico, denim resistente', 3000, 8, 6),
('Pantalón Levi’s Skateboarding Work Pant', 'Pantalón Levi’s para skate, modelo Work Pant con refuerzos y estilo urbano', 3000, 6, 6),

/*Pantalones Vans*/
('Pantalón Vans Authentic Chino', 'Pantalón Vans modelo Authentic Chino, diseño versátil para skate y uso diario', 2500, 10, 6),
('Pantalón Vans Range Relaxed Elastic', 'Pantalón Vans modelo Range Relaxed, cómodo y elástico, ideal para moverse', 2500, 10, 6);


insert into producto (name_product,description,precio,stock_dispo,Id_cat)
values
/*Rulemanes*/
('Rulemanes Shake Junt Abec 7', 'Rulemanes Shake Junt Abec 7, buena velocidad y durabilidad para skate callejero', 500, 15, 7),

/*Lijas*/
('Lija Mob Grip Classic', 'Lija Mob Grip clásica, gran adherencia y resistencia, tamaño estándar', 600, 20, 7),

/*Tornillos*/
('Tornillos Independent 1"', 'Set de tornillos Independent de 1", incluye llave Allen y colores mixtos', 450, 25, 7),
('Tornillos ACE 7/8"', 'Set de tornillos ACE de 7/8", resistente y ligero, incluye llave Allen', 400, 25, 7);


insert into producto (name_product,description,precio,stock_dispo,Id_cat)
values
/*Vans*/
('Zapatillas Vans Old Skool', 'Zapatillas Vans modelo Old Skool, clásico diseño de skate, talles 40 a 45', 3490, 10, 8),

/*Converse*/
('Zapatillas Converse One Star Pro', 'Zapatillas Converse One Star Pro Academy, ideales para skate, talles 40 a 45', 3580, 10, 8),
('Zapatillas Converse OX Casual', 'Zapatillas Converse OX, estilo urbano y versátil, talles 40 a 45', 2890, 12, 8),

/*New Balance*/
('Zapatillas New Balance 440', 'Zapatillas New Balance 440, modelo retro con soporte moderno, talles 40 a 45', 4300, 8, 8),

/*Nike*/
('Zapatillas Nike SB Dunk Low', 'Zapatillas Nike SB Dunk Low, diseño clásico y duradero, talles 40 a 45', 4500, 6, 8),

/*Adidas*/
('Zapatillas Adidas Stan Smith', 'Zapatillas Adidas Stan Smith, diseño clásico, ideal para uso diario, talles 40 a 45', 3500, 12, 8);




insert into metodo_pago(tipo_pago)
values
('efectivo'),
('tarjeta'),
('transferencia');


insert into empleados (nombre,rol,email,clave)
values
('Lucas Pereira', 'vendedor', 'lucas.pereira@planeta.com', 'lucas123'),
('Ana Rodríguez', 'vendedor', 'ana.rodriguez@planeta.com', 'ana123'),
('Santiago Díaz', 'Administrador', 'santiago.diaz@planeta.com', 'admin123'),
('Carlos Martínez', 'vendedor', 'carlos.martinez@planeta.com', 'carlos123'),
('Elena Gómez', 'vendedor', 'elena.gomez@planeta.com', 'elena123'),
('José Fernández', 'Administrador', 'jose.fernandez@planeta.com', 'jose123');



insert into direcciones(id_cliente,direccion,departamento,barrio,nombre_casa,piso_depto)
values 
(1, 'Av. 18 de Julio 123', 'Montevideo', 'Centro', 'Casa de Juan', '2do Piso'),
(2, 'Rambla República del Perú 456', 'Montevideo', 'Pocitos', 'Apartamento 45', '1er Piso'),
(3, 'Calle Gorlero 789', 'Maldonado', 'Centro', 'Casa de Carlos', 'N/A'),
(4, 'Camino Maldonado 321', 'Montevideo', 'La Comercial', 'Casa de Lucía', 'Planta Baja'),
(5, 'Ruta Interbalnearia Km 110', 'Maldonado', 'Punta del Este', 'Casa de Alex', 'N/A'),
(6, 'Av. Italia 654', 'Montevideo', 'La Blanqueada', 'Departamento 15', '5to Piso'),
(7, 'Av. Roosevelt 202', 'Maldonado', 'Punta Ballena', 'Casa de Diego', 'Planta Baja'),
(8, 'Bvar. Artigas 888', 'Montevideo', 'La Teja', 'Casa de Valentina', 'N/A'),
(9, 'Calle 20 y 27', 'Maldonado', 'Punta del Este', 'Casa de Tomás', '1er Piso'),
(10, 'Av. Rivera 4040', 'Montevideo', 'Cordon', 'Departamento 20', '4to Piso');


insert into detalle_ventas (Id_venta,Id_product,Cant,P_unitario,Sub)
values
(1, 1, 1, 4000, 4000),
(1, 2, 2, 3800, 7600),
(2, 3, 1, 3900, 3900),
(2, 4, 2, 4200, 8400),
(3, 5, 1, 3500, 3500),
(3, 6, 3, 4200, 12600),
(4, 7, 1, 3500, 3500),
(4, 8, 2, 3800, 7600),
(5, 9, 1, 4000, 4000),
(5, 10, 2, 3900, 7800),
(6, 11, 1, 3500, 3500),
(6, 12, 2, 3500, 7000),
(7, 13, 1, 4000, 4000),
(7, 14, 2, 4200, 8400),
(8, 15, 1, 3500, 3500),
(8, 16, 2, 3800, 7600),
(9, 17, 1, 4000, 4000),
(9, 18, 2, 3800, 7600),
(10, 19, 1, 4000, 4000),
(10, 20, 2, 3800, 7600);


insert into Clientes (Nombre,Last_Name,Email,Direct,Phone,Sexo,Fecha_Registro)
values
('Juan', 'Pérez', 'juan.perez@example.com', 'Av. 18 de Julio 123, Montevideo', '+59891234567', 'Masculino', '2023-06-10'),
('María', 'Gómez', 'maria.gomez@example.com', 'Rambla República del Perú 456, Montevideo', '+59892345678', 'Femenino', '2023-09-15'),
('Carlos', 'Rodríguez', 'carlos.rod@example.com', 'Calle Gorlero 789, Punta del Este', '+59893456789', 'Masculino', '2024-01-20'),
('Lucía', 'Fernández', 'lucia.fernandez@example.com', 'Camino Maldonado 321, Montevideo', '+59894567890', 'Femenino', '2024-04-05'),
('Alex', 'Martínez', 'alex.martinez@example.com', 'Ruta Interbalnearia Km 110, Punta del Este', '+59895678901', 'Otro', '2024-07-25'),
('Sofía', 'López', 'sofia.lopez@example.com', 'Av. Italia 654, Montevideo', '+59896789012', 'Femenino', '2024-11-30'),
('Diego', 'Silva', 'diego.silva@example.com', 'Av. Roosevelt 202, Punta del Este', '+59897890123', 'Masculino', '2025-01-18'),
('Valentina', 'Ruiz', 'valentina.ruiz@example.com', 'Bvar. Artigas 888, Montevideo', '+59898901234', 'Femenino', '2025-02-22'),
('Tomás', 'Acosta', 'tomas.acosta@example.com', 'Calle 20 y 27, Punta del Este', '+59899012345', 'Masculino', '2025-03-10'),
('Camila', 'Torres', 'camila.torres@example.com', 'Av. Rivera 4040, Montevideo', '+59890123456', 'Femenino', '2025-05-01');

