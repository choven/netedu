<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%

    sql = "SELECT id , bind_title AS c_绑定标记 , bind_uid AS c_绑定用户名,bind_pwd as c_绑定密码, bind_user_type as c_绑定用户类型";
    sql += "  ,open_type as c_切换方式 , CONVERT(varchar(16),created_date,120) AS c_添加时间, status AS c_状态 ";
    sql += " FROM dbo.user_bind where user_id='" + login.getUserId() + "' order by id desc";
    try {
        switch (ActionID) {
            case 2:
                out.print(Data.queryJSON(sql, "list", true));
                break;
            case 3://用于用户切换
                sql = "SELECT id ,bind_title,open_type,bind_user_type";
                sql += " FROM dbo.user_bind where user_id='" + login.getUserId() + "' and status=1 order by id desc";
                out.print(Data.queryJSON(sql, "list", true));
                break;
            case 1:
                String cm = Data.getCMByDB(sql);
//sb.append(sql); %>
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
                            text: '刷新',
                            iconCls: 'myicon my_refresh',
                            handler: function() {
                                grid.store.reload();
                            }
                        },'-', {
                            text: '添加绑定',
                            iconCls: 'myicon my_add2',
                            handler: add
                        }, '-', {
                            text: '编辑绑定',
                            iconCls: 'myicon my_edit',
                            handler: edit
                        }, '-', {
                            text: '切换帐户',
                            iconCls: 'myicon my_users',
                            handler: function() {
                                var rows = grid.initSeChk(1);
                                if (!rows)
                                    return false;
                                if (win)
                                    win.close();
                                window.parent.goApp(rows[0].get('id'), rows[0].get('c_切换方式'))
                            }
                        }, '->', '-', {
                            text: '禁用',
                            iconCls: 'myicon my_del2',
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
                cm.setRenderer(cm.findColumnIndex('c_切换方式'), function(v) {
                    return v == 2 ? "不保留原始用户" : "保留原始帐户"
                });
                grid.store.load();
                grid.on('rowdblclick', edit);
                function formIt() {
                    it1 = new Ext.form.TextField({
                        fieldLabel: '标记说明',
                        name: 'bind_title',
                        emptyText: '对该帐户的标记说明',
                        allowBlank: false
                    });
                    it2 = new Ext.form.TextField({
                        fieldLabel: '绑定用户名',
                        name: 'bind_uid',
                        allowBlank: false
                    });
                    it3 = new Ext.form.TextField({
                        fieldLabel: '绑定密码',
                        name: 'bind_pwd',
                        allowBlank: false
                    });
                    it4 = new netedu.comb({
                        store: new Ext.data.SimpleStore({
                            fields: ['text', 'value'],
                            data: [['管理用户', 'admin'], ['学生用户', 'stu']]
                        }),
                        fieldLabel: '绑定用户类型',
                        name: 'bind_user_type',
                        value: 'admin'

                    })
                    it5 = new netedu.comb({
                        store: new Ext.data.SimpleStore({
                            fields: ['text', 'value'],
                            data: [['多账户同时在线', '1'], ['替换当前账户', '2']]
                        }),
                        fieldLabel: '切换方式',
                        name: 'open_type',
                        value: '1'

                    })
                    it6 = new netedu.comb({
                        store: new Ext.data.SimpleStore({
                            fields: ['text', 'value'],
                            data: [['启用', '1'], ['禁用', '0']]
                        }),
                        fieldLabel: '是否启用',
                        name: 'status',
                        value: 1

                    })
                    return [it1, it2, it3, it4, it5, it6]
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
                    it1.setValue(rows[0].get('c_绑定标记'));
                    it2.setValue(rows[0].get('c_绑定用户名'));
                    it3.setValue(rows[0].get('c_绑定密码'));
                    it4.setValue(rows[0].get('c_绑定用户类型'));
                    it5.setValue(rows[0].get('c_切换方式'));
                    it6.setValue(rows[0].get('c_状态'));
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