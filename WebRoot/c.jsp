<%@ page language="java" pageEncoding="UTF-8"%>
<%@ page import="java.text.*"%>
<%@ page import="java.util.*"%>
<%@ page import="com.swufe.toolkit.*"%>
<%@ page import="com.swufe.user.*"%>
<jsp:useBean id="Data" scope="page" class="com.swufe.data.SQLServer" />
<%
	request.setCharacterEncoding("UTF-8");
	LoginModel login = new LoginModel(request, response);
        out.print(login.getUserId());
	String modUrl=Perm.getUserPerm(login.getUserId(),"url");
	out.print("modUrl=" + modUrl);
%>