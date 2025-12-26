<%!
    public class DBResourceUtil {
        private final org.apache.log4j.Logger loggerDbUtil =
                org.apache.log4j.Logger.getLogger(DBResourceUtil.class);

        public void closeResources(
                java.sql.ResultSet rs,
                java.sql.Statement stmt,
                java.sql.Connection conn,
                com.britemoon.cps.ConnectionPool cp) {

            closeResultSet(rs);
            closeStatement(stmt);
            cleanAndReleaseConnection(conn, cp);
        }

        private void closeResultSet(java.sql.ResultSet rs) {
            if (rs != null) {
                try {
                    rs.close();
                } catch (java.sql.SQLException e) {
                    loggerDbUtil.error("ResultSet close error", e);
                }
            }
        }

        private void closeStatement(java.sql.Statement stmt) {
            if (stmt != null) {
                try {
                    stmt.close();
                } catch (java.sql.SQLException e) {
                    loggerDbUtil.error("Statement close error", e);
                }
            }
        }

        private void cleanAndReleaseConnection(
                java.sql.Connection conn,
                com.britemoon.cps.ConnectionPool cp) {

            if (conn == null) return;

            try {
                if (!conn.getAutoCommit()) {
                    try {
                        conn.rollback();
                    } catch (java.sql.SQLException e) {
                        loggerDbUtil.error("Rollback error", e);
                    }
                    try {
                        conn.setAutoCommit(true);
                    } catch (java.sql.SQLException e) {
                        loggerDbUtil.error("Reset autocommit error", e);
                    }
                }
            } catch (java.sql.SQLException e) {
                loggerDbUtil.error("Connection state check error", e);
            }

            releaseConnection(conn, cp);
        }

        private void releaseConnection(
                java.sql.Connection conn,
                com.britemoon.cps.ConnectionPool cp) {

            if (cp != null) {
                try {
                    cp.free(conn);
                } catch (Exception e) {
                    loggerDbUtil.error("Connection free error", e);
                    forceClose(conn);
                }
            } else {
                forceClose(conn);
            }
        }

        private void forceClose(java.sql.Connection conn) {
            try {
                if (conn != null && !conn.isClosed()) {
                    conn.close();
                }
            } catch (java.sql.SQLException e) {
                loggerDbUtil.error("Fallback connection close error", e);
            }
        }
    }
%>