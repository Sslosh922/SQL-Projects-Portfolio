create table Orders (
Order_ID  varchar(30) primary key ,
Customer_ID varchar(30),
 Customer_Name VARCHAR(100),
 Email varchar(255),
Region text,
Loyalty_Level text,
Signup_Date date,
Last_Login date , 
Product_ID varchar(10),
Product_Name varchar(100),
Category text,
Sub_Category text,
Brand text ,
Quantity int ,
Unit_Price numeric(10,3),
Discount numeric(10,3),
Sales numeric(10,3),
Profit numeric(10,3),
Rating numeric(10,3),
Order_Date date ,
Payment_Mode text,
Delivery_Time int,
Returns int ,
Promo_Code varchar(20),
Website_Session_Time numeric(10,3),
Cart_Abandon_Flag int,
Stock_Level bigint,
Supplier varchar(20),
Tax numeric(10,2)
);

select * from orders limit 10;

-- 1.Find the top 10 products by total sales across all regions.
select product_name,
sum(sales) as total_sales
from orders
group by product_name
order by total_sales desc 
limit 10;

-- 2.Compute total revenue and profit per Category and Sub_Category, only forproducts with average rating > 4.

select sum(sales) as total_revenue, sum(profit) as total_profit, avg(rating) as avg_rating,
category , Sub_Category
from orders 
group by category , Sub_Category
having avg(rating) > 4;

--3.Find the month-over-month revenue growth for 2023–2024

with monthly_sales as (
select date_trunc('month' , order_date) as month,
sum(sales) as revenue
from orders
where order_date >= '2023-01-01' and
order_date < '2025-01-01'
group by date_trunc('month' , order_date)
)
select 
month , revenue,
lag(revenue) over (order by month) as previous_month,
round((revenue-lag(revenue) over (order by month))/lag(revenue) over (order by month) * 100,2) as monthly_growth
from monthly_sales
order by month;

-- 4. List products with highest profit margins, considering only products sold more than 50 units.

select product_name,
sum(profit) as total_profit,
sum(sales) as total_Sales,
sum(quantity) as total_units,
round(sum(profit)/sum(sales)*100,2) as profit_margin
from orders
group by product_name
having sum(quantity) > 50
order by  profit_margin desc 
limit 10;

-- 5.Calculate year-over-year revenue change per Category, using a subquery to fetch previous year sales.

select
category,yearly,revenue,previous_year,revenue-previous_year as revenue_change
from (
select category, 
date_trunc('year' , order_date) as yearly,
sum(sales) as revenue,
lag(sum(sales)) over (partition by category
order by date_trunc('year' , order_date)) as previous_year
from orders 
group by category ,date_trunc('year' , order_date)
) as yearly_sales
order by category , yearly;

-- 6. Identify repeat customers (≥3 orders) in 2024

select count(order_id) , customer_id
from orders
where order_date between '2024-01-01'   and '2024-12-31'
group by customer_id
having count(order_id) >= 3
order by count(order_id) desc
limit 20;

--7.Calculate average revenue per customer by Loyalty_Level, excluding customers with returns > 2.
select 
customer_id,Loyalty_Level,avg(total_revenue) as avg_rvenue
from (
select 
customer_id ,
Loyalty_Level,
sum(sales) as total_revenue,
sum(returns) as total_returns
from orders 
group by customer_id,Loyalty_Level
having sum(returns) < 2
) as customer_sales
group by Loyalty_Level,customer_id
limit 10;


-- 8.Find the top 10 customers by total profit, including their most frequently purchased category (use a subquery).

select
customer_id,
sum(profit) as total_profit,
(select category
from orders o2
 where o2.customer_id = o1.customer_id
group by category
order by count(*) desc
limit 1
) as frequent_category
from orders o1
group by customer_id
order by total_profit desc
limit 10;


-- 9.Identify customers with highest return rates per region.

select customer_id,
region , sum(returns) as total_returns,
round(sum(returns)*100/count(order_id), 2) as return_rate
from orders
group by region,customer_id
order by return_rate desc;

 -- 10 .List customers who have purchased at least one product from each category, using correlated subqueries.

select distinct customer_id
from orders o1
where not exists (
select 1
from orders o2
where not exists (
select 1
from orders o3
 where o3.customer_id = o1.customer_id
  and o3.category = o2.category
    )
);

