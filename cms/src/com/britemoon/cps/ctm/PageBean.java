// PageBean.java
//
// This bean holds the info for a page the user is working on.
//
package com.britemoon.cps.ctm;

import com.britemoon.*;
import com.britemoon.cps.*;
import javax.servlet.http.*;
import javax.servlet.*;
import java.sql.*;
import java.io.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class PageBean implements Serializable {

	private static Logger logger = Logger.getLogger(PageBean.class.getName());
	// An double array of Strings[num_sections][] to hold the input values
	private int contentID;
	private int custID;
	private String pageName;
	private int sendType;
	private TemplateBean tbean;
	private String[][] values; // stored in ctm_page_values.i_value (image) 
	private String[][] keys; // stored in ctm_page_values.n_value (int)

	// Constructor
	public PageBean(int custID, TemplateBean tb) {

		//Set TemplateBean
		this.tbean = tb;

		//Initialize the values array
		values = new String[tbean.getNumSections()][];
		keys = new String[tbean.getNumSections()][];
		for (int x=0;x<tbean.getNumSections();++x) {
			values[x] = new String[tbean.getNumOrders(x)];
			keys[x] = new String[tbean.getNumOrders(x)];
		}

		pageName = "";
		contentID = 0;
		sendType = -1;
		this.custID = custID;
	}

	public int getContentID () {
		return contentID;
	}

	public int getCustID () {
		return custID;
	}

	public String getPageName () {
		return pageName;
	}

	public int getSendType () {
		return sendType;
	}

	public void setPageNameAndType (String pageName, int sendType) {
		this.pageName = pageName;
		this.sendType = sendType;
	}

	public void setPageName (String pageName) {
		this.pageName = pageName;
	}

	//Returns the tbean object
	public TemplateBean getTemplateBean () {
		return tbean;
	}

	// Returns an array of values for section s
	public String[] getSectionValues (int s) {
		return values[s];
	}
	
	// Returns an array of keys for section s
	public String[] getSectionkeys (int s) {
		return keys[s];
	}

	// Grabs values[s][o]
	public String getOneValue (int s, int o) {
		// Need to repace " with &quot;
		return values[s][o];
	}
	
	// Grabs keys[s][o]
	public String getOneValue2 (int s, int o) {
		// Need to repace " with &quot;
		return keys[s][o];
	}

	// Sets the contentID
	public void setContentID (int contentID) {
		this.contentID = contentID;
	}

	// Sets a section
	public void setSectionValues (int s, String[] vals) {
		//Array copy
		for (int x=0;x<tbean.getNumOrders(s);++x) {
			values[s][x] = vals[x];
		}
	}
	
	// Sets a section 
	public void setSectionKeys (int s, String[] vals) {
		//Array copy
		for (int x=0;x<tbean.getNumOrders(s);++x) {
			keys[s][x] = vals[x];
		}
	}

	// Sets values[s][o]
	public void setOneValue (int s, int o, String val) {
		//Set the values
		values[s][o] = val;
	}
	
	// Sets values[s][o]
	public void setOneKey (int s, int o, String val) {
		//Set the keys
		keys[s][o] = val;
	}

	//Spits out the template form by parsing the previewType template:
	//filling in the inputs with values if they exist and placing
	//edit buttons in each section if editOn = true.
	public String createTemplateForm (String previewType, String editSectionName, String imageBase, boolean editOn) {
		String template = tbean.getTemplate(previewType);
		StringBuffer s = new StringBuffer(template);

		boolean isHtml = true;
		if (!previewType.equals("html")) isHtml = false;

		String bminput, bmsection, bmedit;
		String replacement;
		String inputType;
		String linkName, link, color, dName, dValue;
		int i, j, index, colorIndex, dValueIndex;

		//<bminput#:#><bmtype>text</bmtype><bmlabel>ssdf</bmlabel>
		//<bmdefault>sddsf</bmdefault></bminput#:#>
		//Replace with values if they exist else use the default value
		for (int x=0;x<tbean.getNumSections();++x) {

			if (isHtml) {
				//Remove <bmsection#>Section Label</bmsection#>
				bmsection = "bmsection"+(x+1)+">";
				i = template.indexOf("<"+bmsection);
				j = template.indexOf("</"+bmsection,i);
				s = s.replace(i,j+bmsection.length()+2, "");
				template = s.toString();

				//Insert the edit links
				bmedit = "bmedit"+(x+1)+">";
				i = template.indexOf("<"+bmedit);
				j = template.indexOf("</"+bmedit,i);

				if (editOn) {
					replacement = "<a target=_parent href=\""+editSectionName+"?section="+x+"\">"+template.substring(i+bmedit.length()+1,j)+"</a>\n";
				}
				else {
					replacement = "";
				}
				s = s.replace(i,j+bmedit.length()+2, replacement);
				template = s.toString();
			}

			for (int y=0;y<tbean.getNumOrders(x);++y) {
				//Find "<bminputx:y>" and "</bminputx:y>"
				bminput = "bminput"+(x+1)+":"+(y+1)+">";
				i = template.indexOf("<"+bminput);
				j = template.indexOf("</"+bminput,i);

				//If input doesn't exist skip it - could happen in txt files
				//Should never happen in html
				if (i == -1 || j == -1) {
					if (isHtml) {
						return "<h2>Bad Template File</h2>";
					}
					else {
						continue;
					}
				}

				//Figure out what should go into the page
				replacement = values[x][y];
				if (replacement == null) {
					replacement = tbean.getDefaultValue(x,y);
				}
				
				//link and images need to be in a and img tags, respectively
				inputType = tbean.getInputType(x,y);
				if (inputType.equalsIgnoreCase("link")) {
					//link val format: 'name http://sdf.sdf.sdf/sdf #XXXXXX'
					//Find last http://
					index = replacement.toLowerCase().lastIndexOf("http");
					if (index != -1) {
						if (index != 0)     // just in case the link has no name
							linkName = replacement.substring(0,index-1);
						else
							linkName = "Link";
						colorIndex = replacement.lastIndexOf(" #");
						if (colorIndex == -1) {
							link = replacement.substring(index);
							color = "";
						}
						else {
							link = replacement.substring(index,colorIndex);
							color = " style=\"color:"+replacement.substring(colorIndex+1)+"\"";
						}
						if (previewType.equals("txt")) {
							replacement = link;
						}
						else {
							replacement = "<a"+color+" target=_blank href=\""+link+"\">"+linkName+"</a>";
						}
					}
					else if (replacement.length() != 0) {
						replacement = "("+replacement+")";
					}
				}
				else if (inputType.equalsIgnoreCase("image") && replacement.length() != 0) {
					replacement = replacement.trim();
					if (replacement.toLowerCase().indexOf("http://") != -1) {
						replacement = "<img border=0 src=\""+replacement+"\" alt=\""+replacement+"\">";
					}
					else if (replacement.length() > 0){
						replacement = "<img border=0 src=\""+imageBase+custID+"/"+contentID+"/"+replacement+"\" alt=\""+replacement+"\">";
					}
				}
				else if (inputType.equalsIgnoreCase("imagelib") && replacement.length() != 0) {
					replacement = replacement.trim();
					if (replacement.toLowerCase().indexOf("http://") != -1) {
						replacement = "<img border=0 src=\""+replacement+"\" alt=\""+replacement+"\">";
					}
					else if (replacement.length() > 0) {
						replacement = "<img border=0 src=\""+imageBase+custID+"/"+contentID+"/"+replacement+"\" alt=\""+replacement+"\">";
					}
				}
				else if (inputType.equalsIgnoreCase("imageall") && replacement.length() != 0) {
					replacement = replacement.trim();
					if (replacement.toLowerCase().indexOf("http://") != -1) {
						replacement = "<img border=0 src=\""+replacement+"\" alt=\""+replacement+"\">";
					}
					else if (replacement.length() > 0) {
						replacement = "<img border=0 src=\""+imageBase+custID+"/"+contentID+"/"+replacement+"\" alt=\""+replacement+"\">";
					}
				}
				else if (inputType.equalsIgnoreCase("pers") && replacement.length() != 0) {
					//Grab the default value after the ';'
					dValueIndex = replacement.indexOf(";");
					if (dValueIndex == -1) {
						//no value set to "" - This should never happen
						replacement = "";
					}
					else {
						dValue = replacement.substring(dValueIndex+1);
						if (dValue.equals("NULL")) {
							replacement = "";
						}
						else {
							replacement = "!*"+replacement.substring(0,dValueIndex)+";"+dValue+"*!";
						}
					}
				}
				else if (inputType.equalsIgnoreCase("subs") && replacement.length() != 0) {
					//Grab the default value after the ';'
					dValueIndex = replacement.indexOf(";");
					if (dValueIndex == -1) {
						//no value set to "" - This should never happen
						replacement = "";
					}
					else {
						dName = replacement.substring(0,dValueIndex);
						dValue = replacement.substring(dValueIndex+1);
						String sAttrValue = null;
						// get content field values 
						ConnectionPool connPool = null;
						Connection conn = null;
						Statement stmt = null;
						try {
							connPool = ConnectionPool.getInstance();
							conn = connPool.getConnection("PageBean.createTemplateForm()");
							stmt = conn.createStatement();
							String sql = null;
							sql =
								"SELECT v.attr_value " + 
								"  FROM ccps_cont_attr_value v WITH(NOLOCK)," +
								"       ccps_cont_attr a WITH(NOLOCK) " +
								" WHERE v.cust_id = " + custID +
								"   AND v.attr_id = a.attr_id" +
								"   AND UPPER(a.attr_name) = '" + dName.toUpperCase() + "'";
							ResultSet rs = stmt.executeQuery(sql);
							if (rs.next()) {
								sAttrValue = rs.getString(1);
							}
							rs.close();
						}
						catch (Exception e) {
							return "database error";
						}
						finally {
							try { if (stmt != null) stmt.close(); }	catch (Exception ex) {};
							if (conn != null) connPool.free(conn);
						}

						if (sAttrValue == null || sAttrValue.equals("NULL")) {
							replacement = dValue;
						}
						else {
							replacement = sAttrValue;
						}
					}
				}

				//Allow for multiple inputs of the same section:order
				while (i != -1 && j != -1) {

					//Replace the string and then change the template string to reflect the change
					if (replacement == null) {
						replacement = "";
					}
					s = s.replace(i,j+bminput.length()+2, replacement);
					template = s.toString();

					//See if there is another one of the same inputs
					i = template.indexOf("<"+bminput,i);
					j = template.indexOf("</"+bminput,i);
				}
			}
		}

		return s.toString();
	}

	//Create misc html editor hooks outside of the section form
	public String createSectionFormHtmlEditorHooks(int section) {
		String result = "";
		String inputType, val;

		//Go through each input for the section and create the html editor hooks
		for (int x=0;x<tbean.getNumOrders(section);++x) {
			val = values[section][x];
			if (val == null) val = tbean.getDefaultValue(section,x);
			inputType = tbean.getInputType(section,x);
			if (inputType.equalsIgnoreCase("richtext")) {
				val = WebUtils.convertToByteSymbolSequence(val);
				result += "editor_generate('input"+x+"');\n";
			}
			else if (inputType.equalsIgnoreCase("richtextsimple")) {
				val = WebUtils.convertToByteSymbolSequence(val);
				result += "editor_generate('input"+x+"', 'simple');\n";
			}
			else if (inputType.equalsIgnoreCase("richtexthyatt")) {
				val = WebUtils.convertToByteSymbolSequence(val);
				result += "editor_generate('input"+x+"', 'hyatt');\n";
			}
		}

		return result;
	}

	//Create the forms for editing the values of one section.
	public String createSectionForm(int section, String imageBase) {
		String result = "";
		String inputType, val, linkName, link, color, persType, persChecked = "", subsType;
		int index, colorIndex, dValueIndex;

		//Go through each input for the section and create the
		//appropriate input field
		for (int x=0;x<tbean.getNumOrders(section);++x) {
			//Get value that should go in the input field
			val = values[section][x];
			if (val == null) val = tbean.getDefaultValue(section,x);
			//Create input elements
			result += "<tr>\n";
			result += "<th>" + tbean.getLabel(section,x) + ":</th>\n";
			result += "<td>";
			inputType = tbean.getInputType(section,x);
			if (inputType.equalsIgnoreCase("shorttext")) {
				val = WebUtils.convertToByteSymbolSequence(val);
				result += "<input type=text name=input"+x+" value=\""+val+"\" size=60>\n";
			}
			else if (inputType.equalsIgnoreCase("text")) {
				val = WebUtils.convertToByteSymbolSequence(val);
				result += "<textarea rows=10 cols=65 name=input"+x+">"+val+"</textarea>\n";
			}
			else if (inputType.equalsIgnoreCase("richtext")) {
				val = WebUtils.convertToByteSymbolSequence(val);
				result += "<textarea rows=10 cols=65 name=input"+x+">"+val+"</textarea>\n";
			}
			else if (inputType.equalsIgnoreCase("richtextsimple")) {
				val = WebUtils.convertToByteSymbolSequence(val);
				result += "<textarea rows=10 cols=65 name=input"+x+">"+val+"</textarea>\n";
			}
			else if (inputType.equalsIgnoreCase("richtexthyatt")) {
				val = WebUtils.convertToByteSymbolSequence(val);
				result += "<textarea rows=10 cols=65 name=input"+x+">"+val+"</textarea>\n";
			}
			else if (inputType.equalsIgnoreCase("pers")) {
				// Grab the default value after the ';'
				dValueIndex = val.indexOf(";");
				if (dValueIndex == -1) {
					//no value set to "" - This should never happen
					val = "";
					persType = "";
				}
				else {
					persType = val.substring(0,dValueIndex);
					val = val.substring(dValueIndex+1);
					if (val.equals("NULL")) {
						persChecked = "checked";
						val = "";
					}
					else {
						persChecked = "";
					}
				}

				result += "<input type=hidden name=input"+x+" value=\""+persType+"\">\n"+
					"<input type=text name=input"+x+" value=\""+WebUtils.convertToByteSymbolSequence(val)+"\" size=40>\n"+
					"<br><input type=checkbox name=input"+x+" value=\"remove\" "+persChecked+">Don't Use This Personalization\n";

			}
			else if (inputType.equalsIgnoreCase("subs")) {
				// May not be necessary
				//Grab the default value after the ';'
				dValueIndex = val.indexOf(";");
				if (dValueIndex == -1) {
					//no value set to "" - This should never happen
					val = "";
					subsType = "";
				}
				else {
					subsType = val.substring(0,dValueIndex);
					val = val.substring(dValueIndex+1);
				}

				result += "<input type=hidden name=input"+x+" value=\""+subsType+"\">\n"+
					      "<input type=text   name=input"+x+" value=\""+WebUtils.convertToByteSymbolSequence(val)+"\" size=40 disabled>\n";

			}
			else if (inputType.equalsIgnoreCase("colorpicker")) {
				//Gives them a javascript colorpicker
				result += "<SCRIPT LANGUAGE=\"JavaScript\">\n" +
						  "var cp"+x+" = new ColorPicker('window');\n" +
						  "function pick"+x+"(anchorname) {\n" +
						  "  field = document.forms[0].input"+x+";\n" +
						  "  cp"+x+".show(anchorname);\n" +
						  "}\n" +
						  "</SCRIPT>\n";

				result += "<INPUT TYPE=\"text\" NAME=\"input"+x+"\" SIZE=\"10\" VALUE=\""+val+"\"> <A HREF=\"#\" onClick=\"pick"+x+"('pick"+x+"');return false;\" NAME=\"pick"+x+"\" ID=\"pick"+x+"\">Pick</A>";

			}
			else if (inputType.equalsIgnoreCase("image")) {
				//if there is a value it will be the image's file name
				//Should show the current image
				result += "<input type=file name=input"+x+"><br>\n";
				val = val.trim();
				if (val.length() != 0) {
					if (val.toLowerCase().indexOf("http://") != -1) {
						result += "Current Image:<br><img src=\""+val+"\" alt=\""+val+"\"><br>\n";
					}
					else {
						result += "Current Image:<br><img src=\""+imageBase+custID+"/"+contentID+"/"+val+"\" alt=\""+val+"\"><br>\n";
					}
					result += "<input type=checkbox name=input"+x+">Do not use an image<br>\n";
				}
			}
			else if (inputType.equalsIgnoreCase("imagelib")) {
				//Gives them a javascript url generator
				result +=
					"<SCRIPT LANGUAGE=\"JavaScript\">\n" +
					"function PreviewURL(ix)\n" +
					"{\n" +
					"    var freshurl = '/ccps/ui/jsp/image/folder_details_url.jsp?input_name='+ ix;\n" +
					"    var window_features = 'scrollbars=yes,resizable=yes,toolbar=no,width=650,height=500';\n" +
					"    SmallWin = window.open(freshurl,'ImageLibrary',window_features);\n" +
					"}\n" +
					"</SCRIPT>\n";
				//if there is a value it will be the image's file name
				//Should show the current image
				result +=
					"<input type=text name=input" + x + " size=80 value=\"" + val + "\" readonly>&nbsp;" +
					"<a class=\"resourcebutton\" href=\"javascript:PreviewURL('input"+x+"')\">Select from Image Library</a><br>";
				val = val.trim();
				if (val.length() != 0) {
					if (val.toLowerCase().indexOf("http://") != -1) {
						result += "Current Image:<br><img id=imageinput" + x+" src=\""+val+"\" alt=\""+val+"\"><br>\n";
					}
					else {
						result += "Current Image:<br><img id=imageinput" + x+" src=\""+imageBase+custID+"/"+contentID+"/"+val+"\" alt=\""+val+"\"><br>\n";
					}
				}
			}
			else if (inputType.equalsIgnoreCase("imageall")) {
				//if there is a value it will be the image's file name
				//Should show the current image
				result += "<input type=file name=input"+x+"><br>\n";
				val = val.trim();
				if (val.length() != 0) {
					if (val.toLowerCase().indexOf("http://") != -1) {
						result += "Current Image:<br><img src=\""+val+"\" alt=\""+val+"\"><br>\n";
					}
					else {
						result += "Current Image:<br><img src=\""+imageBase+custID+"/"+contentID+"/"+val+"\" alt=\""+val+"\"><br>\n";
					}
					result += "<input type=checkbox name=input"+x+">Do not use an image<br>\n";
				}
			}
			else if (inputType.equalsIgnoreCase("link")) {
				//link val format: 'name http://sdf.sdf.sdf/sdf'
				//Find last http://
				index = val.toLowerCase().lastIndexOf("http");

				if (index != -1) {
					linkName = val.substring(0,index-1);
					colorIndex = val.lastIndexOf(" #");
					if (colorIndex == -1) {
						link = val.substring(index);
						color = "";
					}
					else {
						link = val.substring(index,colorIndex);
						color = val.substring(colorIndex+1);
					}
				}
				else {
					linkName = val;
					link = "http://";
					color = "";
				}
				//Gives them a javascript colorpicker
				result += "<SCRIPT LANGUAGE=\"JavaScript\">\n" +
						  "var cp"+x+" = new ColorPicker('window');\n" +
						  "function pick"+x+"(anchorname) {\n" +
						  "  field = document.forms[0].input"+x+";\n" +
						  "  cp"+x+".show(anchorname);\n" +
						  "}\n" +
						  "</SCRIPT>\n";

				result += "<table celpadding=0 cellspacing=0 border=0>\n" +
				          "<tr><td>Name:</td><td><input type=text name=input"+x+"a value=\""+WebUtils.convertToByteSymbolSequence(linkName)+"\" size=50></td></tr>\n" +
				          "<tr><td>URL:</td><td><input type=text name=input"+x+"a value=\""+link+"\" size=50></td></tr>\n" +
						  "<tr><td>Link Color:</td><td><INPUT TYPE=\"text\" NAME=\"input"+x+"\" SIZE=\"10\" VALUE=\""+color+"\"> <A class=\"resourcebutton\" HREF=\"#\" onClick=\"pick"+x+"('pick"+x+"');return false;\" NAME=\"pick"+x+"\" ID=\"pick"+x+"\">Pick</A></td></tr>" +
				          "</table>";
			}
			else if (inputType.equalsIgnoreCase("bigoffer") || inputType.equalsIgnoreCase("smalloffer")) {
				int size = 1;
				if (inputType.equalsIgnoreCase("bigoffer")) {
					size = 2;
				}
				String inputName = "input" + x;
				String hidden_val = WebUtils.convertToByteSymbolSequence(val);
				//Gives them a javascript offer chooser
				result +=
					"<SCRIPT LANGUAGE=\"JavaScript\">\n" +
					"function OfferPreviewURL(ix)\n" +
					"{\n" +
					"    var freshurl = '/ccps/ui/jsp/ctm/offer_chooser.jsp?offer_size=" + size + "&input_name='+ ix;\n" +
					"    var window_features = 'scrollbars=yes,resizable=yes,toolbar=no,width=600,height=650';\n" +
					"    SmallWin = window.open(freshurl,'OfferChooser',window_features);\n" +
					"}\n" +
					"</SCRIPT>\n";
				result +=
					"<br>&nbsp;<a class=\"resourcebutton\" href=\"javascript:OfferPreviewURL('"+inputName+"')\">Select from Offer Library</a><br><br>" +
					"<input type=hidden name=" + inputName + " id=" + inputName + " value=\"" + hidden_val + "\">" +
					"<input type=hidden name=" + inputName + " id=" + inputName + "key value=\"\">" +
					"<table cellpadding=0 cellspacing=0 border=1><tr><td><div id=offer" + inputName + ">" + val + "</div></td></tr></table>";
			}

			result += "</td>\n";
			result += "</tr>\n";
		}

		return result;
	}

	// Loads the bean from the db corresponding to it's contentID
	public void load (int contentID) throws Exception {
		ConnectionPool connPool = null;
		Connection conn         = null;
		Statement stmt          = null;
		ResultSet rs            = null;
		String sql              = null;

		connPool = ConnectionPool.getInstance();
		conn = connPool.getConnection("PageBean.load()");
		stmt = conn.createStatement();

		this.contentID = contentID;
		//System.out.println("loading a bean for content ID:" + contentID);

		rs = stmt.executeQuery("select name, customer_id, send_type_id from ctm_pages WITH(NOLOCK) where content_id = "+contentID);
		rs.next();
		pageName = rs.getString("name");
		custID = rs.getInt("customer_id");
		sendType = rs.getInt("send_type_id");
		rs.close();

		sql = "select s.sort_order as section, i.sort_order as iorder, i_value, n_value " +
			  "from ctm_page_values v WITH(NOLOCK), ctm_inputs i WITH(NOLOCK), ctm_sections s WITH(NOLOCK)" +
			  "where content_id = "+contentID+" " +
			  "and i.input_id = v.input_id " +
			  "and s.section_id = i.section_id " +
			  "order by s.sort_order, i.sort_order";

		rs = stmt.executeQuery(sql);
		try {
			while (rs.next()) {
				int iSection = rs.getInt("section")-1;       //subtract 1 for array index
				int iIorder = rs.getInt("iorder")-1;       //subtract 1 for array index
				byte[] b = null;
				b = rs.getBytes("i_value");
				try
				{
					values[iSection][iIorder]= ((b == null)? null : new String(b,"UTF-8"));
				}
				catch (Exception ex) {}
				keys[iSection][iIorder] = rs.getString("n_value");
			}
		}
		catch (Exception e) {
			throw e;
		}
		finally {
			rs.close();
			if (conn != null) connPool.free(conn);
		}
	}


	// Save the values to the db - if section == -1, save all sections
	public void save (int userID, String userName, int section) throws SQLException {
		ConnectionPool connPool = null;
		Connection conn         = null;
		Statement stmt          = null;
		PreparedStatement pstmt = null;
		ResultSet rs            = null;
		
		connPool = ConnectionPool.getInstance();
		conn = connPool.getConnection("PageBean.save()");
                conn.setAutoCommit(false);

		String sql = "";
		int rc;
		if (contentID != 0) {
			//Update the page
 			try {
//				stmt = conn.createStatement();
//				stmt.execute("BEGIN TRANSACTION");
//				stmt.close();

				stmt = conn.createStatement();
				sql = "update ctm_pages set " +
					  "name = '"+WebUtils.dbEncode(pageName)+"', " +
					  "send_type_id = "+sendType+", " +
					  "user_id = "+userID+", " +
					  "mod_by = '"+userName+"', " +
					  "mod_date = CURRENT_TIMESTAMP " +
					  "where content_id = "+contentID;
				int returncode = stmt.executeUpdate(sql);
				stmt.close();
				
				int valueID, startVal = 0, endVal = tbean.getNumSections();
				if (section > -1 && section < endVal) {
					startVal = section;
					endVal = section+1;
				}
				for (int x=startVal;x<endVal;++x) {
					for (int y=0;y<tbean.getNumOrders(x);++y) {
						//Is this input already in the db or is it a new input?
						stmt = conn.createStatement();
						rs = stmt.executeQuery("" +
							"select value_id " +
							"from ctm_page_values WITH(NOLOCK) " +
							"where content_id = "+contentID+" " +
							"and input_id = "+tbean.getInputID(x,y));
						if (rs.next()) {
							//There is a value for this input - update row
							valueID = rs.getInt(1);
							rs.close();
							stmt.close();
							if (values[x][y] == null) {
								//The value has been removed by user - delete the row
								sql = "delete ctm_page_values where value_id = "+valueID;
								stmt = conn.createStatement();
								returncode = stmt.executeUpdate(sql);
								stmt.close();
							}
							else {
								sql = "UPDATE ctm_page_values SET i_value = ?, n_value = ? WHERE value_id = ?";
								pstmt = conn.prepareStatement(sql);
								if(values[x][y] == null) pstmt.setString(1, values[x][y]);
								else pstmt.setBytes(1, values[x][y].getBytes("UTF-8"));
								pstmt.setString(2, keys[x][y]);
								pstmt.setInt(3,  valueID);
								rc = pstmt.executeUpdate();
								pstmt.close();
							}
						}
						else {
							rs.close();
							stmt.close();
							//No current value for this input - insert new row
							stmt = conn.createStatement();
							rs = stmt.executeQuery("select isnull(max(value_id), 0) + 1 from ctm_page_values WITH(NOLOCK)");
							rs.next();
							valueID = rs.getInt(1);
							rs.close();
							stmt.close();
							//Only put it in db if there is a value - save time/space
							if (values[x][y] != null) {
								sql = "INSERT INTO ctm_page_values (value_id, content_id, input_id, i_value, n_value) VALUES (?, ?, ?, ?, ?)";
								pstmt = conn.prepareStatement(sql);
								pstmt.setInt(1, valueID);
								pstmt.setInt(2, contentID);
								pstmt.setInt(3, tbean.getInputID(x,y));
								pstmt.setBytes(4, values[x][y].getBytes("UTF-8"));
								pstmt.setString(5, keys[x][y]);
								rc = pstmt.executeUpdate();
								pstmt.close();
							}
						}
					}
				}

				conn.commit();

			}
			catch (SQLException e) {
				conn.rollback();
				throw new SQLException(e.getMessage()+"\n"+sql);
			}
			catch (Exception e) {
				conn.rollback();
				throw new SQLException(e.getMessage()+"\nError in converting to byte sequence.");
			}
			finally {
				if (conn != null) {
                                    conn.setAutoCommit(true);
                                    connPool.free(conn);
                                }
			}

		}
		else {
			//New Page - insert into db
			try {
				
				conn.setAutoCommit(false);
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select isnull(max(content_id), 22000000) + 1 from ctm_pages WITH(NOLOCK)");
				rs.next();
				contentID = rs.getInt(1);
				rs.close();
				stmt.close();
				
				stmt = conn.createStatement();
				sql = "insert into ctm_pages " +
					"(content_id, template_id, name, send_type_id, customer_id, user_id," +
					" user_name, mod_by, status, creation_date, mod_date) " +
					"values " +
					"("+contentID+", "+tbean.getTemplateID()+", '"+WebUtils.dbEncode(pageName) +
					"', "+sendType+", "+custID+", "+userID+", '"+userName+"', '"+userName+"', " +
					"'draft', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";

				int returncode = stmt.executeUpdate(sql);
				stmt.close();
				
				int valueID;
				for (int x=0;x<tbean.getNumSections();++x) {
					for (int y=0;y<tbean.getNumOrders(x);++y) {
						stmt = conn.createStatement();
						rs = stmt.executeQuery("select isnull(max(value_id), 0) + 1 from ctm_page_values WITH(NOLOCK)");
						rs.next();
						valueID = rs.getInt(1);
						rs.close();
						stmt.close();
						
						//Only put it in db if there is a value - save time/space
						if (values[x][y] != null) {
							sql = "INSERT INTO ctm_page_values (value_id, content_id, input_id, i_value, n_value) VALUES (?, ?, ?, ?, ?)";
							pstmt = conn.prepareStatement(sql);
							pstmt.setInt(1, valueID);
							pstmt.setInt(2, contentID);
							pstmt.setInt(3, tbean.getInputID(x,y));
							pstmt.setBytes(4, values[x][y].getBytes("UTF-8"));
							pstmt.setString(5, keys[x][y]);
							rc = pstmt.executeUpdate();
							pstmt.close();
						}
					}
				}
				conn.commit();

			}
			catch (SQLException e) {
				conn.rollback();
				throw new SQLException(e.getMessage()+"\n"+sql);
			}
			catch (Exception e) {
				conn.rollback();
				throw new SQLException(e.getMessage()+"\nError in converting to byte sequence in new page.");
			}
			finally {
				if (conn != null) {
                                    conn.setAutoCommit(true);
                                    connPool.free(conn);
                                }
			}
		}
	}

	//Deletes the page with contentID from the db
	//CHANGED 10/22/2001: Changed delete function to only change status to 'deleted'
	static public void delete (int custID, int contentID, String imageURL, String userName) throws SQLException {
		ConnectionPool connPool = null;
		Connection conn         = null;
		Statement stmt          = null;
		ResultSet rs            = null;

		connPool = ConnectionPool.getInstance();
		conn = connPool.getConnection("PageBean.delete()");
		stmt = conn.createStatement();
		rs = stmt.executeQuery("select customer_id from ctm_pages WITH(NOLOCK) where content_id = "+contentID);
		if (!rs.next()) return;
		if (custID != rs.getInt(1)) return;
		rs.close();

		try {

			stmt.executeUpdate("" +
				"update ctm_pages " +
				"set status = 'deleted', " +
				"mod_by = '"+userName+"', " +
				"mod_date = getdate() " +
				"where content_id = "+contentID);

		}
		catch (SQLException e) {
			throw e;
		}
		finally {
			if (stmt != null) stmt.close();
			if (conn != null) connPool.free(conn);
		}
	}

//Completely removes the page with contentID from the db
//ADDED 10/22/2001: Use this to obliterate a page
//	static public void delete (int custID, int contentID, String imageURL, String userName) throws SQLException {
//		ConnectionPool connPool = null;
//		Connection conn         = null;
//		Statement stmt          = null;
//		ResultSet rs            = null;
//
//		connPool = new ConnectionPool();
//		conn = connPool.getConnection("PageBean.delete()");
//		stmt = conn.createStatement();
//		rs = stmt.executeQuery("select customer_id from ctm_pages where content_id = "+contentID);
//		if (!rs.next()) return;
//		if (custID != rs.getInt(1)) return;
//		rs.close();
//
//		try {
//			stmt.execute("BEGIN TRANSACTION");
//
//			stmt.executeUpdate("delete ctm_page_values where content_id = "+contentID);
//			stmt.executeUpdate("delete ctm_pages where content_id = "+contentID);
//
//			stmt.execute("COMMIT TRANSACTION");
//		} catch (SQLException e) {
//			stmt.execute("ROLLBACK TRANSACTION");
//			throw e;
//		} finally {
//			if (stmt != null) stmt.close();
//			if (conn != null) connPool.free(conn);
//		}
//
//		//Need to delete images associated with this page
//		File i;
//		File f = new File(imageURL+custID+"\\"+contentID);
//		String[] imageFiles = f.list();
//		if (imageFiles != null) {
//			for (int x=0;x<imageFiles.length;++x) {
//				i = new File(imageURL+custID+"\\"+contentID+"\\"+imageFiles[x]);
//				i.delete();
//			}
//		}
//		f.delete();
//		f = f.getParentFile();
//		f.delete();
//	}

	// For hidden sections, fill values with the default values
	public void setHiddenValues () {
		for (int x=0;x<tbean.getNumSections();++x) {
			if (tbean.getSectionLabel(x).length() == 0) {
				for (int y=0;y<tbean.getNumOrders(x);++y) {
					values[x][y] = tbean.getDefaultValue(x,y);
				}
			}
		}
	}

	//Prints out the current values in a pretty format
	public String prettyOutput () {
		String result = "<pre>\n";
		for (int x=0;x<tbean.getNumSections();++x) {
			result += x + " ";
			for (int y=0;y<tbean.getNumOrders(x);++y) {
				result += values[x][y] + " ";
			}
			result += "<br>\n";
		}
		return result+"</pre>\n";
	}

	//Changes the status to commited and saves it in the db
	public void setStatus (String status) throws SQLException {
		ConnectionPool connPool = null;
		Connection conn         = null;
		Statement stmt          = null;

		connPool = ConnectionPool.getInstance();
		conn = connPool.getConnection("PageBean.commit()");
		stmt = conn.createStatement();

		if (status.equals("committed") || status.equals("draft") || status.equals("ready")) {
			int errorcode = stmt.executeUpdate("update ctm_pages set status = '"+status+"' where content_id = "+contentID);
		}

		stmt.close();
		if (conn != null) connPool.free(conn);
	}

	//Generates the xml for the page corresponding to contentID
	public String generateXML (String imageURL) throws Exception {

		String xml = "";
		xml += "<ContentDef>\n" +
			   "<ContentID>"+contentID+"</ContentID>\n" +
			   "<ContentName><![CDATA["+pageName+"]]></ContentName>\n" +
			   "<ContentSendTypeID>"+sendType+"</ContentSendTypeID>\n" +
			   "<Status>Ready</Status>\n";
		String html = "", text = "";
		try {
			html = createTemplateForm("html", "", imageURL, false);
			text = WebUtils.removeHTMLtags2(createTemplateForm("txt", "", imageURL, false));

		}
		catch (Exception e) {
			//System.out.println("Couldn't convert unicode for XML transfer");
			throw e;
		}

		byte[] bVal = null;
		bVal = text.getBytes("UTF-8");
		xml += "<ContentText><![CDATA[\n"+(bVal!=null?new String(bVal,"UTF-8"):"")+"\n]]></ContentText>\n";
		bVal = html.getBytes("UTF-8");
		xml += "<ContentHTML><![CDATA[\n"+(bVal!=null?new String(bVal,"UTF-8"):"")+"\n]]></ContentHTML>\n";


		int index, colorIndex, trackCount=1;
		String link, linkName, countString, tempValue="";
		for (int x=0;x<tbean.getNumSections();++x) {
			for (int y=0;y<tbean.getNumOrders(x);++y) {
				if (tbean.getInputType(x,y).equalsIgnoreCase("link")) {
					//Tracking Links
					//<TrackURLx></TrackURLx>
					//<TrackNamex></TrackNamex>
					if (values[x][y] == null) {
						tempValue = tbean.getDefaultValue(x,y);
					}
					else {
						tempValue = values[x][y];
					}

					if (tempValue == null || tempValue.length() == 0) continue;

					index = tempValue.toLowerCase().lastIndexOf("http");

					if (index != -1) {
						linkName = tempValue.substring(0,index-1);
						colorIndex = tempValue.lastIndexOf(" #");
						if (colorIndex == -1) {
							link = tempValue.substring(index);
						}
						else {
							link = tempValue.substring(index,colorIndex);
						}
					}
					else {
						linkName = tempValue;
						link = "";
					}

					if (trackCount < 10) countString = "00";
					else if (trackCount < 100) countString = "0";
					else countString = "";
					try {
						xml += "<TrackURL"+countString+trackCount+"><![CDATA["+link+"]]></TrackURL"+countString+trackCount+">\n" +
							   "<TrackName"+countString+trackCount+"><![CDATA["+linkName+"]]></TrackName"+countString+trackCount+">\n";
						++trackCount;
					}
					catch (Exception e) {
						logger.info("Error in converting link name to byte code sequence for xml transfer");
					}
				}
			}
		}

		//Blank fields
		xml += "<UnsubContentText></UnsubContentText>\n" +
			   "<UnsubContentHTML></UnsubContentHTML>\n" +
			   "<S2FContentText></S2FContentText>\n" +
			   "<S2FContentHTML></S2FContentHTML>\n" +
			   "<UnsubMailToURL></UnsubMailToURL>\n" +
			   "<SubscribeURL></SubscribeURL>\n" +
			   "<S2FMode></S2FMode>\n" +
			   "<S2FMode></S2FMode>\n" +
			   "<S2FColor></S2FColor>\n" +
			   "<S2FBGColor></S2FBGColor>\n";

		xml += "</ContentDef>";
		return xml;
	}
	
	static public String generateOfferHtml(String headlineHtml, String detailHtml, String imageUrl) 
	{

		String html = 	
			"<table cellpadding=0 cellspacing=0 border=0>" +
			"<tr><td><div>" + headlineHtml + "</div></td></tr>" +
			"<tr><td><img src=\"" + imageUrl + "\"></td></tr>" +
			"<tr><td><div>" + detailHtml + "</div></td></tr>" +
			"</table>";
		
		return html;
	}
}


