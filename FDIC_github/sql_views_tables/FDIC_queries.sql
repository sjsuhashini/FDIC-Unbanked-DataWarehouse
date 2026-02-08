CREATE DATABASE FDIC_BankingDW;
GO
USE FDIC_BankingDW;

drop table if exists FactUnbankedHouseholds;
drop table if exists Stage_UnbankedRaw;
drop table if exists ETL_RunLog;
drop table if exists DimYear;
drop table if exists DimCategory;

--Creating ETL Log table, staging table, dim tables and fact table

create table ETL_RunLog
(
    FileName varchar(200) primary key,
    Year int,
    LoadDate datetime default getdate()
);

create table Stage_UnbankedRaw (
    Year INT,
    CategoryType varchar(50),
    CategoryValue varchar(100),
    Households int,
    Unbanked_Pct decimal(5,2)
    );

create table DimYear (
    YearKey int primary key,
    Year int not null
);

create table DimCategory (
    CategoryKey int identity(1,1) primary key,
    CategoryType varchar(50),     -- Race, Age, Income
    CategoryValue varchar(100)    -- Black, 25-34, <15k
);

create table FactUnbankedHouseholds (
    YearKey INT,
    CategoryKey INT,
    Households INT,
    Unbanked_Pct DECIMAL(5,2)
    
    constraint FK_Year foreign key (YearKey)
        references DimYear(YearKey) ON DELETE CASCADE ON UPDATE CASCADE,

    constraint FK_Category foreign key (CategoryKey)
        references DimCategory(CategoryKey) ON DELETE CASCADE ON UPDATE CASCADE,

    constraint UQ_Fact_Year_Category unique(YearKey, CategoryKey)

);

ALTER TABLE FactUnbankedHouseholds
ALTER COLUMN Households BIGINT;
--ALTER TABLE FactUnbankedHouseholds
--ADD CONSTRAINT UQ_Fact_Year_Category
--UNIQUE (YearKey, CategoryKey);


create index IX_Fact_YearKey on FactUnbankedHouseholds(YearKey);
create index IX_Fact_CategoryKey on FactUnbankedHouseholds(CategoryKey);
create unique index  IX_DimCategory on DimCategory(CategoryType, CategoryValue);

select * from DimCategory;
select * from DimYear;
select * from ETL_RunLog;
select * from Stage_UnbankedRaw;
select * from FactUnbankedHouseholds;

truncate table DimCategory;
truncate table DimYear;
truncate table ETL_RunLog;
truncate table Stage_UnbankedRaw;
truncate table FactUnbankedHouseholds;


--duplicate check in the staging table before adding to the fact table
select
    Year,
    CategoryType,
    CategoryValue,
    count(*)
from Stage_UnbankedRaw
group by
    Year,
    CategoryType,
    CategoryValue
having count(*) > 1;

select * from FactUnbankedHouseholds;