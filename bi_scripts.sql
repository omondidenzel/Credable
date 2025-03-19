-- Portfolio Analysis script
select d.customer_id
    ,d.loan_amount
    ,regexp_replace(d.tenure, ' days', '')::numeric as repayment_period_days
    ,d.loan_fee
    ,r.amount as repayment_amount
    ,r.repayment_type
    ,left(to_char(to_date(r.rep_month::text, 'YYYYMM'), 'YYYY-MM'),7) as rep_month
from public.disbursements d
left join public.repayments r on d.customer_id = r.customer_id


-- Credit Analysis script
select distinct d.customer_id
	, coalesce(sum(d.loan_amount)::decimal(15,2),0) as total_disbursed
    , coalesce(sum(r.amount)::decimal(15,2),0) as total_repaid
    , coalesce((sum(d.loan_amount) - sum(r.amount))::decimal(15,2),0) as outstanding_loans
from public.disbursements d
left join public.repayments r on d.customer_id = r.customer_id
group by 1
order by 4 desc


-- Overdue customers / loan balance per customer
select d.customer_id
    , d.loan_amount
    , regexp_replace(d.tenure, ' days', '')::numeric as repayment_period_days  
    , (d.loan_amount - coalesce(sum(r.amount), 0)) as balance_due
from public.disbursements d
left join public.repayments r on d.customer_id = r.customer_id
--where d.customer_id = 'b8276dec060c7e0a086e35bf1d0daf00452640a7d889b54f2a5afc3700378eb7'
group by 1,2,3
having (d.loan_amount - coalesce(sum(r.amount), 0)) > 0;

-- provision and write off threshold for non performing loans script
select case 
	    when to_date(date_time, 'DD-MON-YY') >= now() - interval '7 days' then 'Performing loan'
	    when to_date(date_time, 'DD-MON-YY') between now() - interval '30 days' and now() - interval '14 days' then 'Underperforming'
	    else 'Non performing'
	end as loan_status
	, amount as loan_total_amount
from public.repayments r