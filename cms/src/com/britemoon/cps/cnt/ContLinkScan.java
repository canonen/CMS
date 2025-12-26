package com.britemoon.cps.cnt;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.cnt.*;

import java.sql.*;
import java.util.*;
import java.io.*;
import org.apache.log4j.*;

public class ContLinkScan
{
	public String s_cust_id = null;
	public String s_cont_id = null;
	public String s_load_id = null;
    public boolean b_use_anchor_name = false;
    public boolean b_use_link_renaming = false;
    public boolean b_replace_scanned_links = false;
	public boolean b_validate_content_load_images = false;
	private static Logger logger = Logger.getLogger(ContLinkScan.class.getName());
	
	public ContLinkScan (String custId, String contId, String loadId, boolean useName, boolean useAuto, boolean replaceLinks)
	{
		s_cust_id = custId;
		s_cont_id = contId;
		s_load_id = loadId;
		b_use_anchor_name = useName;
		b_use_link_renaming = useAuto;
		b_replace_scanned_links = replaceLinks;
		if (s_load_id != null) {
			b_validate_content_load_images = true;
		}
	}
	
	public boolean scanAndSave() throws Exception
	{		
		// get content parts
		Content cont = new Content();
		cont.s_cont_id = s_cont_id;
		if(cont.retrieve() < 1) {
			throw new Exception("Invalid content. Content does not exist.");	
		}
		ContBody cont_body = new ContBody(s_cont_id);
		String contName = cont.s_cont_name;
		String textPart = cont_body.s_text_part;
		String htmlPart = cont_body.s_html_part;
		if (textPart == null) textPart = "";		
		if (htmlPart == null) htmlPart = "";
		
		int linkCount = 0;
		String linkHref = "";
		String linkName = "";
		ConnectionPool cp	= null;
		Connection conn		= null;
		Connection conn2	= null;
		Statement stmt		= null;		
		Statement stmt2		= null;		
		try {
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("ContLinkScan");
			conn2 = cp.getConnection("ContLinkScan2");
			stmt = conn.createStatement();
			stmt2 = conn2.createStatement();						
											
			//Need to create a hashtable of all current links in order to prefill with names
			Hashtable hCurLinks = new Hashtable();
			String sSql =
				" SELECT href, link_name " +
				" FROM cjtk_link " +
				" WHERE cont_id = " + s_cont_id+
				" AND cust_id = " + s_cust_id;
			
			ResultSet rs = stmt.executeQuery(sSql);
			while (rs.next()) hCurLinks.put(rs.getString(1), new String (rs.getBytes(2),"UTF-8"));
			rs.close();
			
			//Need to create a hashtable of all user defined exactly matched links
			Hashtable hExactLinks = new Hashtable();
			sSql =
				" SELECT lower(link_definition), link_name " +
				"   FROM ccnt_link_renaming " +
				"  WHERE link_type_id = 1"+
				"    AND cust_id = " + s_cust_id;
			
			rs = stmt.executeQuery(sSql);
			while (rs.next()) hExactLinks.put(rs.getString(1), new String (rs.getBytes(2),"UTF-8"));
			rs.close();
			
			//Need to create a hashtable of all user defined partially matched links
			LinkedHashMap hPartialLinks = new LinkedHashMap();
			sSql =
				" SELECT lower(link_definition), link_name " +
				"   FROM ccnt_link_renaming " +
				"  WHERE link_type_id = 2"+
				"    AND cust_id = "+ s_cust_id+
				"  ORDER BY len(link_definition) DESC";
			
			rs = stmt.executeQuery(sSql);
			while (rs.next()) hPartialLinks.put(rs.getString(1), new String (rs.getBytes(2),"UTF-8"));
			rs.close();
			
			//Need to create a vector of all images loaded from content load		
			Vector vContentLoadImages = new Vector();
			if (b_validate_content_load_images) {
				String fileUrl = null;
				String fileName = null;
				String rootDir = null;
				int idx = 0;
				
				// find rootdir from text file
				sSql = "SELECT DISTINCT f.file_url"
					+ " FROM ccnt_cont_load_file f"
					+ " WHERE f.type_id = " + FileType.CONT_TEXT
					+ " AND f.load_id = "+ s_load_id;
				
				rs = stmt.executeQuery(sSql);
				if (rs.next()) {
					rootDir = rs.getString(1);
				}
				rs.close();
				idx = rootDir.lastIndexOf('/');
				if (idx > 0) {
					rootDir = rootDir.substring(0, idx+1);
				}
				else {
					rootDir = "/";
				}
				
				// get loaded images
				sSql =
					" SELECT file_url " +
					" FROM ccnt_cont_load_file " +
					" WHERE load_id = " + s_load_id+
					"   AND type_id = " + FileType.IMAGE;			
				rs = stmt.executeQuery(sSql);
				logger.info("rootDir = " + rootDir);
				while (rs.next()) {
					fileUrl = new String (rs.getBytes(1),"UTF-8");
					logger.info("found image = " + fileUrl);
					if (fileUrl.toLowerCase().startsWith(rootDir.toLowerCase())) {
						fileName = fileUrl.substring(rootDir.length());
					}
					else {
						fileName = fileUrl.substring(fileUrl.lastIndexOf("/")+1);
					}
					logger.info("add image = " + fileName);
					vContentLoadImages.add(fileName);
				}
				rs.close();
			}

			Vector vLinks;
			Vector vLinks2;
			Vector vLinks3;
			Vector vAllLinks = new Vector();
			
			vLinks = scanForHtmlAnchors(htmlPart+"\n", hCurLinks, hExactLinks, hPartialLinks, b_use_anchor_name, b_use_link_renaming, b_replace_scanned_links);
			vLinks2 = scanForTextLinks(textPart+"\n", hCurLinks, hExactLinks, hPartialLinks, b_use_link_renaming, b_replace_scanned_links);
			vLinks3 = scanForHtmlImgs(htmlPart+"\n");
			
			vLinks.addAll(vLinks2);
			vLinks.addAll(vLinks3);
			
			if (b_validate_content_load_images) {
				Vector vLeftOver = new Vector();
				String content = htmlPart.toLowerCase();
				for (int n=0; n < vContentLoadImages.size(); n++) {
					String oneImg = (String)vContentLoadImages.get(n);	
					if (content.indexOf(oneImg.toLowerCase()) < 0) {
						vLeftOver.add(oneImg);
					}				
				}
				vContentLoadImages.removeAllElements();
				vContentLoadImages.addAll(vLeftOver);				
			}
			
			// debug: see what is in the hCurLinks
			logger.info("debug: saved links");
			Enumeration eCurLinks = hCurLinks.keys();
			while (eCurLinks.hasMoreElements()) {
				String key = (String)eCurLinks.nextElement();
				logger.info(key + " => " + hCurLinks.get(key));
			}
			logger.info("end debug: saved links");
			// end debug
			
			// 
			String sInsertSql = "";
			if (vLinks.size() > 0) {
				BriteUpdate.executeUpdate("DELETE cjtk_link WHERE cont_id = " + s_cont_id);
				sInsertSql = "Exec usp_ccnt_link_insert_bytes " + s_cont_id + ",?,?," + s_cust_id;
			}

			//Go through every link found and create the html for it
			Enumeration e = vLinks.elements();
			
			String oneLink = "", linkExt = "";
			boolean notImage = true;
			
			for (int i=0;i<vLinks.size();++i) {
				oneLink = (String)e.nextElement();
				if (vAllLinks.contains(oneLink)) {
					continue;
				}
				else {
					vAllLinks.add(oneLink);
				}
				
				linkExt = oneLink.substring(oneLink.length()-4);
				notImage = (!linkExt.equalsIgnoreCase(".gif") && !linkExt.equalsIgnoreCase(".jpeg") && !linkExt.equalsIgnoreCase(".jpg"));
				

				boolean doSave = (notImage || hCurLinks.containsKey(oneLink));
				if (doSave) {
					++linkCount;				
					linkHref = oneLink;
					linkName = (hCurLinks.containsKey(oneLink)?(String)hCurLinks.get(oneLink):"Link "+linkCount);		
					PreparedStatement pstmt	= null;			
					try	{
						pstmt = conn2.prepareStatement(sInsertSql);
						pstmt.setBytes(1,linkName.getBytes("ISO-8859-1"));
						pstmt.setString(2,linkHref);
						pstmt.execute();
					}
					catch(Exception ex){ throw ex; }
					finally { if (pstmt != null) pstmt.close(); }
				}
			}
			
			//Find out which paragraphs are used in this content
			String tmpContID="",tmpContName="",tmpLogicID="",tmpLogicName="";
			String oldLogicID = "";
		
			// KO: new logic block stuff
			String sText = textPart + htmlPart;
			sText = ContUtil.replaceScrapeBlockIds(sText);
			Vector vLogicBlockIds = ContUtil.getLogicBlockIds(sText);
			String sLogicBlockId = null;
			
			// System.out.println(vLogicBlockIds);
			
			for (Enumeration eLogicBlockIds = vLogicBlockIds.elements() ; eLogicBlockIds.hasMoreElements() ;) {
				sLogicBlockId = (String) eLogicBlockIds.nextElement();
				
				// System.out.println("sLogicBlockId = " + sLogicBlockId);
				
				sSql =
					" SELECT l.cont_id, l.cont_name, cnt.cont_id, cnt.cont_name," +
					" ISNULL(pa.html_part,' '), ISNULL(pa.text_part,' ')" +
					" FROM ccnt_content l, ccnt_cont_part p2, " +
					" ccnt_content cnt, ccnt_cont_body pa " +
					" WHERE l.cont_id = " + sLogicBlockId +
					" AND l.cont_id = p2.parent_cont_id " +
					" AND cnt.cont_id = p2.child_cont_id " +
					" AND cnt.cont_id = pa.cont_id " +
					" ORDER BY p2.seq";
				
				rs = stmt.executeQuery(sSql);
				while (rs.next()) {
					tmpLogicID = rs.getString(1);
					tmpLogicName = new String(rs.getBytes(2),"UTF-8");
					tmpContID = rs.getString(3);
					tmpContName = new String(rs.getBytes(4),"UTF-8");
					htmlPart = new String(rs.getBytes(5),"UTF-8");
					textPart = new String(rs.getBytes(6),"UTF-8");
					
					if (!oldLogicID.equals(tmpLogicID)) {
						oldLogicID = tmpLogicID;
					}
					
					vLinks  = scanForHtmlAnchors(htmlPart+"\n", hCurLinks, hExactLinks, hPartialLinks, b_use_anchor_name, b_use_link_renaming, b_replace_scanned_links);				
					vLinks2 = scanForTextLinks(textPart+"\n", hCurLinks, hExactLinks, hPartialLinks, b_use_link_renaming, b_replace_scanned_links);
					vLinks3 = scanForHtmlImgs(htmlPart+"\n");
					vLinks.addAll(vLinks2);
					vLinks.addAll(vLinks3);
					
					if (b_validate_content_load_images) {
						Vector vLeftOver = new Vector();
						String content = htmlPart.toLowerCase();
						for (int n=0; n < vContentLoadImages.size(); n++) {
							String oneImg = (String)vContentLoadImages.get(n);	
							if (content.indexOf(oneImg.toLowerCase()) < 0) {
								vLeftOver.add(oneImg);
							}				
						}
						vContentLoadImages.removeAllElements();
						vContentLoadImages.addAll(vLeftOver);				
					}
					
					
					//Go through every link found and create the html for it
					
					oneLink = "";
					int nLinks = 0;
					for (int i=0;i<vLinks.size();++i) {
						oneLink = (String)vLinks.get(i);
						//See if link is already displayed, in vAllLinks
						if (vAllLinks.contains(oneLink)) {
							continue;
						}
						else {
							vAllLinks.add(oneLink);
						}
						
						linkExt = oneLink.substring(oneLink.length()-4);
						notImage = (!linkExt.equalsIgnoreCase(".gif") && !linkExt.equalsIgnoreCase(".jpeg") && !linkExt.equalsIgnoreCase(".jpg"));						
						boolean doSave = (notImage || hCurLinks.containsKey(oneLink));
						if (doSave) {
							++linkCount;
							linkHref = oneLink;
							linkName = (hCurLinks.containsKey(oneLink)?(String)hCurLinks.get(oneLink):"Link "+linkCount);
							// save to database
							PreparedStatement pstmt	= null;			
							try	{
								pstmt = conn2.prepareStatement(sInsertSql);
								pstmt.setBytes(1,linkName.getBytes("ISO-8859-1"));
								pstmt.setString(2,linkHref);
								pstmt.execute();
							}
							catch(Exception ex){ throw ex; }
							finally { if (pstmt != null) pstmt.close(); }							
						}
					}							  
				}
				rs.close();
			}
		}
		catch(Exception ex) { throw ex; }
		finally	{
			if (stmt != null) stmt.close();
			if (stmt2 != null) stmt2.close();
			if (conn != null) cp.free(conn);
			if (conn2 != null) cp.free(conn2);
		}
		return true;
	}
	
	
    // for text format
	protected Vector scanForTextLinks (String s, Hashtable hCur, Hashtable hExact, LinkedHashMap hPartial, boolean useLink, boolean replaceScannedLinks) throws Exception
	{
		Vector v = new Vector();
		Vector vImages = new Vector();

		int i,j1,j2,j3,j4,j5,j6,min=0;
		String oneLink, linkExt;
		String partS = s;
		while (true) {
			i = partS.toLowerCase().indexOf("http");
			if (i == -1) break;
			partS = partS.substring(i);
			
			//If there is less that 8 characters left quit (cant get "httpxxxx", ie "https://)
			if (partS.length() < 8) break;
			i = partS.substring(0,8).indexOf("://");
			if (i == -1) {
				//does not have "://", skip it
				partS = partS.substring(5);
				continue;
			}
			//Search for a quote, space, >, or \n to denote end of link
			//Links cannot have quote, space, >, or \n in them
			j1 = partS.indexOf("\"");
			j2 = partS.indexOf(" ");
			j3 = partS.indexOf(">");
			j4 = partS.indexOf("\n");
			j5 = partS.indexOf("'");
			j6 = partS.indexOf("<");
			if (j1 != -1 || j2 != -1 || j3 != -1 || j4 != -1 || j5 != -1 || j6 != -1)
			{
				//Want to use the min j, that is not -1
				if (j1 == -1) j1 = Integer.MAX_VALUE;
				if (j2 == -1) j2 = Integer.MAX_VALUE;
				if (j3 == -1) j3 = Integer.MAX_VALUE;
				if (j4 == -1) j4 = Integer.MAX_VALUE;
				if (j5 == -1) j5 = Integer.MAX_VALUE;
				if (j6 == -1) j6 = Integer.MAX_VALUE;
			
				//Take the min of j1,j2,j3,j4,j5
				if (j1 < j2)
					if (j1 < j3)
						if (j1 < j4) min = j1;
						else min = j4;
					else if (j3 < j4) min = j3;
					else min = j4;
				else if (j2 < j3)
					if (j2 < j4) min = j2;
					else min = j4;
				else if (j3 < j4) min = j3;
				else min = j4;

				if (j5 < min) min = j5;
				if (j6 < min) min = j6;

				oneLink = partS.substring(0,min);
				if (!oneLink.equals("http://")  && !oneLink.equals("https://"))
				{
				    oneLink = oneLink.trim();
					linkExt = oneLink.substring(oneLink.length()-4);
					if (!linkExt.equalsIgnoreCase(".gif") &&
						!linkExt.equalsIgnoreCase(".jpeg") &&
						!linkExt.equalsIgnoreCase(".jpg"))
					{
			            //System.out.println("found <"+oneLink+">");
						if (!v.contains(oneLink)) v.add(oneLink);
						if (!hCur.containsKey(oneLink) || replaceScannedLinks) {
							if (useLink) {
								String name = null;
								if (hExact.containsKey(oneLink.toLowerCase())) {
									name = (String) hExact.get(oneLink.toLowerCase());
									hCur.put(oneLink, name);
								}
								else {
									// find longest match, since we ordered the list by length, the first match is the longest
									Iterator iter = hPartial.keySet().iterator();
									while (iter.hasNext()) {
										String key = (String) iter.next();
										if (oneLink.toLowerCase().indexOf(key) != -1) {
											name = (String) hPartial.get(key);
											hCur.put(oneLink, name);
											break;
										}
									}
								}
							}
						}
					}
					else
					{
						if (!vImages.contains(oneLink)) vImages.add(oneLink);
					}
				}
			}
			else
			{
				//Could not find '"' or ' ' or '>' after http, move it ahead of http, ignorning link
				 min = 4;
			}
			partS = partS.substring(min);
		}
		v.addAll(vImages);
		return v;
	}

