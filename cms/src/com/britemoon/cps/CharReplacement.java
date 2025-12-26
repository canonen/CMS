package com.britemoon.cps;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import java.util.logging.Logger;
import java.util.regex.*;

public class CharReplacement
{
	private static Logger logger = Logger.getLogger(CharReplacement.class.getName());
	
	public static String cleanChars (String sText) throws Exception 
	{
        if (sText == null) return sText;

		String sResult = sText;
		/*
        System.out.println("Processing ");
        for (int n=0; n < sText.length(); n++) {
            System.out.print(Integer.toString(sText.charAt(n), 16)+ " ");
        }
        System.out.println();
		*/
		ConnectionPool cp = null;
		Connection conn = null;
		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("cleanMSChars()");

			Statement stmt = null;
			try
			{
				stmt = conn.createStatement();
				String sSql = "SELECT char_value, replacement_char"
						+ " FROM ccps_char_replacement";
				ResultSet rs = stmt.executeQuery(sSql);

				while (rs.next())
				{
					int nChar = rs.getInt(1);
					String sReplaceChar = rs.getString(2);
                    //System.out.println(Integer.toString(nChar,16) + " : " + sReplaceChar);
                    if (nChar <= 256) {
						// this covers unicode u+0000 to u+00FF (Basic Latin, Latin-1 Supplement)
						sResult = sResult.replaceAll("\\x"+Integer.toString(nChar,16), sReplaceChar);
					}
					else if (nChar >= 4096)  {
                        // this covers unicode u+1000 to u+hhhh
						sResult = sResult.replaceAll("\\u"+Integer.toString(nChar,16), sReplaceChar);
					}
					else {
                        // this covers unicode u+0100 to u+0hhh
						sResult = sResult.replaceAll("\\u0"+Integer.toString(nChar,16), sReplaceChar);
					}
				}
				rs.close();
			}
			catch(Exception ex) { throw ex; }
			finally { if(stmt != null) stmt.close(); }
		}
		catch(Exception ex) { throw ex; }
		finally { if(conn != null) cp.free(conn); }

		return sResult;

	}

}
