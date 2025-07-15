-- Some Data Cleaning

/*
We will now move on to the products table
*/

select *
from production.products
;

/*
We notice that there is some redundant information. The product_name contains the model year information too.
However, we already have a model_year column. 
We will now perform a query to remove the model year from the product_name column.
*/

select product_name, 
trim(reverse(right(reverse(product_name), length(product_name) - locate('-', reverse(product_name)))))
	as product_name_updated
from production.products
;

/*
I do not want to manipulate the raw data, so I will create a new table called products_updated, where I will make changes.
*/

drop table if exists production.products_updated;
create table production.products_updated
like products
;

select *
from production.products_updated
;

insert into production.products_updated
select *
from production.products
;

update production.products_updated
set product_name = trim(reverse(right(reverse(product_name), length(product_name) - locate('-', reverse(product_name)))))
;

select *
from production.products_updated
;