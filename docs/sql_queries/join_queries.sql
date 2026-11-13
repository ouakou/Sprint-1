-- 1. Show each complaint with customer name.

SELECT c.*, c2.first_name , c2.last_name , a.account_type
FROM complaint c 
NATURAL JOIN customer c2
-- 2. Add optional account type without dropping complaints that have no account.
LEFT JOIN account a
ON c.account_id = a.account_id;

-- 3. Verify distinct complaint count before and after joins.

-- BEFORE

SELECT COUNT(DISTINCT complaint_id)
FROM complaint c;

-- AFTER

SELECT COUNT(DISTINCT complaint_id)
FROM complaint c 
NATURAL JOIN customer c2
LEFT JOIN account a
ON c.account_id = a.account_id;


-- 4. Create complaint_analyst_view containing only justified fields.

CREATE VIEW complaint_analyst_view2 AS
SELECT c.category, c.status, c.complaint_id, i.started_at, i.completed_at, c.received_at
FROM complaint c 
LEFT JOIN investigation i 
ON c.complaint_id = i.complaint_id
