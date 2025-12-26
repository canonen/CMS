/**
 * PackageBrokerWebServiceLocator.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis WSDL2Java emitter.
 */

package com.britemoon.cps.xcs.cti;

public class PackageBrokerWebServiceLocator extends org.apache.axis.client.Service implements com.britemoon.cps.xcs.cti.PackageBrokerWebService {

    // Use to get a proxy class for PackageBrokerWebServiceSoap
    private final java.lang.String PackageBrokerWebServiceSoap_address = "http://www.clicktactics.com/PackageBrokerWebServices/PackageBrokerWebService.asmx";
     //private final java.lang.String PackageBrokerWebServiceSoap_address = "http://localhost/ccps/services/PackageBrokerWebService";

    public java.lang.String getPackageBrokerWebServiceSoapAddress() {
        return PackageBrokerWebServiceSoap_address;
    }

    // The WSDD service name defaults to the port name.
    private java.lang.String PackageBrokerWebServiceSoapWSDDServiceName = "PackageBrokerWebServiceSoap";

    public java.lang.String getPackageBrokerWebServiceSoapWSDDServiceName() {
        return PackageBrokerWebServiceSoapWSDDServiceName;
    }

    public void setPackageBrokerWebServiceSoapWSDDServiceName(java.lang.String name) {
        PackageBrokerWebServiceSoapWSDDServiceName = name;
    }

    public com.britemoon.cps.xcs.cti.PackageBrokerWebServiceSoap getPackageBrokerWebServiceSoap() throws javax.xml.rpc.ServiceException {
       java.net.URL endpoint;
        try {
            endpoint = new java.net.URL(PackageBrokerWebServiceSoap_address);
        }
        catch (java.net.MalformedURLException e) {
            throw new javax.xml.rpc.ServiceException(e);
        }
        return getPackageBrokerWebServiceSoap(endpoint);
    }

    public com.britemoon.cps.xcs.cti.PackageBrokerWebServiceSoap getPackageBrokerWebServiceSoap(java.net.URL portAddress)
    {
    	com.britemoon.cps.xcs.cti.PackageBrokerWebServiceSoapStub _stub = new com.britemoon.cps.xcs.cti.PackageBrokerWebServiceSoapStub(portAddress, this);
    	_stub.setPortName(getPackageBrokerWebServiceSoapWSDDServiceName());
    	return _stub;
    }

    /**
     * For the given interface, get the stub implementation.
     * If this service has no port for the given interface,
     * then ServiceException is thrown.
     */
    public java.rmi.Remote getPort(Class serviceEndpointInterface) throws javax.xml.rpc.ServiceException {
        try {
            if (com.britemoon.cps.xcs.cti.PackageBrokerWebServiceSoap.class.isAssignableFrom(serviceEndpointInterface)) {
                com.britemoon.cps.xcs.cti.PackageBrokerWebServiceSoapStub _stub = new com.britemoon.cps.xcs.cti.PackageBrokerWebServiceSoapStub(new java.net.URL(PackageBrokerWebServiceSoap_address), this);
                _stub.setPortName(getPackageBrokerWebServiceSoapWSDDServiceName());
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
        String inputPortName = portName.getLocalPart();
        if ("PackageBrokerWebServiceSoap".equals(inputPortName)) {
            return getPackageBrokerWebServiceSoap();
        }
        else  {
            java.rmi.Remote _stub = getPort(serviceEndpointInterface);
            ((org.apache.axis.client.Stub) _stub).setPortName(portName);
            return _stub;
        }
    }

    public javax.xml.namespace.QName getServiceName() {
        return new javax.xml.namespace.QName("http://clicktactics.com/PackageBrokerWebServices/", "PackageBrokerWebService");
    }

    private java.util.HashSet ports = null;

    public java.util.Iterator getPorts() {
        if (ports == null) {
            ports = new java.util.HashSet();
            ports.add(new javax.xml.namespace.QName("PackageBrokerWebServiceSoap"));
        }
        return ports.iterator();
    }

}
