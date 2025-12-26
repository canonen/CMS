package com.britemoon.cps.xcs.cti.dao;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.xcs.cti.bean.*;
import com.britemoon.cps.xcs.cti.*;
import com.britemoon.cps.imc.*;

import java.io.*;
import java.sql.*;
import java.util.*;
import java.net.*;
import org.apache.log4j.*;


public class OrderDAO
{

	private Logger logger = Logger.getLogger(OrderDAO.class.getName()); 
	public OrderDAO() {
	}

	public String getCtiOrderId(String sBriteOrderId) throws Exception {

          //System.out.println("In " + this.getClass().getName() + "; BriteOrderID:"+sBriteOrderId+".");
          ConnectionPool cp = null;
          Connection conn = null;
          PreparedStatement pstmt = null;
          ResultSet rs = null;
          String sCtiOrderId = null;

          try {
               cp = ConnectionPool.getInstance();
               conn = cp.getConnection(this);

               String sSql = "Select o.cust_order_id " +
                                        " FROM cxcs_order o " +
                                        " WHERE o.brite_order_id = ? ";
               pstmt = conn.prepareStatement(sSql);
               pstmt.setString(1, sBriteOrderId);
                    
               rs = pstmt.executeQuery();

               if (rs.next()) {
                    sCtiOrderId = rs.getString(1);
               }
               rs.close();

               return sCtiOrderId;
          } catch (Exception e) 
		  {
          	logger.error("Exception: " , e);
            throw e;
          } finally {
               if (pstmt != null) {
                    try {
                         pstmt.close();
                    } catch (Exception e) {
                         throw e;
                    }
               }
               if (cp != null) cp.free(conn);
          }

	}

	public String getCustId(String sBriteOrderId) throws Exception {

          //System.out.println("In " + this.getClass().getName() + "; BriteOrderID:"+sBriteOrderId+".");
          ConnectionPool cp = null;
          Connection conn = null;
          PreparedStatement pstmt = null;
          ResultSet rs = null;
          String sCustId = null;

          try {
               cp = ConnectionPool.getInstance();
               conn = cp.getConnection(this);

               String sSql = "Select o.cust_id " +
                                        " FROM cxcs_order o " +
                                        " WHERE o.brite_order_id = ? ";
               pstmt = conn.prepareStatement(sSql);
               pstmt.setString(1, sBriteOrderId);
                    
               rs = pstmt.executeQuery();

               if (rs.next()) {
                    sCustId = rs.getString(1);
               }
               rs.close();

               return sCustId;
          } catch (Exception e) 
		  {
          	   logger.error("Exception: ", e);	
               throw e;
          } finally {
               if (pstmt != null) {
                    try {
                         pstmt.close();
                    } catch (Exception e) {
                         throw e;
                    }
               }
               if (cp != null) cp.free(conn);
          }

	}


}

