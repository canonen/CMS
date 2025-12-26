package com.britemoon.cps;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import javax.servlet.http.HttpServletRequest;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import java.io.*;

public class XmlUtil
{
	public static Element getChildByName(Element e, String sChildName)
	{
		Element eChild = null;
		
		Node n = null;
		NodeList nl = e.getChildNodes();
		int iLength = nl.getLength();
		for(int i = 0; i < iLength; i++)
		{
			n = nl.item(i);
			if ((n.getNodeType() == Node.ELEMENT_NODE)&&(n.getNodeName().equals(sChildName)))
			{
				eChild = (Element)n;
				break;
			}
		}
		return 	eChild;
	}

	public static XmlElementList getChildrenByName(Element e, String sChildrenName)
	{
		XmlElementList xelChildren = new XmlElementList();

		Node n;
		NodeList nl = e.getChildNodes();
		int iLength = nl.getLength();
		for(int i = 0; i < iLength; i++)
		{
			n = nl.item(i);		
			if ((n.getNodeType() == Node.ELEMENT_NODE)&&(n.getNodeName().equals(sChildrenName)))
			{
				xelChildren.add(n);
			}
		}
		return xelChildren;
	}

	// === === ===
	
	public static String getChildTextValue(Element e, String sChildName)
	{
		Element eChild = getChildByName(e, sChildName);
		if ( eChild == null ) return null;
		return getTextValue(eChild);
	}

	// Function added during Release 5.9
	public static String getAttrTextValue(Element e, String sAttrName)
	{
		return e.getAttribute(sAttrName).toString();
	}

	public static String getChildCDataValue(Element e, String sChildName)
	{
		Element eChild = getChildByName(e, sChildName);
		if ( eChild == null ) return null;		
		return getCDataValue(eChild);
	}

	public static String getTextValue(Element e)
	{
		return getValue(e, Node.TEXT_NODE);
	}
	
	public static String getCDataValue(Element e)
	{
		return getValue(e, Node.CDATA_SECTION_NODE);
	}
	
	private static String getValue(Element e, short nNodeType)
	{
		String sValue = null;
		
		Node n;
		NodeList nl = e.getChildNodes();
		int iLength = nl.getLength();
		for(int i = 0; i < iLength; i++)
		{
			n = nl.item(i);		
			if ((n.getNodeType() == nNodeType))
			{
				if (sValue == null) sValue = n.getNodeValue();
				else sValue += n.getNodeValue();
			}
		}
		
		if( sValue != null ) sValue = sValue.replaceAll("\\r\\r\\n", "\r\n");
		return sValue;
	}

	// === === ===
	
	public static Element appendTextChild(Element e, String sChildName, String sChildValue)
	{
		return appendChild(e, sChildName, sChildValue, Node.TEXT_NODE);
	}	

	public static Element appendCDataChild(Element e, String sChildName, String sChildValue)
	{
		return appendChild(e, sChildName, sChildValue, Node.CDATA_SECTION_NODE);
	}	

	public static Element appendChild(Element e, String sChildName, String sChildValue, int iNodeType)
	{
		Document d = e.getOwnerDocument();
		Element eChild = d.createElement(sChildName);
		Node n = null;
		
		if( sChildValue != null ) sChildValue = sChildValue.replaceAll("\\r\\n", "\n");
		
		switch(iNodeType)
		{
			case Node.CDATA_SECTION_NODE: n = d.createCDATASection(sChildValue); break;
			case Node.TEXT_NODE: n = d.createTextNode(sChildValue); break;
		}
		eChild.appendChild(n);
		e.appendChild(eChild);
		return eChild;
	}	

	// === === ===

	public static Element getRootElement(String sXml)
		throws IOException, ParserConfigurationException, SAXException
	{
		return getRootElement(new StringReader(sXml)); 
	}

	public static Element getRootElement(StringReader srXml) //Reader rXml ???
		throws IOException, ParserConfigurationException, SAXException
	{
		return getRootElement(new InputSource(srXml));
	}

	public static Element getRootElement(InputStream isXml)
		throws IOException, ParserConfigurationException, SAXException
	{
		BufferedReader brXml = new BufferedReader(new InputStreamReader(isXml, "UTF-8"));	
		return getRootElement(new InputSource(brXml));
	}

	public static Element getRootElement(HttpServletRequest hsrXml)
		throws IOException, ParserConfigurationException, SAXException
	{
		return getRootElement(hsrXml.getInputStream());
	}

	protected static Element getRootElement(InputSource isXml)
		throws IOException, ParserConfigurationException, SAXException
	{
		Element eRootElement =
			DocumentBuilderFactory.newInstance().
			newDocumentBuilder().parse(isXml).getDocumentElement();
			
		return eRootElement;
	}
}
