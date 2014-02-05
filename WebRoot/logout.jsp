<%@ page contentType="text/html;charset=UTF-8"%>
<%@ page import="java.text.*"%>
<%@ page import="java.util.*"%>
<%@ page import="com.swufe.data.*"%>
<%@ page import="com.swufe.user.*"%>
<jsp:useBean id="Data" scope="page" class="com.swufe.data.SQLServer" />
<%
	// 更新在线时间
	ActionLog actionLog = new ActionLog();
	String sSessionID = session.getId();
	String sUserName = (String) session.getAttribute("sUserName");
	String sql = "UPDATE " + Constant.sTableName_user + " SET online_flag=0,last_logout=getDate() WHERE uid='" + sUserName + "' ";
	int result = Data.executeUpdate(sql);
	if (result == 0) {
		out.print("更新出错：" + sql);
	} else {
		out.print("更新行数：" + result);
	}
	Calendar cal = Calendar.getInstance();
	SimpleDateFormat formatter = new SimpleDateFormat("yyyy-M-d H:mm:ss");
	String tmpDateStr = formatter.format(cal.getTime());
	sql = " UPDATE " + Constant.sTableName_log + " SET out_time ='" + tmpDateStr + "'";
	sql += " WHERE SessionID ='" + sSessionID + "' ";
	result = Data.executeUpdate(sql);
	String auto = (String) session.getAttribute("auto");
	// 注销 session
	session.invalidate();
	LoginModel login = new LoginModel(request, response,false);
	login.setCookie("modUrl","",0);
	login.setCookie("curr_bj_bm", "",0);
	login.setCookie("curr_bj_mc", "",0);
	//request.getSession(true).invalidate();
	if (auto!=null && "auto".equals(auto)) {
		out.print("<script type='text/javascript'>window.opener=null;window.open('','_self');window.close();</script>");
	} else {
		response.sendRedirect(Constant.sContextPath);
	}
%>