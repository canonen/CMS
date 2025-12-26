package com.britemoon.cps;

import java.sql.*;
import java.io.*;
import java.util.*;
import javax.xml.parsers.*;
import javax.xml.transform.*;
import javax.xml.transform.dom.*;
import javax.xml.transform.stream.*;

import org.w3c.dom.*;

public abstract class AbstractBriteObject extends AbstractBriteObjectGeneric
{
	// === DB stuff ===

	protected abstract String getRetrieveSql();
	protected abstract String getSaveSql();
	protected abstract String getDeleteSql();

	protected abstract int retrieveProps(PreparedStatement pstmt) throws Exception;
	protected abstract void getPropsFromResultSetRow(ResultSet rs) throws Exception;
	protected abstract int saveProps(PreparedStatement pstmt) throws Exception;
	protected abstract int deleteProps(PreparedStatement pstmt) throws Exception;

	final public int retrieve(Connection conn) throws Exception {return retrieve(this, conn);}
	final public int save(Connection conn) throws Exception {return save(this, conn);}
	final public int delete(Connection conn) throws Exception {return delete(this, conn);}

	// These methods are implemented here to be able
	// to remove them from decendant descendant
	// if they are not required
	
	protected int saveParents(Connection conn) throws Exception { return 0; }
	protected int deleteParents(Connection conn) throws Exception { return 0; }

	protected int saveChildren(Connection conn) throws Exception { return 0; }
	protected int deleteChildren(Connection conn) throws Exception { return 0; }

	// === Static Implementations  ===
	
	final protected static int retrieve(AbstractBriteObject bo, Connection conn) throws Exception {return execDbMethod(bo, conn, RETRIEVE);}
	final protected static int save(AbstractBriteObject bo, Connection conn) throws Exception {return execDbMethod(bo, conn, SAVE);}
	final protected static int delete(AbstractBriteObject bo, Connection conn) throws Exception {return execDbMethod(bo, conn, DELETE);}

	final private static int execDbMethod(AbstractBriteObject bo, Connection conn, int iMethod) throws Exception
	{
		int nReturnCode = 0;

		// === === ===

		switch (iMethod)
		{
			case SAVE: bo.saveParents(conn); break;
			case DELETE: bo.deleteChildren(conn); break;
		}

		// === === ===
					
		PreparedStatement pstmt = null;
		String sSql = null;
		try
		{
			switch (iMethod)
			{
				case RETRIEVE: sSql = bo.getRetrieveSql(); break;
				case SAVE: sSql = bo.getSaveSql(); break;
				case DELETE: sSql = bo.getDeleteSql(); break;
			}
			
			pstmt = conn.prepareStatement(sSql);

			switch (iMethod)
			{
				case RETRIEVE: nReturnCode = bo.retrieveProps(pstmt); break;
				case SAVE: nReturnCode = bo.saveProps(pstmt); break;
				case DELETE: nReturnCode = bo.deleteProps(pstmt); break;
			}
		}
		catch(Exception ex) { throw ex; }
		finally { if(pstmt != null) pstmt.close(); }

		// === === ===
		
		switch (iMethod)
		{
			case SAVE: bo.saveChildren(conn); break;
			case DELETE: bo.deleteParents(conn); break;
		}
		
		// === === ===

		return nReturnCode;
	}

	// === XML stuff ===

	abstract protected void getPropsFromXml(Element e);
	abstract protected void appendPropsToXml(Element e);	

	// These methods are implemented here to be able
	// to remove them from decendant descendant
	// if they are not required
	
	protected void getParentsFromXml(Element e) throws Exception { ; }
	protected void appendParentsToXml(Element e) { ; }

	protected void getChildrenFromXml(Element e) throws Exception { ; }
	protected void appendChildrenToXml(Element e) { ; }
	
	public int getPartsFromXml(Element e) throws Exception
	{
		getPropsFromXml(e);
		getParentsFromXml(e);
		getChildrenFromXml(e);
		return 1;
	}
	
	public int appendPartsToXml(Element e)
	{
		appendPropsToXml(e);
		appendParentsToXml(e);
		appendChildrenToXml(e);
		return 1;			
	}
}