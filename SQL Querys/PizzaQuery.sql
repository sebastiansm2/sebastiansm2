-- Creando Tablas

CREATE TABLE `orders_general` (
    `order_id` int  NOT NULL ,
    `date` date  NOT NULL ,
    `time` time  NOT NULL ,
    PRIMARY KEY (
        `order_id`
    )
);

CREATE TABLE `orders_details` (
    `order_detail` int  NOT NULL ,
    `order_id` int  NOT NULL ,
    `pizza_id` VARCHAR(50)  NOT NULL ,
    `quantity` int  NOT NULL ,
    PRIMARY KEY (
        `order_detail`
    )
);

CREATE TABLE `pizza_types` (
    `pizza_type_id` int  NOT NULL ,
    `name` VARCHAR(100)  NOT NULL ,
    `category` VARCHAR(80)  NOT NULL ,
    PRIMARY KEY (
        `pizza_type_id`
    )
);

CREATE TABLE `pizzas` (
    `pizza_id` VARCHAR(50)  NOT NULL ,
    `pizza_type_id` VARCHAR(30)  NOT NULL ,
    `size` text  NOT NULL ,
    `price` int  NOT NULL ,
    PRIMARY KEY (
        `pizza_id`
    )
);

CREATE TABLE `ingredients` (
    `ing_id` VARCHAR(10)  NOT NULL ,
    `ing_name` VARCHAR(100)  NOT NULL ,
    PRIMARY KEY (
        `ing_id`
    )
);

CREATE TABLE `recipe` (
    `row_id` INT  NOT NULL ,
    `recipe_id` VARCHAR(30)  NOT NULL ,
    `ing_id` VARCHAR(10)  NOT NULL ,
    PRIMARY KEY (
        `row_id`
    )
);

-- Relacionando Tablas

ALTER TABLE `orders_details` ADD CONSTRAINT `fk_orders_details_order_id` FOREIGN KEY(`order_id`)
REFERENCES `orders_general` (`order_id`);

ALTER TABLE `orders_details` ADD CONSTRAINT `fk_orders_details_pizza_id` FOREIGN KEY(`pizza_id`)
REFERENCES `pizzas` (`pizza_id`);

ALTER TABLE `pizzas` ADD CONSTRAINT `fk_pizzas_pizza_type_id` FOREIGN KEY(`pizza_type_id`)
REFERENCES `recipe` (`recipe_id`);

ALTER TABLE `recipe` ADD CONSTRAINT `fk_recipe_recipe_id` FOREIGN KEY(`recipe_id`)
REFERENCES `pizza_types` (`pizza_type_id`);

ALTER TABLE `recipe` ADD CONSTRAINT `fk_recipe_ing_id` FOREIGN KEY(`ing_id`)
REFERENCES `ingredients` (`ing_id`);


-- Analisis de Ventas
SELECT 
orders_general.order_id,
orders_general.date,
orders_general.time,
pizza_types.name,
pizzas.size,
pizzas.price,
pizza_types.category,
order_details.quantity

FROM order_details
LEFT JOIN orders_general ON order_details.order_id= orders_general.order_id
LEFT JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
LEFT JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
LIMIT 50000;

