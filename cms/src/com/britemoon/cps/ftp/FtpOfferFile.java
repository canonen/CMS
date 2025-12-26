package com.britemoon.cps.ftp;

import java.sql.PreparedStatement;
import java.sql.ResultSet;

import org.apache.log4j.Logger;
import org.w3c.dom.Element;

import com.britemoon.cps.XmlUtil;
import com.britemoon.cps.BriteObject;

public class FtpOfferFile extends BriteObject {
//	 === Properties ===

	public String s_original_file_id = null;
	public String s_offer_file_id = null;
	public String s_type_id = null;
	public String s_offer_file_name = null;
	public String s_offer_file_path = null;
	private static Logger logger = Logger.getLogger(FtpOfferFile.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public FtpOfferFile()
	{
	}
	
	public FtpOfferFile(String sOriginalFileId) throws Exception
	{
		s_original_file_id = sOriginalFileId;
		retrieve();
	}

	public FtpOfferFile(Element e) throws Exception
	{
		fromXml(e);
	}

	// === For RCP only ===

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	original_file_id," +		
		"	offer_file_id," +
		"	type_id," +
		"	offer_file_name," +
		"	offer_file_path" +
		" FROM cftp_ftp_offer_file" +
		" WHERE "+
		"	(original_file_id=?) AND" +
		"   (offer_file_id =?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_original_file_id);
		pstmt.setString(2, s_offer_file_id);

		ResultSet rs = pstmt.executeQuery();
		if (rs.next())
		{
			getPropsFromResultSetRow(rs);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	public void getPropsFromResultSetRow(ResultSet rs) throws Exception
	{
		byte[] b = null;
		s_original_file_id = rs.getString(1);
		s_offer_file_id = rs.getString(2);
		s_type_id = rs.getString(3);

		b = rs.getBytes(4);
		s_offer_file_name = (b == null)?null:new String(b,"UTF-8");

		b = rs.getBytes(5);
		s_offer_file_path = (b == null)?null:new String(b,"UTF-8");
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cftp_ftp_offer_file_save" +
		"	@original_file_id=?," +		
		"	@offer_file_id=?," +
		"	@type_id=?," +
		"	@offer_file_name=?," +
		"	@offer_file_path=?" ;

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_original_file_id);
		pstmt.setString(2, s_offer_file_id);
		pstmt.setString(3, s_type_id);

		if(s_offer_file_name == null) pstmt.setString(4, s_offer_file_name);
		else pstmt.setBytes(4, s_offer_file_name.getBytes("UTF-8"));

		if(s_offer_file_path == null) pstmt.setString(5, s_offer_file_path);
		else pstmt.setBytes(5, s_offer_file_path.getBytes("UTF-8"));

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_original_file_id = rs.getString(1);
			s_offer_file_id = rs.getString(2);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cftp_ftp_offer_file" +
		" WHERE" +
		"	(original_file_id=?) AND (offer_file_id = ?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_original_file_id);
		pstmt.setString(2, s_offer_file_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "ftp_offer_file";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_original_file_id != null ) XmlUtil.appendTextChild(e, "original_file_id", s_original_file_id);	
		if( s_offer_file_id != null ) XmlUtil.appendTextChild(e, "offer_file_id", s_offer_file_id);
		if( s_type_id != null ) XmlUtil.appendCDataChild(e, "type_id", s_type_id);
		if( s_offer_file_name != null ) XmlUtil.appendCDataChild(e, "offer_file_name", s_offer_file_name);
		if( s_offer_file_path != null ) XmlUtil.appendTextChild(e, "offer_file_path", s_offer_file_path);
	}
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_original_file_id = XmlUtil.getChildTextValue(e, "original_file_id");	
		s_offer_file_id = XmlUtil.getChildTextValue(e, "offer_file_id");
		s_type_id = XmlUtil.getChildCDataValue(e, "type_id");
		s_offer_file_name = XmlUtil.getChildCDataValue(e, "offer_file_name");
		s_offer_file_path = XmlUtil.getChildTextValue(e, "offer_file_path");
	}

	// === Other Methods ===
}
