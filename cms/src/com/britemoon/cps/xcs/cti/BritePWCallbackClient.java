

package com.britemoon.cps.xcs.cti;

import org.apache.ws.security.WSPasswordCallback;

import javax.security.auth.callback.Callback;
import javax.security.auth.callback.CallbackHandler;
import javax.security.auth.callback.UnsupportedCallbackException;
import java.io.IOException;
import org.apache.log4j.*;

public class BritePWCallbackClient implements CallbackHandler {
	private static Logger logger = Logger.getLogger(BritePWCallbackClient.class.getName());

	public void handle(Callback[] callbacks)
		throws UnsupportedCallbackException {

          logger.info("starting BritePWCallbackClient...");

		for (int i = 0; i < callbacks.length; i++) {
               //System.out.println("callbacks[] is a:" + callbacks[i].getClass().getName());

			if (callbacks[i] instanceof org.apache.ws.security.WSPasswordCallback) {
                    //System.out.println("callback is a callback");
				WSPasswordCallback pc = (WSPasswordCallback) callbacks[i];
				/*
				 * here call a function/method to lookup the password for
				 * the given identifier (e.g. a user name or keystore alias)
				 * e.g.: pc.setPassword(passStore.getPassword(pc.getIdentfifier))
				 * for Testing we supply a fixed name here.
				 */
                    if (pc.getIdentifer().equalsIgnoreCase("qa;cti_user")) {
                         pc.setPassword("cti_password");
                    }
                    if (pc.getIdentifer().equalsIgnoreCase("Marsh QA;cti_user")) {
                         pc.setPassword("cti_m@r5h");
                    }
                    if (pc.getIdentifer().equalsIgnoreCase("britemoon_user")) {
                         pc.setPassword("britemoon_password");
                    }
                    if (pc.getIdentifer().equalsIgnoreCase("testusername")) {
	                    pc.setPassword("password");
                    }
                    if (pc.getIdentifer().equalsIgnoreCase("Britemoon1")) {
                         pc.setPassword("Br!tm@@n");
                    }
                    if (pc.getIdentifer().equalsIgnoreCase("DELTABROKER1\\Britemoon1")) {
                         pc.setPassword("Br!tm@@n");
                    }
			}
               else
               {
/*                    System.out.println("callbacks[i] is " + callbacks[i].getClass().getName());
                    System.out.println("callbacks[i]" + callbacks[i]);
                    System.out.println("Callback is NOT a WSCallback");
                    System.out.flush();
*/
				throw new UnsupportedCallbackException(
					callbacks[i],
					"Unrecognized Callback");
			}
		}
	}
}
