/**
 * PackageBrokerWebServiceSoapSkeleton.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis WSDL2Java emitter.
 */

package com.britemoon.cps.xcs.cti;

public class PackageBrokerWebServiceSoapSkeleton implements com.britemoon.cps.xcs.cti.PackageBrokerWebServiceSoap, org.apache.axis.wsdl.Skeleton {
    private com.britemoon.cps.xcs.cti.PackageBrokerWebServiceSoap impl;
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
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("http://clicktactics.com/PackageBrokerWebServices/", "packageID"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"), java.lang.String.class, false, false), 
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("http://clicktactics.com/PackageBrokerWebServices/", "status"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"), java.lang.String.class, false, false), 
        };
        _oper = new org.apache.axis.description.OperationDesc("updatePackageStatus", _params, new javax.xml.namespace.QName("http://clicktactics.com/PackageBrokerWebServices/", "UpdatePackageStatusResult"));
        _oper.setReturnType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        _oper.setElementQName(new javax.xml.namespace.QName("http://clicktactics.com/PackageBrokerWebServices/", "UpdatePackageStatus"));
        _oper.setSoapAction("http://clicktactics.com/PackageBrokerWebServices/UpdatePackageStatus");
        _myOperationsList.add(_oper);
        if (_myOperations.get("updatePackageStatus") == null) {
            _myOperations.put("updatePackageStatus", new java.util.ArrayList());
        }
        ((java.util.List)_myOperations.get("updatePackageStatus")).add(_oper);
        _params = new org.apache.axis.description.ParameterDesc [] {
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("http://clicktactics.com/PackageBrokerWebServices/", "packageItemID"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"), java.lang.String.class, false, false), 
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("http://clicktactics.com/PackageBrokerWebServices/", "status"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"), java.lang.String.class, false, false), 
        };
        _oper = new org.apache.axis.description.OperationDesc("updatePackageItemStatus", _params, null);
        _oper.setElementQName(new javax.xml.namespace.QName("http://clicktactics.com/PackageBrokerWebServices/", "UpdatePackageItemStatus"));
        _oper.setSoapAction("http://clicktactics.com/PackageBrokerWebServices/UpdatePackageItemStatus");
        _myOperationsList.add(_oper);
        if (_myOperations.get("updatePackageItemStatus") == null) {
            _myOperations.put("updatePackageItemStatus", new java.util.ArrayList());
        }
        ((java.util.List)_myOperations.get("updatePackageItemStatus")).add(_oper);
    }

    public PackageBrokerWebServiceSoapSkeleton() {
        this.impl = new com.britemoon.cps.xcs.cti.PackageBrokerWebServiceSoapImpl();
    }

    public PackageBrokerWebServiceSoapSkeleton(com.britemoon.cps.xcs.cti.PackageBrokerWebServiceSoap impl) {
        this.impl = impl;
    }
    public java.lang.String updatePackageStatus(java.lang.String packageID, java.lang.String status) throws java.rmi.RemoteException
    {
        java.lang.String ret = impl.updatePackageStatus(packageID, status);
        return ret;
    }

    public void updatePackageItemStatus(java.lang.String packageItemID, java.lang.String status) throws java.rmi.RemoteException
    {
        impl.updatePackageItemStatus(packageItemID, status);
    }

}
