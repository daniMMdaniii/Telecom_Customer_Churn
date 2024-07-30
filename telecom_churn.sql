
/*
Churn data for a fictional Telecommunications company that provides 
phone and internet services to 7,043 customers in California, and 
includes details about customer demographics, location, services, and current status.

[架空の通信会社の解約データ: カリフォルニア州の7,043人の顧客に電話およびインターネットサービスを提供しており、
顧客の人口統計情報、所在地、サービス内容、現在のステータスに関する詳細が含まれています。]
*/




--===================================================================================================
-- 1. Churn Rate by Customer Age Groups and Gender: What is the churn rate for different age groups (e.g., 18-25, 26-35) and genders?
-- [顧客の年齢層と性別による解約率: 異なる年齢層（例えば、18-25歳、26-35歳）および性別の解約率はどのくらいですか？]
--===================================================================================================
/*
select min(age) as min_age, max(age) as max_age
from telecom_customer_churn;

declare @churn_var as float 
set @churn_var = ( select count(*) 
                   from telecom_customer_churn
				   where [Customer Status] = 'Churned');

with age_range_table as ( select *, case  when age between 18 and 25 then '18 - 25'
                                     when age between 26 and 35 then '26 - 35'
									 when age between 36 and 45 then '36 - 45'
									 when age between 46 and 55 then '46 - 55'
									 when age between 56 and 65 then '56 - 65'
									 when age between 66 and 75 then '66 - 75'
									 else '76+' end as age_range
					  from telecom_customer_churn )

select *, 
       rank() over (order by perecent_of_total_churned desc) as ranking
from ( select age_range, 
              Gender, 
			  count(*) as churn_rate, 
			  round((count(*) / @churn_var)*100,2) as perecent_of_total_churned
		 from age_range_table
		where [Customer Status] = 'Churned'
		group by age_range, Gender ) d;
*/

--===================================================================================================
-- 2. Churn Rate by Contract Type and Internet Service: What is the churn rate for each contract type (Month-to-Month, One Year, Two Year) segmented by whether the customer has internet service?
-- [契約タイプおよびインターネットサービス別の解約率：顧客がインターネットサービスを利用しているかどうかによって、各契約タイプ（月ごと、1年契約、2年契約）の解約率はどのくらいですか？]
--===================================================================================================
/*
declare @churn_var as float 
set @churn_var = ( select count(*) 
                   from telecom_customer_churn
				   where [Customer Status] = 'Churned');

select Contract, 
       [Internet Type], 
	   count(*) as churn_rate , 
	   round((count(*) / @churn_var)*100,2) as percent_by_total
from telecom_customer_churn
where ([Internet Service] = 'Yes') and ([Customer Status] = 'Churned')
group by Contract, [Internet Type]
order by 3 desc
*/

--===================================================================================================
-- 3. Churn Rate by Number of Dependents: How does the churn rate vary with the number of dependents (e.g., 0, 1, 2, 3 or more)?
-- [扶養家族の数による解約率: 扶養家族の数（例えば、0人、1人、2人、3人以上）によって解約率はどのように変わりますか？]
--===================================================================================================
/*
declare @churn_var as float 
set @churn_var = ( select count(*) 
                   from telecom_customer_churn
				   where [Customer Status] = 'Churned');

with edited_table as (select *, case when [Number of Dependents] = 0 then 'No Dependent'
									 when [Number of Dependents] = 1 then '1 Dependent'
								     when [Number of Dependents] = 2 then '2 Dependent'
								     when [Number of Dependents] = 3 then '3 Dependent'
									 else '3+' end as num_of_dependents
						from telecom_customer_churn
						where [Customer Status] = 'Churned')

select num_of_dependents, 
       count(*) as churn_rate,
	   round((count(*) / @churn_var)*100,2) as percent_by_total
from edited_table
group by num_of_dependents
order by 2 desc
*/

