"""Скрипт для заполнения данными таблиц в БД Postgres."""
import psycopg2
import os
import csv
codecs = ["1", "2", "3"]
pass_word = input("Введите пароль для соединения с  PostgreSQL\n")
conn_params = {
    "host": "localhost",
    "database": "north",
    "user": "postgres",
    "password": pass_word
}
while codecs != []:
    while True:
        code = input("Введите номер файла\n1.customers_data.csv\n2.employees_data.csv\n3.orders_data.csv\n")
        try:
            code in codecs
            break
        except ValueError:
            print("Ошибка: введите корректное число")
    with psycopg2.connect(**conn_params) as conn:
        if code == "1":
            codecs.remove("1")
            file_path = os.path.abspath("north_data/customers_data.csv")
            with conn.cursor() as cur:
                with open(file_path, 'r', newline='', encoding='windows-1251') as csvfile:
                    reader = csv.DictReader(csvfile)
                    for line in reader:
                        cur.execute("INSERT INTO customers VALUES (%s,%s,%s)",
                                    (line['customer_id'], line['company_name'], line['contact_name']))

        elif code == "2":
            codecs.remove("2")
            file_path = os.path.abspath("north_data/employees_data.csv")
            with conn.cursor() as cur:
                with open(file_path, 'r', newline='', encoding='windows-1251') as csvfile:
                    reader = csv.DictReader(csvfile)
                    for line in reader:
                        cur.execute("INSERT INTO employees VALUES (%s,%s,%s,%s,%s,%s)",
                        (int(line['employee_id']), line['first_name'], line['last_name'],
                        line['title'], line['birth_date'], line['notes']))
        else:
            codecs.remove("3")
            file_path = os.path.abspath("north_data/orders_data.csv")
            with conn.cursor() as cur:
                with open(file_path, 'r', newline='', encoding='windows-1251') as csvfile:
                    reader = csv.DictReader(csvfile)
                    for line in reader:
                        cur.execute("INSERT INTO orders VALUES (%s,%s,%s, %s,%s)",
                        (int(line['order_id']), line['customer_id'], int(line['employee_id']),
                         line['order_date'], line['ship_city']))

print("Ввод данных в БД завершен")
