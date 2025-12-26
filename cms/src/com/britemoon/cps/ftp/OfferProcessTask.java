package com.britemoon.cps.ftp;

import java.lang.Integer;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Vector;
import java.util.regex.Pattern;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

import org.apache.log4j.Logger;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

import com.britemoon.cps.Feature;
import com.britemoon.cps.FileType;
import com.britemoon.cps.ObjectType;
import com.britemoon.cps.XmlUtil;
import com.britemoon.cps.BriteTaskGeneric;
import com.britemoon.cps.BriteTimerGeneric;
import com.britemoon.cps.BriteTimer;
import com.britemoon.cps.BriteTask;
import com.britemoon.cps.ConnectionPool;
import com.britemoon.cps.Customer;
import com.britemoon.cps.Registry;
import com.britemoon.cps.adm.CustFeature;
import com.britemoon.cps.ctl.CategortiesControl;
import com.britemoon.cps.ctm.Offer;
import com.britemoon.cps.ctm.OfferHyatt;
import com.britemoon.cps.ftp.FtpTask;

/**
 * Unzips an offer zip file and then uses the data in each extracted file to create ctm_offers.
 * An offer consists of one xml file containing offer data, and one associated image file.
 * Presently the offer module is written for Hyatt and so each offer.zip will three files.
 * The xml file will contain information for one small-sized offer and one large-sized offer.
 * There will be 2 images files in the zip file, one small image for this offer and one large image for this offer.
 * 
 * @author lwilson
 * @param sFileID  the fileid of the zip file in cft_ftp_file
 * @param sTaskID  the taskID 
 * @param sZipLocalFileName cft_ftp_file.file_name_local 
 * @param sZipRemoteFileName cftp_ftp_file.file_name_remote
 *
 */
public class OfferProcessTask extends BriteTask {
	private  String m_sTaskID = null;
	private  String m_sZipFileID = null;
	private  String m_sZipLocalFileName = null;
	private  String m_sZipRemoteFileName = null;
	private  Date m_dDate = null;
	private  String m_sLocalDir = null;
	private  String m_sFileAndPath =null;
	private  String m_sFileUrl =null;
	private  String m_sImageFilePath = null;
	private  String m_sImageUrl = null;
	private static Logger logger = Logger.getLogger(OfferProcessTask.class.getName());

	public OfferProcessTask(String sFileID, String sTaskID, String sZipLocalFileName, String sZipRemoteFileName) throws Exception
	{
		
		init(sFileID, sTaskID, sZipLocalFileName, sZipRemoteFileName);
	}

	private void init(String sFileID, String sTaskID, String sZipLocalFileName, String sZipRemoteFileName)
	{
		setTaskName("OfferProcessTask");
		try {
			FtpTask ftpTask = new FtpTask(sTaskID);
			setCustId(ftpTask.s_cust_id);
		} catch (Exception e) {
			logger.error("No FtpTask for task_id " + sTaskID);
		}
		
		setIdName("task_id");
		setId(m_sTaskID);
		setCreateDate(new java.util.Date());
		
		m_sTaskID = sTaskID;
		m_sZipFileID = sFileID;
		m_sZipLocalFileName = sZipLocalFileName;
		m_sZipRemoteFileName = sZipRemoteFileName;
		m_dDate = new java.util.Date();
	}

	public void start() throws Exception
	{
		String sMsg =
			"OfferProcessTask: zip file_id = "+ m_sZipFileID + " task_id= " + m_sTaskID + " date='" + m_dDate + "'";
		String sErrors = null;
		try
		{
			logger.info(sMsg + " started");
			FtpTask ftpTask = new FtpTask(m_sTaskID);

			m_sLocalDir = Registry.getKey("import_data_dir");
			m_sImageFilePath = Registry.getKey("img_file_path") + ftpTask.s_cust_id + "\\";
			m_sImageUrl = Registry.getKey("img_url_path") + ftpTask.s_cust_id + "/";
			int numFilesInOfferZip = unzipOffer(m_sZipFileID, m_sZipLocalFileName , m_dDate);
			if (numFilesInOfferZip == 3) {
				sErrors = LoadOffer(m_sZipFileID, m_sZipLocalFileName, ftpTask.s_cust_id);
			}
			else {
				logger.error(sMsg + "offer zip file did not contain 3 files");
			}
			if (sErrors == null) {
				logger.info(sMsg + " finished");
			} else {
				logger.error(sMsg + " finished with Errors: " + sErrors);
			}
		}
		catch(Exception ex)
		{
			logger.info(sMsg + " finished WITH ERROR: " + sErrors);
			logger.error("Exception: ", ex);
		}
	}