--===================================================================================================
-- 4. Churn Analysis by Monthly Charges: What is the average monthly charge for churned versus non-churned customers, and what percentage difference does this represent?
-- [月額料金による解約分析: 解約した顧客と解約していない顧客の平均月額料金はそれぞれどのくらいで、これがどのくらいの割合の違いを示していますか？]
--===================================================================================================

/*
declare @all_var as float
set @all_var = (select count(*)
                from telecom_customer_churn);
				
with churn_vs_retain as (select *, case when [Customer Status] = 'Churned' then [Customer Status]
									    else 'Retained' end as customer_status
					   	   from telecom_customer_churn ) 
select customer_status, 
	   concat(round(avg(cast([Monthly Charge] as float)),2),' ','$') as avg_monthly_charge,
	   count(*) as rate,
	   concat(round((COUNT(*) / @all_var)*100,2) ,' ','%') as percent_by_total
from churn_vs_retain
group by customer_status
union
select '','','',''
union
select '' as customer_status, 
       'Total difference' as avg_monthly_charge, 
	   5174 - 1869 as rate, 
	   concat(cast((73.46 - 26.54)as varchar),' ','%') as percent_by_total
order by customer_status desc 
*/

--===================================================================================================
-- 5. Impact of Online Services on Churn: How do online services (e.g., Online Security, Online Backup) affect churn rates?
-- [オンラインサービスが解約率に与える影響: オンラインセキュリティやオンラインバックアップなどのオンラインサービスは解約率にどのように影響しますか？]
--===================================================================================================

/*
declare @churn_var_internet as float 
set @churn_var_internet = ( select count(*) 
                   from telecom_customer_churn
				   where ([Customer Status] = 'Churned') and ([Internet Service] = 'Yes'));

select [Online Security], 
       [Online Backup], 
	   [Device Protection Plan], 
	   [Premium Tech Support],
	   count(*) as churn_rate, 
	   concat(round((count(*) / @churn_var_internet)*100,2),' ','%') as percent_by_total
from telecom_customer_churn
where ([Customer Status] = 'Churned') and ([Internet Service] = 'Yes')
group by [Online Security], [Online Backup], [Device Protection Plan], [Premium Tech Support]
order by 4 desc;
*/

--===================================================================================================
-- 6. Customer Status and Total Revenue: What is the total revenue from churned customers compared to those who stayed?
-- [顧客のステータスと総収益: 解約した顧客と残った顧客の総収益はそれぞれどのくらいですか？]
--===================================================================================================

/*
select [Customer Status], 
       sum(cast([Total Revenue] as float)) as total_revenue
from telecom_customer_churn
group by [Customer Status]
order by 2 desc
*/

--===================================================================================================
-- 7. Churn Rate by Zip Code and Population: What is the churn rate by zip code, and how does it correlate with the population of the zip code?
-- [郵便番号と人口による解約率: 郵便番号ごとの解約率はどのくらいで、これが郵便番号の人口とどのように相関していますか？]
--===================================================================================================

/*
select * , dense_rank() over (order by cast(Population as int) desc ) as ranking_by_population, 
           rank() over (order by churn_rate desc) as ranking_by_churn_rate
           
from (
		select t1.[Zip Code],t2.Population, count(*) as churn_rate
		from telecom_customer_churn t1
		left join telecom_zipcode_population t2
		on t1.[Zip Code] = t2.[Zip Code]
		where [Customer Status] = 'Churned'
		group by t1.[Zip Code],t2.Population ) d
*/

--===================================================================================================
-- 8. Churn Rate by Payment Method: What is the churn rate for each payment method (Bank Withdrawal, Credit Card, Mailed Check)?
-- [支払い方法別の解約率: 各支払い方法（銀行引き落とし、クレジットカード、郵送小切手）の解約率はどのくらいですか？]
--===================================================================================================

