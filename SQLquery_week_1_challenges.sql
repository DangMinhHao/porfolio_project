--Create database for Danny restaurant
CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

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
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

  --look at the whole 3 tables
  SELECT *
  FROM sales
  SELECT *
  FROM menu
  SELECT *
  FROM members

  --1. What is the total amount each customer spent at the restaurant?
  SELECT s.customer_id, SUM(m.price) AS total_amount
  FROM sales s
  JOIN menu m
  ON s.product_id = m.product_id
  GROUP BY s.customer_id
  ORDER BY customer_id

  --2. How many days has each customer visited the restaurant?
  SELECT customer_id, COUNT(DISTINCT(order_date)) AS total_amount
  FROM sales
  GROUP BY customer_id
  ORDER BY customer_id

  --3. What was the first item from the menu purchased by each customer?
 WITH CTE AS 
	(
		SELECT s.customer_id, m.product_name, DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS bought_item_order
	    FROM sales s
	    JOIN menu m
	    ON s.product_id = m.product_id
	)
 SELECT customer_id, product_name
 FROM CTE
 WHERE bought_item_order = 1
 GROUP BY customer_id, product_name
 ORDER BY customer_id

  --4. What is the most purchased item on the menu and how many times was it purchased by all customers?
  SELECT TOP 1 m.product_name, COUNT(*) AS purchased_total_amount
  FROM sales s
  JOIN menu m
  ON s.product_id = m.product_id
  GROUP BY m.product_name
  ORDER BY COUNT(*) DESC

  --5. Which item was the most popular for each customer?
  WITH CTE3 AS 
  (
	  SELECT s.customer_id, m.product_name, COUNT(*) AS item_quantity
	  FROM sales s
	  JOIN menu m
	  ON s.product_id = m.product_id
	  GROUP BY s.customer_id, m.product_name
  ),
       CTE4 AS
  (
	  SELECT 
			customer_id
			,product_name
			,RANK() OVER(PARTITION BY customer_id ORDER BY item_quantity DESC) AS rank
	  FROM CTE3
  )
  SELECT
		customer_id
		,product_name
  FROM CTE4
  WHERE rank = 1
  --6. Which item was purchased first by the customer after they became a member?
  SELECT
		s.customer_id
		,m.product_name AS first_join_date_item
  FROM sales s
  JOIN menu m
  ON s.product_id = m.product_id
  JOIN
  (
	  SELECT 
			s.customer_id
			,MIN(s.order_date) AS first_date_joined
	  FROM sales s
	  JOIN menu m
	  ON s.product_id = m.product_id
	  LEFT JOIN members mem
	  ON s.customer_id = mem.customer_id
	  WHERE mem.join_date <= s.order_date
	  GROUP BY s.customer_id
  ) AS CTE5
  ON s.customer_id = CTE5.customer_id AND s.order_date = CTE5.first_date_joined

  --7. Which item was purchased just before the customer became a member?
  SELECT
		s.customer_id
		,m.product_name AS purchased_item_before_join
  FROM sales s
  JOIN menu m
  ON s.product_id = m.product_id
  JOIN
  (
	  SELECT  
			s.customer_id
			,MAX(s.order_date) AS date_before_join
	  FROM sales s
	  JOIN menu m
	  ON s.product_id = m.product_id
	  LEFT JOIN members mem
	  ON s.customer_id = mem.customer_id
	  WHERE mem.join_date > s.order_date
	  GROUP BY s.customer_id
  ) AS CTE6
  ON s.customer_id = CTE6.customer_id AND s.order_date = CTE6.date_before_join

  --8. What is the total items and amount spent for each member before they became a member?
	  SELECT  
			s.customer_id
			,COUNT(*) AS total_item_before_join
			,SUM(m.price) AS total_spent_before_join
	  FROM sales s
	  JOIN menu m
	  ON s.product_id = m.product_id
	  LEFT JOIN members mem
	  ON s.customer_id = mem.customer_id
	  WHERE mem.join_date > s.order_date
	  GROUP BY s.customer_id

  --9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
  WITH CTE7 AS 
  (
	  SELECT 
			s.customer_id
			,m.product_name
			,m.price
			,CASE WHEN m.product_name = 'sushi' THEN m.price * 20  ELSE m.price * 10 END AS item_point
	  FROM sales s
	  JOIN menu m
	  ON s.product_id = m.product_id
  )
  SELECT
		customer_id
		,SUM(item_point) AS total_point
  FROM CTE7
  GROUP BY customer_id

  --10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
  WITH CTE8 AS 
  (
	  SELECT 
			s.customer_id
			,m.product_name
			,m.price
			,s.order_date
			,mem.join_date
			,CASE WHEN m.product_name = 'sushi' AND (s.order_date < mem.join_date OR DATEDIFF(DAY, mem.join_date, s.order_date) + 1 > 7) THEN m.price * 20  
				  WHEN m.product_name != 'sushi' AND (s.order_date < mem.join_date OR DATEDIFF(DAY, mem.join_date, s.order_date) + 1 > 7) THEN m.price * 10
				  WHEN DATEDIFF(DAY, mem.join_date, s.order_date) + 1 <= 7 AND DATEDIFF(DAY, mem.join_date, s.order_date) + 1 >= 0 THEN m.price * 20
			 END AS test
	  FROM sales s
	  JOIN menu m
	  ON s.product_id = m.product_id
	  LEFT JOIN members mem
	  ON s.customer_id = mem.customer_id
  )
  SELECT
		customer_id
		,SUM(test) AS total_point
  FROM CTE8
  WHERE DATEPART(MONTH, order_date) = 1
  GROUP BY customer_id

  --BONUS QUESTION
  --Join all the things
  SELECT
		s.customer_id
		,s.order_date
		,m.product_name
		,m.price
		,CASE WHEN s.order_date < mem.join_date OR mem.join_date IS NULL THEN 'N'
			  WHEN s.order_date >= mem.join_date THEN 'Y'
		 END AS member
  FROM sales s
  LEFT JOIN menu m
  ON s.product_id = m.product_id
  LEFT JOIN members mem
  ON s.customer_id = mem.customer_id

  --Rank all the things
  WITH CTE9 AS
  (
	  SELECT
			s.customer_id
			,s.order_date
			,m.product_name
			,m.price
			,CASE WHEN s.order_date < mem.join_date OR mem.join_date IS NULL THEN 'N'
				  WHEN s.order_date >= mem.join_date THEN 'Y'
			 END AS member
	  FROM sales s
	  LEFT JOIN menu m
	  ON s.product_id = m.product_id
	  LEFT JOIN members mem
	  ON s.customer_id = mem.customer_id
  )
  SELECT 
		customer_id
		,order_date
		,product_name
		,price
		,member
		,CASE WHEN member = 'N' THEN NULL
			  WHEN member = 'Y' THEN RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date)
		 END AS ranking
  FROM CTE9