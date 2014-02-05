<%@ page contentType="text/html;charset=UTF-8"%>
<%@ page import="com.swufe.user.*"%>
<jsp:useBean id="Data" scope="page" class="com.swufe.data.SQLServer" />
<jsp:useBean id="stringUtil" scope="page" class="com.swufe.toolkit.StringUtil" />
<%
	request.setCharacterEncoding("UTF-8");
	response.setHeader("Cache-Control", "no-cache");
	String sql = "";
	int ActionID = stringUtil.convertAction(request.getParameter("Action"));
	String id = stringUtil.nullValue(request.getParameter("id"), "");
	String title = stringUtil.nullValue(request.getParameter("title"), "");
	String content = stringUtil.nullValue(request.getParameter("content"), "");
	LoginModel login = new LoginModel(request, response);
	try {
		switch (ActionID) {
		case 3:
			sql = " insert into system_sms (uidFrom,title,content,uidTo)";
			sql += " SELECT  '"+login.getUserId()+"' as uidFrom,'"+title+"' as title,'"+content+"' as content,user_id from "
                                + "user_info where user_id in(" + stringUtil.strComma2Singlequotes(id) + ")";
			break;
		case 5:
			sql = " update system_sms set status=0 where id in(" + stringUtil.strComma2Singlequotes(id) + ")";
			break;
		   }
        out.print(Data.updateJSON(sql));
    } catch (Exception e) {
        out.print(stringUtil.getResultJson(false, e.toString()));
    } finally {
        Data.close();
    }
%>