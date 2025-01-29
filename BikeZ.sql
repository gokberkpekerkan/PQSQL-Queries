-- Show oldest and latest items
SELECT MIN(model_year) AS oldest, MAX(model_year) AS latest
FROM products;

-- SELECT most expensive/cheapiest items per brand
SELECT brand_name, MAX(list_price) AS most_expensive, MIN(list_price) AS cheapest
FROM bikes
GROUP BY brand_name;


-- SELECT most expensive/cheapiest items per category
SELECT category_name, MAX(list_price) AS most_expensive, MIN(list_price) AS cheapest
FROM bikes
GROUP BY category_name
ORDER BY most_expensive DESC;

-- Get average price per brand
SELECT brand_name, ROUND(AVG(list_price),2) AS average_price
FROM bikes
GROUP BY brand_name
ORDER BY average_price;

-- Show number of bikes by brand
SELECT brand_name, SUM(quantity) AS total
FROM bikes
GROUP BY brand_name
ORDER BY total DESC;

-- Create View table
-- JOIN brands table with products table...
CREATE VIEW bikes AS
SELECT store_id,
       products.product_id,
       category_name,
       brand_name,
       product_name,
       model_year,
       list_price,
       quantity
FROM   products
       LEFT JOIN brands
              ON products.brand_id = brands. brand_id
       LEFT JOIN categories
              ON products.category_id = categories.category_id
       INNER JOIN stocks 
               ON products.product_id = stocks.product_id;  



-- Show whether shipped late
-- "order_status = 4" means order is shipped and received by customer
-- Create "shipped_late" col; 1: "yes", 0: "no"
SELECT *,
CASE WHEN shipped_date > required_date AND order_status = 4 THEN 1
ELSE 0
END AS shipped_late
FROM orders;

-- Get total orders, items sold, and revenue by using Common Table Expressions (CTE)

WITH sales_info AS (
    SELECT
		order_id,
		brand_id,
        order_items.product_id,
        quantity,
        order_items.list_price,
        quantity * order_items.list_price AS line_subtotal
        
    FROM
        order_items
    INNER JOIN
        products
    ON
        order_items.product_id = products.product_id
	
        
), brand_sales AS (
SELECT * 
FROM 
	sales_info
INNER JOIN 
	brands
ON 
	sales_info.brand_id = brands.brand_id
)

SELECT
    brand_name,
	SUM(quantity) AS units_sold,
	COUNT(DISTINCT(order_id)) AS total_orders,
	SUM(line_subtotal) AS revenue
FROM 
    brand_sales
GROUP BY 
	brand_name
ORDER BY
	revenue DESC;


-- Get total amount spend by customer
-- Create a ranking labeling customers based on their spending by using simple Window function
WITH item_sales AS(
	SELECT 
		customer_id,
		orders.order_id,
		product_id,
		quantity,
		ROUND(quantity*list_price * (1-discount),2) AS total_amount
	FROM 
		orders
	INNER JOIN 
		order_items
	ON 
		orders.order_id = order_items.order_id
)

SELECT
	ROW_NUMBER() OVER(ORDER BY SUM(total_amount) DESC) AS ranking,
	customer_id,
	SUM(quantity) AS total_units_sold,
	SUM(total_amount) AS total_spend
FROM
	item_sales
GROUP BY (customer_id)
;


