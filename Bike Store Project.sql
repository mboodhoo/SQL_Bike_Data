/*
SQL Bike Store Project
Author: Matthew Boodhoo
Data Obtained from:
	https://www.sqlservertutorial.net/getting-started/sql-server-sample-database/
    https://www.kaggle.com/datasets/dillonmyrick/bike-store-sample-database?select=staffs.csv
    
The syntax used to create the database was specific to SQL Server. However, I am using MySQL.
As such, I had to make minor adjustments to the database creation script to conform to MySQL syntax.
For example, changing IDENTITY(1,1) to AUTO_INCREMENT.
Also, the original create table statements included foreign keys linking various tables. I decided to remove these links to 
create my own links during the course of this project.
Also, I downloaded the csv formatted data from the second link to make inserting data into the tables easier.
I then used the Table Data Import Wizard to load the data into the respective tables. 

After the initial database and table setup, every query and action performed on this data is my own work.
*/

-- drop tables
DROP TABLE IF EXISTS sales.order_items;
DROP TABLE IF EXISTS sales.orders;
DROP TABLE IF EXISTS production.stocks;
DROP TABLE IF EXISTS production.products;
DROP TABLE IF EXISTS production.categories;
DROP TABLE IF EXISTS production.brands;
DROP TABLE IF EXISTS sales.customers;
DROP TABLE IF EXISTS sales.staffs;
DROP TABLE IF EXISTS sales.stores;

-- drop the schemas

DROP SCHEMA IF EXISTS sales;
DROP SCHEMA IF EXISTS production;

-- create schemas
CREATE SCHEMA production;

CREATE SCHEMA sales;

-- create tables
CREATE TABLE production.categories (
	category_id INT AUTO_INCREMENT PRIMARY KEY,
	category_name VARCHAR (255) NOT NULL
);

CREATE TABLE production.brands (
	brand_id INT AUTO_INCREMENT PRIMARY KEY,
	brand_name VARCHAR (255) NOT NULL
);

CREATE TABLE production.products (
	product_id INT AUTO_INCREMENT PRIMARY KEY,
	product_name VARCHAR (255) NOT NULL,
	brand_id INT NOT NULL,
	category_id INT NOT NULL,
	model_year SMALLINT NOT NULL,
	list_price DECIMAL (10, 2) NOT NULL
);

CREATE TABLE sales.customers (
	customer_id INT AUTO_INCREMENT PRIMARY KEY,
	first_name VARCHAR (255) NOT NULL,
	last_name VARCHAR (255) NOT NULL,
	phone VARCHAR (25),
	email VARCHAR (255) NOT NULL,
	street VARCHAR (255),
	city VARCHAR (50),
	state VARCHAR (25),
	zip_code VARCHAR (5)
);

CREATE TABLE sales.stores (
	store_id INT AUTO_INCREMENT PRIMARY KEY,
	store_name VARCHAR (255) NOT NULL,
	phone VARCHAR (25),
	email VARCHAR (255),
	street VARCHAR (255),
	city VARCHAR (255),
	state VARCHAR (10),
	zip_code VARCHAR (5)
);

CREATE TABLE sales.staffs (
	staff_id INT AUTO_INCREMENT PRIMARY KEY,
	first_name VARCHAR (50) NOT NULL,
	last_name VARCHAR (50) NOT NULL,
	email VARCHAR (255) NOT NULL UNIQUE,
	phone VARCHAR (25),
	`active` tinyint NOT NULL,
	store_id INT NOT NULL,
	manager_id INT
);

CREATE TABLE sales.orders (
	order_id INT AUTO_INCREMENT PRIMARY KEY,
	customer_id INT,
	order_status tinyint NOT NULL,
	-- Order status: 1 = Pending; 2 = Processing; 3 = Rejected; 4 = Completed
	order_date DATE NOT NULL,
	required_date DATE NOT NULL,
	shipped_date DATE,
	store_id INT NOT NULL,
	staff_id INT NOT NULL
);

CREATE TABLE sales.order_items (
	order_id INT,
	item_id INT,
	product_id INT NOT NULL,
	quantity INT NOT NULL,
	list_price DECIMAL (10, 2) NOT NULL,
	discount DECIMAL (4, 2) NOT NULL DEFAULT 0,
	PRIMARY KEY (order_id, item_id)
);

