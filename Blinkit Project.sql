-- Query 1: Total revenue per customer (joins orders and customers)
SELECT 
    c.customer_id, 
    c.customer_name, 
    SUM(o.order_total) AS total_revenue
FROM 
    orders o
JOIN 
    customers c ON o.customer_id = c.customer_id
GROUP BY 
    c.customer_id, c.customer_name
ORDER BY 
    total_revenue DESC
LIMIT 10;

-- Query 2: Average delivery time per delivery partner (from delivery_performance)
SELECT 
    delivery_partner_id, 
    AVG(delivery_time_minutes) AS avg_delivery_time_minutes
FROM 
    delivery_performance
GROUP BY 
    delivery_partner_id
HAVING 
    AVG(delivery_time_minutes) > 0
ORDER BY 
    avg_delivery_time_minutes DESC
LIMIT 10;

-- Query 3: Products with highest sales quantity (joins order_items and orders)
SELECT 
    oi.product_id, 
    SUM(oi.quantity) AS total_quantity_sold
FROM 
    order_items oi
JOIN 
    orders o ON oi.order_id = o.order_id
GROUP BY 
    oi.product_id
ORDER BY 
    total_quantity_sold DESC
LIMIT 10;

-- Query 4: Customer feedback average rating per category (from customer_feedback)
SELECT 
    feedback_category, 
    AVG(rating) AS avg_rating
FROM 
    customer_feedback
GROUP BY 
    feedback_category
ORDER BY 
    avg_rating DESC;

-- Query 5: Inventory stock received vs damaged per product (using inventory_new, assuming date is in YYYY-MM format)
SELECT 
    product_id, 
    SUM(stock_received) AS total_received, 
    SUM(damaged_stock) AS total_damaged,
    (SUM(damaged_stock) / SUM(stock_received)) * 100 AS damage_percentage
FROM 
    inventory_new
GROUP BY 
    product_id
HAVING 
    SUM(stock_received) > 0
ORDER BY 
    damage_percentage DESC
LIMIT 10;

-- Query 6: Marketing campaigns with highest ROAS (from marketing_performance)
SELECT 
    campaign_id, 
    campaign_name, 
    roas
FROM 
    marketing_performance
ORDER BY 
    roas DESC
LIMIT 10;

-- Query 7: Delayed deliveries count by reason (from delivery_performance)
SELECT 
    reasons_if_delayed, 
    COUNT(*) AS delayed_count
FROM 
    delivery_performance
WHERE 
    delivery_status != 'On Time'
GROUP BY 
    reasons_if_delayed
ORDER BY 
    delayed_count DESC;

-- Query 8: Total orders and average order value per customer segment (from customers)
SELECT 
    customer_segment, 
    COUNT(customer_id) AS total_customers, 
    AVG(avg_order_value) AS avg_order_value
FROM 
    customers
GROUP BY 
    customer_segment
ORDER BY 
    total_customers DESC;

-- Query 9: Top products by revenue (joins order_items and orders)
SELECT 
    oi.product_id, 
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM 
    order_items oi
JOIN 
    orders o ON oi.order_id = o.order_id
GROUP BY 
    oi.product_id
ORDER BY 
    total_revenue DESC
LIMIT 10;

-- Query 10: Customer retention: Number of repeat customers (customers with >1 order, from customers or orders)
SELECT 
    COUNT(DISTINCT customer_id) AS repeat_customers
FROM 
    orders
GROUP BY 
    customer_id
HAVING 
    COUNT(order_id) > 1;

-- Query 11: calculates the number of orders per customer, ranks them within their customer segment, and uses a CTE to prepare the data.
WITH CustomerOrders AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.customer_segment,
        COUNT(o.order_id) AS order_count
    FROM 
        blinkit_orders o
    JOIN 
        blinkit_customers c ON o.customer_id = c.customer_id
    GROUP BY 
        c.customer_id, c.customer_name, c.customer_segment
)
SELECT 
    customer_id,
    customer_name,
    customer_segment,
    order_count,
    RANK() OVER (PARTITION BY customer_segment ORDER BY order_count DESC) AS segment_rank
FROM 
    CustomerOrders
WHERE 
    order_count > 1
ORDER BY 
    customer_segment, order_count DESC
LIMIT 10;
 