	private int unzipOffer(String sZipFileID, String sLocalFileName, java.util.Date dDate4ImportName) throws Exception {
		int DEFAULT_TOTAL_FILE_SIZE_LIMIT = 10240000;	//default total file size limit = 10 Meg
		int numFilesInOfferZip = 0; 
		int numXMLFilesInZip = 0;
		int numImageFilesInZip = 0;
		int BUFFER = 2048;
		boolean bOfferFileIsCorrect = false;
		String ftpFileErrorMsg  = null;

		boolean bHasXMLFile = false;
		boolean bHasImageFile = false;
		boolean bFileSizeIsCorrect = false;
		FtpFile offerZipFile = new FtpFile(sZipFileID);
		m_sFileAndPath = m_sLocalDir + "\\" + offerZipFile.s_file_name_local;
		m_sFileUrl = m_sLocalDir + offerZipFile.s_file_name_local;

		BufferedOutputStream dest = null;
		BufferedInputStream is = null;
		ZipEntry entry;
		try {
			ZipFile zf = new ZipFile(m_sFileAndPath);

			Enumeration e = zf.entries();
			while (e.hasMoreElements()) 
			{
				entry = (ZipEntry) e.nextElement();
				logger.info("Extracting file from zip: " +entry.getName());
				int idx = entry.getName().lastIndexOf('/');
		        if (idx >= 0) {
					bOfferFileIsCorrect = false;
					ftpFileErrorMsg += " Zip file has directories.  No directories allowed. ";
					break;
				}
				String sOfferFileName = entry.getName();
				is = new BufferedInputStream(zf.getInputStream(entry));
				int count;
				byte data[] = new byte[BUFFER];
				FileOutputStream fos = new FileOutputStream(m_sLocalDir + "\\" +  sOfferFileName);
				dest = new BufferedOutputStream(fos, BUFFER);
				while ((count = is.read(data, 0, BUFFER)) != -1) dest.write(data, 0, count);
				dest.flush();
				dest.close();
				is.close();

				// check file sizes (> 0, max file length)
				File file = new File (m_sLocalDir + "\\" +  sOfferFileName);
				long fileLength = file.length();
				if (fileLength == 0) {
					ftpFileErrorMsg += " File " + m_sLocalDir + "\\" +  sOfferFileName + " has zero length.";
					bFileSizeIsCorrect = false;
				} else if (fileLength > DEFAULT_TOTAL_FILE_SIZE_LIMIT  ) {
					ftpFileErrorMsg += " File size for " + m_sLocalDir + "\\" +  sOfferFileName + " is greater than 10MB.";
					bFileSizeIsCorrect = false;
				} else{
					bFileSizeIsCorrect = true;
				}
				numFilesInOfferZip++;


//				Get file type
				int nTypeID = getFileType(sOfferFileName);
				//Insert row in cftp_offer_file table to mark which files the offer zip file extracted.

				FtpOfferFile offerFile = new FtpOfferFile();
				offerFile.s_original_file_id = sZipFileID;
				offerFile.s_offer_file_id = Integer.toString(numFilesInOfferZip);
				offerFile.s_type_id = Integer.toString(nTypeID);
				offerFile.s_offer_file_name = sOfferFileName;
				offerFile.s_offer_file_path = m_sLocalDir + sOfferFileName;
				offerFile.save();

				if (nTypeID == FileType.XML_FILE) {
					bHasXMLFile = true;
					numXMLFilesInZip++;
				}
				else if (nTypeID == FileType.IMAGE) { 
					bHasImageFile = true;
					numImageFilesInZip++;
				}
			} 

			// after all files in the offer zip file are examined check to see if the zip contains
			// one xml file, and 2 image files.

			if ((!bHasXMLFile) || (numXMLFilesInZip != 1)) {
				ftpFileErrorMsg += " Offer Zip File " + sLocalFileName + " must have one xml file.";
				bOfferFileIsCorrect = false;
			}
			else if (!bHasImageFile) {
				ftpFileErrorMsg += " Offer Zip File " + sLocalFileName + " missing Image files.";
				bOfferFileIsCorrect = false;
			}
			else if (numImageFilesInZip != 2) {
				ftpFileErrorMsg += " Offer Zip File " + sLocalFileName + " must have one small and one large image file.";
				bOfferFileIsCorrect = false;
			}
			else if (numFilesInOfferZip != 3) {
				ftpFileErrorMsg += " Offer Zip file " + sLocalFileName + " must contain an xml file and 2 image files.";
				bOfferFileIsCorrect = false;
			} 
			else if (!bFileSizeIsCorrect) {
				bOfferFileIsCorrect = false;
			}
			else {
				bOfferFileIsCorrect = true;
			}
		} catch (IOException ioe) {
			throw new Exception ("Unable to find zip file id = " + sZipFileID + " file name = " +  sLocalFileName);
		}

		if ((ftpFileErrorMsg != null)|| (! bOfferFileIsCorrect)){
			offerZipFile.s_error_msg = ftpFileErrorMsg;
			setStatusAndSave(offerZipFile, "7");
		} 
		else{
			setStatusAndSave(offerZipFile, "6");
		}
		return numFilesInOfferZip;
	}

