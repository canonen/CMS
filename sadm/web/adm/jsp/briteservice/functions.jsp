<%!
	private static Properties loadProps(HttpSession session, String sConfigFile) throws Exception
	{
		ServletContext context = session.getServletContext(); 
		return loadProps(context, sConfigFile);
	}

	public static Properties loadProps(ServletContext context, String sConfigFile) throws Exception
	{
		String sContextRoot = context.getRealPath("/");
		String sResourcesDir = sContextRoot + "\\adm\\jsp\\briteservice";
		if(sConfigFile == null) sConfigFile = "props.conf";
		
		return loadProps(sResourcesDir, sConfigFile);
	}

	private static Properties loadProps(String sResourcesDir, String sPropsFileName) throws Exception
	{
		sPropsFileName = sResourcesDir + "\\" + sPropsFileName;
		Properties props = loadProps(sPropsFileName);
		
		String sDefaults = props.getProperty("defaults");

		Properties defprops = null;
		if (sDefaults == null) defprops = loadProps(sResourcesDir + "\\props.conf");
		else defprops = loadProps(sResourcesDir, sDefaults);
		
		defprops.putAll(props);
		
		return defprops;
	}
			
	private static Properties loadProps(String sPropsFileName) throws Exception
	{
		Properties props = new Properties();

		File fPropsFile = new File(sPropsFileName);
		if (!fPropsFile.exists()) return props;
		
		FileInputStream fisProps = null;		
		try
		{
			fisProps = new FileInputStream(fPropsFile);
			props.load(fisProps);
		}
		catch(Exception ex) { ex.printStackTrace(); throw ex; }
		finally { if( fisProps != null ) fisProps.close(); }
		
		return props;
	}

	private static String getModInstID(Statement stmt, String cust_id, String mod_inst) throws Exception
	{
		if ( cust_id == null || mod_inst == null ) {
			throw new Exception("null not allowed for cust_id or mod_inst");
		}
		if (!(mod_inst.toUpperCase().equals("CCPS") || mod_inst.toUpperCase().equals("RRCP"))) {
			throw new Exception("mod_inst must be either CCPS or RRCP");
		}
		String sModInstId = null;
		String sql = "select mi.mod_inst_id" +
		      		 "  from sadm_customer c with(nolock)" +
		      		 "  left outer join sadm_cust_mod_inst cmi with(nolock) on c.cust_id = cmi.cust_id" +
		      		 "  left outer join sadm_mod_inst mi with(nolock) on mi.mod_inst_id = cmi.mod_inst_id" +
		      		 "  left outer join sadm_module mo with(nolock) on mo.mod_id = mi.mod_id" +
		      		 " inner join sadm_machine ma with(nolock) on ma.machine_id = mi.machine_id" +
		      		 " where c.cust_id = '" + cust_id + "' and mo.abbreviation = '" + mod_inst.toUpperCase() + "'"+
		      		 " order by mo.abbreviation";
		ResultSet rs = stmt.executeQuery(sql);
		rs.next();
		sModInstId = rs.getString(1);
		rs.close();	

		return sModInstId;
	}
%>