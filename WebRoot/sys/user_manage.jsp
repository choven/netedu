<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
    String keys = StringUtil.nullValue(request.getParameter("key"), "");
    sql = "SELECT id,user_id,login_name AS c_用户名, user_name AS c_姓名, pwd AS c_密码  ";
    //sql += " ,swufe_online.dbo.uf_RTrimS( (SELECT DISTINCT (SELECT TOP 1 name FROM user_group WHERE id=gid) + ',' AS \"data()\" FROM user_group_user WHERE uid=user_info.uid FOR XML PATH ('')), ',' ) AS c_所在组名称 ";
    sql += " ,CONVERT(varchar(16),created_date,111) AS c_注册日期, uTimes AS c_登录次数, status AS c_状态,user_type_id ";
    sql += " FROM user_info ";
    sql += " where 1=1 ";
    if (!"".equals(keys)) {
        sql += " AND (user_name LIKE '%" + keys + "%' OR login_name LIKE '%" + keys + "%')";
    }
    try {
        switch (ActionID) {
            case 3:
                sql = "SELECT name as text,id as value  from user_type";
                out.print(Data.queryJSON(sql, "list", true));
                break;
            case 2:
                out.print(Data.queryJSON(sql, "order by id desc", request));
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
                            emptyText: '输入关键字查询账户...',
                            _t1Click: function() {
                                //
                                grid.store.setBaseParam('key', "");
                                grid.store.load();
                            },
                            _t2Click: function() {
                                grid.store.setBaseParam('key', this.getValue());
                                grid.store.load();
                            }
                        }), '-', {
                            text: '添加用户',
                            iconCls: 'myicon my_add2',
                            handler: add
                        }, '-', {
                            text: '编辑用户',
                            iconCls: 'myicon my_edit',
                            handler: edit
                        }, '-', {
                            text: '分配权限',
                            iconCls: 'myicon my_edit2',
                            handler: function() {
                                var rows = grid.initSeChk(1);
                                if (!rows)
                                    return false;
                                window.parent.openApp("user_perm", "sys/user_perm.jsp?sUid=" + rows[0].get('user_id'), "权限分配", false, true)
                            }
                        }, '->', '-', {
                            text: '禁用帐户',
                            iconCls: 'myicon my_del',
                            handler: function() {
                                grid.initDel('user_id', '<%=ModName%>_update.jsp?Action=5', ok)
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
                    autoHeight: false,
                    height: pageHeight,
                    _pageSize: Math.floor((pageHeight - 20) / 23),
                    _cm: '<%=cm%>'
                });
                var cm = grid.getColumnModel();
                cm.setRenderer(cm.findColumnIndex('c_状态'), FormatTrueFalse);
                grid.store.load();
                grid.on('rowdblclick', edit);
                function formIt() {
                    it1 = new Ext.form.TextField({
                        fieldLabel: '用户名',
                        name: 'login_name',
                        allowBlank: false
                    });
                    it2 = new Ext.form.TextField({
                        fieldLabel: '姓名',
                        name: 'user_name',
                        allowBlank: false
                    });
                    it3 = new Ext.form.TextField({
                        fieldLabel: '密码',
                        name: 'pwd',
                        allowBlank: false
                    });
                    it4 = new netedu.comb({
                        store: new Ext.data.SimpleStore({
                            fields: ['text', 'value'],
                            data: [['启用', '1'], ['禁用', '0']]
                        }),
                        fieldLabel: '是否启用',
                        name: 'status',
                        value: 1
                    })
                    it5 = new netedu.comb({
                        fieldLabel: '用户类型',
                        name: 'user_type_id',
                        store: typeStore
                    })
                    return [it1, it2, it3, it5, it4]
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
                        title: '添加用户',
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
                    pkid = rows[0].get('user_id');
                    win = new netedu.formWin({
                        title: '编辑信息',
                        width: 400,
                        _it: formIt(),
                        _url: '<%=ModName%>_update.jsp?Action=4',
                        _id: pkid,
                        _suc: ok
                    });
                    win.show();
                    //it1.setReadOnly(true);
                    it1.setValue(rows[0].get('c_用户名'));
                    it2.setValue(rows[0].get('c_姓名'));
                    it3.setValue(rows[0].get('c_密码'));
                    it4.setValue(rows[0].get('c_状态'));
                    it5.setValue(rows[0].get('user_type_id'));
                }
            });
        </script>
        <style type="text/css">
            #l div{padding-top:5px;}
        </style>
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