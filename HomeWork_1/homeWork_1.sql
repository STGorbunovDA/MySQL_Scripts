/*
Создайте таблицу с мобильными телефонами
*/
CREATE SCHEMA `phonesdb` ;

/*
Необходимые поля таблицы: product_name (название товара), manufacturer (производитель), product_count (количество), price (цена). 
*/
CREATE TABLE `phonesdb`.`phones` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `product_name` VARCHAR(45) NOT NULL,
  `manufacturer` VARCHAR(45) NOT NULL,
  `product_count` INT NOT NULL,
  `price` DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (`id`));
  
/*
Заполните БД произвольными данными
*/
INSERT INTO `phonesdb`.`phones` (`product_name`, `manufacturer`, `product_count`, `price`) VALUES ('x100', 'Samsung', '10', '1400.22');
INSERT INTO `phonesdb`.`phones` (`product_name`, `manufacturer`, `product_count`, `price`) VALUES ('8', 'Iphone', '10', '1400000.00');

/*
Напишите SELECT-запрос, который выводит название товара, производителя и цену для товаров, количество которых превышает 2
*/
SELECT product_name  FROM phonesdb.phones where product_count > 2;

/*
Выведите SELECT-запросом весь ассортимент товаров марки “samsung”
*/
SELECT id, product_name, manufacturer, product_count, price FROM phonesdb.phones where manufacturer = 'samsung';

/*
Товары, в которых есть упоминание "Iphone"
*/
SELECT id, product_name, manufacturer, product_count, price FROM phonesdb.phones WHERE manufacturer LIKE 'Iphone';
/*
Товары, в которых есть упоминание "Samsung"
*/
SELECT id, product_name, manufacturer, product_count,price FROM phonesdb.phones WHERE manufacturer LIKE 'samsung';
/*
Товары, в названии которых есть ЦИФРЫ
*/
SELECT id, product_name, manufacturer, product_count, price FROM phonesdb.phones WHERE REGEXP_LIKE(product_name, '^[[:digit:]]+$');
/*
Товары, в названии которых есть ЦИФРА "8"
*/
SELECT id, product_name, manufacturer, product_count, price FROM phonesdb.phones WHERE product_name LIKE '%8%';
