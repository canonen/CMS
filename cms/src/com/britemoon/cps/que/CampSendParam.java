package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class CampSendParam extends BriteObject
{
	// === Properties ===

	public String s_camp_id = null;
	public String s_recip_qty_limit = null;
	public String s_randomly = null;
	public String s_delay = null;
	public String s_limit_per_hour = null;
	public String s_msg_per_recip_limit = null;
	public String s_response_frwd_addr = null;
	public String s_msg_per_email821_limit = null;
	public String s_camp_frequency = null;
	public String s_queue_date = null;
	public String s_queue_daily_flag = null;
	public String s_queue_daily_time = null;
	public String s_queue_daily_weekday_mask = null;	
	public String s_test_recip_qty_limit = null;
	public String s_link_append_text = null;
	private static Logger logger = Logger.getLogger(CampSendParam.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public CampSendParam()
	{
	}
	
	public CampSendParam(String sCampId) throws Exception
	{
		s_camp_id = sCampId;
		retrieve();
	}

	public CampSendParam(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	camp_id," +
		"	recip_qty_limit," +
		"	randomly," +
		"	delay," +
		"	limit_per_hour," +
		"	msg_per_recip_limit," +
		"	response_frwd_addr," +
		"	msg_per_email821_limit," +
		"	camp_frequency," +
		"	queue_date," +
		"	queue_daily_flag," +
		"	queue_daily_time," +
		"	queue_daily_weekday_mask," +
		"	test_recip_qty_limit," +
		"	link_append_text" +
		" FROM cque_camp_send_param WITH(NOLOCK)" +
		" WHERE" +
		"	(camp_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_camp_id);

		ResultSet rs = pstmt.executeQuery();
		if (rs.next())
		{
			getPropsFromResultSetRow(rs);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	public void getPropsFromResultSetRow(ResultSet rs) throws Exception
	{
		byte[] b = null;
		s_camp_id = rs.getString(1);
		s_recip_qty_limit = rs.getString(2);
		s_randomly = rs.getString(3);
		s_delay = rs.getString(4);
		s_limit_per_hour = rs.getString(5);
		s_msg_per_recip_limit = rs.getString(6);
		b = rs.getBytes(7);
		s_response_frwd_addr = (b == null)?null:new String(b,"UTF-8");
		s_msg_per_email821_limit = rs.getString(8);
		s_camp_frequency = rs.getString(9);
		s_queue_date = rs.getString(10);
		s_queue_daily_flag = rs.getString(11);
		s_queue_daily_time = rs.getString(12);
		s_queue_daily_weekday_mask = rs.getString(13);
		s_test_recip_qty_limit = rs.getString(14);
		b = rs.getBytes(15);
		s_link_append_text = (b == null)?null:new String(b,"UTF-8");
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cque_camp_send_param_save" +
		"	@camp_id=?," +
		"	@recip_qty_limit=?," +
		"	@randomly=?," +
		"	@delay=?," +
		"	@limit_per_hour=?," +
		"	@msg_per_recip_limit=?," +
		"	@response_frwd_addr=?," +
		"	@msg_per_email821_limit=?," +
		"	@camp_frequency=?," +
		"	@queue_date=?," +
		"	@queue_daily_flag=?," +
		"	@queue_daily_time=?," +
		"	@queue_daily_weekday_mask=?," +
		"	@test_recip_qty_limit=?," +
		"	@link_append_text=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_camp_id);
		pstmt.setString(2, s_recip_qty_limit);
		pstmt.setString(3, s_randomly);
		pstmt.setString(4, s_delay);
		pstmt.setString(5, s_limit_per_hour);
		pstmt.setString(6, s_msg_per_recip_limit);
		if(s_response_frwd_addr == null) pstmt.setString(7, s_response_frwd_addr);
		else pstmt.setBytes(7, s_response_frwd_addr.getBytes("UTF-8"));
		pstmt.setString(8, s_msg_per_email821_limit);
		pstmt.setString(9, s_camp_frequency);
		pstmt.setString(10, s_queue_date);
		pstmt.setString(11, s_queue_daily_flag);
		pstmt.setString(12, s_queue_daily_time);
		pstmt.setString(13, s_queue_daily_weekday_mask);
		pstmt.setString(14, s_test_recip_qty_limit);
		if(s_link_append_text == null) pstmt.setString(15, s_link_append_text);
		else pstmt.setBytes(15, s_link_append_text.getBytes("UTF-8"));

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_camp_id = rs.getString(1);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cque_camp_send_param" +
		" WHERE" +
		"	(camp_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_camp_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "camp_send_param";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_camp_id != null ) XmlUtil.appendTextChild(e, "camp_id", s_camp_id);
		if( s_recip_qty_limit != null ) XmlUtil.appendTextChild(e, "recip_qty_limit", s_recip_qty_limit);
		if( s_randomly != null ) XmlUtil.appendTextChild(e, "randomly", s_randomly);
		if( s_delay != null ) XmlUtil.appendTextChild(e, "delay", s_delay);
		if( s_limit_per_hour != null ) XmlUtil.appendTextChild(e, "limit_per_hour", s_limit_per_hour);
		if( s_msg_per_recip_limit != null ) XmlUtil.appendTextChild(e, "msg_per_recip_limit", s_msg_per_recip_limit);
		if( s_response_frwd_addr != null ) XmlUtil.appendCDataChild(e, "response_frwd_addr", s_response_frwd_addr);
		if( s_msg_per_email821_limit != null ) XmlUtil.appendTextChild(e, "msg_per_email821_limit", s_msg_per_email821_limit);
		if( s_camp_frequency != null ) XmlUtil.appendTextChild(e, "camp_frequency", s_camp_frequency);
		if( s_queue_date != null ) XmlUtil.appendTextChild(e, "queue_date", s_queue_date);
		if( s_queue_daily_flag != null ) XmlUtil.appendTextChild(e, "queue_daily_flag", s_queue_daily_flag);
		if( s_queue_daily_time != null ) XmlUtil.appendTextChild(e, "queue_daily_time", s_queue_daily_time);
		if( s_queue_daily_weekday_mask != null ) XmlUtil.appendTextChild(e, "queue_daily_weekday_mask", s_queue_daily_weekday_mask);
		if( s_test_recip_qty_limit != null ) XmlUtil.appendTextChild(e, "test_recip_qty_limit", s_test_recip_qty_limit);
		if( s_link_append_text != null ) XmlUtil.appendCDataChild(e, "link_append_text", s_link_append_text);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_camp_id = XmlUtil.getChildTextValue(e, "camp_id");
		s_recip_qty_limit = XmlUtil.getChildTextValue(e, "recip_qty_limit");
		s_randomly = XmlUtil.getChildTextValue(e, "randomly");
		s_delay = XmlUtil.getChildTextValue(e, "delay");
		s_limit_per_hour = XmlUtil.getChildTextValue(e, "limit_per_hour");
		s_msg_per_recip_limit = XmlUtil.getChildTextValue(e, "msg_per_recip_limit");
		s_response_frwd_addr = XmlUtil.getChildCDataValue(e, "response_frwd_addr");
		s_msg_per_email821_limit = XmlUtil.getChildTextValue(e, "msg_per_email821_limit");
		s_camp_frequency = XmlUtil.getChildTextValue(e, "camp_frequency");
		s_queue_date = XmlUtil.getChildTextValue(e, "queue_date");
		s_queue_daily_flag = XmlUtil.getChildTextValue(e, "queue_daily_flag");	
		s_queue_daily_time = XmlUtil.getChildTextValue(e, "queue_daily_time");
		s_queue_daily_weekday_mask = XmlUtil.getChildTextValue(e, "queue_daily_weekday_mask");
		s_test_recip_qty_limit = XmlUtil.getChildTextValue(e, "test_recip_qty_limit");
		s_link_append_text = XmlUtil.getChildCDataValue(e, "link_append_text");
	}

	// === Other Methods ===
}