    // for html and aol formats link e.g. <a href="http://www.britemoon.com" name="Britemoon">
    protected Vector scanForHtmlAnchors (String s, Hashtable hCur, Hashtable hExact, LinkedHashMap hPartial,  boolean useName, boolean useLink, boolean replaceScannedLinks) throws Exception
	{
		Vector v = new Vector();

		int i,j,min=0;
		String oneLink;
		String partS = s;
		while (true) {
			i = partS.toLowerCase().indexOf("<a");
			if (i == -1) break;
			partS = partS.substring(i);
			// can't be less than 4 characters left (i.e. '<a >' is minimally expected)
			if (partS.length() < 4) break;
			j = partS.indexOf(">");
			if (j != -1) {
				min = j+1;
				oneLink = partS.substring(0,min);
				if (!oneLink.equals("<a")) {
					String href = scanForOneLink(oneLink);
					if (href != null) {
	                    href = href.trim();
			            //System.out.println("found <"+href+">");
						if (!v.contains(href)) v.add(href);
						if (!hCur.containsKey(href) || replaceScannedLinks) {
							// get link name using the following order of preferences
							// 1. use href name if found
							// 2. use exact match if found
							// 3. use longest partial match if found
							String name = null;
                            if (useName) {
                                name = scanForOneName(oneLink);
                            }
							if (name != null) {
								hCur.put(href, name);
			                    //System.out.println("replaced by name: " + href + " => " + name);
							}
							else if (useLink) {
								if (hExact.containsKey(href.toLowerCase())) {
									name = (String) hExact.get(href.toLowerCase());
									hCur.put(href, name);
			                        //System.out.println("replaced by exact: " + href + " => " + name);
								}
								else {
									// find longest match, since we ordered the list by length, the first match is the longest
									Iterator iter = hPartial.keySet().iterator();
									while (iter.hasNext()) {
										String key = (String) iter.next();
										if (href.toLowerCase().indexOf(key) != -1) {
											name = (String) hPartial.get(key);
											hCur.put(href, name);
											//System.out.println("replaced by partial: " + href + " => " + name);
											break;
										}
										else {
											//name = (String) hPartial.get(key);
											//System.out.println("NOT replaced by partial: " + href + " => (" + name + ") " + key);
										}
									}
								}
							}
						}
					}
				}
			}
			else {
				//Could not find '>' after '<a', move it ahead of '<a', ignorning anchor
				min = 2;
			}
			partS = partS.substring(min);
		}
		return v;
	}
	protected Vector scanForHtmlImgs (String s) throws Exception
	{
		Vector vImages = new Vector();

		int i,j1,j2,j3,j4,j5,j6,min=0;
		String oneLink, linkExt;
		String partS = s;
		while (true) {
			i = partS.toLowerCase().indexOf("http");
			if (i == -1) break;
			partS = partS.substring(i);
			
			//If there is less that 8 characters left quit (cant get "httpxxxx", ie "https://)
			if (partS.length() < 8) break;
			i = partS.substring(0,8).indexOf("://");
			if (i == -1) {
				//does not have "://", skip it
				partS = partS.substring(5);
				continue;
			}
			//Search for a quote, space, >, or \n to denote end of link
			//Links cannot have quote, space, >, or \n in them
			j1 = partS.indexOf("\"");
			j2 = partS.indexOf(" ");
			j3 = partS.indexOf(">");
			j4 = partS.indexOf("\n");
			j5 = partS.indexOf("'");
			j6 = partS.indexOf("<");
			if (j1 != -1 || j2 != -1 || j3 != -1 || j4 != -1 || j5 != -1 || j6 != -1)
			{
				//Want to use the min j, that is not -1
				if (j1 == -1) j1 = Integer.MAX_VALUE;
				if (j2 == -1) j2 = Integer.MAX_VALUE;
				if (j3 == -1) j3 = Integer.MAX_VALUE;
				if (j4 == -1) j4 = Integer.MAX_VALUE;
				if (j5 == -1) j5 = Integer.MAX_VALUE;
				if (j6 == -1) j6 = Integer.MAX_VALUE;
			
				//Take the min of j1,j2,j3,j4,j5
				if (j1 < j2)
					if (j1 < j3)
						if (j1 < j4) min = j1;
						else min = j4;
					else if (j3 < j4) min = j3;
					else min = j4;
				else if (j2 < j3)
					if (j2 < j4) min = j2;
					else min = j4;
				else if (j3 < j4) min = j3;
				else min = j4;

				if (j5 < min) min = j5;
				if (j6 < min) min = j6;

				oneLink = partS.substring(0,min);
				if (!oneLink.equals("http://")  && !oneLink.equals("https://"))
				{
                    oneLink = oneLink.trim();
					linkExt = oneLink.substring(oneLink.length()-4);
					if (linkExt.equalsIgnoreCase(".gif") ||
						linkExt.equalsIgnoreCase(".jpeg") ||
						linkExt.equalsIgnoreCase(".jpg"))
					{
						if (!vImages.contains(oneLink)) vImages.add(oneLink);
					}
				}
			}
			else
			{
				//Could not find '"' or ' ' or '>' after http, move it ahead of http, ignorning link
				 min = 4;
			}
			partS = partS.substring(min);
		}
		return vImages;
	}
	
