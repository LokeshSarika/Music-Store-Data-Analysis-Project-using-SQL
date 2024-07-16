use music_store;

select 
first_name,
last_name
from employee
order by levels desc
limit 1;

select * from invoice;

select 
billing_country,
count(invoice_id) as count
from invoice
group by billing_country
order by count desc
limit 1;

select 
total
from invoice
order by total desc
limit 3;

select 
billing_city,
sum(total) as Invoice_totals
from invoice 
group by billing_city
order by Invoice_totals desc
limit 1;

select 
customer.*,
sum(invoice.total) as Invoice_totals
from customer 
join invoice 
on customer.customer_id=invoice.customer_id
group by invoice.customer_id
order by Invoice_totals desc
limit 1;

select 
customer.email,
customer.first_name,
customer.last_name,
genre.name
from customer 
join invoice on customer.customer_id=invoice.customer_id
join  invoice_line on invoice.invoice_id=invoice_line.invoice_id
join track on invoice_line.track_id=track.track_id
join genre on track.genre_id=genre.genre_id
where genre.name='rock'
group by customer.email
order by customer.email 
limit 10;


SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;




SELECT
artist.artist_id,
artist.name,
count(artist.artist_id) as no_of_songs
from track 
join album on   album.album_id=track.album_id
join artist on artist.artist_id = album.artist_id
join genre on track.genre_id = genre.genre_id
where genre.name like 'rock'
group by artist.artist_id
order by no_of_songs desc
limit 10;


select 
name ,
milliseconds
from track 
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc;

select 
customer.first_name, customer.last_name, artist.name as artist_name, sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
from customer 
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join album on track.album_id = album.album_id
join artist on artist.artist_id = album.artist_id
group by customer.first_name, customer.last_name, artist.name
order by total_sales desc;

WITH best_selling_artist AS (
SELECT artist.artist_id AS artist_id, artist.name AS artist_name, 
SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
 FROM invoice_line
JOIN track ON track.track_id = invoice_line.track_id
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
GROUP BY 1
ORDER BY 3 DESC
limit 1
)

SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id= i.customer_id
JOIN invoice_line il ON il.invoice_id= i.invoice_id
JOIN track t ON t.track_id= il.track_id
JOIN album alb ON alb.album_id=t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;


with popular_genre as
(select 
customer.country as country, genre.name as genre_name, count(invoice_line.quantity),
row_number() over( partition by customer.country order by count(invoice_line.quantity) desc) as rollno
from invoice_line
JOIN invoice ON invoice.Invoice_id=invoice_line.invoice_id
JOIN customer ON customer.customer_id = invoice.customer_id
JOIN track ON track.track_id=invoice_line.track_id
JOIN genre ON genre.genre_id= track.genre_id
GROUP BY 1
ORDER BY 3 DESC )
select country, genre_name
from popular_genre where rollno=1;

with recursive 
customer_consume
as
(select customer.country as country, customer.customer_id as c_id, customer.first_name as f_n, customer.last_name as l_n , sum(invoice.total) as total,
row_number() over(partition by customer.country order by sum(invoice.total) desc) as roll_num
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

select customer.country as country, customer.customer_id as c_id, customer.first_name as f_n, customer.last_name as l_n , sum(invoice.total),
row_number() over(partition by customer.country order by sum(invoice.total) desc) as roll_num
from customer
join invoice on invoice.customer_id = customer.customer_id
group by c_id
order by sum(invoice.total) desc