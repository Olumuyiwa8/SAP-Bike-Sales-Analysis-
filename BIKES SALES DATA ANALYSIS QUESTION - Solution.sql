CREATE database bike_sales;

alter table addresses
rename column ï»¿ADDRESSID to ADDRESSID;

-- Products Analysis
-- Q1: Find the total number of products for each product category
select PRODCATEGORYID, SHORT_DESCR, count(*) as TOTAL_NO_PRODUCT 
from products p left join productcategorytext pct
using (PRODCATEGORYID) 
group by PRODCATEGORYID, SHORT_DESCR;

-- Q2: List the top 5 most expensive products
select PRODCATEGORYID, SHORT_DESCR, PRICE as TOTAL_nO_PRODUCT 
from products p left join productcategorytext pct
using (PRODCATEGORYID) 
group by PRODCATEGORYID, SHORT_DESCR, PRICE
order by PRICE desc
limit 5;

-- Q3: Find all products that belong to the 'Mountain Bike' category
select PRODCATEGORYID, SHORT_DESCR
from products p left join productcategorytext pct
using (PRODCATEGORYID)
where SHORT_DESCR = 'Mountain Bike';

-- Q4: List the total sales amount (gross) for each product category
select PRODCATEGORYID, sum(GROSSAMOUNT) as Total_sales 
from products p left join salesorderitems soi
using(PRODUCTID)
group by PRODCATEGORYID
order by Total_sales desc;

-- Q7: List the top 5 suppliers by total product sales.
select SUPPLIER_PARTNERID, sum(GROSSAMOUNT) as Total_sales 
from products p left join salesorderitems soi
using(PRODUCTID)
group by SUPPLIER_PARTNERID
order by Total_sales desc
limit 5;

-- Q6: Find the total number of products created by each employee
select distinct CREATEDBY, concat(NAME_FIRST,' ', NAME_LAST, ' ', NAME_MIDDLE) full_name, count(CREATEDBY) as no_of_products
from products p left join employees e
on p.CREATEDBY = e.EMPLOYEEID
group by CREATEDBY, NAME_FIRST, NAME_LAST, NAME_MIDDLE
order by no_of_products desc;

-- Q7: List the employees who have changed product details the most
select distinct CHANGEDBY, concat(NAME_FIRST,' ', NAME_LAST, ' ', NAME_MIDDLE) as full_name, count(CHANGEDBY) as no_of_products
from products p left join employees e
on p.CHANGEDBY = e.EMPLOYEEID
group by CHANGEDBY, NAME_FIRST, NAME_LAST, NAME_MIDDLE
order by no_of_products desc;

-- Sales Orders Items Analysis
-- Q8: Calculate the total gross amount for each sales order.
select SALESORDERID, sum(GROSSAMOUNT) as total_gross_amount 
from salesorders
group by SALESORDERID;

-- Q9: Trend in sales over different fiscal year periods
update salesorders
set FISCALYEARPERIOD = str_to_date(concat(left(FISCALYEARPERIOD, 4), '-', right(FISCALYEARPERIOD,3)), '%Y-%j');
alter table salesorders
modify column FISCALYEARPERIOD date;

select year(FISCALYEARPERIOD) as 'Year', sum(NETAMOUNT) sum_net_amount
from salesorders
group by year(FISCALYEARPERIOD);

-- Q10: Which products contribute the most to revenue when the billing status is 'Complete'
select p.PRODUCTID, so.BILLINGSTATUS, sum(so.NETAMOUNT) as netamout_reveue  from salesorders so left join salesorderitems soi  
using (SALESORDERID) 
left join products p
using (PRODUCTID)
where BILLINGSTATUS = 'C'
group by PRODUCTID, BILLINGSTATUS
order by netamout_reveue desc;

-- Q11: Find the sales order items for a specific product ID.
select * from salesorderitems 
where PRODUCTID = 'MB-1034';

-- Sales Orders Analysis
-- Q12: How does revenue vary over different fiscal year periods for orders with a billing status of 'Complete'
select soi.PRODUCTID, so.BILLINGSTATUS, sum(soi.NETAMOUNT * QUANTITY) as netamout_reveue, year(so.FISCALYEARPERIOD) as 'Year'  
from salesorders so left join salesorderitems soi  
using (SALESORDERID) 
where BILLINGSTATUS = 'C'
group by PRODUCTID, BILLINGSTATUS, Year
order by netamout_reveue desc;

