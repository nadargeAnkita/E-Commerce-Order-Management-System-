-- =====================================================
-- PROJECT: E-Commerce Order Management System 
-- Database: MySQL
-- Concepts: DDL, DML, constraints, joins, GROUP BY, subqueries,
--           CTEs, window functions, views, indexes
-- =====================================================

DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

-- ---------- 1. TABLES ----------
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name   VARCHAR(100) NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE,
    city        VARCHAR(50),
    joined_date DATE NOT NULL
);

CREATE TABLE categories (
    category_id   INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE products (
    product_id   INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category_id  INT NOT NULL,
    price        DECIMAL(10,2) NOT NULL CHECK (price > 0),
    stock_qty    INT NOT NULL DEFAULT 0 CHECK (stock_qty >= 0),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE orders (
    order_id    INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date  DATE NOT NULL,
    status      VARCHAR(20) NOT NULL
                CHECK (status IN ('Placed','Shipped','Delivered','Cancelled')),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id      INT NOT NULL,
    product_id    INT NOT NULL,
    quantity      INT NOT NULL CHECK (quantity > 0),
    unit_price    DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
    payment_id   INT PRIMARY KEY AUTO_INCREMENT,
    order_id     INT NOT NULL UNIQUE,
    payment_date DATE NOT NULL,
    method       VARCHAR(20) NOT NULL
                 CHECK (method IN ('UPI','Card','NetBanking','COD')),
    amount       DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- ---------- 2. SAMPLE DATA ----------
INSERT INTO customers (full_name, email, city, joined_date) VALUES
('Aarav Patil',   'aarav@mail.com',  'Pune',       '2025-01-15'),
('Sneha Kulkarni','sneha@mail.com',  'Mumbai',     '2025-02-10'),
('Rohan Deshmukh','rohan@mail.com',  'Kolhapur',   '2025-03-05'),
('Priya Shah',    'priya@mail.com',  'Pune',       '2025-04-20'),
('Vikram Rao',    'vikram@mail.com', 'Bengaluru',  '2025-05-12'),
('Neha Joshi',    'neha@mail.com',   'Nagpur',     '2025-06-01'),
('Karan Mehta',   'karan@mail.com',  'Mumbai',     '2025-07-18'),
('Isha Verma',    'isha@mail.com',   'Delhi',      '2025-08-25');

INSERT INTO categories (category_name) VALUES
('Electronics'), ('Books'), ('Clothing'), ('Home & Kitchen');

INSERT INTO products (product_name, category_id, price, stock_qty) VALUES
('Wireless Mouse',      1,  799.00, 120),
('Bluetooth Speaker',   1, 2499.00,  60),
('USB-C Charger',       1, 1199.00,  90),
('Python Crash Course', 2,  649.00,  40),
('SQL Made Easy',       2,  499.00,  55),
('Cotton T-Shirt',      3,  399.00, 200),
('Denim Jacket',        3, 1999.00,  35),
('Mixer Grinder',       4, 3499.00,  25),
('Non-stick Pan',       4,  899.00,  70),
('Water Bottle',        4,  299.00, 150);

INSERT INTO orders (customer_id, order_date, status) VALUES
(1,'2025-09-01','Delivered'),
(2,'2025-09-03','Delivered'),
(3,'2025-09-10','Shipped'),
(1,'2025-09-15','Delivered'),
(4,'2025-09-18','Cancelled'),
(5,'2025-09-22','Delivered'),
(2,'2025-10-02','Delivered'),
(6,'2025-10-05','Placed'),
(7,'2025-10-09','Delivered'),
(1,'2025-10-12','Shipped'),
(4,'2025-10-20','Delivered'),
(5,'2025-10-25','Delivered');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 2,  799.00), (1, 4, 1,  649.00),
(2, 2, 1, 2499.00),
(3, 6, 3,  399.00), (3, 10,2,  299.00),
(4, 8, 1, 3499.00),
(5, 7, 1, 1999.00),
(6, 3, 2, 1199.00), (6, 5, 1,  499.00),
(7, 9, 2,  899.00), (7, 10,1,  299.00),
(8, 5, 2,  499.00),
(9, 2, 1, 2499.00), (9, 1, 1,  799.00),
(10,7, 1, 1999.00), (10,6, 2,  399.00),
(11,4, 1,  649.00), (11,5, 1,  499.00),
(12,8, 1, 3499.00), (12,3, 1, 1199.00);

INSERT INTO payments (order_id, payment_date, method, amount) VALUES
(1,'2025-09-01','UPI',       2247.00),
(2,'2025-09-03','Card',      2499.00),
(3,'2025-09-10','COD',       1795.00),
(4,'2025-09-15','NetBanking',3499.00),
(6,'2025-09-22','UPI',       2897.00),
(7,'2025-10-02','Card',      2097.00),
(8,'2025-10-05','UPI',        998.00),
(9,'2025-10-09','UPI',       3298.00),
(10,'2025-10-12','Card',     2797.00),
(11,'2025-10-20','UPI',      1148.00),
(12,'2025-10-25','NetBanking',4698.00);

-- ---------- 3. INDEXES ----------
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date     ON orders(order_date);
CREATE INDEX idx_items_product   ON order_items(product_id);

-- ---------- 4. VIEWS ----------
CREATE VIEW vw_order_totals AS
SELECT o.order_id, o.customer_id, o.order_date, o.status,
       SUM(oi.quantity * oi.unit_price) AS order_total
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.customer_id, o.order_date, o.status;

CREATE VIEW vw_product_sales AS
SELECT p.product_id, p.product_name, c.category_name,
       COALESCE(SUM(oi.quantity), 0)                AS units_sold,
       COALESCE(SUM(oi.quantity * oi.unit_price),0) AS revenue
FROM products p
JOIN categories c ON c.category_id = p.category_id
LEFT JOIN order_items oi ON oi.product_id = p.product_id
LEFT JOIN orders o ON o.order_id = oi.order_id AND o.status <> 'Cancelled'
GROUP BY p.product_id, p.product_name, c.category_name;

-- ---------- 5. ANALYSIS QUERIES ----------

-- Q1. Total revenue (excluding cancelled orders)
SELECT SUM(order_total) AS total_revenue
FROM vw_order_totals
WHERE status <> 'Cancelled';

-- Q2. Monthly revenue trend
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
       COUNT(*)         AS orders,
       SUM(order_total) AS revenue
FROM vw_order_totals
WHERE status <> 'Cancelled'
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

-- Q3. Top 5 customers by spend
SELECT c.full_name, c.city, SUM(v.order_total) AS total_spent
FROM customers c
JOIN vw_order_totals v ON v.customer_id = c.customer_id
WHERE v.status <> 'Cancelled'
GROUP BY c.customer_id, c.full_name, c.city
ORDER BY total_spent DESC
LIMIT 5;

-- Q4. Best-selling products
SELECT product_name, category_name, units_sold, revenue
FROM vw_product_sales
ORDER BY units_sold DESC
LIMIT 5;

-- Q5. Revenue by category with percentage share
SELECT category_name,
       SUM(revenue) AS revenue,
       ROUND(100 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 2) AS pct_share
FROM vw_product_sales
GROUP BY category_name
ORDER BY revenue DESC;

-- Q6. Customers who never placed an order
SELECT c.customer_id, c.full_name
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;

-- Q7. Products never sold
SELECT product_name
FROM products
WHERE product_id NOT IN (SELECT DISTINCT product_id FROM order_items);

-- Q8. Orders above the average order value (subquery)
SELECT order_id, customer_id, order_total
FROM vw_order_totals
WHERE order_total > (SELECT AVG(order_total) FROM vw_order_totals)
ORDER BY order_total DESC;

-- Q9. Rank customers by spend within each city (window function)
WITH spend AS (
    SELECT c.customer_id, c.full_name, c.city, SUM(v.order_total) AS total_spent
    FROM customers c
    JOIN vw_order_totals v ON v.customer_id = c.customer_id
    WHERE v.status <> 'Cancelled'
    GROUP BY c.customer_id, c.full_name, c.city
)
SELECT city, full_name, total_spent,
       RANK() OVER (PARTITION BY city ORDER BY total_spent DESC) AS city_rank
FROM spend;

-- Q10. Repeat customers (more than 1 order)
SELECT c.full_name, COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name
HAVING COUNT(o.order_id) > 1;

-- Q11. Payment method usage
SELECT method, COUNT(*) AS payments, SUM(amount) AS total_amount
FROM payments
GROUP BY method
ORDER BY total_amount DESC;

-- Q12. Order status breakdown
SELECT status, COUNT(*) AS orders
FROM orders
GROUP BY status;

-- Q13. Low stock products (reorder list)
SELECT product_name, stock_qty
FROM products
WHERE stock_qty < 40
ORDER BY stock_qty;

-- Q14. Month-over-month revenue growth (LAG)
WITH monthly AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, SUM(order_total) AS revenue
    FROM vw_order_totals
    WHERE status <> 'Cancelled'
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT month, revenue,
       LAG(revenue) OVER (ORDER BY month) AS prev_revenue,
       ROUND(100 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / LAG(revenue) OVER (ORDER BY month), 2) AS growth_pct
FROM monthly;

-- Q15. Data check: payments that don't match order totals
SELECT p.order_id, p.amount AS paid, v.order_total AS expected
FROM payments p
JOIN vw_order_totals v ON v.order_id = p.order_id
WHERE p.amount <> v.order_total;