	/**
	 * 
	 * @param sZipFileID  FtpFile.s_file_id
	 * @param sZipFileName  the file name of the zip file
	 * @param sCustID 
	 * @return sErrors  a list of all errors found in the xml file.
	 * @throws Exception
	 */

	private String LoadOffer(String sZipFileID, String sZipFileName, String sCustID)
	throws Exception
	{
		Vector vOfferFiles = new Vector();
		String sErrors = null;
		Offer smallOffer = new Offer();
		Offer largeOffer = new Offer();
		Customer cust = null;
		boolean bIsHyattCustomer = false;
		int numCategories =0;

		cust = new Customer(sCustID);
		bIsHyattCustomer  =  CustFeature.exists(cust.s_cust_id, Feature.HYATT);


		//		=== === ===
		// read offer xml file and load into the offer table and offer_hyatt table.
		// read the two image files and load into the image directory, and write the image
		// url in the offer.
		vOfferFiles = getFtpOfferXMLFile(sZipFileID);
		Iterator lOfferIter = vOfferFiles.iterator();
		while (lOfferIter.hasNext()) {
			HashMap offerFileMap = (HashMap) lOfferIter.next();
			String sFileTypeID = (String) offerFileMap.get("type_id");
			String sOfferFileUrl = (String) offerFileMap.get("offer_file_path");
			String sXMLFileName = (String) offerFileMap.get("offer_file_name");

			int nFileTypeID = Integer.parseInt(sFileTypeID);
			if (nFileTypeID == FileType.XML_FILE) {
				Element eOfferInfo = null;
				InputStream offerInputStream = null;
				try{
					String line = null;
					String xmlString = null;
					StringBuffer buffer = new StringBuffer();
					offerInputStream = (InputStream) new FileInputStream(sOfferFileUrl);
					BufferedReader reader = new BufferedReader(new InputStreamReader(offerInputStream));

					while ((line = reader.readLine()) != null) {
						buffer.append(line); 
					}
					xmlString = buffer.toString();
					eOfferInfo = XmlUtil.getRootElement(xmlString);
					reader.close();

					// read offer xml file and create Offer and OfferHyatt objects.
					//offerInputStream = (InputStream) new FileInputStream(offerFile);	

					// load offer xml file into Offer and OfferHyatt Objects
					// Hyatt requires two offers with the same text content and other attributes; however the headline, teaser text and images 
					// will change size.  When the template calls for an offer, the offer it will accept depends on a tag in the template saying
					// that section will require a small offer or a large offer.
					String sTextContent = XmlUtil.getChildCDataValue(eOfferInfo,"text_content");
					if (sTextContent == null) sErrors += "Errors in Zipfile: "+ sZipFileName + " TextContent is empty. ";
					
					
					NodeList nl = XmlUtil.getChildrenByName(eOfferInfo, "categories");
					numCategories = nl.getLength();
					if (numCategories == 0) sErrors += " No categories for this offer ";
						
					String sOfferName = XmlUtil.getChildTextValue(eOfferInfo, "offer_name");
					String sLastSendDate = XmlUtil.getChildCDataValue(eOfferInfo,"last_mail_date");
					if (sLastSendDate == null) sErrors+= " Last Mail Date is empty. ";
					// check to see that the smallOffer and largeOffer's image file name in the xml file
					// is the same name as each image file's name.
					boolean bSmallImageFileNameSame = false;
					boolean bLargeImageFileNameSame = false;
					String smallImageName = XmlUtil.getChildCDataValue(eOfferInfo,"small_image_file");
					String largeImageName = XmlUtil.getChildCDataValue(eOfferInfo,"large_image_file");
					Vector vOfferImageFiles = getFtpOfferImgFiles(sZipFileID);
					Iterator lImageIter = vOfferImageFiles.iterator();
					while (lImageIter.hasNext()) {
						HashMap offerImageMap = (HashMap) lImageIter.next();
						String imageFileName = (String) offerImageMap.get("offer_file_name");
						if (imageFileName.equalsIgnoreCase(smallImageName)){
							bSmallImageFileNameSame = true;
						}
						if (imageFileName.equalsIgnoreCase(largeImageName)) {
							bLargeImageFileNameSame = true;
						}
					}
					
					if (smallImageName == null) {
						sErrors += " small_image_file name in offer is empty. ";
					} 

					if (largeImageName == null) {
						sErrors += " large_image_file name in offer is empty. ";
					} 
					
					if (! bSmallImageFileNameSame) {
						sErrors += " small_image_file in offer has not the same name as the file name";
					}
					if (! bLargeImageFileNameSame) {
						sErrors += " large_image_file in offer has not the same name as the file name";
					}
					
					// Start creating the offer objects.
					smallOffer.s_cust_id = sCustID;
					smallOffer.s_size_id = "1"; // 1 = This offer contains small image, headline and teaser text
					smallOffer.s_headline_html = XmlUtil.getChildCDataValue(eOfferInfo, "small_headline");
					if (smallOffer.s_headline_html == null) sErrors += " small headline is empty. ";
					smallOffer.s_detail_html = XmlUtil.getChildCDataValue(eOfferInfo, "small_teaser_text");
					if (smallOffer.s_detail_html == null) sErrors += " small teaser text is empty. ";
					
					smallOffer.s_image_url = m_sImageUrl + smallImageName;
					smallOffer.s_detail_text = sTextContent;
					smallOffer.s_name = sOfferName;
					smallOffer.s_last_send_date = sLastSendDate;

					
					largeOffer.s_cust_id = sCustID;
					largeOffer.s_size_id = "2"; // 2 = This offer contains large image and large headline and teaser text
					largeOffer.s_headline_html = XmlUtil.getChildCDataValue(eOfferInfo, "large_headline");
					if (largeOffer.s_headline_html == null) sErrors += " large headline in offer is empty. ";
					largeOffer.s_detail_html = XmlUtil.getChildCDataValue(eOfferInfo, "large_teaser_text");
					if (largeOffer.s_detail_html == null) sErrors += " large teaser text is empty. ";
					
					largeOffer.s_image_url = m_sImageUrl + largeImageName;
					largeOffer.s_detail_text = sTextContent;
					largeOffer.s_name = sOfferName;
					largeOffer.s_last_send_date = sLastSendDate;

					if (sErrors == null) {
						smallOffer.save();
						largeOffer.save();
						
						String[] sCategories;
						Vector vCategories = new Vector();
						// after saving the offers, load the categories for each offer.
						if (numCategories > 0) {
							String sCategoryId = null;
							
							Element el = null;
							//NodeList nl = XmlUtil.getChildrenByName(eOfferInfo, "categories");
							numCategories = nl.getLength();
							for (int i = 0; i < numCategories; i++) {
								el = (Element)nl.item(i);
								NodeList nlCat = XmlUtil.getChildrenByName(el,"category_name");
								int numCats = nlCat.getLength();
								for (int j=0; j < numCats; j++) {
									Element el2 = (Element)nlCat.item(j);
									String sCategoryName = XmlUtil.getTextValue(el2);
									if (sCategoryName != null) {
										sCategoryId = CategortiesControl.getCategoryIdByName(sCustID, sCategoryName);
										if (sCategoryId != null) {
											vCategories.add(sCategoryId);
										}
									}
								}
							}
							
							//sCategories = (String[])vCategories.toArray(new String[0]); 
							vCategories.trimToSize();
							sCategories = (String[])vCategories.toArray(new String[0]); 

							CategortiesControl.saveCategories(sCustID, ObjectType.OFFER, smallOffer.s_offer_id, sCategories);
							CategortiesControl.saveCategories(sCustID, ObjectType.OFFER, largeOffer.s_offer_id, sCategories);
						}
						if (bIsHyattCustomer) {
							// get new offer id from Offer and use the offer_id for OfferHyatt.
							String sBrandCode = XmlUtil.getChildTextValue(eOfferInfo, "brand_code");
							if (sBrandCode == null) sErrors += " brand code is empty. ";
							String sHotelID = XmlUtil.getChildTextValue(eOfferInfo, "hotel_id");
							if (sHotelID == null) sErrors += " hotel id is empty. ";
							String sXMLHotelID = sXMLFileName.substring(16,21);
							if (!sXMLHotelID.equalsIgnoreCase(sHotelID)) sErrors += " hotel id does not match XML file name. ";
							OfferHyatt smallOfferHyatt = new OfferHyatt();
							OfferHyatt largeOfferHyatt = new OfferHyatt();

							smallOfferHyatt.s_cust_id = sCustID;
							smallOfferHyatt.s_offer_id = smallOffer.s_offer_id;
							smallOfferHyatt.s_hotel_id = sHotelID;
							smallOfferHyatt.s_brand_code = sBrandCode;
							smallOfferHyatt.save();
							smallOffer.m_OfferHyatt = smallOfferHyatt;
							
							largeOfferHyatt.s_cust_id = sCustID;
							largeOfferHyatt.s_offer_id = largeOffer.s_offer_id;
							largeOfferHyatt.s_hotel_id = sHotelID;
							largeOfferHyatt.s_brand_code = sBrandCode;
							largeOfferHyatt.save();
							largeOffer.m_OfferHyatt = largeOfferHyatt;
							
						}
					} else {
						logger.info("Errors in Offer File" + sErrors);
					}
				} catch (IOException ioe) {
					logger.error("Error opening OfferInputStream " + sOfferFileUrl + ". Exception: " + ioe);
				}  catch (Exception e) {
					logger.error("Error parsing xml file: "+ sOfferFileUrl + ". Exception: "+ e);
				}
				finally{ 
					offerInputStream.close();
				}

			}
		}
		// Put image files in the image directory 
		if ((sErrors == null ) || (sErrors.length() >  1)) {
			String sCopyErrors = copyFtpOfferImageFiles(sZipFileID);
			if (sCopyErrors != null) {
				sErrors += sCopyErrors;
			}
		}

		// set status of ftpFile to denote if this input file has been sucessfully loaded or not.
		if ((sErrors == null ) || (sErrors.length() >  1)) {
			// mark the zip file as fully loaded and processed.
			FtpFile ff = new FtpFile(sZipFileID);
			setStatusAndSave(ff, "4");
		} else {
			logger.info("Task ID = " + m_sTaskID + ". Errors parsing Offer zip file. FTP File " + m_sZipLocalFileName + " remains unprocessed. " + sErrors);
			//store the errors about the zip file.
			FtpFile ff = new FtpFile(sZipFileID);
			ff.s_error_msg = sErrors;
			setStatusAndSave(ff, "7");
		}
		return sErrors;
	}

