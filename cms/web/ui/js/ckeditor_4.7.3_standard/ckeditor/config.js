/**
 * @license Copyright (c) 2003-2017, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.md or http://ckeditor.com/license
 */

CKEDITOR.editorConfig = function( config ) {
	 
 
	config.uiColor = '#f0f0f0';
	config.height = 300;
	config.toolbarCanCollapse = true;
	
	config.pasteFromWordRemoveFontStyles = false;
 	config.pasteFromWordRemoveStyles = false;
 	config.forceSimpleAmpersand = true;

	

	config.fillEmptyBlocks = false;
	config.tabSpaces = 0;

	//preg_replace('/\s&nbsp;\s/i', ' ', $text);

	config.forcePasteAsPlainText = true;
	// config.pasteFromWordRemoveFontStyles = false;
	// config.pasteFromWordRemoveStyles = false;
	// config.forceSimpleAmpersand = true;
	// config.fillEmptyBlocks = false;
	// config.tabSpaces = 0;
	// config.forcePasteAsPlainText = true; 
	
	
	
	
};
