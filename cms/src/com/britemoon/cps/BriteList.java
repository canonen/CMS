package com.britemoon.cps;

import com.britemoon.*;

public abstract class BriteList extends AbstractBriteList
{
	public BriteConnectionPoolInterface getConnectionPool()
	{
		return ConnectionPool.getInstance();
	}
}	
