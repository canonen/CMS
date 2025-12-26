package com.britemoon.cps.ctm;

import java.util.*;
import com.britemoon.cps.cnt.*;
import java.io.*;
import java.net.*;
import javax.servlet.http.HttpServletResponse;
import org.apache.log4j.*;

public class WebUtils {
	private static Logger logger = Logger.getLogger(WebUtils.class.getName());

	// Encodes a string for insertion into the SQL Server DB
	// Special Chars:
	//    original		changed to
	//		'				''
	//
	public static String dbEncode (String s) 
	{
		//if null return null
		if (s == null) return null;

		return replace(s, "'", "''");
	}

	// Encodes a string for display in html
	// Special Chars:
	//    original		changed to
	//		"				&#34
	//		'				&#39
	//		<				&lt;
	//		>				&gt;
	//		&				&amp;
	public static String htmlEncode (String s) 
	{
		//if null return null
		if (s == null) return null;

		//Allow for & - to allow foreign characters
		//s = replace(s, "&", "&amp;");  //&
		s = replace(s, "\"", "&#34;");  //"
		s = replace(s, "'", "&#39;");   //'

		//Allowing tags - so these are commented out
		//s = replace(s, "<", "&lt");
		//s = replace(s, ">", "&gt;");

		return s;
	}

	//***old has to be a single char string*** - because StringTokenizer sucks
	public static String replace (String s, String old, String newValue) 
	{
		if (s == null) return null;
		if (s.indexOf(old) == -1) return s;

		StringTokenizer st = new StringTokenizer(s,old,true);
		s = "";
		String temp;
		while (st.hasMoreElements()) {
			temp = (String)st.nextElement();
			if (temp.equals(old)) temp = newValue;

			s += temp;
		}

		return s;
	}

	//Removes all HTML tags (<xxx> and </xxx>) from the string
	public static String removeHTMLtags (String s) 
	{
		int i,j;

		i = s.indexOf("<");
		while (i != -1) {
			j = s.indexOf(">",i);
			if (j == -1) return s;
			if (j+1 >= s.length()) return s;
			s = s.substring(0,i)+s.substring(j+1);
			i = s.indexOf("<");
		}
		return s;
	}

	//Removes all HTML tags (<xxx> and </xxx>) from the string and replace <br> with newline, <p> with two newline
	public static String removeHTMLtags2 (String s)
	{
		int i,j;
		i = s.indexOf("<");
		while (i != -1) {
			j = s.indexOf(">",i);
			if (j == -1) {
				break;
			}
			// replace <br> with single newline, <p> and </p> with double newline
			String tag = null, head = null, tail = null;
			tag  = s.substring(i+1,j).toLowerCase();
			head = s.substring(0,i);
			if (j+1 < s.length()) {
				tail = s.substring(j+1);
			}
			if (tag.equals("br")) {
				s = (head == null ? "" : head) + "\n"   + (tail == null ? "" : tail);
			}
			else if (tag.equals("p")) {
				s = (head == null ? "" : head) + "\n\n" + (tail == null ? "" : tail);
			}
			else if (tag.equals("/p")) {
				s = (head == null ? "" : head) + "\n\n" + (tail == null ? "" : tail);
			}
			else {
				if (!tag.startsWith("a ")) {
					s = (head == null ? "" : head) + (tail == null ? "" : tail);
				}
				else {
					String link = ContLinkScan.scanForOneLink(tag);
					if (link == null) {
						s = (head == null ? "" : head) + (tail == null ? "" : tail);
					}
					else {
						String orig_tag = s.substring(i+1,j);
						int idx = tag.indexOf(link);
						link = orig_tag.substring(idx, idx + link.length());
						// find </a> from tail
						String desc = null;
						if (tail != null) {
							int idx2 = tail.toLowerCase().indexOf("</a>");
							if (idx2 > 0) {
								desc = removeHTMLtags(tail.substring(0, idx2));
								tail = tail.substring(idx2+4); // skip pass </a>
							}
						}
						s = (head == null ? "" : head) + "\n" +	(desc == null ? "" : desc + "\n") + link + "\n" + (tail == null ? "" : tail);
					}
				}
			}
			i = s.indexOf("<");
		}
		// replace &nbsp; with space
		if (s != null) {
			s = s.replaceAll("&nbsp;", " ");
		}
		return s;
	}
		
	// convert (java -> UI)
	public static String convertToByteSymbolSequence(String strSource) 
	{
		StringBuffer strwRow=new StringBuffer();
		char cSymb;
		strSource=strSource.trim();
		for (int i=0;i<strSource.length();i++){
			cSymb=strSource.charAt(i);
			strwRow.append("&#"+(int)cSymb+";");
		};
		return strwRow.toString();
	};
	
	//	Converts a num; sequence to chars (UI/db -> java)
	public static String convertFromByteSymbolSequence(String strSource) throws Exception
	{
		if (strSource.trim().length() > 0)
		{
			StringWriter strwRow = new StringWriter();
			StringTokenizer stSource=new StringTokenizer(strSource, ";");
			String strToken;
			while (stSource.hasMoreTokens()) 
			{
		        strToken=stSource.nextToken();
		        try
		        {
		        	if (strToken.startsWith("&#")) {
		        		strToken = strToken.substring(2);
		        	}
		        	strwRow.write((char) Integer.parseInt(strToken));
		        }
		        catch (Exception ex)
		        {
		        	//System.out.println("invalid input string: " + strToken);
		        }
			};
			return strwRow.toString();
		}
		else
		{
			return "";
		}
	};	
	
	//Copies the images from the old ID to the new ID directory
	public static void copyImages(String imagePath, int oldID, int newID) 
	{
		File fOld = new File(imagePath+oldID);
		File fNew = new File(imagePath+newID);
		File oldFiles[];

		//No images
		if (!fOld.exists()) return;

		//There is at least one image to copy
		fNew.mkdirs();
		oldFiles = fOld.listFiles();
		for (int x=0;x<oldFiles.length;++x) {
			copyImageFile(oldFiles[x], new File(imagePath+newID+"\\"+oldFiles[x].getName()));
		}

	}

	//Copys a file
	//not very efficient - should use a buffered stream
	public static void copyImageFile (File inputFile, File outputFile) 
	{
		try 
		{
			FileInputStream in = new FileInputStream(inputFile);
			FileOutputStream out = new FileOutputStream(outputFile);
			int c;
			while ((c = in.read()) != -1)
				out.write(c);
			in.close();
			out.close();
		} 
		catch (FileNotFoundException e) {}
		catch (IOException ioe) {}
	}

}

