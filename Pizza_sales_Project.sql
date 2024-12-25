CREATE DATABASE pizzahut;

CREATE TABLE orders (
order_id int NOT NULL,
order_date date NOT NULL,
order_time time NOT NULL,
primary key (order_id)
);

CREATE TABLE orders_details (
order_details_id int NOT NULL,
order_id int NOT NULL,
pizza_id text NOT NULL,
quantity int NOT NULL,
primary key (order_details_id)
);

-- BASIC
-- Q1 Retrieve the total number of orders placed.

SELECT * FROM orders;
SELECT count(order_id) AS total_orders FROM orders;

-- Q2 Calculate the total revenue generated from pizza sales.

SELECT ROUND(SUM(orders_details.quantity * pizzas.price),2) AS total_sales
FROM orders_details JOIN pizzas 
ON pizzas.pizza_id = orders_details.pizza_id;

-- Q3 Identify the highest-priced pizza.

SELECT pizza_types.name, pizzas.price
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC limit 1;

-- Q4 Identify the most common pizza size ordered.

SELECT pizzas.size, COUNT(orders_details.order_details_id) AS order_count
FROM pizzas JOIN orders_details
ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- Q5 List the top 5 most ordered pizza types along with their quantities.

SELECT pizza_types.name, SUM(orders_details.quantity) AS Quantity
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details 
ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Quantity DESC limit 5;

-- INTERMEDIATE
-- Q6 Join the necessary tables to find the total quantity of each pizza category ordered

SELECT pizza_types.category, SUM(orders_details.quantity) AS quantity
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details
ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Quantity DESC;

-- Q7 Determine the distribution of orders by hour of the day

SELECT HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM orders
GROUP BY HOUR(order_time);

-- Q8 Join relevant tables to find the category wise distribution of pizzas

SELECT category, COUNT(name) 
FROM pizza_types
GROUP BY category;

-- Q9 Group the orders by date and calculate the average number of pizzas ordered per day

SELECT ROUND(AVG(sum_quantity) ,0) AS avg_pizza_ordered_per_day
FROM
(SELECT orders.order_date, SUM(orders_details.quantity) AS sum_quantity
FROM orders JOIN orders_details
ON orders.order_id = orders_details.order_id
GROUP BY orders.order_date) AS order_quantity;

-- Q10 Determine the top 3 most ordered pizza types based on revenue

SELECT pizza_types.name, SUM(orders_details.quantity * pizzas.price) AS revenue
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details
ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC limit 3;

-- Q11 Calculate the percentage contribution of each pizza type to total revenue

SELECT pizza_types.category, ROUND(SUM(orders_details.quantity * pizzas.price) / (SELECT ROUND(SUM(orders_details.quantity * pizzas.price),2) AS total_sales
FROM orders_details JOIN pizzas 
ON pizzas.pizza_id = orders_details.pizza_id) * 100,2) AS revenue
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details
ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

-- Q12 Analyze the cumulative(har din) revenue generated over time.

-- 200 - 200
-- 300 - 500
-- 450 - 950
-- 250 - 1200

SELECT order_date, SUM(revenue)
over(order by order_date) AS cum_revenue
FROM
(SELECT orders.order_date, SUM(orders_details.quantity * pizzas.price) AS revenue 
FROM orders_details JOIN pizzas
ON orders_details.pizza_id = pizzas.pizza_id
JOIN orders
ON orders.order_id  = orders_details.order_id
GROUP BY orders.order_date) AS sales;

-- Q13 Determine the tp 3 most ordered pizza types based on revenue for each pizza category.

SELECT name, revenue
FROM
(SELECT category, name, revenue, 
rank() over(partition by category order by revenue DESC) AS rn
FROM
(SELECT pizza_types.category, pizza_types.name, SUM(orders_details.quantity * pizzas.price) AS revenue 
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details
ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category, pizza_types.name) AS a) AS b
WHERE rn <= 3;