CREATE TABLE production.stocks (
	store_id INT,
	product_id INT,
	quantity INT,
	PRIMARY KEY (store_id, product_id)
);

/*
From this line onward is completely my own work 
*/


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

-- Case Statements
-- Determine if orders arrive on time or not
select order_id, required_date, shipped_date,
case
	when shipped_date <= required_date then 'On Time'
	else 'Late'
end as `Status`
from sales.orders
;

/*
We would now like to determine which stores deliver the most late orders.
Based on the order_status numbering, rejected orders (order_status = 3) should not be taken into account.
Also, rows where shipped_date is null should be removed, since we can't say whether they are late or not.
We will remove those rows,
We'll then determine Late status of the orders,
Filter out the on time orders,
Then count the number of late orders for each store.
*/

-- Common Table Expression
select * 
from sales.orders
;

select *
from sales.orders
where shipped_date is null
;

select *
from sales.orders
where shipped_date is not null and order_status = 3
;

-- Removing the null rows alone will remove all rejected orders as well.

with Remove_Null as
(
select *
from sales.orders
where shipped_date is not null
),
Determine_Status as
(
select order_id, order_status, order_date, required_date, shipped_date, store_id,
case
	when shipped_date <= required_date then 'On Time'
	else 'Late'
end as `Status`
from Remove_Null
),
Late_Status as
(
select *
from Determine_Status
where `Status` = 'Late'
)
select store_id, count(`Status`) as Number_Late
from Late_Status
group by store_id
;

/*
It seems as though store_id = 2 has the most late deliveries and store_id = 3 has the least. 
That being said it makes more sense to find the percentage of late deliveries from each store.
For example if store A has 100 late deliveries from a total of 1000 deliveries, that means a 10% late delivery rate.
However, if store B has 200 late deliveries from a total of 20000 deliveries, that means a 1% late delivery rate.
Store A has less late deliveries than store B, but a higher late delivery percentage.
*/

with Remove_Null as
(
select *
from sales.orders
where shipped_date is not null
),
Determine_Status as
(
select order_id, order_status, order_date, required_date, shipped_date, store_id,
case
	when shipped_date <= required_date then 'On Time'
	else 'Late'
end as `Status`
from Remove_Null
),
Total_Deliveries as
(
select store_id, count(`Status`) as Number_of_Deliveries
from Determine_Status
group by store_id
),
Late_Status as
(
select *
from Determine_Status
where `Status` = 'Late'
),
Late_Deliveries as
(
select store_id, count(`Status`) as Number_Late
from Late_Status
group by store_id
)
select LD.store_id, LD.Number_Late/TD.Number_of_Deliveries as Late_Percentage
from Late_Deliveries as LD
join Total_Deliveries as TD
on LD.store_id = TD.store_id
;

/*
From this we can see that store_id = 1 now has the largest late delivery percentage, while store_id = 3 still has
the lowest late delivery percentage. 
*/

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

/*
We would now like to rank the staff by total sales for each store.

It would make sense to work with only completed orders.
We need to join orders with order_items on order_id
*/

select *
from sales.staffs
;

select *
from sales.orders
;

select *
from sales.order_items
;

with Completed_Orders as
(
select *
from sales.orders
where order_status = 4
),
Join_orders_order_items as
(
select co.order_id, co.store_id, co.staff_id, oi.quantity, oi.list_price, oi.discount
from Completed_Orders as co
join sales.order_items as oi
	on co.order_id = oi.order_id
),
Selling_Price as
(
select store_id, staff_id, quantity, list_price, discount,
	round(quantity*list_price*(1 - discount), 2) as selling_price
from Join_orders_order_items
),
Categorize as
(
select store_id, staff_id, sum(selling_price) as Total_Sales
from Selling_Price
group by store_id, staff_id
)
select *, 
rank() over(partition by store_id order by Total_Sales desc) as Staff_Rank
from Categorize
;

/*
Also, we notice some staff are inactive, we will turn them inactive except top manager. 
Create duplicate table.
*/

drop table if exists sales.staffs_updated;
create table sales.staffs_updated
like sales.staffs
;

