<%@page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.swufe.user.*"%>
<%
	//response.sendRedirect("/user");
	LoginModel login = new LoginModel(request, response);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE9" />
<title>西财在线--教务管理系统</title>
<script language="javascript" type="text/javascript" src="/file/jquery/jquery-1.4.4.min.js"></script>
<link rel="stylesheet" type="text/css" href="http://www.swufe-online.com/demo/images/login.css" />
<script type="text/javascript">
function postdata() {
	$.ajax({
		type:'POST',url:'userCheck.jsp',data:'uid='+$('#uid').val()+'&pwd='+$('#pwd').val(),
		success:function(msg){
			msg=$.trim(msg);if (msg=='') {window.location.href='index.jsp';} else {alert(msg);$('#pwd').select();}
		}
	});
}
function CheckForm(){
	if($('#uid').val()=='') {
		alert('请输入登录教务管理系统的用户名！     ');$('#uid').focus();return false;
	}
	if($('#pwd').val()=='') {
		alert('请输入设定的登录密码！     ');$('#pwd').select();return false;
	}
	postdata();
}
$(function(){
	$('#uid,#pwd').keydown(function(event){if (event.keyCode==13) {postdata();}}).focus(function(){this.select();});
});
</script>
</head>
<body>
<div class="page">
  <div class="bg content">
    <input id="uid" name="uid" class="iptuser" type="text" />
    <input id="pwd" name="pwd" class="iptpwd" type="password" />
    <div class="dl">
      <input id="login" name="login" class="subdl" type="button" value="登 录" onclick="return CheckForm();" />
      <input class="rest1" type="reset" value="重 置" />
    </div>
    <div class="fanhui"><a href="/v2010/index.jsp">点此返回-- 西财在线--西部财经从业人员终生学习基地</a></div>
    <div style="width:100%;text-align:left;text-indent:12px;padding-top:12px;padding-left:20px;"><b>提示：</b></div>
  </div>
</div>
</body>
</html>