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
    LoginModel login = new LoginModel(request, response);
    String ModName=com.swufe.toolkit.PathUtil.getFileBaseName(request.getRequestURI().toString().replace("_update", ""));
    try {
        if (!login.hasUrlPerm(ModName)) {
            out.print(stringUtil.getResultJson(false, "你没有权限操作数据！"));
            return;
        }
        Enumeration<String> e = request.getParameterNames();
        switch (ActionID) {
            case 3:
                // 新添
                 id = Data.sequence("module_info", "id");
                sql = "";
                while (e.hasMoreElements()) {
                    n = (String) e.nextElement();
                    if (!"Action".equals(n) && !"btn".equals(n) && !"id".equals(n) && !n.startsWith("ext-")) {
                        v = stringUtil.nullValue(request.getParameter(n), "");
                        sql += ("".equals(sql) ? "" : ",") + "'" + v + "' AS " + n;
                    }
                }
                sql = " WITH T1 AS ( SELECT " + sql;
                sql += " ) ";
                sql += " INSERT INTO module_info(id,parent_id,name,code,url,type,is_public,is_finish,is_blank,is_reload,status,create_user) ";
                sql += " SELECT '"+id+"',parent_id,name,code,url,type,is_public,is_finish,is_blank,is_reload,status,'" + login.getUserId() + "' FROM T1 ";
                break;
            case 4:
                // 编辑
                sql = "";
                while (e.hasMoreElements()) {
                    n = (String) e.nextElement();
                    if (!"Action".equals(n) && !"btn".equals(n) && !"id".equals(n)) {
                        v = stringUtil.nullValue(request.getParameter(n), "");
                        sql += ("".equals(sql) ? "" : ",") + n + "='" + v + "' ";
                    }
                }
                sql = "UPDATE module_info SET " + sql;
                sql += " WHERE id='" + id + "' ";
                break;
            case 5://
                sql = " delete from  user_perm WHERE module_id IN (" + stringUtil.strComma2Singlequotes(id) + ")";
                sql += " ;delete from  module_panel WHERE module_info_id IN (" + stringUtil.strComma2Singlequotes(id) + ")";
                sql += " ;delete from  module_info WHERE id IN (" + stringUtil.strComma2Singlequotes(id) + ")";
                break;
        }
                out.print(Data.updateJSON(sql));
            } catch (Exception e) {
                out.print(stringUtil.getResultJson(false, e.toString()));
            } finally {
                Data.close();
            }
%>