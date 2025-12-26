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
        cal.setTimeZone(timeZone2);
        
        if(sSelectedDate != null)
        {
            java.util.Date dSelectedDate = null;
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
            dSelectedDate = sdf.parse(sSelectedDate);
            cal.setTime(dSelectedDate);
        }
        return cal;
    }

    private static String getTimeZone(String sSelectedZone)
        throws Exception
    {
        StringWriter sw = new StringWriter();
        sw.write("<OPTION value=Europe/Istanbul selected>GMT +3:00 Europe/Istanbul</OPTION>\r\n");
        sw.write("<OPTION value=US/Eastern>GMT +5:00 US/Eastern</OPTION>\r\n");
        return sw.toString();
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
        sw.write("<OPTION value=0" + (nSelectedHour != 0 ? "" : " selected") + ">Midnight</OPTION>\r\n");
        sw.write("<OPTION value=1" + (nSelectedHour != 1 ? "" : " selected") + ">1:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=2" + (nSelectedHour != 2 ? "" : " selected") + ">2:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=3" + (nSelectedHour != 3 ? "" : " selected") + ">3:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=4" + (nSelectedHour != 4 ? "" : " selected") + ">4:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=5" + (nSelectedHour != 5 ? "" : " selected") + ">5:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=6" + (nSelectedHour != 6 ? "" : " selected") + ">6:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=7" + (nSelectedHour != 7 ? "" : " selected") + ">7:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=8" + (nSelectedHour != 8 ? "" : " selected") + ">8:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=9" + (nSelectedHour != 9 ? "" : " selected") + ">9:00 AM</OPTION>\r\n");
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

/*
    private static String getHalfHourOptionsHtml(String sSelectedDate)
        throws Exception
    {
		Calendar c = getCalendar(sSelectedDate);
		int nMinutes = (c.get(Calendar.HOUR_OF_DAY) * 60 + c.get(Calendar.MINUTE));
		int nHalfHour = nMinutes / 30;
        return getHalfHourOptionsHtml(nHalfHour);
    }

    private static String getHourOptionsHtml_(int nSelectedHour)
    {
        StringWriter sw = new StringWriter();
        sw.write("<OPTION value=00:00" + (nSelectedHour != 0 ? "" : " selected") + ">Midnight</OPTION>\r\n");
        sw.write("<OPTION value=01:00" + (nSelectedHour != 1 ? "" : " selected") + ">1:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=02:00" + (nSelectedHour != 2 ? "" : " selected") + ">2:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=03:00" + (nSelectedHour != 3 ? "" : " selected") + ">3:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=04:00" + (nSelectedHour != 4 ? "" : " selected") + ">4:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=05:00" + (nSelectedHour != 5 ? "" : " selected") + ">5:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=06:00" + (nSelectedHour != 6 ? "" : " selected") + ">6:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=07:00" + (nSelectedHour != 7 ? "" : " selected") + ">7:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=08:00" + (nSelectedHour != 8 ? "" : " selected") + ">8:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=09:00" + (nSelectedHour != 9 ? "" : " selected") + ">9:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=10:00" + (nSelectedHour != 10 ? "" : " selected") + ">10:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=11:00" + (nSelectedHour != 11 ? "" : " selected") + ">11:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=12:00" + (nSelectedHour != 12 ? "" : " selected") + ">Noon</OPTION>\r\n");
        sw.write("<OPTION value=13:00" + (nSelectedHour != 13 ? "" : " selected") + ">1:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=14:00" + (nSelectedHour != 14 ? "" : " selected") + ">2:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=15:00" + (nSelectedHour != 15 ? "" : " selected") + ">3:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=16:00" + (nSelectedHour != 16 ? "" : " selected") + ">4:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=17:00" + (nSelectedHour != 17 ? "" : " selected") + ">5:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=18:00" + (nSelectedHour != 18 ? "" : " selected") + ">6:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=19:00" + (nSelectedHour != 19 ? "" : " selected") + ">7:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=20:00" + (nSelectedHour != 20 ? "" : " selected") + ">8:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=21:00" + (nSelectedHour != 21 ? "" : " selected") + ">9:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=22:00" + (nSelectedHour != 22 ? "" : " selected") + ">10:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=23:00" + (nSelectedHour != 23 ? "" : " selected") + ">11:00 PM</OPTION>\r\n");
        return sw.toString();
    }

    private static String getHalfHourOptionsHtml_(int nSelectedHalfHour)
    {
		nSelectedHalfHour = nSelectedHalfHour * 5;
        StringWriter sw = new StringWriter();
        sw.write("<OPTION value=00:00" + (nSelectedHalfHour != 0 ? "" : " selected") + ">Midnight</OPTION>\r\n");
        sw.write("<OPTION value=00:30" + (nSelectedHalfHour != 5 ? "" : " selected") + ">12:30 AM</OPTION>\r\n");
        sw.write("<OPTION value=01:00" + (nSelectedHalfHour != 10 ? "" : " selected") + ">1:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=01:30" + (nSelectedHalfHour != 15 ? "" : " selected") + ">1:30 AM</OPTION>\r\n");
        sw.write("<OPTION value=02:00" + (nSelectedHalfHour != 20 ? "" : " selected") + ">2:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=02:30" + (nSelectedHalfHour != 25 ? "" : " selected") + ">2:30 AM</OPTION>\r\n");
        sw.write("<OPTION value=03:00" + (nSelectedHalfHour != 30 ? "" : " selected") + ">3:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=03:30" + (nSelectedHalfHour != 35 ? "" : " selected") + ">3:30 AM</OPTION>\r\n");
        sw.write("<OPTION value=04:00" + (nSelectedHalfHour != 40 ? "" : " selected") + ">4:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=04:30" + (nSelectedHalfHour != 45 ? "" : " selected") + ">4:30 AM</OPTION>\r\n");
        sw.write("<OPTION value=05:00" + (nSelectedHalfHour != 50 ? "" : " selected") + ">5:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=05:30" + (nSelectedHalfHour != 55 ? "" : " selected") + ">5:30 AM</OPTION>\r\n");
        sw.write("<OPTION value=06:00" + (nSelectedHalfHour != 60 ? "" : " selected") + ">6:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=06:30" + (nSelectedHalfHour != 65 ? "" : " selected") + ">6:30 AM</OPTION>\r\n");
        sw.write("<OPTION value=07:00" + (nSelectedHalfHour != 70 ? "" : " selected") + ">7:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=07:30" + (nSelectedHalfHour != 75 ? "" : " selected") + ">7:30 AM</OPTION>\r\n");
        sw.write("<OPTION value=08:00" + (nSelectedHalfHour != 80 ? "" : " selected") + ">8:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=08:30" + (nSelectedHalfHour != 85 ? "" : " selected") + ">8:30 AM</OPTION>\r\n");
        sw.write("<OPTION value=09:00" + (nSelectedHalfHour != 90 ? "" : " selected") + ">9:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=09:30" + (nSelectedHalfHour != 95 ? "" : " selected") + ">9:30 AM</OPTION>\r\n");
        sw.write("<OPTION value=10:00" + (nSelectedHalfHour != 100 ? "" : " selected") + ">10:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=10:30" + (nSelectedHalfHour != 105 ? "" : " selected") + ">10:30 AM</OPTION>\r\n");
        sw.write("<OPTION value=11:00" + (nSelectedHalfHour != 110 ? "" : " selected") + ">11:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=11:30" + (nSelectedHalfHour != 115 ? "" : " selected") + ">11:30 AM</OPTION>\r\n");
        sw.write("<OPTION value=12:00" + (nSelectedHalfHour != 120 ? "" : " selected") + ">Noon</OPTION>\r\n");
        sw.write("<OPTION value=12:30" + (nSelectedHalfHour != 125 ? "" : " selected") + ">12:30 PM</OPTION>\r\n");
        sw.write("<OPTION value=13:00" + (nSelectedHalfHour != 130 ? "" : " selected") + ">1:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=13:30" + (nSelectedHalfHour != 135 ? "" : " selected") + ">1:30 PM</OPTION>\r\n");
        sw.write("<OPTION value=14:00" + (nSelectedHalfHour != 140 ? "" : " selected") + ">2:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=14:30" + (nSelectedHalfHour != 145 ? "" : " selected") + ">2:30 PM</OPTION>\r\n");
        sw.write("<OPTION value=15:00" + (nSelectedHalfHour != 150 ? "" : " selected") + ">3:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=15:30" + (nSelectedHalfHour != 155 ? "" : " selected") + ">3:30 PM</OPTION>\r\n");
        sw.write("<OPTION value=16:00" + (nSelectedHalfHour != 160 ? "" : " selected") + ">4:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=16:30" + (nSelectedHalfHour != 166 ? "" : " selected") + ">4:30 PM</OPTION>\r\n");
        sw.write("<OPTION value=17:00" + (nSelectedHalfHour != 170 ? "" : " selected") + ">5:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=17:30" + (nSelectedHalfHour != 175 ? "" : " selected") + ">5:30 PM</OPTION>\r\n");
        sw.write("<OPTION value=18:00" + (nSelectedHalfHour != 180 ? "" : " selected") + ">6:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=18:30" + (nSelectedHalfHour != 185 ? "" : " selected") + ">6:30 PM</OPTION>\r\n");
        sw.write("<OPTION value=19:00" + (nSelectedHalfHour != 190 ? "" : " selected") + ">7:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=19:30" + (nSelectedHalfHour != 195 ? "" : " selected") + ">7:30 PM</OPTION>\r\n");
        sw.write("<OPTION value=20:00" + (nSelectedHalfHour != 200 ? "" : " selected") + ">8:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=20:30" + (nSelectedHalfHour != 205 ? "" : " selected") + ">8:30 PM</OPTION>\r\n");
        sw.write("<OPTION value=21:00" + (nSelectedHalfHour != 210 ? "" : " selected") + ">9:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=21:30" + (nSelectedHalfHour != 215 ? "" : " selected") + ">9:30 PM</OPTION>\r\n");
        sw.write("<OPTION value=22:00" + (nSelectedHalfHour != 220 ? "" : " selected") + ">10:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=22:30" + (nSelectedHalfHour != 225 ? "" : " selected") + ">10:30 PM</OPTION>\r\n");
        sw.write("<OPTION value=23:00" + (nSelectedHalfHour != 230 ? "" : " selected") + ">11:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=23:30" + (nSelectedHalfHour != 235 ? "" : " selected") + ">11:30 PM</OPTION>\r\n");
        return sw.toString();
    }
*/
%>

