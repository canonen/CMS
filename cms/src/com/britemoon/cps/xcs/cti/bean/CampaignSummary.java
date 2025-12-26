package com.britemoon.cps.xcs.cti.bean;


public class CampaignSummary  {

     private String campId;
     private String ctiOrderId;
     private String lastUpdateDate;
     private String sendDate;
     private int    bbackQty;
     private int    unsubQty;
     private int    readQty;
     private int    clickQty;

     public CampaignSummary () {
     }

     public String getCampId() {
          return campId;
     }
     public void setCampId(String aCampId) {
          campId = aCampId;
     }

     public String getCtiOrderId() {
          return ctiOrderId;
     }
     public void setCtiOrderId(String aCtiOrderId) {
          ctiOrderId = aCtiOrderId;
     }

     public String getSendDate() {
          return sendDate;
     }
     public void setSendDate(String aSendDate) {
          sendDate = aSendDate;
     }

     public String getLastUpdateDate() {
          return lastUpdateDate;
     }
     public void setLastUpdateDate(String aDate) {
          lastUpdateDate = aDate;
     }
     
     public int getBbackQty() {
          return bbackQty;
     }
     public void setBbackQty(int iVal) {
          bbackQty = iVal;
     }

     public int getUnsubQty() {
          return unsubQty;
     }
     public void setUnsubQty(int iVal) {
          unsubQty = iVal;
     }

     public int getReadQty() {
          return readQty;
     }
     public void setReadQty(int iVal) {
          readQty = iVal;
     }

     public int getClickQty() {
          return readQty;
     }
     public void setClickQty(int iVal) {
          clickQty = iVal;
     }


     
     
}