

WITH dir_person as (select dir_uid as username, uuid, primaryaffiliation
                        from dirsvcs.dir_person 
                        where  
                                 dir_person.primaryaffiliation != 'Not currently affiliated'
                             and dir_person.primaryaffiliation != 'Retiree'
                             and dir_person.primaryaffiliation != 'Affiliate'
                             and dir_person.primaryaffiliation != 'Member'),


dir_affiliation as (select * 
                    from dir_affiliation 
                    where 
                                dir_affiliation.campus = 'Boulder Campus' 
                            and dir_affiliation.description != 'Admitted Student'
                            and dir_affiliation.description != 'Alum'
                            and dir_affiliation.description != 'Confirmed Student' 
                            and dir_affiliation.description != 'Former Student'
                            and dir_affiliation.description != 'Member Spouse'
                            and dir_affiliation.description != 'Sponsored'
                            and dir_affiliation.description != 'Sponsored EFL' 
                            and dir_affiliation.description not like 'POI_%'
                            and dir_affiliation.description != 'Retiree'
                            and dir_affiliation.description != 'Boulder3'
),

dir_person_affiliation AS (
    select distinct username,  uuid, primaryaffiliation
  ,case  
    when dp.primaryaffiliation = 'Student' then 'Student'
    when dp.primaryaffiliation = 'Faculty' then 
      case when daf.edupersonaffiliation = 'Faculty'
        and daf.description = 'Student Faculty' then 'Student'
      else 'Faculty/Staff'
      end
    when dp.primaryaffiliation = 'Staff' then 'Faculty/Staff'
    when dp.primaryaffiliation = 'Employee' then 
      case
        when daf.edupersonaffiliation = 'Employee'
          and daf.description = 'Student Employee' then 'Student'
        when daf.edupersonaffiliation = 'Employee'
          and daf.description = 'Student Faculty' then 'Student'
        else 'Faculty/Staff'
      end
    when dp.primaryaffiliation = 'Officer/Professional' then 'Faculty/Staff'
    when dp.primaryaffiliation = 'Affiliate'
      and daf.edupersonaffiliation = 'Affiliate'
      and daf.description = 'Student Employee' then 'Student'
    when dp.primaryaffiliation = 'Affiliate'
      and daf.edupersonaffiliation = 'Affiliate'
      and daf.description = 'Continuing Ed Non-Credit Student' then 'Student'
    when dp.primaryaffiliation = 'Member'
      and daf.edupersonaffiliation = 'Member'
      and daf.description = 'Faculty' then 'Faculty/Staff'
    else 'Student'
  end as person_type
from dir_person dp 
  inner join dir_affiliation daf
    on daf.uuid = dp.uuid
    ),

dir_person_affiliation_email AS (
    select * from dir_person_affiliation as dpa left join
        dirsvcs.dir_email de on 
        on de.uuid = dpa.uuid
            and de.mail_flag = 'M'
            and de.mail is not null
)

select * from dir_person_affiliation_email 
    where (
    primaryaffiliation != 'Student'
    and lower(mail) not like '%cu.edu'
  ) or (
    primaryaffiliation = 'Student'
    and exists (
      select 'x' from dirsvcs.dir_acad_career where uuid = dir_person_affiliation_email.uuid
    )
  )
  and mail is not NULL
  and lower(mail) not like '%cu.edu'


'''If there are columns with the same name in dir_email and dir_affiliation, we need to use an alias in the last select query.'''