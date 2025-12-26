//
// Zac Warren - Britemoon Inc.
// 6/22/2001
// TemplateBean.java
//
// This bean holds the info for a template.  It also contains static
// function for loading templates and returning templates.

package com.britemoon.cps.ctm;

import com.britemoon.cps.*;
import javax.servlet.http.*;
import javax.servlet.*;
import java.sql.*;
import java.io.*;
import java.util.*;
import org.apache.log4j.*;

public class TemplateBean implements Serializable, Runnable
{
	private static Logger logger = Logger.getLogger(TemplateBean.class.getName());

	private int templateID;
	private String templateName;
	private String category;
	private String imageURL[];
	private int custID;
	private String childCustList;

	private int numSections;
	private int global_flag = 0;
	private int active = 1;
	private int approval_flag = 0;
	private String[] sectionLabels;
	private int[] numOrders;

	private int[][] inputIDs;
	private String[][] inputTypes;
	private String[][] labels;
	private String[][] defaultValues;

	private String htmlTemplate;
	private String txtTemplate;

	// Empty Constructor
	public TemplateBean() {
		templateID = 0;
	}

	// Param Constructor
	public TemplateBean(int templateID, int custID, String templateName, String category,
	                    String[] imageURL, String[] templates) {

		this.templateID = templateID;
		this.custID = custID;
		this.templateName = new String(templateName);
		this.category = new String(category);
		this.childCustList = null;
		this.global_flag = 0;
		this.approval_flag = 0;

		this.imageURL = new String[2];
		this.imageURL[0] = imageURL[0];
		this.imageURL[1] = imageURL[1];

		//Make sure any of the img tags don't refer to src="" - index.jsp page
		//Just remove the src="" if they exist
		int iStart;
		for (int x=0;x<2;++x) {
			iStart = templates[x].toLowerCase().indexOf("src=\"\"");
			while (iStart != -1) {
				templates[x] = templates[x].substring(0,iStart)+templates[x].substring(iStart+6);
				iStart = templates[x].toLowerCase().indexOf("src=\"\"",iStart);
			}
			iStart = templates[x].toLowerCase().indexOf("src=\"index.jsp\"");
			while (iStart != -1) {
				templates[x] = templates[x].substring(0,iStart)+templates[x].substring(iStart+6);
				iStart = templates[x].toLowerCase().indexOf("src=\"index.jsp\"",iStart);
			}
		}
		htmlTemplate = new String(templates[0]);
		txtTemplate = new String(templates[1]);

	}

	public void addChildCustList (String val) {
		if (val != null && val.length() > 0) {
			this.childCustList = val;
		}
	}

	public void setGlobal (boolean val) {
		if (val) {
			this.global_flag = 1;
		}
		else {
			this.global_flag = 0;
		}
	}

	public void setApproval (boolean val) {
		if (val) {
			this.approval_flag = 1;
		}
		else {
			this.approval_flag = 0;
		}
	}

