-- Phones Without Accounts: every figure in the brief, reproducible in PostgreSQL.
-- Table eth = Global Findex 2025 rows where economy = 'Ethiopia' (1,001 rows).
-- Weights: sum(wgt) = 1,001, so a weighted share = sum(wgt where condition) / sum(wgt).
-- Codes: con1 1=yes 2=no 3=don't know | account 1=yes 0=no | female 1=female 2=male
--        urbanicity 1=rural 2=urban | educ 1=primary or less 2=secondary 3=tertiary
--        inc_q 1=poorest 5=richest | con9 1=smartphone 2=basic | fin11a-f 1=yes


-- 0. Typed working table. DataGrip imported most columns as text, so cast once here.
--    nullif(...,'') turns blank cells into NULL; ::numeric first handles values like '1.0'.
drop table if exists eth_clean;
create table eth_clean as
select
       nullif(wgt::text, '')::numeric as wgt,
       nullif(con1::text, '')::numeric::int as con1,
       nullif(con9::text, '')::numeric::int as con9,
       nullif(account::text, '')::numeric::int as account,
       nullif(female::text, '')::numeric::int as female,
       nullif(age::text, '')::numeric::int as age,
       nullif(educ::text, '')::numeric::int as educ,
       nullif(inc_q::text, '')::numeric::int as inc_q,
       nullif(urbanicity::text, '')::numeric::int as urbanicity,
       nullif(internet_use::text, '')::numeric::int as internet_use,
       nullif(fin11a::text, '')::numeric::int as fin11a,
       nullif(fin11b::text, '')::numeric::int as fin11b,
       nullif(fin11c::text, '')::numeric::int as fin11c,
       nullif(fin11d::text, '')::numeric::int as fin11d,
       nullif(fin11e::text, '')::numeric::int as fin11e,
       nullif(fin11f::text, '')::numeric::int as fin11f
from eth;
select count(*) from eth_clean;  -- expect 1001

-- 1. Validation: unweighted vs weighted account ownership (58.7% vs 48.8%)
select round(avg(account) * 100.0, 1) as unweighted_pct,
       round(sum(wgt) filter (where account = 1) * 100.0 / sum(wgt), 1) as weighted_pct
from eth_clean;

-- 2. Phone ownership, excluding the one "don't know" answer (58.1%)
select round(sum(wgt) filter (where con1 = 1) * 100.0 / sum(wgt), 1) as phone_pct
from eth_clean
where con1 in (1, 2);

-- 3. The four groups (38.3 / 19.8 / 10.6 / 31.3, adds to 100)
-- grain: one row per (phone, account) pair, from one row per respondent
select con1 = 1     as has_phone,
       account = 1  as has_account,
       round(sum(wgt) * 100.0 / (select sum(wgt) from eth_clean where con1 in (1, 2)), 1) as pct_adults,
       count(*)     as respondents
from eth_clean
where con1 in (1, 2)
group by 1, 2
order by 1 desc, 2 desc;

-- 4. Among phone owners: share with no account, by group (34% overall)
-- Same pattern for each group column; education shown, swap educ for urbanicity, inc_q, female.
select educ,
       round(sum(wgt) filter (where account = 0) * 100.0 / sum(wgt), 1) as no_account_pct,
       count(*) as respondents
from eth_clean
where con1 = 1
group by educ
order by educ;

-- age bands
select case when age <= 24 then '15-24' when age <= 34 then '25-34'
            when age <= 49 then '35-49' else '50+' end as age_band,
       round(sum(wgt) filter (where account = 0) * 100.0 / sum(wgt), 1) as no_account_pct,
       count(*) as respondents
from eth_clean
where con1 = 1
group by 1
order by 1;

-- 5. Profile of the "phone, no account" group (rural 86%, primary 87%, basic phone 84%, internet 13%)
select round(sum(wgt) filter (where urbanicity = 1)   * 100.0 / sum(wgt), 1) as rural_pct,
       round(sum(wgt) filter (where educ = 1)         * 100.0 / sum(wgt), 1) as primary_pct,
       round(sum(wgt) filter (where con9 = 2)         * 100.0 / sum(wgt), 1) as basic_phone_pct,
       round(sum(wgt) filter (where internet_use = 1) * 100.0 / sum(wgt), 1) as internet_pct,
       count(*) as respondents
from eth_clean
where con1 = 1 and account = 0;

-- 6. Reasons for no account, same group (money 82%, distance 33%, ...)
-- Not mutually exclusive: shares do not add to 100.
select round(sum(wgt) filter (where fin11d = 1) * 100.0 / sum(wgt), 1) as not_enough_money,
       round(sum(wgt) filter (where fin11a = 1) * 100.0 / sum(wgt), 1) as too_far,
       round(sum(wgt) filter (where fin11c = 1) * 100.0 / sum(wgt), 1) as lack_documents,
       round(sum(wgt) filter (where fin11e = 1) * 100.0 / sum(wgt), 1) as family_has_one,
       round(sum(wgt) filter (where fin11b = 1) * 100.0 / sum(wgt), 1) as too_expensive,
       round(sum(wgt) filter (where fin11f = 1) * 100.0 / sum(wgt), 1) as no_trust
from eth_clean
where con1 = 1 and account = 0;

-- 7. Effective sample size for the margins of error (Kish): (sum w)^2 / sum(w^2)
select round((sum(wgt) ^ 2 / sum(wgt ^ 2))::numeric, 0) as n_effective from eth_clean;              -- about 591
select round((sum(wgt) ^ 2 / sum(wgt ^ 2))::numeric, 0) as n_effective from eth_clean where con1 = 1; -- about 405
-- 95% margin (points) = 196 * sqrt(p * (1 - p) / n_effective), p as a fraction
