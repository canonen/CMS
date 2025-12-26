package com.britemoon.cps;

import com.britemoon.*;

public abstract class BriteObject extends AbstractBriteObject
{
	public BriteConnectionPoolInterface getConnectionPool()
	{
		return ConnectionPool.getInstance();
	}
}	
