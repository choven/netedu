<%@ page contentType="text/html;charset=UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="org.json.*"%>
<%@ page import="com.swufe.toolkit.*"%>
<%@ page import="com.swufe.user.*"%>
<jsp:useBean id="Data" scope="page" class="com.swufe.data.SQLServer" />
<jsp:useBean id="stringUtil" scope="page" class="com.swufe.toolkit.StringUtil" />
<%
    request.setCharacterEncoding("UTF-8");
    response.setHeader("Cache-Control", "no-cache");
    String sql = "";
    int ActionID = stringUtil.convertAction(request.getParameter("Action"));
    String id = StringUtil.nullValue(request.getParameter("id"), "");
    String content = StringUtil.nullValue(request.getParameter("content"), "");
    String title = StringUtil.nullValue(request.getParameter("title"), "");
    String code = StringUtil.nullValue(request.getParameter("code"), "");
    String url = StringUtil.nullValue(request.getParameter("url"), "");
    LoginModel login = new LoginModel(request, response);
    try {
        Enumeration<String> e = request.getParameterNames();
        switch (ActionID) {
            case 3:
                // 新添
                id = StringUtil.nullValue(Data.queryScalar("select id from module_info where code='" + code + "'"), "-1");
                if ("-1".equals(id)) {
                    title = "系统";
                }
                sql = " INSERT INTO help_center(module_id,title,ques_content,ques_uid,sys_info,ip)  ";
                sql += "values(" + id + ", '" + login.getUserName() + "关于《" + title + "》的咨询','" + content + "','" + login.getUserId() + "','" + url + ";" + request.getHeader("User-Agent") + "','" + login.getIpAddr() + "') ";
                //out.print(sql);
                break;
        }
        out.print(Data.updateJSON(sql));
    } catch (Exception e) {
        out.print(stringUtil.getResultJson(false, e.toString()));
    } finally {
        Data.close();
    }
%>