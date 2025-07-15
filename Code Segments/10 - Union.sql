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