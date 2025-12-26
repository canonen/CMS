package com.britemoon.cps;

import java.sql.Connection;

public interface BriteConnectionPoolInterface
{
	public Connection getConnection(Object obj) throws Exception;
    public void free(Connection conn);
}
