-- Crear tablas

CREATE TABLE `brands` (
    `brand_id` INT  NOT NULL ,
    `brand_name` VARCHAR(50)  NOT NULL ,
    PRIMARY KEY (
        `brand_id`));

CREATE TABLE `categories` (
    `category_id` INT  NOT NULL ,
    `category_name` VARCHAR(60)  NOT NULL ,
    PRIMARY KEY (
        `category_id`));

CREATE TABLE `customers` (
    `customer_id` INT  NOT NULL ,
    `first_name` VARCHAR(50)  NOT NULL ,
    `last_name` VARCHAR(50)  NOT NULL ,
    `phone` INT  NOT NULL ,
    `email` VARCHAR(100)  NOT NULL ,
    `street` VARCHAR(200)  NOT NULL ,
    `city` VARCHAR(100)  NOT NULL ,
    `state` TEXT  NOT NULL ,
    `zip_code` INT  NOT NULL ,
    PRIMARY KEY (
        `customer_id`));

CREATE TABLE `order_items` (
    `order_id` INT  NOT NULL ,
    `item_id` INT  NOT NULL ,
    `product_id` INT  NOT NULL ,
    `quantity` INT  NOT NULL ,
    `list_price` DOUBLE  NOT NULL ,
    `discount` DOUBLE  NOT NULL );

CREATE TABLE `orders` (
    `order_id` INT  NOT NULL ,
    `customer_id` INT  NOT NULL ,
    `order_status` INT  NOT NULL ,
    `order_date` INT  NOT NULL ,
    `required_date` INT  NOT NULL ,
    `shipped_date` INT  NOT NULL ,
    `store_id` INT  NOT NULL ,
    `staff_id` INT  NOT NULL ,
    PRIMARY KEY (
        `order_id`));

CREATE TABLE `products` (
    `product_id` INT  NOT NULL ,
    `product_name` VARCHAR(100)  NOT NULL ,
    `brad_id` INT  NOT NULL ,
    `category_id` INT  NOT NULL ,
    `model_year` INT  NOT NULL ,
    `list_price` DOUBLE  NOT NULL ,
    PRIMARY KEY (
        `product_id`));

CREATE TABLE `staff` (
    `staff_id` INT  NOT NULL ,
    `first_name` VARCHAR(50)  NOT NULL ,
    `last_name` VARCHAR(50)  NOT NULL ,
    `email` VARCHAR(100)  NOT NULL ,
    `phone` INT  NOT NULL ,
    `active` INT  NOT NULL ,
    `store_id` INT  NOT NULL ,
    `manager_id` INT  NOT NULL ,
    PRIMARY KEY (
        `staff_id`));

CREATE TABLE `stocks` (
    `store_id` INT  NOT NULL ,
    `product_id` INT  NOT NULL ,
    `quantity` INT  NOT NULL
    ) ;

CREATE TABLE `stores` (
    `store_id` INT  NOT NULL ,
    `store_name` VARCHAR(200)  NOT NULL ,
    `phone` INT  NOT NULL ,
    `email` VARCHAR(100)  NOT NULL ,
    `city` VARCHAR(100)  NOT NULL ,
    `state` TEXT  NOT NULL ,
    `zip_code` INT  NOT NULL ,
    PRIMARY KEY (
        `store_id`));


-- Relacionar las tablas

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_orders
FOREIGN KEY (order_id) REFERENCES orders(order_id);

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_products
FOREIGN KEY (product_id) REFERENCES products(product_id);

ALTER TABLE orders
ADD CONSTRAINT fk_customer_orders
FOREIGN KEY (customer_id) REFERENCES customers (customer_id);

ALTER TABLE orders
ADD CONSTRAINT fk_stores_orders
FOREIGN KEY (store_id) REFERENCES stores(store_id);

ALTER TABLE orders
ADD CONSTRAINT fk_staff_orders
FOREIGN KEY (staff_id) REFERENCES staff(staff_id);