	//Will parse the htmlTemplate to fill in the templates properties
	//Returns a descriptive error message or "ok" if no errors
	public String parseTemplate () {
		String errmsg = "";

		Vector vSectionLabels = new Vector();
		Vector vNumOrders = new Vector();

		//A Vector of String[3] -  1: type  2: label  3: default
		Vector vInputProperties = new Vector();
		String[] oneInput;
		String[] paramNames = {"type","label","default"};
		String validInputTypes = "text richtext richtextsimple richtexthyatt shorttext colorpicker image imagelib imageall link pers subs smalloffer bigoffer";

		String bmsection,bminput,bmparam,inputString;
		int iStart,iEnd;
		int section=1,order=1;
		boolean done = false;
		boolean moreInputs;
		while (!done) {
			//Grab section label
			bmsection = "bmsection"+section+">";
			iStart = htmlTemplate.indexOf("<"+bmsection);
			if (iStart != -1) {
				iEnd = htmlTemplate.indexOf("</"+bmsection,iStart);
				if (iEnd == -1) {
					//No matching end tag
					errmsg += "*** Missing end tag for &lt;bmsection"+section+"&gt; ***\n";
					break;
				}
				//Add the section label to the vector
				vSectionLabels.add(htmlTemplate.substring(iStart+bmsection.length()+1,iEnd));

				//Make sure there are <bmedit#></bmedit#> tags
				iStart = htmlTemplate.indexOf("<bmedit"+section+">");
				iEnd = htmlTemplate.indexOf("</bmedit"+section+">",iStart);
				if (iStart == -1 || iEnd == -1) {
					//No matching end tag
					errmsg += "*** Missing edit tags (&lt;bmedit"+section+"&gt;) for section"+section+" ***\n";
					break;
				}

				//Loop through the inputs for this section
				moreInputs = true;
				while (moreInputs) {
					//Find "<bminput#section#:#order#>" and "</bminput#section#:#order#>"
					bminput = "bminput"+section+":"+order+">";
					iStart = htmlTemplate.indexOf("<"+bminput);
					if (iStart != -1) {
						iEnd = htmlTemplate.indexOf("</"+bminput,iStart);
						if (iEnd == -1) {
							errmsg += "*** Missing end tag for &lt;bminput"+section+":"+order+"&gt; ***\n";
							done = true;
							break;
						}

						inputString = htmlTemplate.substring(iStart+bminput.length()+1,iEnd);
						//get type, label, and default then add it to vInputProperties vector
						oneInput = new String[3];
						//type
						for (int x=0;x<3;x++) {
							bmparam = "bm"+paramNames[x]+">";
							iStart = inputString.indexOf("<"+bmparam);
							iEnd = inputString.indexOf("</"+bmparam,iStart);
							if (iStart == -1 || iEnd == -1) {
								//missing type
								errmsg += "*** Missing "+paramNames[x]+" tag for input"+section+":"+order+" ***\n";
								done = true;
								break;
							}
							oneInput[x] = inputString.substring(iStart+bmparam.length()+1,iEnd);
							//Check to make sure inputType is a valid type
							if ((x == 0) && (validInputTypes.indexOf(oneInput[x]) == -1)) {
								//Invalid type
								errmsg += "*** Invalid type: "+oneInput[x]+" in &lt;bminput"+section+":"+order+"&gt; ***\n";
								done = true;
								break;
							}
						}
						//Put oneInput into the input vector
						vInputProperties.add(oneInput);
						++order;

					} else {
						moreInputs = false;

						//Make sure there was at least one input
						if (order == 1 && errmsg.length() == 0) {
							errmsg += "*** No inputs for section "+section+" ***\n";
							done = true;
							break;
						}
						//only add it if there was actually an input
						if (order != 1) vNumOrders.add(new Integer(order-1));
						order = 1;
					}

				}
				++section;
			} else {
				done = true;
				//Make sure there was at least one section - section should be at least 2
				if (section == 1 && errmsg.length() == 0) {
					errmsg += "*** No section labels - please add &lt;bmsection#&gt;&lt;/bmsection#&gt; tags ***\n";
				}
			}
		}

		//If there is an error message return without saving any values
		if (errmsg.length() != 0) return errmsg;

		numSections = vSectionLabels.size();
		sectionLabels = (String[])vSectionLabels.toArray(new String[numSections]);
		Integer[] numOrdersInt = (Integer[])vNumOrders.toArray(new Integer[numSections]);

		//Allocate 1st dimension space from numSections
		numOrders = new int[numSections];
		inputTypes = new String[numSections][];
		labels = new String[numSections][];
		defaultValues = new String[numSections][];

		String[][] inputProp = (String[][])vInputProperties.toArray(new String[numSections][]);

		//Go through the Vector and fill in:
		//inputTypes[][], labels[][], defaultValues[][]
		//Converting from inputProp[absolute input #][paramtype] to paramtype[section#][input#]
		int z=0;
		for (int x=0;x<numSections;++x) {
			numOrders[x] = numOrdersInt[x].intValue();
			//Allocate space for arrays
			inputTypes[x] = new String[numOrders[x]];
			labels[x] = new String[numOrders[x]];
			defaultValues[x] = new String[numOrders[x]];

			for (int y=0;y<numOrders[x];++y) {
				inputTypes[x][y] = inputProp[z][0];
				labels[x][y] = inputProp[z][1];
				defaultValues[x][y] = inputProp[z][2];
				z++;
			}
		}

		return "ok";
	}

