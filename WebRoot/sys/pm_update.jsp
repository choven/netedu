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
    String id = stringUtil.nullValue(request.getParameter("id"));
    String title = stringUtil.nullValue(request.getParameter("title"));
    String table = stringUtil.nullValue(request.getParameter("table"));
    String column = stringUtil.nullValue(request.getParameter("column"));
    LoginModel login = new LoginModel(request, response);
    try {
        if (!login.hasPerm("pm_mgt")) {
            out.print(stringUtil.getResultJson(false, "你没有权限操作数据！"));
            return;
        }
        switch (ActionID) {
            case 3://添加字段说明
                sql = "EXEC sp_addextendedproperty N'MS_Description', '"+title+"', N'user', N'dbo', N'table', N'"+table+"', N'column', N'"+column+"' ";
                break;
            case 4://修改字段说明
               sql = "EXEC sp_updateextendedproperty 'MS_Description','"+title+"','user',dbo,'table','"+table+"','column',"+column+" ";
                break;
              case 5://执行数据库作业
               sql = "EXEC msdb.dbo.sp_start_job N'"+title+"' ";
                break;
        }
        out.print(Data.updateJSON(sql));
    } catch (Exception e) {
        out.print(stringUtil.getResultJson(false, e.toString()));
    } finally {
        Data.close();
    }
%>