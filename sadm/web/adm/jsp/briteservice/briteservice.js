	function document.onselectstart()
	{
		var s = event.srcElement.tagName;
		var sElem = event.srcElement;
		var pElem = sElem;

		while (pElem.tagName != "TD" && pElem.tagName != "BODY")
		{
			pElem = pElem.parentElement;
		}

		if (s != "INPUT" && s != "TEXTAREA" && pElem.id != "IPtextBox" && pElem.className != "canSelect")
		{
			event.returnValue = false;
		}
	}

	function document.ondragstart()
	{
		event.returnValue = false;
	}

	var userCookie = document.cookie;

	function getCookie(name)
	{
		var index = userCookie.indexOf(name + "=");

		if (index == -1)
		{
			return null;
		}
		index = userCookie.indexOf("=", index) + 1;

		var endstr = userCookie.indexOf(";", index);
		if (endstr == -1)
		{
			endstr = userCookie.length;
		}

		return unescape(userCookie.substring(index, endstr));
	}

	var today = new Date();
	var expDate = new Date(today.getTime() + 28 * 24 * 60 * 60 * 1000);

	function setCookie(cookie, name, value)
	{
		if (value != null && value != "")
		document.cookie = name + "=" + escape(value) + "; expires=" + expDate.toGMTString();
		userCookie = document.cookie;
		cookie = getCookie(name) || "0";
	}
		
	function document.onkeyup()
	{
		var sKeyCode = window.event.keyCode;
		var ddl01 = document.getElementById("cust_list");

		ddl01.onKeyUp(sKeyCode);
	}
	
	function getXMLNodeData(node, tag)
	{
		if (node.selectSingleNode(tag) != null)
		{
			return node.selectSingleNode(tag).text;
		}
		else
		{
			return "";
		}
	}
	
	var curParentRow = null;
	var curLink = null;
	var curRow = null;
		
	function toggleDetails(item_id)
	{
		var oParentRow = document.getElementById("parent_row_" + item_id);
		var oLink = document.getElementById("link_" + item_id);
		var oRow = document.getElementById("row_" + item_id);
		var oTable = document.getElementById("item_list");
		
		if (curParentRow != null && curParentRow != oParentRow)
		{
			curParentRow.className = "dataRow";
			curRow.style.display = "none";
			curLink.innerText = "+";
		}
		
		if (oRow.style.display == "")
		{
			oParentRow.className = "dataRow";
			oRow.style.display = "none";
			oLink.innerText = "+";
		}
		else
		{
			oParentRow.className = "dataRowSel";
			oRow.style.display = "";
			oLink.innerText = "-";
			
			curParentRow = oParentRow;
			curRow = oRow;
			curLink = oLink;
		
			if (oRow.rowIndex >= 3)
			{
				if (oTable.rows(oRow.rowIndex - 2).style.display == "")
				{
					oTable.rows(oRow.rowIndex - 2).scrollIntoView();
				}
				else
				{
					oTable.rows(oRow.rowIndex - 3).scrollIntoView();
				}
			}
		}
	}
	
	function toggleObj(obj, action)
	{
		if (action == "show")
		{
			obj.style.display = "";
		}
		else
		{
			obj.style.display = "none";
		}
	}
	
	function userLogin(co_login, login_name, password)
	{
		
		gotoModulePage('CCPS_Login', '/ccps/ui/jsp/login2.jsp?company=' + co_login + '&login=' + login_name + '&password=' + password);
				
	}
	
	
//////////////////////////////////
// POP UP WINDOW SCRIPTS
//////////////////////////////////

	//creates pop up window
	//uses naming convention: [ModuleName]_[ServerIPAddress]
	//to reuse windows on the same server for the same module
		function gotoSite(destURL, Module)
		{
			var winName = "";
			var modURL = "";
			var modURL2 = "";
			//if (Module != "FedEx25")
			//{
			//	modURL = destURL.substring(7, 19);
			//	modURL2 = modURL.replace(".","").replace(".","").replace(".","").replace(".","");
				winName = Module + "_" + modURL2;
			//}
			var oWin = window.open(destURL,winName,"toolbar=1,location=1,scrollbars=1,directories=1,resizable=1,status=1,menubar=1,width=750, height=600,screenX=100,screenY=10,top=10,left=100");
			oWin.focus();
		}
		
		function gotoSiteSlim(destURL, Module)
		{
			var winName = "";
			var modURL = "";
			var modURL2 = "";
			var oWin = window.open(destURL,winName,"toolbar=0,location=0,scrollbars=0,directories=0,resizable=0,status=0,menubar=0,width=425, height=275,screenX=100,screenY=10,top=10,left=100");
			oWin.focus();
		}

	//looks up module IP Address for a customer
	//and appends the partial URL to pass along to gotoSite()
		function gotoModulePage(Module, PartialURL)
		{
			var destURL = "";
			var useLogin = false;
			var cust_id = document.getElementById("cust_id").value;
			var type_id = document.getElementById("type_id_system_admin").value;

			if (Module == "CCPS_Login")
			{
				Module = "CCPS";
				useLogin = true;
				type_id = document.getElementById("type_id_user_login").value;
			}

			if (document.getElementById("Module_" + Module).value != "0")
			{
				destURL = "http://" + document.getElementById("Module_" + Module).value + PartialURL;
				if (useLogin == true)
				{
					Module = "CCPS_Login";
				}
				
				destURL = "redirect.jsp?cust_id=" + cust_id + "&type_id=" + type_id + "&url=" + encodeURIComponent(destURL);
			
				gotoSite(destURL, Module);
			}
			else
			{
				alert("There is no " + Module + " Module for this Customer.");
			}
		}
	
		
	function switchSteps(tab_id, tab_page_header_id, tab_page_body_id)
	{
		if (tab_id == "" || tab_page_header_id == "" || tab_page_body_id == "") return;

		disable_all_tab_pages(tab_id);
		
		var tab_page_header = eval(tab_page_header_id);
		var tab_page_body = eval(tab_page_body_id);	
		
		tab_page_header.className = "EditTabOn";
		tab_page_body.style.display = "";
	}

	function disable_all_tab_pages(tab_id)
	{
		var tab = eval(tab_id);
		
		for (i=0; i < tab.cells.length; i++)
			if (tab.cells(i).className == "EditTabOn")
				tab.cells(i).className = "EditTabOff";

		for (i=0; i < tab.tBodies.length; i++)
			if (tab.tBodies(i).className == "EditBlock")
				tab.tBodies(i).style.display = "none";
	}