    // for href link inside an anchor
	public static String scanForOneLink (String s)
	{
		int i,j1,j2,j3,j4,j5,j6,min=0;
		String oneLink, linkExt;
		String partS = s;
		while (true) {
			i = partS.toLowerCase().indexOf("http");
			if (i == -1) break;
			partS = partS.substring(i);
			
			//If there is less that 8 characters left quit (cant get "httpxxxx", ie "https://)
			if (partS.length() < 8) break;
			i = partS.substring(0,8).indexOf("://");
			if (i == -1) {
				//does not have "://", skip it
				partS = partS.substring(5);
				continue;
			} 
			//Search for a quote, space, >, or \n to denote end of link
			//Links cannot have quote, space, >, or \n in them
			j1 = partS.indexOf("\"");
			j2 = partS.indexOf(" ");
			j3 = partS.indexOf(">");
			j4 = partS.indexOf("\n");
			j5 = partS.indexOf("'");
			j6 = partS.indexOf("<");
			if (j1 != -1 || j2 != -1 || j3 != -1 || j4 != -1 || j5 != -1 || j6 != -1)
			{
				//Want to use the min j, that is not -1
				if (j1 == -1) j1 = Integer.MAX_VALUE;
				if (j2 == -1) j2 = Integer.MAX_VALUE;
				if (j3 == -1) j3 = Integer.MAX_VALUE;
				if (j4 == -1) j4 = Integer.MAX_VALUE;
				if (j5 == -1) j5 = Integer.MAX_VALUE;
				if (j6 == -1) j6 = Integer.MAX_VALUE;
			
				//Take the min of j1,j2,j3,j4,j5
				if (j1 < j2)
					if (j1 < j3)
						if (j1 < j4) min = j1;
						else min = j4;
					else if (j3 < j4) min = j3;
					else min = j4;
				else if (j2 < j3)
					if (j2 < j4) min = j2;
					else min = j4;
				else if (j3 < j4) min = j3;
				else min = j4;

				if (j5 < min) min = j5;
				if (j6 < min) min = j6;

				oneLink = partS.substring(0,min);
				if (!oneLink.equals("http://")  && !oneLink.equals("https://"))
				{
					linkExt = oneLink.substring(oneLink.length()-4);
					if (!linkExt.equalsIgnoreCase(".gif") &&
						!linkExt.equalsIgnoreCase(".jpeg") &&
						!linkExt.equalsIgnoreCase(".jpg"))
					{
						return oneLink;
					}
					else
					{
						return null;
					}
				}
			}
			else
			{
				//Could not find '"' or ' ' or '>' after http, move it ahead of http, ignorning link
				 min = 4;
			}
			partS = partS.substring(min);
		}
		return null;
	}

