# Olist-Enterprise-Data-Decision-Analytics-In-Progress
End-to-End Data Management, SQL, Python, and Decision Analytics Portfolio Project

Project Overview

This project uses the Brazilian Olist e-commerce dataset to demonstrate an end-to-end approach to enterprise data management and decision analytics.

The objective is not simply to analyze an existing CSV file. The project is designed to show how raw operational data can be assessed, organized, cleaned, modeled, queried, analyzed, and transformed into information that supports business decisions.

The project combines:

Data quality assessment
PostgreSQL database development
Raw, staging, and clean data layers
Data integration
Relational data modeling
SQL analytics
KPI development
Python-based analysis
Statistical reasoning
Business intelligence concepts
Decision-oriented recommendations
Technical and business documentation

The project is being developed as a professional portfolio case study demonstrating the relationship between trusted enterprise data, analytical methods, and effective decision-making.

Business Objective

E-commerce organizations generate data across customers, orders, products, sellers, payments, reviews, and delivery operations.

The primary objective of this project is to organize those separate data sources into a reliable analytical environment capable of answering business questions such as:

How is order activity changing over time?
What factors contribute to order value and customer experience?
Which products and sellers contribute most to business activity?
Where are delivery or fulfillment problems occurring?
How do customer review scores relate to operational performance?
Which data-quality issues could affect reporting or decision-making?
What KPIs should management monitor?
What actions could management take based on the analytical evidence?

The final objective is to move beyond descriptive reporting and produce decision-oriented findings and recommendations.

Data Management Approach

The project uses a layered PostgreSQL architecture to separate source data from transformed analytical data.

Raw Source Data
      │
      ▼
olist_raw
      │
      ▼
stage_olist
      │
      ▼
clean_2017
      │
      ▼
Analytics / KPI Layer
      │
      ▼
Decision Analysis

Raw Layer — olist_raw

Preserves source data in a form close to the original datasets.

Purpose:

Maintain source-data integrity
Preserve traceability
Support reproducibility
Separate ingestion from transformation
Staging Layer — stage_olist

Provides an intermediate environment for:

Data-type validation
Standardization
Initial transformations
Data-quality assessment
Join preparation
Identification of missing, duplicate, or inconsistent data
Clean Analytical Layer — clean_2017

Contains the cleaned and integrated 2017 analytical dataset used for KPI development and subsequent analysis.

This separation follows enterprise data-management principles by maintaining clear boundaries between source, transformation, and analytical data.

Current Data Scope

The current analytical scope focuses on 2017 Olist e-commerce activity.

The working analytical dataset currently contains approximately:

MetricCurrent Scope	
Order-line records	50,864
Distinct orders	44,579
Customers	43,225
Sellers	1,784
Products	17,273

These figures represent the current project dataset and may be refined as additional validation and modeling work is completed.

Planned Analytical Areas
Revenue and Order Analysis
Order volume
Order value
Average order value
Items per order
Monthly trends
Order status
Customer Experience
Review scores
Delivery performance
Cancellations
Customer purchasing behavior
Potential relationships between operational performance and customer satisfaction
Product Analysis
Product activity
Product-category performance
Order contribution
Sales concentration
Seller Analysis
Seller activity
Seller contribution
Fulfillment performance
Seller concentration
Data Quality
Missing values
Duplicate records
Key integrity
Invalid or inconsistent values
Referential relationships
Fitness of data for analytical use
Decision Analytics

The project will progressively move from:

What happened?
      ↓
Why did it happen?
      ↓
What patterns matter?
      ↓
What uncertainty exists?
      ↓
What should the business do?


The final portfolio deliverables will emphasize business decisions and recommendations, rather than presenting dashboards or statistical outputs without interpretation.

Technology Stack
Database
PostgreSQL
SQL
Analytics
Python
pandas
NumPy
Statistical analysis
Development
Jupyter Notebook
Anaconda
Git
GitHub
Documentation
Markdown
Data dictionaries
Data-model documentation
Methodology documentation
Business findings

Additional analytical and visualization tools may be incorporated as the project develops.

Planned Repository Structure
olist-enterprise-data-decision-analytics/
│
├── README.md
│
├── data/
│   └── README.md
│
├── sql/
│   ├── 01_create_clean_schema.sql
│   ├── 02_eda_queries.sql
│   ├── 03_kpi_queries.sql
│   └── 04_mart_build.sql
│
├── notebooks/
│   ├── 01_data_quality_analysis.ipynb
│   ├── 02_exploratory_analysis.ipynb
│   ├── 03_statistical_analysis.ipynb
│   └── 04_decision_analysis.ipynb
│
├── docs/
│   ├── methodology.md
│   ├── data_dictionary.md
│   ├── data_model_diagram.md
│   └── business_findings.md
│
├── images/
│   └── README.md
│
└── requirements.txt


The repository structure may evolve as the project progresses.

Portfolio Release 1.0

The first release will focus on five deliverables:

Data Management Architecture
Raw, staging, and clean-data workflow
Data-quality methodology
Source relationships
SQL Analytics
Exploratory queries
KPI queries
Analytical transformations
Data Model
Entity relationships
Analytical model
Documentation of important keys and relationships
Core Business KPIs
Order activity
Order value
Customer experience
Seller/product activity
Delivery performance
Business Findings
Three to five meaningful findings
Supporting analytical evidence
Decision-oriented recommendations
Future Development

After the core data-management and decision-analytics components are complete, later project releases may incorporate:

Advanced statistical analysis
Bayesian analysis
Forecasting
Customer or seller segmentation
Automated analytical workflows
AI-assisted analytics
Generative AI for analytical summarization
Agentic analytical workflows
AI-ready data-management considerations

These additions will be incorporated only where they provide meaningful analytical value.

Professional Skills Demonstrated

This project is intended to demonstrate practical capabilities relevant to:

Senior Data Analyst
Decision Analyst
Enterprise Data Analyst
Data Management Specialist
Data Governance Analyst
Data Quality Analyst
Business Intelligence Analyst
Analytics Consultant
AI-Augmented Analytics roles

Core competencies demonstrated include:

SQL | PostgreSQL | Python | Data Quality | Data Modeling | Data Integration | Data Management | KPI Development | Statistical Analysis | Business Intelligence | Decision Support | Technical Documentation

Project Philosophy

Reliable analytics begins with reliable data.

This project therefore treats data management and analytics as one continuous process rather than separate activities.

The objective is to demonstrate how well-managed data can be transformed into reproducible analytical evidence and ultimately into better-informed business decisions.

Author

Stanley E. Guinn
M.S. Data Analytics

Data & Decision Analytics | Enterprise Data Management | SQL | Python | PostgreSQL | Business Intelligence | AI-Augmented Analytics


