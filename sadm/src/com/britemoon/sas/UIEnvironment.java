package com.britemoon.sas;

import com.britemoon.*;
import java.io.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class UIEnvironment
{
	private SystemUser m_SystemUser = null;
	private Partner m_Partner = null;
	
	// === for Kevin to keep per session settings ===	
	
	private Properties m_Props = null;
	
	public String getProp(String key) { return m_Props.getProperty(key); }
	public Object setProp(String key, String value) { return m_Props.setProperty(key, value); }
	public Properties getProps() { return m_Props; }
	
	// obsolete
	public String getSessionProperty(String key) { return getProp(key); }
	public Object setSessionProperty(String key, String value) { return setProp(key, value); }
	public Properties getSessionProperties() { return getProps(); }

	// === === ===

	// === Constructors ===
	
	public UIEnvironment(HttpSession session, SystemUser systemuser, Partner part) throws Exception
	{
		setup(session, systemuser, part);
		session.setAttribute("ui", this);
	}
	
	private void setup(HttpSession session, SystemUser systemuser, Partner part) throws Exception
	{
		m_SystemUser = systemuser;
		m_Partner = part;
		
		session.setAttribute("part", part);
		session.setAttribute("systemuser", systemuser);
		
	}

	// === === ===

}
