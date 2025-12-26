/**
 * ErrorStatus.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.2RC2 Nov 16, 2004 (12:19:44 EST) WSDL2Java emitter.
 */

package com.britemoon.cps.xcs.cti;

public class ErrorStatus implements java.io.Serializable {
    private java.lang.String _value_;
    private static java.util.HashMap _table_ = new java.util.HashMap();

    // Constructor
    protected ErrorStatus(java.lang.String value) {
        _value_ = value;
        _table_.put(_value_,this);
    }

    public static final java.lang.String _None = "None";
    public static final java.lang.String _Bad_GroupID = "Bad_GroupID";
    public static final java.lang.String _Bad_DocumentID = "Bad_DocumentID";
    public static final java.lang.String _Bad_Document_Name = "Bad_Document_Name";
    public static final java.lang.String _No_SoapContext = "No_SoapContext";
    public static final java.lang.String _No_UserName = "No_UserName";
    public static final java.lang.String _No_Customer_For_Group = "No_Customer_For_Group";
    public static final java.lang.String _Error_Saving_Document = "Error_Saving_Document";
    public static final ErrorStatus None = new ErrorStatus(_None);
    public static final ErrorStatus Bad_GroupID = new ErrorStatus(_Bad_GroupID);
    public static final ErrorStatus Bad_DocumentID = new ErrorStatus(_Bad_DocumentID);
    public static final ErrorStatus Bad_Document_Name = new ErrorStatus(_Bad_Document_Name);
    public static final ErrorStatus No_SoapContext = new ErrorStatus(_No_SoapContext);
    public static final ErrorStatus No_UserName = new ErrorStatus(_No_UserName);
    public static final ErrorStatus No_Customer_For_Group = new ErrorStatus(_No_Customer_For_Group);
    public static final ErrorStatus Error_Saving_Document = new ErrorStatus(_Error_Saving_Document);
    public java.lang.String getValue() { return _value_;}
    public static ErrorStatus fromValue(java.lang.String value)
          throws java.lang.IllegalArgumentException {
        ErrorStatus enumeration = (ErrorStatus)
            _table_.get(value);
        if (enumeration==null) throw new java.lang.IllegalArgumentException();
        return enumeration;
    }
    public static ErrorStatus fromString(java.lang.String value)
          throws java.lang.IllegalArgumentException {
        return fromValue(value);
    }
    public boolean equals(java.lang.Object obj) {return (obj == this);}
    public int hashCode() { return toString().hashCode();}
    public java.lang.String toString() { return _value_;}
    public java.lang.Object readResolve() { return fromValue(_value_);}
    public static org.apache.axis.encoding.Serializer getSerializer(
           java.lang.String mechType, 
           java.lang.Class _javaType,  
           javax.xml.namespace.QName _xmlType) {
        return 
          new org.apache.axis.encoding.ser.EnumSerializer(
            _javaType, _xmlType);
    }
    public static org.apache.axis.encoding.Deserializer getDeserializer(
           java.lang.String mechType, 
           java.lang.Class _javaType,  
           javax.xml.namespace.QName _xmlType) {
        return 
          new org.apache.axis.encoding.ser.EnumDeserializer(
            _javaType, _xmlType);
    }
    // Type metadata
    private static org.apache.axis.description.TypeDesc typeDesc =
        new org.apache.axis.description.TypeDesc(ErrorStatus.class);

    static {
        typeDesc.setXmlType(new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", "ErrorStatus"));
    }
    /**
     * Return type metadata object
     */
    public static org.apache.axis.description.TypeDesc getTypeDesc() {
        return typeDesc;
    }

}
