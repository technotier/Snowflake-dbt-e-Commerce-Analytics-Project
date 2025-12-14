snowflake-dbt-analytics/
│
├── README.md
├── LICENSE
├── .gitignore
│
├── profiles.yml.example
│
├── dbt_project.yml
├── packages.yml
│
├── macros/
│   └── custom_schema_name.sql
│
├── models/
│   ├── staging/
│   │   ├── stg_customers.sql
│   │   ├── stg_category.sql
│   │   ├── stg_products.sql
│   │   ├── stg_orders.sql
│   │   ├── stg_order_items.sql
│   │
│   ├── cleaned/
│   │   ├── cleaned_customers.sql
│   │   ├── cleaned_products.sql
│   │   ├── cleaned_category.sql
│   │   ├── cleaned_orders.sql
│	│	├── cleaned_order_items.sql
│   │
│   ├── analytics/
│   │   ├── dim_customers.sql
│   │   ├── dim_date.sql
│   │   ├── dim_products.sql
		├── fact_sales.sql
│   │
│   └── reporting/
│       ├── executive_dashboard_view.sql
│		├── customers_analytics_view.sql
│		├── product_performance_view.sql
	│
│   └── sources.yml
│
├── snapshots/
│   └──
│
├── tests/
│   └── rel
│
└── docs/
    ├── architecture.png
    └── data_flow.md
