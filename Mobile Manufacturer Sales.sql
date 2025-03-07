
--Q1--BEGIN 
	
/* List all the states in which we have customers who have bought cellphones  
from 2005 till today.   */

select distinct [State] from (
select 
	  [State],
	  year([Date]) [Year]
from FACT_TRANSACTIONS t
join DIM_LOCATION l on t.IDLocation=l.IDLocation
where year([Date])>=2005
group by State,year([Date])
)as a




--Q1--END

--Q2--BEGIN
	
/*2 . What state in the US is buying the most 'Samsung' cell phones? 
state dim location ,country dim location ,mname dim manufacturer,quantity fact transactions              */

select top 1
      l.State,
	  sum(t.Quantity)[Quantity]
from DIM_LOCATION l
join FACT_TRANSACTIONS t on l.IDLocation=t.IDLocation
join DIM_MODEL mo on mo.IDModel=t.IDModel
join DIM_MANUFACTURER ma on mo.IDManufacturer=ma.IDManufacturer and Country='US'
where ma.Manufacturer_Name='Samsung'
group by l.State
order by [Quantity] desc



--Q2--END

--Q3--BEGIN      
	
 --Show the number of transactions for each model per zip code per state. 
 --count of trans-fact_T,grp by model name -dim_model,grp by zip code,state -dim_l

 select 
       
	   t.IDModel,
	   ZipCode,
	   State,
	   count(*)[Count]
 from FACT_TRANSACTIONS t
 join DIM_MODEL m on t.IDModel=m.IDModel
 join DIM_LOCATION l on t.IDLocation=l.IDLocation
 group by t.IDModel,State,ZipCode

--Q3--END

--Q4--BEGIN
-- . Show the cheapest cellphone (Output should contain the price also)

select top 1 Model_Name,
       Unit_price
from DIM_MODEL
order by Unit_price

--Q4--END

--Q5--BEGIN
/*Find out the average price for each model in the top5 manufacturers in  
terms of sales quantity and order by average price.  */
--unit price,idmodel -dim_model  ,id manufacturer,  quantity fact
select Manufacturer_Name,
       t.IDModel,
	   avg(TotalPrice)[Avg price]
	   
from FACT_TRANSACTIONS t
join DIM_MODEL mo on t.IDModel=mo.IDModel
join DIM_MANUFACTURER ma on ma.IDManufacturer=mo.IDManufacturer
where Manufacturer_Name in (
                    select top 5 sum(TotalPrice)[Sales]
                    from FACT_TRANSACTIONS t
                    join DIM_MODEL mo on t.IDModel=mo.IDModel
                    join DIM_MANUFACTURER ma on ma.IDManufacturer=mo.IDManufacturer
                    group by Manufacturer_Name
                    order by [Sales] desc)

group by t.IDModel,Manufacturer_Name



--Q5--END

--Q6--BEGIN
--List the names of the customers and the average amount spent in 2009,  
--where the average is higher than 500 
--customer name - dim_cus,avg()total price,date-fact transaction

select Customer_Name,
       AVG(TotalPrice) [Average amount]
from FACT_TRANSACTIONS t 
join DIM_CUSTOMER c on t.IDCustomer=c.IDCustomer
where year(Date)='2009'
group by Customer_Name
having  AVG(TotalPrice)>500



--Q6--END
	
--Q7--BEGIN  
/* List if there is any model that was in the top 5 in terms of quantity,  
simultaneously in 2008, 2009 and 2010  */	--model name - dim model,quantity,date - fact trans

select IDModel from (
select top 5 IDModel,
       sum(Quantity) as Quantity
from FACT_TRANSACTIONS
where YEAR(Date)=2008
group by IDModel 
order by Quantity desc) as top2008

intersect

select IDModel from 
(select top 5 IDModel,
       sum(Quantity) as Quantity
from FACT_TRANSACTIONS
where YEAR(Date)=2009
group by IDModel 
order by Quantity desc) as top2009

intersect

select IDModel from (
select top 5 IDModel,
       sum(Quantity) as Quantity
from FACT_TRANSACTIONS
where YEAR(Date)=2010
group by IDModel 
order by Quantity desc) as top2010

order by IDModel

--Q7--END	
--Q8--BEGIN
/*Show the manufacturer with the 2nd top sales in the year of 2009 and the  
manufacturer with the 2nd top sales in the year of 2010.  */ --idmanufacturer - dim manu,sum(total price),date-fact trans,
select * from (
select Manufacturer_Name,
       sum(TotalPrice) as totalprice
from FACT_TRANSACTIONS t 
join DIM_MODEL m on m.IDModel=t.IDModel
JOIN DIM_MANUFACTURER ma on ma.IDManufacturer=m.IDManufacturer
where year(Date)=2009
group by Manufacturer_Name
order by totalprice desc
OFFSET 1 rows fetch next 1 row only ) as t2009

union

select * from(
select Manufacturer_Name,
       sum(TotalPrice) as totalprice
from FACT_TRANSACTIONS t 
join DIM_MODEL m on m.IDModel=t.IDModel
JOIN DIM_MANUFACTURER ma on ma.IDManufacturer=m.IDManufacturer
where year(Date)=2010
group by Manufacturer_Name
order by totalprice desc
OFFSET 1 rows fetch next 1 row only ) as t2010















--Q8--END
--Q9--BEGIN
/* Show the manufacturers that sold cellphones in 2010 but did not in 2009.  */

select Manufacturer_Name    
from FACT_TRANSACTIONS t
join DIM_MODEL m on t.IDModel=m.IDModel
join DIM_MANUFACTURER ma on ma.IDManufacturer=m.IDManufacturer
where year(Date) =2010 
group by Manufacturer_Name

	
except


select Manufacturer_Name      
from FACT_TRANSACTIONS t
join DIM_MODEL m on t.IDModel=m.IDModel
join DIM_MANUFACTURER ma on ma.IDManufacturer=m.IDManufacturer
where year(Date) =2009
group by Manufacturer_Name



--Q9--END

--Q10--BEGIN
/*	 Find top 100 customers and their average spend, average quantity by each  
year. Also find the percentage of change in their spend. */

select * ,((avgprice-prevyearsales)/prevyearsales) as percentag from(
select *,LAG(avgprice,1) over(partition by IDCustomer order by year) as prevyearsales from(

select IDCustomer,avg(TotalPrice)as avgprice,
       avg(Quantity) avgquantity,
	   YEAR(Date) as year
from FACT_TRANSACTIONS
where IDCustomer in (select top 10 IDCustomer
from FACT_TRANSACTIONS
group by IDCustomer
order by sum(TotalPrice) desc)
group by IDCustomer,year(Date)
) as a
)as b















--Q10--END
	