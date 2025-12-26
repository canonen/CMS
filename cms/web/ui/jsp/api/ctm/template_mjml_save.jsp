<%@page
        language="java"
        contentType="text/html;charset=UTF-8"
        import="java.io.*,java.util.*,java.sql.*"
        import="com.britemoon.*,
        com.britemoon.cps.*,
        com.britemoon.cps.ctm.*,
        com.britemoon.cps.adm.CustFeature"
        import="org.apache.log4j.*"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp" %>

<%! static Logger logger = Logger.getLogger("template_mjml_save.jsp"); %>

<%
    out.println("testteyizz 1");

    ConnectionPool cp = null;
    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection("template_mjml_save.jsp");

        int templateID = Integer.parseInt(request.getParameter("templateID"));
        int custID = Integer.parseInt(request.getParameter("custID"));
        String templateName = request.getParameter("templateName");
        String templateMJML = "";
        String smallImageBase64 = "";
        String largeImageBase64 = "";


        logger.info("templateID: " + templateID);
        logger.info("custID: " + custID);
        logger.info("templateName: " + templateName);


        try{
            Part mjmlPart = request.getPart("templateMJML");
            Part smallImagePart = request.getPart("smallImage");
            Part largeImagePart = request.getPart("largeImage");

        logger.info("templateMjml: " + mjmlPart);
        logger.info("smallImagePart: " + smallImagePart);
        logger.info("largeImagePart: " + largeImagePart);}catch (Exception e){
            e.printStackTrace();
        }

        try (InputStream mjmlInputStream = mjmlPart.getInputStream();
             InputStream smallImageInputStream = smallImagePart.getInputStream();
             InputStream largeImageInputStream = largeImagePart.getInputStream()) {

            // MJML dosyasını oku
            ByteArrayOutputStream mjmlBuffer = new ByteArrayOutputStream();
            byte[] mjmlData = new byte[1024];
            int mjmlLength;
            while ((mjmlLength = mjmlInputStream.read(mjmlData)) != -1) {
                mjmlBuffer.write(mjmlData, 0, mjmlLength);
            }
            templateMJML = mjmlBuffer.toString("UTF-8");

            // Small Image'ı Base64'e çevir
            byte[] smallImageData = new byte[smallImageInputStream.available()];
            smallImageInputStream.read(smallImageData);
            smallImageBase64 = Base64.getEncoder().encodeToString(smallImageData);

            // Large Image'ı Base64'e çevir
            byte[] largeImageData = new byte[largeImageInputStream.available()];
            largeImageInputStream.read(largeImageData);
            largeImageBase64 = Base64.getEncoder().encodeToString(largeImageData);

        logger.info("templateMjmlInputStream: " + templateMjmlInputStream);
        logger.info("smallImageInputStream: " + smallImageInputStream);
        logger.info("largeImageInputStream: " + largeImageInputStream);

        try {
            String sql = "INSERT INTO ctm_templates (template_id, name, customer_id, template_mjml, small_image, large_image, global_flag, active, approval_flag)" +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

            pstmt = conn.prepareStatement(sql);

            // Parametreleri set et
            pstmt.setInt(1, templateID);
            pstmt.setString(2, templateName);
            pstmt.setInt(3, custID);
            pstmt.setBinaryStream(4, templateMjmlInputStream);
            pstmt.setBinaryStream(5, smallImageInputStream);
            pstmt.setBinaryStream(6, largeImageInputStream);
            pstmt.setInt(7, 0); // global_flag
            pstmt.setInt(8, 1); // active
            pstmt.setInt(9, 0); // approval_flag

            out.println("Veriler başarıyla eklendi.");
        }catch(Exception e){
            e.printStackTrace();
            out.println("veritabanina yukleme hatasi...");
        }
        }

        // Sorguyu çalıştır
        int affectedRows = pstmt.executeUpdate();

        if (affectedRows > 0) {
            out.println("Dosyalar başarıyla veritabanına kaydedildi.");
        } else {
            out.println("Dosyaların veritabanına kaydedilmesi sırasında bir hata oluştu.");
        }
    } catch (Exception e) {
        e.printStackTrace();
        logger.error("Hata: " + e.getMessage());
    } finally {
        // Kaynakları serbest bırak
        try {
            if (pstmt != null) pstmt.close();
            if (conn != null) cp.free(conn);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>
