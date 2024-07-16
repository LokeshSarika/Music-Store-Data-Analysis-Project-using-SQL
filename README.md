# Music-Store-Data-Analysis-Project-using-SQL


## Introduction
Comprehensive data analysis project focusing on a music store, utilizing SQL to extract, clean, and analyse vast datasets. 
By querying the database, I uncovered valuable insights into sales trends, customer preferences, and inventory management, enabling strategic decision-making.
Through this project, I honed my skills in data manipulation, interpretation, demonstrating a strong aptitude for leveraging data to drive business objectives effectively.


## Data

### Tables Used:
1. **album**: Contains information about albums in the store.
2. **artist**: Provides details about the artists of the albums.
3. **cc_detail**: Includes credit card details used for payments in invoices.
4. **customer**: Stores customer information such as names, addresses, and email contacts.
5. **employee**: Contains details about store employees.
6. **genre**: Lists different music genres available in the store.
7. **invoice**: Contains invoice details, including billing address, invoice date, and total.
8. **invoice_line**: Provides line-by-line details of items purchased in each invoice.
9. **media_type**: Describes different media types available for tracks.
10. **playlist**: Stores playlists created by customers or store managers.
11. **playlist_track**: Maps tracks to playlists, linking playlists with their respective tracks.
12. **track**: Contains information about individual tracks available for purchase.

### Data Sources:
- The dataset used in this project is sourced from a relational database representing a music store's operations.
- It includes comprehensive data on sales transactions, customer interactions, and inventory management.


## Music store query:
### Q1: Who is the senior most employee based on job title?
           select first_name, last_name
           from employee
           order by levels desc
           limit 1;
### Q2: Which countries have the most Invoices?
           select billing_country, count(invoice_id) as count
           from invoice
           group by billing_country
           order by count desc
           limit 1;
### Q3: What are top 3 values of total invoice?
           select total
           from invoice
           order by total desc
           limit 3;
### Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money.Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals.
           select billing_city, sum(total) as Invoice_totals
           from invoice 
           group by billing_city
           order by Invoice_totals desc
           limit 1;
### Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money.
           select customer.*, sum(invoice.total) as Invoice_totals
           from customer 
           join invoice 
           on customer.customer_id=invoice.customer_id
           group by invoice.customer_id
           order by Invoice_totals desc
           limit 1;
### Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A.
           select customer.email, customer.first_name, customer.last_name, genre.name
           from customer 
           join invoice on customer.customer_id=invoice.customer_id
           join  invoice_line on invoice.invoice_id=invoice_line.invoice_id
           join track on invoice_line.track_id=track.track_id
           join genre on track.genre_id=genre.genre_id
           where genre.name='rock'
           group by customer.email
           order by customer.email 
           limit 10;
### Q7: Let's invite the artists who have written the most rock music in our dataset.Write a query that returns the Artist name and total track count of the top 10 rock bands.
           SELECT artist.artist_id, artist.name, count(artist.artist_id) as no_of_songs
           from track 
           join album on   album.album_id=track.album_id
           join artist on artist.artist_id = album.artist_id
           join genre on track.genre_id = genre.genre_id
           where genre.name like 'rock'
           group by artist.artist_id
           order by no_of_songs desc
           limit 10;
### Q8: Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.
           select name, milliseconds
           from track 
           where milliseconds > (select avg(milliseconds) from track)
           order by milliseconds desc;
### Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent
           WITH best_selling_artist AS (
	                                      SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	                                      FROM invoice_line
                                        JOIN track ON track.track_id = invoice_line.track_i
                                        JOIN album ON album.album_id = track.album_id 
                                        JOIN artist ON artist.artist_id = album.artist_id                               
	                                      GROUP BY 1
	                                      ORDER BY 3 DESC
	                                      LIMIT 1
                                        )
                                        
           SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
           FROM invoice i
           JOIN customer c ON c.customer_id = i.customer_id
           JOIN invoice_line il ON il.invoice_id = i.invoice_id
           JOIN track t ON t.track_id = il.track_id
           JOIN album alb ON alb.album_id = t.album_id
           JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id          
           GROUP BY 1,2,3,4
           ORDER BY 5 DESC;
### Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres.
           with popular_genre as (
                                  select customer.country as country, genre.name as genre_name, count(invoice_line.quantity), row_number() over( partition by customer.country order by count(invoice_line.quantity) desc) as rollno
                                  from invoice_line
                                  JOIN invoice ON invoice.Invoice_id=invoice_line.invoice_id
                                  JOIN customer ON customer.customer_id = invoice.customer_id
                                  JOIN track ON track.track_id=invoice_line.track_id
                                  JOIN genre ON genre.genre_id= track.genre_id
                                  GROUP BY 1
                                  ORDER BY 3 DESC
                                  )
           select country, genre_name 
           from popular_genre
           where rollno=1;
### Q11: Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount.
           with recursive customer_consume as (
                                               select customer.country as country, customer.customer_id as c_id, customer.first_name as f_n, customer.last_name as l_n , sum(invoice.total) as total, row_number() over(partition by customer.country order by sum(invoice.total) desc) as roll_num
                                               from customer
                                               join invoice on invoice.customer_id = customer.customer_id
                                               group by c_id
                                               order by sum(invoice.total) desc
                                               )
          select country, c_id, f_n, l_n, total
          from customer_consume
          where roll_num=1
          order by c_id
          ;


