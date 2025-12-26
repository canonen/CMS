package com.britemoon.cps;

public final class AccessRight
{
	//public static final int	CREATE = 0x00000001;
	public static final int	READ = 0x00000002;
	public static final int	WRITE = 0x00000004;
	public static final int	EXECUTE = 0x00000008;
	public static final int	DELETE = 0x00000010;
     public static final int    APPROVE = 0x00000020;
	public static final int	EDIT = READ | WRITE;
}
