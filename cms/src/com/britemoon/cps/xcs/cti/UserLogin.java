package com.britemoon.cps.xcs.cti;

import org.apache.ws.security.WSPasswordCallback;
import org.apache.log4j.*;

import com.britemoon.*;
import com.britemoon.cps.*;

public class UserLogin  {

     private String m_sPassword;
     private String m_sUserName;
     private String m_sCustId;
     private String m_sCustName;
     private static Logger logger = Logger.getLogger(UserLogin.class.getName());

     public UserLogin (String sLogin) throws Exception{
          m_sPassword = null;
          m_sUserName = null;
          m_sCustId = null;
          m_sCustName = null;
          getUser(sLogin);
     }

     public String getPassword() {
          return m_sPassword;
     }

     public String getUserName() {
          return m_sUserName;
     }

     public String getCustName() {
          return m_sCustName;
     }

     public String getCustId() {
          return m_sCustId;
     }

     private void getUser(String sLogin)  throws Exception{

          //System.out.println("In WS-UserLogin");

          try {
               // Parse Customer name and user name from sLogin
               // format should be 'custname;username'

               try {
                    int iSeparator = sLogin.indexOf(";");
                    m_sCustName = sLogin.substring(0, iSeparator);
                    m_sUserName = sLogin.substring(iSeparator + 1);
               } catch (Exception e) {
                    throw new Exception("Malformed Username.  Username should be in the format 'customer;username'");
               }

               //System.out.println("Cust:" + sCustName + " ...;... User:"+sUserName);
               
               //verify that the customer is active
               Customer cust = new Customer(null, m_sCustName);
               boolean bIsCustActive = ((cust.s_status_id != null) && (CustStatus.ACTIVATED == Integer.parseInt(cust.s_status_id)));

               //verify that the user is active
               User user = new User(null, m_sUserName, cust.s_cust_id);
               boolean bIsUserActive = ((user.s_status_id != null) && (UserStatus.ACTIVATED == Integer.parseInt(user.s_status_id)));

               //if customer and user are in active status, return the password for the user.
               //System.out.println("CustActive:" + bIsCustActive);
               //System.out.println("UserActive:" + bIsUserActive);
               if ( bIsCustActive && bIsUserActive ) {
                    m_sPassword = user.s_password;
                    m_sCustId = cust.s_cust_id;
               } else {
                    m_sPassword = null;
                    m_sCustId = null;
               }
          } catch (Exception e) 
		  {
               logger.error("Exception: " , e);
               throw e;
          }

     }

}
