/**
 * ArrayOfVariablePair.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.2RC2 Nov 16, 2004 (12:19:44 EST) WSDL2Java emitter.
 */

package com.britemoon.cps.xcs.cti;

import org.apache.log4j.*;

public class ArrayOfVariablePair  implements java.io.Serializable 
{
	private static Logger logger = Logger.getLogger(ArrayOfVariablePair.class.getName());
	private com.britemoon.cps.xcs.cti.VariablePair[] variablePair;

    public ArrayOfVariablePair() {
    }

    public ArrayOfVariablePair(
           com.britemoon.cps.xcs.cti.VariablePair[] variablePair) {
           this.variablePair = variablePair;
    }


    /**
     * Gets the variablePair value for this ArrayOfVariablePair.
     * 
     * @return variablePair
     */
    public com.britemoon.cps.xcs.cti.VariablePair[] getVariablePair() {
        return variablePair;
    }


    /**
     * Sets the variablePair value for this ArrayOfVariablePair.
     * 
     * @param variablePair
     */
    public void setVariablePair(com.britemoon.cps.xcs.cti.VariablePair[] variablePair) {
        this.variablePair = variablePair;
    }

    public com.britemoon.cps.xcs.cti.VariablePair getVariablePair(int i) {
        return this.variablePair[i];
    }

    public void setVariablePair(int i, com.britemoon.cps.xcs.cti.VariablePair _value) {
        this.variablePair[i] = _value;
    }

    private java.lang.Object __equalsCalc = null;
    public synchronized boolean equals(java.lang.Object obj) {
        if (!(obj instanceof ArrayOfVariablePair)) return false;
        ArrayOfVariablePair other = (ArrayOfVariablePair) obj;
        if (obj == null) return false;
        if (this == obj) return true;
        if (__equalsCalc != null) {
            return (__equalsCalc == obj);
        }
        __equalsCalc = obj;
        boolean _equals;
        _equals = true && 
            ((this.variablePair==null && other.getVariablePair()==null) || 
             (this.variablePair!=null &&
              java.util.Arrays.equals(this.variablePair, other.getVariablePair())));
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
        if (getVariablePair() != null) {
            for (int i=0;
                 i<java.lang.reflect.Array.getLength(getVariablePair());
                 i++) {
                java.lang.Object obj = java.lang.reflect.Array.get(getVariablePair(), i);
                if (obj != null &&
                    !obj.getClass().isArray()) {
                    _hashCode += obj.hashCode();
                }
            }
        }
        __hashCodeCalc = false;
        return _hashCode;
    }

    // Type metadata
    private static org.apache.axis.description.TypeDesc typeDesc =
        new org.apache.axis.description.TypeDesc(ArrayOfVariablePair.class, true);

    static {
        typeDesc.setXmlType(new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", "ArrayOfVariablePair"));
        org.apache.axis.description.ElementDesc elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("variablePair");
        elemField.setXmlName(new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", "VariablePair"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", "VariablePair"));
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
