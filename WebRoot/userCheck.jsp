<%@ page language="java" pageEncoding="UTF-8"%>
<%@ page import="com.swufe.user.LoginModel"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=utf-8");
    response.setDateHeader("Expires", 0);
    response.setHeader("Cache-Control", "no-cache");
    response.setHeader("Prama", "no-cache");
    LoginModel login = new LoginModel(request, response);
    String login_name = com.swufe.toolkit.StringUtil.nullValue(request.getParameter("uid"));
    String pwd = com.swufe.toolkit.StringUtil.nullValue(request.getParameter("pwd"));
    if (!login.login(login_name, pwd)) {
        out.print(login.err);
        return;
    } 
%>