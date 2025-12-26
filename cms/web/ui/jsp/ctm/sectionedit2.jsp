<%@ page
	import="org.apache.log4j.*"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.ctm.*"
	import="java.util.*"
	import="java.io.*"
	import="com.oreilly.servlet.multipart.*"
	import="com.oreilly.servlet.multipart.Part"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<jsp:useBean id="tbean" class="com.britemoon.cps.ctm.TemplateBean" scope="session" />
<%
PageBean pbean = (PageBean)session.getAttribute("pbean");

int custID = Integer.parseInt(cust.s_cust_id);
int userID = Integer.parseInt(user.s_user_id);

File f;
long fileLength;
String validExtensions = application.getInitParameter("ValidImageExtensions");

//Have a 1 Meg limit
MultipartParser mp = new MultipartParser(request, 1000000);

//Parts will arrive in the following order:
//section, input1, input2, ..., inputx

Part myPart = mp.readNextPart();
int section = Integer.parseInt(((ParamPart)myPart).getStringValue());
int numInputs = tbean.getNumOrders(section);
//Inputs
String[] vals = new String[numInputs];
String[] keys = new String[numInputs];

String filePath, fileName, link, color, inputType, persValue, offerValue;
boolean alreadyRead = false;
for (int x=0;x<numInputs;++x) {
	if (!alreadyRead) myPart = mp.readNextPart();
	alreadyRead = false;
	inputType = tbean.getInputType(section,x);
	
	if (myPart.isFile()) {
		//Its an image input
		fileName = ((FilePart)myPart).getFileName();
		//If spaces in file name change to _
		fileName = WebUtils.replace(fileName," ","_");
		if (fileName == null) {
			//Get current filename
			fileName = pbean.getOneValue(section,x);
		} else {
			fileName = fileName.toLowerCase();
			if (validExtensions.indexOf(fileName.substring(fileName.lastIndexOf(".")+1)) == -1) {
				//not a valid image extension
				%>
				<h2>Bad Image Extension</h2>
				Valid image extensions are: <b><%= validExtensions %></b><br><br>
				Please back up your browser and fix the image.
				<%
				return;
			} else {
				//write image to images directory
				filePath = application.getInitParameter("ImagePath")+custID+"\\"+pbean.getContentID();
				f = new File(filePath);
				if (!f.exists()) {
					//create directory
					f.mkdirs();
				}
				f = new File(filePath+"\\"+fileName);
				if (!f.exists()) {
					fileLength = ((FilePart)myPart).writeTo(f);			
					if (fileLength == 0) {
						//remove the file
						f.delete();
						//return an error
						%>
						<h2>Bad Image File</h2>
						Image file size is 0 - Make sure the image exists.<br><br>
						Please back up your browser and fix the image file.
						<%
						return;
					}
				}
			}
		}
		vals[x] = fileName;
		myPart = mp.readNextPart();
		if (myPart == null || myPart.isFile() || !(myPart.getName().equals("input"+x))) {
			alreadyRead = true;
		} else {
			//"Don't use image" is checked - so remove the image
			vals[x] = "";
		}
	} else {
		vals[x] = new String(((ParamPart)myPart).getValue(), "UTF-8");
		if (inputType.equalsIgnoreCase("link")) {
			myPart = mp.readNextPart();
			link = ((ParamPart)myPart).getStringValue();
			if (link.length() != 0 && !link.equalsIgnoreCase("http://")) {
				vals[x] += " "+link;

				myPart = mp.readNextPart();
				color = ((ParamPart)myPart).getStringValue().trim().toUpperCase();
				if (color.length() != 0) {
					//Make sure color is in the #XXXXXX format
					if (color.length() != 7 || color.charAt(0) != '#' ||
					    color.charAt(1) > 'F' || color.charAt(1) < '0' ||
					    color.charAt(2) > 'F' || color.charAt(2) < '0' ||
					    color.charAt(3) > 'F' || color.charAt(3) < '0' ||
					    color.charAt(4) > 'F' || color.charAt(4) < '0' ||
					    color.charAt(5) > 'F' || color.charAt(5) < '0' ||
					    color.charAt(6) > 'F' || color.charAt(6) < '0') {

						%>
						<h2>Bad link color "<%= color %>"</h2>
						Must be in RGB hexadecimal format. (i.e. "#FFFFFF")<br><br>
						Please back up your browser and fix the link color.
						<%
						return;
					}
					vals[x] += " "+color;
				}
			} else {
				myPart = mp.readNextPart();
			}
		} else if (inputType.equalsIgnoreCase("pers")) {
			//Need to attach the default value to it
			myPart = mp.readNextPart();
			persValue = new String(((ParamPart)myPart).getValue(), "UTF-8");

			//Might be another input if box is checked to not use 		
			myPart = mp.readNextPart();
			if (myPart == null || myPart.isFile() || !(myPart.getName().equals("input"+x))) {
				alreadyRead = true;
				vals[x] += ";"+persValue;
			} else {
				//"Don't use" is checked - so make the default value = "NULL"
				vals[x] += ";NULL";
			}
		} else if ( inputType.equalsIgnoreCase("bigoffer") ||inputType.equalsIgnoreCase("smalloffer")) {
			//Need to attach the offer id value to it
			myPart = mp.readNextPart();
			offerValue = new String(((ParamPart)myPart).getValue(), "UTF-8");
			//Need to convert byte symbols back to UTF-8
			String offerByteSequence = vals[x];
			String offerUtf8 = WebUtils.convertFromByteSymbolSequence(offerByteSequence);
			vals[x] = offerUtf8;
			keys[x] = offerValue;
		}
	}
}

//Puts vals into page bean
pbean.setSectionValues(section, vals);
pbean.setSectionKeys(section, keys);

//Saves the changes to the database
pbean.save(userID, user.s_user_name, section);

response.sendRedirect("pageedit.jsp?templateID="+tbean.getTemplateID());

%>




