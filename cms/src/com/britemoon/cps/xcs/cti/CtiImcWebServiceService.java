/**
 * CtiImcWebServiceService.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis WSDL2Java emitter.
 */

package com.britemoon.cps.xcs.cti;

public interface CtiImcWebServiceService extends javax.xml.rpc.Service {
    public java.lang.String getCtiIMCAddress();

    public com.britemoon.cps.xcs.cti.CtiImcWebService getCtiIMC() throws javax.xml.rpc.ServiceException;

    public com.britemoon.cps.xcs.cti.CtiImcWebService getCtiIMC(java.net.URL portAddress) throws javax.xml.rpc.ServiceException;
}
