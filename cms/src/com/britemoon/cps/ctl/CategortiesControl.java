package com.britemoon.cps.ctl;

import java.io.StringWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;

import com.britemoon.cps.HtmlUtil;
import com.britemoon.cps.ConnectionPool;

public class CategortiesControl
{
	// commonly used categories related code
	// was taken from everywhere and put in here
	// almost without changes and improvements
	// probably will require review and recoding

	private static Logger logger = Logger.getLogger(CategortiesControl.class.getName());

	public static String toHtml(String sCustId, boolean bExecute, String sSelectedCategoryId, String sScript)
	throws Exception
	{
		StringWriter sw = new StringWriter();

		sw.write("<SELECT name=\"category_id\" size=\"1\" " + ((sScript==null)?"":sScript) + (!bExecute?" disabled":"")+">\r\n");
		sw.write("<OPTION value=\"0\">All</OPTION>\r\n");
		sw.write(toHtmlOptions(sCustId, sSelectedCategoryId));
		sw.write("</SELECT>");

		return sw.toString();
	}

	public static String toHtmlOptions(String sCustId, String sSelectedCategoryId)
	throws Exception
	{
		StringWriter sw = new StringWriter();

		ConnectionPool cp = null;
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		String sSql  =
			" SELECT category_id, category_name" +
			" FROM ccps_category" +
			" WHERE cust_id=?" +
			" ORDER BY category_name";

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("CategortiesControl.toHtml()");

			try
			{
				pstmt = conn.prepareStatement(sSql);
				pstmt.setString(1, sCustId);
				rs = pstmt.executeQuery();

				String sCategoryId = null;
				String sCategoryName = null;

				while (rs.next())
				{
					sCategoryId = rs.getString(1);
					sCategoryName = new String(rs.getBytes(2), "UTF-8");
					sw.write("<OPTION value=\"" + sCategoryId + "\"");
					if(sCategoryId.equals(sSelectedCategoryId)) sw.write(" selected");
					sw.write(">" + sCategoryName + "</OPTION>\r\n");
				}
				rs.close();
			}
			catch(Exception ex) {throw ex;}
			finally{if(pstmt != null) pstmt.close();}
		}
		catch(Exception ex) {throw ex;}
		finally{if(conn != null) cp.free(conn);}

