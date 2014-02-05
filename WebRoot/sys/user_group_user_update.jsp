<%@ page contentType="text/html;charset=UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="com.swufe.user.*"%>
<jsp:useBean id="Data" scope="page" class="com.swufe.data.SQLServer" />
<jsp:useBean id="stringUtil" scope="page" class="com.swufe.toolkit.StringUtil" />
<%
    request.setCharacterEncoding("UTF-8");
    response.setHeader("Cache-Control", "no-cache");
    String sql = "", n = "", v = "";;
    int ActionID = stringUtil.convertAction(request.getParameter("Action"));
    String id = stringUtil.nullValue(request.getParameter("id"), "");
    String sUid = stringUtil.nullValue(request.getParameter("sUid"), "");
    String sGid = stringUtil.nullValue(request.getParameter("sGid"), "");
    LoginModel login = new LoginModel(request, response);
    String ModName=com.swufe.toolkit.PathUtil.getFileBaseName(request.getRequestURI().toString().replace("_update", ""));
    try {
        if (!login.hasUrlPerm(ModName)) {
            out.print(stringUtil.getResultJson(false, "你没有权限操作数据！"));
            return;
        }
        int result = 0;
        switch (ActionID) {
            case 3:
                // 添加
                sql = " INSERT INTO user_group_user (user_group_id,created_user,user_id) ";
                sql += " SELECT  '" + sGid + "' , '" + login.getUserId() + "',user_id from user_info where user_id  IN (" + stringUtil.strComma2Singlequotes(id) + ")";
                break;
            case 4:
                // 移除
                sql += " delete from  user_group_user  where user_id  IN (" + stringUtil.strComma2Singlequotes(id) + ") and user_group_id='" + sGid + "'";
                break;
        }
        out.print(Data.updateJSON(sql));
    } catch (Exception e) {
        out.print(stringUtil.getResultJson(false, e.toString()));
    } finally {
        Data.close();
    }
%>