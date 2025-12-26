/**
 * PackageBrokerWebServiceSoap.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis WSDL2Java emitter.
 */

package com.britemoon.cps.xcs.cti;

public interface PackageBrokerWebServiceSoap extends java.rmi.Remote {

    // Update Package Status.
    public java.lang.String updatePackageStatus(java.lang.String packageID, java.lang.String status) throws java.rmi.RemoteException;

    // Update Package Item Status.
    public void updatePackageItemStatus(java.lang.String packageItemID, java.lang.String status) throws java.rmi.RemoteException;
}