    // scan for name inside an anchor
	public static String scanForOneName (String s)
	{
		//System.out.println("looking for name in {" + s + "}");
		int i,j,k1,k2,k3,min=0;
		String partS = s;
		String name = null;
		
		// look for name
		i = partS.indexOf("name");
		if (i == -1) return null;
		partS = partS.substring(i+4);

		//System.out.println("looking for name in {" + partS + "}");
		
		// look for =
		j = partS.indexOf("=");
		if (j == -1) return null;
		partS = partS.substring(j+1);

		//System.out.println("looking for name in {" + partS + "}");
		
		partS = partS.trim();
		if (partS.length() <= 0) return null;
		
		//System.out.println("looking for name in {" + partS + "}");

		String q = partS.substring(0,1);
		if (q.equals("'") || q.equals("\"")) {
			//System.out.println("found starting quote");
			partS = partS.substring(1);
			// look for q
			min = partS.indexOf(q);
			if (min == -1) return null;
			//System.out.println("found ending quote");
		}
		else {
			//System.out.println("found other starting char");
			// look for " ", ">", "\n"
			k1 = partS.indexOf(" ");
			k2 = partS.indexOf(">");
			k3 = partS.indexOf("\n");
			//System.out.println("found other ending char (" + k1 + "," + k2 + "," + k3 + ")");
			if (k1 == -1 && k2 == -1 && k3 == -1) return null;
			if (k1 == -1) k1 = Integer.MAX_VALUE;
			if (k2 == -1) k2 = Integer.MAX_VALUE;
			if (k3 == -1) k3 = Integer.MAX_VALUE;
			min = k1;
			if (k2 <= k1 && k2 <= k3) min = k2;
			if (k3 <= k1 && k3 <= k2) min = k3;
		}
		name = partS.substring(0,min).trim();
		//System.out.println("found name = {" + name + "}");
		return name;
	}
}
