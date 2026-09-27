SQL
Overview

This directory contains the PostgreSQL scripts used to transform the Olist source data into a clean analytical environment and produce business-oriented analytical outputs.

The SQL work is organized so that the project can be reviewed as a reproducible data-management and analytics workflow rather than as a collection of unrelated queries.

Planned SQL Workflow
01_create_clean_schema.sql
        |
        v
02_eda_queries.sql
        |
        v
03_kpi_queries.sql
        |
        v
04_mart_build.sql
SQL Files
01_create_clean_schema.sql

Creates and prepares the cleaned 2017 analytical environment.

Primary responsibilities include:

Creating analytical schema objects
Filtering the current analytical scope to 2017
Standardizing important fields and data types
Integrating related Olist tables
Preparing reusable analytical tables
Supporting key and relationship validation
Creating indexes where appropriate
Preparing the database for subsequent analysis
02_eda_queries.sql

Contains exploratory SQL used to understand the analytical dataset.

Examples include:

Record counts
Date coverage
Order status
Missing values
Order activity
Product activity
Seller activity
Customer activity
Review-score distributions
Delivery-performance exploration
03_kpi_queries.sql

Contains business-oriented KPI calculations.

Planned KPI areas include:

Order volume
Order value
Average order value
Items per order
Delivery performance
Customer review scores
Product activity
Seller activity
Cancellation activity
04_mart_build.sql

Will contain SQL used to create reusable analytical marts or reporting-oriented structures after the core KPIs and business requirements have been validated.

Design Principles

The SQL in this repository is intended to demonstrate:

Reproducibility
Clear transformation logic
Relational data modeling
Data-quality awareness
Appropriate use of joins
Aggregation and KPI development
Readable and maintainable SQL
Business-oriented analytical thinking

Each production portfolio script should contain comments explaining the purpose of major transformations rather than documenting every individual SQL statement.

Database Architecture
olist_raw
    |
    v
stage_olist
    |
    v
clean_2017
    |
    v
Analytics / KPI Layer

The separation between raw, staging, and analytical data supports traceability and prevents analytical transformations from altering the original source data.

Project Status

The SQL portion of the project is currently under active development.

The first major repository deliverable will be:

01_create_clean_schema.sql
