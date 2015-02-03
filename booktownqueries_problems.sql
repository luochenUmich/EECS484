-- Homework #2: EECS 484.
-- Your uniquname:
-- include your teamate's uniqname if you are working in team's of two

-- Your answer should work for any instance of the database, not just the one given.

-- EXAMPLE
-- Q0: "list titles of all books". Answer given below.

SELECT title FROM books;

-- Q1: List the ISBN of all books written by "Frank Herbert"
SELECT isbn from books b, authors a WHERE a.first_name='Frank' 
AND a.last_name='Herbert' AND a.author_id=b.author_id;

-- Q2: List last name and first name of authors who have written both
-- Short Story and Horror books. In general, there could be two different authors
-- with the same name, one who has written a horror book and another
-- who has written short stories. 

SELECT last_name, first_name from  
(
	SELECT a.author_id, a.last_name, a.first_name
	FROM authors a, subjects s, books b
	WHERE a.author_id=b.author_id AND s.subject_id=b.subject_id AND
		s.subject='Horror'
	INTERSECT
	SELECT a.author_id, a.last_name, a.first_name
	FROM authors a, subjects s, books b
	WHERE a.author_id=b.author_id AND s.subject_id=b.subject_id AND
		s.subject='Short Story'
);

-- Q3: List titles, subjects, author's id, author's last name, and author's first name of all books 
-- by authors who have written Short Story book(s). Note: that this may
-- require a nested query. The answer can include non-Short Story books. You
-- can also use views. But DROP any views at the end of your query. Using
-- a single query is likely to be more efficient in practice.

SELECT b.title, s.subject, b.author_id, a.last_name, a.first_name
FROM books b, subjects s, 
(
	SELECT a.author_id 
	FROM authors a, books b, subjects s
	WHERE a.author_id = b.author_id AND b.subject_id=s.subject_id 
		AND s.subject = 'Short Story'
	GROUP BY a.author_id 
	HAVING COUNT(*) > 0
) q, authors a 
WHERE b.author_id=q.author_id AND q.author_id=a.author_id 
	AND b.subject_id=s.subject_id;

-- Q4: Find id, first name, and last name of authors who wrote books for all the 
-- subjects of books written by Edgar Allen Poe.

CREATE VIEW all_subject AS
(
	SELECT DISTINCT b.subject_id 
	FROM books b, authors a, subjects s
	WHERE a.last_name='Poe' AND a.first_name='Edgar Allen' AND 
		b.author_id=a.author_id
);

SELECT a.author_id, a.first_name, a.last_name
FROM author a, 
(
	SELECT author_id
	FROM 
	(
		SELECT DISTINCT a.author_id, q.subject_id
		FROM author a, books b, all_subject q
		WHERE a.author_id=b.author_id AND q.subject_id=b.subject_id
	)
	GROUP BY author_id
	HAVING COUNT(*)=(SELECT COUNT(*) FROM all_subject)
) q
WHERE a.author_id = q.author_id;

DROP VIEW all_subject;

-- Q5: Find the name of all publishers whos have published books for authors
-- who have written more than one book, order by ascending publisher id;

SELECT p.name
FROM editions e, books b, publishers p
(
	SELECT a.author_id 
	FROM authors a, books b
	WHERE a.author_id=b.author_id
	GROUP BY a.author_id
	HAVING COUNT(*) > 1
) q
WHERE e.book_id=b.book_id AND p.publisher_id=e.publisher_id 
	AND q.author_id=b.author_id
ORDER BY p.publisher_id ASC;

-- Q6: Find the last name and first name of authors who haven't written any book

SELECT a.last_name, a.first_name
FROM authors a, 
(
	SELECT author_id 
	FROM authors
	EXCEPT
	SELECT DISTINCT author_id
	FROM books
) q
WHERE a.author_id=q.author_id;

-- Q7: Find id of authors who have written exactly 1 book. Name the column as id. 
-- Order the id in ascending order

SELECT a.author_id AS id
FROM books b, authors a
WHERE b.author_id=a.author_id
GROUP BY a.author_id
HAVING COUNT(*)=1
ORDER BY a.author_id ASC;

