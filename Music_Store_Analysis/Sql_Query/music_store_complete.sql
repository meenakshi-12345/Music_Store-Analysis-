SELECT * FROM album;
SELECT * FROM artist;
SELECT * FROM customer;
SELECT * FROM employee;
SELECT * FROM genre;
SELECT * FROM invoice;
SELECT * FROM invoice_line;
SELECT * FROM media_type;
SELECT * FROM playlist;
SELECT * FROM playlist_track;
SELECT * FROM track;

-- 1) who is the senior most employee based on job title?


SELECT * FROM employee;

SELECT *
FROM employee
ORDER BY levels DESC LIMIT 1;


--2) which country have the most invoices?


SELECT * FROM invoice;

SELECT billing_country, COUNT(invoice_id)
FROM invoice
GROUP BY billing_country
ORDER BY COUNT(invoice_id) DESC;


-- 3) What are the top 3 values of total invoice 


 SELECT total
 FROM invoice
 ORDER BY total DESC LIMIT 3;
 

-- 4) Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
--     Write a query that returns one city that has the highest sum of invoice totals. 
--      Return both the city name & sum of all invoice totals */


SELECT billing_city, SUM(total)
FROM invoice
GROUP BY billing_city 
ORDER BY SUM(total) DESC LIMIT 1;



-- 5) Write a query that returns the person who has spent the emost money 

SELECT * FROM customer;
SELECT * FROM invoice;


SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total)
FROM customer c 
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id 
ORDER BY SUM(i.total) DESC LIMIT 1;


-- MODERATE QUERIES 

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */ 


SELECT * FROM genre;
SELECT * FROM customer;
SELECT * FROM invoice;

SELECT DISTINCT c.email, c.first_name, c.last_name,g.name
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line l ON i.invoice_id = l.invoice_id 
JOIN track t ON t.track_id = l.track_id
JOIN genre g ON g.genre_id = t.genre_id 
WHERE g.name like 'Rock'
ORDER BY c.email ASC;



/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */


SELECT * FROM artist;




SELECT a.name, a.artist_id ,COUNT(a.artist_id)
FROM artist a 
JOIN album  b ON a.artist_id = b.artist_id
JOIN track t ON b.album_id = t.album_id 
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name LIKE 'Rock'
GROUP BY a.artist_id, a.name
ORDER BY COUNT(a.artist_id) DESC LIMIT 10;




/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */


SELECT * FROM track;


SELECT AVG(milliseconds) FROM track;


SELECT name, milliseconds FROM track
WHERE milliseconds >(SELECT CAST(AVG(milliseconds) AS DECIMAL (10,2)) FROM track) 
ORDER BY milliseconds DESC;




 -- ADVANCE QUERY -- 


/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

SELECT * FROM artist;
SELECT * FROM customer;

WITH best_selling_artist AS (
   SELECT ar.name, ar.artist_id, SUM(i.unit_price * i.quantity ) AS total_sales
   FROM invoice_line i 
   JOIN track t ON i.track_id = t.track_id 
   JOIN album ab ON t.album_id = ab.album_id
   JOIN artist ar ON ab.artist_id = ar.artist_id
   GROUP BY ar.name,ar.artist_id
   ORDER BY total_sales DESC 
   LIMIT 1
)

SELECT c.customer_id, c.first_name, c.last_name, bsa.name AS artist_name, SUM(il.unit_price * il.quantity) AS amount_spent

FROM invoice i 

JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id 
JOIN album ab ON ab.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = ab.artist_id 
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.name
ORDER BY amount_spent DESC;


/* Q2: We want to find out the most popular music Genre for each country. 
We determine the most popular genre as the genre with the highest amount of purchases.
Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres. */

WITH popular_genre AS (
    SELECT 
        COUNT(il.quantity) AS purchases,
        c.country,
        g.name AS genre_name,
        g.genre_id,
        ROW_NUMBER() OVER (
            PARTITION BY c.country
            ORDER BY COUNT(il.quantity) DESC
        ) AS row_no
    FROM invoice_line il
    JOIN invoice i   ON i.invoice_id = il.invoice_id
    JOIN customer c  ON c.customer_id = i.customer_id
    JOIN track t     ON t.track_id = il.track_id
    JOIN genre g     ON g.genre_id = t.genre_id
    GROUP BY c.country, g.name, g.genre_id
)
SELECT *
FROM popular_genre
WHERE row_no = 1;


/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */


WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1






