/**
 * Content.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.2RC2 Nov 16, 2004 (12:19:44 EST) WSDL2Java emitter.
 */

package com.britemoon.cps.xcs.cti;

public interface Content extends javax.xml.rpc.Service {
    public java.lang.String getContentSoapAddress();

    public com.britemoon.cps.xcs.cti.ContentSoap getContentSoap() throws javax.xml.rpc.ServiceException;

    public com.britemoon.cps.xcs.cti.ContentSoap getContentSoap(java.net.URL portAddress) throws javax.xml.rpc.ServiceException;
}
