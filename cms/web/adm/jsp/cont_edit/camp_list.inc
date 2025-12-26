<%
{
	ConnectionPool cp = null;
	Connection conn = null;
	Statement stmt = null;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();

		ResultSet rs = stmt.executeQuery(sSql);
		
		String sCampId = null;
		String sCampName = null;	
		while(rs.next())
		{
			sCampId = rs.getString(1);
			sCampName = rs.getString(2);		
%>
<OPTION value="<%=sCampId%>"> <%=HtmlUtil.escape(sCampName)%> ( <%=sCampId%> ) </OPTION>	
<%
		}
		rs.close();
	}
	catch(Exception ex) { throw ex; }
	finally
	{
		try { if (stmt != null) stmt.close(); }
		catch(Exception exx) 
		{ 
			logger.error("Exception: ",exx); 
		}
		if (conn != null) cp.free(conn);
	}
}
%>
