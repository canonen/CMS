/**
 * ContentLocator.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.2RC2 Nov 16, 2004 (12:19:44 EST) WSDL2Java emitter.
 */

package com.britemoon.cps.xcs.cti;

public class ContentLocator extends org.apache.axis.client.Service implements Content {

    public ContentLocator() {
    }


    public ContentLocator(org.apache.axis.EngineConfiguration config) {
        super(config);
    }

    // Use to get a proxy class for ContentSoap
    private java.lang.String ContentSoap_address = "http://69.15.102.18/stip/content.asmx";

    public java.lang.String getContentSoapAddress() {
        return ContentSoap_address;
    }

    // The WSDD service name defaults to the port name.
    private java.lang.String ContentSoapWSDDServiceName = "ContentSoap";

    public java.lang.String getContentSoapWSDDServiceName() {
        return ContentSoapWSDDServiceName;
    }

    public void setContentSoapWSDDServiceName(java.lang.String name) {
        ContentSoapWSDDServiceName = name;
    }

    public ContentSoap getContentSoap() throws javax.xml.rpc.ServiceException {
       java.net.URL endpoint;
        try {
            endpoint = new java.net.URL(ContentSoap_address);
        }
        catch (java.net.MalformedURLException e) {
            throw new javax.xml.rpc.ServiceException(e);
        }
        return getContentSoap(endpoint);
    }

    public ContentSoap getContentSoap(java.net.URL portAddress)
	{
    	ContentSoapStub _stub = new ContentSoapStub(portAddress, this);
    	_stub.setPortName(getContentSoapWSDDServiceName());
    	return _stub;
    }

    public void setContentSoapEndpointAddress(java.lang.String address)
	{
        ContentSoap_address = address;
    }

    /**
     * For the given interface, get the stub implementation.
     * If this service has no port for the given interface,
     * then ServiceException is thrown.
     */
    public java.rmi.Remote getPort(Class serviceEndpointInterface) throws javax.xml.rpc.ServiceException
	{
        try
		{
            if (ContentSoap.class.isAssignableFrom(serviceEndpointInterface))
			{
                ContentSoapStub _stub = new ContentSoapStub(new java.net.URL(ContentSoap_address), this);
                _stub.setPortName(getContentSoapWSDDServiceName());
                return _stub;
            }
        }
        catch (java.lang.Throwable t)
		{
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
        if ("ContentSoap".equals(inputPortName)) {
            return getContentSoap();
        }
        else  {
            java.rmi.Remote _stub = getPort(serviceEndpointInterface);
            ((org.apache.axis.client.Stub) _stub).setPortName(portName);
            return _stub;
        }
    }

    public javax.xml.namespace.QName getServiceName() {
        return new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", "Content");
    }

    private java.util.HashSet ports = null;

    public java.util.Iterator getPorts() {
        if (ports == null) {
            ports = new java.util.HashSet();
            ports.add(new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", "ContentSoap"));
        }
        return ports.iterator();
    }

    /**
    * Set the endpoint address for the specified port name.
    */
    public void setEndpointAddress(java.lang.String portName, java.lang.String address) throws javax.xml.rpc.ServiceException {
        if ("ContentSoap".equals(portName)) {
            setContentSoapEndpointAddress(address);
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
