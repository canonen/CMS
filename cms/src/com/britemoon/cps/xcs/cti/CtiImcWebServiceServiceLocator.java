/**
 * CtiImcWebServiceServiceLocator.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis WSDL2Java emitter.
 */

package com.britemoon.cps.xcs.cti;

public class CtiImcWebServiceServiceLocator extends org.apache.axis.client.Service implements com.britemoon.cps.xcs.cti.CtiImcWebServiceService {

    // Use to get a proxy class for CtiIMC
    // private final java.lang.String CtiIMC_address = "http://localhost/rrcp/services/CtiIMC";
    private final java.lang.String CtiIMC_address = "http://dev226.00b.net/rrcp/services/CtiIMC";

    public java.lang.String getCtiIMCAddress() {
        return CtiIMC_address;
    }

    // The WSDD service name defaults to the port name.
    private java.lang.String CtiIMCWSDDServiceName = "CtiIMC";

    public java.lang.String getCtiIMCWSDDServiceName() {
        return CtiIMCWSDDServiceName;
    }

    public void setCtiIMCWSDDServiceName(java.lang.String name) {
        CtiIMCWSDDServiceName = name;
    }

    public com.britemoon.cps.xcs.cti.CtiImcWebService getCtiIMC() throws javax.xml.rpc.ServiceException {
       java.net.URL endpoint;
        try {
            endpoint = new java.net.URL(CtiIMC_address);
        }
        catch (java.net.MalformedURLException e) {
            throw new javax.xml.rpc.ServiceException(e);
        }
        return getCtiIMC(endpoint);
    }

    public com.britemoon.cps.xcs.cti.CtiImcWebService getCtiIMC(java.net.URL portAddress)
    {
    	com.britemoon.cps.xcs.cti.CtiIMCSoapBindingStub _stub = new com.britemoon.cps.xcs.cti.CtiIMCSoapBindingStub(portAddress, this);
    	_stub.setPortName(getCtiIMCWSDDServiceName());
    	return _stub;
    }

    /**
     * For the given interface, get the stub implementation.
     * If this service has no port for the given interface,
     * then ServiceException is thrown.
     */
    public java.rmi.Remote getPort(Class serviceEndpointInterface) throws javax.xml.rpc.ServiceException {
        try {
            if (com.britemoon.cps.xcs.cti.CtiImcWebService.class.isAssignableFrom(serviceEndpointInterface)) {
                com.britemoon.cps.xcs.cti.CtiIMCSoapBindingStub _stub = new com.britemoon.cps.xcs.cti.CtiIMCSoapBindingStub(new java.net.URL(CtiIMC_address), this);
                _stub.setPortName(getCtiIMCWSDDServiceName());
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
        if ("CtiIMC".equals(inputPortName)) {
            return getCtiIMC();
        }
        else  {
            java.rmi.Remote _stub = getPort(serviceEndpointInterface);
            ((org.apache.axis.client.Stub) _stub).setPortName(portName);
            return _stub;
        }
    }

    public javax.xml.namespace.QName getServiceName() {
        return new javax.xml.namespace.QName("urn:cti_imc", "CtiImcWebServiceService");
    }

    private java.util.HashSet ports = null;

    public java.util.Iterator getPorts() {
        if (ports == null) {
            ports = new java.util.HashSet();
            ports.add(new javax.xml.namespace.QName("CtiIMC"));
        }
        return ports.iterator();
    }

}