	private void setStatusAndSave(FtpFile ff, String sStatusId)
	{
		try
		{
			ff.s_status_id = sStatusId;

			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
			ff.s_finish_date = sdf.format(new java.util.Date());

			ff.save();
		}
		catch(Exception ex)
		{
			logger.error("Exception: ", ex);
		}	
	}

	private int getFileType(String sFileName) throws Exception
	{
		if (Pattern.matches(".*\\.XML\\Z", sFileName.toUpperCase().trim())) return FileType.XML_FILE; //FileType.XML_FILE
		else if (Pattern.matches(".*\\.GIF\\Z", sFileName.toUpperCase().trim())) return FileType.IMAGE; //FileType.IMAGE
		else if (Pattern.matches(".*\\.JPG\\Z", sFileName.toUpperCase().trim())) return FileType.IMAGE; //FileType.IMAGE
		else if (Pattern.matches(".*\\.ZIP\\Z", sFileName.toUpperCase().trim())) return FileType.ZIP; //FileType.ZIP
		else throw new Exception("Unknown File : " + sFileName);					
	}

	private Vector getFtpOfferXMLFile(String sZipFileID) throws Exception{
		Vector vOfferFiles = new Vector();
		ConnectionPool cp = null;
		Connection conn = null;
		Statement stmt = null;
		String sSql = null;
		//select the files which were in the offer zip file.
		cp = null;
		conn = null;
		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("OfferProcessTask.setupImports()");
			stmt = conn.createStatement();

			try 
			{
				sSql = 
					" SELECT original_file_id, offer_file_id, type_id, offer_file_name, offer_file_path " +
					" FROM cftp_ftp_offer_file " +
					" WHERE original_file_id = " + sZipFileID + " AND type_id = " + FileType.XML_FILE +
					" ORDER by type_id desc, offer_file_name desc";
				ResultSet rs = stmt.executeQuery(sSql);
				while (rs.next())
				{
					HashMap offerFileHash = new HashMap();
					offerFileHash.put("original_file_id", rs.getString(1));
					offerFileHash.put("offer_file_id", rs.getString(2));
					offerFileHash.put("type_id", rs.getString(3));
					offerFileHash.put("offer_file_name", rs.getString(4));
					offerFileHash.put("offer_file_path", rs.getString(5));
					vOfferFiles.add(offerFileHash);
				}
				rs.close();
			} catch (Exception ex) { throw ex; }
			finally { if (stmt!=null) stmt.close(); }
		} catch (Exception ex) { throw ex; }
		finally { if (stmt!=null) stmt.close(); }

