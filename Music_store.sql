DROP DATABASE IF EXISTS Music_store;
CREATE DATABASE Music_store;
USE Music_store;

-- **** Creating Tables ****

DROP TABLE IF EXISTS employee;

CREATE TABLE employee(
employee_id INT PRIMARY KEY AUTO_INCREMENT,
last_name VARCHAR(20),
first_name VARCHAR(20),
title VARCHAR(50),
reports_to INT,
levels VARCHAR(20),
birthdate DATE,
hire_date DATE,
address VARCHAR(50),
city VARCHAR(50),
state VARCHAR(50),
country VARCHAR(50),
postal_code VARCHAR(50),
phone VARCHAR(200),
fax VARCHAR(200),
email VARCHAR(200));


DROP TABLE IF EXISTS media_type;

CREATE TABLE media_type(
media_type_id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(30));


DROP TABLE IF EXISTS genre;

CREATE TABLE genre(
genre_id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(30));


DROP TABLE IF EXISTS playlist;

CREATE TABLE playlist(
playlist_id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(30));


DROP TABLE IF EXISTS artist;

CREATE TABLE artist(
artist_id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(200));


DROP TABLE IF EXISTS customer;

CREATE TABLE customer(
customer_id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(30),
last_name VARCHAR(30),
comapny VARCHAR(50),
address VARCHAR(50),
city VARCHAR(50),
state VARCHAR(50),
country VARCHAR(50),
postal_code VARCHAR(50),
phone VARCHAR(200),
fax VARCHAR(200),
email VARCHAR(200),
support_rep_id INT,
FOREIGN KEY (support_rep_id) REFERENCES employee(employee_id));


DROP TABLE IF EXISTS invoice;

CREATE TABLE invoice(
invoice_id INT PRIMARY KEY AUTO_INCREMENT,
customer_id INT,
FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
invioce_date DATE,
billing_address VARCHAR(200),
billing_city VARCHAR(30),
billing_state VARCHAR(30),
billing_country VARCHAR(50),
billing_postal_code VARCHAR(50),
total INT);


DROP TABLE IF EXISTS album;

CREATE TABLE album(
album_id INT PRIMARY KEY AUTO_INCREMENT,
title VARCHAR(200),
artist_id INT,
FOREIGN KEY (artist_id) REFERENCES artist(artist_id));


DROP TABLE IF EXISTS track;

CREATE TABLE track(
track_id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(200),
album_id INT,
FOREIGN KEY (album_id) REFERENCES album(album_id),
media_type_id INT,
FOREIGN KEY (media_type_id) REFERENCES media_type(media_type_id),
genre_id INT,
FOREIGN KEY (genre_id) REFERENCES genre(genre_id),
composer VARCHAR(200),
milliseconds BIGINT,
bytes BIGINT,
unit_price INT);


DROP TABLE IF EXISTS invoice_line;

CREATE TABLE invoice_line(
invoice_line_id INT PRIMARY KEY AUTO_INCREMENT,
invoice_id INT,
FOREIGN KEY (invoice_id) REFERENCES invoice(invoice_id),
track_id INT,
FOREIGN KEY (track_id) REFERENCES track(track_id),
unit_price INT,
quantity INT);


DROP TABLE IF EXISTS playlist_track;

CREATE TABLE playlist_track(
playlist_id INT,
FOREIGN KEY (playlist_id) REFERENCES playlist(playlist_id),
track_id INT,
FOREIGN KEY (track_id) REFERENCES track(track_id));


-- To retrieve all the data from tables
SELECT * FROM employee;
SELECT * FROM media_type;
SELECT * FROM genre;
SELECT * FROM playlist;
SELECT * FROM artist;
SELECT * FROM customer;
SELECT * FROM invoice;
SELECT * FROM track;
SELECT * FROM invoice_line;
SELECT * FROM album;
SELECT * FROM playlist_track;


-- ************** Question and Answers **************

-- 1. Which employee has the highest total sales?
SELECT 
    CONCAT(e.First_name, ' ', e.Last_name) AS Employee,
    SUM(Unit_Price * Quantity) AS TotalSales
FROM
    Invoice_line
        JOIN
    Invoice USING (Invoice_id)
        JOIN
    Customer c USING (Customer_id)
        JOIN
    Employee e ON e.Employee_id = c.Support_rep_id
GROUP BY e.First_name , e.Last_name
ORDER BY TotalSales DESC
LIMIT 1;



-- 2. Who is the senior most employee based on level?
SELECT 
    CONCAT(Last_name, ' ', First_name) AS Employee,
    Title AS Job_Title
FROM
    Employee
ORDER BY Levels DESC
LIMIT 1;



-- 3. Which country has the most Invoices?
SELECT 
    Country, COUNT(Country) AS Invoices
FROM
    Customer
        JOIN
    Invoice USING (Customer_id)
GROUP BY Country
ORDER BY Invoices DESC
LIMIT 1;



-- 4. What are the top 3 values of total invoice?
SELECT 
    Total
FROM
    Invoice
ORDER BY Total DESC
LIMIT 3;



-- 5. what is the count of customers across different countries? 
SELECT 
    Country, COUNT(DISTINCT Customer_Id) AS Customer_Count
