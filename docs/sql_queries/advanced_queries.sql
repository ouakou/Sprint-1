

-- 1. Use CASE for unresolved age buckets 0-7, 8-30 and 31+ days from the last day of feb.

SELECT cav.status , cav.category, cav.received_at,
	CASE
	  WHEN CAST(JULIANDAY('2025-02-28') - JULIANDAY(cav.received_at) AS INTEGER ) <= 7 THEN '0-7 days'
	  WHEN CAST(JULIANDAY('2025-02-28') - JULIANDAY(cav.received_at) AS INTEGER ) <= 30 THEN '8-30 days'
	ELSE '31+ days'
END
FROM complaint_analyst_view2 cav 
LEFT JOIN complaint_status_history csh 
ON cav.complaint_id  = csh.complaint_id 
WHERE cav.status != 'CLOSED'


-- 2. Use a CTE to identify repeat complainants.

WITH repeat_complaints as (
SELECT count(DISTINCT c.complaint_id)
FROM complaint c 
GROUP BY c.complaint_id 
)
SELECT *
FROM repeat_complaints;


-- 3. Use ROW_NUMBER to select latest status per complaint.

WITH ranked AS (
  SELECT complaint_id,
         old_status,
         new_status,
         changed_by,
         changed_at,
         ROW_NUMBER() OVER (
           PARTITION BY complaint_id
           ORDER BY changed_at DESC
         ) AS rn
  FROM complaint_status_history
)
SELECT complaint_id,
       new_status AS latest_status,
       changed_by,
       changed_at,
       rn 
FROM ranked


WITH ranked AS (
  SELECT complaint_id,
         ROW_NUMBER() OVER (PARTITION BY complaint_id ORDER BY changed_at DESC, rowid DESC) AS rn
  FROM complaint_status_history
)
SELECT COUNT(*) AS rows_returned,
       COUNT(DISTINCT complaint_id) AS distinct_complaints
FROM ranked
WHERE rn = 1;


-- Rank customers by complaint count

WITH counts AS (
SELECT c.customer_id,
       COUNT(DISTINCT c.complaint_id)  AS complaint_count
FROM complaint c 
GROUP BY c.customer_id
)
SELECT customer_id, 
       complaint_count,
   	   RANK() OVER(ORDER BY complaint_count DESC) AS complaint_rank
FROM counts



-- 5.Determine complaint priority classification.

WITH classification AS(
SELECT c.complaint_id , c.priority, c.received_at,
CASE
	WHEN c.priority ='Critical' THEN 1
	WHEN c.priority ='High' THEN 2
	WHEN c.priority ='Medium' THEN 3
	WHEN c.priority ='Low' THEN 4
	END AS priority_level
FROM complaint c
)
SELECT complaint_id, priority, received_at,
	   ROW_NUMBER() OVER(ORDER BY priority_level, received_at DESC)
FROM classification 


-- 6.Find customers who submitted more than one complaint.



SELECT c.customer_id,
       COUNT(DISTINCT c.complaint_id) AS complaint_count
FROM complaint c 
GROUP BY c.customer_id 
HAVING complaint_count != 1



-- 7.Rank customers by number of complaints.


WITH complaint_number AS (
SELECT c.customer_id,
       COUNT(DISTINCT c.complaint_id) AS complaint_count
FROM complaint c 
GROUP BY c.customer_id 
)
SELECT customer_id, 
	  complaint_count,
      DENSE_RANK() OVER(ORDER BY complaint_count DESC) AS number_of_complaint_order
FROM complaint_number 


-- 8.Rank complaints by receive date within each category


SELECT c.complaint_id, 
	   c.received_at,
       RANK() OVER(PARTITION BY c.category ORDER BY c.received_at DESC) AS receieved_at_order_per_category,
       c.category 
FROM complaint c 



