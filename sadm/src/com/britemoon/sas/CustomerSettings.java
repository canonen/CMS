package com.britemoon.sas;

import com.britemoon.*;
import com.britemoon.cps.XmlUtil;
import java.sql.*;
import org.w3c.dom.*;
import org.apache.log4j.Logger;

public class CustomerSettings extends BriteObject {

    // === Properties ===
    public String s_id = null;
    public String s_cust_id = null;
    public String s_industry = null;
    public String s_tax_location = null;
    public String s_tax_id = null;
    public String s_country = null;
    public String s_language = null;
    public String s_time_zone = null;
    public String s_currency = null;
    public String s_format = null;
    public String s_display_sample = null;
    public String s_active = null;
    public String s_search_text = null;

    // log4j
    private static Logger logger = Logger.getLogger(CustomerSettings.class.getName());

    // === Constructors ===
    public CustomerSettings() {}

    public CustomerSettings(String id) throws Exception {
        s_id = id;
        retrieve();
    }

    public CustomerSettings(Element e) throws Exception {
        fromXml(e);
    }

    // === DB Methods ===

    // retrieve SQL
    public String m_sRetrieveSql =
            " SELECT id, cust_id, industry, tax_location, tax_id, country, [language], time_zone, currency, format, display_sample, active, search_text " +
                    " FROM ccps_language_currency " +
                    " WHERE id=?";

    public String getRetrieveSql() { return m_sRetrieveSql; }

    public int retrieveProps(PreparedStatement pstmt) throws Exception {
        int nReturnCode = 0;
        pstmt.setString(1, s_id);

        ResultSet rs = pstmt.executeQuery();
        if (rs.next()) {
            getPropsFromResultSetRow(rs);
            nReturnCode = 1;
        }
        rs.close();
        return nReturnCode;
    }

    public void getPropsFromResultSetRow(ResultSet rs) throws Exception {
        s_id = rs.getString("id");
        s_cust_id = rs.getString("cust_id");
        s_industry = rs.getString("industry");
        s_tax_location = rs.getString("tax_location");
        s_tax_id = rs.getString("tax_id");
        s_country = rs.getString("country");
        s_language = rs.getString("language");
        s_time_zone = rs.getString("time_zone");
        s_currency = rs.getString("currency");
        s_format = rs.getString("format");
        s_display_sample = rs.getString("display_sample");
        s_active = rs.getString("active");
        s_search_text = rs.getString("search_text");
    }

    // save SQL (örnek: stored procedure üzerinden)
    public String m_sSaveSql =
            " EXECUTE usp_customer_settings_save " +
                    "   @id=?, " +
                    "   @cust_id=?, " +
                    "   @industry=?, " +
                    "   @tax_location=?, " +
                    "   @tax_id=?, " +
                    "   @country=?, " +
                    "   @language=?, " +
                    "   @time_zone=?, " +
                    "   @currency=?, " +
                    "   @format=?, " +
                    "   @display_sample=?, " +
                    "   @active=?, " +
                    "   @search_text=?";

    public String getSaveSql() { return m_sSaveSql; }

    public int saveProps(PreparedStatement pstmt) throws Exception {
        int i = 1;
        pstmt.setString(i++, s_id);
        pstmt.setString(i++, s_cust_id);
        pstmt.setString(i++, s_industry);
        pstmt.setString(i++, s_tax_location);
        pstmt.setString(i++, s_tax_id);
        pstmt.setString(i++, s_country);
        pstmt.setString(i++, s_language);
        pstmt.setString(i++, s_time_zone);
        pstmt.setString(i++, s_currency);
        pstmt.setString(i++, s_format);
        pstmt.setString(i++, s_display_sample);
        pstmt.setString(i++, s_active);
        pstmt.setString(i++, s_search_text);

        ResultSet rs = pstmt.executeQuery();
        int nReturnCode = rs.next() ? 1 : 0;
        rs.close();
        return nReturnCode;
    }

    // delete SQL
    public String m_sDeleteSql =
            " DELETE FROM customer_settings WHERE id=?";

    public String getDeleteSql() { return m_sDeleteSql; }

    public int deleteProps(PreparedStatement pstmt) throws Exception {
        pstmt.setString(1, s_id);
        return pstmt.executeUpdate();
    }

    // === XML Methods ===
    public String m_sMainElementName = "customer_setting";
    public String getMainElementName() { return m_sMainElementName; }

    public void appendPropsToXml(Element e) {
        if (s_id != null) XmlUtil.appendTextChild(e, "id", s_id);
        if (s_cust_id != null) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
        if (s_industry != null) XmlUtil.appendTextChild(e, "industry", s_industry);
        if (s_tax_location != null) XmlUtil.appendTextChild(e, "tax_location", s_tax_location);
        if (s_tax_id != null) XmlUtil.appendTextChild(e, "tax_id", s_tax_id);
        if (s_country != null) XmlUtil.appendTextChild(e, "country", s_country);
        if (s_language != null) XmlUtil.appendTextChild(e, "language", s_language);
        if (s_time_zone != null) XmlUtil.appendTextChild(e, "time_zone", s_time_zone);
        if (s_currency != null) XmlUtil.appendTextChild(e, "currency", s_currency);
        if (s_format != null) XmlUtil.appendTextChild(e, "format", s_format);
        if (s_display_sample != null) XmlUtil.appendTextChild(e, "display_sample", s_display_sample);
        if (s_active != null) XmlUtil.appendTextChild(e, "active", s_active);
        if (s_search_text != null) XmlUtil.appendTextChild(e, "search_text", s_search_text);
    }

    public void getPropsFromXml(Element e) {
        s_id = XmlUtil.getChildTextValue(e, "id");
        s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
        s_industry = XmlUtil.getChildTextValue(e, "industry");
        s_tax_location = XmlUtil.getChildTextValue(e, "tax_location");
        s_tax_id = XmlUtil.getChildTextValue(e, "tax_id");
        s_country = XmlUtil.getChildTextValue(e, "country");
        s_language = XmlUtil.getChildTextValue(e, "language");
        s_time_zone = XmlUtil.getChildTextValue(e, "time_zone");
        s_currency = XmlUtil.getChildTextValue(e, "currency");
        s_format = XmlUtil.getChildTextValue(e, "format");
        s_display_sample = XmlUtil.getChildTextValue(e, "display_sample");
        s_active = XmlUtil.getChildTextValue(e, "active");
        s_search_text = XmlUtil.getChildTextValue(e, "search_text");
    }
}
