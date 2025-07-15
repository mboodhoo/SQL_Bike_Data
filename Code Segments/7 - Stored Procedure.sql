-- Stored Procedure

-- We want to do a Stored Procedure where we return information about a staff member given their id.

use sales;
drop procedure if exists Staff_Info;

delimiter $$
create procedure Staff_Info (p_staff_id int)
begin
	declare is_active int;
    
    select `active` into is_active
    from sales.staffs_updated
    where staff_id = p_staff_id
    ;
    
    if is_active = 1 then
		select first_name, last_name, email, phone
        from sales.staffs_updated
        where staff_id = p_staff_id;
	else select 'No longer works here' as `Status`;
    end if;
end $$
delimiter ;

call Staff_Info(1);
call Staff_Info(4);