/*
declare @churn_var as float 
set @churn_var = ( select count(*) 
                   from telecom_customer_churn
				   where [Customer Status] = 'Churned');

select [Payment Method], count(*) as churn_rate, round((count(*) / @churn_var ) * 100,2) as percent_by_total
from telecom_customer_churn
where [Customer Status] = 'Churned'
group by [Payment Method]
order by 2 desc
*/

--===================================================================================================
-- 9. Top 5 Cities with Highest and Lowest Churn Rates: Which are the top 5 cities with the highest churn rates?
-- [解約率が最も高いトップ5の都市: 解約率が最も高いトップ5の都市はどこですか？]
--===================================================================================================

/*
--Highest churn rate
select top (5) City, count(*) as churn_rate
from telecom_customer_churn
where [Customer Status] = 'Churned'
group by city 
order by 2 desc;

--Lowest churn rate
select top (5) City, count(*) as churn_rate
from telecom_customer_churn
where [Customer Status] = 'Churned'
group by city 
order by 2 asc;
*/

--===================================================================================================
-- 10. Churn Analysis Based on Offers: What is the churn rate for customers who received different marketing offers compared to those who did not receive any offer?
-- [オファーに基づく解約分析: さまざまなマーケティングオファーを受け取った顧客の解約率は、オファーを受け取らなかった顧客と比べてどのくらいですか？]
--===================================================================================================

/*
select offer, count(*) as churn_rate
from telecom_customer_churn
where [Customer Status] = 'Churned'
group by Offer
order by 2 desc
*/

--===================================================================================================
-- 11. Churn Rate by Streaming Services: What is the churn rate for customers who use streaming services (TV, Movies, Music) versus those who do not?
-- [ストリーミングサービス別の解約率: テレビ、映画、音楽などのストリーミングサービスを利用している顧客の解約率は、利用していない顧客と比べてどのくらいですか？]
--===================================================================================================

/*
declare @churn_var_internet as float 
set @churn_var_internet = ( select count(*) 
                   from telecom_customer_churn
				   where ([Customer Status] = 'Churned') and ([Internet Service] = 'Yes'));

select [Streaming TV], 
       [Streaming Movies], 
	   [Streaming Music], count(*) as churn_rate,
	   concat(round((count(*) / @churn_var_internet) * 100,2),' ','%') as percent_by_total
from telecom_customer_churn
where ([Internet Service] = 'Yes') and ([Customer Status] = 'Churned')
group by [Streaming TV], [Streaming Movies], [Streaming Music]
order by 4 desc
*/

--===================================================================================================
-- 12. Customer Churn by Tenure and Contract Type: How does churn rate vary based on the length of tenure and contract type?
-- [勤続年数と契約タイプによる解約率: 解約率は勤続年数と契約タイプによってどのように変わりますか？]
--===================================================================================================

/*
select min(cast([Tenure in Months] as int)) as min_value, 
       max(cast([Tenure in Months] as int)) as max_value
from telecom_customer_churn;

with tenure_year as ( select *, case when [Tenure in Months] < 7 then '6 months or lower '
									   when [Tenure in Months] < 13 then 'between 6 to 12 months'
									   when [Tenure in Months] < 19 then 'between 1 to 1.5 years'
									   when [Tenure in Months] < 25 then 'between 1.5 to 2 years'
									   when [Tenure in Months] < 31 then 'between 2 to 2.5 years'
									   when [Tenure in Months] < 37 then 'betwenn 2.5 to 3 years'
									   when [Tenure in Months] < 43 then 'betwenn 3 to 3.5 years'
									   when [Tenure in Months] < 449 then 'between 3.5 to 4 years'
									   else '4 years above' end as tenure_in_years
						from telecom_customer_churn ),


     by_pivot_table as ( select contract, tenure_in_years, COUNT(*) as churn_rate
							from tenure_year
							where [Customer Status] = 'Churned'
							group by Contract, tenure_in_years)
select tenure_in_years, 
	   isnull([Month-to-Month], 0) as 'Month to Month',
	   isnull([One Year], 0) as 'One year',
	   isnull([Two Year], 0) as 'Two year'
from by_pivot_table
pivot ( sum(churn_rate) for [contract] in ([Month-to-Month],[One Year],[Two Year])) as pvt
*/

