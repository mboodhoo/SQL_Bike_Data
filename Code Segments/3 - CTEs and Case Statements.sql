-- Common Table Expressions and Case Statements

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
