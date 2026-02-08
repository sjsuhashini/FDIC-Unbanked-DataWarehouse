--------------------KPI for FDIC unbanked percentage -----------------------------------------------

--------------------------------- view to calculate percentage of unbanked people -------------------
---------------------- ---------- with different category against total population-------------------
go
;alter view vw_KPI_CategoryTrend
AS

with headcount_calculation_cte AS
(
    select
        y.Year,
        c.CategoryType,
        c.CategoryValue,

        f.Households,
        f.Unbanked_Pct,

        -- unbanked headcount for each category value
        cast(f.Households * f.Unbanked_Pct / 100.0 as decimal(18,2))
            as Unbanked_Headcount

    from FactUnbankedHouseholds f
    join DimCategory c
        ON f.CategoryKey = c.CategoryKey
    join DimYear y
        ON f.YearKey = y.YearKey
),

-- total population
all_population_cte as
(
    select
        *,
        sum(Households) over (
            partition by Year, CategoryType
        ) as TotalHouseholds_Category
    from headcount_calculation_cte
)

-- unbanked percentage for overall population for each category value
select
    Year,
    CategoryType,
    CategoryValue,
    Households,
    Unbanked_Pct,
    Unbanked_Headcount,
    TotalHouseholds_Category,

    cast(
        Unbanked_Headcount * 100.0 / TotalHouseholds_Category
        as decimal(10,2)
    ) as Unbanked_Headcount_Pct_of_Total
from all_population_cte;


select * from vw_KPI_CategoryTrend;
select *  from FactUnbankedHouseholds;
select * from DimCategory;
select * from DimYear;
-------------------------- View and stored proc to retreive data based on category---------------
go
alter view vw_AgUnbankede as
select  y.Year, c.CategoryType, c.CategoryValue, f.unbanked_Pct 
from DimCategory as c
join FactUnbankedHouseholds as f
on f.CategoryKey = c.CategoryKey
join DimYear as y
on f.YearKey = y.YearKey
;

go
alter procedure usp_UnbankedDetails @CategoryType nvarchar(50)
as
begin
select * from vw_AgUnbankede as v
where v.CategoryType= @CategoryType
order by 1
end

exec usp_UnbankedDetails "Education" 
-----------------------------------------------------------------------------------------------------

