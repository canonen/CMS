////////////////////////////////////
//*******
//START
//System Notification Include
//*******
////////////////////////////////////

var sWrite = "";


sWrite = "<table cellspacing=0 cellpadding=0 width=100% border=0>\n";
sWrite = sWrite + "	<tr>\n";
sWrite = sWrite + "		<td class=listHeading valign=center nowrap align=left>\n";
sWrite = sWrite + "			Revotas continues deliverability enhancements\n";
sWrite = sWrite + "			<br><br>\n";
sWrite = sWrite + "			<table class=main cellpadding=2 cellspacing=1 border=0 width=100%>\n";
sWrite = sWrite + "				<tr>\n";
sWrite = sWrite + "					<td align=left valign=top style=\"padding:10px;\">\n";
sWrite = sWrite + "						Effective: 07.09.04\n";
sWrite = sWrite + "						<br>\n";
sWrite = sWrite + "						<br>\n";
sWrite = sWrite + "						As part of our ongoing deliverability initiative, Revotas will begin setting all Bad Username bouncebacks to a status of Bounceback (i.e. inactive). Setting these email addresses to a status of Bouncedback has a number of benefits, including helping to ensure that your marketing messages are delivered properly, and in a timely manner.\n";
sWrite = sWrite + "						<br>\n";
sWrite = sWrite + "						<br>\n";
sWrite = sWrite + "						Setting Bad Usernames to an inactive status has become an industry standard. Many of the larger Internet Service Providers (EX: AOL & Verizon) require email marketers remove these records from their active mail file immediately or risk being blocked from sending future email.\n";
sWrite = sWrite + "						<br>\n";
sWrite = sWrite + "						<br>\n";
sWrite = sWrite + "						Revotas's current process marks an email address with a status of Bounceback after three bounces are received from three campaigns.  This process remains for all other bounce types besides Bad Usernames.\n";
sWrite = sWrite + "						<br>\n";
sWrite = sWrite + "						<br>\n";
sWrite = sWrite + "						How will this impact your Revotas system?\n";
sWrite = sWrite + "						<ul>\n";
sWrite = sWrite + "							<li>All Bad Username bouncebacks will be set to a status of Bounceback, making their status inactive and preventing them from being part of future campaigns.</li>\n";
sWrite = sWrite + "							<li>The database will become cleaner at an accelerated rate.</li>\n";
sWrite = sWrite + "							<li>Target Group counts may appear lower than expected.</li>\n";
sWrite = sWrite + "							<li>Initially, campaign report bounceback rates may lower.</li>\n";
sWrite = sWrite + "						</ul>\n";
sWrite = sWrite + "						Should you have any questions or comments please feel free to contact your account manager or Revotas Technical Support at 617.326.7386.<br><br>\n";
sWrite = sWrite + "					</td>\n";
sWrite = sWrite + "				</tr>\n";
sWrite = sWrite + "			</table>\n";
sWrite = sWrite + "		</td>\n";
sWrite = sWrite + "	</tr>\n";
sWrite = sWrite + "</table>\n";
sWrite = sWrite + "<br>\n";


document.write(sWrite);

	var sysCookie = document.cookie;

	function getCookie(name)
	{
		var index = sysCookie.indexOf(name + "=");
		if (index == -1) return null;
		index = sysCookie.indexOf("=", index) + 1;
		var endstr = sysCookie.indexOf(";", index);
		if (endstr == -1) endstr = sysCookie.length;
		return unescape(sysCookie.substring(index, endstr));
	}

	// retrieve cookie values
	var not_20040713 = getCookie("not_20040713") || "0";

	var today = new Date();
	var expiry = new Date(today.getTime() + 28 * 24 * 60 * 60 * 1000); // plus 28 days

	function setCookie(name, value)
	{
		if (value != null && value != "")
		document.cookie = name + "=" + escape(value) + "; expires=" + expiry.toGMTString();
		sysCookie = document.cookie;
		not_20040713 = getCookie("not_20040713") || "0";
	}
	
	if (not_20040713 == "0")
	{
		//has not had pop up
		window.open("http://www.Revotas.com/not_20040713.html", "not_20040713", "toolbar=0,location=0,scrollbars=1,directories=0,resizable=1,status=1,menubar=0,width=620,height=620,screenX=100,screenY=100,top=100,left=100");
		setCookie("not_20040713", "yes");
	}

////////////////////////////////////
//*******
//END
//System Notification Include
//*******
////////////////////////////////////