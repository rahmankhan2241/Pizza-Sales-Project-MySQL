-- Retrieve Total number of orders 
select count(*) as TotalOrders
from order_details;

--  Calculate the total revenue generated from pizza sales
select 
  round(sum(quantity * price)) as revenue 
from 
  pizzas as t1 
  join order_details as t2 on t1.pizza_id = t2.pizza_id;

-- Identify the highest priced pizza by it's name
select 
  name,  price 
from 
  pizzas as t1 
  join pizza_types as t2 on t1.pizza_type_id = t2.pizza_type_id 
order by price desc limit 1;

-- Identify what size of pizza is being order most
select size, count(order_id) as orders from pizzas as t1
join order_details as t2 
on t1.pizza_id = t2.pizza_id
group by size
order by orders desc limit 1;

-- List Top 5 most ordered Pizzas (name) along with their quantity
select name, sum(quantity) as Quantity from pizzas as t1
join pizza_types as t2
on t1.pizza_type_id = t2.pizza_type_id
join order_details as t3 on 
t1.pizza_id = t3.pizza_id
group by name
order by Quantity desc limit 5;

-- Find the Total Revenue generated per pizza category
select category, round(sum(quantity * price)) as revenue
from pizzas as t1
join pizza_types as t2
on t1.pizza_type_id = t2.pizza_type_id
join order_details as t3 on 
t1.pizza_id = t3.pizza_id
group by category
order by revenue desc;

-- Distribute the orders of pizza on the basis of hours
-- Change the hours into 12 hours clock with  AM and PM except 24 hours clock

select 
Case
 when hour(order_time) < 12 then concat(hour(order_time) , " AM")
 when hour(order_time) = 12 then concat(12 , " PM")
 when hour(order_time) > 12 then concat(hour(order_time) - 12 , " PM")
end as hours, count(*) as orders
from orders
group by hours order by orders desc;

-- Calculate the average orders and average generated revenue of pizza per day
SELECT 
    AVG(qty) AS avg_qty, AVG(revenue) AS avg_revenue
FROM
    (SELECT 
        order_date,
            SUM(quantity) AS qty,
            SUM(quantity * price) AS revenue
    FROM
        orders AS t1
    JOIN order_details AS t2 ON t1.order_id = t2.order_id
    JOIN pizzas AS t3 ON t2.pizza_id = t3.pizza_id
    GROUP BY order_date) AS main_table;
    
    
-- Calculate the percentage distribution of each pizza (name) to the total revenue
with revenue_per_pizza as (select name , sum(price* quantity) as revenue from pizzas as t1
join pizza_types as t2
on t1.pizza_type_id = t2.pizza_type_id
join order_details as t3
on t1.pizza_id = t3.pizza_id
group by name),
total_revenue as
(
	select sum(price * quantity) as tot_rev
    from pizzas as t1 join order_details as t2
    on t1.pizza_id = t2.pizza_id
)
select name, round(revenue/tot_rev * 100, 2) as prcntge_dst from revenue_per_pizza, total_revenue
order by prcntge_dst desc;

-- Analyze the Cumulative sales over months
select order_date ,qty,  sum(qty) over(order by order_date) as cumulative_sales
from 
(select order_date, sum(quantity) as qty
from orders as t1 join order_details as t2
on t1.order_id = t2.order_id
group by order_date)
as t;


-- Determine Top 3 most ordered pizza along with it's catgory and generated revenue
select Category, name, orders, revenue from
(
select *, 
rank() over(partition by category order by orders desc) as rnk
from 
	(
	select category , name , count(order_id) as orders, sum(price* quantity) as revenue from pizzas as t1
	join pizza_types as t2
	on t1.pizza_type_id = t2.pizza_type_id
	join order_details as t3 on t1.pizza_id = t3.pizza_id
	group by category , name
	) as T1
) as T2
where rnk <= 3;

-- Identify those dates where the placed orders exceed the average placed order_value
select order_date , orders from
(
select *, avg(orders) over() as avg_orders
from 
	(select order_date, count(*) as orders
	from orders as t1
	join order_details as t2
	on t1.order_id = t2.order_id
	group by order_date)
    as T1)
as T2
where orders > avg_orders;

-- Determine those Order_id's where the order was placed for
-- more than 2 unique type of pizza 
select * from (
	select order_id , count(distinct(pizza_id)) as unique_pizzas_order
	from order_details
	group by order_id
) as T1
where unique_pizzas_order > 2;





