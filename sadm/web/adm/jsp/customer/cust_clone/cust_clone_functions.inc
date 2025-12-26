<%!
private static void fixIds(Customer clone)
{
	if(clone.m_FromAddresses != null)
	{
		FromAddress fa = null;
		for (Enumeration e = clone.m_FromAddresses.elements() ; e.hasMoreElements() ;)
		{
			fa = (FromAddress)e.nextElement();
			fa.s_from_address_id = null;
		}
	}

	if(clone.m_UnsubMsgs != null)
	{
		UnsubMsg um = null;
		for (Enumeration e = clone.m_UnsubMsgs.elements() ; e.hasMoreElements() ;)
		{
			um = (UnsubMsg)e.nextElement();
			um.s_msg_id = null;
		}
	}

	if(clone.m_Users != null)
	{
		User u = null;
		for (Enumeration e = clone.m_Users.elements() ; e.hasMoreElements() ;)
		{
			u = (User)e.nextElement();
			u.s_user_id = null;
		}
	}
	
	if(clone.m_CustModInsts != null)
	{
		CustModInst cmi = null;
		for (Enumeration e = clone.m_CustModInsts.elements() ; e.hasMoreElements() ;)
		{
			cmi = (CustModInst)e.nextElement();
			if(cmi.m_VanityDomains == null) continue;
			
			VanityDomain vd = null;
			for (Enumeration ee = cmi.m_VanityDomains.elements() ; ee.hasMoreElements() ;)
			{
				vd = (VanityDomain)ee.nextElement();
				vd.s_domain_id = null;
			}
		}
	}
	
	if(clone.m_AprvlCusts != null)
	{
		AprvlCust ac = null;
		for (Enumeration e = clone.m_AprvlCusts.elements() ; e.hasMoreElements() ;)
		{
			ac = (AprvlCust)e.nextElement();
			ac.s_cust_id = null;
		}
	}	
}
%>