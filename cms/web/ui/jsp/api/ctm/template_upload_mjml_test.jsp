<%@ page import="java.io.*, java.nio.charset.StandardCharsets, java.nio.file.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Dosya Upload ve Okuma</title>
</head>
<body>

<%
    // Dosyanın upload edildiği dizin
    String uploadDosyaYolu = request.getParameter("dosyaYolu");

// Dosya upload işlemi
    if (request.getMethod().equalsIgnoreCase("post")) {
        Part dosyaPart = request.getPart("dosya"); // "dosya" parametresi, formdaki dosya input'unun adı

        if (dosyaPart != null) {
            String dosyaAdi = Paths.get(dosyaPart.getSubmittedFileName()).getFileName().toString();
            String dosyaYolu = uploadDosyaYolu + File.separator + dosyaAdi;

            // Dosyayı upload et
            dosyaPart.write(dosyaYolu);

            // Dosyanın içeriğini oku
            Path dosyaPath = Paths.get(dosyaYolu);
            String dosyaIcerik = new String(Files.readAllBytes(dosyaPath), StandardCharsets.UTF_8);

            // Okunan içeriği ekrana yazdır
            out.println("Upload Edilen Dosya İçeriği:<br>" + dosyaIcerik);
        }
    }
%>

<form action="" method="post" enctype="multipart/form-data">
    Dosya Yolu: <input type="text" name="dosyaYolu" /><br/>
    Dosya Seç: <input type="file" name="dosya" /><br/>
    <input type="submit" value="Upload" />
</form>

</body>
</html>
