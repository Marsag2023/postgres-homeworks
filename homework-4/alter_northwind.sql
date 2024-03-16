-- Подключиться к БД Northwind и сделать следующие изменения:
-- 1. Добавить ограничение на поле unit_price таблицы products (цена должна быть больше 0)
ALTER TABLE products ADD CONSTRAINT chk_products_unit_price CHECK (unit_price >0)

-- 2. Добавить ограничение, что поле discontinued таблицы products может содержать только значения 0 или 1
ALTER TABLE products ADD CONSTRAINT chk_products_discontinued CHECK (discontinued IN (0, 1))

-- 3. Создать новую таблицу, содержащую все продукты, снятые с продажи (discontinued = 1)
SELECT * INTO discontinued_products FROM products WHERE discontinued = 1

-- 4. Удалить из products товары, снятые с продажи (discontinued = 1)
-- Для 4-го пункта может потребоваться удаление ограничения, связанного с foreign_key. Подумайте, как это можно решить, чтобы связь с таблицей order_details все же осталась.
ALTER TABLE order_details DROP CONSTRAINT fk_order_details_products;
ALTER TABLE order_details ADD CONSTRAINT fk_order_details_products
FOREIGN KEY(product_id) REFERENCES products(product_id) ON DELETE CASCADE;
DELETE FROM products WHERE discontinued = 1;
-- Возвращаем значение внешнего ключа без DELETE CASCADE, для безопасности данных
ALTER TABLE order_details DROP CONSTRAINT fk_order_details_products;
ALTER TABLE order_details ADD CONSTRAINT fk_order_details_products
FOREIGN KEY(product_id) REFERENCES products(product_id)
-- ИЛИ

ALTER TABLE order_details DROP CONSTRAINT fk_order_details_products;
DELETE FROM products WHERE discontinued = 1;
DELETE FROM order_details WHERE product_id NOT IN (SELECT product_id FROM products);
DELETE FROM orders WHERE order_id NOT IN (SELECT order_id FROM order_details);
ALTER TABLE order_details ADD CONSTRAINT fk_order_details_products
FOREIGN KEY(product_id) REFERENCES products(product_id);

-- Создаем временную таблицу для хранения идентификаторов товаров, которые нужно удалить
CREATE TEMPORARY TABLE temp_deleted_products AS
SELECT  FROM products WHERE discontinued = 1;

-- Обновляем ключ в таблице order_details до временной таблицы
ALTER TABLE order_details DROP CONSTRAINT fk_order_details_products;

UPDATE order_details
SET product_id = NULL
WHERE product_id IN (SELECT product_id FROM temp_deleted_products);

-- Удаляем товары из таблицы products
DELETE FROM products
WHERE product_id IN (SELECT product_id FROM temp_deleted_products);

-- Восстанавливаем первоначальный внешний ключ в таблице order_details
ALTER TABLE order_details
ADD CONSTRAINT fk_order_details_products
FOREIGN KEY (product_id) REFERENCES products(product_id);

-- Удаляем временную таблицу
DROP TABLE temp_deleted_products;