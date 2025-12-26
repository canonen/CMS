package com.britemoon.cps.exp;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.net.URLConnection;

import javax.servlet.http.HttpServletResponse;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.Document;
import org.w3c.tidy.Tidy;
import org.xhtmlrenderer.pdf.ITextRenderer;
import org.xml.sax.SAXException;

import com.lowagie.text.DocumentException;

public class ExportToPDF {
	
	private String urlString;
	private String saveToLocation;
	
	public ExportToPDF() throws IOException {
		
		this.urlString 		= "";
		this.saveToLocation = "pdfreportsza/sample.pdf";
		
	}
	
	public void setUrlString(String url) {
		this.urlString = url;
	}
	
	public String getUrlString() {
		return urlString;
	}

	public String getSaveToLocation() {
		return saveToLocation;
	}
	
	public void createPDF() throws IOException, ParserConfigurationException, SAXException, DocumentException {
		
		// optimized
		ITextRenderer renderer = new ITextRenderer();
		renderer.setDocument(new URL(this.getUrlString()).toString());
        renderer.layout();
        OutputStream os = new FileOutputStream(this.getSaveToLocation());
        renderer.createPDF(os);
        os.close();

		
		/* older revision first try
		 
		URL url				  	= new URL(this.getUrlString());
		URLConnection urlConn 	= url.openConnection();
		InputStream byteStream 	= urlConn.getInputStream();	
		
		Tidy tidy = new Tidy();
		tidy.setXHTML(true);
		
		ByteArrayOutputStream tidyout = new ByteArrayOutputStream();
		
		tidy.parse(byteStream, tidyout);
		
		InputStream tidyIn 		= new ByteArrayInputStream(tidyout.toByteArray()); 
		ITextRenderer renderer 	= new ITextRenderer();	
		
		DocumentBuilderFactory dbf 	= DocumentBuilderFactory.newInstance();
		DocumentBuilder db 	= null;
		Document doc 		= null;
		
		db	= dbf.newDocumentBuilder();
		doc	= db.parse(tidyIn);
		
		renderer.setDocument(doc, null);
		
		OutputStream os = new FileOutputStream(this.getSaveToLocation());
		renderer.layout();
	
		renderer.createPDF(os);
		os.close();
		
		*/

	}

}
