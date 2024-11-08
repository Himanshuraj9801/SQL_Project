----------------------------create___database------------------------------------------------------------------
create database walmartsalesdata1

-------------------------------use___Database-------------------------------------------------------------------
use walmartsalesdata1

------------------------------create___table__using__CSV___file-------------------------------------------------

create table Sales_data(invoice_id VARCHAR(20),
    branch VARCHAR(10),
    city VARCHAR(50),
    customer_type VARCHAR(10),
    gender VARCHAR(10),
    product_line VARCHAR(50),
    unit_price DECIMAL(10, 2),
    quantity INT,
    tax DECIMAL(10, 2),
    total DECIMAL(10, 2),
    date_str VARCHAR(10), 
    time TIME,
    payment VARCHAR(20),
    cogs DECIMAL(10, 2),
    gross_margin_percentage DECIMAL(10, 2),
    gross_income DECIMAL(10, 2),
    rating DECIMAL(10, 2)
);

----------------------------show___Table-------------------------------------------------------------------------

select * from Sales_data

---------------------------insert_____data____in___the___table___by___CSV___file--------------------------------------------------

load data infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\WalmartSalesData.csv'
into table Sales_data
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 lines;

----------------------------show___Table__Data-------------------------------------------------------------------------

select * from Sales_data

----1__Add__new__column__named`time_of_day`__to__give__insight__of sales__in the Morning, Afternoon Evening.----------

Alter Table Sales_data Add Column time_of_day varchar(20)

set SQL_SAFE_UPDATES=0

Update Sales_Data set time_of_day = CASE
    WHEN TIME(time) >= '06:00:00' AND TIME(time) < '12:00:00' THEN 'Morning'
    WHEN TIME(time) >= '12:00:00' AND TIME(time) < '16:00:00' THEN 'Afternoon'
    ELSE 'Evening'
END;

select * from Sales_data

------2__Add__new__column __named `day_name` that__contains the extracted days__of the__week__on which the
 given__transaction took place (Mon, Tue, Wed, Thur, Fri). 
 
Alter Table Sales_data Add Column day_name varchar(20)

Update Sales_data
SET day_name = CASE DAYOFWEEK(STR_TO_DATE(date_str, '%d-%m-%Y'))
    WHEN 1 THEN 'Sunday'
    WHEN 2 THEN 'Monday'
    WHEN 3 THEN 'Tuesday'
    WHEN 4 THEN 'Wednesday'
    WHEN 5 THEN 'Thursday'
    WHEN 6 THEN 'Friday'
    WHEN 7 THEN 'Saturday'
END;

------- 3__Add anewcolumnnamed`month_name` that__contains the extracted months__of the__year__on which__the given__transaction took place (Jan, Feb, Mar). 

alter table Sales_data Add Column month_name varchar(20)

Update Sales_data 
	SET month_name = CASE MONTH(STR_TO_DATE(date_str, '%d-%m-%Y'))
    WHEN 1 THEN 'Jan'
    WHEN 2 THEN 'Feb'
    WHEN 3 THEN 'Mar'
    WHEN 4 THEN 'Apr'
    WHEN 5 THEN 'May'
    WHEN 6 THEN 'Jun'
    WHEN 7 THEN 'Jul'
    WHEN 8 THEN 'Aug'
    WHEN 9 THEN 'Sep'
    WHEN 10 THEN 'Oct'
    WHEN 11 THEN 'Nov'
    WHEN 12 THEN 'Dec'
END;

SET SQL_SAFE_UPDATES = 1;

select * from Sales_data
---------------------------------------------------------------------------------------------------------------------

---------------- Generic Question----------------------------------------------------------------

------Q1__1. How many__unique cities does the_data have?------------------------------------------
select count(distinct(city)) from 

------Q2---In_which city_is_each branch?-----------------------------------------------------------------

select distinct branch,city from Sales_data

-----------------------------------------Product-------------------------------------------------------------

select * from Sales_data

---Q1---How many__unique product__lines does the__data have----------------------------------------------------

Select distinct product_line from Sales_data

Select count(distinct product_line) from Sales_data

---Q2--- What__is__the most common payment method----------------------------------------------------------------

select count(*),Payment as pay_count from Sales_data group by Payment order by pay_count desc

----Q3---What--is the most selling product line?----------------------------------------------------------------