	public int getTemplateID () {
		return templateID;
	}

	public int getCustID () {
		return custID;
	}

	public String getChildCustList () {
		return childCustList;
	}

	public boolean inChildCustList(String childID) {
		String tmp = new String("," + childCustList + ",");
		if (tmp.indexOf(","+childID+",") >= 0) {
			return true;
		}
		return false;
	}

	public String getTemplateName () {
		return templateName;
	}

	public String getCategory () {
		return category;
	}

	public String getImageURL (int x) {
		return imageURL[x];
	}

	public int getNumSections () {
		return numSections;
	}

	public boolean isGlobal() {
		if (global_flag == 0) {
			return false;
		}
		return true;
	}
	
	public boolean isApproval() {
		if (approval_flag == 0) {
			return false;
		}
		return true;
	}

	public boolean isActive() {
		if (active == 0) {
			return false;
		}
		return true;
	}

	public int getNumOrders ( int x ) {
		return numOrders[x];
	}

	public String getSectionLabel ( int x ) {
		return sectionLabels[x];
	}

	public int getInputID ( int x, int y ) {
		return inputIDs[x][y];
	}

	public String getLabel ( int x, int y ) {
		return labels[x][y];
	}

	public String getInputType ( int x, int y ) {
		return inputTypes[x][y];
	}

	public String getDefaultValue ( int x, int y ) {
		return defaultValues[x][y];
	}

	public String getTemplate ( String type ) {
		if (type.equals("html")) return htmlTemplate;
		else if (type.equals("txt")) return txtTemplate;
		else return "Error: Bad Type";
	}

	public boolean isOneInputImage( int section ) {
		for (int x=0;x<numOrders[section];++x) {
			if (inputTypes[section][x].equals("colorpicker")) return true;
		}
		return false;
	}

	public void loadOneTemplate (int templateID) throws SQLException
	{
		ConnectionPool connPool = null;
		Connection conn         = null;
		Connection conn2        = null;
		Statement stmt          = null;
		Statement stmt2         = null;

		try
		{
			connPool = ConnectionPool.getInstance();
			conn = connPool.getConnection("TemplateBean.loadOneTemplate() 1");
			conn2 = connPool.getConnection("TemplateBean.loadOneTemplate() 2");
			stmt = conn.createStatement();
			stmt2 = conn2.createStatement();

//System.out.println("Loading template #" + templateID + " started");
			loadOneTemplate (stmt, stmt2, templateID);
//System.out.println("Loading template #" + templateID + " finished");
		}
		catch(SQLException ex)	{ throw ex; }
		finally
		{
			if (stmt != null) stmt.close();
			if (stmt2 != null) stmt2.close();
			if (conn != null) connPool.free(conn);
			if (conn2 != null) connPool.free(conn2);
		}
	}

