package com.britemoon.cps;

import java.sql.*;
import java.io.*;
import java.util.*;
import javax.xml.parsers.*;
import javax.xml.transform.*;
import javax.xml.transform.dom.*;
import javax.xml.transform.stream.*;

import org.w3c.dom.*;

public abstract class AbstractBriteObjectGeneric
{
	// === DB stuff ===

	final public int retrieve() throws Exception {return retrieve(this);}
	final public int save() throws Exception {return save(this);}
	final public int delete() throws Exception {return delete(this);}

	protected abstract int retrieve(Connection conn) throws Exception;
	protected abstract int save(Connection conn) throws Exception;
	protected abstract int delete(Connection conn) throws Exception;

	protected abstract BriteConnectionPoolInterface getConnectionPool() throws Exception;
	
	// === Static Implementations  ===
	
	final protected static int RETRIEVE = 1;
	final protected static int SAVE = 2;
	final protected static int DELETE = 3;		
	
	final protected static int retrieve(AbstractBriteObjectGeneric bo) throws Exception {return execDbMethod(bo, RETRIEVE);}
	final protected static int save(AbstractBriteObjectGeneric bo) throws Exception {return execDbMethod(bo, SAVE);}
	final protected static int delete(AbstractBriteObjectGeneric bo) throws Exception {return execDbMethod(bo, DELETE);}

	final private static int execDbMethod(AbstractBriteObjectGeneric bo, int iMethod) throws Exception
	{
		int nReturnCode = -1;

		BriteConnectionPoolInterface cp = null;
		Connection conn = null;
		boolean bAutoCommit = true;
		try
		{
			cp = bo.getConnectionPool();
			conn = cp.getConnection(bo);
			bAutoCommit = conn.getAutoCommit();
			conn.setAutoCommit(false);

			switch (iMethod)
			{
				case RETRIEVE: nReturnCode = bo.retrieve(conn); break;
				case SAVE: nReturnCode = bo.save(conn); break;
				case DELETE: nReturnCode = bo.delete(conn); break;
			}

			conn.commit();
		}
		catch(Exception ex)
		{
			if (conn != null)
			{
				try { conn.rollback(); }
				catch(Exception exx) { System.out.println(bo + " ERROR on conn.rollback()"); }
			}
			throw ex;
		}
		finally
		{
			if (conn != null)
			{
				try { conn.setAutoCommit(bAutoCommit); }
				catch(Exception ex) { System.out.println(bo + " ERROR on conn.setAutoCommit(bAutoCommit)"); }
				cp.free(conn);
			}
		}
		
		return nReturnCode;
	}

	// === XML stuff ===

	protected abstract String getMainElementName();

	// === from XML ===

	protected abstract int appendPartsToXml(Element e);
	protected abstract int getPartsFromXml(Element e) throws Exception;	

	final public int fromXml(Element e) throws Exception
	{
		return fromXmlElement(e);
	}
		
	final public int fromXmlElement(Element e) throws Exception
	{
		String s = getMainElementName();
		if(!e.getNodeName().equals(s)) throw new Exception("Malformed " + s + " xml.");
		return getPartsFromXml(e);
	}

	// === to XML ===
	
	public boolean bStripXmlHeader = true;
	
	final public String toXml()	throws TransformerException, ParserConfigurationException
	{
		StringWriter sw = new StringWriter();
		toXml(sw);
		String sResultXml =  sw.toString();

		//This is incorrect, but as usual for backward compatibility
		//Strip XML header <?xml version="1.0" encoding="UTF-8"?>
		if (bStripXmlHeader)
		{
			String sXmlHeader = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
			int i = sResultXml.indexOf(sXmlHeader);
			if (i >= 0)
			{
				i += sXmlHeader.length();
				sResultXml = sResultXml.substring(i);
			}
		}

		return sResultXml;
	}

	final public void toXml(StringWriter sw) throws TransformerException, ParserConfigurationException
	{
		Document d = toXmlDocument();
		Transformer t = TransformerFactory.newInstance().newTransformer();
		t.transform(new DOMSource(d), new StreamResult(sw));
	}

	
	final public Document toXmlDocument() throws ParserConfigurationException
	{
		Document d = null;
		DocumentBuilder db = DocumentBuilderFactory.newInstance().newDocumentBuilder();
		d = db.newDocument();

		Element e = toXmlElement(d);
		d.appendChild(e);

		return d;
	}

	final public Element toXmlElement(Document d)
	{
		Element e = d.createElement(getMainElementName());
		appendPartsToXml(e);
		return e;
	}

	final public Element toXmlElement(Element e)
	{
		Document d = e.getOwnerDocument();
		return toXmlElement(d);
	}

	final protected static Element appendChild(Element e, AbstractBriteObjectGeneric bo)
	{
		return (Element) e.appendChild(bo.toXmlElement(e));
	}
	
	// === === ===
	
	final public String toXmlNice() throws Exception
	{
		return toXmlNice(toXml());
	}
	
	final public static String toXmlNice(String sXml) throws Exception
	{
		sXml = sXml.replaceAll("><", ">\r\n<");
		BufferedReader br = new BufferedReader(new StringReader(sXml));
		StringWriter sw = new StringWriter();
		int nTabCount = 0;
		boolean bReadingCdata = false;
		
		for(String sLine = br.readLine(); sLine != null; sLine = br.readLine())
		{
			if (bReadingCdata)
			{
				if ((sLine.length() > 2) && (sLine.substring(sLine.length()-3).equals("]]>"))) bReadingCdata = false;
				sw.write(sLine);
				sw.write("\r\n");
				continue;
			}		
						
			if(sLine.length() == 0) continue;

			if (sLine.startsWith("</"))
			{
				nTabCount--;

				for(int i = 0; i < nTabCount; i++) sw.write("\t");
				sw.write(sLine);
				sw.write("\r\n");
			}
			else
			{												
				for(int i = 0; i < nTabCount; i++) sw.write("\t");
				sw.write(sLine);
				sw.write("\r\n");
				
				if (sLine.startsWith("<![CDATA["))
				{
					if(!sLine.substring(sLine.length()-3).equals("]]>")) bReadingCdata = true;
					continue;
				}
				if (sLine.indexOf("</") != -1) continue;
				if (sLine.indexOf("/>") != -1) continue;
				if (sLine.substring(sLine.length()-1).equals(">")) nTabCount++;
			}
		}
		return sw.toString();
	}
}

/*
	final public int fromXml(Document d) throws Exception
	{
		return fromXmlDocument(d);
	}

	final public int fromXmlDocument(Document d) throws Exception
	{
		Element e = d.getDocumentElement();
		return fromXmlElement(e);
	}
*/
