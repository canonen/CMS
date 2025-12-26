/**
 * ContentSoap.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.2RC2 Nov 16, 2004 (12:19:44 EST) WSDL2Java emitter.
 */

package com.britemoon.cps.xcs.cti;

public interface ContentSoap extends java.rmi.Remote {
    public com.britemoon.cps.xcs.cti.ArrayOfVariablePair getBritemoonVariables(java.lang.String groupID, java.lang.String documentID) throws java.rmi.RemoteException;
    public com.britemoon.cps.xcs.cti.DocumentOutput deleteExistingDocument(java.lang.String groupID, java.lang.String documentID) throws java.rmi.RemoteException;
    public com.britemoon.cps.xcs.cti.DocumentOutput cloneExistingDocument(java.lang.String groupID, java.lang.String oldDocumentID, java.lang.String newDocumentName) throws java.rmi.RemoteException;

    /**
     * Update document name.
     */
    public com.britemoon.cps.xcs.cti.DocumentOutput saveDocumentName(java.lang.String groupID, java.lang.String documentID, java.lang.String documentName) throws java.rmi.RemoteException;
}