	public void loadOneTemplate (Statement stmt, Statement stmt2, int templateID) throws SQLException
	{
		this.templateID = templateID;

		String sSql =
		     "select customer_id, name, category, small_image, large_image, " +
			 "template_html, template_txt, sections_n, ISNULL(global_flag, 0), ISNULL(active, 1), ISNULL(approval_flag, 0) " +
			 "from ctm_templates WITH(NOLOCK)" +
			 "where template_id = " + templateID;

		ResultSet rs = stmt.executeQuery(sSql);
		if (!rs.next())
		{
			rs.close();
			return;
		}

		custID = rs.getInt(1);
		templateName = rs.getString(2);
		category = rs.getString(3);

		imageURL = new String[2];
		imageURL[0] = rs.getString(4);
		imageURL[1] = rs.getString(5);

		// === === ===
		
		byte[] b = null;
		
		b = rs.getBytes(6);
		try
		{
			htmlTemplate = ((b == null)? null : new String(b,"UTF-8"));
		}
		catch (Exception ex) {}
		
		b = rs.getBytes(7);
		try
		{
			txtTemplate = (b == null)? null: new String(b,"UTF-8");
		}
		catch (Exception ex) {}
		
		// === === ===

		numSections = rs.getInt(8);
		global_flag = rs.getInt(9);
		active = rs.getInt(10);
		approval_flag = rs.getInt(11);
		rs.close();


		// load child cust
		sSql = "select cust_id from ctm_inherited_templates WITH(NOLOCK) where template_id = " + templateID;

		rs = stmt.executeQuery(sSql);
		String childList = "";
		while (rs.next()) {
			childList += "," + rs.getString(1);
		}
		rs.close();
		if (childList != null && childList.length() > 0) {
			this.childCustList = childList.substring(1);
		}

		// === === ===

		sectionLabels = new String[numSections];
		numOrders = new int[numSections];
		inputIDs = new int[numSections][];
		inputTypes = new String[numSections][];
		labels = new String[numSections][];
		defaultValues = new String[numSections][];

		//Get Section info
		rs = stmt.executeQuery("" +
			"select inputs_n, label, section_id " +
			"from ctm_sections WITH(NOLOCK)" +
			"where template_id = " + templateID + " " +
			"order by sort_order");
		int x = 0;
		while (rs.next())
		{
			numOrders[x] = rs.getInt("inputs_n");
			sectionLabels[x] = rs.getString("label");

			inputIDs[x] = new int[numOrders[x]];
			inputTypes[x] = new String[numOrders[x]];
			labels[x] = new String[numOrders[x]];
			defaultValues[x] = new String[numOrders[x]];

			ResultSet rs2 = stmt2.executeQuery("" +
				"select input_id, type, label, default_value " +
				"from ctm_inputs WITH(NOLOCK)" +
				"where section_id = " + rs.getString("section_id") + " " +
				"order by sort_order");
			int y = 0;

		    while (rs2.next())
			{
				//Get the input properties
				inputIDs[x][y] = rs2.getInt("input_id");
				inputTypes[x][y] = rs2.getString("type");
				labels[x][y] = rs2.getString("label");
				defaultValues[x][y] = rs2.getString("default_value");
				++y;
			}
			rs2.close();
			++x;
		}
		rs.close();
	}

	//Should be called on Server startup only once.
	//Initializes all of the templates currently in the db.
	public static Hashtable loadAllTemplates() throws SQLException
	{
		ConnectionPool connPool = null;
		Connection conn         = null;
		Statement stmt          = null;

		Hashtable tbeans = new Hashtable();
		try
		{
			connPool = ConnectionPool.getInstance();
			conn = connPool.getConnection("TemplateBean.loadAllTemplates()");
			stmt = conn.createStatement();

			Integer templateID;

			ResultSet rs = stmt.executeQuery("select template_id from ctm_templates WITH(NOLOCK) order by category, name");
			while (rs.next())
			{
				templateID = new Integer(rs.getInt(1));

				//Hash the templateID and the TemplateBean
				TemplateBean tbean = new TemplateBean();
				tbean.loadOneTemplate(templateID.intValue());
				tbeans.put(templateID, tbean);
			}
		}
		catch (SQLException e) {throw e; }
		finally
		{
			if (stmt != null) stmt.close();
			if (conn != null) connPool.free(conn);
		}

		return tbeans;
	}