		return vOfferFiles;
	}

	// copy image files from staging area to image file directory 
	private String copyFtpOfferImageFiles(String sZipFileID) throws Exception {
		String sErrors = null;
		Vector vOfferImageFiles = getFtpOfferImgFiles(sZipFileID);
		Iterator lImageIter = vOfferImageFiles.iterator();
		while (lImageIter.hasNext()) {
			FileInputStream fis = null;
			FileOutputStream fos = null;
			HashMap offerImageMap = (HashMap) lImageIter.next();
			String sFileTypeID = (String) offerImageMap.get("type_id");
			String sOfferFileUrl = (String) offerImageMap.get("offer_file_path");
			String sOfferFileName = (String) offerImageMap.get("offer_file_name");
			int nFileTypeID = Integer.parseInt(sFileTypeID);
			if (nFileTypeID == FileType.IMAGE) {
				try
				{
					// if image directory doesn't exist make the directory.
					File f = new File(m_sImageFilePath);
					if (!f.exists()) {
						f.mkdirs();
					}

					fis = new FileInputStream (sOfferFileUrl);
					fos = new FileOutputStream (m_sImageFilePath + sOfferFileName);

					int byte_;
					while ((byte_ = fis.read ()) != -1)
					fos.write (byte_);
				}
				catch (FileNotFoundException e)
				{
					sErrors = "File " + sOfferFileUrl + " not found";
				}
				catch (IOException e)
				{
					sErrors = "I/O Problem: " + e.getMessage ();
				}
				finally
				{
					if (fis != null)
						try
					{
							fis.close ();
					}
					catch (IOException e)
					{
					}

					if (fos != null)
						try
					{
							fos.close ();
					}
					catch (IOException e)
					{
					}
				}
			}
		}
		
		return sErrors;
	}

	private Vector getFtpOfferImgFiles(String sZipFileID) throws Exception {
		Vector vOfferImageFiles = new Vector();
		ConnectionPool cp = null;
		Connection conn = null;
		Statement stmt = null;
		String sSql = null;
		//select the files which were in the offer zip file.
		cp = null;
		conn = null;
		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("OfferProcessTask.setupImports()");
			stmt = conn.createStatement();

			try 
			{
				sSql = 
					" SELECT original_file_id, offer_file_id, type_id, offer_file_name, offer_file_path " +
					" FROM cftp_ftp_offer_file " +
					" WHERE original_file_id = " + sZipFileID + " AND type_id = " + FileType.IMAGE +
					" ORDER by type_id desc, offer_file_name desc";
				ResultSet rs = stmt.executeQuery(sSql);
				while (rs.next())
				{
					HashMap offerImageHash = new HashMap();
					offerImageHash.put("original_file_id", rs.getString(1));
					offerImageHash.put("offer_file_id", rs.getString(2));
					offerImageHash.put("type_id", rs.getString(3));
					offerImageHash.put("offer_file_name", rs.getString(4));
					offerImageHash.put("offer_file_path", rs.getString(5));
					vOfferImageFiles.add(offerImageHash);
				}
				rs.close();
			} catch (Exception ex) { throw ex; }
			finally { if (stmt!=null) stmt.close(); }
		} catch (Exception ex) { throw ex; }
		finally { if (stmt!=null) stmt.close(); }

		return vOfferImageFiles;
	}
}
	