-- 11. Find all products sold with discount > 15% and quantity > 3
select * from orders limit 10;

select product_name,product_id
from orders
where discount > 0.15 and quantity > 3;

-- 12.Compute total sales per Promo_Code, excluding the top 2 promo codes by usage(subquery).

select promo_code,
sum(sales) as total_sales
from orders
where promo_code not in (
select promo_code 
from orders
group by promo_code
order by count(promo_code) desc
limit 2
)
group by promo_code;


--13.dentify products with discount higher than the average discount per category.

select 
product_name , category , avg(discount) as avg_discount
from orders o1
where discount > (
 select avg(discount) as avg_discount
 from orders o2
 where o2.category = o1.category
 )
group by category,product_name
limit 10;

-- 14.List products with high discount but below-average sales per category.
select 
product_name , category
from orders o1
where discount > (
select 
 avg(discount) as avg_discount
 from orders o2
  where o2.category = o1.category
 )
 and sales <(
 select avg(sales) as avg_sales
 from orders o3
 where o3.category = o1.category
 )
group by category,product_name
limit 10;

-- 15.Find promo codes contributing to the top 20% revenue, using nested queries

select promo_code, sum(sales) as total_revenue
from orders
where promo_code in (
select promo_code
from orders
group by promo_code
order by sum(sales) desc
limit ( 
select count(distinct promo_code) * 0.20
from orders
)
)
group by promo_code
order by total_revenue desc;

-- 16.Calculate return rate (%) per Category, excluding products with <10 sales

select * from orders limit 10;

select   category,
sum(returns)/count(returns) * 100 as return_rate 
from orders
where  product_name in 
(
select product_name
from orders
group by product_name
having sum(quantity) > 10 
)
group by category;


-- 17.Find the average delivery time per region for orders that were returned.

select 
region  , avg(delivery_time)
from orders
where returns >= 1
group by region;

-- 18. List orders returned within 7 days of purchase, including customer loyalty level.

select loyalty_level,
order_date , returns,
order_date + interval '7 days' as seven_days
from orders
where returns >= 1;

-- 19.  Identify products with the highest return frequency, using a correlated subquery

select product_name
,
(
select sum(returns)
from orders o2
where o2.product_name = o1.product_name
)as return_frequeny
from orders o1
group by product_name
order by return_frequeny desc;

-- 20 .Find regions with return rate above the average return rate (nested query).

select region,
return_rate
from 
(
select region,
sum(returns) * 100.0 / count(returns)  as  return_rate
from orders
group by region
) as t1
where return_rate  > 
(
select
sum(returns)*100.0 / count(returns)
from orders
);

--21.Find top 5 brands by revenue per category, using window functions.
select category,brand,revenue,rank
from (
select category,brand,
sum(sales) as revenue,
dense_rank() over (
partition by category
order by sum(sales) desc
) as rank
from orders
group by category, brand
) as t1
where rank <= 5
order by category, rank;

-- 22. List customers who purchased multiple products in a single order
select order_id,
customer_id,
count(distinct product_name) as product_count
from orders
group by order_id, customer_id
having count(distinct product_name) > 1;

-- 23.Compute cumulative revenue per month, ordered by month, using a window function.
select 
clm , revenue,
sum(revenue) over (order by clm) as clumative_revenue
from (
select 
date_trunc('month' , order_date)as clm,
sum(sales) as revenue	
from orders
group by date_trunc('month' , order_date)
) as t1 
order by clm;

--24.Rank products by sales and profit per category using ROW_NUMBER() or RANK().
select category , product_name,
sum(sales) as revenue,
sum(profit) as profit,
rank() over (partition by category
order by sum(sales)) as sales_rank,
rank () over (partition by category order by
sum(profit))as profit_rank
from orders
group by category ,product_name
order by sales_rank,profit_rank desc limit 10;

--25.Identify customers with no purchases in the last 6 months, using subquery.

select
customer_id,customer_name,
max(order_date) as last_purch
from orders
group by customer_id, customer_name
having max(order_date) < (
select max(order_date) - interval '6 months'
from orders
);

-- 26.List orders where profit < 10% of sales, including product and customer info.

