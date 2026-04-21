# StreamVibe — User Behavior Analysis (SQL)

## Project Overview
StreamVibe is a Netflix-style streaming platform database project.
This project involves data cleaning and user behavior analysis 
using MySQL on a dataset of 6000+ rows across 4 tables.

## Tools Used
- MySQL
- MySQL Workbench

## Database Schema
4 tables:
- users — user profiles and subscription details
- content — movies and TV shows information
- watch_history — what users watched and how much
- user_reviews — ratings and reviews given by users

## Data Cleaning Steps Performed
1. Removed duplicate rows using ROW_NUMBER() and MIN(row_id)
2. Handled missing values using NULL and default replacements
3. Standardized date formats from 3 formats to YYYY-MM-DD using REGEXP
4. Converted all VARCHAR columns to proper data types (INT, DATE, DECIMAL)

## Business Questions Answered
1. What are the top 5 most watched genres?
2. Which subscription plan has the most users and what is their average age?
3. Which country has the highest average watch percentage?
4. What are the top 10 highest rated content based on user reviews?
5. Which device is most used and what is average watch duration per device?
6. How many users joined every year and which year had most signups?
7. What percentage of content is Movies vs TV Shows?
8. Which genre has the highest average IMDB score?
9. What is the drop off rate for each genre?
10. Which users are most engaged based on watch count and percentage?
11. Which country gives the highest average ratings?

## Key SQL Concepts Used
- JOINS (INNER JOIN across multiple tables)
- GROUP BY and HAVING
- Aggregate functions (COUNT, AVG, SUM, ROUND)
- Window functions (ROW_NUMBER, RANK, PARTITION BY)
- Subqueries
- CASE WHEN
- REGEXP for pattern matching
- STR_TO_DATE for date standardization
- ALTER TABLE for data type conversion

## Dataset
- Self generated synthetic dataset simulating Netflix style platform
- 4 tables with 6000+ rows total
- Intentionally made dirty for cleaning practice
