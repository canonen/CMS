package com.britemoon.sas;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class CustomerSettingsList extends BriteList {
    private static Logger logger = Logger.getLogger(CustomerSettingsList.class.getName());

    public CustomerSettingsList() {
    }

    public CustomerSettingsList(Element e) throws Exception {
        fromXml(e);
    }

    // === Fields (tablodaki kolonlar) ===
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

    private void resetParams() {
        s_id = null;
        s_cust_id = null;
        s_industry = null;
        s_tax_location = null;
        s_tax_id = null;
        s_country = null;
        s_language = null;
        s_time_zone = null;
        s_currency = null;
        s_format = null;
        s_display_sample = null;
        s_active = null;
        s_search_text = null;
    }

    // === SQL init ===
    {
        m_sRetrieveSql = null;
        m_bUseParamsForRetrieve = true;

        m_sSelectClause =
                " SELECT " +
                        " id, cust_id, industry, tax_location, tax_id, country, [language], " +
                        " time_zone, currency, format, display_sample, active, search_text ";

        m_sFromClause = " FROM customer_settings ";
        m_sWhereClause = null;
        m_sOrderByClause = " ORDER BY id ";
    }

    public String buildWhereClause() {
        String sWhereSql = " WHERE ";
        boolean bAddAnd = false;

        if (s_id != null) { sWhereSql += " (id IN (?)) "; bAddAnd = true; }
        if (s_cust_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (cust_id IN (?)) "); bAddAnd = true; }
        if (s_industry != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (industry IN (?)) "); bAddAnd = true; }
        if (s_tax_location != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (tax_location IN (?)) "); bAddAnd = true; }
        if (s_tax_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (tax_id IN (?)) "); bAddAnd = true; }
        if (s_country != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (country IN (?)) "); bAddAnd = true; }
        if (s_language != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " ([language] IN (?)) "); bAddAnd = true; }
        if (s_time_zone != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (time_zone IN (?)) "); bAddAnd = true; }
        if (s_currency != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (currency IN (?)) "); bAddAnd = true; }
        if (s_format != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (format IN (?)) "); bAddAnd = true; }
        if (s_display_sample != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (display_sample IN (?)) "); bAddAnd = true; }
        if (s_active != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (active IN (?)) "); bAddAnd = true; }
        if (s_search_text != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (search_text IN (?)) "); bAddAnd = true; }

        return sWhereSql;
    }

    public void setParams(PreparedStatement pstmt) throws Exception {
        int i = 1;
        if (s_id != null) { pstmt.setString(i, s_id); i++; }
        if (s_cust_id != null) { pstmt.setString(i, s_cust_id); i++; }
        if (s_industry != null) { pstmt.setString(i, s_industry); i++; }
        if (s_tax_location != null) { pstmt.setString(i, s_tax_location); i++; }
        if (s_tax_id != null) { pstmt.setString(i, s_tax_id); i++; }
        if (s_country != null) { pstmt.setString(i, s_country); i++; }
        if (s_language != null) { pstmt.setString(i, s_language); i++; }
        if (s_time_zone != null) { pstmt.setString(i, s_time_zone); i++; }
        if (s_currency != null) { pstmt.setString(i, s_currency); i++; }
        if (s_format != null) { pstmt.setString(i, s_format); i++; }
        if (s_display_sample != null) { pstmt.setString(i, s_display_sample); i++; }
        if (s_active != null) { pstmt.setString(i, s_active); i++; }
        if (s_search_text != null) { pstmt.setString(i, s_search_text); i++; }
    }

    public void fixIds() {
        CustomerSettings settings = null;
        for (Enumeration e = v.elements(); e.hasMoreElements();) {
            settings = (CustomerSettings) e.nextElement();
            if (s_cust_id != null) settings.s_cust_id = s_cust_id;
        }
    }

    public int getListFromResultSet(ResultSet rs) throws Exception {
        int nReturnCode = 0;
        CustomerSettings settings = null;
        while (rs.next()) {
            settings = new CustomerSettings();
            settings.getPropsFromResultSetRow(rs);
            add(settings);
            nReturnCode++;
        }
        return nReturnCode;
    }

    // === XML Methods ===
    public String m_sMainElementName = "customer_settings_list";
    public String getMainElementName() { return m_sMainElementName; }

    public String m_sSubElementName = "customer_settings";
    public String getSubElementName() { return m_sSubElementName; }

    public int getPartsFromXml(NodeList nl) throws Exception {
        int iLength = nl.getLength();
        CustomerSettings settings = null;
        for (int i = 0; i < iLength; i++) {
            settings = new CustomerSettings((Element) nl.item(i));
            v.add(settings);
        }
        return iLength;
    }
}
