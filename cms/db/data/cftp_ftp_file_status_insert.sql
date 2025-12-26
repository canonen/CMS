PRINT ('cftp_ftp_file_status Insert and Update rows')
GO

insert into cftp_ftp_file_status (status_id, status_name)
values (6,'Offer Load finished successfully')

insert into cftp_ftp_file_status (status_id, status_name)
values (7,'Offer Load finished WITH ERROR')

update cftp_ftp_file_status set status_name = 'Ready to load import' 
where status_id = 3

update cftp_ftp_file_status set status_name = 'FTP and Load have finished successfully' 
where status_id = 4

update cftp_ftp_file_status set status_name = 'Recip/Entity FTP&Load finished IN ERROR' 
where status_id = 5
