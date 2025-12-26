package com.britemoon.cps;

import java.io.*;
import java.util.*;

final public class HtmlUtil
{
	public static String escape(String s)
	{
		if( s == null ) return "";

		StringWriter sw = new StringWriter();
		char c = 0;
		int n = 0;
		int len = s.length();
		for(int i = 0; i < len; i ++)
		{
			c = s.charAt(i);
			n = c;
			if
			(
				(n == 32)
				||
				((n >= 48)&&(n <= 57))
				||
				((n >= 65)&&(n <= 90))
				||
				((n >= 97)&&(n <= 122))
			) sw.write(c);
			else sw.write("&#" + (int)c + ";");
		}	
		return sw.toString();
	}
	
	public static String getBaseAction (String action)
	{
		String baseAction = "";
		if (action != null && action.length() > 0) {
			int idx = action.indexOf("?");
			if (idx > 0) {
				baseAction = action.substring(0, idx);
			}
		}
		return baseAction;
	}
	
	public static String generateHiddenInputs(String action)
	{
		String hiddenInputs = "";
		if (action != null && action.length() > 0) {
			int idx = action.indexOf("?");
			if (idx > 0) {
				String params = action.substring(idx+1);
				StringTokenizer st = new StringTokenizer(params, "&");
				while (st.hasMoreElements()) {
					String p = st.nextToken();
					int n = p.indexOf("=");
					String name = p.substring(0,n);
					String value = p.substring(n+1);
					if (name != null && value != null) {
						hiddenInputs += "<input type=hidden value='" + value + "' name='" + name + "'>";
					}
				}
			}
		}
		return hiddenInputs;
	}
	
	public static String getPVBaseAction (String action)
	{
		String baseAction = "";
		if (action != null && action.length() > 0) {
			int idx = action.indexOf("?");
			if (idx > 0) {
				baseAction = action.substring(0, idx);
				String params = action.substring(idx+1);
				StringTokenizer st = new StringTokenizer(params, "&");
				while (st.hasMoreElements()) {
					String p = st.nextToken();
					int n = p.indexOf("=");
					String name = p.substring(0,n);
					String value = p.substring(n+1);
					if (name != null && value != null && name.toLowerCase().equals("action")) {
						baseAction += "?action=" + value;
					}
				}
			}
		}
		return baseAction;
	}
	
	public static String generatePVHiddenInputs(String action)
	{
		String hiddenInputs = "";
		if (action != null && action.length() > 0) {
			int idx = action.indexOf("&");
			if (idx > 0) {
				String params = action.substring(idx+1);
				StringTokenizer st = new StringTokenizer(params, "&");
				while (st.hasMoreElements()) {
					String p = st.nextToken();
					int n = p.indexOf("=");
					String name = p.substring(0,n);
					String value = p.substring(n+1);
					if (name != null && value != null && !name.toLowerCase().equals("action")) {
						hiddenInputs += "<input type=hidden value='" + value + "' name='" + name + "'>";
					}
				}
			}
		}
		return hiddenInputs;
	}
}
