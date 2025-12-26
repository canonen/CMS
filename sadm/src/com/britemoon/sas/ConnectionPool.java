package com.britemoon.sas;

import com.britemoon.*;
import com.britemoon.cps.BriteConnectionPool;
import org.apache.log4j.*;
public class ConnectionPool extends BriteConnectionPool
{
	//log4j implementation
	private static Logger logger = Logger.getLogger(ConnectionPool.class.getName());
	private static ConnectionPool m_cpMainInstance = null;

    public static ConnectionPool getInstance() { return m_cpMainInstance; }
	
    protected BriteConnectionPool getLocalInstance() { return m_cpMainInstance; }
    protected void setLocalInstance(BriteConnectionPool cp) { m_cpMainInstance = (ConnectionPool) cp; }
}
