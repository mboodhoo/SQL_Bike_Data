-- Simple Select, filtering, ordering and aggregation statements

-- Select and From
select *
from production.brands;

select *
from sales.stores;

-- Distinct
select distinct model_year
from production.products
;

-- Various where clauses
select *
from production.products
where model_year > 2017
;

select *
from sales.customers
where (phone is not null) and (state = 'NY')
;

select min(order_date), max(order_date)
from sales.orders
;

select order_id, order_status, order_date
from sales.orders
where order_date between '2017-01-01' and '2017-12-31'
;

select *
from sales.customers
where first_name like 'Ma%'
;

-- Order by and Group by
select *
from production.products
order by list_price desc
;

select model_year, avg(list_price) as avg_list_price
from production.products
group by model_year
;

select brand_id, avg(list_price) as avg_list_price
from production.products
group by brand_id
order by avg_list_price desc
;

select brand_id, model_year, avg(list_price) as avg_list_price
from production.products
group by brand_id, model_year
order by brand_id, model_year
;

select brand_id, model_year, avg(list_price) as avg_list_price
from production.products
group by brand_id, model_year
having avg_list_price > 1000
order by brand_id, model_year
;

-- Limit
select *
from sales.staffs
;

select *
from sales.staffs
limit 3
;

select *
from sales.staffs
limit 3, 2
;