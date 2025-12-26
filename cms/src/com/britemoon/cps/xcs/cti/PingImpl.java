package com.britemoon.cps.xcs.cti;

import com.britemoon.*;

import java.io.*;
import java.util.*;
import org.w3c.dom.*;

public class PingImpl  {


     public String echo(String sMsg) {
          String sEcho = null;
          sEcho = "Received: " + sMsg;
          return sEcho;
     }

     public String ping() {
          String sPing = "PING successful";

          return sPing;
     }


    

     
}