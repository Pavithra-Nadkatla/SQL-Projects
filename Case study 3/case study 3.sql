Customers/ customer_id | name | email | country
Orders/ order_id | customer_id | order_date | total_amount
Order_Items/ order_id | product_id | quantity | unit_price
Products/ product_id | product_name | category_id
Categories/ category_id | category_name

use case_study_3;
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255),
    country VARCHAR(255)
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE Order_Items (
    order_id INT,
    product_id INT PRIMARY KEY,
    quantity INT,
    unit_price DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

CREATE TABLE Categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(255)
);
1.Retrieve the names and countries of all customers.
 select name, country from customers;
 
2.Find the total number of orders made.
select count(order_id) from orders;

3.List the top 5 customers who made the most orders along with their total order count.
select orders.customer_id,customers.name,count(order_id) as total_orders
from orders
inner join
customers on orders.customer_id=customers.customer_id
group by
orders.customer_id
order by total_orders desc limit 5;

4. Retrieve the top 10 orders by the total order amount.
SELECT order_id,customer_id,total_amount
FROM
    Orders o
ORDER BY
    o.total_amount DESC
LIMIT 10;

5.Calculate the average order amount per customer.
SELECT
    customer_id,AVG(total_amount) AS average_order_amount
FROM
    Orders
GROUP BY
    customer_id;

6.Get the list of products in the 'Electronics' category.
select product_name from products
inner join categories on products.category_id=categories.category_id
where category_name='Electronics';

7.Find the customer(s) who spent the most in a single order
SELECT
    customers.customer_id,customers.name,orders.order_id,orders.total_amount
FROM
    Customers 
inner JOIN
    orders ON customers.customer_id = orders.customer_id
ORDER BY
    orders.total_amount DESC
LIMIT 1;

8.List countries with more than 5 customers.
select country, count(customer_id) as no_of_customers 
from customers
group by country
having no_of_customers>5;

9.Rank customers based on their total order amount
select customer_id,rank() over (partition by customer_id order by total_amount)as rnk from orders;

10. Calculate the running total order amount for each customer.
select customer_id,sum(total_amount) over (partition by customer_id order by total_amount)as total_order from orders;

11.Retrieve the orders made by customers from 'Germany'
SELECT
    order_id,
    customer_id,
    order_date,
    total_amount
FROM
    Orders
WHERE
    customer_id IN (SELECT customer_id FROM Customers WHERE country = 'Germany');

12.List order details with customer name, order date, product name, and quantity.
SELECT
    c.name AS customer_name,
    o.order_id,
    o.order_date,
    p.product_name,
    oi.quantity
FROM
    Orders o
JOIN
    Customers c ON o.customer_id = c.customer_id
JOIN
    Order_Items oi ON o.order_id = oi.order_id
JOIN
    Products p ON oi.product_id = p.product_id;

13.Display the average order amount in each category.
SELECT
    c.category_name,
    o.order_id,
    o.total_amount,
    AVG(o.total_amount) OVER (PARTITION BY p.category_id) AS avg_order_amount_in_category
FROM
    Orders o
JOIN
    Order_Items oi ON o.order_id = oi.order_id
JOIN
    Products p ON oi.product_id = p.product_id
JOIN
    Categories c ON p.category_id = c.category_id;

14.Find the customer with the highest total order amount, along with their average order amount
select customer_id,name,avg(total_order_amount)
from
(
 SELECT
        c.customer_id,
        c.name,
        SUM(o.total_amount) AS total_order_amount,
        RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS rnk
    FROM
        Customers c
    JOIN
        Orders o ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_id, c.name
        ) as table1
        where rnk=1
        group by customer_id,name;
        
        
15.Retrieve customers who have made orders greater than the average order amount.
SELECT
    o.order_id,
    o.total_amount
FROM
    Orders o
JOIN
    Order_Items oi ON o.order_id = oi.order_id
JOIN
    Products p ON oi.product_id = p.product_id
group by 
 o.order_id,
    o.total_amount
having
 o.total_amount > avg(o.total_amount);
 
 16.	Using ROW_NUMBER with Joins:Apply ROW_NUMBER() within each category to enumerate products, displaying product details alongside their row numbers.
 SELECT
    ROW_NUMBER() OVER (PARTITION BY c.category_id ORDER BY p.product_id) AS rownumber,
    p.product_id,
    p.product_name,
    c.category_name
FROM
    Products p
JOIN
    Categories c ON p.category_id = c.category_id;
    
17.Ranking and Joining:Rank customers based on their total order amount within their respective countries, displaying customer details alongside their rankings.
SELECT
    customer_id,
    name,
    country,
    total_order_amount,
    RANK() OVER (PARTITION BY country ORDER BY total_order_amount DESC) AS customer_rank
