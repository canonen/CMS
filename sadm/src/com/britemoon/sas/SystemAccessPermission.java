package com.britemoon.sas;

import com.britemoon.*;
import com.britemoon.cps.AccessRight;

public class SystemAccessPermission
{
	//public boolean bCreate = false;
	public boolean bRead = false;
	public boolean bWrite = false;
	public boolean bExecute = false;
	public boolean bDelete = false;	
	public boolean bEdit = false;	
    public boolean bApprove = false;
		
	SystemAccessPermission(int iAccessMask)
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