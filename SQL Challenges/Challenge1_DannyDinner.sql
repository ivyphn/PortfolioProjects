-- SQL Challenges 8weeksqlchallenge.com/case-study-1/

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
)

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
)

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12')
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
)

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09')

 SELECT * FROM sales
 SELECT * FROM menu
 SELECT * FROM members

 -- What is the total amount each customer spent at the restaurant?

 SELECT s.customer_id, SUM(me.price) AS total_spent
 FROM sales AS s
 JOIN menu AS me ON me.product_id = s.product_id
 GROUP BY s.customer_id

 -- How many days has each customer visited the restaurant?
 SELECT customer_id, COUNT(DISTINCT order_date) AS visited
 FROM sales
 GROUP BY customer_id

 -- What was the first item from the menu purchased by each customer?
 WITH CTE AS 
 (
 SELECT s.customer_id, me.product_name, s.order_date
      , RANK () OVER(PARTITION BY s.customer_id ORDER BY s.order_date ASC) AS rnk 
 FROM sales as s
 JOIN menu as me ON s.product_id = me.product_id
 )
 SELECT * 
 FROM CTE
 WHERE rnk = 1 

 -- What is the most purchased item on the menu and how many times was it purchased by all customers?
 WITH CTE AS
 (
 SELECT s.product_id, me.product_name, COUNT(s.customer_id) as total_purchased
      , RANK () OVER (ORDER BY COUNT(s.customer_id) DESC) AS rnk 
 FROM sales AS s
 JOIN menu AS me ON me.product_id = s.product_id
 GROUP BY s.product_id, me.product_name
 ) 
 SELECT *
 FROM CTE
 WHERE rnk = 1

 -- Which item was the most popular for each customer?
 WITH CTE AS
 (
 SELECT s.customer_id, s.product_id, me.product_name, COUNT(s.customer_id) as quantity_per_item
      , RANK () OVER (PARTITION BY s.customer_id ORDER BY COUNT(s.customer_id) DESC) AS rnk 
 FROM sales AS s
 JOIN menu AS me ON me.product_id = s.product_id
 GROUP BY s.product_id, me.product_name, s.customer_id
 ) 
 SELECT customer_id, product_name
 FROM CTE
 WHERE rnk = 1

 -- Which item was purchased first by the customer after they became a member?
 WITH CTE AS
 (
 SELECT s.customer_id, s.order_date, mem.join_date, me.product_name 
       ,RANK () OVER (PARTITION BY s.customer_id ORDER BY s.order_date ASC) AS rnk
 FROM sales AS s
 JOIN members AS mem ON s.customer_id = mem.customer_id
 JOIN menu AS me ON s.product_id = me.product_id
 WHERE s.order_date >= mem.join_date
)
SELECT *
FROM CTE
WHERE rnk = 1

-- Which item was purchased just before the customer became a member?
 WITH CTE AS
 (
 SELECT s.customer_id, s.order_date, mem.join_date, me.product_name 
       ,RANK () OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rnk
 FROM sales AS s
 JOIN members AS mem ON s.customer_id = mem.customer_id
 JOIN menu AS me ON s.product_id = me.product_id
 WHERE s.order_date < mem.join_date
)
SELECT *
FROM CTE
WHERE rnk = 1

-- What is the total items and amount spent for each member before they became a member?
 WITH CTE AS
 (
 SELECT s.customer_id, s.order_date, mem.join_date, me.product_name, me.price
       ,RANK () OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rnk
 FROM sales AS s
 JOIN members AS mem ON s.customer_id = mem.customer_id
 JOIN menu AS me ON s.product_id = me.product_id
 WHERE s.order_date < mem.join_date
)
SELECT customer_id, SUM(price)
FROM CTE
GROUP BY customer_id

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
 SELECT s.customer_id
       ,SUM(CASE 
	        WHEN
		    me.product_name = 'sushi' THEN 20*me.price
	    ELSE 10*me.price 
        END) AS point
 FROM sales AS s
 JOIN menu AS me ON me.product_id = s.product_id
 GROUP BY s.customer_id

 -- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
 -- not just sushi - how many points do customer A and B have at the end of January?
 SELECT s.customer_id 
       ,SUM(CASE 
			WHEN s.order_date BETWEEN mem.join_date AND DATEADD(day,6,mem.join_date) THEN 20*m.price
	        WHEN m.product_name = 'sushi' THEN 20*m.price
			ELSE 10*m.price 
			END) AS point
 FROM sales s
 JOIN menu m ON s.product_id = m.product_id
 JOIN members mem ON s.customer_id = mem.customer_id
 WHERE DATETRUNC(month, order_date ) = '2021-01-01'
 GROUP BY s.customer_id 

 -- Membership table
 SELECT s.customer_id, s.order_date, me.product_name, me.price
       ,CASE 
			WHEN s.order_date >= mem.join_date THEN 'Y'
			ELSE 'N'
		END AS member_status
 FROM sales s
 LEFT JOIN members mem ON s.customer_id = mem.customer_id
 LEFT JOIN menu me ON s.product_id = me.product_id

 









