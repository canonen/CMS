/**
 * BritemoonOrderPlacementServiceLocator.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.2RC2 Nov 16, 2004 (12:19:44 EST) WSDL2Java emitter.
 */

package com.britemoon.cps.xcs.cti;

import org.apache.log4j.*;

public class BritemoonOrderPlacementServiceLocator extends org.apache.axis.client.Service implements com.britemoon.cps.xcs.cti.BritemoonOrderPlacementService {

	private static Logger logger = Logger.getLogger(BritemoonOrderPlacementServiceLocator.class.getName());
	public BritemoonOrderPlacementServiceLocator() {
    }


    public BritemoonOrderPlacementServiceLocator(org.apache.axis.EngineConfiguration config) {
        super(config);
    }

    // Use to get a proxy class for BritemoonOrderPlacementServiceSoap
    private java.lang.String BritemoonOrderPlacementServiceSoap_address = "http://localhost/STIP/BritemoonOrderPlacementService.asmx";

    public java.lang.String getBritemoonOrderPlacementServiceSoapAddress() {
        return BritemoonOrderPlacementServiceSoap_address;
    }

    // The WSDD service name defaults to the port name.
    private java.lang.String BritemoonOrderPlacementServiceSoapWSDDServiceName = "BritemoonOrderPlacementServiceSoap";

    public java.lang.String getBritemoonOrderPlacementServiceSoapWSDDServiceName() {
        return BritemoonOrderPlacementServiceSoapWSDDServiceName;
    }

    public void setBritemoonOrderPlacementServiceSoapWSDDServiceName(java.lang.String name) {
        BritemoonOrderPlacementServiceSoapWSDDServiceName = name;
    }

    public com.britemoon.cps.xcs.cti.BritemoonOrderPlacementServiceSoap getBritemoonOrderPlacementServiceSoap() throws javax.xml.rpc.ServiceException {
       java.net.URL endpoint;
        try {
            endpoint = new java.net.URL(BritemoonOrderPlacementServiceSoap_address);
        }
        catch (java.net.MalformedURLException e) {
            throw new javax.xml.rpc.ServiceException(e);
        }
        return getBritemoonOrderPlacementServiceSoap(endpoint);
    }

    public com.britemoon.cps.xcs.cti.BritemoonOrderPlacementServiceSoap getBritemoonOrderPlacementServiceSoap(java.net.URL portAddress)
    {
    	com.britemoon.cps.xcs.cti.BritemoonOrderPlacementServiceSoapStub _stub =
    		new com.britemoon.cps.xcs.cti.BritemoonOrderPlacementServiceSoapStub(portAddress, this);
    	_stub.setPortName(getBritemoonOrderPlacementServiceSoapWSDDServiceName());
    	return _stub;
    }

    public void setBritemoonOrderPlacementServiceSoapEndpointAddress(java.lang.String address) {
        BritemoonOrderPlacementServiceSoap_address = address;
    }

    /**
     * For the given interface, get the stub implementation.
     * If this service has no port for the given interface,
     * then ServiceException is thrown.
     */
    public java.rmi.Remote getPort(Class serviceEndpointInterface) throws javax.xml.rpc.ServiceException {
        try {
            if (com.britemoon.cps.xcs.cti.BritemoonOrderPlacementServiceSoap.class.isAssignableFrom(serviceEndpointInterface)) {
                com.britemoon.cps.xcs.cti.BritemoonOrderPlacementServiceSoapStub _stub = new com.britemoon.cps.xcs.cti.BritemoonOrderPlacementServiceSoapStub(new java.net.URL(BritemoonOrderPlacementServiceSoap_address), this);
                _stub.setPortName(getBritemoonOrderPlacementServiceSoapWSDDServiceName());
                return _stub;
            }
        }
        catch (java.lang.Throwable t) {
            throw new javax.xml.rpc.ServiceException(t);
        }
        throw new javax.xml.rpc.ServiceException("There is no stub implementation for the interface:  " + (serviceEndpointInterface == null ? "null" : serviceEndpointInterface.getName()));
    }

    /**
     * For the given interface, get the stub implementation.
     * If this service has no port for the given interface,
     * then ServiceException is thrown.
     */
    public java.rmi.Remote getPort(javax.xml.namespace.QName portName, Class serviceEndpointInterface) throws javax.xml.rpc.ServiceException {
        if (portName == null) {
            return getPort(serviceEndpointInterface);
        }
        java.lang.String inputPortName = portName.getLocalPart();
        if ("BritemoonOrderPlacementServiceSoap".equals(inputPortName)) {
            return getBritemoonOrderPlacementServiceSoap();
        }
        else  {
            java.rmi.Remote _stub = getPort(serviceEndpointInterface);
            ((org.apache.axis.client.Stub) _stub).setPortName(portName);
            return _stub;
        }
    }

    public javax.xml.namespace.QName getServiceName() {
        return new javax.xml.namespace.QName("http://localhost/STIP/", "BritemoonOrderPlacementService");
    }

    private java.util.HashSet ports = null;

    public java.util.Iterator getPorts() {
        if (ports == null) {
            ports = new java.util.HashSet();
            ports.add(new javax.xml.namespace.QName("http://localhost/STIP/", "BritemoonOrderPlacementServiceSoap"));
        }
        return ports.iterator();
    }

    /**
    * Set the endpoint address for the specified port name.
    */
    public void setEndpointAddress(java.lang.String portName, java.lang.String address) throws javax.xml.rpc.ServiceException {
        if ("BritemoonOrderPlacementServiceSoap".equals(portName)) {
            setBritemoonOrderPlacementServiceSoapEndpointAddress(address);
        }
        else { // Unknown Port Name
            throw new javax.xml.rpc.ServiceException(" Cannot set Endpoint Address for Unknown Port" + portName);
        }
    }

    /**
    * Set the endpoint address for the specified port name.
    */
    public void setEndpointAddress(javax.xml.namespace.QName portName, java.lang.String address) throws javax.xml.rpc.ServiceException {
        setEndpointAddress(portName.getLocalPart(), address);
    }

}
