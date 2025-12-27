# Layoffs-Analysis-SQL
SQL Scripts for Cleaning and Analyzing Global Layoff Data

## Files

1. **layoffs_data_cleaning_query.sql**  
   - Removes duplicates and standardizes data  
   - Converts text dates to proper DATE format  
   - Handles NULL and blank values  
   - Creates a cleaned dataset (`layoffs_staging_2`)  

2. **layoffs_EDA_query.sql**  
   - Exploratory data analysis on the cleaned dataset  
   - Aggregates layoffs by company, year, and month  
   - Identifies top companies with layoffs  
   - Calculates rolling totals and rankings

---

## Dataset Schema (`layoffs_staging_2`)

| Column             | Data Type | Description |
|-------------------|-----------|------------|
| company           | TEXT      | Company name |
| location          | TEXT      | Office or city location |
| total_laid_off    | TEXT      | Number of employees laid off |
| date              | DATE      | Layoff date |
| percentage_laid_off | TEXT    | Percentage of workforce laid off |
| industry          | TEXT      | Company industry |
| source            | TEXT      | News or source of information |
| stage             | TEXT      | Company stage (Startup, Series A, etc.) |
| funds_raised      | INT       | Funds raised before layoffs |
| country           | TEXT      | Country of company |
| date_added        | DATE      | Date record was added |
  
## Skills Demonstrated

- Data cleaning and preprocessing with SQL  
- Aggregation, grouping, and ranking queries  
- Window functions (`ROW_NUMBER`, `DENSE_RANK`)  
- Date extraction and formatting  
- Handling real-world dataset inconsistencies  
