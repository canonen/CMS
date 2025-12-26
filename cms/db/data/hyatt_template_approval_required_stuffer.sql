-- Run this when putting Hyatt Offers and template code into production.

-- Run this only once.

-- This will make all already existing templage have an approval required flag turned on.


update ctm_templates set approval_flag = 1 
where approval_flag is null 
and cust_id <> 0