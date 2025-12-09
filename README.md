📊 Layoffs Data Cleaning Project (MySQL)

This project focuses on cleaning and standardizing a layoffs dataset using MySQL.
It demonstrates real data-cleaning techniques used in data analytics and data engineering.

🔧 Tech Stack

MySQL

SQL Window Functions

CTEs

Data Cleaning & Standardization Concepts

🧹 Project Tasks Done
1. Created Staging Tables

Duplicated raw dataset into layoffs_staging and layoffs_staging2.

Preserved original data for safe processing.

2. Removed Duplicates

Used:

ROW_NUMBER()

CTE (WITH clause)

This identified and removed duplicate records.

3. Standardized Data

Performed:

Trimming spaces from company names

Fixing inconsistent industry names (e.g., “Crypto%”)

Cleaning country names (e.g., removed trailing dots)

Converting date strings to proper DATE datatype

4. Handling Null & Missing Values

Converted blank strings to NULL

Used self-join to fill missing industry values

Removed records where both total_laid_off and percentage_laid_off were completely missing

5. Final Clean Table

Produced a fully cleaned version of the dataset ready for:

Analysis

Visualization

Dashboard creation



📌 Key Skills Shown

SQL Data Cleaning

Using Window Functions

Handling NULL values

Data Standardization

Removing Duplicates

Working with Staging Tables
