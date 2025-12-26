<%@ page
    import="org.apache.commons.fileupload.*,
             org.apache.commons.fileupload.servlet.ServletFileUpload,
             org.apache.commons.fileupload.disk.DiskFileItemFactory,
             org.apache.commons.io.FilenameUtils,
             java.util.*,
             java.io.File,
             java.util.Date,
             java.text.SimpleDateFormat,
             java.lang.Exception"%>
<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page isThreadSafe="false" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="java.nio.file.Paths" %>
<%@ include file="../header.jsp" %>

<%!
String getSizeString(float sizeInBytes) {
    if (sizeInBytes < 1024)
        return sizeInBytes + " Bytes";
    else if (sizeInBytes < 1024 * 1024)
        return sizeInBytes / 1024 + " KB";
    else
        return sizeInBytes / (1024 * 1024) + " MB";
}
%>

<%
    int maxSize = 1024 * 1024 * 25; // 25 MB
    JsonObject json = new JsonObject();

    List<String> whitelist = new ArrayList<String>(Arrays.asList(
        "pdf", "doc", "docx", "txt", "xls", "xlsx", "zip" , "rar" , "csv" , "mp4" , "jpg" , "png" , "gif" , "jpeg", "html"
    ));

    String path = "C:/Revotas/cms/web/ui/jsp/api/help/admin-file";
    String ticketId = request.getParameter("ticket_id");

    FileItemFactory factory1 = new DiskFileItemFactory();
    ServletFileUpload upload2 = new ServletFileUpload(factory1);
    List<FileItem> uploadItems = null;

    try {
        uploadItems = upload2.parseRequest(request);
    } catch (FileUploadException e) {
        throw new RuntimeException(e);
    }

    for (FileItem uploadItem : uploadItems) {
        if (uploadItem.getName() == null || uploadItem.getName().isEmpty()) {
            continue;
        }

        String fullName = uploadItem.getName();
        String fullFileName = Paths.get(fullName).getFileName().toString();
        long fileSize = uploadItem.getSize();

        if (fileSize < maxSize) {
            File targetPath = new File(path);
            if (targetPath.exists()) {

                if (!fullFileName.contains(".")) {
                    json.put("status_code", "1999");
                    json.put("status_txt", "Invalid file format");
                    out.print(json.toString());
                    out.flush();
                    return;
                }

                try {
                    String fileExtension = fullFileName.substring(fullFileName.lastIndexOf(".") + 1).toLowerCase();

                    if (!whitelist.contains(fileExtension)) {
                        json.put("status_code", "1999");
                        json.put("status_txt", "File type not allowed");
                        out.print(json.toString());
                        out.flush();
                        return;
                    }

                    String fileName = fixTurkishCharacters(fullFileName.substring(0, fullFileName.lastIndexOf(".")));
                    String newFileName = turkishToEnglish(fileName).toUpperCase(Locale.ENGLISH) + "_" + ticketId + "." + fileExtension;

                    File savedFile = new File(targetPath, newFileName);
                    uploadItem.write(savedFile);

                    json.put("status_code", "200");
                    json.put("fileName", newFileName);
                    json.put("fileSize", getSizeString(fileSize));
                    json.put("fileType", uploadItem.getContentType());
                    out.print(json.toString());
                    out.flush();

                } catch (Exception e) {
                    json.put("status_code", "500");
                    json.put("status_txt", "File upload failed: " + e.getMessage());
                    out.print(json.toString());
                    out.flush();
                    return;
                }

            } else {
                json.put("status_code", "1999");
                json.put("status_txt", "Path not found");
                out.print(json.toString());
                out.flush();
            }

        } else {
            json.put("status_code", "1999");
            json.put("status_txt", "File size too large");
            out.print(json.toString());
            out.flush();
        }
    }
%>

<%!
	public  String fixTurkishCharacters(String input) {
		if (input == null) {
			return null;
		}

		String s = input;


		s = s.replace("Ã„Â±", "ı");
		s = s.replace("Ã„ÂŸ", "ğ");
		s = s.replace("Ã„Âž", "Ğ");
		s = s.replace("Ã…ÅŸ", "ş");
		s = s.replace("Ã…Åž", "Ş");
		s = s.replace("ÃƒÂ¼", "ü");
		s = s.replace("ÃƒÂ–", "Ö");
		s = s.replace("ÃƒÂœ", "Ü");
		s = s.replace("ÃƒÂ§", "ç");
		s = s.replace("Ãƒâ€¹", "Ç");

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


        s =s.replace("Ğ" ,"G");
        s =s.replace("ğ" ,"g");
        s =s.replace("İ" ,"I");
        s =s.replace("ı" ,"i");
        s =s.replace("Ş" ,"S");
        s =s.replace("ş" ,"s");

		return s;
	}

    public static String turkishToEnglish(String text) {
		return text.replace("ç", "c")
				.replace("Ç", "C")
				.replace("ğ", "g")
				.replace("Ğ", "G")
				.replace("ı", "i")
				.replace("İ", "I")
				.replace("ö", "o")
				.replace("Ö", "O")
				.replace("ş", "s")
				.replace("Ş", "S")
				.replace("ü", "u")
				.replace("Ü", "U");
	}

%>
