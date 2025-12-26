//**************************************************************** 
// You are free to copy the "Folder-Tree" script as long as you  
// keep this copyright notice: 
// Script found in: http://www.geocities.com/Paris/LeftBank/2178/ 
// Author: Marcelino Alves Martins (martins@hks.com) December '97. 
//**************************************************************** 
 
//Log of changes: 
//       17 Feb 98 - Fix initialization flashing problem with Netscape
//       
//       27 Jan 98 - Root folder starts open; support for USETEXTLINKS; 
//                   make the ftien4 a js file 
//       
// Definition of class Folder 
// ***************************************************************** 

//JRun change log:
//		03 Nov 99 - Added onMouseOver='winStatus(\"" + this.desc + "\"); return true;'
//					for folders and docs
//				  - Added window.defaultStatus = "";
//				  - Added function winStatus( msg ).
//				  - Added "onMouseOver='winStatus(\"\"); return true;'"
//					on <A HREF to hide ugly javascript window status.
//		10 Oct 99 - Appended "CLASS='contentList'" to appropriate areas.
//		01 Oct 99 - Turned on USETEXTLINKS.
//		15 Sep 99 - Appended TARGET=\"content\" so that all nav links
//					go to the content frame on the right
//		12 Jan 00 - Added logic to be able to change icons at the panel level
//					switch( this.desc ) { case "Change Password": (line circa 27)
//		12 Jan 00 - Added "&nbsp;" + this.desc for extra padding in front of the
//					description since we are now trimming the GIFs
//		08 Feb 00 - Moved default status and display function to /includes/JS_functions.js
//		28 Feb 00 - Added support for node level gifs in Item(desc,link), desc split on "^"
//					Folder(desc,href) splits the description on "|" and sets new attribute folderIconType and 
//					propagateChangesInState(folder) now points to jmc_icons and takes folderIconType
//onMouseOver='winStatus(\"a\");'
// ***************************************************************** 

function Folder(folderDescription, hreference, target) //constructor 
{ 
  //constant data
  descTemp_arr = folderDescription .split("|");
  this.desc=descTemp_arr[0];
  // Assign the default icon if none specified
  if( descTemp_arr[1] == null ) {
	this.folderIconType = "iGeneric";
  } else {
	this.folderIconType = descTemp_arr[1];
  }
  //this.desc = folderDescription 
  this.hreference = hreference 
  this.target = target
  this.id = -1   
  this.navObj = 0  
  this.iconImg = 0  
  this.nodeImg = 0  
  this.isLastNode = 0 
 
  //dynamic data 
  this.isOpen = true 
  this.iconSrc = "folder_open.gif"   
  this.children = new Array 
  this.nChildren = 0 
 
  //methods 
  this.initialize = initializeFolder 
  this.setState = setStateFolder 
  this.addChild = addChild 
  this.createIndex = createEntryIndex 
  this.hide = hideFolder 
  this.display = display 
  this.renderOb = drawFolder 
  this.totalHeight = totalHeight 
  this.subEntries = folderSubEntries 
  this.outputLink = outputFolderLink
} 

function setStateFolder(isOpen) 
{ 

  var subEntries 
  var totalHeight 
  var fIt = 0 
  var i=0 
 
  if (isOpen == this.isOpen) 
    return 
 
  if (browserVersion == 2)  
  { 
    totalHeight = 0 
    for (i=0; i < this.nChildren; i++) 
      totalHeight = totalHeight + this.children[i].navObj.clip.height 
      subEntries = this.subEntries() 
    if (this.isOpen) 
      totalHeight = 0 - totalHeight 
    for (fIt = this.id + subEntries + 1; fIt < nEntries; fIt++) 
      indexOfEntries[fIt].navObj.moveBy(0, totalHeight) 
  }  
  this.isOpen = isOpen 
  propagateChangesInState(this) 
} 
 
function propagateChangesInState(folder) 
{
  var i=0 
 
  if (folder.isOpen) 
  { 
    if (folder.nodeImg) 
      if (folder.isLastNode) 
        folder.nodeImg.src = imagePath + "elbow.gif" 
      else 
	  folder.nodeImg.src = imagePath + "elbow.gif" 
    folder.iconImg.src = imagePath + "folder_open.gif" 
    for (i=0; i<folder.nChildren; i++)
      folder.children[i].display()
  } 
  else 
  { 
    if (folder.nodeImg) 
      if (folder.isLastNode) 
        folder.nodeImg.src = imagePath + "elbow.gif" 
      else 
	  folder.nodeImg.src = imagePath + "elbow.gif" 
    folder.iconImg.src = imagePath + "folder_closed.gif"
//	alert(folder.iconImg.src);////////////////////////////////////////////////////////////////
    for (i=0; i<folder.nChildren; i++) 
      folder.children[i].hide() 
  }  
} 
 
