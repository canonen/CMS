<%@ page 
          language="java"
          import="org.apache.log4j.*"
          import="com.britemoon.cps.*"
          import="com.britemoon.cps.ctm.*"
          import="java.util.*" 
          errorPage="../../error_page.jsp"
          contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../../header.jsp"%>
<%@ include file="../../wvalidator.jsp"%>
<jsp:useBean id="tbeans" class="java.util.Hashtable" scope="application" />
<%
//Make sure these are gone
session.removeAttribute("pbean");
session.removeAttribute("tbean");

String isHyatt = (String)session.getAttribute("isHyatt");
if (isHyatt == null || isHyatt.length() == 0) isHyatt = "0";

int numPerPage = 6;
String sNumPerPage = application.getInitParameter("NumTemplatesPerPage");
if (sNumPerPage != null) numPerPage = Integer.parseInt(sNumPerPage);

String isWizard = (String)session.getAttribute("isWizard");
if ("1".equals(isWizard)) {
    numPerPage = 100;
}

String sCurPage = request.getParameter("page");
int curPage, nextPage, prevPage;
if (sCurPage == null)
{
	curPage = 1;
	nextPage = 2;
	prevPage = 0;
}
else
{
	curPage = Integer.parseInt(sCurPage);
	nextPage = curPage + 1;
	prevPage = curPage - 1;
}

int custID = Integer.parseInt(cust.s_cust_id);

TemplateBean tbean;

//No next page if there aren't any more to show
int actualNumTemplates = 0;
for(Enumeration tb = tbeans.elements(); tb.hasMoreElements();)
{
	tbean = (TemplateBean)tb.nextElement();
	if (!tbean.isActive()) continue;
	boolean ok = false;
	if (isHyatt.equals("1"))
	{
		// this is fine because hyatt is in its own CPS otherwise make sure cust's parent cust id = template's cust id	
		ok = (tbean.isGlobal() && (tbean.getCustID() != 0));
	}	
	else
	{
		ok = (tbean.getCustID() == 0);
	}	
	if (ok || tbean.getCustID() == custID || tbean.inChildCustList(custID+"")) ++actualNumTemplates;
}

if (curPage*numPerPage >= actualNumTemplates) nextPage = 0;
%>

<html>
<body>
<head>
<title>Şablon seçiniz</title>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" href="../default.css" TYPE="text/css">
</head>
<body style="margin:0;background-color:#FFFFFF">
		
<a href="index.jsp" class="zbuttons zbuttons-normal zbuttons-black mta5">
	<span class="zicon zicon-white zicon-return"></span>
	<span class="zlabel">İçeriklere Geri Dön</span>
</a>
	
