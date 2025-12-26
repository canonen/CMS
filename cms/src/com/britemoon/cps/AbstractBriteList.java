package com.britemoon.cps;

import com.britemoon.*;

import java.io.*;
import java.sql.*;
import java.util.*;
import org.w3c.dom.*;

public abstract class AbstractBriteList extends AbstractBriteListGeneric
{
	// === DB stuff ===
	
	public String m_sRetrieveSql = null;
	public boolean m_bUseParamsForRetrieve = true;
	
	public String m_sSelectClause = null;
	public String m_sFromClause = null;
	public String m_sWhereClause = null;
	public String m_sOrderByClause = null;

	abstract protected String buildWhereClause();
	
	public String getRetrieveSql()
	{
		if( m_sRetrieveSql != null ) return m_sRetrieveSql;
		return buildRetrieveSql();
	}

	public String buildRetrieveSql()
	{
	
		String sRetrieveSql = "";
		
		if(m_sSelectClause!=null)
			sRetrieveSql += (" " + m_sSelectClause + " ");

		if(m_sFromClause!=null)
			sRetrieveSql += (" " + m_sFromClause + " ");

		if(m_sWhereClause != null)
			sRetrieveSql += (" " + m_sWhereClause + " ");
		else if (m_bUseParamsForRetrieve)
		{
			String sWhereClause = buildWhereClause();

			if ((sWhereClause!=null) && (sWhereClause.trim().equals("WHERE")))
			{
				String sErrMsg = 
					"" + this + " ERROR:" +
					"\r\n\tAll params in " + this + " are null" +					
					"\r\n\tif you need the whole list set m_bUseParamsForRetrieve = false";
					
				System.out.println(sErrMsg);
				System.out.flush();
			}
			
			sRetrieveSql += (" " + sWhereClause + " ");
		}
			
		if(m_sOrderByClause!=null)
			sRetrieveSql += (" " + m_sOrderByClause + " ");

		return sRetrieveSql;
	}
}	
