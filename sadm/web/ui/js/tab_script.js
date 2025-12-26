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