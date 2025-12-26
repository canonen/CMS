package com.britemoon.cps;

import com.britemoon.*;

import java.io.*;
import java.sql.*;
import java.util.*;
import org.w3c.dom.*;

public abstract class AbstractBriteListGeneric extends AbstractBriteObjectGeneric
{
	protected Vector v = null;
	
	// === Constructors ===
		
	public AbstractBriteListGeneric () { v = new Vector(); }
	
	// === Generic methods ===
		
	final public int size() { return v.size(); }
	final public Enumeration elements() { return v.elements(); }
	final public boolean add(AbstractBriteObjectGeneric bo) { return v.add(bo); }
	final public boolean add(AbstractBriteListGeneric bl) { return v.addAll(bl.v); }	

	// === DB stuff ===
	
	public boolean bFixIds = true;
	public void fixIds() { ; }
	
	public int save(Connection conn) throws Exception { return save(this, conn); }
	public int delete(Connection conn) throws Exception { return delete(this, conn); }	
		
	final protected static int save(AbstractBriteListGeneric bl, Connection conn)
		throws Exception { return execDbMethod(bl, conn, SAVE); }
	final protected static int delete(AbstractBriteListGeneric bl, Connection conn)
		throws Exception { return execDbMethod(bl, conn, DELETE); }

	final private static int execDbMethod(AbstractBriteListGeneric bl, Connection conn, int iMethod)
		throws Exception
	{
		int nReturnCode = 0;
		if( bl.v == null ) return nReturnCode;
	
		if(bl.bFixIds) bl.fixIds();

		AbstractBriteObject bo = null;
		for (Enumeration e = bl.v.elements() ; e.hasMoreElements() ;)
		{
			bo = (AbstractBriteObject)e.nextElement();
			switch (iMethod)
			{
				case SAVE:
				{
					nReturnCode += bo.save(conn);
					break;
				}
				case DELETE:
				{
					nReturnCode += bo.delete(conn);
					break;
				}
			}
		}
		
		return nReturnCode;		
	}
	
	// === === ===
	
	public boolean m_bUseParamsForRetrieve = true;
	
	abstract protected String getRetrieveSql();
	abstract protected void setParams(PreparedStatement pstmt) throws Exception;
	abstract protected int getListFromResultSet(ResultSet rs) throws Exception;
		
	public int retrieve(Connection conn) throws Exception
	{
		int nReturnCode = 0;
		PreparedStatement pstmt = null;
		try
		{
			String sRetrieveSql = getRetrieveSql();
			pstmt = conn.prepareStatement(sRetrieveSql);
			
			if (m_bUseParamsForRetrieve) setParams(pstmt);

			ResultSet rs = pstmt.executeQuery();
			nReturnCode = getListFromResultSet(rs);
			rs.close();
		}
		catch(Exception ex)	{ throw ex; }
		finally	{ if(pstmt != null) pstmt.close(); }
		
		return nReturnCode;
	}

	// === XML stuff ===

	protected abstract String getSubElementName();
	protected abstract int getPartsFromXml(NodeList nl) throws Exception;
	
	public int getPartsFromXml(Element e) throws Exception
	{
		int nReturnCode = 0;

		NodeList nl = XmlUtil.getChildrenByName(e, getSubElementName());
		int iLength = nl.getLength();
		if (iLength > 0)
		{
			v = new Vector(iLength);
			nReturnCode = getPartsFromXml(nl);
		}
		else { v = new Vector();}
		
		return nReturnCode;
	}

	public int appendPartsToXml(Element e)
	{
		int nReturnCode = 0;
		if( v == null ) return nReturnCode;

		AbstractBriteObjectGeneric bo = null;
		for (Enumeration en = v.elements() ; en.hasMoreElements() ;)
		{
			bo = (AbstractBriteObjectGeneric) en.nextElement();
			appendChild(e, bo);
			nReturnCode ++;
		}
		
		 return nReturnCode;
	}	
}	
