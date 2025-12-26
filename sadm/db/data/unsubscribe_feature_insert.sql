-- inserting data for Unsubscribe Message feature in britemoon 6.1

-- Insert service_type_id in sadm_service_type
INSERT INTO [brite_sadm_500].[dbo].[sadm_service_type] ([type_id],[type_name]) VALUES (102,'SADM_UNSUB_MESSAGE_UPDATE');

-- Insert new feature_id in sadm_feature
INSERT INTO [brite_sadm_500].[dbo].[sadm_feature] ([feature_id],[feature_name]) VALUES (610,'UNSUB_EDIT');

-- Insert new object_type in scps_object_type
INSERT INTO [brite_sadm_500].[dbo].[scps_object_type] ([type_id],[type_name]) VALUES (350,'Unsubscribe Messages');

-- Insert access values for user 77 in scps_access_mask
INSERT INTO [brite_sadm_500].[dbo].[scps_access_mask] ([user_id],[type_id],[mask]) VALUES (77,350,62);