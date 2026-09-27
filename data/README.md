Dataset Overview

This project uses the Brazilian Olist e-commerce dataset, which contains transactional and operational data related to customers, orders, order items, products, sellers, payments, reviews, and delivery activity.

The dataset is used to demonstrate an end-to-end enterprise data-management and decision-analytics workflow.

Repository Data Policy

The original raw Olist datasets are not stored directly in this GitHub repository.

This approach keeps the repository focused on:

SQL transformation logic
Data-quality processes
Analytical modeling
KPI development
Statistical analysis
Business findings
Reproducibility

The data/ directory is used for documentation describing the source data, analytical scope, and any derived datasets that may be appropriate for inclusion in the project.

Data Architecture

The PostgreSQL environment follows a layered structure:

Raw Olist Source Data
        |
        v
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
        |
        v
Decision Analysis
olist_raw

Contains source data loaded with minimal modification.

Purpose:

Preserve source structure
Maintain traceability
Support reproducibility
Separate ingestion from transformation
stage_olist

Intermediate layer used for:

Data-type validation
Standardization
Initial data cleaning
Missing-value assessment
Duplicate detection
Relationship validation
Join preparation
clean_2017

Contains the cleaned and integrated analytical dataset used for the current portfolio analysis.

The first project release focuses primarily on Olist activity occurring during calendar year 2017.

Current Analytical Scope

The current working 2017 dataset contains approximately:

Metric	Current Scope
Order-line records	50,864
Distinct orders	44,579
Customers	43,225
Sellers	1,784
Products	17,273

These values represent the current working analytical environment and may be refined as additional validation is completed.

Major Source Domains

The Olist dataset includes information related to:

Customers
Orders
Order items
Products
Sellers
Payments
Customer reviews
Product categories
Delivery activity

These datasets are integrated through relational keys to create analytical datasets suitable for business reporting and decision analysis.

Reproducibility

SQL scripts used to create and analyze the PostgreSQL environment are stored in the repository's sql/ directory.

Python-based validation, statistical analysis, and decision analysis will be stored in the notebooks/ directory.

Detailed methodol
