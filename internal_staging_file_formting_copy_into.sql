use warehouse ecommerce_wh;
use database db_ecommerce;

-- create file format for uploading csv
create or replace file format raw_schema.csv_format
type = 'csv'
field_delimiter = ','
skip_header = 1
empty_field_as_null = true;

-- create stage for raw customers
create or replace stage raw_schema.customers_stage;

-- create table for raw customers
create or replace table raw_schema.customers
(
    id int autoincrement primary key,
    first_name varchar(100) not null,
    last_name varchar(100),
    email varchar(100) unique,
    phone string unique,
    city varchar(50),
    country varchar(50),
    gender string,
    signup_date date
);

-- copy into from stage to raw customers
copy into raw_schema.customers 
from @raw_schema.customers_stage
file_format = (format_name=raw_schema.csv_format)
on_error = 'continue';

select * from raw_schema.customers;

-- create stage for raw category 
create or replace stage raw_schema.category_stage;

-- create table for raw category
create or replace table raw_schema.category
(
    id int primary key,
    category_name varchar(100)
);

-- copy into from stage to raw category
copy into raw_schema.category
from @raw_schema.category_stage
file_format = (format_name = raw_schema.csv_format)
on_error = 'continue';

select * from raw_schema.category;

-- create stage for raw products
create or replace stage raw_schema.products_stage;

-- create table for raw products
create or replace table raw_schema.products
(
    id int autoincrement primary key,
    category_id int references category(id),
    product_name varchar(100),
    sale_price number(10, 2),
    cost_price number(10, 2),
    stock_quantity int
);

-- copy into from stage to raw products
copy into raw_schema.products
from @raw_schema.products_stage
file_format = (format_name = raw_schema.csv_format)
on_error = 'continue';

select * from raw_schema.products;

-- create stage for raw orders
create or replace stage raw_schema.orders_stage;

-- create table for raw orders
create or replace table raw_schema.orders
(
    id int autoincrement primary key,
    customer_id int references customers(id),
    order_date date,
    order_status varchar(100)
);

-- copy into from stage to raw orders
copy into raw_schema.orders
from @raw_schema.orders_stage
file_format = (format_name = raw_schema.csv_format)
on_error = 'continue';

select * from raw_schema.orders;

-- create stage for raw order_items
create or replace stage raw_schema.order_items_stage;

-- create table for raw order_items
create or replace table raw_schema.order_items
(
    id int autoincrement primary key,
    order_id int references raw_schema.orders(id),
    product_id int references raw_schema.products(id),
    quantity int,
    unit_price number(10, 2),
    discounts number(10, 2)
);

-- copy into from stage to raw order_items
copy into raw_schema.order_items
from @raw_schema.order_items_stage
file_format = (format_name = raw_schema.csv_format)
on_error = 'continue';

select * from raw_schema.order_items;
