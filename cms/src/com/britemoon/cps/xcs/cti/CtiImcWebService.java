/**
 * CtiImcWebService.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis WSDL2Java emitter.
 */

package com.britemoon.cps.xcs.cti;

public interface CtiImcWebService extends java.rmi.Remote {
    public int getMessageActivityQty(java.lang.String sCustId, java.lang.String sCampId) throws java.rmi.RemoteException;
    public com.britemoon.cps.xcs.cti.bean.MessageActivity[] getMessageActivity(java.lang.String sCustId, java.lang.String sCampId, java.lang.String sCtiOrderId, java.lang.String sLastId) throws java.rmi.RemoteException;
    public int getClickActivityQty(java.lang.String sCustId, java.lang.String sCampId) throws java.rmi.RemoteException;
    public com.britemoon.cps.xcs.cti.bean.ClickActivity[] getClickActivity(java.lang.String sCustId, java.lang.String sCampId, java.lang.String sCtiOrderId, java.lang.String sLastId) throws java.rmi.RemoteException;
}
