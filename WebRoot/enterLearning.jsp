<%@ page contentType="text/html;charset=UTF-8"%>
<%@ include file="baseParameter.jsp"%>
<%
try {
	//先利用统一身份认证中的应用授权，找到EMS对应的统一身份认证的UID,再找到授权中的119系统的UID,对应119中的login_name
	String  user_id_119="",login_name_119="",login_password_119="",login_name_learning="",login_password_learning="";
	String url = "http://" + com.swufe.toolkit.host.getHost(request, "admin") + "/learning/netedu_login.jsp";
	String learning_course_id = StringUtil.nullValue(request.getParameter("learning_course_id"));
	String course_name = StringUtil.nullValue(request.getParameter("course_name"));

	sql = "   select  ui.user_id,ui.login_name,ui.login_password  FROM [swufe_user].[dbo].[user_perm] up ";
	sql += "   inner join swufe_online.dbo.user_info ui on ui.login_name=up.uid_old ";
	sql += "   where uid=(SELECT  uid ";
	sql += "   FROM [swufe_user].[dbo].[user_perm] where uid_old='"+uid+"' and web_app_info_id=4) and web_app_info_id=11 ";
	rs = Data.executeQuery(sql); 
	if (rs.next()) {
		user_id_119=rs.getString("user_id");
		login_name_119=rs.getString("login_name");
		login_password_119=rs.getString("login_password");		
	}else{
		out.print("您没有获得综合管理系统的应用授权，请联系技术部门！");
		return;

	}

	sql = " select top 1 login_name,login_password";
	sql += " FROM [learning_swufe].[dbo].[user_info] where third_party_id='"+user_id_119+"'";
	rs = Data.executeQuery(sql);   
	if (rs.next()) {//
		login_name_learning = rs.getString("login_name");
		login_password_learning = rs.getString("login_password");
	} else{//同步数据到学习平台
		sql=" insert into [learning_swufe].[dbo].[user_info] (user_id,login_name,user_name,registed_date,login_password,user_type,third_party_id,status) ";
		sql+=" values('"+user_id_119+"','"+login_name_119+"','"+name+"',getdate(),'"+login_password_119+"','admin','"+user_id_119+"',1)";
		Data.executeUpdate(sql);
		if (Data.err.length() == 0) {
			login_name_learning=login_name_119;
			login_password_learning=login_password_119;
		}else{
			out.print("同步您的帐户到学习平台失败，请联系技术部门！");
			return;
		}
	}

%>
<form name="form99" id="form99" method="post" action="<%=url%>">
<input type="hidden" name="txtLoginName" value="<%=login_name_learning%>"/>
<input type="hidden" name="txtPassword" value="<%=login_password_learning%>"/>
<input type="hidden" name="txtCourseName" value="<%=course_name%>"/>
<input type="hidden" name="txtCourseId" value="<%=learning_course_id%>"/>
<input type="hidden" name="txtIsGraduated" value="0"/>
<input type="hidden" name="txtUserType" value="admin"/>
 
<input type="submit" style="display:none">
</form>
<script type="text/javascript">
	document.getElementById("form99").submit();
</script>
<%
	} catch (Exception e) { 
	 out.print(e.toString());   
	}
%>