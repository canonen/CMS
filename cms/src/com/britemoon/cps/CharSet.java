package com.britemoon.cps;

import java.io.StringWriter;

final public class CharSet
{
	final public static int	ISO_8859_1	=	1;
	final public static int	ASCII		=	2;
	final public static int	UNICODE		=	3;
	final public static int	ISO_2022_JP	=	4;
	final public static int	ISO_8859_7	=	5;
	final public static int	EUC_CN		=	6;
	final public static int	ISO_2022_KR	=	7;
	final public static int	EUC_KR		=	8;

	// === === ===

	public static String toString(int iCharsetId)
	{
		String sDisplayName = "UNKNOWN";

		switch (iCharsetId)
		{
			case ISO_8859_1:	sDisplayName = "Latin-1"; break;
			case ASCII:			sDisplayName = "ASCII"; break;
			case UNICODE:		sDisplayName = "Unicode"; break;
			case ISO_2022_JP:	sDisplayName = "Japanese JIS"; break;
			case ISO_8859_7:	sDisplayName = "Greek"; break;
			case EUC_CN:		sDisplayName = "Simplified Chinese EUC"; break;
			case ISO_2022_KR:	sDisplayName = "Korean ISO"; break;
			case EUC_KR:		sDisplayName = "Korean EUC"; break;
		}

		return sDisplayName;
	}

	// === === ===

	public static String toHtmlOptions()
	{
		return toHtmlOptions(-1);
	}

	public static String toHtmlOptions(String sSelected)
	{
		int iSelected = -1;
		try	{ iSelected = Integer.parseInt(sSelected); }
		catch(Exception ex) {}
		return toHtmlOptions(iSelected);
	}

	public static String toHtmlOptions(int iSelected)
	{
		StringWriter sw = new StringWriter();

		sw.write("<OPTION value=\"1\"" + ((iSelected == ISO_8859_1)?" selected":"") + ">Latin-1</OPTION>\r\n");
		sw.write("<OPTION value=\"2\"" + ((iSelected == ASCII)?" selected":"") + ">ASCII</OPTION>\r\n");
		sw.write("<OPTION value=\"3\"" + ((iSelected == UNICODE)?" selected":"") + ">Unicode</OPTION>\r\n");
		sw.write("<OPTION value=\"4\"" + ((iSelected == ISO_2022_JP)?" selected":"") + ">Japanese JIS</OPTION>\r\n");
		sw.write("<OPTION value=\"5\"" + ((iSelected == ISO_8859_7)?" selected":"") + ">Greek</OPTION>\r\n");
		sw.write("<OPTION value=\"6\"" + ((iSelected == EUC_CN)?" selected":"") + ">Simplified Chinese EUC</OPTION>\r\n");
		sw.write("<OPTION value=\"7\"" + ((iSelected == ISO_2022_KR)?" selected":"") + ">Korean ISO</OPTION>\r\n");
		sw.write("<OPTION value=\"8\"" + ((iSelected == EUC_KR)?" selected":"") + ">Korean EUC</OPTION>\r\n");

		return sw.toString();
	}
}