function hideFolder() 
{ 
  if (browserVersion == 1 || browserVersion == 3) { 
    if (this.navObj.style.display == "none") 
      return 
    this.navObj.style.display = "none" 
  } else { 
    if (this.navObj.visibility == "hiden") 
      return 
    this.navObj.visibility = "hiden" 
  } 
   
  this.setState(0) 
} 
 
function initializeFolder(level, lastNode, leftSide) 
{ 
var j=0 
var i=0 
var numberOfFolders 
var numberOfDocs 
var nc 
      
  nc = this.nChildren 
   
  this.createIndex() 
 
  var auxEv = "<a>" 
 
  if (level==1) //level 1 folders do not have elbow
    if (lastNode) //the last 'brother' in the children array 
    { 
    	this.renderOb("") 
      this.isLastNode = 1 
    } 
    else 
    { 
    	this.renderOb("") 
      this.isLastNode = 0 
    } 
 
  else if (level>1) 
    if (lastNode) //the last 'brother' in the children array 
    { 
      this.renderOb(leftSide + auxEv + "<img name='nodeIcon" + this.id + "' src='" + imagePath + "elbow.gif' width=14 height=16 border=0></a>") 
      leftSide = leftSide + "<img border=0 src='" +imagePath + "spacer.gif' width=14 height=16>"  
      this.isLastNode = 1 
    } 
    else 
    { 
      this.renderOb(leftSide + auxEv + "<img name='nodeIcon" + this.id + "' src='" +imagePath + "elbow.gif' width=14 height=16 border=0></a>") 
      leftSide = leftSide + "<img src='" + imagePath + "spacer.gif' width=14 height=16 border=0>" 
      this.isLastNode = 0 
    } 
  else 
    this.renderOb("") 
   
  if (nc > 0) 
  { 
//alert(this.nChildren); ///////////////////////////////////////////////////////////////////////////////////////////////////////
    level = level + 1 
    for (i=0 ; i < this.nChildren; i++)  
    { 
      if (i == this.nChildren-1) 
        this.children[i].initialize(level, 1, leftSide) 
      else 
        this.children[i].initialize(level, 0, leftSide) 
      } 
  } 
} 
 
function drawFolder(leftSide) 
{ 
  if (browserVersion == 2) { 
    if (!doc.yPos) 
      doc.yPos=8 
    doc.write("<layer id='folder" + this.id + "' top=" + doc.yPos + " visibility=hiden>") 
  } 
   
  doc.write("<table ") 
  if (browserVersion == 1 || browserVersion == 3) 
    doc.write(" id='folder" + this.id + "' style='position:block;' ") 
  doc.write(" border=0 cellspacing=0 cellpadding=0>") 
  doc.write("<tr><td>") 
  doc.write(leftSide) 
  this.outputLink() 
  doc.write("<img name='folderIcon" + this.id + "' ") 
  doc.write("src='" + imagePath + this.iconSrc+"' width=14 height=16 border=0></a>") 
  doc.write("</td><td valign=middle nowrap CLASS='contentList'>") 
  if (USETEXTLINKS) 
  { 
    this.outputLink() 
    doc.write("" + this.desc + "</a>") 
  } 
  else 
    doc.write("" + this.desc) 
  doc.write("</td>")  
  doc.write("</table>") 
   
  if (browserVersion == 2) { 
    doc.write("</layer>") 
  } 
 
  if (browserVersion == 1) { 
    this.navObj = doc.all["folder"+this.id] 
    this.iconImg = doc.all["folderIcon"+this.id] 
    this.nodeImg = doc.all["nodeIcon"+this.id] 
  } else if (browserVersion == 2) { 
    this.navObj = doc.layers["folder"+this.id] 
    this.iconImg = this.navObj.document.images["folderIcon"+this.id] 
    this.nodeImg = this.navObj.document.images["nodeIcon"+this.id] 
    doc.yPos=doc.yPos+this.navObj.clip.height 
  } else if (browserVersion == 3) {
    this.navObj = document.getElementById("folder"+this.id)
    this.iconImg = doc.images["folderIcon"+this.id]
    this.nodeImg = doc.images["nodeIcon"+this.id]
  }

} 
 
function outputFolderLink() 
{ 
  if (this.hreference) 
  { 
    doc.write("<a href='" + this.hreference + "&jrun_fid=" + this.id + "&jrun_children=" + this.nChildren + "' TARGET='" + this.target + "' onMouseOver='winStatus(\"" + this.desc + "\"); return true;' ")
    if (browserVersion > 0) 
      doc.write("onClick='javascript:clickOnFolder("+this.id+")'") 
    doc.write(">") 
  } 
  else 
    doc.write("<a>") 
} 
 
