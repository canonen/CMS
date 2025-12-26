<%
private java.util.Locale getLocaleBasingOnRequest(HttpServletRequest request) {
    java.util.Enumeration<Locale> locales = request.getLocales();

    java.util.Locale ret = Locale.ENGLISH;
    while(locales.hasMoreElements()) {
        ret = locales.nextElement();

        if(ret == Locale.ENGLISH) {
            ret = Locale.ENGLISH;
            return ret;
        } else if (ret == Locale.FRANCE) {
            ret = Locale.FRENCH;
            return ret;
        } else if (ret == Locale.ITALY) {
            ret = Locale.ITALIAN;
            return ret;
        }
    }

    return ret;
}
%>

<%
Locale locale = getLocaleBasingOnRequest(request);
java.util.ResourceBundle lang = java.util.ResourceBundle.getBundle("language", locale);
%>