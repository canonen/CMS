<%@ page
		language="java"
		import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
		errorPage="../../error_page.jsp"
		contentType="text/html;charset=UTF-8"
%>

<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

	String sFromAddressId = request.getParameter("from_address_id");

	FromAddress fa = null;

	if( sFromAddressId == null)
	{
		fa = new FromAddress();
		fa.s_cust_id = cust.s_cust_id;
	}
	else fa = new FromAddress(sFromAddressId);
%>
<%
	ConnectionPool cp = null;
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	String sSql = null;
	String sDomainId = null;
	ArrayList arrDomain = new ArrayList();

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();

		sSql =  " SELECT domain_id, domain" +
				" FROM cadm_vanity_domain vd, cadm_mod_inst mi" +
				" WHERE vd.cust_id=" + cust.s_cust_id +
				" AND vd.mod_inst_id=mi.mod_inst_id" +
				" AND mi.mod_id=" + Module.AINB +
				" ORDER BY domain";

		rs = stmt.executeQuery(sSql);
		while(rs.next())
		{
			sDomainId = rs.getString(1);
			arrDomain.add(rs.getString(2));
		}
		rs.close();
	}
	catch(Exception ex)
	{
		ErrLog.put(this, ex, "Error in " + this.getClass().getName() , out, 1);
	}
	finally
	{
		if(conn!=null) cp.free(conn);
	}

%>
