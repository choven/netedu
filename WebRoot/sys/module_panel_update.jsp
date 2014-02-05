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
    String ModName = com.swufe.toolkit.PathUtil.getFileBaseName(request.getRequestURI().toString().replace("_update", ""));
    try {
        if (!login.hasUrlPerm(ModName)) {
            out.print(stringUtil.getResultJson(false, "你没有权限操作数据！"));
            return;
        }
        // 表单元素
        String parent_id = stringUtil.nullValue(request.getParameter("parent_id"), "");
        String list_no = stringUtil.nullValue(request.getParameter("list_no"));
        String index = stringUtil.nullValue(request.getParameter("index"));
        String dir = stringUtil.nullValue(request.getParameter("dir"), "up");
        String oIndex = stringUtil.nullValue(request.getParameter("oIndex"));
        Enumeration<String> e = request.getParameterNames();
        // 分类处理
        switch (ActionID) {
            case 3:
                // 添加 3
                id = Data.sequence("module_panel", "id");
                list_no = stringUtil.nullValue(Data.queryScalar("select max(list_no)+1 from module_panel where parent_id='" + parent_id + "'"), "1");
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
                sql += " INSERT INTO module_panel(id,list_no,group_no,module_info_id, parent_id, name,create_user) ";
                sql += " SELECT '" + id + "','"+list_no+"',group_no,module_info_id, parent_id, name,'" + login.getUserId() + "' FROM T1 ";
                break;


            case 4:
                sql = "";
                while (e.hasMoreElements()) {
                    n = (String) e.nextElement();
                    if (!"Action".equals(n) && !"btn".equals(n) && !"id".equals(n)) {
                        v = stringUtil.nullValue(request.getParameter(n), "");
                        sql += ("".equals(sql) ? "" : ",") + n + "='" + v + "' ";
                    }
                }
                sql = "UPDATE module_panel SET " + sql;
                sql += " WHERE id='" + id + "' ";
                break;
            case 5:
                // 删除 5
                sql = " DELETE FROM module_panel  WHERE id = '" + id + "' ";
                break;
            case 6:
                // 排序
                if ("up".equals(dir)) {
                    sql = " with t as (SELECT  ROW_NUMBER()over( order by  list_no  ) as rn, [id],list_no ";
                    sql += " FROM [module_panel] where parent_id='" + parent_id + "') ";
                    sql += " update  [module_panel] ";
                    sql += " set list_no=(case when [module_panel].id='" + id + "' then (case when 0=" + index + " then 1 else(select list_no+1 from t where rn=" + index + ") end) else list_no+1 end) ";
                    sql += " where parent_id='" + parent_id + "'  and id in (select id from t where  rn>" + index + " and rn<(" + oIndex + "+2)) ";
                } else {
                    sql = " with t as (SELECT  ROW_NUMBER()over( order by  list_no  ) as rn, [id],list_no ";
                    sql += " FROM [module_panel] where parent_id='" + parent_id + "') ";
                    sql += " update  [module_panel] ";
                    sql += " set list_no=(case when [module_panel].id='" + id + "' then " + index + " else list_no-1 end) ";
                    sql += " where parent_id='" + parent_id + "'  and id in (select id from t where  rn>" + oIndex + " and rn<=" + index + ") ";
                }

                break;
        }
        out.print(Data.updateJSON(sql));
    } catch (Exception e) {
        out.print(stringUtil.getResultJson(false, e.toString()));
    } finally {
        Data.close();
    }
%>