select 
customer_id , customer_name,
product_id , product_name,
sales,profit
from orders
where profit < sales*0.10;

-- 27.Find top 10 products contributing 80% of total sales (Pareto analysis using cumulative sum).

select *
from(
select
product_name,total_sales,
sum(total_sales)over(order by total_sales desc) as cumulative_sales,
sum(total_sales) over() as overall_sales
from(select product_name, sum(sales) as total_sales
from orders
group by product_name
)t                                      --idea was was same took little help of  chatgpt
)x
where cumulative_sales<=overall_sales*0.80
order by total_sales desc limit 10;


-- 28. List orders with discount above the average discount for that sub-category

select 
order_id ,discount,sub_category
from orders o1
where discount > 
(
select 
sum(discount)/ count(*) 
from orders  o2
where o2.sub_category = o1.sub_category
);

-- 29.Identify customers who used multiple promo codes, showing number of distinct promo codes

select
customer_name,
count(distinct promo_code) as promo_code_count
from orders
group by customer_name
having count(distinct promo_code)>1;

-- 30.List product pairs frequently bought together (self-join and count).

select o1.product_name  as product1,
o2.product_name as p2,
count(*) as bought
from orders o1
join orders o2
on o1.order_id = o2.order_id
where o1.product_name < o1.product_name
group by o1.product_name,o2.product_name
order by count(*) desc

-- 31. Find orders where sales are higher than the average sales for that customer (correlated subquery).
	
select 
customer_name,
order_id
from
orders o1
where sales > (
select avg(sales)
from orders o2
where o2.customer_id = o1.customer_id
);

-- 32.Identify customers who purchased both Electronics and Fashion products
select *  from orders limit 10;

select customer_id,
customer_name
from orders
where category  in ('Electronics' , 'Fashion')
group by customer_id , customer_name
having count(distinct category) = 2;

-- 33. List products never returned, using a subquery

select product_name
from orders
where product_name not in  (
select product_name
from orders
where returns = 1
limit 10
);


-- 34.  Identify customers with maximum orders per region, using RANK() and partition

select
 region,customer_id,customer_name,order_count,rank
from(
select region,customer_id,customer_name,
count(order_id) as order_count,
rank() over(partition by region order by count(order_id) desc
 )as rank
from orders
group by region, customer_id, customer_name
)as t
where rank=1
order by region;


--35.List top 3 products per region by revenue (window function with partition).
select
 region,product_id,product_name,rank
from(
select region,product_id,product_name,
rank() over(partition by region order by sum(sales) desc
 )as rank
from orders
group by region, product_id, product_name
)as t
where rank<=3
order by region;

-- 36. Find products with highest average rating per brand, using subquery
select * from orders limit 10;
select product_id , product_name,brand
from (
select product_id ,product_name, brand,
avg(rating),
rank () over(partition by brand order by avg(rating))as rank
 from orders
 group by product_id,brand,product_name
) as t
where rank =1;

-- 37.Compare total sales between online (Credit/Debit/UPI) and COD payments
select * from orders limit 10;

select
case
when payment_mode in ('Credit Card', 'Debit Card', 'UPI','Net Banking') then 'Online'
when payment_mode = 'Cash on Delivery' then 'COD'
end as payment_type,
sum(sales) as total_sales
from orders
group by payment_type
order by total_sales desc;

-- 38.Calculate total profit per supplier, excluding suppliers with average stock < 50.

select 
supplier,
sum(profit)
from orders
 group by supplier
having avg(stock_level) > 50

select 
supplier,
total_profit
from  (
select supplier,
sum(profit) as total_profit,
avg(stock_level) as avg_stock
from orders
group by supplier
) as t
where avg_stock > 50;

-- 39.List customers with more than 2 cart abandonments, including their last login date

select * from orders limit 10;

select customer_id , customer_name ,max(last_login) as last_login
from orders 
group by customer_id,customer_name,last_login
 having sum(cart_abandon_flag) > 2;


--40 .Identify top 5% orders contributing to total revenue, using window functions and cumulative sum.
select 
order_id ,product_id,product_name,sales,
cimulative_sales
from 
(
select order_id ,product_id,product_name,sales ,
sum(sales) over (order by sales desc ) as cimulative_sales
from orders 
)t
order by sales desc 
limit 500;
