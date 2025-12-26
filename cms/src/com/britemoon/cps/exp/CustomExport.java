package com.britemoon.cps.exp;

import java.sql.*;
import java.util.*;

import com.britemoon.cps.ExportType;
import com.britemoon.cps.XmlUtil;
import org.w3c.dom.*;

import com.britemoon.*;
import org.apache.log4j.*;

public class CustomExport 
{
	private static Logger logger = Logger.getLogger(CustomExport.class.getName());
	public String s_cust_id = null;
	public String s_delimiter = null;
	public String s_stored_proc = null;
	public String s_fixed_width_flag = null;
	
	// Added for custom_save
	public String s_export_name = null;
	public String s_params = null;
	public String s_file_url = null;
	public String s_file_id = null;
		
	public ExportParams eParams = null;
	public String sQuery = null;
	public int numRecips = 0;
	private Vector vAttrIDs = null;

	public CustomExport () {}

	public CustomExport (Export exp) throws Exception 
	{
		s_cust_id = exp.s_cust_id;
		s_delimiter = exp.s_delimiter;
		s_stored_proc = exp.s_stored_proc;
		s_fixed_width_flag = (String.valueOf(ExportType.CUSTOM_FIXED_WIDTH).equals(exp.s_type_id))?"1":null;
		s_export_name = exp.s_export_name;
		s_params = exp.s_params;
		s_file_url = exp.s_file_url;
		s_file_id = exp.s_file_id;
	
		eParams = new ExportParams();
		eParams.s_file_id = exp.s_file_id;
		eParams.s_cust_id = exp.s_cust_id;
		eParams.retrieve();
	}

	public CustomExport (Element e) throws Exception
	{
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_delimiter = XmlUtil.getChildTextValue(e, "delimiter");
		s_stored_proc = XmlUtil.getChildTextValue(e, "stored_proc");
		s_fixed_width_flag = XmlUtil.getChildTextValue(e, "fixed_width_flag");
		s_export_name = XmlUtil.getChildTextValue(e, "export_name");
		s_params = XmlUtil.getChildTextValue(e, "params");
		s_file_url = XmlUtil.getChildTextValue(e, "file_url");
		s_file_id  = XmlUtil.getChildTextValue(e, "file_id");
		
		NodeList nl = XmlUtil.getChildrenByName(e, "parameter");
		if (nl.getLength() > 0) 
		{
			eParams = new ExportParams();
			Element el = null;
			for (int i = 0; i < nl.getLength(); i++) 
			{
				el = (Element)nl.item(i);
				ExportParam ep = new ExportParam();
				ep.s_param_id = String.valueOf(i+1);
				ep.s_param_name = XmlUtil.getChildTextValue(el, "param_name");
				ep.s_param_value = XmlUtil.getChildCDataValue(el, "param_value");
				eParams.add(ep);
			}
		}
	}

	public ResultSet getRS (Connection conn, Statement stmt) throws Exception 
	{
		ResultSet rs = null;
		PreparedStatement pstmt = null;
	
		if ((s_cust_id == null) || (s_cust_id.trim().equals("")))
			throw new Exception ("No CustomExport Customer specified.");
	
		String sSQL = "";
		String sParamSQL = "";
	
		try 
		{
			stmt.executeUpdate("CREATE TABLE #tmp_attr_map (n int identity, attr_id int)");
	
			// Create and fill temp table to store all recip attributes
			sSQL = "CREATE TABLE #tmp_attr (row_id int, recip_id int, attr_id int, attr_value varchar(8000))";
			stmt.executeUpdate(sSQL);
	
			// Some stuff happens
			if (eParams != null) 
			{
				ExportParam ep = null;
				for (Enumeration e = eParams.elements(); e.hasMoreElements() ;) 
				{
					ep = (ExportParam)e.nextElement();
					sParamSQL += ((sParamSQL.length()>0)?",":"") + " @" + ep.s_param_name.trim() + "=?";
				}
			}
			sSQL = "EXEC "+s_stored_proc + sParamSQL;
			sQuery = "EXEC "+s_stored_proc + sParamSQL;
	
			pstmt = conn.prepareStatement(sSQL);
	
			if (eParams != null) 
			{
				ExportParam ep = null;
				int i = 1;
				for (Enumeration e = eParams.elements(); e.hasMoreElements();) 
				{
					ep = (ExportParam)e.nextElement();
					pstmt.setString(i++,ep.s_param_value);
				}
			}
			pstmt.executeUpdate();
	
			vAttrIDs = new Vector();
			sSQL = "SELECT attr_id FROM #tmp_attr_map ORDER BY n";
			rs = stmt.executeQuery(sSQL);
			while (rs.next()) 
			{
				vAttrIDs.add(rs.getString(1));
			}
	
			// Return ResultSet of all recips
	
			sSQL = "SELECT a.row_id, a.recip_id, a.attr_id, a.attr_value"
				+ " FROM #tmp_attr a, #tmp_attr_map m"
				+ " WHERE a.attr_id = m.attr_id"
				+ " ORDER BY a.row_id, a.recip_id, m.n";
	
			rs = stmt.executeQuery(sSQL);
		} 
		catch (Exception e) 
		{
			logger.error("Exception : ", e);
			throw new Exception (e.getMessage());
		}
		return rs;
	}

	public void close (Statement stmt) 
	{
		String sSQL = null;
		try 
		{
			sSQL = "DROP TABLE  #tmp_attr_map";
			stmt.executeUpdate(sSQL);
		} 
		catch (SQLException se) { }
	 	try 
		{
			sSQL = "DROP TABLE #tmp_attr";
			stmt.executeUpdate(sSQL);
		} catch (SQLException se) { }
	}
	
} //End