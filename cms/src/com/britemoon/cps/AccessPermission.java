package com.britemoon.cps;

import com.britemoon.*;

import java.util.logging.Logger;


public class AccessPermission
{
	//public boolean bCreate = false;
	public boolean bRead = false;
	public boolean bWrite = false;
	public boolean bExecute = false;
	public boolean bDelete = false;	
	public boolean bEdit = false;	
     public boolean bApprove = false;
     private static Logger logger = Logger.getLogger(AccessPermission.class.getName());
		
	AccessPermission(int iAccessMask)
	{
		//bCreate = (( iAccessMask & AccessRight.CREATE ) == AccessRight.CREATE );
		bRead = (( iAccessMask & AccessRight.READ ) == AccessRight.READ );
		bWrite = (( iAccessMask & AccessRight.WRITE ) == AccessRight.WRITE );
		bExecute = (( iAccessMask & AccessRight.EXECUTE ) == AccessRight.EXECUTE );
		bDelete = (( iAccessMask & AccessRight.DELETE ) == AccessRight.DELETE );
		bApprove = (( iAccessMask & AccessRight.APPROVE ) == AccessRight.APPROVE );
		bEdit = bRead && bWrite;
	}
}