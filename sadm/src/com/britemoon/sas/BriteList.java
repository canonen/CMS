package com.britemoon.sas;

import com.britemoon.*;
import com.britemoon.cps.AbstractBriteList;
import com.britemoon.cps.BriteConnectionPoolInterface;
import org.apache.log4j.*;
public abstract class BriteList extends AbstractBriteList
{
	//log4j implementation
	private static Logger logger = Logger.getLogger(BriteList.class.getName());
	public BriteConnectionPoolInterface getConnectionPool()
	{
		return ConnectionPool.getInstance();
	}
}	
