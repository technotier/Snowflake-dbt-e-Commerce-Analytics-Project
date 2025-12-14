-- Create Warehouse
CREATE OR REPLACE WAREHOUSE ecommerce_wh
WAREHOUSE_SIZE = 'X-SMALL'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE
INITIALLY_SUSPENDED = TRUE
COMMENT = 'Main warehouse for e-commerce data processing';

use warehouse ecommerce_wh;

-- create database 
create or replace database db_ecommerce;
use db_ecommerce;

-- create schema
create or replace schema raw_schema;
create or replace schema cleaned_schema;
create or replace schema analytics_schema;
create or replace schema reports_schema;

