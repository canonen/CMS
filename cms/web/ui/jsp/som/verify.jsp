// get session object do not create new one
HttpSession scope = request.getSession(false);
int custId = 0;

// get customer id if not set redirect to error page
if(scope.getAttribute("custId") != null)
{
	System.out.println("CUST ID IS settttttttttt");
	custId = Integer.parseInt((String)scope.getAttribute("custId"));	
} else {
	System.out.println("CUST ID IS NULL SHOULD REDIRECT");
	request.getRequestDispatcher("index.jsp").forward(request, response);
}

// first check session object for accounts
if(scope.getAttribute("accounts") == null)
{
	System.out.println("accounts null SHOULD REDIRECT");
	request.getRequestDispatcher("index.jsp").forward(request, response);
} else {
	System.out.println("accounts is FULL SHOULD REDIRECT");

}