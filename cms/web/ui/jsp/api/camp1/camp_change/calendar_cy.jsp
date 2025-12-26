<%!
    private static String getYearOptionsHtml(String sSelectedDate)
        throws Exception
    {
        return getYearOptionsHtml(getCalendar(sSelectedDate).get(Calendar.YEAR));
    }

    private static String getMonthOptionsHtml(String sSelectedDate)
        throws Exception
    {
        return getMonthOptionsHtml(getCalendar(sSelectedDate).get(Calendar.MONTH) + 1);
    }

    private static String getDayOptionsHtml(String sSelectedDate)
        throws Exception
    {
        return getDayOptionsHtml(getCalendar(sSelectedDate).get(Calendar.DAY_OF_MONTH));
    }

    private static String getHourOptionsHtml(String sSelectedDate)
        throws Exception
    {
        return getHourOptionsHtml(getCalendar(sSelectedDate).get(Calendar.HOUR_OF_DAY));
    }

    private static GregorianCalendar getCalendar(String sSelectedDate)
        throws Exception
    {
        GregorianCalendar cal = new GregorianCalendar();
        
        TimeZone timeZone2 = TimeZone.getTimeZone("Europe/Istanbul");
        calendar.setTimeZone(timeZone2);
        
        if(sSelectedDate != null)
        {
            java.util.Date dSelectedDate = null;
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
            dSelectedDate = sdf.parse(sSelectedDate);
            cal.setTime(dSelectedDate);
        }
        return cal;
    }

    private static String getYearOptionsHtml(int nSelectedYear)
    {
		GregorianCalendar cal = new GregorianCalendar();
		int currentYear = cal.get(Calendar.YEAR);
        StringWriter sw = new StringWriter();
		nSelectedYear = (nSelectedYear < (currentYear-5))?(currentYear-5):nSelectedYear;
		nSelectedYear = (nSelectedYear > (currentYear+5))?(currentYear+5):nSelectedYear;
		int startYear = (nSelectedYear < (currentYear))?nSelectedYear:(currentYear);
		int endYear = (nSelectedYear > (currentYear+2))?nSelectedYear:(currentYear+2);

        for(int i = startYear; i <= endYear; i++)
            sw.write("<OPTION value=" + i + (i != nSelectedYear ? "" : " selected") + ">" + i + "</OPTION>\r\n");

        return sw.toString();
    }

    private static String getMonthOptionsHtml(int nSelectedMonth)
    {
        StringWriter sw = new StringWriter();
        sw.write("<OPTION value=01" + (nSelectedMonth != 1 ? "" : " selected") + ">January</OPTION>\r\n");
        sw.write("<OPTION value=02" + (nSelectedMonth != 2 ? "" : " selected") + ">February</OPTION>\r\n");
        sw.write("<OPTION value=03" + (nSelectedMonth != 3 ? "" : " selected") + ">March</OPTION>\r\n");
        sw.write("<OPTION value=04" + (nSelectedMonth != 4 ? "" : " selected") + ">April</OPTION>\r\n");
        sw.write("<OPTION value=05" + (nSelectedMonth != 5 ? "" : " selected") + ">May</OPTION>\r\n");
        sw.write("<OPTION value=06" + (nSelectedMonth != 6 ? "" : " selected") + ">June</OPTION>\r\n");
        sw.write("<OPTION value=07" + (nSelectedMonth != 7 ? "" : " selected") + ">July</OPTION>\r\n");
        sw.write("<OPTION value=08" + (nSelectedMonth != 8 ? "" : " selected") + ">August</OPTION>\r\n");
        sw.write("<OPTION value=09" + (nSelectedMonth != 9 ? "" : " selected") + ">September</OPTION>\r\n");
        sw.write("<OPTION value=10" + (nSelectedMonth != 10 ? "" : " selected") + ">October</OPTION>\r\n");
        sw.write("<OPTION value=11" + (nSelectedMonth != 11 ? "" : " selected") + ">November</OPTION>\r\n");
        sw.write("<OPTION value=12" + (nSelectedMonth != 12 ? "" : " selected") + ">December</OPTION>\r\n");
        return sw.toString();
    }

    private static String getDayOptionsHtml(int nSelectedDay)
    {
        StringWriter sw = new StringWriter();
        for(int i = 1; i <= 31; i++)
            sw.write("<OPTION value=" + i + (i != nSelectedDay ? "" : " selected") + ">" + i + "</OPTION>\r\n");

        return sw.toString();
    }

    private static String getHourOptionsHtml(int nSelectedHour)
    {
        StringWriter sw = new StringWriter();
        sw.write("<OPTION value=00" + (nSelectedHour != 0 ? "" : " selected") + ">Midnight</OPTION>\r\n");
        sw.write("<OPTION value=01" + (nSelectedHour != 1 ? "" : " selected") + ">1:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=02" + (nSelectedHour != 2 ? "" : " selected") + ">2:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=03" + (nSelectedHour != 3 ? "" : " selected") + ">3:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=04" + (nSelectedHour != 4 ? "" : " selected") + ">4:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=05" + (nSelectedHour != 5 ? "" : " selected") + ">5:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=06" + (nSelectedHour != 6 ? "" : " selected") + ">6:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=07" + (nSelectedHour != 7 ? "" : " selected") + ">7:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=08" + (nSelectedHour != 8 ? "" : " selected") + ">8:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=09" + (nSelectedHour != 9 ? "" : " selected") + ">9:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=10" + (nSelectedHour != 10 ? "" : " selected") + ">10:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=11" + (nSelectedHour != 11 ? "" : " selected") + ">11:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=12" + (nSelectedHour != 12 ? "" : " selected") + ">Noon</OPTION>\r\n");
        sw.write("<OPTION value=13" + (nSelectedHour != 13 ? "" : " selected") + ">1:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=14" + (nSelectedHour != 14 ? "" : " selected") + ">2:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=15" + (nSelectedHour != 15 ? "" : " selected") + ">3:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=16" + (nSelectedHour != 16 ? "" : " selected") + ">4:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=17" + (nSelectedHour != 17 ? "" : " selected") + ">5:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=18" + (nSelectedHour != 18 ? "" : " selected") + ">6:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=19" + (nSelectedHour != 19 ? "" : " selected") + ">7:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=20" + (nSelectedHour != 20 ? "" : " selected") + ">8:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=21" + (nSelectedHour != 21 ? "" : " selected") + ">9:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=22" + (nSelectedHour != 22 ? "" : " selected") + ">10:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=23" + (nSelectedHour != 23 ? "" : " selected") + ">11:00 PM</OPTION>\r\n");
        return sw.toString();
    }
%>

