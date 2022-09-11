# Nashville Houses Data Cleaning with SQL Server

A SQL data cleaning project using the Nashville housing dataset.
The following task completed for this project:

-> Standardized date format using CAST and updated the table.
    
-> By using a JOIN, populated the PropertyAddress fields where the value is NULL.

-> Broken out PropertyAddress and OwnerAddress fields into individual columns using SUBSTRING and PARSENAME functions.
    
-> Changing Y and N to Yes and No in the SoldAsVacant field using CASE statement.
    
-> Removed Duplicates using ROW_NUMBER, PARTITION BY, and CTE.
 
-> Deleted a few unused fields using the DROP command.
