<%@ page contentType="text/html;charset=UTF-8"%>
<%@ include file="../baseParameter.jsp"%>
<%
    ResultSet rs = null;
    try {
        switch (ActionID) {
            case 2://
                sql = "  select name from msdb.dbo.sysjobs where enabled=1  and category_id in (0,3)  ";
                rs = Data.executeQuery(sql);
                while (rs.next()) {
                    out.print("<li><a href='javascript:exec(\"" + rs.getString("name") + "\")'>" + rs.getString("name") + "</a></li>");
                }
                break;
            case 1:
                if (!login.hasUrlPerm()) {
                    out.print("没有权限访问此功能");
                    return;
                }
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>教学计划</title><%@ include file="../ext-3.3.0.jsp"%>
        <script type="text/javascript">
            var exec;
            Ext.onReady(function() {
                function loadCt() {
                    Ext.get("tool").load({
                        url: '<%=ModName%>.jsp?Action=2'
                    })
                }
                var tbar = new Ext.Toolbar({
                    items: ['-', {
                            text: '刷新', iconCls: 'myicon my_refresh',
                            handler: loadCt
                        }, '-'],
                    renderTo: 'tbar'
                });
                loadCt();
                exec = function(title) {
                    fn_btn_ajax('pm_update.jsp?Action=5', 'title=' + title, function() {
                        alert("执行数据库作业《" + title + "》成功！")
                    });
                }
            });
        </script>
        <style>
            .line{
                border-top:1px solid #7db45c;
                font-size:2px;
                height:2px;
                width:100%;
            }
            #tool li{
                line-height:24px;
                margin-left: 30px;
                list-style:decimal;
            }
        </style>
    </head>
    <body>
        <div id='tbar'></div>
        <div class='line'></div>

        <div>
            <ul id="tool">

            </ul>
        </div>
    </body>
</html>
<%
                break;
        }
    } catch (Exception e) {
        out.print(e.toString());
    } finally {
        Data.close();
    }
%>