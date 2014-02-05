<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
    sql = "SELECT id , id as c_ID, name AS c_组名称 ";
    sql += " ,(select count(1) from user_group_user where user_group_id=user_group.id) as c_成员数 ";
    sql += "   , CONVERT(varchar(16),created_date,120) AS c_添加时间, status AS c_状态 ";
    sql += " FROM dbo.user_group order by id desc";
    try {
        switch (ActionID) {
            case 2:
                out.print(Data.queryJSON(sql, "list", true));
                break;
            case 1:
                if (!login.hasUrlPerm()) {
                    out.print("没有权限访问此功能");
                    return;
                }
                String cm = Data.getCMByDB(sql);
                %>
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>用户组管理</title>
        <%@ include file="../ext-3.3.0.jsp" %>
        <script type="text/javascript">
            var win, it1, it2, it3, it4, it5, it6, it7
            Ext.onReady(function() {
                var tbar = new Ext.Toolbar({
                    items: ['-', {
                            text: '刷新', iconCls: 'myicon my_refresh',
                            handler: function() {
                                grid.store.reload();
                            }
                        }, '-', {
                            text: '添加',
                            iconCls: 'myicon my_add2',
                            handler: add
                        }, '-', {
                            text: '编辑',
                            iconCls: 'myicon my_edit',
                            handler: edit
                        }, '-', {
                            text: '设置成员',
                            iconCls: 'myicon my_users',
                            handler: function() {
                                var rows = grid.initSeChk(1);
                                if (!rows)
                                    return false;
                                window.parent.openApp("user_group_user", "sys/user_group_user.jsp?sGid=" + rows[0].get('id'), "组成员管理", false, true)
                            }
                        }, '-', {
                            text: '分配权限',
                            iconCls: 'myicon my_edit2',
                            handler: function() {
                                var rows = grid.initSeChk(1);
                                if (!rows)
                                    return false;
                                window.parent.openApp("user_perm", "sys/user_perm.jsp?sGid=" + rows[0].get('id'), "权限分配", false, true)
                            }
                        }, '->', {
                            text: '禁用',
                            iconCls: 'myicon my_del',
                            handler: function() {
                                grid.initDel('id', '<%=ModName%>_update.jsp?Action=5', ok)
                            }
                        }, '-', {
                            text: '导出数据',
                            iconCls: 'myicon my_excel2',
                            handler: function() {
                                grid.initExport()
                            }
                        }]
                });
                var grid = new netedu.grid({
                    tbar: tbar,
                    renderTo: '<%=ModName%>_content',
                    border: false,
                    _cm: '<%=cm%>'
                });
                var cm = grid.getColumnModel();
                cm.setRenderer(cm.findColumnIndex('c_状态'), FormatTrueFalse);
                grid.store.load();
                grid.on('rowdblclick', edit);
                function formIt() {
                    it1 = new Ext.form.TextField({
                        fieldLabel: '组名称',
                        name: 'name',
                        allowBlank: false
                    });
                    it2 = new netedu.comb({
                        store: new Ext.data.SimpleStore({
                            fields: ['text', 'value'],
                            data: [['启用', '1'], ['禁用', '0']]
                        }),
                        fieldLabel: '是否启用',
                        name: 'status',
                        value: 1

                    })
                    return [it1, it2]
                }
                function ok() {
                    if (win)
                        win.close();
                    grid.store.reload();
                }
                function add() {
                    if (win)
                        win.close();
                    win = new netedu.formWin({
                        title: '添加数据',
                        _it: formIt(),
                        _url: '<%=ModName%>_update.jsp?Action=3',
                        _id: '',
                        _suc: ok
                    });
                    win.show();
                }
                function edit() {
                    var rows = grid.initSeChk(1);
                    if (!rows)
                        return false;
                    if (win)
                        win.close();
                    pkid = rows[0].get('id');
                    win = new netedu.formWin({
                        title: '编辑数据',
                        width: 400,
                        _it: formIt(),
                        _url: '<%=ModName%>_update.jsp?Action=4',
                        _id: pkid,
                        _suc: ok
                    });
                    win.show();
                    it1.setValue(rows[0].get('c_组名称'));
                    it2.setValue(rows[0].get('c_状态'));
                }
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
    }%>