FROM
    Customer
GROUP BY Country
ORDER BY Customer_Count DESC;



-- 6. Which city has the best customers? Write a query that returns one city that has the highest sum of invoice totals.
SELECT 
    City, SUM(Total) AS sum
FROM
    Customer
        JOIN
    Invoice USING (Customer_Id)
GROUP BY City
ORDER BY sum DESC
LIMIT 1;



-- 7. Who is the best customer? Write a query that returns the person who has spent the most money.
SELECT 
    CONCAT(First_name, ' ', Last_name) AS Customer,
    SUM(Total) AS Money_spent
FROM
    CustomerS
        JOIN
    Invoice USING (Customer_id)
GROUP BY First_name , Last_name
ORDER BY Money_spent DESC
LIMIT 1;



-- 8.How many customers make repeat purchases?
SELECT 
    COUNT(*) AS no_of_repeat_customers
FROM
    (SELECT 
        Customer_Id, COUNT(Invoice_Id) AS PurchaseCount
    FROM
        Invoice
    GROUP BY Customer_Id
    HAVING PurchaseCount > 1) AS repeat_customer_count;



-- 9. Write a query that returns the Artist name and total track count of the top 10 rock bands.
SELECT 
    a.Name, COUNT(*) Track_count
FROM
    Artist a
        JOIN
    Album USING (Artist_id)
        JOIN
    Track USING (Album_id)
        JOIN
    Genre g USING (Genre_id)
WHERE
    g.Name = 'rock'
GROUP BY a.Name
ORDER BY Track_count DESC
LIMIT 10;



-- 10. What are the Top 10 selling tracks?  
SELECT 
    t.Name, SUM(il.quantity) AS SalesCount
FROM
    Invoice_Line AS il
        JOIN
    Track AS t USING (track_id)
GROUP BY t.name
ORDER BY SalesCount DESC
LIMIT 10;



-- 11. Find out the most popular music genre based on the quantity purchased?
SELECT 
    g.name, SUM(il.quantity) AS Quantity_purchased
FROM
    genre AS g
        JOIN
    track USING (genre_id)
        JOIN
    invoice_line AS il USING (track_id)
GROUP BY g.name
ORDER BY Quantity_purchased DESC
LIMIT 1;




-- 12. Find out the least popular music genre based on the quantity purchased?
SELECT 
    g.name, SUM(il.quantity) AS Quantity_purchased
FROM
    genre AS gS
        JOIN
    track USING (genre_id)
        JOIN
    invoice_line AS il USING (track_id)
GROUP BY g.name
ORDER BY Quantity_purchased
LIMIT 1;



-- 13. Find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. 
with cte as (select i.billing_country as country,g.name as genre,row_number() over (partition by i.billing_country order by sum(quantity) desc) as ranking from genre as g
join track using (genre_id)
join invoice_line using(track_id)
join invoice as i using(invoice_id)
group by g.name,i.billing_country)
select country,genre from cte
where ranking =1;



-- 14. Which tracks have shorter durations?.Suggest 10 short music tracks to your customers
SELECT 
    name, milliseconds
FROM
    track
ORDER BY milliseconds ASC
LIMIT 10;



-- 15. Which tracks have longer durations?.Suggest 10 long music tracks to your customers
SELECT 
    name, milliseconds
FROM
    track
ORDER BY milliseconds DESC
LIMIT 10;



-- 16. Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A.
SELECT 
    c.first_name, c.last_name, c.email, g.name
FROM
    customer c
        JOIN
    invoice USING (customer_id)
        JOIN
    invoice_line USING (invoice_id)
        JOIN
    track USING (track_id)
        JOIN
    genre g USING (genre_id)
WHERE
    g.name = 'Rock'
ORDER BY c.email ASC;



-- 17. Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first
SELECT 
    name, milliseconds
FROM
    track
WHERE
    milliseconds > (SELECT 
            AVG(milliseconds)
        FROM
            track)
ORDER BY milliseconds DESC;



-- 18.Find how much amount is spent by each customer on artists? Write a query to return customer name, artist name and total spent
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) Customer_name,
    a.name,
    SUM(i.total) Total_spent
FROM
    customer c
        JOIN
    invoice AS i USING (customer_id)
        JOIN
    invoice_line USING (invoice_id)
        JOIN
    track USING (track_id)
        JOIN
    album USING (album_id)
        JOIN
    artist a USING (artist_id)
GROUP BY c.first_name , c.last_name , a.name;



-- 19. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount.
with cte as 
(select concat(first_name," ",last_name) customers,country,sum(total) amount_spent from customer
join invoice using (customer_id)
join invoice_line using(invoice_id)
join track using(track_id)
join genre using(genre_id) 
group by first_name,last_name,country
order by amount_spent desc)
select *,dense_rank() over (order by amount_spent desc) as Rank1 from cte
order by rank1 ;



-- 20. Find out the total number of units sold for each track? 
SELECT 
    t.Name, SUM(il.quantity) AS SalesCount
FROM
    Invoice_Line AS il
        JOIN
    Track AS t USING (track_id)
GROUP BY t.name
ORDER BY SalesCount DESC;