select * 
from sales.staffs_updated
;

insert into sales.staffs_updated
select *
from sales.staffs
;

update sales.staffs_updated
set `active` = 
(case
	when (staff_id in (select distinct staff_id from sales.orders)) or 
		 (manager_id is null) then 1
    else 0
end)
;

select * 
from sales.staffs_updated
;

-- We want to do a Stored Procedure where we return information about a staff member given their id.

use sales;
drop procedure if exists Staff_Info;

delimiter $$
create procedure Staff_Info (p_staff_id int)
begin
	declare is_active int;
    
    select `active` into is_active
    from sales.staffs_updated
    where staff_id = p_staff_id
    ;
    
    if is_active = 1 then
		select first_name, last_name, email, phone
        from sales.staffs_updated
        where staff_id = p_staff_id;
	else select 'No longer works here' as `Status`;
    end if;
end $$
delimiter ;

call Staff_Info(1);
call Staff_Info(4);

-- Trigger

drop table if exists sales.customers_updated;
create table sales.customers_updated
like sales.customers
;

select * 
from sales.customers_updated
;

insert into sales.customers_updated
select *
from sales.customers
;

drop table if exists sales.orders_updated;
create table sales.orders_updated
like sales.orders
;

select * 
from sales.orders_updated
;

insert into sales.orders_updated
select *
from sales.orders
;

drop table if exists sales.order_items_updated;
create table sales.order_items_updated
like sales.order_items
;

select * 
from sales.order_items_updated
;

insert into sales.order_items_updated
select *
from sales.order_items
;

select customer_id, count(customer_id) as cus_count
from sales.orders
group by customer_id
having cus_count > 1
;

-- Updating stock, creating a new copy of stocks table in production schema

drop table if exists production.stocks_updated;
create table production.stocks_updated
like production.stocks
;

select * 
from production.stocks_updated
;

insert into production.stocks_updated
select *
from production.stocks
;

-- Write a trigger to update stocks_updated table after update to orders_updated and order_items_updated tables

select *
from sales.orders_updated
order by order_id desc;

select *
from sales.order_items_updated
order by order_id desc;

use sales;
drop trigger if exists update_stock;

delimiter $$
create trigger update_stock
	after insert on sales.order_items_updated
    for each row
begin
	declare p_store_id int;
    
    select store_id into p_store_id
    from sales.orders_updated ou
    where ou.order_id = new.order_id
    ;
    
    update production.stocks_updated su
    set su.quantity = su.quantity - new.quantity
    where su.store_id = p_store_id and su.product_id = new.product_id
    ;
end $$
delimiter ;

insert into sales.orders_updated (customer_id, order_status, order_date, required_date, shipped_date, store_id, staff_id)
values (71, 1, '2018-12-30', '2019-01-02', null, 2, 3)
;

insert into sales.order_items_updated
values (1616, 1, 68, 1, 449.99, 0.10)
;

insert into sales.order_items_updated
values (1616, 2, 19, 2, 449, 0.05)
;

-- Original Stock
select *
from production.stocks
where (store_id = 2 and product_id = 68) or (store_id = 2 and product_id = 19)
;

-- Updated Stock
select *
from production.stocks_updated
where (store_id = 2 and product_id = 68) or (store_id = 2 and product_id = 19)
;

-- Views

drop view if exists active_staff;
create view active_staff as
select staff_id, first_name, last_name, store_id
from sales.staffs_updated
where `active` = 1
;

select *
from active_staff
;

-- Union

-- We want to label our customers as loyal if they return

select o.customer_id, c.first_name, c.last_name, count(o.customer_id) as amt_visits, 'Loyal' as Label
from sales.customers c, sales.orders o
where c.customer_id = o.customer_id
group by o.customer_id
having amt_visits > 1

union

select o.customer_id, c.first_name, c.last_name, count(o.customer_id) as amt_visits, 'Not Loyal Yet' as Label
from sales.customers c, sales.orders o
where c.customer_id = o.customer_id
group by o.customer_id
having amt_visits <= 1
order by customer_id
;

-- Verification

select customer_id, count(customer_id) as amt
from sales.orders
group by customer_id
order by customer_id
;
