-- Trigger

-- Creating copies of tables used in Trigger

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