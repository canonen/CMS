package com.britemoon.cps.xcs.cti.bean;


public class MessageActivity  {

     private String campId;
     private String ctiOrderId;
     private String recipId;
     private String msgId;
     private String recipEmailAddr;
     private String sendDate;
     private String optOutDate;
     private String bounceBackDate;
     private String bounceBackReason;

     public MessageActivity () {
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

     public String getMsgId() {
          return msgId;
     }
     public void setMsgId(String aMsgId) {
          msgId = aMsgId;
     }
     
     public String getRecipId() {
          return recipId;
     }
     public void setRecipId(String aRecipId) {
          recipId = aRecipId;
     }
     
     public String getRecipEmailAddr() {
          return recipEmailAddr;
     }
     public void setRecipEmailAddr(String aRecipEmailAddr) {
          recipEmailAddr = aRecipEmailAddr;
     }

     public String getSendDate() {
          return sendDate;
     }
     public void setSendDate(String aSendDate) {
          sendDate = aSendDate;
     }
     
     public String getOptOutDate() {
          return optOutDate;
     }
     public void setOptOutDate(String aOptOutDate) {
          optOutDate = aOptOutDate;
     }

     public String getBounceBackDate() {
          return bounceBackDate;
     }
     public void setBounceBackDate(String aBounceBackDate) {
          bounceBackDate = aBounceBackDate;
     }

     public String getBounceBackReason() {
          return bounceBackReason;
     }
     public void setBounceBackReason(String aBounceBackReason) {
          bounceBackReason = aBounceBackReason;
     }

     
     
}