	public String prettyOutput()
	{
		String result = "<table width=100%>\n";
		for (int x=0;x<numSections;++x) {
			result += "<tr><td class=ctmheadtd colspan=4>"+(x+1)+". "+sectionLabels[x]+"</td></tr>\n";
			for (int y=0;y<numOrders[x];++y) {
				result += "<tr><td nowrap>&nbsp;&nbsp;"+(x+1)+":"+(y+1)+" "+labels[x][y]+"</td>\n";
				result += "<td>"+inputTypes[x][y]+"</td><td>"+defaultValues[x][y]+"</td></tr>\n";
			}
			result += "\n";
		}
		return result+"</table>";
	}

	//Saves the bean to the db
	public void save () throws SQLException
	{
		ConnectionPool connPool = null;
		Connection conn         = null;
		Connection conn2        = null;
		Connection conn3        = null;
		Statement stmt          = null;
		PreparedStatement pstmt = null;
		Statement stmt2         = null;
		Statement stmt3         = null;
		ResultSet rs            = null;
		ResultSet rs2           = null;

		connPool = ConnectionPool.getInstance();
		conn = connPool.getConnection("TemplateBean.save() 1");
                conn.setAutoCommit(false);
		stmt = conn.createStatement();

		if (templateID != 0) {
			conn2 = connPool.getConnection("TemplateBean.save() 2");
                        conn2.setAutoCommit(false);
			conn3 = connPool.getConnection("TemplateBean.save() 3");
                        conn3.setAutoCommit(false);
			stmt2 = conn2.createStatement();
			stmt3 = conn3.createStatement();

			//Update the template
			String sql = "";
			int x,y, rc;
			try
			{
	
				// update template
				sql = 
					"UPDATE ctm_templates" +
					"   SET name = ?, customer_id = ?, category = ?, template_html = ?, template_txt = ?," +
					"       small_image = ?, large_image = ?, global_flag = ?, approval_flag = ?" +
					" WHERE template_id = ?";
				pstmt = conn.prepareStatement(sql);
				pstmt.setString(1,  templateName);
				pstmt.setInt(2,  custID);
				pstmt.setString(3,  category);
				if(htmlTemplate == null) pstmt.setString(4, htmlTemplate);
				else pstmt.setBytes(4, htmlTemplate.getBytes("UTF-8"));
				if(htmlTemplate == null) pstmt.setString(5, txtTemplate);
				else pstmt.setBytes(5, txtTemplate.getBytes("UTF-8"));
				pstmt.setString(6,  imageURL[0]);
				pstmt.setString(7,  imageURL[1]);
				pstmt.setInt(8,  global_flag);
				pstmt.setInt(9, approval_flag);
				pstmt.setInt(10,  templateID);

				rc = pstmt.executeUpdate();
						
				// inherit template to children
				sql = "DELETE FROM ctm_inherited_templates WHERE template_id = " + templateID;
				rc = stmt.executeUpdate(sql);

				if (this.childCustList != null) {
					StringTokenizer childList = new StringTokenizer(this.childCustList, ",");
					String childCustID;
					while (childList.hasMoreTokens()) {
						childCustID = childList.nextToken();
						sql = "INSERT INTO ctm_inherited_templates " +
							"(cust_id, template_id) " +
							"VALUES " +
							"("+childCustID+","+templateID+")";
						rc = stmt.executeUpdate(sql);
					}
				}

				inputIDs = new int[numSections][];
				int sectionID, inputID;
				rs = stmt.executeQuery("select section_id, sort_order from ctm_sections WITH(NOLOCK) where template_id = "+templateID);
				while (rs.next()) {
					sectionID = rs.getInt(1);
					x = rs.getInt(2) - 1;
					sql = "update ctm_sections set " +
					      "label = '"+WebUtils.dbEncode(sectionLabels[x])+"' " +
						  "where section_id = "+sectionID;

					rc = stmt3.executeUpdate(sql);

					inputIDs[x] = new int[numOrders[x]];
					//Get inputID and put it in inputIDs[x][y]
					rs2 = stmt2.executeQuery("select input_id, sort_order from ctm_inputs WITH(NOLOCK) where section_id = "+sectionID);
					while (rs2.next()) {
						inputID = rs2.getInt(1);
						y = rs2.getInt(2) - 1;
						inputIDs[x][y] = inputID;
						sql = "update ctm_inputs set " +
							  "type = '"+WebUtils.dbEncode(inputTypes[x][y])+"', " +
							  "label = '"+WebUtils.dbEncode(labels[x][y])+"', " +
							  "default_value = '"+WebUtils.dbEncode(defaultValues[x][y])+"' " +
							  "where input_id = "+inputID;

						rc = stmt3.executeUpdate(sql);
					}
				}

				conn.commit();
				conn2.commit();
				conn3.commit();

			} catch (Exception e) {
				conn.rollback();
				throw new SQLException(e.getMessage()+"\n"+sql);
			} finally {
				stmt.close();
				stmt2.close();
				stmt3.close();
				if (conn != null) { conn.setAutoCommit(true); connPool.free(conn); }
				if (conn2 != null) { conn2.setAutoCommit(true); connPool.free(conn2); }
				if (conn3 != null) { conn3.setAutoCommit(true); connPool.free(conn3); }
			}

		} else {
			//New Template - insert into db
			String sql = "";
			int rc;
			try {

				//get the templateID
				rs = stmt.executeQuery("select isnull(max(template_id), 0) + 1 from ctm_templates WITH(NOLOCK)");
				rs.next();
				templateID = rs.getInt(1);
				rs.close();

				// update template
				sql = 
					"INSERT INTO ctm_templates (template_id, name, customer_id, category, sections_n," +
					"                           template_html, template_txt, small_image, large_image, global_flag, active, approval_flag)" +
					"     VALUES (?,?,?,?,?,?,?,?,?,?,?,?)";
				pstmt = conn.prepareStatement(sql);
				pstmt.setInt(1,  templateID);
				pstmt.setString(2,  templateName);
				pstmt.setInt(3,  custID);
				pstmt.setString(4,  category);
				pstmt.setInt(5,  numSections);
				if(htmlTemplate == null) pstmt.setString(6, htmlTemplate);
				else pstmt.setBytes(6, htmlTemplate.getBytes("UTF-8"));
				if(htmlTemplate == null) pstmt.setString(7, txtTemplate);
				else pstmt.setBytes(7, txtTemplate.getBytes("UTF-8"));
				pstmt.setString(8,  imageURL[0]);
				pstmt.setString(9,  imageURL[1]);
				pstmt.setInt(10,  global_flag);
				pstmt.setInt(11,  1);
				pstmt.setInt(12, approval_flag);
				rc = pstmt.executeUpdate();
				
				// update sections
				inputIDs = new int[numSections][];
				int sectionID, inputID;
				for (int x=0;x<numSections;++x) {
					rs = stmt.executeQuery("select isnull(max(section_id), 0) + 1 from ctm_sections WITH(NOLOCK)");
					rs.next();
					sectionID = rs.getInt(1);
					rs.close();

					sql = "insert into ctm_sections " +
					      "(section_id, template_id, inputs_n, label, sort_order) " +
						  "values " +
						  "("+sectionID+", "+templateID+", "+numOrders[x]+", '"+WebUtils.dbEncode(sectionLabels[x])+"', "+(x+1)+")";

					rc = stmt.executeUpdate(sql);

					inputIDs[x] = new int[numOrders[x]];
					for (int y=0;y<numOrders[x];++y) {
						//Get inputID and put it in inputIDs[x][y]
						rs = stmt.executeQuery("select isnull(max(input_id), 0) + 1 from ctm_inputs WITH(NOLOCK)");
						rs.next();
						inputID = rs.getInt(1);
						rs.close();

						inputIDs[x][y] = inputID;
						sql = "insert into ctm_inputs " +
							  "(input_id, section_id, sort_order, type, label, default_value) " +
							  "values " +
							  "("+inputID+", "+sectionID+", "+(y+1)+", '" +
							  WebUtils.dbEncode(inputTypes[x][y])+"', '"+WebUtils.dbEncode(labels[x][y]) +
							  "', '"+WebUtils.dbEncode(defaultValues[x][y])+"')";

						rc = stmt.executeUpdate(sql);

					}
				}

				// inherit templates to children
				if (this.childCustList != null) {
					StringTokenizer childList = new StringTokenizer(this.childCustList, ",");
					String childCustID;
					while (childList.hasMoreTokens()) {
						childCustID = childList.nextToken();
						sql = "insert into ctm_inherited_templates " +
							"(cust_id, template_id) " +
							"values " +
							"("+childCustID+","+templateID+")";
						rc = stmt.executeUpdate(sql);
					}
				}

				conn.commit();

			}
			catch (Exception e)
			{
				conn.rollback();
				throw new SQLException(e.getMessage()+"\n"+sql);
			}
			finally
			{
				if (conn != null) connPool.free(conn);
			}
		}
	}

