# Snowflake-dbt-e-Commerce-Analytics-Project
Analytics engineering project showcasing Snowflake ingestion, dbt transformations, star-schema modeling, and business insights.

# Snowflake + dbt Analytics Project

## 📌 Overview
This project demonstrates an end-to-end modern data stack using **Snowflake** and **dbt**.
Raw CSV data is ingested into Snowflake, transformed using dbt, and modeled into analytics-
ready tables for reporting and business insights.

## 🏗️ Architecture
- Source: CSV files
- Warehouse: Snowflake
- Transformation: dbt
- Modeling: Star Schema
- Layers:
  - raw_schema
  - staging_schema
  - cleaned_schema
  - analytics_schema
  - report_schema

## 📂 Data Models
### Raw Tables
- customers
- categories
- products
- orders
- order_items

### Staging
- Transfer all tables with data exactly in raw tables

### Cleaned
- Standardized column names
- Type casting
- Light transformations

### Analytics
- Dimensions & Facts
- KPI-ready tables
- Feature engineering
- Aggregations

dbt run
dbt test
