package com.britemoon.cps.xcs.cti;

import org.apache.ws.security.WSPasswordCallback;

import org.apache.axis.MessageContext;

import javax.security.auth.callback.Callback;
import javax.security.auth.callback.CallbackHandler;
import javax.security.auth.callback.UnsupportedCallbackException;
import java.io.IOException;

public class BritePWCallbackServer implements CallbackHandler {

  private static final byte[] key = {
    (byte)0x31, (byte)0xfd, (byte)0xcb, (byte)0xda,
    (byte)0xfb, (byte)0xcd, (byte)0x6b, (byte)0xa8,
    (byte)0xe6, (byte)0x19, (byte)0xa7, (byte)0xbf,
    (byte)0x51, (byte)0xf7, (byte)0xc7, (byte)0x3e,
    (byte)0x80, (byte)0xae, (byte)0x98, (byte)0x51,
    (byte)0xc8, (byte)0x51, (byte)0x34, (byte)0x04,
  };

     public void handle(Callback[] callbacks) throws UnsupportedCallbackException {

          String sLogin = null;
          String sPassword = null;
          for (int i = 0; i < callbacks.length; i++) {
               if (callbacks[i] instanceof WSPasswordCallback) {
                    WSPasswordCallback pc = (WSPasswordCallback) callbacks[i];
                     if (pc.getUsage() == WSPasswordCallback.KEY_NAME) {
                         pc.setKey(key);
                    } else {
                         sLogin = pc.getIdentifer();
                    }
                    try {
                         UserLogin ulLogin = new UserLogin(sLogin);
                         // get the password from UserLogin based on sLogin (sLogin should be in the format 'customername;username'
                         sPassword = ulLogin.getPassword();
                         // also set the custId property in the MessageContext for use in later objects
                         String sCustId = ulLogin.getCustId();
                         if (sCustId != null)
                              MessageContext.getCurrentContext().setProperty("CUST_ID",sCustId);
                         else
                              throw new Exception("Customer information not complete.  Failed security processing.");
                    } catch (Exception e) {
                         throw new UnsupportedCallbackException(
                              callbacks[i], e.getMessage());
                    }
                    if (sPassword != null) {
                         pc.setPassword(sPassword);
                    } 
/* The following two statements are for testing purposes only!!  Remove them for live system!! */
/*                    else if (pc.getIdentifer().equalsIgnoreCase("werner")) {
                         pc.setPassword("security");
                    } else if (pc.getIdentifer().equalsIgnoreCase("cti_user")) {
                         pc.setPassword("cti_password");
                    } 
*/
                    else {
                         pc.setPassword(null);
                    }
			} else {
				throw new UnsupportedCallbackException(
					callbacks[i],
					"Unrecognized Callback");
			}
		}
	}
}