	//Removes the template from the db
	public boolean delete () throws SQLException
	{
		boolean bResult = false;

		ConnectionPool connPool = null;
		Connection conn         = null;
		Statement stmt          = null;

		try
		{
			connPool = ConnectionPool.getInstance();
			conn = connPool.getConnection("TemplateBean.delete()");
                        conn.setAutoCommit(false);
			stmt = conn.createStatement();

			ResultSet rs = stmt.executeQuery("select template_id from ctm_pages WITH(NOLOCK) where template_id = "+templateID);
			bResult = rs.next();
			rs.close();

			if (!bResult)
			{
				try
				{

					//Delete ctm_inputs
					stmt.executeUpdate("delete ctm_inputs where section_id in " +
						"(select section_id from ctm_sections WITH(NOLOCK) where template_id = "+templateID+")");

					//Delete ctm_sections
					stmt.executeUpdate("delete ctm_sections where template_id = "+templateID);

					//Delete ctm_inherited_templates
					stmt.executeUpdate("delete ctm_inherited_templates where template_id = "+templateID);

					//Delete ctm_templates
					stmt.executeUpdate("delete ctm_templates where template_id = "+templateID);

					conn.commit();
				}
				catch (SQLException e)
				{
					conn.rollback();
					throw e;
				}
			}
			else {
				// we will hide it when it is already used in some content templates
				stmt.executeUpdate("update ctm_templates set active = 0 where template_id = "+templateID);
                                conn.commit();
				bResult = false;
			}
		}
		catch (SQLException e) {throw e; }
		finally
		{
			if (stmt != null) stmt.close();
			if (conn != null) { 
                            conn.setAutoCommit(true); 
                            connPool.free(conn); 
                        }
		}

		return (!bResult);
	}

	// === === ===

	private ServletContext context = null;

	public void loadAllTemplatesInSeperateThread(ServletContext sc)
	{
		context = sc;
		Thread t = new Thread(this);
		t.start();
	}

	public void run()
	{
		Hashtable tbeans = null;
		try
		{
		    logger.info("Loading Template Beans using separate thread ...");
		    tbeans = TemplateBean.loadAllTemplates();
		}
		catch (Exception e)
		{
		    logger.error("ERROR LOADING BEANS! :", e);
		}
		finally
		{
		    context.setAttribute("tbeans", tbeans);
		    logger.info("Total of " + tbeans.size()+ " Template Beans loaded into memory.");
		}
	}
}


