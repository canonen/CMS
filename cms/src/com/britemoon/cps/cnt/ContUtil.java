package com.britemoon.cps.cnt;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.jtk.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import javax.servlet.http.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ContUtil
{
	private static Logger logger = Logger.getLogger(ContUtil.class.getName());
	public static ContParts parseContBody(String sContId) throws Exception
	{
		ContBody cb = new ContBody();
		cb.s_cont_id = sContId;
		
		if ( cb.retrieve() < 1 )
			throw new Exception("Content parsing error: no body for content part " + sContId);

		replaceScrapeBlockIds(cb);
		ContParts cps = parseContBody(cb);
		cps.s_parent_cont_id = sContId;
		
		// === === ===
		
		Content cont = new Content(sContId);

		ContPart cp = null;
		Content	cc = null;
		for (Enumeration e = cps.elements() ; e.hasMoreElements() ;)
		{
			cp = (ContPart)e.nextElement();
			cc = cp.m_ChildContent;
			if(cc == null) continue;
			if(cc.s_cont_name == null) cc.s_cont_name = cc.toString();
			if(cc.s_cust_id == null) cc.s_cust_id = cont.s_cust_id;
			if(cc.s_type_id == null) cc.s_type_id = String.valueOf(ContType.PARAGRAPH);			
			if(cc.s_status_id == null) cc.s_status_id = String.valueOf(ContStatus.READY);
			if(cc.s_origin_cont_id == null) cc.s_origin_cont_id = sContId;
			if(cc.s_charset_id == null) cc.s_charset_id = cont.s_charset_id;
		}

		cps.save();
		return cps;
	}

	private static ContParts parseContBody(ContBody cb) throws Exception
	{
		String sLogicBlockId = null;
		boolean bUseHtml = false;
		boolean bUseText = false;
		boolean bUseAol = false;				

		String[] sHtmls = split(cb.s_html_part, sLogicBlockId);
		if(sLogicBlockId == null) sLogicBlockId = sHtmls[1];
		if(sHtmls[1]!=null) bUseHtml = true; 

		String[] sTexts = split(cb.s_text_part, sLogicBlockId);
		if(sLogicBlockId == null) sLogicBlockId = sTexts[1];
		if(sTexts[1]!=null) bUseText = true;

		String[] sAols = split(cb.s_aol_part, sLogicBlockId);
		if(sLogicBlockId == null) sLogicBlockId = sAols[1];
		if(sAols[1]!=null) bUseAol = true;
				
		ContParts cps = new ContParts();
		
		if (sLogicBlockId == null) // no logic blocks
		{
			ContPart cp = createContPart(cb);
			cps.add(cp);
		}
		else
		{
			ContBody cb0 = new ContBody();
			cb0.s_html_part = sHtmls[0];
			cb0.s_text_part = sTexts[0];
			cb0.s_aol_part = sAols[0];
			cps.add(parseContBody(cb0));
					
			// === === ===

			String sNewLogicBlockId = cloneContTricky(sLogicBlockId, bUseHtml, bUseText, bUseAol);
			ContPart cp = createContPart(sNewLogicBlockId);
			cps.add(cp);
			
			// === === ===		

			ContBody cb2 = new ContBody();
			cb2.s_html_part = sHtmls[2];
			cb2.s_text_part = sTexts[2];
			cb2.s_aol_part = sAols[2];
			cps.add(parseContBody(cb2));
		}

		return cps;
	}

	public static String[] split(String sPart, String sLogicBlockId) throws Exception
	{
		String[] ss = new String[3];
		
		if(sPart == null) return ss;
		if("".equals(sPart)) return ss;
		
		String sLbEnd = "*lb!";
		if(sLogicBlockId!=null) sLbEnd = ";" + sLogicBlockId + sLbEnd;

		int nLbEnd = sPart.indexOf(sLbEnd);
		if (nLbEnd == -1)
		{
			ss[2] = sPart;
			return ss;
		}
		
		ss[2] = sPart.substring(nLbEnd + sLbEnd.length());
		sPart = sPart.substring(0,nLbEnd);
		
		if (sLogicBlockId==null)
		{
			sLogicBlockId = sPart.substring(sPart.lastIndexOf(";") + 1);
			int nLogicBlockId = Integer.parseInt(sLogicBlockId);
		}
		
		ss[1] = sLogicBlockId;
		ss[0] = sPart.substring(0, sPart.lastIndexOf("!lb*"));
		
		if("".equals(ss[0])) ss[0]=null;
		if("".equals(ss[1])) ss[1]=null;
		if("".equals(ss[2])) ss[2]=null;				
		
		return ss;
	}

	private static ContPart createContPart(ContBody cb)
	{
		ContPart cp = new ContPart();
		cp.m_ChildContent = new Content();
		cp.m_ChildContent.m_ContBody = cb;
		return cp;
	}

	private static ContPart createContPart(String sChildContId)
	{
		ContPart cp = new ContPart();
		cp.s_child_cont_id = sChildContId;
		return cp;
	}

	private static String cloneContTricky(String sContId, boolean bUseHtml, boolean bUseText, boolean bUseAol) throws Exception
	{
		String sNewContId = null;
		
		ConnectionPool cp = null;
		Connection conn = null;

		try
		{
			cp = ConnectionPool.getInstance();			
			conn = cp.getConnection("ContUtil.cloneContTricky()");
			Statement stmt = null;
			try
			{
				stmt = conn.createStatement();
				sNewContId = cloneContTricky(sContId, bUseHtml, bUseText, bUseAol, stmt);
			}
			catch(SQLException ex) { throw ex; }
			finally { if(stmt != null) stmt.close(); }
		}
		catch(SQLException ex) { throw ex; }
		finally { if (conn != null) cp.free(conn); }
				
		return sNewContId;
	}

	private static String cloneContTricky(String sContId, boolean bUseHtml, boolean bUseText, boolean bUseAol, Statement stmt) throws Exception
	{
		String sNewContId = null;
			
		String sSql =
			" EXEC usp_ccnt_cont_clone_tricky2" +
			"  @cont_id=" + sContId +
			", @use_html=" + ((bUseHtml)?"1":"0") +
			", @use_text=" + ((bUseText)?"1":"0") +
			", @use_aol=" + ((bUseAol)?"1":"0");
			
		ResultSet rs = stmt.executeQuery(sSql);
		if(rs.next()) sNewContId = rs.getString(1);
		rs.close();
		
		return sNewContId;		
	}
	
	// === === ===
	
	public static Vector getLogicBlockIds(String sText)
	{
		Vector vIds = new Vector();
		if((sText==null)&&("".equals(sText))) return vIds;

		String sLbEnd = "*lb!";
		String sLogicBlockId = null;
		
		for(int nLbEnd = sText.indexOf(sLbEnd); nLbEnd != -1; nLbEnd = sText.indexOf(sLbEnd))
		{
			sLogicBlockId = sText.substring(0,nLbEnd);
			sLogicBlockId = sLogicBlockId.substring(sLogicBlockId.lastIndexOf(";") + 1);
			try
			{
				Integer.parseInt(sLogicBlockId);
				if(!vIds.contains(sLogicBlockId)) vIds.add(sLogicBlockId);
			}
			catch(Exception ex)
			{
				logger.error("Error: ContUtil.getLogicBlockIds() warning: bad logic block id " + sLogicBlockId,ex);
			}
			sText = sText.substring(nLbEnd + sLbEnd.length());
		}
		
		return vIds;
	}
	
	// === === ===
	
	public static String replaceScrapeBlockIds (String sText)
	{
		String sResult = sText;
		String sSbEnd = "*sb!";
		String sScrapeBlockId = null;
		
		for(int nSbEnd = sText.indexOf(sSbEnd); nSbEnd != -1; nSbEnd = sText.indexOf(sSbEnd))
		{
			sScrapeBlockId = sText.substring(0,nSbEnd);
			sScrapeBlockId = sScrapeBlockId.substring(sScrapeBlockId.lastIndexOf(";") + 1);
			try
			{
				ScrapeFormat sf = new ScrapeFormat();
				sf.s_format_id = sScrapeBlockId;
				
				if (sf.retrieve() > 0) 
				{
					sResult = sResult.replaceAll("\\;"+sf.s_format_id+"\\*sb\\!", ";"+sf.s_cont_id+"*sb!");
					sResult = sResult.replaceAll("\\!sb\\*", "!lb*");
					sResult = sResult.replaceAll("\\*sb\\!", "*lb!");
				} 
				else 
				{
					logger.info("ContUtil.replaceScrapeBlockIds() warning: bad scrape block id " + sScrapeBlockId);
				}
				
			}
			catch(Exception ex)
			{
				logger.error("ContUtil.replaceScrapeBlockIds() warning: bad scrape block id " + sScrapeBlockId,ex);
			}
			sText = sText.substring(nSbEnd + sSbEnd.length());
		}
		
		return sResult;
	}
	
	public static void replaceScrapeBlockIds (ContBody cb) throws Exception
	{
		cb.s_html_part = (cb.s_html_part!=null)?replaceScrapeBlockIds(cb.s_html_part):cb.s_html_part;
		cb.s_text_part = (cb.s_text_part!=null)?replaceScrapeBlockIds(cb.s_text_part):cb.s_text_part;
		cb.s_aol_part = (cb.s_aol_part!=null)?replaceScrapeBlockIds(cb.s_aol_part):cb.s_aol_part;

		cb.save();		
	}
	
	// === === ===

	public static boolean isContSimple(String sContId) throws Exception
	{
		Content cont = new Content();
		cont.s_cont_id = sContId;
		if(cont.retrieve() < 1) throw new Exception ("Invalid content id");

		if(String.valueOf(ContType.LOGIC_BLOCK).equals(cont.s_type_id)) return false;
			
		ContBody cb = new ContBody(sContId);
		if((cb.s_html_part != null) && (cb.s_html_part.indexOf("!lb*") != -1)) return false;
		if((cb.s_text_part != null) && (cb.s_text_part.indexOf("!lb*") != -1)) return false;
		if((cb.s_html_part != null) && (cb.s_html_part.indexOf("!sb*") != -1)) return false;
		if((cb.s_text_part != null) && (cb.s_text_part.indexOf("!sb*") != -1)) return false;
		
		ContParts cps = new ContParts();
		cps.s_parent_cont_id = sContId;
		int nParts = cps.retrieve();

		if(nParts == 0) return true;
		
		if(String.valueOf(ContType.PARAGRAPH).equals(cont.s_type_id))
			throw new Exception ("Invalid content structure");

		if( nParts > 1) return false;
		
		ContPart cp = (ContPart)cps.elements().nextElement();		

		cps.s_parent_cont_id = cp.s_child_cont_id;
		if(cps.retrieve() > 0 ) return false;

		cb = new ContBody(cp.s_child_cont_id);
		if((cb.s_html_part != null) && (cb.s_html_part.indexOf("!lb*") != -1)) return false;
		if((cb.s_text_part != null) && (cb.s_text_part.indexOf("!lb*") != -1)) return false;
		if((cb.s_html_part != null) && (cb.s_html_part.indexOf("!sb*") != -1)) return false;
		if((cb.s_text_part != null) && (cb.s_text_part.indexOf("!sb*") != -1)) return false;
		
		return true;			
	}
	
	// this is assuming the content has been parsed and stored in the content parts table
	public static Vector getContLogicBlockContentElements(String sContId) throws Exception
	{
		Vector vec = new Vector();
		
		Content cont = new Content(sContId);
		if (!String.valueOf(ContType.CONTENT).equals(cont.s_type_id)) {
			return vec;
		}
		ContParts cps = new ContParts();
		cps.s_parent_cont_id = sContId;
		int n = cps.retrieve();
		for (Enumeration e = cps.elements() ; e.hasMoreElements() ;) {
			ContPart cp = (ContPart)e.nextElement();
			Content cc = new Content(cp.s_child_cont_id);
			if (String.valueOf(ContType.LOGIC_BLOCK).equals(cc.s_type_id)) {
				ContParts ccps = new ContParts();
				ccps.s_parent_cont_id = cc.s_cont_id;
				int n2 = ccps.retrieve();
				for (Enumeration e2 = ccps.elements() ; e2.hasMoreElements() ;) {
					ContPart ccp = (ContPart)e2.nextElement();
					if (!vec.contains(ccp.s_child_cont_id)) {
						vec.add(ccp.s_child_cont_id);
					}
				}
			}
		}
		return vec;
	}
	
	//s contains the content parts
	//h contains the list of attr_names for this customer
	public static Vector scanForPers (String s, Hashtable h) throws Exception 
	{
		Vector v = new Vector();
		
		String attrName;
		int i,j,k;

		String tmp = s;
		while (true) {
			i = tmp.indexOf("!*");
			if (i == -1) break;

			tmp = tmp.substring(i);
			j = tmp.indexOf("*!");
			if (j == -1) {
				tmp = tmp.substring(2);
				continue;
			}
			
			//find the attr_name and make sure it is in h
			k = tmp.indexOf(";");
			if (k == -1) {
				tmp = tmp.substring(2);
				continue;
			}
			
			if (k > j) k = j;

			attrName = tmp.substring(2,k);
			if (h.containsKey(attrName) && !v.contains(attrName)) {
				v.add(attrName);
			}
			tmp = tmp.substring(j);
		}
		return v;
	}
	
	// Parses a content paragraph returning it's paragraphs
	// as a vector of Strings and logic blocks
	public static Vector parseParagraph(String part) 
	{
		Vector vPara = new Vector();
		String tmpPart = part;

		int i = tmpPart.indexOf("!lb*");
		int j = 0;
		while (i != -1) {
			vPara.add(tmpPart.substring(0,i));
			j = tmpPart.indexOf("*lb!") + 4;
			if (j != -1) {
				vPara.add(tmpPart.substring(i,j));
				tmpPart = tmpPart.substring(j);
				i = tmpPart.indexOf("!lb*");
			} else {
				i = -1;
			}
		}
		
		if (tmpPart.length() != 0)
			vPara.add(tmpPart);

		return vPara;
	}

	public static String replacePers (String vtext, Hashtable h, HttpServletRequest request) throws Exception 
	{

		String tmp;
		int offset,j,i,l;

		String attrID, attrName, attrValue;
		Enumeration e = h.keys();
		for (int k=0;e.hasMoreElements();++k) {
			attrID = (String)e.nextElement();
			attrName = (String)h.get(attrID);
			
			attrValue = request.getParameter("a"+attrID);
			
			tmp = vtext;
			offset = 0;
			i = tmp.indexOf("!*"+attrName+";");
			while (i != -1) {
				tmp = tmp.substring(i);
				j = tmp.indexOf("*!");
				if (j != -1) {
					if (attrValue.length() == 0) {
						l = tmp.indexOf(";");
						if (l != -1 && l < j) {
							//Use this default since one was not provided
							attrValue = tmp.substring(l+1,j);
						}
					}
					vtext = vtext.substring(0,offset+i)+attrValue+tmp.substring(j+2);

					offset += attrValue.length()+i-2;
					tmp = tmp.substring(j);
					i = tmp.indexOf("!*"+attrName+";");
				} else {
					i = -1;
				}
			}
		}
		return vtext;
	}
	
}