--===================================================================================================
-- 13. Churn and Long Distance Charges Correlation: Is there a significant relationship between churn rate and total long distance charges?
-- [解約率と長距離料金の相関関係: 解約率と総長距離料金の間に有意な関係はありますか？]
--===================================================================================================

/*
select min(cast([Total Long Distance Charges] as float)) as min_value, max(cast([Total Long Distance Charges] as float)) as max_value
from telecom_customer_churn
where [Customer Status] = 'Churned';

with long_distance_charge as ( select *, case when cast([Total Long Distance Charges] as float) between 0 and 499 then '0 - 499 ($)'
                                              when cast([Total Long Distance Charges] as float) between 500 and 999 then '500 - 999 ($)'
											  when cast([Total Long Distance Charges] as float) between 1000 and 1499 then '1000 - 1499 ($)'
											  when cast([Total Long Distance Charges] as float) between 1500 and 1999 then '1500 - 1999 ($)'
											  when cast([Total Long Distance Charges] as float) between 2000 and 2499 then '2000 - 2499 ($)'
											  when cast([Total Long Distance Charges] as float) between 2500 and 2999 then '2500 - 2999 ($)'
											  when cast([Total Long Distance Charges] as float) between 3000 and 3499 then '3000 - 3499 ($)'
											  else '3500 $ above' end as ordered_charge 
								from telecom_customer_churn)

select ordered_charge as total_long_distance_charge, count(*) as churn_rate
from long_distance_charge
where [Customer Status] = 'Churned'
group by ordered_charge
order by 2 desc
*/
                                      
--===================================================================================================
-- 14. Impact of Device Protection Plan on Churn: How does having a device protection plan impact churn rates across different internet types?
-- [デバイス保護プランが解約率に与える影響: デバイス保護プランを持っていることは、異なるインターネットタイプにおける解約率にどのように影響しますか？]
--===================================================================================================

/*
with by_pivot_table as (
						select [Internet Type],
							   [Device Protection Plan],
							   COUNT(*) as churn_rate
						from telecom_customer_churn
						where ([Internet Service] = 'Yes') and ([Customer Status] = 'Churned')
						group by[Internet Type],
								[Device Protection Plan] )

select[Device Protection Plan],
      isnull([Cable], 0) AS cable,
      isnull([DSL], 0) AS dsl,
	  isnull([Fiber Optic],0) as fiber_optic
from by_pivot_table
PIVOT ( sum(churn_rate)
        for [Internet Type] in ([Cable], [DSL], [Fiber Optic])) as pvt
order by [Device Protection Plan];
*/


--===================================================================================================
-- 15. Churn Rate by Age and Marital Status: What is the churn rate for different age groups and marital statuses?
-- [年齢層と婚姻状況別の解約率: 年齢層や婚姻状況ごとの解約率はどのくらいですか？]
--===================================================================================================

/*
with age_range_table as ( select *, case  when age between 18 and 25 then '18 - 25'
                                     when age between 26 and 35 then '26 - 35'
									 when age between 36 and 45 then '36 - 45'
									 when age between 46 and 55 then '46 - 55'
									 when age between 56 and 65 then '56 - 65'
									 when age between 66 and 75 then '66 - 75'
									 else '76+' end as age_range
					  from telecom_customer_churn ),

	 by_pivot_table as (select Married, age_range, count(*) as churn_rate
						  from age_range_table
						 where [Customer Status] = 'Churned'
                         group by Married, age_range)

select age_range,
       [Yes] as married,
	   [No] as single
from by_pivot_table
pivot ( sum(churn_rate) for [Married] in ([Yes], [No])) as pvt
*/