function addChild(childNode) 
{ 
  this.children[this.nChildren] = childNode 
  this.nChildren++ 
  return childNode 
} 
 
function folderSubEntries() 
{ 
  var i = 0 
  var se = this.nChildren 
 
  for (i=0; i < this.nChildren; i++){ 
    if (this.children[i].children) //is a folder 
      se = se + this.children[i].subEntries() 
  } 
 
  return se 
} 
 
 
// Definition of class Item (a document or link inside a Folder) 
// ************************************************************* 
 
function Item(itemDescription, itemLink, target) // Constructor 
{ 
  // constant data
  descTemp_arr = itemDescription.split("^");
  this.desc=descTemp_arr[0];
  // Assign the default icon if none specified
  if( descTemp_arr[1] == null ) {
	//this.iconSrc = imagePath + "iGenericAttribute.gif";
  } else {
    //this.iconSrc = imagePath + descTemp_arr[1];
  }
  
  //this.desc = itemDescription 
  this.link = itemLink 
  this.id = -1 //initialized in initalize() 
  this.navObj = 0 //initialized in render() 
  this.iconSrc = "node_basic.gif"
// alert('desc= '+this.desc);
  this.initialize = initializeItem 
  this.createIndex = createEntryIndex 
  this.hide = hideItem 
  this.display = display 
  this.renderOb = drawItem 
  this.totalHeight = totalHeight
  this.target = target
} 
 
function hideItem() 
{ 
  if (browserVersion == 1 || browserVersion == 3) { 
    if (this.navObj.style.display == "none") 
      return 
    this.navObj.style.display = "none" 
  } else { 
    if (this.navObj.visibility == "hiden") 
      return 
    this.navObj.visibility = "hiden" 
  }     
} 
 
function initializeItem(level, lastNode, leftSide) 
{  
  this.createIndex() 
 
  if (level>0) 
    if (lastNode) //the last 'brother' in the children array 
    { 
      this.renderOb(leftSide + "<img src='" + imagePath + "elbow.gif' width=14 height=16 border=0>") 
      leftSide = leftSide + "<img src='" +imagePath + "spacer.gif' width=14 height=16  border=0>"  
    } 
    else 
    { 
      this.renderOb(leftSide + "<img src='" + imagePath + "elbow.gif' width=14 height=16 border=0>") 
      leftSide = leftSide + "<img src='" + imagePath + "spacer.gif' width=14 height=16 border=0>" 
    } 
  else 
    this.renderOb("")   
} 
 
function showPopup(url) {
   	var height = 540;
   	var width = 730;
   	var left = (screen.width - width) / 2;
   	var top = (screen.height - height) / 2;
   	var props = "resizable,scrollbars=yes,left=" + left + ",top=" + top + ",width=" + width + ",height=" + height;
   	popupWin = window.open(url,"popup",props);
	popupWin.focus();
}

function drawItem(leftSide) 
{ 
  var popupText = "javascript:showPopup('" + this.link + "');"
  if (browserVersion == 2) 
    doc.write("<layer id='item" + this.id + "' top=" + doc.yPos + " visibility=hiden>") 
     
  doc.write("<table ") 
  if (browserVersion == 1 || browserVersion == 3) 
    doc.write(" id='item" + this.id + "' style='position:block;' ") 
  doc.write(" border=0 cellspacing=0 cellpadding=0>") 
  doc.write("<tr><td>") 
  doc.write(leftSide)
  if(this.target=="popup")  {
	  doc.write("<a href=" + popupText + " onMouseOver='winStatus(\"" + this.desc + "\"); return true;'>")
  }
  else  {
  	doc.write("<a href=" + this.link + " onMouseOver='winStatus(\"" + this.desc + "\"); return true;'>")
  }
  doc.write("<img border=0 id='itemIcon"+this.id+"' ") 
  doc.write("src='"+ imagePath + this.iconSrc+"' width=14 height=16 border=0>") 
  doc.write("</a>") 
  doc.write("</td><td valign=middle nowrap CLASS='contentList'>") 
  if (USETEXTLINKS)  { 
  	if(this.target=="popup")  {
	    doc.write("<a href=" + popupText + " onMouseOver='winStatus(\"" + this.desc + "\"); return true;'>" + this.desc + "</a>")
   	}
   	else  {
   	    doc.write("<a href=" + this.link + " onMouseOver='winStatus(\"" + this.desc + "\"); return true;'>" + this.desc + "</a>")	
   	}
   }
  else 
    doc.write("" + this.desc) 
  doc.write("</table>") 
   
  if (browserVersion == 2) 
    doc.write("</layer>") 
 
  if (browserVersion == 1) { 
    this.navObj = doc.all["item"+this.id] 
    this.iconImg = doc.all["itemIcon"+this.id] 
  } else if (browserVersion == 2) { 
    this.navObj = doc.layers["item"+this.id] 
    this.iconImg = this.navObj.document.images["itemIcon"+this.id] 
    doc.yPos=doc.yPos+this.navObj.clip.height 
  } else if (browserVersion == 3) {
    this.navObj = doc.getElementById("item"+this.id)
    this.iconImg = doc.getElementById("itemIcon"+this.id)
  }  
  
} 
 
 
// Methods common to both objects (pseudo-inheritance) 
// ******************************************************** 
 
