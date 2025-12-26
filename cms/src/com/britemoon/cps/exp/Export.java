package com.britemoon.cps.exp;

import com.britemoon.*;
import com.britemoon.cps.*;
import java.sql.*;
import java.text.SimpleDateFormat;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class Export extends BriteObject
{
	private static Logger logger = Logger.getLogger(Export.class.getName());
	public String s_file_id = null;
	public String s_type_id = null;
	public String s_cust_id = null;
	public String s_export_name = null;
	public String s_file_url = null;
	public String s_status_id = null;
	public String s_params = null;
	public String s_attr_list = null;
	public String s_delimiter = null;
	public String s_action = null;
	public String s_stored_proc = null;
	
	//==== Children====
	public ExportParams m_ExportParams = null;
	
//	 === Constructors ===

	public Export()
	{
	}
	
	public Export(String sFileId) throws Exception
	{
		s_file_id = sFileId;
		retrieve();
	}
	
	public Export(Element e) throws Exception
	{
		fromXml(e);
	}
	
	public Export (RecipList rl) throws Exception
	{
		// Create new export from a RecipList object
		ExportParams eps = new ExportParams();
		int paramCnt = 0;

		s_type_id = String.valueOf(ExportType.STANDARD);
		s_status_id = rl.s_status_id;
		s_cust_id = rl.s_cust_id;
		s_attr_list = rl.s_attr_list;
		s_delimiter = rl.s_delimiter;
		s_action = rl.sAction;
				
		s_file_id = rl.s_recip_id;
		//getExportLocations(this);
		
		s_export_name = rl.s_export_name;
		s_file_url = rl.s_file_url;
		s_params = rl.s_params;

		if (rl.s_camp_id != null)
		{
			paramCnt++;
			ExportParam ep = new ExportParam();
			ep.s_file_id = s_file_id;
			ep.s_param_id = String.valueOf(paramCnt);
			ep.s_param_name = "camp_id";
			ep.s_param_value = rl.s_camp_id;
			eps.add(ep);
		}
		if (rl.s_chunk_id != null)
		{
			paramCnt++;
			ExportParam ep = new ExportParam();
			ep.s_file_id = s_file_id;
			ep.s_param_id = String.valueOf(paramCnt);
			ep.s_param_name = "chunk_id";
			ep.s_param_value = rl.s_chunk_id;
			eps.add(ep);
		}
		if (rl.s_link_id != null)
		{
			paramCnt++;
			ExportParam ep = new ExportParam();
			ep.s_file_id = s_file_id;
			ep.s_param_id = String.valueOf(paramCnt);
			ep.s_param_name = "link_id";
			ep.s_param_value = rl.s_link_id;
			eps.add(ep);
		}
		if (rl.s_content_type != null)
		{
			paramCnt++;
			ExportParam ep = new ExportParam();
			ep.s_file_id = s_file_id;
			ep.s_param_id = String.valueOf(paramCnt);
			ep.s_param_name = "content_type";
			ep.s_param_value = rl.s_content_type;
			eps.add(ep);
		}
		if (rl.s_form_id != null)
		{
			paramCnt++;
			ExportParam ep = new ExportParam();
			ep.s_file_id = s_file_id;
			ep.s_param_id = String.valueOf(paramCnt);
			ep.s_param_name = "form_id";
			ep.s_param_value = rl.s_form_id;
			eps.add(ep);
		}
		if (rl.s_filter_id != null)
		{
			paramCnt++;
			ExportParam ep = new ExportParam();
			ep.s_file_id = s_file_id;
			ep.s_param_id = String.valueOf(paramCnt);
			ep.s_param_name = "filter_id";
			ep.s_param_value = rl.s_filter_id;
			eps.add(ep);
		}
		if (rl.s_batch_id != null)
		{
			paramCnt++;
			ExportParam ep = new ExportParam();
			ep.s_file_id = s_file_id;
			ep.s_param_id = String.valueOf(paramCnt);
			ep.s_param_name = "batch_id";
			ep.s_param_value = rl.s_batch_id;
			eps.add(ep);
		}
		if (rl.s_bback_category != null)
		{
			paramCnt++;
			ExportParam ep = new ExportParam();
			ep.s_file_id = s_file_id;
			ep.s_param_id = String.valueOf(paramCnt);
			ep.s_param_name = "bback_category";
			ep.s_param_value = rl.s_bback_category;
			eps.add(ep);
		}
		if (rl.s_unsub_level != null)
		{
			paramCnt++;
			ExportParam ep = new ExportParam();
			ep.s_file_id = s_file_id;
			ep.s_param_id = String.valueOf(paramCnt);
			ep.s_param_name = "unsub_level";
			ep.s_param_value = rl.s_unsub_level;
			eps.add(ep);
		}
		if (rl.s_domain != null)
		{
			paramCnt++;
			ExportParam ep = new ExportParam();
			ep.s_file_id = s_file_id;
			ep.s_param_id = String.valueOf(paramCnt);
			ep.s_param_name = "domain";
			ep.s_param_value = rl.s_domain;
			eps.add(ep);
		}
		if (rl.s_newsletter_id != null)
		{
			paramCnt++;
			ExportParam ep = new ExportParam();
			ep.s_file_id = s_file_id;
			ep.s_param_id = String.valueOf(paramCnt);
			ep.s_param_name = "newsletter_id";
			ep.s_param_value = rl.s_newsletter_id;
			eps.add(ep);
		}

        if (rl.s_cache_id != null)
		{
			paramCnt++;
			ExportParam ep = new ExportParam();
			ep.s_file_id = s_file_id;
			ep.s_param_id = String.valueOf(paramCnt);
			ep.s_param_name = "cache_id";
			ep.s_param_value = rl.s_cache_id;
			eps.add(ep);
		}
		if (rl.s_cache_start_date != null)
		{
			paramCnt++;
			ExportParam ep = new ExportParam();
			ep.s_file_id = s_file_id;
			ep.s_param_id = String.valueOf(paramCnt);
			ep.s_param_name = "cache_start_date";
			ep.s_param_value = rl.s_cache_start_date;
			eps.add(ep);
		}

          if (rl.s_cache_end_date != null) 
          {
          	paramCnt++;
            ExportParam ep = new ExportParam();
            ep.s_file_id = s_file_id;
            ep.s_param_id = String.valueOf(paramCnt);
            ep.s_param_name = "cache_end_date";
            ep.s_param_value = rl.s_cache_end_date;
            eps.add(ep);
          }

          if (rl.s_cache_attr_id != null) {
            paramCnt++;
            ExportParam ep = new ExportParam();
            ep.s_file_id = s_file_id;
			ep.s_param_id = String.valueOf(paramCnt);
			ep.s_param_name = "cache_attr_id";
			ep.s_param_value = rl.s_cache_attr_id;
			eps.add(ep);
          }

          if (rl.s_cache_attr_value1 != null) 
          {
            paramCnt++;
            ExportParam ep = new ExportParam();
            ep.s_file_id = s_file_id;
			ep.s_param_id = String.valueOf(paramCnt);
			ep.s_param_name = "cache_attr_value1";
			ep.s_param_value = rl.s_cache_attr_value1;
			eps.add(ep);
          }

          if (rl.s_cache_attr_value2 != null) 
          {
            paramCnt++;
            ExportParam ep = new ExportParam();
            ep.s_file_id = s_file_id;
			ep.s_param_id = String.valueOf(paramCnt);
			ep.s_param_name = "cache_attr_value2";
			ep.s_param_value = rl.s_cache_attr_value2;
			eps.add(ep);
          }

          if (rl.s_cache_attr_operator != null) {
            paramCnt++;
            ExportParam ep = new ExportParam();
            ep.s_file_id = s_file_id;
			ep.s_param_id = String.valueOf(paramCnt);
			ep.s_param_name = "cache_attr_operator";
			ep.s_param_value = rl.s_cache_attr_operator;
			eps.add(ep);
          }

          if (rl.s_cache_user_id != null ) 
          {
            paramCnt++;
            ExportParam ep = new ExportParam();
            ep.s_file_id = s_file_id;
			ep.s_param_id = String.valueOf(paramCnt);
			ep.s_param_name = "cache_user_id";
			ep.s_param_value = rl.s_cache_user_id;
			eps.add(ep);
          }

		if (paramCnt > 0) m_ExportParams = eps;
	}
	
	public Export (CustomExport ce) throws Exception
	{
		// Create new export from a CustomExport object
		s_status_id = String.valueOf(ExportStatus.QUEUED);
		s_cust_id = ce.s_cust_id;
		s_delimiter = ce.s_delimiter;
		s_stored_proc = ce.s_stored_proc;
		s_type_id =
			(
				(ce.s_fixed_width_flag != null) &&
				(!ce.s_fixed_width_flag.equals("0"))
			) ? String.valueOf(ExportType.CUSTOM_FIXED_WIDTH) : String.valueOf(ExportType.CUSTOM);

		s_export_name = ce.s_export_name;
		s_params = ce.s_params;
		s_file_url = ce.s_file_url;
		s_file_id = ce.s_file_id;
		
		m_ExportParams = ce.eParams;

		//getExportLocations(this);
	}
	
	//	 === DB Methods ===
	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	file_id," +
		"	type_id," +
		"	cust_id," +
		"	export_name," +
		"	file_url," +
		"	status_id," +
		"	params," +
		"	attr_list," +
		"	delimiter," +
		"	action," +
		"	stored_proc" + 
		" FROM cexp_export_file" +
		" WHERE" +
		"	(file_id=?)";
	
	public String getRetrieveSql(){ return m_sRetrieveSql; }
	
	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_file_id);

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
		s_file_id = rs.getString(1);
		s_type_id = rs.getString(2);
		s_cust_id = rs.getString(3);
		b = rs.getBytes(4);
		s_export_name = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(5);
		s_file_url = (b == null)?null:new String(b,"UTF-8");
		s_status_id = rs.getString(6);
		b = rs.getBytes(7);
		s_params = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(8);
		s_attr_list = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(9);
		s_delimiter = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(10);
		s_action = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(11);
		s_stored_proc = (b == null)?null:new String(b,"UTF-8");
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cexp_export_save" +
		"	@file_id=?," +
		"	@type_id=?," +
		"	@cust_id=?," +
		"	@export_name=?," +
		"	@file_url=?," +
		"	@status_id=?," +
		"	@params=?," +
		"	@attr_list=?," +
		"	@delimiter=?," +
		"	@action=?," +
		"	@stored_proc=?";
	
	public String getSaveSql() { return m_sSaveSql; }

	public int saveParents(Connection conn) throws Exception
	{	
		if (s_file_id == null) return 1;
		
		if (m_ExportParams!=null)
		{
			ExportParams expParams = new ExportParams();
			expParams.s_file_id = s_file_id;
			if(expParams.retrieve(conn) > 0) expParams.delete(conn);
		}
		return 1;
	}
	
	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;
		pstmt.setString(1, s_file_id);
		pstmt.setString(2, s_type_id);
		pstmt.setString(3, s_cust_id);
		
		if(s_export_name == null) pstmt.setString(4, s_export_name);
		else pstmt.setBytes(4, s_export_name.getBytes("UTF-8"));
		
		if(s_file_url == null) pstmt.setString(5, s_file_url);
		else pstmt.setBytes(5, s_file_url.getBytes("UTF-8"));
		
		pstmt.setString(6, s_status_id);
		
		if(s_params == null) pstmt.setString(7, s_params);
		else pstmt.setBytes(7, s_params.getBytes("UTF-8"));
		
		if(s_attr_list == null) pstmt.setString(8, s_attr_list);
		else pstmt.setBytes(8, s_attr_list.getBytes("UTF-8"));
		
		if(s_delimiter == null) pstmt.setString(9, s_delimiter);
		else pstmt.setBytes(9, s_delimiter.getBytes("UTF-8"));
		
		if(s_action == null) pstmt.setString(10, s_action);
		else pstmt.setBytes(10, s_action.getBytes("UTF-8"));
		
		if(s_stored_proc == null) pstmt.setString(11, s_stored_proc);
		else pstmt.setBytes(11, s_stored_proc.getBytes("UTF-8"));

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_file_id = rs.getString(1);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}
	
	public int saveChildren(Connection conn) throws Exception
	{
		if (m_ExportParams!=null)
		{
			m_ExportParams.s_file_id = s_file_id;
			m_ExportParams.save(conn);
		}
		return 1;
	}
	
	// === DB Method delete()===
	public String m_sDeleteSql =
		" DELETE FROM cexp_export_file" +
		" WHERE" +
		"	(file_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }
	
	public int deleteChildren(Connection conn) throws Exception
	{
		if (m_ExportParams!=null)
		{ 
			m_ExportParams.s_file_id = s_file_id;
			m_ExportParams.delete(conn);
		}
		return 1;
	}
	
	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_file_id);
		return pstmt.executeUpdate();
	}
	
	//	 === XML Methods ===
	public String m_sMainElementName = "export";
	public String getMainElementName() { return m_sMainElementName; }
	
	// === To XML Methods ===	
	public void appendPropsToXml(Element e)
	{
		if( s_file_id != null ) XmlUtil.appendTextChild(e, "file_id", s_file_id);
		if( s_type_id != null ) XmlUtil.appendTextChild(e, "type_id", s_type_id);
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_export_name != null ) XmlUtil.appendCDataChild(e, "export_name", s_export_name);
		if( s_file_url != null ) XmlUtil.appendCDataChild(e, "file_url", s_file_url);
		if( s_status_id != null ) XmlUtil.appendTextChild(e, "status_id", s_status_id);
		if( s_params != null ) XmlUtil.appendCDataChild(e, "params", s_params);
		if( s_attr_list != null ) XmlUtil.appendCDataChild(e, "attr_list", s_attr_list);
		if( s_delimiter != null ) XmlUtil.appendCDataChild(e, "delimiter", s_delimiter);
		if( s_action != null ) XmlUtil.appendCDataChild(e, "action", s_action);
		if( s_stored_proc != null ) XmlUtil.appendCDataChild(e, "stored_proc", s_stored_proc);
	}
	
	public void appendChildrenToXml(Element e)
	{
		if (m_ExportParams != null) appendChild(e, m_ExportParams);
	}
		
	// === From XML Methods ===	
	public void getPropsFromXml(Element e)
	{
		s_file_id = XmlUtil.getChildTextValue(e, "file_id");
		s_type_id = XmlUtil.getChildTextValue(e, "type_id");
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_export_name = XmlUtil.getChildCDataValue(e, "export_name");
		s_file_url = XmlUtil.getChildCDataValue(e, "file_url");
		s_status_id = XmlUtil.getChildTextValue(e, "status_id");
		s_params = XmlUtil.getChildCDataValue(e, "params");
		s_attr_list = XmlUtil.getChildCDataValue(e, "attr_list");
		s_delimiter = XmlUtil.getChildCDataValue(e, "delimiter");
		s_action = XmlUtil.getChildCDataValue(e, "action");
		s_stored_proc = XmlUtil.getChildCDataValue(e, "stored_proc");
	}
	
	public void getChildrenFromXml(Element e) throws Exception
	{
		Element eExportParams = XmlUtil.getChildByName(e, "export_params");
		if(eExportParams != null) m_ExportParams = new ExportParams(eExportParams);
	}
	
	private static void getExportLocations(Export exp) throws Exception
	{
		String sExportDir = Registry.getKey("export_dir");
		if (sExportDir == null) throw new Exception("Missing export_dir in registry");
		String sExportUrl = Registry.getKey("export_url");
		if (sExportUrl == null) throw new Exception("Missing export_url in registry");

		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd_HH-mm-ss_SSS");
		String sExportName = "exp_" + exp.s_cust_id + "_" + sdf.format(new java.util.Date()) + ".txt";

		//exp.s_export_name = sExportDir + sExportName;
		exp.s_file_url = sExportUrl + sExportName;
	}
}

