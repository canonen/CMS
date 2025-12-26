/**
 * VariablePair.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.2RC2 Nov 16, 2004 (12:19:44 EST) WSDL2Java emitter.
 */

package com.britemoon.cps.xcs.cti;

public class VariablePair  implements java.io.Serializable {
    private java.lang.String variableID;
    private java.lang.String britemoonName;

    public VariablePair() {
    }

    public VariablePair(
           java.lang.String variableID,
           java.lang.String britemoonName) {
           this.variableID = variableID;
           this.britemoonName = britemoonName;
    }


    /**
     * Gets the variableID value for this VariablePair.
     * 
     * @return variableID
     */
    public java.lang.String getVariableID() {
        return variableID;
    }


    /**
     * Sets the variableID value for this VariablePair.
     * 
     * @param variableID
     */
    public void setVariableID(java.lang.String variableID) {
        this.variableID = variableID;
    }


    /**
     * Gets the britemoonName value for this VariablePair.
     * 
     * @return britemoonName
     */
    public java.lang.String getBritemoonName() {
        return britemoonName;
    }


    /**
     * Sets the britemoonName value for this VariablePair.
     * 
     * @param britemoonName
     */
    public void setBritemoonName(java.lang.String britemoonName) {
        this.britemoonName = britemoonName;
    }

    private java.lang.Object __equalsCalc = null;
    public synchronized boolean equals(java.lang.Object obj) {
        if (!(obj instanceof VariablePair)) return false;
        VariablePair other = (VariablePair) obj;
        if (obj == null) return false;
        if (this == obj) return true;
        if (__equalsCalc != null) {
            return (__equalsCalc == obj);
        }
        __equalsCalc = obj;
        boolean _equals;
        _equals = true && 
            ((this.variableID==null && other.getVariableID()==null) || 
             (this.variableID!=null &&
              this.variableID.equals(other.getVariableID()))) &&
            ((this.britemoonName==null && other.getBritemoonName()==null) || 
             (this.britemoonName!=null &&
              this.britemoonName.equals(other.getBritemoonName())));
        __equalsCalc = null;
        return _equals;
    }

    private boolean __hashCodeCalc = false;
    public synchronized int hashCode() {
        if (__hashCodeCalc) {
            return 0;
        }
        __hashCodeCalc = true;
        int _hashCode = 1;
        if (getVariableID() != null) {
            _hashCode += getVariableID().hashCode();
        }
        if (getBritemoonName() != null) {
            _hashCode += getBritemoonName().hashCode();
        }
        __hashCodeCalc = false;
        return _hashCode;
    }

    // Type metadata
    private static org.apache.axis.description.TypeDesc typeDesc =
        new org.apache.axis.description.TypeDesc(VariablePair.class, true);

    static {
        typeDesc.setXmlType(new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", "VariablePair"));
        org.apache.axis.description.ElementDesc elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("variableID");
        elemField.setXmlName(new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", "VariableID"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        elemField.setMinOccurs(0);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("britemoonName");
        elemField.setXmlName(new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", "BritemoonName"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        elemField.setMinOccurs(0);
        typeDesc.addFieldDesc(elemField);
    }

    /**
     * Return type metadata object
     */
    public static org.apache.axis.description.TypeDesc getTypeDesc() {
        return typeDesc;
    }

    /**
     * Get Custom Serializer
     */
    public static org.apache.axis.encoding.Serializer getSerializer(
           java.lang.String mechType, 
           java.lang.Class _javaType,  
           javax.xml.namespace.QName _xmlType) {
        return 
          new  org.apache.axis.encoding.ser.BeanSerializer(
            _javaType, _xmlType, typeDesc);
    }

    /**
     * Get Custom Deserializer
     */
    public static org.apache.axis.encoding.Deserializer getDeserializer(
           java.lang.String mechType, 
           java.lang.Class _javaType,  
           javax.xml.namespace.QName _xmlType) {
        return 
          new  org.apache.axis.encoding.ser.BeanDeserializer(
            _javaType, _xmlType, typeDesc);
    }

}
