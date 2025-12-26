package com.britemoon.cps.sbs;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.imc.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class Form extends BriteObject
{
	// === Properties ===

	public String s_cust_id = null;
	public String s_form_id = null;
	public String s_type_id = null;
	public String s_prefill_no_validate_flag = null;
	public String s_post_validate_flag = null;
	public String s_form_name = null;
	public String s_update_incomplete_flag = null;
	public String s_prefill_flag = null;
	public String s_high_priority_flag = null;
	public String s_form_next_success = null;
	public String s_form_alt_prefill_bad_recip = null;
	public String s_form_source = null;
	public String s_form_alt_prefill_no_recip = null;
	public String s_form_url = null;
	public String s_confirm_url = null;
	public String s_upd_rule_id = null;
	public String s_upd_hierarchy_id = null;
	public String s_unsub_hierarchy_id = null;
	private static Logger logger = Logger.getLogger(Form.class.getName());

	// === SBS extra fields ===

	public String s_high_priority_post_url = null;
	public String s_prefill_url = null;
	public String s_vanity_domain = null;

	// === Parents ===

	// === Children ===

	public FormEditInfo m_FormEditInfo = null;

	// === Constructors ===

	public Form()
	{
	}

	public Form(String sFormId) throws Exception
	{
		s_form_id = sFormId;
		retrieve();
	}

	public Form(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
			" SELECT" +
					"	cust_id," +
					"	form_id," +
					"	type_id," +
					"	prefill_no_validate_flag," +
					"	post_validate_flag," +
					"	form_name," +
					"	update_incomplete_flag," +
					"	prefill_flag," +
					"	high_priority_flag," +
					"	form_next_success," +
					"	form_alt_prefill_bad_recip," +
					"	form_source," +
					"	form_alt_prefill_no_recip," +
					"	form_url," +
					"	confirm_url," +
					"	upd_rule_id," +
					"	upd_hierarchy_id," +
					"	unsub_hierarchy_id" +
					" FROM csbs_form" +
					" WHERE" +
					"	(form_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_form_id);

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
		s_cust_id = rs.getString(1);
		s_form_id = rs.getString(2);
		s_type_id = rs.getString(3);
		s_prefill_no_validate_flag = rs.getString(4);
		s_post_validate_flag = rs.getString(5);
		b = rs.getBytes(6);
		s_form_name = (b == null)?null:new String(b,"UTF-8");
		s_update_incomplete_flag = rs.getString(7);
		s_prefill_flag = rs.getString(8);
		s_high_priority_flag = rs.getString(9);
		s_form_next_success = rs.getString(10);
		s_form_alt_prefill_bad_recip = rs.getString(11);
		b = rs.getBytes(12);
		s_form_source = (b == null)?null:new String(b,"UTF-8");
		s_form_alt_prefill_no_recip = rs.getString(13);
		b = rs.getBytes(14);
		s_form_url = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(15);
		s_confirm_url = (b == null)?null:new String(b,"UTF-8");
		s_upd_rule_id = rs.getString(16);
		s_upd_hierarchy_id = rs.getString(17);
		s_unsub_hierarchy_id = rs.getString(18);
	}

	// === DB Method save()===

	public String m_sSaveSql =
			" EXECUTE usp_csbs_form_save" +
					"	@cust_id=?," +
					"	@form_id=?," +
					"	@type_id=?," +
					"	@prefill_no_validate_flag=?," +
					"	@post_validate_flag=?," +
					"	@form_name=?," +
					"	@update_incomplete_flag=?," +
					"	@prefill_flag=?," +
					"	@high_priority_flag=?," +
					"	@form_next_success=?," +
					"	@form_alt_prefill_bad_recip=?," +
					"	@form_source=?," +
					"	@form_alt_prefill_no_recip=?," +
					"	@form_url=?," +
					"	@confirm_url=?," +
					"	@upd_rule_id=?," +
					"	@upd_hierarchy_id=?," +
					"	@unsub_hierarchy_id=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_form_id);
		pstmt.setString(3, s_type_id);
		pstmt.setString(4, s_prefill_no_validate_flag);
		pstmt.setString(5, s_post_validate_flag);
		if(s_form_name == null) pstmt.setString(6, s_form_name);
		else pstmt.setBytes(6, s_form_name.getBytes("UTF-8"));
		pstmt.setString(7, s_update_incomplete_flag);
		pstmt.setString(8, s_prefill_flag);
		pstmt.setString(9, s_high_priority_flag);
		pstmt.setString(10, s_form_next_success);
		pstmt.setString(11, s_form_alt_prefill_bad_recip);
		if(s_form_source == null) pstmt.setNull(12, java.sql.Types.BLOB);
		else pstmt.setBytes(12, s_form_source.getBytes("UTF-8"));
		pstmt.setString(13, s_form_alt_prefill_no_recip);
		if(s_form_url == null) pstmt.setString(14, s_form_url);
		else pstmt.setBytes(14, s_form_url.getBytes("UTF-8"));
		if(s_confirm_url == null) pstmt.setString(15, s_confirm_url);
		else pstmt.setBytes(15, s_confirm_url.getBytes("UTF-8"));
		pstmt.setString(16, s_upd_rule_id);
		pstmt.setString(17, s_upd_hierarchy_id);
		pstmt.setString(18, s_unsub_hierarchy_id);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_form_id = rs.getString(1);

			nReturnCode = 1;
		}
		rs.close();

		return nReturnCode;
	}

	public int saveChildren(Connection conn) throws Exception
	{
		if (m_FormEditInfo!=null)
		{
			m_FormEditInfo.s_form_id = s_form_id;
			m_FormEditInfo.save(conn);
		}
		return 1;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
			" DELETE FROM csbs_form" +
					" WHERE" +
					"	(form_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteChildren(Connection conn) throws Exception
	{
		if(m_FormEditInfo!=null) m_FormEditInfo.delete(conn);
		return 1;
	}

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_form_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "form";
	public String getMainElementName() { return m_sMainElementName; }

	// === To XML Methods ===

	public void appendPropsToXml(Element e)
	{
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_form_id != null ) XmlUtil.appendTextChild(e, "form_id", s_form_id);
		if( s_type_id != null ) XmlUtil.appendTextChild(e, "type_id", s_type_id);
		if( s_prefill_no_validate_flag != null ) XmlUtil.appendTextChild(e, "prefill_no_validate_flag", s_prefill_no_validate_flag);
		if( s_post_validate_flag != null ) XmlUtil.appendTextChild(e, "post_validate_flag", s_post_validate_flag);
		if( s_form_name != null ) XmlUtil.appendCDataChild(e, "form_name", s_form_name);
		if( s_update_incomplete_flag != null ) XmlUtil.appendTextChild(e, "update_incomplete_flag", s_update_incomplete_flag);
		if( s_prefill_flag != null ) XmlUtil.appendTextChild(e, "prefill_flag", s_prefill_flag);
		if( s_high_priority_flag != null ) XmlUtil.appendTextChild(e, "high_priority_flag", s_high_priority_flag);
		if( s_form_next_success != null ) XmlUtil.appendTextChild(e, "form_next_success", s_form_next_success);
		if( s_form_alt_prefill_bad_recip != null ) XmlUtil.appendTextChild(e, "form_alt_prefill_bad_recip", s_form_alt_prefill_bad_recip);
		if( s_form_source != null ) XmlUtil.appendCDataChild(e, "form_source", s_form_source);
		if( s_form_alt_prefill_no_recip != null ) XmlUtil.appendTextChild(e, "form_alt_prefill_no_recip", s_form_alt_prefill_no_recip);
		if( s_form_url != null ) XmlUtil.appendCDataChild(e, "form_url", s_form_url);
		if( s_confirm_url != null ) XmlUtil.appendCDataChild(e, "confirm_url", s_confirm_url);
		if( s_upd_rule_id != null ) XmlUtil.appendTextChild(e, "upd_rule_id", s_upd_rule_id);
		if( s_upd_hierarchy_id != null ) XmlUtil.appendTextChild(e, "upd_hierarchy_id", s_upd_hierarchy_id);
		if( s_unsub_hierarchy_id != null ) XmlUtil.appendTextChild(e, "unsub_hierarchy_id", s_unsub_hierarchy_id);

		if( s_high_priority_post_url != null ) XmlUtil.appendCDataChild(e, "high_priority_post_url", s_high_priority_post_url);
		if( s_prefill_url != null ) XmlUtil.appendCDataChild(e, "prefill_url", s_prefill_url);
		if( s_vanity_domain != null ) XmlUtil.appendCDataChild(e, "vanity_domain", s_vanity_domain);
	}

	public void appendChildrenToXml(Element e)
	{
		if (m_FormEditInfo != null) appendChild(e, m_FormEditInfo);
	}

	// === From XML Methods ===

	public void getPropsFromXml(Element e)
	{
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_form_id = XmlUtil.getChildTextValue(e, "form_id");
		s_type_id = XmlUtil.getChildTextValue(e, "type_id");
		s_prefill_no_validate_flag = XmlUtil.getChildTextValue(e, "prefill_no_validate_flag");
		s_post_validate_flag = XmlUtil.getChildTextValue(e, "post_validate_flag");
		s_form_name = XmlUtil.getChildCDataValue(e, "form_name");
		s_update_incomplete_flag = XmlUtil.getChildTextValue(e, "update_incomplete_flag");
		s_prefill_flag = XmlUtil.getChildTextValue(e, "prefill_flag");
		s_high_priority_flag = XmlUtil.getChildTextValue(e, "high_priority_flag");
		s_form_next_success = XmlUtil.getChildTextValue(e, "form_next_success");
		s_form_alt_prefill_bad_recip = XmlUtil.getChildTextValue(e, "form_alt_prefill_bad_recip");
		s_form_source = XmlUtil.getChildCDataValue(e, "form_source");
		s_form_alt_prefill_no_recip = XmlUtil.getChildTextValue(e, "form_alt_prefill_no_recip");
		s_form_url = XmlUtil.getChildCDataValue(e, "form_url");
		s_confirm_url = XmlUtil.getChildCDataValue(e, "confirm_url");
		s_upd_rule_id = XmlUtil.getChildTextValue(e, "upd_rule_id");
		s_upd_hierarchy_id = XmlUtil.getChildTextValue(e, "upd_hierarchy_id");
		s_unsub_hierarchy_id = XmlUtil.getChildTextValue(e, "unsub_hierarchy_id");
	}

	public void getChildrenFromXml(Element e) throws Exception
	{
		Element eFormEditInfo = XmlUtil.getChildByName(e, "form_edit_info");
		if(eFormEditInfo != null) m_FormEditInfo = new FormEditInfo(eFormEditInfo);
	}

	// === Other Methods ===

	public void setupSBS() throws Exception
	{
		try
		{
			Vector services = Services.getByCust(ServiceType.RSBS_PREFILL_RESPONDER, s_cust_id);
			Service service = (Service) services.get(0);
			s_prefill_url = service.getURL().toString();
		}
		catch (Exception e)
		{
			throw new Exception("Customer does not have the RSBS_PREFILL_RESPONDER service");
		}

		// === === ===

		try
		{
			Vector services = Services.getByCust(ServiceType.RSBS_HIGH_PRIORITY_ACTIVITY_RECEIVE, s_cust_id);
			Service service = (Service) services.get(0);
			s_high_priority_post_url = service.getURL().toString();
		}
		catch (Exception e)
		{
			throw new Exception("Customer does not have the RSBS_HIGH_PRIORITY_ACTIVITY_RECEIVE service");
		}

		// === === ===

		ConnectionPool cp = null;
		Connection conn = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection(this);

			Statement stmt = null;
			try
			{
				String sSql =
						" SELECT TOP 1 v.domain " +
								" FROM cadm_vanity_domain v, cadm_mod_inst m " +
								" WHERE m.mod_inst_id = v.mod_inst_id" +
								" AND m.mod_id = " + Module.ASBS +
								" AND v.cust_id = " + s_cust_id;

				stmt = conn.createStatement();
				ResultSet rs = stmt.executeQuery(sSql);
				if(rs.next()) s_vanity_domain = rs.getString(1);
				rs.close();

				// === === ===

				String sRequest = this.toXml();
				String sResponse = Service.communicate(ServiceType.ASBS_FORM_SETUP, s_cust_id, sRequest);
				Element eResponse = XmlUtil.getRootElement(sResponse);
				s_form_url = XmlUtil.getCDataValue(eResponse);

				// === === ===

				sSql =
						" UPDATE csbs_form SET form_url = '" + s_form_url + "' WHERE form_id = " + s_form_id;
				stmt.executeUpdate(sSql);
			}
			catch(Exception ex) { throw ex; }
			finally { if (stmt != null) stmt.close(); }
		}
		catch(Exception ex) { throw ex; }
		finally { if (conn != null) cp.free(conn); }
	}

	public void setupRCP() throws Exception
	{
		String sRequest = this.toXml();
		String sResponse = Service.communicate(ServiceType.RSBS_FORM_SETUP, s_cust_id, sRequest);
		Element eResponse = XmlUtil.getRootElement(sResponse);
	}
}


