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
    LoginModel login = new LoginModel(request, response);
    String ModName = com.swufe.toolkit.PathUtil.getFileBaseName(request.getRequestURI().toString().replace("_update", ""));
    try {
        if (!login.hasUrlPerm(ModName)) {
            out.print(stringUtil.getResultJson(false, "你没有权限操作数据！"));
            return;
        }
        String nodes = stringUtil.nullValue(request.getParameter("nodes"), "");
        String sUid = stringUtil.nullValue(request.getParameter("sUid"));
        String sGid = stringUtil.nullValue(request.getParameter("sGid"));
        switch (ActionID) {
            case 3:
                // 用户授权
                sql = " insert into user_perm (user_id,is_user_group,created_user,module_id)";
                sql += " SELECT  '" + sUid + "' ,0,'" + login.getUserId() + "',id from module_info ";
                sql += " where id not in (SELECT module_id FROM user_perm where user_id='" + sUid + "') and id in (" + stringUtil.strComma2Singlequotes(nodes) + ") ";
                sql += " ;delete FROM user_perm where user_id='" + sUid + "' and is_user_group=0 and module_id not in(" + stringUtil.strComma2Singlequotes(nodes) + ") ";
                break;
            case 4:
                // 用户组授权 ,user_group_id
                sql = " insert into user_perm (user_group_id,is_user_group,created_user,module_id)";
                sql += " SELECT  '" + sGid + "',1, '" + login.getUserId() + "' ,id from module_info ";
                sql += " where id not in (SELECT module_id FROM user_perm where user_group_id='" + sGid + "') and id in (" + stringUtil.strComma2Singlequotes(nodes) + ") ";
                sql += " ;delete FROM user_perm where user_group_id='" + sGid + "' and is_user_group=1 and module_id not in(" + stringUtil.strComma2Singlequotes(nodes) + ")";
                break;
        }
        out.print(Data.updateJSON(sql));
    } catch (Exception e) {
        out.print(stringUtil.getResultJson(false, e.toString()));
    } finally {
        Data.close();
    }
%>