--===================================================================================================
-- 16. Average Tenure of Churned vs. Stayed Customers: What is the average tenure in months for churned customers compared to those who stayed?
-- [解約した顧客と残った顧客の平均勤続年数: 解約した顧客と残った顧客の平均勤続年数（月単位）はそれぞれどのくらいですか？]
--===================================================================================================

/*
select [Customer Status], 
       round(avg(cast([Tenure in Months] as float)),2) as avg_tenure_in_months
from telecom_customer_churn
group by [Customer Status]
order by 2 desc
*/

--===================================================================================================
-- 17. Churn Rate by Internet Type and Data Usage: How does churn rate vary with different types of internet service and average data usage?
-- [インターネットタイプとデータ使用量による解約率: 異なるインターネットサービスのタイプや平均データ使用量によって解約率はどのように変わりますか？]
--===================================================================================================

/*
select min(cast([Avg Monthly GB Download] as float)), max(cast([Avg Monthly GB Download] as float))
from telecom_customer_churn;

with grouped_table as ( select *, case when cast([Avg Monthly GB Download] as float) between 0 and 10 then '0 - 10 GB'
                                       when cast([Avg Monthly GB Download] as float) between 11 and 20 then '11 - 20 GB'
									   when cast([Avg Monthly GB Download] as float) between 21 and 30 then '21 - 30 GB'
									   when cast([Avg Monthly GB Download] as float) between 31 and 40 then '31 - 40 GB'
									   when cast([Avg Monthly GB Download] as float) between 41 and 50 then '41 - 50 GB'
									   when cast([Avg Monthly GB Download] as float) between 51 and 60 then '51 - 60 GB'
									   when cast([Avg Monthly GB Download] as float) between 61 and 70 then '61 - 70 GB'
									   when cast([Avg Monthly GB Download] as float) between 71 and 80 then '71 - 80 GB'
									   when cast([Avg Monthly GB Download] as float) between 81 and 90 then '81 - 90 GB'
									   when cast([Avg Monthly GB Download] as float) between 91 and 100 then '91 - 100 GB'
									   else '100+ GB' end as data_usage
						from telecom_customer_churn),

	by_pivot_table as (select contract, [Unlimited Data], data_usage, count(*) as churn_rate
						from grouped_table
						where ([Customer Status] = 'Churned') and ([Internet Service] = 'Yes')
						group by Contract, [Unlimited Data], data_usage)

select [Unlimited Data], 
       data_usage,
	   isnull([Month-to-Month],'') as 'month to month',
	   isnull([One Year],'') as 'one year',
	   isnull([Two Year],'') as 'two year'
from by_pivot_table
pivot ( sum(churn_rate) for [contract] in ([Month-to-Month], [One Year], [Two Year])) as pvt
order by 3 desc, 4 desc, 5 desc
*/

--===================================================================================================
-- 18. Churn Rate by Contract Type and Monthly Charges: What is the churn rate for each contract type, and how does it correlate with average monthly charges?
-- [契約タイプと月額料金による解約率: 各契約タイプの解約率はどのくらいで、これが平均月額料金とどのように相関していますか？]
--===================================================================================================
/*
select Contract, 
       concat(round(avg(cast([Monthly Charge] as float)),2),' ','$') as avg_monthly_charge
from telecom_customer_churn
group by Contract
*/

--===================================================================================================
-- 19. What were the top 10 reasons for churning the service?
-- [サービス解約のトップ10の理由は何ですか？]
--===================================================================================================

/*
declare @churn_var as float 
set @churn_var = ( select count(*) 
                   from telecom_customer_churn
				   where [Customer Status] = 'Churned');

select top 10 [Churn Reason], 
       count(*) as num_of_reports, 
       concat(round(((count(*) / @churn_var) *100),2),' ','%') as percent_by_total
from telecom_customer_churn
where [Customer Status] = 'Churned'
group by [Churn Reason]
order by 2 desc
*/