use olist_ecommerce;
-- KPI -1
-- Weekday/Weekend (order_purchase_timestamp) Payment Statistics
SELECT 
  CASE
    WHEN WEEKDAY(o.order_purchase_timestamp) IN (5,6) THEN 'Weekend' 
    ELSE 'Weekday'
  END AS day_type,
  COUNT(distinct o.order_id) AS No_of_Orders,
  CONCAT(
    ROUND(SUM(p.payment_value)),
    ' ',
    '(',
    ROUND(SUM(p.payment_value) / (SELECT SUM(payment_value) FROM olist_order_payments_dataset) * 100),
    '%',
    ')'
  ) AS Total_Payments,
  ROUND(AVG(p.payment_value)) AS Avg_Payment
FROM 
  olist_orders_dataset AS o 
INNER JOIN 
  olist_order_payments_dataset AS p ON o.order_id = p.order_id 
GROUP BY 
  day_type;

-- KPI - 2
-- 2.Number of Orders with review score 5 and payment type as credit card.
SELECT
  r.review_score,
  COUNT(r.order_id) AS No_of_orders,
  p.payment_type
FROM
  olist_order_reviews_dataset AS r
INNER JOIN
  olist_order_payments_dataset AS p USING(order_id)
WHERE
  r.review_score = 5 AND p.payment_type = 'credit_card'
GROUP BY
  r.review_score, p.payment_type;

-- KPI - 3
 -- 3.Average number of days taken for order_delivered_customer_date for pet_shop
 SELECT
  p.product_category_name,
  round(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp))) AS Avg_delivery_time
FROM
  olist_products_dataset AS p
INNER JOIN
  olist_order_items_dataset AS i USING(product_id)
INNER JOIN
  olist_orders_dataset AS o USING(order_id)
WHERE 
p.product_category_name='pet_shop'
GROUP BY
p.product_category_name;

 -- KPI -4
 -- 4.Average price and payment values from customers of sao paulo city
 SELECT
  c.customer_city,
  round(AVG(i.price))AS AVG_item_Price,
  round(AVG(p.payment_value)) AS avg_payment_value
FROM
  olist_order_items_dataset AS i
INNER JOIN
  olist_order_payments_dataset AS p USING(order_id)
INNER JOIN
  olist_orders_dataset AS o USING(order_id)
INNER JOIN
  olist_customers_dataset AS c USING(customer_id)
WHERE
  c.customer_city = 'sao paulo'
GROUP BY
c.customer_city;

-- KPI -5
-- 5.Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.
SELECT
  r.review_score,
  ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp))) AS Avg_Shipping_Days
FROM
  olist_orders_dataset AS o
INNER JOIN
  olist_order_reviews_dataset AS r USING(order_id)
WHERE
  DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp) IS NOT NULL
GROUP BY
  review_score
ORDER BY
  Avg_Shipping_Days ASC;
