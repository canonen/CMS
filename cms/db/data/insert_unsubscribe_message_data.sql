-- data scripts to support Unsubscribe messages feature in Britemoon 6.1

-- Insert new feature_id in ccps_feature
INSERT INTO [brite_ccps_500].[dbo].[ccps_feature] ([feature_id],[feature_name]) VALUES (610,'UNSUB_EDIT');

-- Insert new object type in ccps_object_type
INSERT INTO [brite_ccps_500].[dbo].[ccps_object_type] ([type_id],[type_name]) VALUES (350,'Unsubscribe Messages');

-- Insert access values for user 77 in ccps_access_mask
INSERT INTO [brite_ccps_500].[dbo].[ccps_access_mask] ([user_id],[type_id],[mask]) VALUES (77,350,62);

-- Insert in cadm_mod_inst_service to include new service_type
INSERT INTO [brite_ccps_500].[dbo].[cadm_mod_inst_service] ([mod_inst_id],[service_type_id],[protocol],[port],[path]) VALUES (107, 102, 'http', 80, '/sadm/imc/adm/unsub_msg_setup.jsp');
INSERT INTO [brite_ccps_500].[dbo].[cadm_mod_inst_service] ([mod_inst_id],[service_type_id],[protocol],[port],[path]) VALUES (125, 102, 'http', 8888, '/sadm/imc/adm/unsub_msg_setup.jsp');


