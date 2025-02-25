select * from layoff_in_covid;

/*copying the data of layoff_in_covid into another table*/
create table laid_off_2
like layoff_in_covid;

select * from laid_off_2;

insert  laid_off_2
select * from layoff_in_covid;

select * from laid_off_2;
/*data copied into laid_off_2*/
/* now the first step in data cleaning is remove duplicates*/
/* to remove duplicates we use window functions in mysql */

select company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions,row_number() 
over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions)
from laid_off_2;

/* now we copy the data into another table call laid_off_3 and add a one more column called row_number*/

create table laid_off_3(
company text,
location text,
industry text,
total_laid_off int,
percentage_laid_off text,
`date` text,
stage text,
country text,
funds_raised_millions text,
row_num int);

select * from laid_off_3;

insert into laid_off_3(
`company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
`row_num`)
select `company`,`location`,`industry`,`total_laid_off`,`percentage_laid_off`,`date`,`stage`,`country`,`funds_raised_millions`,row_number() 
over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions)
from laid_off_2;

select * from laid_off_3;
/* we added row_num in the laid_off_ table based on this we remove duplicates */


select * from laid_off_3 where row_num >=2;
/* in row_num the value is equatl to or greater than 2 then we consider that rows as duplicates so we remove that row */


delete  from laid_off_3 
where row_num>=2;

select * from laid_off_3;

select * from laid_off_3 where row_num>=2;

/* we removed all the duplicates in the table by using the sql window functions */
/* if we look at industry it looks like we have some null and empty rows, let's take a look at these */
select * from laid_off_3;

select company, trim(company) 
from laid_off_3;
/* company name is good */

select distinct(industry) from laid_off_3 order by industry;
/*  I  noticed the Crypto has multiple different variations. We need to standardize that - let's say all to Crypto */
 update laid_off_3
 set industry='Crypto'
 where industry in ('Crypto Currency','CryptoCurrency');
select distinct(industry) from laid_off_3 order by industry;

/* next we update tha empty values with null */
update laid_off_3
set industry=null
where  industry='';
select industry from laid_off_3 order by industry;

/*  write a query that if there is another row with the same company name, it will update it to the non-null industry values */

select * from laid_off_3 t1 
inner join laid_off_3 t2 on t1.company=t2.company where t1.industry is null and t2.industry is not null;

update laid_off_3 t1 
inner join laid_off_3 t2 on t1.company=t2.company set t1. industry=t2.industry where t1.industry IS null and t2.industry is not null;

select * from laid_off_3 where industry is null;
/*and if we check it looks like Bally's was the only one without a populated row to populate this null values */
/* we updated possible null values in the industry column */
/*company,location,industry columns are good upto now*/
/*the null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal. I don't think I want to change that
I like having them null because it makes it easier for calculations during the EDA phase.so there isn't anything I want to change with the null values */

/* coming to country column */
select distinct(country) from laid_off_3 order by country;
/*  we have some "United States" and some "United States." with a period at the end. Let's standardize this. */
update laid_off_3
set country=Trim(Trailing '.' from country);

select distinct(country) from laid_off_3 order by country;

/* now everything is good and we standardize the data as possible. now we remove unwanted data */


select * from laid_off_3 where total_laid_off is null and percentage_laid_off is null ;

delete from laid_off_3
where total_laid_off is null and percentage_laid_off is null ;

select * from laid_off_3 where total_laid_off is null and percentage_laid_off is null ;
/* we add row_num column for remove duplicates in the table it is unwanted after removal of duplicates so i delete the column */

alter table laid_off_3
drop column row_num;

select * from laid_off_3 ;
/* i want to change the data type of date column from text to date */

update laid_off_3
set `date`=str_to_date(`date`,'%m/%d/%Y');

alter table laid_off_3
modify column `date` Date;

/* the data clean up is completed */