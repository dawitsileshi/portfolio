-- Africa digital finance indicators: every country figure on the dashboard, in PostgreSQL.
-- Source table: findex_raw (the full Global Findex 2025 CSV, imported in DataGrip).
-- Most columns were imported as text, so cast once into a typed working table.

drop table if exists ssa;
create table ssa as
select economy,
       economycode,
       nullif(pop_adult::text, '')::numeric          as pop_adult,
       nullif(wgt::text, '')::numeric                as wgt,
       nullif(account::text, '')::numeric::int       as account,
       nullif(account_mob::text, '')::numeric::int   as account_mob,
       nullif(anydigpayment::text, '')::numeric::int as anydigpayment,
       nullif(merchantpay_dig::text, '')::numeric::int as merchantpay_dig,
       nullif(con1::text, '')::numeric::int          as con1,
       nullif(con9::text, '')::numeric::int          as con9,
       nullif(internet_use::text, '')::numeric::int  as internet_use
from findex_raw
where regionwb like 'Sub-Saharan%';

select count(*), count(distinct economy) from ssa;  -- expect 35,093 rows, 35 countries

-- 1. Country indicators. Each share has its own base (the WHERE-like condition inside FILTER on the denominator).
-- grain: one row per country, from one row per respondent
select economy,
  round(100 * sum(wgt) filter (where account = 1) / sum(wgt), 1) as account,
  round(100 * sum(wgt) filter (where account_mob = 1)
            / nullif(sum(wgt) filter (where account_mob is not null), 0), 1) as mobile_money,  -- Mauritania: NULL, not asked
  round(100 * sum(wgt) filter (where anydigpayment = 1) / sum(wgt), 1) as dig_pay,
  round(100 * sum(wgt) filter (where merchantpay_dig = 1) / sum(wgt), 1) as merchant_dig,
  round(100 * sum(wgt) filter (where con1 = 1)
            / sum(wgt) filter (where con1 in (1, 2)), 1) as phone,
  round(100 * sum(wgt) filter (where con1 = 1 and con9 = 1)
            / sum(wgt) filter (where con1 in (1, 2) and coalesce(con9, 0) not in (8, 9)), 1) as smartphone,
  round(100 * sum(wgt) filter (where internet_use = 1) / sum(wgt), 1) as internet,
  round(100 * sum(wgt) filter (where con1 = 1 and account = 0)
            / sum(wgt) filter (where con1 in (1, 2)), 1) as phone_no_acct,
  round(100 * sum(wgt) filter (where account = 1 and anydigpayment = 0)
            / sum(wgt) filter (where account = 1), 1) as acct_no_digpay
from ssa
group by economy
order by acct_no_digpay desc;
-- Check: Ethiopia should read account 48.8, mobile_money 9.5, dig_pay 20.7 (the published figures), acct_no_digpay 57.7.

-- 2. Regional figure, weighted by adult population.
-- Each country's weights sum to its sample size; rescale them so they sum to its adult population.
with pw as (
  select *, wgt * pop_adult / sum(wgt) over (partition by economy) as w_pop
  from ssa
)
select round(100 * sum(w_pop) filter (where account = 1) / sum(w_pop), 1) as account,
       round(100 * sum(w_pop) filter (where account = 1 and anydigpayment = 0)
                 / sum(w_pop) filter (where account = 1), 1) as acct_no_digpay   -- expect 58.2 and 13.1
from pw;

-- Note for smartphone: con9 is NULL for people with no phone, and coalesce(con9, 0) keeps them in the base.
-- Without the coalesce, "NULL not in (8, 9)" is NULL, and every non-owner silently drops out of the denominator.
