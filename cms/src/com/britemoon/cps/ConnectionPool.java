package com.britemoon.cps;

import com.britemoon.*;

public class ConnectionPool extends BriteConnectionPool
{
    private static ConnectionPool m_cpMainInstance = null;

    public static ConnectionPool getInstance() { return m_cpMainInstance; }
	
    protected BriteConnectionPool getLocalInstance() { return m_cpMainInstance; }
    protected void setLocalInstance(BriteConnectionPool cp) { m_cpMainInstance = (ConnectionPool) cp; }
}
