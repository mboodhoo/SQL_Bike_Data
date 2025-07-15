-- Window Functions

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