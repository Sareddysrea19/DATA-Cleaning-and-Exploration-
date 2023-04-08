/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [pclass]
      ,[survived]
      ,[name]
      ,[sex]
      ,[age]
      ,[sibsp]
      ,[parch]
      ,[ticket]
      ,[fare]
      ,[cabin]
      ,[embarked]
      ,[boat]
      ,[body]
      ,[home#dest]
  FROM [Projects].[dbo].[TitanicCleaning]

select * from Projects..TITANICDATASET


--Change NULL to -1 in TitanicData
--Update TITANICDATASET 
--Set Age = 999 
--where Age = NULL


CREATE VIEW Titanic_clean AS
SELECT
-- Parsed First and Last name (title)
	NAME,
	RIGHT(name,LEN(name)-CHARINDEX(',',name)) as [FirstName],
	LEFT(name,CHARINDEX(',',name)-1) as[LastnName],
--Assign Cabin Class
	CASE pclass
	WHEN 1 THEN 'First Class'
	When 2 then 'Second Class'
	When 3 then 'Third Class'
	else 'Not Recorded'
	End as 'Cabin Class',
-- Change case for Gender
	Case sex
	when 'male' then 'M'
	Else 'F'
	End 'Gender',
--Create Age group fo 5 and 10 years, ceiling
	Age,
	Ceiling(Age/5)*5 as five_year_ceiling,
	ceiling(age/10)*5 as ten_year_ceiling,
	SibSp,
	Parch,
--Family
	(SibSp + Parch +1) as [FamilySize],
--Department
	Case embarked
	when 'S' Then 'Southampton'
	when 'Q' Then 'Queentown'
	when 'C' Then 'Cherbourg'
	Else 'Not Recorded'
	End 'Embarked',
-- Did person survive?
	case survived
	when 0 Then 'Died'
	When 1 then 'Survived'
	end as 'Survived',
--Seperate Hometown and destination
	home#dest,
	LEFT(home#dest,charindex(',',home#dest)) as [Home],
	RIGHT(home#dest,LEN(home#dest)-CHARINDEX(',',home#dest)) as [Destination]
FROM TITANICDATASET



	

-------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
------------------------------Seperate Hometown and state---------------------------------
--right(hometown,len(hometown)-charindex(',',hometown)) as [Home_state_country],
--right(destination,len(destination,)-charindex(',',destination)) as [Destination_state_country],
-----------------------------Split out state and country-------------------------------------------
-- Left(hometown,charindex(',',[howntown])) as home_state,
-- right([hometown],len([hometown])-charindex(',',[hometown])) as [homecountry],
-- left([destination],charindex(',',[destination])) as destination_state,
-- right([destination],len([destination])-charindex(',',[destination])) as [destination_country]
-------------------------------------------------------------------------------------------------------------------




--- View---
select * from TITANICDATASET
select * from Titanic_clean


select five_year_ceiling,count(*) as Bins from Titanic_clean 
group by five_year_ceiling order by five_year_ceiling

select ten_year_ceiling,count(*) as Bins from Titanic_clean 
group by ten_year_ceiling order by ten_year_ceiling

select hometown_state_country,count(hometown_state_country) as count_by_home_country
from Titanic_clean
group by hometown_state_country
order by count(hometown_state_country) Desc

select destination_state_country,count(destination_state_country) as count_by_destination
from Titanic_clean
group by destination_state_country
order by count(destination_state_country) Desc






--Histogram of Ages


--Historgram for 5 year Bins(Ceiling)
Drop view five_year_bins
create view five_year_bins as
select CEILING(age/5)*5 as five_years,
count(*) as Bin 
from Titanic_clean 
group by CEILING(age/5)*5 
--order by CEILING(age/5)*5 

--Historgram for 10 year Bins(Ceiling)
Drop view ten_year_bins
create view ten_year_bins as
select CEILING(age/10)*10 as ten_years,
count(*) as Bin 
from Titanic_clean 
group by CEILING(age/10)*10 

select * from ten_year_bins 
------------------------------------------------------------------------------------------------------------------------------------------------

--10 Year Age Group by Gender : Male
select * from Titanic_clean

Drop view ten_year_gender_male
create view ten_year_gender_male as
select CEILING(age/10)*10 as ten_years_ceiling,
count(*) as Male 
from Titanic_clean  
where Gender =  'M'
group by CEILING(age/10)*10 

select * from ten_year_gender_male 
select sum(Male) from ten_year_gender_male as MensTotal 

--10 Year Age Group by Gender : Female
Drop view ten_year_gender_female
create view ten_year_gender_female as
select CEILING(age/10)*10 as ten_years_ceiling,
count(*) as Female 
from Titanic_clean 
where Gender =  'F'
group by CEILING(age/10)*10 

select sum(FeMale) from ten_year_gender_female
select *,sum(Female) over() from ten_year_gender_female
-----------------------------------------------------------------------------------------------------------------------
select * from ten_year_gender_male
select * from ten_year_gender_male 

select *,sum(Male) over() as MalesTotal from ten_year_gender_male
select *,sum(FeMale) over() as FemalsTotal from ten_year_gender_Female



--Drop View Totalview
Create View TOTALVIEW as
Select A.ten_years_ceiling,Male,Female,sum(Male) over() as MensTotal,sum(FeMale) over() as WomensTotal 
from ten_year_gender_male A
join ten_year_gender_female B
on A.ten_years_ceiling = B.ten_years_ceiling

--Select add(distinct(MensTotal) + distinct(WomensTotal)) over() as TOTAL from SSR
select * from TOTALVIEW
select *,sum(Male + Female) over() as Count from TOTALVIEW
select ten_years_ceiling,Male,MensTotal,Female,WomensTotal,sum(Male + Female) over() as count from TOTALVIEW

------------------------------------------------------------------------------------------------------------------------
--Histogram by Age and Gender
create view five_year_age_gender as
select Gender,
CEILING(age/5)*5 as five_years,
count(*) as Bin 
from Titanic_clean
group by Gender,CEILING(age/5)*5

create view ten_year_age_gender as
select Gender,CEILING(age/10)*10 as ten_years,count(*) as Bin 
from Titanic_clean group by Gender,CEILING(age/10)*10

select * from five_year_age_gender --order by Gender
select * from ten_year_age_gender --order by Gender


-- Count Passengers by Port of Embarkment
DROP View Port_embarked
create View Port_embarked as
select Embarked, Count(Embarked) as 'Passengers Count'
From Titanic_clean 
where Embarked != 'NULL'
Group by Embarked

select * from Port_embarked 

-- Count by Gender
CREATE VIEW Gender_count as
SELECT Gender,count(Gender) as Count_by_Gender
from Titanic_clean 
group by Gender

SELECT * FROM Gender_count 

---Passenger Count by Cabin Class
CREATE VIEW class_count as
SELECT [Cabin Class],COUNT([Cabin Class]) as Count_by_Gender
from Titanic_clean 
group by [Cabin Class] 

SELECT * FROM class_count

--Count by Family size
CREATE VIEW family_size as
SELECT FamilySize,count(FamilySize) as Count_by_Gender
from Titanic_clean 
group by FamilySize
--- Count by Age and Cabin Class
CREATE VIEW count_age_count as
SELECT Age,[Cabin Class],count(*) as Count_age_cabin
from Titanic_clean 
group by Age,[Cabin Class]

--- Count by Age and Survival
CREATE VIEW count_age_Survived as
SELECT Age,Survived,count(*) as Count_age_cabin
from Titanic_clean 
group by Age,Survived

select * from count_age_Survived

--- Count by Age,Cabin Class and Survival
CREATE VIEW count_age_Cabin_Survived as
SELECT [Cabin Class],Age,Survived,count(*) as Count_age_cabin
from Titanic_clean 
group by [Cabin Class],Age,Survived

select * from count_age_Cabin_Survived



----------------------------------------------------------------------------------------------------------
with CTE AS (SELECT [Cabin Class],Age,five_year_ceiling,Survived,
					count(*) as Count_SS 
			from Titanic_clean 
			group by [Cabin Class],Age,five_year_ceiling,Survived)

--select * from CTE
Select *,sum(Count_SS) over() from CTE
-------------------------------------------------------------------------------------------------------

Create view TotalChecking as
SELECT [Cabin Class],Age,five_year_ceiling,Survived,count(*) as Count_SS
from Titanic_clean 
group by [Cabin Class],Age,five_year_ceiling,Survived

select * from TotalChecking order by Count_SS Desc
select *,sum(Count_SS) over() from TotalChecking



