<%--
  Created by IntelliJ IDEA.
  User: Emre CERRAH
  Date: 27.06.2025
  Time: 11:41
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%!
    public String fixTurkishCharacters(String input) {
        return fixTurkishCharacters2(input);
    }

    public String fixTurkishCharacters2(String input) {
        if (input == null) {
            return null;
        }
        String s = input;
        s = s.replace("Ã„Â±", "ı");
        s = s.replace("Ã„Â°", "İ");
        s = s.replace("Ã„ÂŸ", "ğ");
        s = s.replace("Ã„Âž", "Ğ");
        s = s.replace("Ã…ÅŸ", "ş");
        s = s.replace("Å\u009F", "ş");
        s = s.replace("Ã…Åž", "Ş");
        s = s.replace("Å\u009E", "Ş");
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
        s = s.replace("ã§", "ç");
        s = s.replace("Ã‡", "Ç");
        s = s.replace("Ã¶", "ö");
        s = s.replace("Ã–", "Ö");
        s = s.replace("Ã§", "ç");
        s = s.replace("Ã‡", "Ç");
        s = s.replace("Ã\u0087", "Ç");
        s = s.replace("Ã„ÂŸ", "ğ");
        s = s.replace("Ä\u009F", "ğ");
        s = s.replace("Ã„Âž", "Ğ");
        s = s.replace("Ä\u009E", "Ğ");
        s = s.replace("Ã…ÅŸ", "ş");
        s = s.replace("Ã…Åž", "Ş");
        s = s.replace("ÃƒÂ¼", "ü");
        s = s.replace("ã¼", "ü");
        s = s.replace("ÃƒÂœ", "Ü");
        s = s.replace("Ã\u009C", "Ü");
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
%>