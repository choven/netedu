<%@ page contentType="text/html;charset=UTF-8"%>
<%@ include file="../baseParameter.jsp"%>
<%
    ResultSet rs = null;
    try {
        switch (ActionID) {
            case 2://
                sql = "  select title,asw_content from help_center where module_id in ( ";
                sql += "  select id from  module_info  where  url like '%" + ModName + ".jsp'";
                sql += ") and is_system=1";

                rs = Data.executeQuery(sql);
                while (rs.next()) {
%>
<div class="ct_block">
    <b class="tl"></b><b class="tr"></b>
    <div class="block2">
        <h3><%=rs.getString("title")%></h3>
        <ul id="apply" class="clear">
            <%=rs.getString("asw_content")%>
        </ul>
    </div>
</div>
<%
        }
        //out.print(sql);
        break;
    case 1:
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>教学计划</title><%@ include file="../ext-3.3.0.jsp"%>
        <script type="text/javascript">
            var win;
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
            });
        </script>
        <style>
            .line{
                border-top:1px solid #7db45c;
                font-size:2px;
                height:2px;
                width:100%;
            }
            #tool{
                margin:2px 2px 2px 5px;
            }
            #tool h3{
                line-height:24px;
            }
            #tool h3 span{
                display:block;
            }
            #tool h3 span.right{
                cursor:hand;
            }
            #tool li{
                line-height:24px;
            }
            .block2{
                margin-bottom:5px;
            }
            .ct_block{
                float:left;
                width:49%;
                margin-right:5px;
            }
            .ct_block ul{
                padding-left:10px;
                height:200px;
                overflow:auto;
                list-style:decimal;
                padding-left:30px;
            }
        </style>
    </head>
    <body>
        <div id='tbar'></div>
        <div class='line'></div>

        <div id="tool">
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