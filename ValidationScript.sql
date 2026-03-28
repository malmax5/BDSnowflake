select 
    'Raw Staging' as source,
    count(*) as totalRows,
    sum(sale_quantity) as totalQuantity,
    sum(sale_total_price) as totalRevenue
from raw_data

union all

select 
    'Snowflake Model' as source,
    count(*) as totalRows,
    sum(quantity) as totalQuantity,
    sum(totalPrice) as totalRevenue
from FactSales;
