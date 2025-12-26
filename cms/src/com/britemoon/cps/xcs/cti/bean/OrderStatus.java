package com.britemoon.cps.xcs.cti.bean;

public class OrderStatus {

     private int    statusId;
     private String statusName;

     public OrderStatus() {
     }

     public int getStatusId() {
          return statusId;
     }
     public void setStatusId(int iVal) {
          statusId = iVal;
     }

     public String getStatusName() {
          return statusName;
     }
     public void setStatusName(String sVal) {
          statusName = sVal;
     }

}