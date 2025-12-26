/**
 * BritemoonOrderPlacementServiceSoapSkeleton.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.2RC2 Nov 16, 2004 (12:19:44 EST) WSDL2Java emitter.
 */

package com.britemoon.cps.xcs.cti;

public class BritemoonOrderPlacementServiceSoapSkeleton implements com.britemoon.cps.xcs.cti.BritemoonOrderPlacementServiceSoap, org.apache.axis.wsdl.Skeleton {
    private com.britemoon.cps.xcs.cti.BritemoonOrderPlacementServiceSoap impl;
    private static java.util.Map _myOperations = new java.util.Hashtable();
    private static java.util.Collection _myOperationsList = new java.util.ArrayList();

    /**
    * Returns List of OperationDesc objects with this name
    */
    public static java.util.List getOperationDescByName(java.lang.String methodName) {
        return (java.util.List)_myOperations.get(methodName);
    }

    /**
    * Returns Collection of OperationDescs
    */
    public static java.util.Collection getOperationDescs() {
        return _myOperationsList;
    }

    static {
        org.apache.axis.description.OperationDesc _oper;
        org.apache.axis.description.FaultDesc _fault;
        org.apache.axis.description.ParameterDesc [] _params;
        _params = new org.apache.axis.description.ParameterDesc [] {
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("http://localhost/STIP/", ">PushOrderFile>fileName"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"), java.lang.String.class, false, false), 
        };
        _oper = new org.apache.axis.description.OperationDesc("pushOrderFile", _params, new javax.xml.namespace.QName("http://localhost/STIP/", "PushOrderFileResult"));
        _oper.setReturnType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        _oper.setElementQName(new javax.xml.namespace.QName("http://localhost/STIP/", "PushOrderFile"));
        _oper.setSoapAction("http://localhost/STIP/PushOrderFile");
        _myOperationsList.add(_oper);
        if (_myOperations.get("pushOrderFile") == null) {
            _myOperations.put("pushOrderFile", new java.util.ArrayList());
        }
        ((java.util.List)_myOperations.get("pushOrderFile")).add(_oper);
    }

    public BritemoonOrderPlacementServiceSoapSkeleton() {
        this.impl = new com.britemoon.cps.xcs.cti.BritemoonOrderPlacementServiceSoapImpl();
    }

    public BritemoonOrderPlacementServiceSoapSkeleton(com.britemoon.cps.xcs.cti.BritemoonOrderPlacementServiceSoap impl) {
        this.impl = impl;
    }
    public java.lang.String pushOrderFile(java.lang.String fileName) throws java.rmi.RemoteException
    {
        java.lang.String ret = impl.pushOrderFile(fileName);
        return ret;
    }

}
