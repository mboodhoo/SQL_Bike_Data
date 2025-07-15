-- Update Table

/*
Also, we notice some staff are inactive, we will turn them inactive except top manager. 
Create duplicate table.
*/

drop table if exists sales.staffs_updated;
create table sales.staffs_updated
like sales.staffs
;

select * 
from sales.staffs_updated
;

insert into sales.staffs_updated
select *
from sales.staffs
;

update sales.staffs_updated
set `active` = 
(case
	when (staff_id in (select distinct staff_id from sales.orders)) or 
		 (manager_id is null) then 1
    else 0
end)
;

select * 
from sales.staffs_updated
;