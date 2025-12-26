/**
 * ContentSoapSkeleton.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.2RC2 Nov 16, 2004 (12:19:44 EST) WSDL2Java emitter.
 */

package com.britemoon.cps.xcs.cti;

public class ContentSoapSkeleton implements com.britemoon.cps.xcs.cti.ContentSoap, org.apache.axis.wsdl.Skeleton {
    private com.britemoon.cps.xcs.cti.ContentSoap impl;
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
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", ">GetBritemoonVariables>groupID"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"), java.lang.String.class, false, false), 
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", ">GetBritemoonVariables>documentID"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"), java.lang.String.class, false, false), 
        };
        _oper = new org.apache.axis.description.OperationDesc("getBritemoonVariables", _params, new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", "GetBritemoonVariablesResult"));
        _oper.setReturnType(new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", "ArrayOfVariablePair"));
        _oper.setElementQName(new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", "GetBritemoonVariables"));
        _oper.setSoapAction("http://www.clicktactics.com/STIP/GetBritemoonVariables");
        _myOperationsList.add(_oper);
        if (_myOperations.get("getBritemoonVariables") == null) {
            _myOperations.put("getBritemoonVariables", new java.util.ArrayList());
        }
        ((java.util.List)_myOperations.get("getBritemoonVariables")).add(_oper);
        _params = new org.apache.axis.description.ParameterDesc [] {
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", ">DeleteExistingDocument>groupID"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"), java.lang.String.class, false, false), 
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", ">DeleteExistingDocument>documentID"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"), java.lang.String.class, false, false), 
        };
        _oper = new org.apache.axis.description.OperationDesc("deleteExistingDocument", _params, new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", "DeleteExistingDocumentResult"));
        _oper.setReturnType(new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", "DocumentOutput"));
        _oper.setElementQName(new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", "DeleteExistingDocument"));
        _oper.setSoapAction("http://www.clicktactics.com/STIP/DeleteExistingDocument");
        _myOperationsList.add(_oper);
        if (_myOperations.get("deleteExistingDocument") == null) {
            _myOperations.put("deleteExistingDocument", new java.util.ArrayList());
        }
        ((java.util.List)_myOperations.get("deleteExistingDocument")).add(_oper);
        _params = new org.apache.axis.description.ParameterDesc [] {
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", ">CloneExistingDocument>groupID"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"), java.lang.String.class, false, false), 
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", ">CloneExistingDocument>oldDocumentID"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"), java.lang.String.class, false, false), 
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", ">CloneExistingDocument>newDocumentName"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"), java.lang.String.class, false, false), 
        };
        _oper = new org.apache.axis.description.OperationDesc("cloneExistingDocument", _params, new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", "CloneExistingDocumentResult"));
        _oper.setReturnType(new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", "DocumentOutput"));
        _oper.setElementQName(new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", "CloneExistingDocument"));
        _oper.setSoapAction("http://www.clicktactics.com/STIP/CloneExistingDocument");
        _myOperationsList.add(_oper);
        if (_myOperations.get("cloneExistingDocument") == null) {
            _myOperations.put("cloneExistingDocument", new java.util.ArrayList());
        }
        ((java.util.List)_myOperations.get("cloneExistingDocument")).add(_oper);
        _params = new org.apache.axis.description.ParameterDesc [] {
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", ">SaveDocumentName>groupID"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"), java.lang.String.class, false, false), 
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", ">SaveDocumentName>documentID"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"), java.lang.String.class, false, false), 
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", ">SaveDocumentName>documentName"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"), java.lang.String.class, false, false), 
        };
        _oper = new org.apache.axis.description.OperationDesc("saveDocumentName", _params, new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", "SaveDocumentNameResult"));
        _oper.setReturnType(new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", "DocumentOutput"));
        _oper.setElementQName(new javax.xml.namespace.QName("http://www.clicktactics.com/STIP/", "SaveDocumentName"));
        _oper.setSoapAction("http://www.clicktactics.com/STIP/SaveDocumentName");
        _myOperationsList.add(_oper);
        if (_myOperations.get("saveDocumentName") == null) {
            _myOperations.put("saveDocumentName", new java.util.ArrayList());
        }
        ((java.util.List)_myOperations.get("saveDocumentName")).add(_oper);
    }

    public ContentSoapSkeleton() {
        this.impl = new com.britemoon.cps.xcs.cti.ContentSoapImpl();
    }

    public ContentSoapSkeleton(com.britemoon.cps.xcs.cti.ContentSoap impl) {
        this.impl = impl;
    }
    public com.britemoon.cps.xcs.cti.ArrayOfVariablePair getBritemoonVariables(java.lang.String groupID, java.lang.String documentID) throws java.rmi.RemoteException
    {
        com.britemoon.cps.xcs.cti.ArrayOfVariablePair ret = impl.getBritemoonVariables(groupID, documentID);
        return ret;
    }

    public com.britemoon.cps.xcs.cti.DocumentOutput deleteExistingDocument(java.lang.String groupID, java.lang.String documentID) throws java.rmi.RemoteException
    {
        com.britemoon.cps.xcs.cti.DocumentOutput ret = impl.deleteExistingDocument(groupID, documentID);
        return ret;
    }

    public com.britemoon.cps.xcs.cti.DocumentOutput cloneExistingDocument(java.lang.String groupID, java.lang.String oldDocumentID, java.lang.String newDocumentName) throws java.rmi.RemoteException
    {
        com.britemoon.cps.xcs.cti.DocumentOutput ret = impl.cloneExistingDocument(groupID, oldDocumentID, newDocumentName);
        return ret;
    }

    public com.britemoon.cps.xcs.cti.DocumentOutput saveDocumentName(java.lang.String groupID, java.lang.String documentID, java.lang.String documentName) throws java.rmi.RemoteException
    {
        com.britemoon.cps.xcs.cti.DocumentOutput ret = impl.saveDocumentName(groupID, documentID, documentName);
        return ret;
    }

}
