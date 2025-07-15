-- Views

-- View the active staff

drop view if exists active_staff;
create view active_staff as
select staff_id, first_name, last_name, store_id
from sales.staffs_updated
where `active` = 1
;

select *
from active_staff
;