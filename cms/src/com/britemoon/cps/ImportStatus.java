package com.britemoon.cps;

final public class ImportStatus
{
	final public static int DOWNLOADED = 1;
	final public static int PENDING_APPROVAL = 7;
	final public static int READY_FOR_PREPROCESS = 10;
	final public static int PREPROCESSING = 15;
	final public static int TEMP_FILE_READY = 20;
	final public static int CLEANING = 25;
	final public static int IN_STAGING = 30;
	final public static int REJECTED = 35;
	final public static int READY_FOR_COMMIT = 40;
	final public static int COMMIT_PROCESSING = 45;
	final public static int COMMIT_COMPLETE = 50;
	final public static int ROLLBACK = 60;
	final public static int ERROR = 70;
	final public static int ERROR_IN_FILE_CREATION = 71;
	final public static int ERROR_IN_PREPROCESSING = 72;
	final public static int DELETED = 80;
}
