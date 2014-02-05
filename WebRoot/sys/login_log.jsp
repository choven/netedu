<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
    try {
        switch (ActionID) {
            case 2:
                String keys = StringUtil.nullValue(request.getParameter("key"), "");
                sql = "SELECT id, user_name, in_time, out_time,datediff(MINUTE,in_time,out_time) as stick_time, request_url FROM  login_log  ";
                sql += " where 1=1 ";
                if (!"".equals(keys)) {
                    sql += " AND (user_name LIKE '%" + keys + "%' or request_url LIKE '%" + keys + "%')";
                }
                out.print(Data.queryJSON(sql, "order by id desc", request));
                break;
            case 1:
          
%>
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>用户管理</title>
        <%@ include file="../ext-3.3.0.jsp" %>
        <script type="text/javascript">
            var win, it1, it2, it3, it4, it5, it6, it7
            Ext.onReady(function() {
                var pageHeight = document.body.clientHeight;
                var typeStore = new Ext.data.JsonStore({
                    url: '<%=ModName%>.jsp?Action=3',
                    autoLoad: true
                })
                var tbar = new Ext.Toolbar({
                    items: ['-', {
                            text: '刷新', iconCls: 'myicon my_refresh',
                            handler: function() {
                                grid.store.reload();
                            }
                        }, '-', new netedu.search({
                            emptyText: '输入用户、地址关键查询...',
                            width:250,
                            _t1Click: function() {
                                //
                                grid.store.setBaseParam('key', "");
                                grid.store.load();
                            },
                            _t2Click: function() {
                                grid.store.setBaseParam('key', this.getValue());
                                grid.store.load();
                            }
                        }), '->', {
                            text: '导出数据',
                            iconCls: 'myicon my_excel2',
                            handler: function() {
                                grid.initExport()
                            }
                        }]
                });
                var sm = new Ext.grid.CheckboxSelectionModel();
                var cm = new Ext.grid.ColumnModel([new Ext.grid.RowNumberer({
                        width: 45
                    }), sm, {
                        "sortable": true,
                        "dataIndex": "user_name",
                        "header": "用户"
                    }, {
                        "sortable": true,
                        "dataIndex": "in_time",
                        "header": "登录时间"
                    }, {
                        "sortable": true,
                        "dataIndex": "out_time",
                        "header": "登出时间"
                    }, {
                        "sortable": true,
                        "dataIndex": "stick_time",
                        "header": "停留时长（分钟）"
                    }, {
                        "sortable": true,
                        "dataIndex": "request_url",
                        "header": "入口地址"
                    }])
                var grid = new netedu.grid({
                    tbar: tbar,
                    renderTo: '<%=ModName%>_content',
                    border: false,
                    autoHeight: false,
                    height: pageHeight,
                    _pageSize: Math.floor((pageHeight - 20) / 23),
                    cm: cm,
                    sm: sm
                });
                grid.store.load();
            });
        </script>

    </head>
    <body>
        <div id='<%=ModName%>_content' class='my_grid'></div>
        <div id='win'></div>
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