select product_line,sum(quantity) as total_sale from Sales_data group by product_line order by total_sale desc

----Q4--- What --is the total revenue--by--month?-----------------------------------------------------------

select month_name,sum(gross_income) as Total_Revenue from Sales_data group by month_name order by Total_Revenue desc

----Q5---What__month had the largest COGS---------------------------------------------------------------------------

select month_name,sum(cogs) as largest_cogs from Sales_data group by month_name 

-----Q_6----What product line had the largest revenue?----------------------------------------------------------------

select product_line,sum(total) as large_revenue from Sales_data group by product_line

----Q--7-------What--is the city--with the largest revenue?--------------------------------------------------------

select  city,sum(total) as large_revenue from Sales_data group by city order by large_revenue desc


----Q--8--- What product line had the largest VAT-------------------------------------------------------------------

select product_line,sum(tax) as largest_VAT from Sales_data group by product_line order by largest_VAT desc

----Q--9--Fetch_each product line_and_add a_column to those product line showing "Good", "Bad". Good if its
 greater_than average sale
 
 select product_line,
       SUM(total) as total_sales_amount,
       avg(total) as average_sales,
       case
           when SUM(total) > (select avg(total) from Sales_data) then 'Good'
           else 'Bad'
       end as status_of_product from Sales_data group by product_line;
                
 
 select * from Sales_data

---------Q--1_0------ Which branch sold more products than average product sold?-------------------------------------

select branch,sum(quantity) as product_sold from Sales_data group by branch

-----Q_11__What is the most common product line by gender?-------------------------------------------------------

select gender,product_line,count(product_line) as product_count from Sales_data group by gender,product_line order by gender,product_count

---Q--1_2----------------What is the average rating of each product line?---------------------------------------

select product_line,AVG(rating) as Rating from Sales_data group by product_line

-----------------------------------------------------Sales----------------------------------------------------------------------

-----Q_1_Number of sales made in each time of the day per weekday---------------------------------------------------

select time_of_day,day_name,count(*) as total_sales from Sales_data group by time_of_day,day_name 

----Q_2-----. Which of the customer types brings the most revenue ----------------------------------------------------

select customer_type,sum(total) as most_revenue from Sales_data group by customer_type order by most_revenue desc

----Q_3--- Which city has the largest tax percent/ VAT (**Value Added Tax**)?------------------------------------------

select city, sum(tax) as largest_tax from Sales_data group by city order by largest_tax desc

---Q_4---- Which customer type pays the most in VAT--------------------------------------------------------------------

select customer_type,sum(tax) as most_vat from Sales_data group by customer_type order by most_vat desc

-------------------------------------------CUSTOMER--------------------------------------------------------------------

--Q_1--How manyunique customer types does the data have?-------------------------------------------------------------

select count(distinct customer_type) as Unique_customer from Sales_data

---Q_2--- Howmanyunique payment methods does the data have------------------------------------------------------------

select count(distinct payment) as unique_payment from Sales_data

--Q_3----What is the most common customer type?--------------------------------------------------------------------

select count(*) as common_cust,customer_type from Sales_data group by customer_type order by common_cust

--Q_4--- Which customer type buys the most?----------------------------------------------------------------------

select customer_type,sum(quantity) as most_buy from Sales_data group by customer_type order by most_buy desc

--Q_5--What is the gender of most of the customers---------------------------------------------------------------

select count(*) as most_of_customer, gender from Sales_data group by gender order by most_of_customer desc

--Q_6---What is the gender distribution per branch?--------------------------------------------------------------

select count(*) as gender_count,branch,gender from Sales_data group by branch,gender order by branch

--Q_7---Which time of the day do customers give most ratings------------------------------------------------------

select time_of_day,sum(rating) as most_rating from Sales_data group by time_of_day order by most_rating desc

--Q_8--- Which time of the day do customers give most ratings per branch------------------------------------------

select branch,time_of_day,sum(rating) as most_rating from Sales_data group by branch,time_of_day order by most_rating,branch desc


--Q_9--Which day fo the week has the best avg ratings?-----------------------------------------------------------

select day_name,AVG(rating) as average_rating from Sales_data group by day_name order by average_rating desc

--Q_10--Which day of the week has the best average ratings per branch?-------------------------------------------

select day_name,branch,AVG(rating) as average_rating from Sales_data group by day_name,branch order by branch,average_rating desc