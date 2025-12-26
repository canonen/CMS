package com.britemoon.cps.tgt;

import com.britemoon.cps.XmlUtil;
import com.britemoon.cps.BriteObject;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import org.apache.log4j.Logger;
import org.w3c.dom.Element;

public class CustomFormula extends BriteObject {
    public String s_filter_id = null;

    public String s_attr_id = null;

    public String s_operation_id = null;

    public String s_web_formula_operation_id = null;

    public String s_web_formula_time_operation_id = null;

    public String s_positive_flag = null;

    public String s_time_value1 = null;

    public String s_time_value2 = null;

    public String s_value1 = null;

    public String s_value2 = null;

    public String s_type_id = null;

    private static Logger logger = Logger.getLogger(CustomFormula.class.getName());

    public String m_sRetrieveSql;

    public String m_sSaveSql;

    public String m_sDeleteSql;

    public String m_sMainElementName;

    public CustomFormula() {
        this
                .m_sRetrieveSql = " SELECT\tfilter_id,\tcolumn_id,\toperation_id,\tweb_formula_operation_id,\tweb_formula_time_operation_id,\ttime_value1,\ttime_value2,\tvalue1,\tpositive_flag,\tvalue2,\ttype_id FROM ctgt_web_formula WHERE\t(filter_id=?)";
        this
                .m_sSaveSql = " EXECUTE usp_ctgt_web_formula_save\t@filter_id=?,\t@column_id=?,\t@operation_id=?,\t@web_formula_operation_id=?,\t@web_formula_time_operation_id=?,\t@time_value1=?,\t@time_value2=?,\t@value1=?,\t@positive_flag=?,\t@value2=?,\t@type_id=?";
        this
                .m_sDeleteSql = " DELETE FROM ctgt_web_formula WHERE\t(filter_id=?)";
        this.m_sMainElementName = "formula";
    }

    public CustomFormula(String sFilterId) throws Exception {
        this.m_sRetrieveSql = " SELECT\tfilter_id,\tcolumn_id,\toperation_id,\tweb_formula_operation_id,\tweb_formula_time_operation_id,\ttime_value1,\ttime_value2,\tvalue1,\tpositive_flag,\tvalue2,\ttype_id FROM ctgt_web_formula WHERE\t(filter_id=?)";
        this.m_sSaveSql = " EXECUTE usp_ctgt_web_formula_save\t@filter_id=?,\t@column_id=?,\t@operation_id=?,\t@web_formula_operation_id=?,\t@web_formula_time_operation_id=?,\t@time_value1=?,\t@time_value2=?,\t@value1=?,\t@positive_flag=?,\t@value2=?,\t@type_id=?";
        this.m_sDeleteSql = " DELETE FROM ctgt_web_formula WHERE\t(filter_id=?)";
        this.m_sMainElementName = "formula";
        this.s_filter_id = sFilterId;
        retrieve();
    }

    public CustomFormula(Element e) throws Exception {
        this.m_sRetrieveSql = " SELECT\tfilter_id,\tcolumn_id,\toperation_id,\tweb_formula_operation_id,\tweb_formula_time_operation_id,\ttime_value1,\ttime_value2,\tvalue1,\tpositive_flag,\tvalue2,\ttype_id FROM ctgt_web_formula WHERE\t(filter_id=?)";
        this.m_sSaveSql = " EXECUTE usp_ctgt_web_formula_save\t@filter_id=?,\t@column_id=?,\t@operation_id=?,\t@web_formula_operation_id=?,\t@web_formula_time_operation_id=?,\t@time_value1=?,\t@time_value2=?,\t@value1=?,\t@positive_flag=?,\t@value2=?,\t@type_id=?";
        this.m_sDeleteSql = " DELETE FROM ctgt_web_formula WHERE\t(filter_id=?)";
        this.m_sMainElementName = "formula";
        fromXml(e);
    }

    public String getRetrieveSql() {
        return this.m_sRetrieveSql;
    }

    public int retrieveProps(PreparedStatement pstmt) throws Exception {
        int nReturnCode = 0;
        pstmt.setString(1, this.s_filter_id);
        ResultSet rs = pstmt.executeQuery();
        if (rs.next()) {
            getPropsFromResultSetRow(rs);
            nReturnCode = 1;
        }
        rs.close();
        return nReturnCode;
    }

    public void getPropsFromResultSetRow(ResultSet rs) throws Exception {
        byte[] b = null;
        this.s_filter_id = rs.getString(1);
        this.s_attr_id = rs.getString(2);
        this.s_operation_id = rs.getString(3);
        this.s_web_formula_operation_id = rs.getString(4);
        this.s_web_formula_time_operation_id = rs.getString(5);
        b = rs.getBytes(6);
        this.s_time_value1 = (b == null) ? null : new String(b, "UTF-8");
        b = rs.getBytes(7);
        this.s_time_value2 = (b == null) ? null : new String(b, "UTF-8");
        b = rs.getBytes(8);
        this.s_value1 = (b == null) ? null : new String(b, "UTF-8");
        this.s_positive_flag = rs.getString(9);
        b = rs.getBytes(10);
        this.s_value2 = (b == null) ? null : new String(b, "UTF-8");
        this.s_type_id = rs.getString(11);
    }

