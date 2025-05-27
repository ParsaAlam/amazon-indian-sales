USE[Amazon Sales];
GO
SELECT
TOP 10*FROM amazon_orders

SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_NAME = 'amazon_orders';
SELECT DISTINCT Sales_Channel
FROM amazon_orders

Select 
[index],Order_ID,[Date],[Status],Fulfilment,Sales_Channel,ship_service_level,Style,SKU,Category,Size,[ASIN],Courier_Status,Qty,currency,Amount,ship_city,ship_state,ship_postal_code,ship_country,promotion_ids,B2B,fulfilled_by,Unnamed_22,
count(*)
From amazon_orders
 Group by [index],Order_ID,[Date],[Status],Fulfilment,Sales_Channel,ship_service_level,Style,SKU,Category,Size,[ASIN],Courier_Status,Qty,currency,Amount,ship_city,ship_state,ship_postal_code,ship_country,promotion_ids,B2B,fulfilled_by,Unnamed_22
 having count(*)>1
---------------------------------Find Null Values----------------------------------------------
DECLARE @SQL NVARCHAR(MAX);

set @SQL = 'SELECT ';

SELECT @SQL = @SQL + 
    'SUM(CASE WHEN [' + COLUMN_NAME + '] IS NULL THEN 1 ELSE 0 END) AS [' + COLUMN_NAME + '], '
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'amazon_orders';

-- Remove the last comma and space
SET @SQL = LEFT(@SQL, LEN(@SQL) - 1);

SET @SQL = @SQL + ' FROM amazon_orders;';

-- Optional: print for debugging
PRINT @SQL;

-- Execute the dynamic SQL
EXEC sp_executesql @SQL;

DECLARE @findDuplicate NVARCHAR(MAX);

-- Start building the dynamic SQL query
SET @findDuplicate = 'SELECT ';

-- Dynamically get all column names from the table and append to @findDuplicate
SELECT @findDuplicate = @findDuplicate + 
    CASE 
        WHEN COLUMN_NAME = 'index' THEN '[index] AS Index_Column, '  -- Enclose index in brackets and rename
        WHEN COLUMN_NAME = 'Date' THEN 'Date AS Order_Date, '         -- Rename Date but keep original name
        WHEN COLUMN_NAME = 'Status' THEN 'Status AS Order_Status, '   -- Rename Status but keep original name
        WHEN COLUMN_NAME = 'Unnamed_22' THEN NULL  -- Omit Unnamed_22
        ELSE COLUMN_NAME + ', ' 
    END
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'amazon_orders'
ORDER BY ORDINAL_POSITION;

-- Remove the last comma and space (from the SELECT clause)
SET @findDuplicate = LEFT(@findDuplicate, LEN(@findDuplicate) - 1);  -- Use LEN(@findDuplicate) - 1

-- Continue building the dynamic SQL to group by all original columns and check for duplicates
SET @findDuplicate = @findDuplicate + ', COUNT(*) AS DuplicateCount FROM dbo.amazon_orders GROUP BY ';

-- Add the original column names again for the GROUP BY clause, excluding Unnamed_22
SELECT @findDuplicate = @findDuplicate + 
    CASE 
        WHEN COLUMN_NAME = 'index' THEN '[index], '  -- Enclose index in brackets
        WHEN COLUMN_NAME = 'Date' THEN 'Date, '       -- Use original Date
        WHEN COLUMN_NAME = 'Status' THEN 'Status, '   -- Use original Status
        WHEN COLUMN_NAME = 'Unnamed_22' THEN NULL     -- Omit Unnamed_22
        ELSE COLUMN_NAME + ', ' 
    END
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'amazon_orders'
ORDER BY ORDINAL_POSITION;
-- Remove the last comma and space (from the GROUP BY clause)
SET @findDuplicate = LEFT(@findDuplicate, LEN(@findDuplicate) - 1);  -- Use LEN(@findDuplicate) - 1

-- Add the HAVING clause to filter duplicates
SET @findDuplicate = @findDuplicate + ' HAVING COUNT(*) > 1;';

-- Print the dynamic query (for debugging)
PRINT @findDuplicate;

-- Execute the dynamic SQL
EXEC sp_executesql @findDuplicate;
select distinct [Date]
from amazon_orders
order by [Date]

-----Server name--------------
SELECT @@SERVERNAME AS 'Server Name';

Select distinct [Status],fulfilled_by
FROM amazon_orders

UPDATE dbo.amazon_orders
Set Amount =0
Where Amount IS NULL;

UPDATE dbo.amazon_orders
Set ship_city ='unknown'
Where ship_city IS NULL;


UPDATE dbo.amazon_orders
Set ship_state ='unknown'
Where ship_state IS NULL;


UPDATE dbo.amazon_orders
Set ship_postal_code =-1
Where ship_postal_code IS NULL;


UPDATE dbo.amazon_orders
Set Courier_Status ='unknown'
Where Courier_Status IS NULL;

ALTER TABLE amazon_orders
ADD B2B_Status Varchar(10);

ALTER TABLE amazon_orders
ALTER COLUMN B2B Varchar(10);

UPDATE dbo.amazon_orders
Set B2B =CASE
When B2B =1 then 'buisness'
Else 'customer'
END;

SELECT B2B
FROM amazon_orders
group by B2B

ALTER TABLE dbo.amazon_orders
DROP COLUMN B2B_Status,Unnamed_22,fulfilled_by;