FROM (
    SELECT
        c.customer_id,
        c.name,
        c.country,
        SUM(o.total_amount) AS total_order_amount
    FROM
        Customers c
    JOIN
        Orders o ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_id, c.name, c.country
) AS customer_totals;


18.	Using LAG/LEAD with Joins:Retrieve the details of products and their previous and next products within the same category, ordered by product_id.

SELECT
    p.product_id,
    p.product_name,
    p.category_id,
    LAG(p.product_name) OVER (PARTITION BY p.category_id ORDER BY p.product_id) AS previous_product,
    LEAD(p.product_name) OVER (PARTITION BY p.category_id ORDER BY p.product_id) AS next_product
FROM
    Products p
ORDER BY
    p.category_id, p.product_id;

19.Partitioning with Aggregation and Joins:Calculate the average order amount for each customer, comparing it to the average order amount within their respective countries.

SELECT
    c.customer_id,
    c.name,
    c.country,
    AVG(o.total_amount) AS avg_order_amount_customer,
    AVG(AVG(o.total_amount)) OVER (PARTITION BY c.country) AS avg_order_amount_country
FROM
    Customers c
JOIN
    Orders o ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id, c.name, c.country;
    
20.Using NTILE with Joins:Partition customers into quartiles based on their total order amount within each country, displaying customer details along with their quartile rankings.
SELECT
    customer_id,
    name,
    country,
    total_order_amount,
    NTILE(4) OVER (PARTITION BY country ORDER BY total_order_amount) AS quartile_rank
FROM (
    SELECT
        c.customer_id,
        c.name,
        c.country,
        SUM(o.total_amount) AS total_order_amount
    FROM
        Customers c
    JOIN
        Orders o ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_id, c.name, c.country
) AS customer_totals
ORDER BY
    country, quartile_rank;
    
21.Preceding and Following with Joins:Calculate the sum of order amounts for each customer within a specified time frame preceding and following each order, alongside order details.
SELECT
    c.customer_id,
    o.order_id,
    o.order_date,
    o.total_amount,
    SUM(o.total_amount) OVER (
        PARTITION BY c.customer_id
        ORDER BY o.order_date
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS sum_order_amount_within_timeframe
FROM
    Customers c
JOIN
    Orders o ON c.customer_id = o.customer_id
ORDER BY
    c.customer_id, o.order_date;

22.Using RANK with Different Joins:Rank products within each category based on their sales quantities, displaying product details and their rankings.
SELECT
    p.product_id,
    p.product_name,
    p.category_id,
    oi.quantity,
    RANK() OVER (PARTITION BY p.category_id ORDER BY oi.quantity DESC) AS product_rank
FROM
    Products p
JOIN
    Order_Items oi ON p.product_id = oi.product_id
JOIN
    Orders o ON oi.order_id = o.order_id
JOIN
    Categories c ON p.category_id = c.category_id
ORDER BY
    p.category_id, product_rank;
23.Comparing Aggregate Values with Joins:Compare the total order amount of each customer with the average total order amount within their country, displaying customer details and their comparison results.
SELECT
    c.customer_id,
    c.name,
    c.country,
    SUM(o.total_amount) AS total_order_amount,
    AVG(o.total_amount) AS avg_order_amount_country,
    CASE
        WHEN SUM(o.total_amount) > AVG(o.total_amount) THEN 'Above Average'
        WHEN SUM(o.total_amount) < AVG(o.total_amount) THEN 'Below Average'
        ELSE 'Equal to Average'
    END AS comparison_result
FROM
    Customers c
JOIN
    Orders o ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id, c.name, c.country;
    
    
24.Analyzing Trends with Window Functions and Joins:Display the difference in order amounts for each customer between their first and last orders, including customer details.
SELECT
    c.customer_id,
    c.name,
    MAX(o.total_amount) - MIN(o.total_amount) AS order_amount_difference
FROM
    Customers c
JOIN
    Orders o ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id, c.name;
25.Combining Multiple Window Functions with Joins:Calculate the cumulative sum of order amounts for each customer, alongside their average order amount within their country, in separate columns.
SELECT
    c.customer_id,
    c.name,
    o.order_id,
    o.total_amount,
    SUM(o.total_amount) OVER (PARTITION BY c.customer_id ORDER BY o.order_id) AS cumulative_order_amount,
    AVG(o.total_amount) OVER (PARTITION BY c.country) AS avg_order_amount_country
FROM
    Customers c
JOIN
    Orders o ON c.customer_id = o.customer_id
ORDER BY
    c.customer_id, o.order_id;