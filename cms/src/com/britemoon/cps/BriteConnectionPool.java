package com.britemoon.cps;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Hashtable;
import java.util.Vector;

import javax.servlet.ServletContext;

import org.apache.log4j.Logger;

public abstract class BriteConnectionPool implements Runnable, BriteConnectionPoolInterface
{
	protected abstract BriteConnectionPool getLocalInstance();
    protected abstract void setLocalInstance(BriteConnectionPool cp);

	// === === ===
    
    private static Logger logger = Logger.getLogger(BriteConnectionPool.class.getName());
		
    public String m_sDriver = null;
    public String m_sUrl = null;
    public String m_sUserName = null;
    public String m_sPassword = null;
	
	// === === ===
		
    public int m_nMinConns = 0;
    public int m_nMaxConns = 0;
    private int iRetrys = 3;
	private long iRetryIntervalMS = 750;
	public boolean m_bWaitIfBusy = true;
	
	// === === ===
		
    public Vector m_vFreeConns = null;
    public Vector m_vBusyConns = null;
    public Vector m_vDirtyConns = null;
    
	private boolean m_bIsConnPending = false;
    
	// === === ===
		
	public Hashtable m_htConnRequestors = null;

	// === === ===
	
	public synchronized void init(ServletContext sc) throws Exception
	{
        if(getLocalInstance() != null) return;
		init(this, sc);
        setLocalInstance(this);
        sc.setAttribute("BriteConnectionPool", this);
	}
    
	private static synchronized void init(BriteConnectionPool cp, ServletContext sc) throws Exception
    {
		cp.m_sDriver = sc.getInitParameter("JdbcDriver");
        cp.m_sUrl = sc.getInitParameter("JdbcUrl");
        cp.m_sUserName = sc.getInitParameter("JdbcUser");
        cp.m_sPassword = sc.getInitParameter("JdbcPassword");
		
        String sMixConns = sc.getInitParameter("JdbcConnectionsMin");
        cp.m_nMinConns = ( sMixConns != null ) ? Integer.parseInt(sMixConns) : 0;
        
		String sMaxConns = sc.getInitParameter("JdbcConnectionsMax");
        cp.m_nMaxConns = ( sMaxConns != null ) ? Integer.parseInt(sMaxConns) : 1;
		
        if(cp.m_nMinConns > cp.m_nMaxConns)  cp.m_nMinConns = cp.m_nMaxConns;
        
        String val = sc.getInitParameter("MaxConnectionRetrys");
    	cp.setRetrys((val != null) ? Integer.parseInt(val): 2);
    	val = sc.getInitParameter("ConnectionRetryIntervalMiliseconds");
    	cp.setRetryInterval((val != null) ? Long.parseLong(val): 500);
        
        cp.m_bWaitIfBusy = true;
		
        cp.init();
    }

    private void init() throws SQLException
    {
        String s =
			"\r\nBriteConnectionPool is opening connections:" + 
			"\r\n\tDriver = " + m_sDriver +
			"\r\n\tUrl = " + m_sUrl +
			"\r\n\tUser Name = " + m_sUserName +
			"\r\n\tMinimum Connections = " + m_nMinConns +
			"\r\n\tMaximum Connections = " + m_nMaxConns +
			"\r\n\tMaximum Retrys = " + getRetrys() +
			"\r\n\tRetry Interval = " + getRetryInterval();
			
        logger.info(s);
		
        m_vFreeConns = new Vector();
        m_vBusyConns = new Vector();
        m_vDirtyConns = new Vector();
		
        m_htConnRequestors = new Hashtable();
		
        for(int i = 0; i < m_nMinConns; i++)
        {
            Connection conn = makeNewConnection();
            logger.info("Connection\t" + (i + 1) + "\t" + conn + "\r");
            m_vFreeConns.add(conn);
        }

        logger.info("\r\n" + m_vFreeConns.size() + " connections created\r\n\r\n");
    }

    protected Connection makeNewConnection() throws SQLException
    {
        try
        {
            Class.forName(m_sDriver);
            Connection conn = DriverManager.getConnection(m_sUrl, m_sUserName, m_sPassword);
            return conn;
        }
        catch(ClassNotFoundException classnotfoundex)
        {
            throw new SQLException("Can't find class for driver: " + m_sDriver);
        }
    }

    private void makeBackgroundConnection()
    {
        m_bIsConnPending = true;
        try
        {
            Thread thread = new Thread(this);
            thread.start();
        }
        catch(Exception ex)
        {
            logger.error("Error: BriteConnectionPool.makeBackgroundConnection", ex);
        }
    }