		return sw.toString();
	}

	// === === ===

	public static String toHtmlOptions(String sCustId, int nObjectType, String sObjectId)
	throws Exception
	{
		return toHtmlOptions(sCustId, nObjectType, sObjectId, null);
	}

	public static String toHtmlOptions(String sCustId, int nObjectType, String sObjectId, String sSelectedCategoryId)
	throws Exception
	{	
		ConnectionPool cp = null;
		Connection conn = null;

		try
		{
			cp = ConnectionPool.getInstance();			
			conn = cp.getConnection("CategortiesControl.toHtmlOptions()");
			return toHtmlOptions(sCustId, nObjectType, sObjectId, sSelectedCategoryId, conn);
		}
		catch(Exception ex) { throw ex; }
		finally { if (conn != null) cp.free(conn); }
	}

	public static String toHtmlOptions(String sCustId, int nObjectType, String sObjectId, String sSelectedCategoryId, Connection conn)
	throws Exception
	{
		Statement stmt = null;
		try
		{
			stmt = conn.createStatement();
			return toHtmlOptions(sCustId, nObjectType, sObjectId, sSelectedCategoryId, stmt);
		}
		catch(SQLException ex) { throw ex; }
		finally { if(stmt != null) stmt.close(); }
	}

	public static String toHtmlOptions(String sCustId, int nObjectType, String sObjectId, String sSelectedCategoryId, Statement stmt)
	throws Exception
	{
		StringWriter sw = new StringWriter();

		String sCategoryId = null;
		String sCategoryName = null;
		String sObjId = null;
		boolean isSelected = false;

		String sSql = "";
		if (sObjectId != null) {
			sSql = "SELECT c.category_id, c.category_name, oc.object_id" +
			" FROM ccps_category c" +
			" LEFT OUTER JOIN ccps_object_category oc" + 
			" ON (c.category_id = oc.category_id" + 
			" AND c.cust_id = oc.cust_id" + 
			" AND oc.object_id =" + sObjectId + 
			" AND oc.type_id="+nObjectType+")" +
			" WHERE c.cust_id="+sCustId;
		} else {
			sSql = "SELECT c.category_id, c.category_name, [object_id] = NULL" +
			" FROM ccps_category c" +
			" WHERE c.cust_id="+sCustId;
		}

		ResultSet rs = stmt.executeQuery(sSql);

		while (rs.next())
		{
			sCategoryId = rs.getString(1);
			sCategoryName = new String(rs.getBytes(2), "UTF-8");
			sObjId = rs.getString(3);

			isSelected =
				(sObjId!=null) || ((sSelectedCategoryId!=null)&&(sSelectedCategoryId.equals(sCategoryId)));

			sw.write("<OPTION value=\""+sCategoryId+"\""+((isSelected)?" selected":"")+">");
			sw.write(HtmlUtil.escape(sCategoryName));
			sw.write("</OPTION>");
		}
		rs.close();

		return sw.toString();
	}

	// === === ===

	public static void saveCategories(String sCustId, int nObjectType, String sObjectId, HttpServletRequest request)
	throws Exception
	{
		ConnectionPool cp = null;
		Connection conn = null;

		try
		{
			cp = ConnectionPool.getInstance();			
			conn = cp.getConnection("CategoriesControl.saveCategories()");
			saveCategories(sCustId,nObjectType,sObjectId,request,conn);
		}
		catch(Exception ex) { throw ex; }
		finally { if (conn != null) cp.free(conn); }
	}

	private static void saveCategories(String sCustId, int nObjectType, String sObjectId, HttpServletRequest request, Connection conn)
	throws Exception
	{
		PreparedStatement pstmt = null;
		String sSql = null;
		try
		{
			if (sObjectId != null)
			{
				sSql =
					" DELETE FROM ccps_object_category" + 
					" WHERE cust_id=?" +
					" AND object_id=?" +
					" AND type_id=?";
				pstmt = conn.prepareStatement(sSql);
				pstmt.setString(1, sCustId);
				pstmt.setString(2, sObjectId);
				pstmt.setString(3, String.valueOf(nObjectType));
				pstmt.executeUpdate();
			}
		}
		catch(Exception ex) { throw ex; }
		finally { if(pstmt != null) pstmt.close(); }

		String[] sCategories = request.getParameterValues("categories");
		int l = ( sCategories == null )?0:sCategories.length;
		if ( l > 0)
		{
			sSql  =
				" INSERT ccps_object_category (cust_id,  object_id, type_id, category_id)" +
				" VALUES (?, ?, ?, ?)";

			for(int i=0; i<l ;i++)
			{
				try
				{
					pstmt = conn.prepareStatement(sSql);
					pstmt.setString(1, sCustId);
					pstmt.setString(2, sObjectId);
					pstmt.setString(3, String.valueOf(nObjectType));
					pstmt.setString(4, sCategories[i]);
					pstmt.executeUpdate();
				}
				catch(Exception ex) { System.out.println("Exception on insert: " + ex.getMessage()); throw ex; }
				finally { if(pstmt != null) pstmt.close(); }
			}
		}
	}

	/**
	 * 
	 * This method handles saving categories during a file upload.  Content upload uses 
	 * a MultiPartParser to handle the request object due to the upload of a file.  So the categories String array is
	 * extracted from the MultiPart request object w/in the cont_load_save.jsp and then the following public method is called.
	 * OfferProcessTask uses this method to save the categories listed in the offer xml file.
	 *
	 * @param sCustId - customer id
	 * @param nObjectType - from ObjectType class
	 * @param sObjectId - the id of the object - the categories will classify this object.
	 * @param sCategories The list of category_ids that this object will be classified under.
	 * @throws Exception
	 */
	public static void saveCategories(String sCustId, int nObjectType, String sObjectId, String[] sCategories)
	throws Exception
	{

		ConnectionPool cp = null;
		Connection conn = null;
		try
		{
			cp = ConnectionPool.getInstance();			
			conn = cp.getConnection("CategoriesControl.saveCategories(String[] sCategories)");
			saveCategories(sCustId, nObjectType, sObjectId, sCategories, conn);
		}
		catch(Exception ex) { throw ex; }
		finally { if (conn != null) cp.free(conn); }
	}

	private static void saveCategories(String sCustId, int nObjectType, String sObjectId, String[] sCategories, Connection conn)
	throws Exception
	{
		PreparedStatement pstmt = null;
		String sSql = null;
		try
		{
			if (sObjectId != null)
			{
				sSql =
					" DELETE FROM ccps_object_category" + 
					" WHERE cust_id=?" +
					" AND object_id=?" +
					" AND type_id=?";
				pstmt = conn.prepareStatement(sSql);
				pstmt.setString(1, sCustId);
				pstmt.setString(2, sObjectId);
				pstmt.setString(3, String.valueOf(nObjectType));
				pstmt.executeUpdate();
			}
		}
		catch(Exception ex) { throw ex; }
		finally { if(pstmt != null) pstmt.close(); }

		int l = ( sCategories == null )?0:sCategories.length;

		if ( l > 0)
		{
			sSql  =
				" INSERT ccps_object_category (cust_id,  object_id, type_id, category_id) " +
				" VALUES (?, ?, ?, ?)";

			for(int i=0; i<l ;i++)
			{
				try
				{
					pstmt = conn.prepareStatement(sSql);
					pstmt.setString(1, sCustId);
					pstmt.setString(2, sObjectId);
					pstmt.setString(3, String.valueOf(nObjectType));
					pstmt.setString(4, sCategories[i]);
					pstmt.executeUpdate();
				}
				catch(Exception ex) { throw ex; }
				finally { if(pstmt != null) pstmt.close(); }
			}
		}
	}


	public static String getCategoryIdByName(String sCustId, String sCategoryName) {
		String sCategoryID = null;
		if (sCategoryName == null) {
			return null;
		}
		ConnectionPool cp = null;
		Connection conn = null;
		Statement stmt = null; 
		String sSql = null;

		try
		{
			cp = ConnectionPool.getInstance();			
			conn = cp.getConnection("CategoriesControl.saveCategories(String[] sCategories)");

			stmt = conn.createStatement();

			try 
			{
				sSql = 
					" SELECT category_id " +
					" FROM ccps_category " +
					" WHERE category_name = '" + sCategoryName + "' AND cust_id = " + sCustId ;

				ResultSet rs = stmt.executeQuery(sSql);
				while (rs.next())
				{
					sCategoryID =  rs.getString(1);
				}
				rs.close();
			} catch (Exception ex) { throw ex; }
			finally { if (stmt!=null) stmt.close(); }
		}
		catch(Exception ex) { logger.error("CategoriesControl.getCategoryIdByName Exception" + ex.getMessage()); }
		finally { if (conn != null) cp.free(conn); }

		return sCategoryID;
	}



}
