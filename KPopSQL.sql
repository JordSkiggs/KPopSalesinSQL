-- Using a dataset found on Kaggle
-- I will be analysing sales data for 4th Generation K-Pop groups
-- Showing some of my SQL understanding and knowledge throughout

-- Firstly, I want to see the data I am working with. So I select all from the imported table

SELECT *
FROM KPopSales

-- There are many questions that can be asked about this data here are a few that come to mind

-- What are the Top 10 Albums by Sales?

SELECT TOP(10) *
From KPopSales	
ORDER BY sales DESC

-- Using the TOP function and the ORDER BY function I can easily see the top 10 albums and their respective data

-- Which Artist has the most sales?

SELECT Artist, SUM(sales) AS SalesSum
FROM KPopSales
GROUP BY Artist
ORDER BY SalesSum DESC

-- Using the SUM aggregate function with an alias and ordering by the alias, I can see that IZONE has
-- the most sales in this table with 2,356,819 closely followed by Stray Kids with 1,916,965

-- Which year had the best selling sales?

SELECT Year(date), SUM(sales) AS SalesSum
FROM KPopSales
GROUP BY Year(date)
ORDER BY SalesSum DESC

-- Using the YEAR function to distinguish the year from the data column, I can group by the year
-- and can see that 2020 was a much better year for sales than any other year, nearly tripling 
-- 2nd places figures

-- What is each artists best selling Korean album? 

SELECT a.artist, a.title, a.sales
FROM KPopSales a
INNER JOIN (
    SELECT Artist, MAX(sales) AS maxsales
    FROM KPopSales
	WHERE country = 'KOR'
    GROUP BY Artist
) b ON a.sales = b.maxsales
ORDER BY maxsales DESC

-- To be able to see all the album that had the most sales for the artist I had to use a self join on the table
-- to be able to select the columns I wanted to view. Then using the Where function to distinguish Korean albums
-- and the MAX function to find the top selling album, I can see each artists best selling album. With IZONE's Oneiric Diary
-- having the best selling album of all of them with 559,138 closely followed by TXY's Blue Hour

-- What percantage of sales does each group contribute to the total sales in the database?

SELECT Artist,SUM(sales),
       ROUND(SUM(sales) * 100.0 / SUM(SUM(sales)) OVER (),2) AS Percentage
FROM KPopSales
GROUP BY Artist
ORDER BY Percentage DESC;

-- Using a window function to be able to use the total sales of every album, and the ROUND function to 
-- keep the percantage to 2 decimal places I can see that IZONE's percentage is just over 20% when
-- Everglow only takes up 1.23% of total sales and Ateez with 14.11%

-- Now how about finding the percentage of sales for each album for each artists?

SELECT Artist, title,SUM(sales) AS SumSales,
       ROUND(SUM(sales) * 100.0 / SUM(SUM(sales)) OVER (PARTITION BY Artist),2) AS Percentage
FROM KPopSales
GROUP BY Artist,title
ORDER BY Artist, Percentage DESC;

-- Using a similar query to above but adding a PARTITION BY to show only the artists max sales and
-- percentages, I can easily see that ATEEZ's Zero: Fever Part 1 takes up 24.6% of their total sales
-- and Stray Kids' Miroh takes up 12.11 of their total sales

-- I want to be able to see only the albums that have done the best out of the entire dataset, and doing 4% or 
-- more of the total sales in the dataset

WITH AlbumSales AS 
(
SELECT Artist,title,SUM(sales) AS SumSales,
       ROUND(SUM(sales) * 100.0 / SUM(SUM(sales)) OVER (),2) AS Percentage
FROM KPopSales
GROUP BY Artist, title
)

SELECT *
FROM AlbumSales
WHERE Percentage > 4
ORDER BY Percentage DESC

-- By using a CTE to be able to use the SalesSum and Percentage variables even further, I can then
-- use a simply WHERE to find the albums that have particularly done well. Stray Kids, TXT and IZONE
-- are the only artists to have more than 4% of the total sales and therefore are some of the best selling
-- albums of the year