<table cellpadding="0" cellspacing="0" class="p6-table" width="100%">
	<tr>
		<th style="font-size:12px">Şablon Seçin</th>
	</tr>
	<tr>
		<td>Lütfen içeriğinizde kullanmak istediğiniz şablonu seçiniz. HTML kodunuz varsa HTML Editor'ü seçiniz.</td>
	</tr>
	<tr>
		<td  style="border:none;" valign="center" nowrap align="left">
			<% if ((prevPage != 0) || (nextPage != 0)) { %>
			<table class="" cellspacing="0" cellpadding="2" border="0" align="right">
				<tr>
					<td align="center" valign="middle">
						<table class="" cellspacing="0" cellpadding="5" border="0">
							<tr>
							<% if (prevPage != 0) { %>
								<td align="right" valign="middle" nowrap id="prev_page" style="display:inline"><a href="selecttemplate.jsp?page=<%= prevPage %>">< Previous</a></td>
							<% } %>
							<% if (nextPage != 0) { %>
								<td align="right" valign="middle" nowrap id="next_page" style="display:inline"><a href="selecttemplate.jsp?page=<%= nextPage %>">Next ></a></td>
							<% } %>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			&nbsp;
			<br><br><br>
			<% } %>
			<table class="thumb-list" cellspacing="0" cellpadding="0">
				<tr>
					<%
					Vector vKeys = new Vector();
					Enumeration keys = tbeans.keys();

					while (keys.hasMoreElements()) vKeys.add(keys.nextElement());

					Collections.sort(vKeys);
					Iterator sortedKeys = vKeys.iterator();

					int rowCount = 0, count = 0;
					boolean hasOneRow = false;

					int iCount = 0;
					String sClassAppend = "_Alt";

					// skip the ones displayed in previous pages
					int numToSkip = curPage*numPerPage-numPerPage;
					while (numToSkip > 0)
					{
						if (!sortedKeys.hasNext()) break;
						Integer key = (Integer) sortedKeys.next();
						tbean = (TemplateBean)tbeans.get(key);

						if (!tbean.isActive()) continue;
						boolean ok = false;
						if (isHyatt.equals("1"))
						{
							ok = (tbean.isGlobal() && (tbean.getCustID() != 0)); // this is fine because hyatt is in its own CPS otherwise make sure cust's parent cust id = template's cust id
						}	
						else
						{
							ok = (tbean.getCustID() == 0);
						}	
						
						if ( tbean.isActive() && (ok || tbean.getCustID() == custID || tbean.inChildCustList(custID+"")) )
						{
							numToSkip--;
						}
					}

					// display the next page
					while (sortedKeys.hasNext() && count < numPerPage)
					{
						Integer key = (Integer) sortedKeys.next();
						tbean = (TemplateBean)tbeans.get(key);
						boolean ok = false;
						if (isHyatt.equals("1"))
						{
							ok = (tbean.isGlobal() && (tbean.getCustID() != 0)); // this is fine because hyatt is in its own CPS otherwise make sure cust's parent cust id = template's cust id
						}	
						else
						{
							ok = (tbean.getCustID() == 0);
						}	
						if ( tbean.isActive() && (ok || tbean.getCustID() == custID || tbean.inChildCustList(custID+"")) )
						{
							hasOneRow = true;
							++rowCount;
							++count;
							if (rowCount == 6)
							{
								rowCount = 1;
					%>
				</tr>
				<tr>
<%
			if (iCount % 2 != 0) sClassAppend = "_Alt";
			else sClassAppend = "";
			
			++iCount;
		}
		
		String turl = "pageedit.jsp?templateID="+ tbean.getTemplateID();

		if(tbean.getTemplateName().equals("Enter HTML")) 
		{
			turl += "&skipstep=1";
		%>
			<td valign="top" align="center">
				<div style="margin-bottom:5px;font-weight: bold;">HTML Editör</div>
				<div style="border: 1px solid #B5ECFC;background-color:#F3FCFF;border-radius: 3px 3px 3px 3px;padding: 10px;">
					<div style="margin: 6px 0;">
						<img width="100" height="100" border="0" src="../images/HTMLeditor1.png">
					</div>
					<div>						
						<a style="width: 80px;" href="<%=turl%>" class="zbuttons zbuttons-normal zbuttons-light-gray">
							<span class="zicon zicon-black zicon-select"></span>
							<span class="zlabel">Seç</span>
						</a>
					</div>
				</div>
			</td>
		<%
			continue;
		}
		
		%>
			<td valign="top" align="center">
				<div style="margin-bottom:5px;font-weight: bold;"><%= tbean.getTemplateName() %></div>
				<div style="border: 1px solid #DDDDDD;background-color:#F4F4F4;border-radius: 3px 3px 3px 3px;padding: 10px;">
					<div style="margin: 6px 0;">
						<a target="_blank" href="/cctm/ui/images/templates/<%= tbean.getImageURL(1) %>"><img width="100" height="100" border="0" src="/cctm/ui/images/templates/<%= tbean.getImageURL(0) %>"></a>
					</div>
					<div>							
						<a style="width: 80px;" href="<%=turl%>" class="zbuttons zbuttons-normal zbuttons-light-gray">
							<span class="zicon zicon-black zicon-select"></span>
							<span class="zlabel">Seç</span>
						</a>
					</div>
				</div>
			</td>
		<%
	}
}

for (int x=rowCount+1;x<6;++x)
{
	%><td></td><%
}

if (!hasOneRow)
{
	%><td colspan="5" class="listItem_Data">Seçebileceğiniz kampanya bulunmuyor.</td><%
}
%>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