    public String getSaveSql() {
        return this.m_sSaveSql;
    }

    public int saveProps(PreparedStatement pstmt) throws Exception {
        int nReturnCode = 0;
        pstmt.setString(1, this.s_filter_id);
        pstmt.setString(2, this.s_attr_id);
        pstmt.setString(3, this.s_operation_id);
        pstmt.setString(4, this.s_web_formula_operation_id);
        pstmt.setString(5, this.s_web_formula_time_operation_id);
        if (this.s_time_value1 == null) {
            pstmt.setString(6, this.s_time_value1);
        } else {
            pstmt.setBytes(6, this.s_time_value1.getBytes("UTF-8"));
        }
        if (this.s_time_value2 == null) {
            pstmt.setString(7, this.s_time_value2);
        } else {
            pstmt.setBytes(7, this.s_time_value2.getBytes("UTF-8"));
        }
        if (this.s_value1 == null) {
            pstmt.setString(8, this.s_value1);
        } else {
            pstmt.setBytes(8, this.s_value1.getBytes("UTF-8"));
        }
        pstmt.setString(9, this.s_positive_flag);
        if (this.s_value2 == null) {
            pstmt.setString(10, this.s_value2);
        } else {
            pstmt.setBytes(10, this.s_value2.getBytes("UTF-8"));
        }
        pstmt.setString(11, this.s_type_id);
        ResultSet rs = pstmt.executeQuery();
        byte[] b = null;
        if (rs.next()) {
            this.s_filter_id = rs.getString(1);
            nReturnCode = 1;
        }
        rs.close();
        return nReturnCode;
    }

    public String getDeleteSql() {
        return this.m_sDeleteSql;
    }

    public int deleteProps(PreparedStatement pstmt) throws Exception {
        pstmt.setString(1, this.s_filter_id);
        return pstmt.executeUpdate();
    }

    public String getMainElementName() {
        return this.m_sMainElementName;
    }

    public void appendPropsToXml(Element e) {
        if (this.s_filter_id != null)
            XmlUtil.appendTextChild(e, "filter_id", this.s_filter_id);
        if (this.s_attr_id != null)
            XmlUtil.appendTextChild(e, "attr_id", this.s_attr_id);
        if (this.s_operation_id != null)
            XmlUtil.appendTextChild(e, "operation_id", this.s_operation_id);
        if (this.s_web_formula_operation_id != null)
            XmlUtil.appendTextChild(e, "web_formula_operation_id", this.s_web_formula_operation_id);
        if (this.s_web_formula_time_operation_id != null)
            XmlUtil.appendTextChild(e, "web_formula_time_operation_id", this.s_web_formula_time_operation_id);
        if (this.s_time_value1 != null)
            XmlUtil.appendCDataChild(e, "time_value1", this.s_time_value1);
        if (this.s_time_value2 != null)
            XmlUtil.appendCDataChild(e, "time_value2", this.s_time_value2);
        if (this.s_value1 != null)
            XmlUtil.appendCDataChild(e, "value1", this.s_value1);
        if (this.s_positive_flag != null)
            XmlUtil.appendTextChild(e, "positive_flag", this.s_positive_flag);
        if (this.s_value2 != null)
            XmlUtil.appendCDataChild(e, "value2", this.s_value2);
        if (this.s_type_id != null)
            XmlUtil.appendTextChild(e, "type_id", this.s_type_id);
    }

    public void getPropsFromXml(Element e) {
        this.s_filter_id = XmlUtil.getChildTextValue(e, "filter_id");
        this.s_attr_id = XmlUtil.getChildTextValue(e, "attr_id");
        this.s_operation_id = XmlUtil.getChildTextValue(e, "operation_id");
        this.s_web_formula_operation_id = XmlUtil.getChildTextValue(e, "web_formula_operation_id");
        this.s_web_formula_time_operation_id = XmlUtil.getChildTextValue(e, "web_formula_time_operation_id");
        this.s_time_value1 = XmlUtil.getChildCDataValue(e, "time_value1");
        this.s_time_value2 = XmlUtil.getChildCDataValue(e, "time_value2");
        this.s_value1 = XmlUtil.getChildCDataValue(e, "value1");
        this.s_positive_flag = XmlUtil.getChildTextValue(e, "positive_flag");
        this.s_value2 = XmlUtil.getChildCDataValue(e, "value2");
        this.s_type_id = XmlUtil.getChildTextValue(e, "type_id");
    }
}