    public void run()
    {
        try
        {
            Connection conn = makeNewConnection();
            synchronized(this)
            {
                m_vFreeConns.add(conn);
                m_bIsConnPending = false;
                notifyAll();
            }
        }
        catch(Exception ex)
        {
            logger.error("Error: BriteConnectionPool.run", ex);
        }
    }

    public Connection getConnection(Object obj) throws SQLException
    {
        String s = obj.getClass().getName();
        return getConnection(s);
    }

    public Connection getConnection(String sRequestor) throws SQLException
    {
        Connection conn = getConnection();
        sRequestor = sRequestor + " @ " + new java.util.Date();
        m_htConnRequestors.put(conn, sRequestor);
        return conn;
    }

    protected synchronized Connection getConnection() throws SQLException
    {
        if(!m_vFreeConns.isEmpty())
        {
            Connection conn = (Connection)m_vFreeConns.lastElement();
            m_vFreeConns.removeElementAt(m_vFreeConns.size() - 1);
            
			if((conn.isClosed())||(!isConnGood(conn)))
            {
                notifyAll();
                return getConnection();
            }
			else
            {
                m_vBusyConns.addElement(conn);
                return conn;
            }
        }
        if (m_vFreeConns.size() + m_vBusyConns.size() < m_nMaxConns && !m_bIsConnPending)
            makeBackgroundConnection();
        else
	        if(!m_bWaitIfBusy) throw new SQLException("Connection limit reached");
			
        try { wait(); }
        catch(InterruptedException interruptedex) { }
		
        return getConnection();
    }

    protected boolean isConnGood(Connection conn) //throws SQLException
    {
		String sErrMsg = null;
		
		try
		{
			sErrMsg = getErrMsg(conn);
		}
		catch(SQLException ex)
		{
			sErrMsg = ex.getMessage();
			logger.info("BriteConnectionPool.isConnGood", ex);
		}
		
		if(sErrMsg == null) return true;

		try { conn.close(); }
		catch(Exception e) { }
		if (!m_vDirtyConns.contains(conn)) {
			m_vDirtyConns.add(conn);
		}
    	logger.info(sErrMsg);
		
		return false;
    }
	
    private String getErrMsg(Connection conn) throws SQLException
    {
		String sErrMsg = null;
        if(!conn.getAutoCommit())
		{
			conn.setAutoCommit(true);
			sErrMsg = "BriteConnectionPool ERROR: auto-commit is false conn: " + conn;
			return sErrMsg;
		}

        Statement stmt = null;
        try
        {
            stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT @@trancount as test");
            while (rs.next())
			{
				if (rs.getInt(1) == 0) continue;
				sErrMsg = "BriteConnectionPool ERROR: @@trancount > 1 conn: " + conn;
			}
            rs.close();
        }
        catch(SQLException ex)
        {
			try { if(stmt != null) stmt.close(); }
			catch(Exception e) { }

			sErrMsg = "BriteConnectionPool ERROR: dirty conn: " + conn;
			logger.info("BriteConnectionPool.getErrMsg: Error testing for dirty conn", ex);			
        }

        return sErrMsg;
    }

    public synchronized void free(Connection conn)
    {
        m_vBusyConns.removeElement(conn);	
		if (isConnGood(conn)) {
			if (!m_vFreeConns.contains(conn)) {
				m_vFreeConns.addElement(conn);
			}
		}
        notifyAll();
    }

    public synchronized void closeConnections()
    {
        closeConnections(m_vFreeConns);
        m_vFreeConns = new Vector();
        closeConnections(m_vBusyConns);
        m_vBusyConns = new Vector();
        closeConnections(m_vDirtyConns);
        m_vDirtyConns = new Vector();
    }

    private static void closeConnections(Vector vector)
    {
        if(vector == null) return;
        try
        {
            for(int i = 0; i < vector.size(); i++)
            {
                Connection conn = (Connection)vector.elementAt(i);
                if(!conn.isClosed()) conn.close();
            }
        }
        catch(SQLException sqlex) { }
    }
    
    public void setRetrys(int r)
    {
    	iRetrys = r;
    }
    
    public int getRetrys()
    {
    	return iRetrys;
    }
    
    public void setRetryInterval(long i)
    {
    	iRetryIntervalMS = i;
    }
    
    public long getRetryInterval()
    {
    	return iRetryIntervalMS;
    }
}
