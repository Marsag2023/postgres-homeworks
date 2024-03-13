-- Напишите запросы, которые выводят следующую информацию:
-- 1. Название компании заказчика (company_name из табл. customers) и ФИО сотрудника, работающего над заказом этой компании (см таблицу employees),
-- когда и заказчик и сотрудник зарегистрированы в городе London, а доставку заказа ведет компания United Package (company_name в табл shippers)
SELECT c.company_name customer,  (e.first_name || ' '|| e.last_name)  employee FROM employees e
JOIN orders o USING(employee_id)
JOIN customers c USING(customer_id)
WHERE e.city = 'London' AND c.city ='London'
AND o.ship_via =(SELECT shipper_id FROM shippers  s WHERE s.company_name ='United Package')

-- 2. Наименование продукта, количество товара (product_name и units_in_stock в табл products),
-- имя поставщика и его телефон (contact_name и phone в табл suppliers) для таких продуктов,
-- которые не сняты с продажи (поле discontinued) и которых меньше 25 и которые в категориях Dairy Products и Condiments.
-- Отсортировать результат по возрастанию количества оставшегося товара.
SELECT p.product_name, p.units_in_stock,  s.contact_name, s.phone from products p
JOIN suppliers s USING(supplier_id)
WHERE  p.discontinued = 0 AND p.units_in_stock < 25
and (p.category_id = (SELECT category_id from categories c where c.category_name ='Dairy Products')
or p.category_id = (SELECT category_id from categories c where c.category_name ='Condiments'))
ORDER BY units_in_stock

-- 3. Список компаний заказчиков (company_name из табл customers), не сделавших ни одного заказа
SELECT company_name  from customers c
LEFT JOIN orders USING(customer_id)
WHERE NOT EXISTS(SELECT * from orders o WHERE o.customer_id = c.customer_id)
ORDER BY company_name

-- 4. уникальные названия продуктов, которых заказано ровно 10 единиц (количество заказанных единиц см в колонке quantity табл order_details)
-- Этот запрос написать именно с использованием подзапроса.
SELECT DISTINCT product_name  from products p
WHERE  p.product_id IN (SELECT product_id from order_details od WHERE od.quantity =10)
ORDER BY  product_name