update ctm_templates 
   set active = NULL 
 where template_id in (select template_id 
                         from ctm_templates_old 
                        where active is null)
go
update ctm_templates 
   set global_flag = NULL 
 where template_id in (select template_id 
                         from ctm_templates_old 
                        where global_flag is null)
go

