package com.britemoon.sas;

import com.britemoon.*;
import com.britemoon.cps.AbstractBriteObject;
import com.britemoon.cps.BriteConnectionPoolInterface;
import org.apache.log4j.*;
public abstract class BriteObject extends AbstractBriteObject
{
	//log4j implementation
	private static Logger logger = Logger.getLogger(BriteObject.class.getName());
	public BriteConnectionPoolInterface getConnectionPool()
	{
		return ConnectionPool.getInstance();
	}
}	
