	// VARIABLES
		var on = new Array(6);
		var off = new Array(6);
		var def = new Array(6);
		var imageState = false;
		var SwitchOnItem;
		var SwitchOnTimerID = 0;
		var SwitchOffItem;
		var SwitchOffTimerID = 0;
		var PublicOrd = "0";
		var PublicState = "off";

	// OFF DEFINITIONS
		for (x=0;x<6;x++)
		{
			off[x] = new Image;
		}

		off[1].src = "../images/campaignB.gif";
		off[2].src = "../images/databaseB.gif";
		off[3].src = "../images/contentB.gif";
		off[4].src = "../images/reportingB.gif";
		off[5].src = "../images/setupB.gif";

	// ON DEFINITIONS
		for (x=0;x<6;x++)
		{
			on[x] = new Image;
		}

		on[1].src = "../images/campaignC.gif";
		on[2].src = "../images/databaseC.gif";
		on[3].src = "../images/contentC.gif";
		on[4].src = "../images/reportingC.gif";
		on[5].src = "../images/setupC.gif";

	// DEFAULT DEFINITIONS
		for (x=0;x<6;x++)
		{
			def[x] = new Image;
		}

		def[1].src = "../images/campaignA.gif";
		def[2].src = "../images/databaseA.gif";
		def[3].src = "../images/contentA.gif";
		def[4].src = "../images/reportingA.gif";
		def[5].src = "../images/setupA.gif";

	function cancelIt()
	{
		flipImg("0", "off");
	}

	function flipImg(ord, state)
	{
		if (window.event)
		{
			window.event.cancelBubble = true;
		}
		
		PublicOrd = ord;
		PublicState = state;
		
		if (PublicState == "on")
		{
			SwitchOnTimerID = window.setTimeout(switchNav, 200);
			window.clearTimeout(SwitchOffTimerID);
			SwitchOffTimerID = 0;
		}
		else
		{
			if (PublicOrd != "0")
			{
				if (document.all.item("nav_m" + PublicOrd).contains(window.event.toElement))
				{
					//do nothing
				}
				else
				{
					SwitchOffTimerID = window.setTimeout(cancelIt, 200);
					window.clearTimeout(SwitchOnTimerID);
					SwitchOnTimerID = 0;
				}
			}
			else
			{
				switchNav();
				window.clearTimeout(SwitchOnTimerID);
				SwitchOnTimerID = 0;
			}
		}
	}
	
	function switchNav()
	{
		if (PublicOrd != "" && PublicState != "")
		{
			for (i = 1; i <= 5; i++)
			{
				document.all.item("nav_m" + i).style.display = "none";
				if (document.all.item("img_m" + i).className != "NavImageOn")
				{
					document.all.item("img_m" + i).src = off[i].src;
				}
			}

			if (PublicState == "on")
			{
				document.all.item("nav_m" + PublicOrd).style.display = "";
				if (document.all.item("nav_m" + PublicOrd).className == "SubMenuTableOff")
				{
					document.all.item("img_m" + PublicOrd).src = def[PublicOrd].src;
				}
				else
				{
					document.all.item("img_m" + PublicOrd).src = on[PublicOrd].src;
				}
			}
			else
			{
				//if (document.all.item("nav_contents").contains(window.event.toElement))
				//{
					//do nothing
				//}
				//else
				//{
					for (i = 1; i <= 5; i++)
					{
						if (document.all.item("nav_m" + i).className == "SubMenuTableOff")
						{
							document.all.item("nav_m" + i).style.display = "";
							document.all.item("img_m" + i).src = def[i].src;
						}
					}
				//}
			}
		}
	}

	function gotoFunction()
	{
		self.location = document.wizard.page.options[document.wizard.page.selectedIndex].value;
	}