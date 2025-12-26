package com.britemoon.cps;

import com.britemoon.*;

import java.util.logging.Logger;

public abstract class BriteTask extends BriteTaskGeneric
{
	private static Logger logger = Logger.getLogger(BriteTask.class.getName());
	public int save() throws Exception
	{
		// put code in here to save task to database
		// in case we need to have task history
		//
		// save() is setup to run
		// right at the beginning of start()
		// and when task is finished;
		return 1;
	}

	public int retrieve() throws Exception
	{
		//not yet
		return 1;		
	}

	public int delete() throws Exception
	{
		//do we need it?
		return 1;		
	}
}