-- Q13: Find the top-selling product within each category along with its total sales amount.
with Top_selling as(
select p.PRODCATEGORYID, soi.PRODUCTID, SHORT_DESCR, soi.CURRENCY, sum(p.PRICE * QUANTITY) as netamount_revenue  
from salesorders so left join salesorderitems soi  
using (SALESORDERID) 
left join products p
using (PRODUCTID)
left join productcategorytext pct
using (PRODCATEGORYID)
group by PRODCATEGORYID, PRODUCTID, SHORT_DESCR, CURRENCY
order by netamount_revenue), Top_Ranking_sales as(
select *, rank() over(partition by PRODCATEGORYID order by netamount_revenue desc) as 'net_revenue_rank'
from Top_selling)
select PRODCATEGORYID, PRODUCTID, SHORT_DESCR, CURRENCY, netamount_revenue
from Top_Ranking_sales where net_revenue_rank = 1;

-- Q14: Calculate the total gross amount for each sales organization.
select PARTNERID, COMPANYNAME, sum(GROSSAMOUNT) as total_gross_amount from salesorders so left join businesspartners bp
using (PARTNERID)
group by PARTNERID, COMPANYNAME
order by COMPANYNAME
rank();

-- Q15: Find the top 5 sales orders by net amount.
select SALESORDERID, CURRENCY, sum(NETAMOUNT) as total_netamount from salesorders
group by SALESORDERID, CURRENCY
order by total_netamount desc
limit 5;

-- Q16: How many sales orders were created in the year 2018?
select count(*) from salesorders where year(FISCALYEARPERIOD) = 2018;


-- Business Partners Analysis
-- Q17: How many business partners are there for each partner role?
with PARTNER_ROLE as (select PARTNERID, PARTNERROLE  from businesspartners)
select PARTNERROLE, count(PARTNERID) as No_of_Partners
from PARTNER_ROLE
group by PARTNERROLE;

-- Q18: List the top 5 companies with the most recent creation dates.
select * from businesspartners;

-- Employees Analysis
-- Q19: Find the number of employees for each sex.
select SEX, count(*) as No_of_employee  
from employees
group by SEX;

-- Q20: List the employees who have 'W' in their first name 
select NAME_FIRST, NAME_MIDDLE, NAME_LAST from employees
where NAME_FIRST like '%W%';

select NAME_FIRST, NAME_MIDDLE, NAME_LAST from employees
where NAME_FIRST regexp 'W';


-- Product Categories Analysis
-- Q21: List all product categories along with their descriptions.
select PRODCATEGORYID, SHORT_DESCR  from productcategorytext;

-- Q22: Find all products that belong to the 'Mountain Bike' category.
select PRODUCTID, PRODCATEGORYID, SHORT_DESCR from products p left join productcategorytext pct
using (PRODCATEGORYID)
where SHORT_DESCR = 'Mountain Bike';

-- Addresses Analysis
-- Q23: Count the number of addresses in each country.
select COUNTRY, count(*) as No_of_addresses 
from addresses
group by COUNTRY;

-- Q24: List all addresses in a specific city, e.g., 'New York'.
select concat(BUILDING,',', ' ', STREET) as street_address, CITY, COUNTRY
from addresses
order by CITY;

-- Q25: Find the number of business partners in each region.
select REGION, count(PARTNERID) as no_of_parter from businesspartners bp left join addresses a
using (ADDRESSID)
group by REGION;

-- Q26: List all addresses associated with a specific business partner.
select ADDRESSID, COMPANYNAME, PARTNERID, EMAILADDRESS, PHONENUMBER, WEBADDRESS from businesspartners bp left join addresses a
using (ADDRESSID);

-- Combining Data from Multiple Tables
-- Q27: List the top 5 employees who have created the most sales orders.
select distinct CREATEDBY, concat(NAME_FIRST,' ', NAME_LAST, ' ', NAME_MIDDLE) as full_name, count(CREATEDBY) as no_of_products
from products p left join employees e
on p.CREATEDBY = e.EMPLOYEEID
group by CREATEDBY, NAME_FIRST, NAME_LAST, NAME_MIDDLE
order by no_of_products desc;

-- Sales Orders Items Analysis
-- Q8: Calculate the total gross amount for each sales order.



-- Q28: Find the total sales amount (gross) for each product category.
select SALESORDERID, sum(GROSSAMOUNT) as total_gross_amount 
from salesorders
group by SALESORDERID;

select PRODCATEGORYID, soi.CURRENCY, sum(price*QUANTITY) as total_gross_amount from salesorderitems soi left join products p
using (PRODUCTID)
group by PRODCATEGORYID, CURRENCY










