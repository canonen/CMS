package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.cnt.*;
import com.britemoon.cps.tgt.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class Campaign extends BriteObject
{
	// === Properties ===

	public String s_camp_id = null;
	public String s_type_id = null;
	public String s_status_id = null;
	public String s_camp_name = null;
	public String s_cust_id = null;
	public String s_cont_id = null;
	public String s_filter_id = null;
	public String s_seed_list_id = null;
	public String s_origin_camp_id = null;
	public String s_sample_id = null;
	public String s_approval_flag = null;
	public String s_mode_id = null;
	public String s_media_type_id = null;
	public String s_pv_iq = null;
	public String s_sample_filter_id = null;
	public String s_sample_priority = null;
	public String s_camp_code = null;
	private static Logger logger = Logger.getLogger(Campaign.class.getName());

	// === Parents ===

	public Content m_Content = null;
	public Filter m_Filter = null;
	public SeedList m_SeedList = null;

	// === Children ===

	public CampEditInfo m_CampEditInfo = null;
	public CampList m_CampList = null;
	public CampSendParam m_CampSendParam = null;
	public MsgHeader m_MsgHeader = null;
	public Schedule m_Schedule = null;
	public LinkedCamp m_LinkedCamp = null;

	// CampSampleset is not exactly a child of this campaign
	// in fact it supposed to be a child of origin campaign
	// but origin campaign never goes to RCP
	// so here is probably the most reasonable place
	// to add CampSampleset

	public CampSampleset m_CampSampleset = null;

	// === Constructors ===

	public Campaign()
	{
	}

	public Campaign(String sCampId) throws Exception
	{
		s_camp_id = sCampId;
		retrieve();
	}

	public Campaign(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	camp_id," +
		"	type_id," +
		"	status_id," +
		"	camp_name," +
		"	cust_id," +
		"	cont_id," +
		"	filter_id," +
		"	seed_list_id," +
		"	origin_camp_id," +
		"	sample_id," +
		"	approval_flag, " +
		"	mode_id, " +
		"	media_type_id, " +
		"	pv_iq," +
		"	sample_filter_id," +
		"	sample_priority," +
		"   camp_code" +
		" FROM cque_campaign" +
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
		s_type_id = rs.getString(2);
		s_status_id = rs.getString(3);
		b = rs.getBytes(4);
		s_camp_name = (b == null)?null:new String(b,"UTF-8");
		s_cust_id = rs.getString(5);
		s_cont_id = rs.getString(6);
		s_filter_id = rs.getString(7);
		s_seed_list_id = rs.getString(8);
		s_origin_camp_id = rs.getString(9);
		s_sample_id = rs.getString(10);
		s_approval_flag = rs.getString(11);
		s_mode_id = rs.getString(12);
		s_media_type_id = rs.getString(13);
		s_pv_iq = rs.getString(14);
		s_sample_filter_id= rs.getString(15);
		s_sample_priority= rs.getString(16);
		s_camp_code = rs.getString(17);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cque_campaign_save" +
		"	@camp_id=?," +
		"	@type_id=?," +
		"	@status_id=?," +
		"	@camp_name=?," +
		"	@cust_id=?," +
		"	@cont_id=?," +
		"	@filter_id=?," +
		"	@seed_list_id=?," +
		"	@origin_camp_id=?," +
		"	@sample_id=?," +
		"	@approval_flag=?," +
		"	@mode_id=?," +
		"	@media_type_id=?," +
		"	@pv_iq=?," +
	    "	@sample_filter_id=?," +
        "	@sample_priority=?,"+
        "	@camp_code=?";


	public String getSaveSql() { return m_sSaveSql; }

	public int saveParents(Connection conn) throws Exception
	{
		if (m_Content!=null)
		{
			m_Content.save(conn);
			s_cont_id = m_Content.s_cont_id;
		}

		if (m_Filter!=null)
		{
			m_Filter.save(conn);
			s_filter_id = m_Filter.s_filter_id;
		}

		if (m_SeedList!=null)
		{
			m_SeedList.save(conn);
			s_seed_list_id = m_SeedList.s_filter_id;
		}

		return 1;
	}

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_camp_id);
		pstmt.setString(2, s_type_id);
		pstmt.setString(3, s_status_id);
		if(s_camp_name == null) pstmt.setString(4, s_camp_name);
		else pstmt.setBytes(4, s_camp_name.getBytes("UTF-8"));
		pstmt.setString(5, s_cust_id);
		pstmt.setString(6, s_cont_id);
		pstmt.setString(7, s_filter_id);
		pstmt.setString(8, s_seed_list_id);
		pstmt.setString(9, s_origin_camp_id);
		pstmt.setString(10, s_sample_id);
		pstmt.setString(11, s_approval_flag);
		pstmt.setString(12, s_mode_id);
		pstmt.setString(13, s_media_type_id);
		pstmt.setString(14, s_pv_iq);
		pstmt.setString(15, s_sample_filter_id);
		pstmt.setString(16, s_sample_priority);
		pstmt.setString(17, s_camp_code);

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

	public int saveChildren(Connection conn) throws Exception
	{
		if (m_CampEditInfo!=null)
		{
		 	m_CampEditInfo.s_camp_id = s_camp_id;
		  	m_CampEditInfo.save(conn);
		}

		if (m_CampList!=null)
		{
		 	m_CampList.s_camp_id = s_camp_id;
		  	m_CampList.save(conn);
		}

		if (m_CampSendParam!=null)
		{
		 	m_CampSendParam.s_camp_id = s_camp_id;
		  	m_CampSendParam.save(conn);
		}

		if (m_MsgHeader!=null)
		{
		 	m_MsgHeader.s_camp_id = s_camp_id;
		  	m_MsgHeader.save(conn);
		}

		if (m_Schedule!=null)
		{
		 	m_Schedule.s_camp_id = s_camp_id;
		  	m_Schedule.save(conn);
		}

		if (m_LinkedCamp!=null)
		{
		 	m_LinkedCamp.s_camp_id = s_camp_id;
		  	m_LinkedCamp.save(conn);
		}

		if (m_CampSampleset != null)
		{
			m_CampSampleset.s_camp_id = s_origin_camp_id; // see comments on m_CampSampleset above
			m_CampSampleset.save(conn);
		}

		return 1;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cque_campaign" +
		" WHERE" +
		"	(camp_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_camp_id);
		return pstmt.executeUpdate();
	}

	public int deleteParents(Connection conn) throws Exception
	{
		if(m_Content!=null) m_Content.delete(conn);
		if(m_Filter!=null) m_Filter.delete(conn);
		if(m_SeedList!=null) m_SeedList.delete(conn);
		return 1;
	}

	// === XML Methods ===

	public String m_sMainElementName = "campaign";
	public String getMainElementName() { return m_sMainElementName; }

	// === To XML Methods ===

	public void appendPropsToXml(Element e)
	{
		if( s_camp_id != null ) XmlUtil.appendTextChild(e, "camp_id", s_camp_id);
		if( s_type_id != null ) XmlUtil.appendTextChild(e, "type_id", s_type_id);
		if( s_status_id != null ) XmlUtil.appendTextChild(e, "status_id", s_status_id);
		if( s_camp_name != null ) XmlUtil.appendCDataChild(e, "camp_name", s_camp_name);
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_cont_id != null ) XmlUtil.appendTextChild(e, "cont_id", s_cont_id);
		if( s_filter_id != null ) XmlUtil.appendTextChild(e, "filter_id", s_filter_id);
		if( s_seed_list_id != null ) XmlUtil.appendTextChild(e, "seed_list_id", s_seed_list_id);
		if( s_origin_camp_id != null ) XmlUtil.appendTextChild(e, "origin_camp_id", s_origin_camp_id);
		if( s_sample_id != null ) XmlUtil.appendTextChild(e, "sample_id", s_sample_id);
		if( s_approval_flag != null ) XmlUtil.appendTextChild(e, "approval_flag", s_approval_flag);
		if( s_mode_id != null ) XmlUtil.appendTextChild(e, "mode_id", s_mode_id);
		if( s_media_type_id != null ) XmlUtil.appendTextChild(e, "media_type_id", s_media_type_id);
		if( s_pv_iq != null ) XmlUtil.appendTextChild(e, "pv_iq", s_pv_iq);
		if( s_sample_filter_id != null ) XmlUtil.appendTextChild(e, "sample_filter_id", s_sample_filter_id);
		if( s_sample_priority != null ) XmlUtil.appendTextChild(e, "sample_priority", s_sample_priority);
		if( s_camp_code != null ) XmlUtil.appendTextChild(e, "camp_code", s_camp_code);

	}

	public void appendParentsToXml(Element e)
	{
		if (m_Content != null) appendChild(e, m_Content);
		if (m_Filter != null) appendChild(e, m_Filter);
		if (m_SeedList != null) appendChild(e, m_SeedList);
	}

	public void appendChildrenToXml(Element e)
	{
		if (m_CampEditInfo != null) appendChild(e, m_CampEditInfo);
		if (m_CampList != null) appendChild(e, m_CampList);
		if (m_CampSendParam != null) appendChild(e, m_CampSendParam);
		if (m_MsgHeader != null) appendChild(e, m_MsgHeader);
		if (m_Schedule != null) appendChild(e, m_Schedule);
		if (m_LinkedCamp != null) appendChild(e, m_LinkedCamp);
		if (m_CampSampleset != null) appendChild(e, m_CampSampleset);
	}

	// === From XML Methods ===

	public void getPropsFromXml(Element e)
	{
		s_camp_id = XmlUtil.getChildTextValue(e, "camp_id");
		s_type_id = XmlUtil.getChildTextValue(e, "type_id");
		s_status_id = XmlUtil.getChildTextValue(e, "status_id");
		s_camp_name = XmlUtil.getChildCDataValue(e, "camp_name");
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_cont_id = XmlUtil.getChildTextValue(e, "cont_id");
		s_filter_id = XmlUtil.getChildTextValue(e, "filter_id");
		s_seed_list_id = XmlUtil.getChildTextValue(e, "seed_list_id");
		s_origin_camp_id = XmlUtil.getChildTextValue(e, "origin_camp_id");
		s_sample_id = XmlUtil.getChildTextValue(e, "sample_id");
		s_approval_flag = XmlUtil.getChildTextValue(e, "approval_flag");
		s_mode_id = XmlUtil.getChildTextValue(e, "mode_id");
		s_media_type_id = XmlUtil.getChildTextValue(e, "media_type_id");
		s_pv_iq = XmlUtil.getChildTextValue(e, "pv_iq");
		s_sample_filter_id = XmlUtil.getChildTextValue(e, "sample_filter_id");
		s_sample_priority = XmlUtil.getChildTextValue(e, "sample_priority");
		s_camp_code = XmlUtil.getChildTextValue(e, "camp_code");
	}

	public void getParentsFromXml(Element e) throws Exception
	{
		Element eContent = XmlUtil.getChildByName(e, "content");
		if(eContent != null) m_Content = new Content(eContent);

		Element eFilter = XmlUtil.getChildByName(e, "filter");
		if(eFilter != null) m_Filter = new Filter(eFilter);

		Element eSeedList = XmlUtil.getChildByName(e, "seed_list");
		if(eSeedList != null) m_SeedList = new SeedList(eSeedList);
	}

	public void getChildrenFromXml(Element e) throws Exception
	{
		Element eCampEditInfo = XmlUtil.getChildByName(e, "camp_edit_info");
		if(eCampEditInfo != null) m_CampEditInfo = new CampEditInfo(eCampEditInfo);

		Element eCampList = XmlUtil.getChildByName(e, "camp_list");
		if(eCampList != null) m_CampList = new CampList(eCampList);

		Element eCampSendParam = XmlUtil.getChildByName(e, "camp_send_param");
		if(eCampSendParam != null) m_CampSendParam = new CampSendParam(eCampSendParam);

		Element eMsgHeader = XmlUtil.getChildByName(e, "msg_header");
		if(eMsgHeader != null) m_MsgHeader = new MsgHeader(eMsgHeader);

		Element eSchedule = XmlUtil.getChildByName(e, "schedule");
		if(eSchedule != null) m_Schedule = new Schedule(eSchedule);

		Element eLinkedCamp = XmlUtil.getChildByName(e, "linked_camp");
		if(eLinkedCamp != null) m_LinkedCamp = new LinkedCamp(eLinkedCamp);

		Element eCampSampleset = XmlUtil.getChildByName(e, "camp_sampleset");
		if(eCampSampleset != null) m_CampSampleset = new CampSampleset(eCampSampleset);
	}

	// === Other Methods ===
}
