<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.ctl.*,
		java.sql.*,java.util.Vector,
		org.w3c.dom.*,org.apache.log4j.*"

%>

<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>

<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page pageEncoding="UTF-8" %>

<%! static Logger logger = null;%>

<%

if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
AccessPermission can = user.getAccessPermission(ObjectType.EXPORT);
boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);


if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

// ********** KU
String		scurPage	= request.getParameter("curPage");
String		samount		= request.getParameter("amount");

int			curPage			= 1;
int			amount			= 0;

curPage		= (scurPage		== null) ? 1 : Integer.parseInt(scurPage);
amount		= (samount==null)? 25 : Integer.parseInt(samount);

boolean isCustom = false;

Statement 		stmt	= null;
ResultSet 		rs		= null; 
ConnectionPool 	cp		= null;
Connection 		conn	= null;

JsonArray exportDataArray = new JsonArray();
try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();

	boolean isDisable = false;
	String		CUSTOMER_ID	= cust.s_cust_id;

	String	sFilename	= "";
	String	sFileUrl	= "";
	String	sFileId		= "";
	String	sStatus		= "";
	int nStatusID = 0;
	int nTypeID = 0;

	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;


			if (sSelectedCategoryId == null || sSelectedCategoryId.equals("0"))
			{
				rs = stmt.executeQuery(
					"SELECT f.file_url, f.export_name, f.file_id, ISNULL(s.display_name, s.status_name),"+
					" ISNULL(f.status_id, "+ExportStatus.COMPLETE+"), f.type_id " +
					"FROM cexp_export_file f, cexp_export_status s " +
					"WHERE cust_id = "+CUSTOMER_ID+
					" AND ISNULL(f.status_id, "+ExportStatus.COMPLETE+") = s.status_id " +
                                        " AND f.type_id<>40 "+
					"ORDER BY file_id DESC");
			}
			else
			{
				rs = stmt.executeQuery(
					"SELECT f.file_url, f.export_name, f.file_id, ISNULL(s.display_name, s.status_name),"+
					" ISNULL(f.status_id, "+ExportStatus.COMPLETE+"), f.type_id " +
					"FROM cexp_export_file f, cexp_export_status s, ccps_object_category c " +
					"WHERE f.cust_id = "+CUSTOMER_ID+
					" AND ISNULL(f.status_id, "+ExportStatus.COMPLETE+") = s.status_id " +
					" AND c.cust_id = "+CUSTOMER_ID+" AND c.type_id = "+ObjectType.EXPORT+
					" AND c.category_id = "+sSelectedCategoryId+" AND c.object_id = f.file_id " +
                                        " AND f.type_id<>40 "+
					"ORDER BY file_id DESC");
			}

			boolean isOne = false;

			String sClassAppend = "";
			int exportCount = 0;

			while (rs.next())
			{
				JsonObject  export = new JsonObject();

				isOne = true;
				sFileUrl  = rs.getString(1);
				sFileId   = rs.getString(3);
				sStatus   = rs.getString(4);
				nStatusID = rs.getInt(5);
				nTypeID = rs.getInt(6);


                String convertFileName = new String(rs.getBytes(2), StandardCharsets.UTF_8);

				export.put("fileUrl",sFileUrl);
				export.put("fileName", fixTurkishCharacters(convertFileName));


				export.put("fileId",sFileId);
				export.put("status",sStatus);
				export.put("statusId",nStatusID);
				export.put("typeId",nTypeID);


				exportDataArray.put(export);



			}
			rs.close();

		out.print(exportDataArray.toString());

	} catch(Exception ex) {
		ErrLog.put(this,ex,"export_list.jsp",out,1);
		return;
	} finally {
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	}


%>
<%!
    public String fixTurkishCharacters(String input) {
        if (input == null) {
            return null;
        }
        String s = fixEncoding(input);
        s = s.replace("Ã„Â±", "ı");
        s = s.replace("Ã„Â°", "İ");
        s = s.replace("Ã„ÂŸ", "ğ");
        s = s.replace("Ã„Âž", "Ğ");
        s = s.replace("Ã…ÅŸ", "ş");
        s = s.replace("Ã…Åž", "Ş");
        s = s.replace("ÃƒÂ¼", "ü");
        s = s.replace("ÃƒÂ–", "Ö");
        s = s.replace("ÃƒÂœ", "Ü");
        s = s.replace("Ãœ", "Ü");
        s = s.replace("ÃƒÂ§", "ç");
        s = s.replace("Ãƒâ€¹", "Ç");
        s = s.replace("Ã\\u2021", "Ç");
        s = s.replace("ÃƒÂ¶", "ö");
        s = s.replace("Ä±", "ı");
        s = s.replace("Ä°", "İ");
        s = s.replace("ÄŸ", "ğ");
        s = s.replace("Äž", "Ğ");
        s = s.replace("ÅŸ", "ş");
        s = s.replace("Åž", "Ş");
        s = s.replace("Ã¼", "ü");
        s = s.replace("Ãœ", "Ü");
        s = s.replace("Ã§", "ç");
        s = s.replace("Ã‡", "Ç");
        s = s.replace("Ã¶", "ö");
        s = s.replace("Ã–", "Ö");
        s = s.replace("Ã§", "ç");
        s = s.replace("Ã‡", "Ç");
        s = s.replace("Ã„ÂŸ", "ğ");
        s = s.replace("Ã„Âž", "Ğ");
        s = s.replace("Ã…ÅŸ", "ş");
        s = s.replace("Ã…Åž", "Ş");
        s = s.replace("ÃƒÂ¼", "ü");
        s = s.replace("ÃƒÂœ", "Ü");
        s = s.replace("ÃƒÂ¶", "ö");
        s = s.replace("ÃƒÂ–", "Ö");
        s = s.replace("Ã„Â±", "ı");
        s = s.replace("Ã„Â°", "İ");
        // Bozuk yer tutucu karakter (replacement char)
        s = s.replace("�", "ö"); // ! Dikkat: hangi harfe denk geldiğine göre ayarlayın
        // Diğer sık gözüken ikili bozulmalar
        s = s.replace("Â±", "ı");
        s = s.replace("Â§", "Ş");
        s = s.replace("Âş", "ş");
        return s;
    }

    public String fixEncoding(String input) {
        try {
            byte[] bytes = input.getBytes("ISO-8859-1");
            return new String(bytes, "UTF-8");
        } catch (Exception e) {
            return input;
        }
    }
%>