ALTER TABLE products 
ADD CONSTRAINT fk_brands_products
FOREIGN KEY (brand_id) REFERENCES brands (brand_id);

ALTER TABLE products 
ADD CONSTRAINT fk_categories_products
FOREIGN KEY (category_id) REFERENCES categories (category_id);

ALTER TABLE staff
ADD CONSTRAINT fk_stores_staff
FOREIGN KEY (store_id) REFERENCES stores (store_id);

ALTER TABLE stocks
ADD CONSTRAINT fk_stores_stocks
FOREIGN KEY (store_id) REFERENCES stores (store_id);

ALTER TABLE stocks
ADD CONSTRAINT fk_products_stocks
FOREIGN KEY (product_id) REFERENCES products (product_id);

-- ARREGLOS
-- Arreglo #1
SELECT CONCAT(first_name," ",last_name) from customers;

ALTER TABLE customers 
ADD FullName VARCHAR(100);
UPDATE customers
SET FullName =  CONCAT(first_name," ",last_name);

-- Arreglo #2
SELECT order_date,required_date, shipped_date,
CASE 
	WHEN required_date = shipped_date THEN 'At Time'
    WHEN required_date < shipped_date THEN 'Late'
    WHEN required_date > shipped_date THEN 'Early'
    ELSE 'Never Arrive'
END AS ArrivalTime
FROM orders

ALTER TABLE orders
ADD ArrivalStatus VARCHAR(50);

ALTER TABLE orders 
CHANGE COLUMN `ArrivalStatus` `ShipmentStatus` VARCHAR(50) NULL DEFAULT NULL ; 

UPDATE orders
SET ShipmentStatus = CASE WHEN required_date = shipped_date THEN 'At Time'
    WHEN required_date < shipped_date THEN 'Late'
    WHEN required_date > shipped_date THEN 'Early'
    ELSE 'Not Registered'
	END;


-- ANALISIS VENTAS

SELECT 
o.order_id,
c.FullName,
c.email,
c.street,
c.city,
c.state,
oi.item_id,
oi.list_price,
oi.discount,
ROUND (oi.list_price-(oi.list_price*oi.discount)) as FinalPrice,
oi.quantity,
p.product_name,
b.brand_name,
ct.category_name,
s.store_name,
CONCAT(stf.first_name,' ',stf.last_name) as vendedor,
o.order_date,
o.shipped_date,
o.ShipmentStatus

FROM orders o
LEFT JOIN customers c ON (o.customer_id=c.customer_id)
LEFT JOIN order_items oi ON (o.order_id=oi.order_id)
LEFT JOIN products p ON (oi.product_id=p.product_id)
LEFT JOIN brands b ON (p.brand_id=b.brand_id)
LEFT JOIN categories ct ON (p.category_id=ct.category_id)
LEFT JOIN stores s ON (o.store_id=s.store_id)
LEFT JOIN staff stf ON (o.staff_id=stf.staff_id)
ORDER BY order_id;

-- ANALISIS ALMACEN

SELECT 
BD2.product_id,
BD2.product_name,
BD2.VentaTotal,
SUM(stock) as StockTotal,
SUM(stock) - BD2.VentaTotal as StockActual

from( 
SELECT
DB.product_id,
DB.product_name,
SUM(DB.venta) as VentaTotal,
DB.stock

from (
Select
oi.order_id,
sto.store_name,
sto.store_id,
p.product_id,
p.product_name,
oi.quantity as Venta,
st.quantity as Stock


FROM order_items oi
LEFT JOIN products p ON (oi.product_id=p.product_id)
LEFT JOIN stocks st ON (oi.product_id=st.product_id)
LEFT JOIN stores sto ON (st.store_id=sto.store_id)

GROUP BY
oi.order_id,
sto.store_name,
sto.store_id,
p.product_id,
p.product_name,
Venta,
Stock
ORDER BY 
product_id) DB
GROUP BY product_id,product_name, stock) BD2
RIGHT JOIN products p ON (BD2.product_id=p.product_id)
GROUP BY product_id, product_name,VentaTotal

