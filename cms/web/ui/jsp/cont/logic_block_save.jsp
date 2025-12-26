<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.net.URLEncoder"		
	import="java.util.*"
	import="org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
	if(logger == null) logger = Logger.getLogger(this.getClass().getName());

	AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

	if(!can.bWrite)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}
	
	// === === ===
	
	final int SAVE=1, SAVE_AS_NEW=2, SAVE_BLOCK=3, SAVE_FILTER=4;
	final int METHOD_SAVE=0, METHOD_ADD=1, METHOD_DELETE=2,METHOD_UP=3,METHOD_DOWN=4;

	String userID = user.s_user_id;
	String custID = cust.s_cust_id;

	String sSelectedCategoryId = BriteRequest.getParameter(request, "category_id");

	int iActionSave = -1, iMethod = -1;
	String logicID = BriteRequest.getParameter(request, "logicID");
	String logicName = BriteRequest.getParameter(request, "LogicName");
	
	String parentContID = BriteRequest.getParameter(request, "parentContID");
	String destContID = BriteRequest.getParameter(request, "destContID");
	String destFilterID = BriteRequest.getParameter(request, "destFilterID");
        String sMaxElementsInLogicBlock = BriteRequest.getParameter(request, "MaxElementsInLogicBlock");
        
        String contID = BriteRequest.getParameter(request, "contID");
        String filterID = BriteRequest.getParameter(request, "filterID");
        String defaultFlag = "null";
        int nSeq = Integer.parseInt(BriteRequest.getParameter(request, "seq"));
        int nNextSeq = Integer.parseInt(BriteRequest.getParameter(request, "next_seq"));
       
        boolean newLogic = false;


	String extraRedirectParams = "";

	// === === ===
	
	ConnectionPool cp	= null;
	Connection conn		= null;
	Statement stmt		= null;
	ResultSet rs		= null;
	PreparedStatement pstmt = null;
	
	try
	{
		if (BriteRequest.getParameter(request, "ActionSave") != null)
			iActionSave = new Integer(BriteRequest.getParameter(request, "ActionSave")).intValue();
			
		if (iActionSave < SAVE || iActionSave > SAVE_FILTER)
			throw new Exception ("Incorrect Action Code:"+iActionSave);

		if (BriteRequest.getParameter(request, "method")!=null)
			iMethod = new Integer(BriteRequest.getParameter(request, "method")).intValue();
			
		if (iMethod < METHOD_SAVE || iMethod > METHOD_DOWN)
			throw new Exception ("Incorrect Method Code: "+iMethod);

		// === === ===
		
		String cloneLogicID = null;

		if (iActionSave==SAVE_AS_NEW)
		{
			cloneLogicID = logicID;
			logicID = null;
		}
		
		// === === ===
		
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
                conn.setAutoCommit(false);
		stmt = conn.createStatement();

		String sSql = null;

		try
		{
			// === === ===

			sSql =
				"  EXEC usp_ccnt_logic_block_modify" +
				"  @cont_id=" + logicID +
				", @cust_id=" + custID +
				", @cont_name=?" +
				", @user_id=" + userID;

			newLogic = (logicID == null || logicID.equals("null"));
			pstmt = conn.prepareStatement(sSql);
			pstmt.setBytes(1, logicName.getBytes("UTF-8"));
			rs = pstmt.executeQuery();
			if (rs.next())
			{
				logicID = rs.getString(1);
				rs.close();
			}
			else
			{
				rs.close();
				throw new Exception ("Could not save logic block info");
			}

			// === === ===
				
			if (iMethod != METHOD_SAVE)
			{

				//Grab the numMaps, filterID and contID, seq
				//int numMaps = Integer.parseInt(BriteRequest.getParameter(request, "numMaps"));

				if (iMethod == METHOD_ADD)
				{
					if (filterID.equals("-1"))
					{
						filterID = "null";
						defaultFlag = "1";
					}
					
					sSql =
						" INSERT ccnt_cont_part " +
						" (parent_cont_id, child_cont_id, filter_id, seq, default_flag) " +
						" VALUES " +
						" ("+logicID+","+contID+","+filterID+","+nNextSeq+","+defaultFlag+")";
 					stmt.executeUpdate(sSql);
				}
				else if (iMethod == METHOD_DELETE)
				{
					sSql =
						" DELETE ccnt_cont_part " +
						" WHERE parent_cont_id = " + logicID +
						" AND seq = " + nSeq;

					stmt.executeUpdate(sSql);

					sSql =
						" EXEC usp_ccnt_cont_part_move" +
						"  @parent_cont_id = " + logicID +
					 	", @seq = " + nSeq +
					 	", @steps = 0";

					stmt.executeUpdate(sSql);
					
					extraRedirectParams += "&cont_id="+contID;
				}
				else if (iMethod == METHOD_UP)
				{
					sSql =
						" EXEC usp_ccnt_cont_part_move" +
						"  @parent_cont_id = " + logicID +
					 	", @seq = " + nSeq +
					 	", @steps = -1";
					 	
					stmt.executeUpdate(sSql);
				}
				else if (iMethod == METHOD_DOWN)
				{
					sSql =
						" EXEC usp_ccnt_cont_part_move" +
						"  @parent_cont_id = " + logicID +
					 	", @seq = " + nSeq +
					 	", @steps = 1";

					stmt.executeUpdate(sSql);
				}
			}
			else if (iActionSave == SAVE_AS_NEW)
			{
				//Copy the mappings
				sSql =
					" INSERT ccnt_cont_part (parent_cont_id,child_cont_id,filter_id,seq,default_flag)" +
					" SELECT " + logicID + ",child_cont_id,filter_id,seq,default_flag" +
					" FROM ccnt_cont_part " +
					" WHERE parent_cont_id = " + cloneLogicID;					
				stmt.executeUpdate(sSql);
			}
                        conn.commit();
                        
                } catch (Exception e)
		{
			conn.rollback();	
			throw e;
		}
                
                try {
			// === Categories ===
			
			if (!newLogic)
			{
				sSql =
					" DELETE FROM ccps_object_category" + 
					" WHERE cust_id=?" +
					" AND object_id=?" +
					" AND type_id=?";
				pstmt = conn.prepareStatement(sSql);
				pstmt.setString(1, cust.s_cust_id);
				pstmt.setString(2, logicID);
				pstmt.setString(3, String.valueOf(ObjectType.CONTENT));
				pstmt.executeUpdate();
			}
			
			String[] sCategories = request.getParameterValues("categories");
			int l = ( sCategories == null )?0:sCategories.length;

			if ( l > 0)
			{
				sSql =
					" INSERT ccps_object_category (cust_id,  object_id, type_id, category_id)" +
					" VALUES (?, ?, ?, ?)";

				for(int i=0; i<l ;i++)
				{
					pstmt = conn.prepareStatement(sSql);
					pstmt.setString(1, cust.s_cust_id);
					pstmt.setString(2, logicID);
					pstmt.setString(3, String.valueOf(ObjectType.CONTENT));
					pstmt.setString(4, sCategories[i]);
					pstmt.executeUpdate();
				}
			}
                        // === Update MaxElementsInLogicBlock for only parent record of logic block. ===
                
                        if (!newLogic) 
                        {
                            sSql =
                                " EXECUTE usp_ccnt_cont_part_update_max_elements" +
                                "	@parent_cont_id= "+ logicID + 
                                ",      @max_elements_in_logic_block=" + sMaxElementsInLogicBlock;
                             stmt.executeUpdate(sSql);
                            
                        }
		
			conn.commit();						
		}
 		catch (Exception e)
		{
			conn.rollback();	
			throw e;
		}
		finally
		{
			if (stmt!=null) stmt.close();
			if (pstmt!=null) pstmt.close();
			if (conn!=null) {
                            conn.setAutoCommit(true);
                            cp.free(conn);
                        }
		}

		if (iActionSave == SAVE_BLOCK)
		{
			response.sendRedirect("cont_block_edit.jsp?logic_id="+logicID+(parentContID!=null?"&parent_cont_id="+parentContID:"")+(destContID!=null?"&cont_id="+destContID:"")+extraRedirectParams);
		}
		else if (iActionSave == SAVE_FILTER)
		{
			response.sendRedirect("../filter/filter_edit.jsp?usage_type_id="+FilterUsageType.CONTENT+"&logic_id="+logicID+(parentContID!=null?"&parent_cont_id="+parentContID:"")+(destFilterID!=null?"&filter_id="+destFilterID:"")+extraRedirectParams);
		}
		else if (iMethod != METHOD_SAVE)
		{
			response.sendRedirect("logic_block_edit.jsp?logic_id="+logicID+(parentContID!=null?"&parent_cont_id="+parentContID:"")+extraRedirectParams);
		}
		else
		{
%>
<HTML>
<HEAD>
<title>Logic Block: Save</title>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>
<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Logic Block:</b> <%= (iActionSave==SAVE_AS_NEW)?"Cloned":"Saved" %></td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<b>The logic block was <%= (iActionSave==SAVE_AS_NEW)?"cloned":"saved" %>.</b>
						<P align="center"><a href="logic_block_list.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>">Back to List</a></P>
<%
			if ( parentContID != null )
			{
%>
						<P align="center"><a href="cont_edit.jsp?cont_id=<%= parentContID %><%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>">Back to Content</a></P>
<%
			}
%>
						<P align="center"><a href="logic_block_edit.jsp?logic_id=<%= logicID %><%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>"><%= (iActionSave==SAVE_AS_NEW)?"Edit New Copy":"Back to Edit" %></a></P>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
</BODY>
</HTML>
<%		
		}
	}
	catch(Exception ex)
	{
		ErrLog.put(this,ex,"logic_block_save.jsp",out,1);
	}
%>

