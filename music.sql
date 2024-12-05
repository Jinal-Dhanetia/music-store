#Q1 : Who is the senior most employee based on job title?

SELECT * FROM employee
ORDER by levels DESC
LIMIT 1

#Q2 : Which countries have the most invoices?

SELECT COUNT(total),billing_country FROM invoice
GROUP BY billing_country 
ORDER BY COUNT(total) DESC

#Q3 : What are the top 3 values of total invoice

SELECT total from invoice
ORDER BY total desc
limit 3

#Q4 : Which city has the best customers? We would like to throw a promotional Music Festivalin the city we made the most money.Write a query that returns one city that has the highest sum of invoice totals.Return both the city name & sum of all invoice totals.

SELECT SUM(total),billing_city FROM invoice
GROUP BY Billing_city
ORDER BY SUM(total) desc
limit 1

#Q5 : Who is the best customer?The customer who has spent the most money will be declared the best customer.Write a query that returns the person who has spent the most money.
NOT WORKING
SELECT customer.customer_id,customer.first_name,customer.last_name,SUM(invoice.total)
FROM CUSTOMER
JOIN invoice on customer.customer_id=invoice.customer_id
GROUP BY customer.customer_id
ORDER BY SUM(total) desc
limit 1

#Q6 : Write a query to return the email,first name ,last name & genre of all Rock Music listeners.Return your list ordered alphabeticallyby email starting with A.

SELECT DISTINCT customer.email,customer.first_name,customer.last_name
FROM customer
JOIN invoice on customer.customer_id=invoice.customer_id
JOIN invoice_line on invoice.invoice_id=invoice_line.invoice_id
JOIN track on invoice_line.track_id=track.track_id
JOIN genre on track.genre_id=genre.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY customer.email

#Q7 : Lets's invite the artists who have written the most rock music in our dataset .Write a query that returns the Artist name and total track count of the top 10 rock bands.

SELECT artist.artist_id,artist.name
FROM track
JOIN album2 on artist.artist_id=album2.artist_id
JOIN track on album2.album_id=track.album_id
JOIN genre on track.genre_id=genre.genre_id
WHERE genre.name like 'Rock'
GROUP BY artist.artist_id
ORDER BY COUNT(artist.artist_id) desc
limit 10

SELECT artist.name,count(artist.artist_id)
from artist
JOIN album2 on artist.artist_id=album2.artist_id
JOIN track on album2.album_id=track.album_id
JOIN genre on track.genre_id=genre.genre_id
WHERE genre.name like 'Rock'
GROUP BY artist.name
ORDER BY COUNT(artist.artist_id) desc
LIMIT 10

#Q8 : Return all the track names that have a song length longer than the average song length.Return the name and milliseconds for each track.Order by the song length with the longest songs listed first.
 
SELECT name , milliseconds  from track
WHERE milliseconds>(SELECT AVG(milliseconds) AS avg_tracklength
from track)
order by milliseconds desc

#Q9: Find how much amount spent by each customer on artists?Write a query to return customer name, artist name and total spent.

WITH best_selling_artists AS (
	SELECT artist.artist_id AS artist_id,artist.name AS artist_name,
	SUM(invoice_line.unit_price*invoice_line.quantity) as total_sales
	From invoice_line
	JOIN album2 on artist.artist_id = album2.artist_id
	JOIN track on album2.album_id=track.album_id
	JOIN invoice_line on track.track_id = invoice_line.track_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)

SELECT c.customer_id,c.first_name,c.last_name,bsa.artist_name,
SUM(il.unit_price*il.quantity)AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id=i.customer_id
JOIN invoice_line il on il.invoice_id= i.invoice_id
JOIN album2 alb ON alb.album_id=t.album_id
JOIN best_selling_artists bsa on bsa.artist_id=alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

not executed
#Q9 : We want to find out the most popular music genre for each country.We determine the most popular genre as the genre with the highest amount of purchases.Write a query that returns each country along with the top genre.For countries where the maximum number of purchases is shared return all genres .


WITH popular_genre AS(
	SELECT COUNT(invoice_line.quantity) as purchases,customer.country,genre.name,genre.genre_id,
    ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo
    FROM invoice_line
    JOIN invoice ON invoice.invoice_id=invoice_line.invoice_id
    JOIN customer on customer.customer_id=invoice.customer_id
    JOIN track on track.track_id=invoice_line.track_id
    JOIN genre ON genre.genre_id=track.genre_id
    GROUP BY 2,3,4
    ORDER BY 2 ASC,1 DESC
)
SELECT * FROM popular_genre WHERE RowNo<=1

#Method 2:

WITH RECURSIVE
	sales_per_country AS(
		SELECT COUNT(*) AS purchases_per_genre,customer.country,genre.name,genre.genre_id
		FROM invoice_line
		JOIN invoice on invoice.invoice_id=invoice_line.invoice_id
		JOIN customer on customer.customer_id=invoice.customer_id
		JOIN track on track.track_id=invoice_line.track_id
		JOIN genre on genre.genre_id=track.genre_id
		GROUP BY 2,3,4
		ORDER BY 2
	),
    max_genre_per_country AS(SELECT MAX(purchases_per_genre) AS max_genre_number,country
		FROM sales_per_country
        GROUP BY 2
        ORDER BY 2)
		      
	SELECT sales_per_country.*
    FROM sales_per_country
    JOIN max_genre_per_country ON sales_per_country.country=max_genre_per_country.country
    WHERE sales_per_country.purchases_per_genre=max_genre_per_country.max_genre_number
    
#Q10: Write a query that determines the customer that has spent the most on music for each country.Write a query that returns the country along with the top customer and how much they spent.For countries where the top amount spent is shared ,provide all customers who spent this amount.

WITH RECURSIVE
	customer_with_country AS(
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
        FROM invoice
        JOIN customer ON customer.customer_id=invoice.customer_id
        GROUP BY 1,2,3,4
        ORDER BY 2,3 DESC),
        
	country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
        FROM customer_with_country
        GROUP BY billing_country)
        
	SELECT cc.billing_country,cc.total_spending,cc.first_name,cc.last_name,cc.customer_id
    FROM customer_with_country cc
    JOIN country_max_spending ms
    ON cc.billing_country=ms.billing_country
    WHERE cc.total_spending=ms.max_spending
    ORDER BY 1;
    
    #Method 2-
    
    WITH Customer_with_country AS(
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
        ROW_NUMBER() OVER (PARTITION BY billing_country ORDER BY SUM(total)DESC) AS RowNo
        FROM invoice
        JOIN customer on customer.customer_id=invoice.customer_id
        GROUP BY 1,2,3,4
        ORDER BY 4 ASC,5 DESC)
	SELECT * FROM customer_with_country WHERE RowNo<=1
        
    
		
	
	

