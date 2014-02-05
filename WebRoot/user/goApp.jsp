<%@ page contentType="text/html;charset=UTF-8"%>
<%@ include file="../baseParameter.jsp"%>
<%
    String id = stringUtil.nullValue(request.getParameter("id"));
    ResultSet rs;
    sql = " SELECT [bind_uid],[bind_pwd],[bind_user_type],[open_type]";
    sql += " FROM [user_bind] ";
    sql += " WHERE status=1 AND user_id='" + user_id + "' and id='" + id + "'";
    //out.print(sql);
    String url_app = "";
    String uid_app = "";
    String pwd_app = "";
    rs = Data.executeQuery(sql);
    if (rs.next()) {
        uid_app = rs.getString("bind_uid");
        pwd_app = rs.getString("bind_pwd");
        if ("stu".equals(rs.getString("bind_user_type"))) {//公司
            url_app = "http://" + Config.getHost(request, "admin") + "/netedu/userCheckAuto.jsp";
        } else {
            url_app = "2".equals(rs.getString("open_type")) ? "/" + Config.appCode + "/userCheckAuto.jsp" : "http://" + Config.getOtherWebHost(request) + "/" + Config.appCode + "/userCheckAuto.jsp";
        }
    }
    rs.close();
    Data.close();
    //out.print(sql);
    //json.put("success", new Boolean(true));
    //json.put("uid", uid_app);
    //json.put("pwd", pwd_app);
    //json.put("url", url_app);
%>
<form name="form99" id="form99" method="post" action="<%=url_app%>" style="display:none">
    <input type="hidden" name="uid" value="<%=uid_app%>"/>
    <input type="hidden" name="pwd" value="<%=pwd_app%>"/>
    <input type="hidden" name="page" value="<%=stringUtil.nullValue(request.getParameter("page"), "")%>"/>
    <input type="submit"/>
</form>
<script type="text/javascript">
    document.getElementById("form99").submit();
</script>
