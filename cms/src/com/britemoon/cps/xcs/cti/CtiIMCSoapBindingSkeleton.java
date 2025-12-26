/**
 * CtiIMCSoapBindingSkeleton.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis WSDL2Java emitter.
 */

package com.britemoon.cps.xcs.cti;

public class CtiIMCSoapBindingSkeleton implements com.britemoon.cps.xcs.cti.CtiImcWebService, org.apache.axis.wsdl.Skeleton {
    private com.britemoon.cps.xcs.cti.CtiImcWebService impl;
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
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("", "sCustId"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"), java.lang.String.class, false, false), 
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("", "sCampId"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"), java.lang.String.class, false, false), 
        };
        _oper = new org.apache.axis.description.OperationDesc("getMessageActivityQty", _params, new javax.xml.namespace.QName("", "getMessageActivityQtyReturn"));
        _oper.setReturnType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "int"));
        _oper.setElementQName(new javax.xml.namespace.QName("urn:cti_imc", "getMessageActivityQty"));
        _oper.setSoapAction("");
        _myOperationsList.add(_oper);
        if (_myOperations.get("getMessageActivityQty") == null) {
            _myOperations.put("getMessageActivityQty", new java.util.ArrayList());
        }
        ((java.util.List)_myOperations.get("getMessageActivityQty")).add(_oper);
        _params = new org.apache.axis.description.ParameterDesc [] {
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("", "sCustId"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"), java.lang.String.class, false, false), 
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("", "sCampId"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"), java.lang.String.class, false, false), 
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("", "sCtiOrderId"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"), java.lang.String.class, false, false), 
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("", "sLastId"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"), java.lang.String.class, false, false), 
        };
        _oper = new org.apache.axis.description.OperationDesc("getMessageActivity", _params, new javax.xml.namespace.QName("", "getMessageActivityReturn"));
        _oper.setReturnType(new javax.xml.namespace.QName("urn:cti_imc", "ArrayOf_tns2_MessageActivity"));
        _oper.setElementQName(new javax.xml.namespace.QName("urn:cti_imc", "getMessageActivity"));
        _oper.setSoapAction("");
        _myOperationsList.add(_oper);
        if (_myOperations.get("getMessageActivity") == null) {
            _myOperations.put("getMessageActivity", new java.util.ArrayList());
        }
        ((java.util.List)_myOperations.get("getMessageActivity")).add(_oper);
        _params = new org.apache.axis.description.ParameterDesc [] {
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("", "sCustId"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"), java.lang.String.class, false, false), 
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("", "sCampId"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"), java.lang.String.class, false, false), 
        };
        _oper = new org.apache.axis.description.OperationDesc("getClickActivityQty", _params, new javax.xml.namespace.QName("", "getClickActivityQtyReturn"));
        _oper.setReturnType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "int"));
        _oper.setElementQName(new javax.xml.namespace.QName("urn:cti_imc", "getClickActivityQty"));
        _oper.setSoapAction("");
        _myOperationsList.add(_oper);
        if (_myOperations.get("getClickActivityQty") == null) {
            _myOperations.put("getClickActivityQty", new java.util.ArrayList());
        }
        ((java.util.List)_myOperations.get("getClickActivityQty")).add(_oper);
        _params = new org.apache.axis.description.ParameterDesc [] {
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("", "sCustId"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"), java.lang.String.class, false, false), 
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("", "sCampId"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"), java.lang.String.class, false, false), 
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("", "sCtiOrderId"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"), java.lang.String.class, false, false), 
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("", "sLastId"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"), java.lang.String.class, false, false), 
        };
        _oper = new org.apache.axis.description.OperationDesc("getClickActivity", _params, new javax.xml.namespace.QName("", "getClickActivityReturn"));
        _oper.setReturnType(new javax.xml.namespace.QName("urn:cti_imc", "ArrayOf_tns2_ClickActivity"));
        _oper.setElementQName(new javax.xml.namespace.QName("urn:cti_imc", "getClickActivity"));
        _oper.setSoapAction("");
        _myOperationsList.add(_oper);
        if (_myOperations.get("getClickActivity") == null) {
            _myOperations.put("getClickActivity", new java.util.ArrayList());
        }
        ((java.util.List)_myOperations.get("getClickActivity")).add(_oper);
    }

    public CtiIMCSoapBindingSkeleton() {
        this.impl = new com.britemoon.cps.xcs.cti.CtiIMCSoapBindingImpl();
    }

    public CtiIMCSoapBindingSkeleton(com.britemoon.cps.xcs.cti.CtiImcWebService impl) {
        this.impl = impl;
    }
    public int getMessageActivityQty(java.lang.String sCustId, java.lang.String sCampId) throws java.rmi.RemoteException
    {
        int ret = impl.getMessageActivityQty(sCustId, sCampId);
        return ret;
    }

    public com.britemoon.cps.xcs.cti.bean.MessageActivity[] getMessageActivity(java.lang.String sCustId, java.lang.String sCampId, java.lang.String sCtiOrderId, java.lang.String sLastId) throws java.rmi.RemoteException
    {
        com.britemoon.cps.xcs.cti.bean.MessageActivity[] ret = impl.getMessageActivity(sCustId, sCampId, sCtiOrderId, sLastId);
        return ret;
    }

    public int getClickActivityQty(java.lang.String sCustId, java.lang.String sCampId) throws java.rmi.RemoteException
    {
        int ret = impl.getClickActivityQty(sCustId, sCampId);
        return ret;
    }

    public com.britemoon.cps.xcs.cti.bean.ClickActivity[] getClickActivity(java.lang.String sCustId, java.lang.String sCampId, java.lang.String sCtiOrderId, java.lang.String sLastId) throws java.rmi.RemoteException
    {
        com.britemoon.cps.xcs.cti.bean.ClickActivity[] ret = impl.getClickActivity(sCustId, sCampId, sCtiOrderId, sLastId);
        return ret;
    }

}