function display() 
{ 
  if (browserVersion == 1) 
    this.navObj.style.display = "block" 
  else if (browserVersion == 2) 
    this.navObj.visibility = "show" 
  else if (browserVersion == 3)
    this.navObj.style.display = "block" // other value can be "", but effects size???
} 
 
function createEntryIndex() 
{ 
  this.id = nEntries 
  indexOfEntries[nEntries] = this 
  nEntries++ 
} 
 
// total height of subEntries open 
function totalHeight() //used with browserVersion == 2 
{ 
  var h = this.navObj.clip.height 
  var i = 0 
   
  if (this.isOpen) //is a folder and _is_ open 
    for (i=0 ; i < this.nChildren; i++)  
      h = h + this.children[i].totalHeight() 
 
  return h 
} 
 
 
// Events 
// ********************************************************* 
 
function clickOnFolder(folderId) 
{ 

  var clicked = indexOfEntries[folderId] 
 
  //if (!clicked.isOpen)
  clickOnNode(folderId) 
 
  return  
  
 
  if (clicked.isSelected) 
    return 
} 
 
function clickOnNode(folderId) 
{ 

  var clickedFolder = 0 
  var state = 0 
 
  clickedFolder = indexOfEntries[folderId] 
  state = clickedFolder.isOpen 
 
  clickedFolder.setState(!state) //open<->close  
} 
 
function initializeDocument() 
{ 
  
  if (doc.all) 
    browserVersion = 1 //IE4   
  else 
    if (doc.layers) 
      browserVersion = 2 //NS4 
    else 
      if (document.getElementById)
        browserVersion = 3 //Netscape6
      else 
        browserVersion = 0 //other      
 
  foldersTree.initialize(0, 1, "") 
  foldersTree.display()
  
  if (browserVersion > 0) 
  { 
    
    doc.write("<layer top="+indexOfEntries[nEntries-1].navObj.top+">&nbsp;</layer>") 
 
    // close the whole tree 
    clickOnNode(0) 
    // open the root folder 
    clickOnNode(0) 
    
    //this part only hides the Root Folder
    if (browserVersion == 1 || browserVersion == 3) { 
        if (indexOfEntries[0].navObj.style.display == "none") 
          return 
        indexOfEntries[0].navObj.style.display = "none" 
      } else { 
        if (indexOfEntries[0].navObj.visibility == "hiden") 
          return 
          
        indexOfEntries[0].navObj.visibility = "hiden" 
    } 
  } 
} 
 
// Auxiliary Functions for Folder-Treee backward compatibility 
// ********************************************************* 
 
function gFld(description, hreference, target) 
{ 
  folder = new Folder(description, hreference, target) 
  return folder 
} 
 
function gLnk(target, description, linkData) 
{ 
  fullLink = "" 
 
  if (target==0) 
  { 
    fullLink = "'"+linkData+"' target=\"_top\"" 
  } 
  else 
  { 
    if (target==1) 
       fullLink = "'http://"+linkData+"' target=_blank" 
    
    else 
       fullLink = "'"+linkData+"' target='" + target + "'"
  } 
  if(target=="popup")  { 	
	  linkItem = new Item(description, linkData, target)
  }
  else  {
  	linkItem = new Item(description, fullLink, target)
  }
  return linkItem 
} 
 
function insFld(parentFolder, childFolder) 
{ 
  return parentFolder.addChild(childFolder) 
} 
 
function insDoc(parentFolder, document) 
{ 
  parentFolder.addChild(document) 
} 
 
// Global variables 
// **************** 
 
USETEXTLINKS = 1
indexOfEntries = new Array 
nEntries = 0 
doc = document 
browserVersion = 0 
selectedFolder=0
imagePath = ""

