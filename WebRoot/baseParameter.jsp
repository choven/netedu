<%@ page contentType="text/html;charset=UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="com.swufe.toolkit.*"%>
<%@ page import="com.swufe.data.*"%>
<%@ page import="com.swufe.user.*"%>
<%@ page import="com.swufe.module.*"%>

<jsp:useBean id="Data" scope="page" class="com.swufe.data.SQLServer" />
<jsp:useBean id="stringUtil" scope="page" class="com.swufe.toolkit.StringUtil" />
<%
	request.setCharacterEncoding("UTF-8");
	response.setHeader("Cache-Control", "no-cache");
	String ModName =PathUtil.getFileBaseName(request.getRequestURI().toString());
	LoginModel login = new LoginModel(request, response);
	//login.addPageLog();
	String user_id = login.getUserId();
        String user_name = login.getUserName();
	if (user_id == null || "".equals(user_id)) {
		response.sendRedirect("login.jsp");
		return;
	}
	int ActionID = stringUtil.convertAction(request.getParameter("Action"));
        String sql = "";
	StringBuffer sb = new StringBuffer();
%>