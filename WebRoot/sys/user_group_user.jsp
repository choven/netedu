<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
    String status = StringUtil.nullValue(request.getParameter("status"), "");
    String sUid = StringUtil.nullValue(request.getParameter("sUid"), "");
    String sGid = StringUtil.nullValue(request.getParameter("sGid"), "");
    String keys = StringUtil.nullValue(request.getParameter("key"), "");
    sql = "SELECT  id, user_name AS c_姓名, user_id,login_name AS c_用户名,created_date";
    sql += " FROM dbo.user_info ";
    if ("un".equals(status)) {
        sql += " where user_id not in (select user_id from user_group_user where user_group_id='" + sGid + "') ";
    } else {
        sql += " where user_id in (select user_id from user_group_user where user_group_id='" + sGid + "') ";
    }
    if (!"".equals(keys)) {
        sql += " and (login_name like '%" + keys + "%' or user_name like '%" + keys + "%')";
    }
    try {
        switch (ActionID) {
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
        <title>用户组管理</title>
        <%@ include file="../ext-3.3.0.jsp" %>
        <script type="text/javascript">
            Ext.onReady(function() {
                var pageHeight = document.body.clientHeight < 100 ? document.documentElement.clientHeight - 29 : document.body.clientHeight - 4;
                var sGid = '<%=sGid%>';
                var userGroupComb = new netedu.comb({
                    tpl: '<tpl for="."><div class="x-combo-list-item">{[xindex]}、{text}（{num}）</div></tpl>',
                    store: new Ext.data.JsonStore({
                        url: '../dataUtil.jsp?Action=3',
                        autoLoad: true,
                        listeners: {
                            'load': function() {
                                if (sGid != "") {
                                    userGroupComb.setValue(sGid);
                                    reload(sGid)
                                }
                            }
                        }
                    }),
                    listeners: {
                        'select': function(c, e, i) {
                            sGid = c.getValue();
                            reload(sGid)
                        }
                    },
                    emptyText: '选择需要设置的用户组...'
                })

                var tbar = new Ext.Toolbar({
                    items: ['<span class="red" style="margin-left:20px;">已在该组的用户：</span>', '-', '当前用户组：', userGroupComb, '-', new netedu.search({
                            emptyText: '输入关键字查询账户...',
                            _t1Click: function() {
                                //
                                reload()
                            },
                            _t2Click: function() {
                                grid.store.setBaseParam('key', this.getValue());
                                grid.store.load();
                            }
                        }), {
                            text: '从该组移除',
                            iconCls: 'myicon my_del2',
                            handler: remove
                        }, '->',  '<span class="red">不在该组的用户：</span>','-', {
                            text: '添加到组',
                            iconCls: 'myicon my_add2',
                            handler: add
                        }, new netedu.search({
                            emptyText: '输入关键字查询账户...',
                            _t1Click: function() {
                                //
                                reload()
                            },
                            _t2Click: function() {
                                grid2.store.setBaseParam('key', this.getValue());
                                grid2.store.load();
                            }
                        }),'-']
                });
                var grid = new netedu.grid({
                    region: 'center',
                    autoHeight: false,
                    height: pageHeight,
                    _pageSize: Math.floor((pageHeight - 20) / 23),
                    border: false,
                    _cm: '<%=cm%>',
                    store: new Ext.data.JsonStore({
                        url: '<%=ModName%>.jsp?Action=2&status=in',
                        autoLoad: false
                    })
                });
                var cm = grid.getColumnModel();
                //cm.setRenderer(cm.findColumnIndex('c_状态'), FormatTrueFalse);
                var grid2 = new netedu.grid({
                    region: 'east',
                    split: true,
                    width: 400,
                    autoHeight: false,
                    height: pageHeight,
                    _pageSize: Math.floor((pageHeight - 20) / 23),
                    cls: 'Lb1',
                    border: false,
                    _cm: '<%=cm%>',
                    store: new Ext.data.JsonStore({
                        url: '<%=ModName%>.jsp?Action=2&status=un',
                        autoLoad: false
                    })
                });
                new Ext.Panel({
                    tbar: tbar,
                    layout: 'border',
                    border: false,
                    height: pageHeight,
                    items: [grid, grid2],
                    renderTo: '<%=ModName%>_content'
                });
                function reload(gid) {
                    if (gid) {
                        grid.store.setBaseParam('sGid', gid);
                        grid2.store.setBaseParam('sGid', gid);
                    }
                    //清除关键字
                    Ext.apply(grid2.store.baseParams, {
                        key: ""
                    });
                    Ext.apply(grid.store.baseParams, {
                        key: ""
                    });
                    grid.store.load();
                    grid2.store.load();
                }
                function add() {
                    var oRows = grid2.getSelectionModel().getSelections();
                    if (oRows.length < 1) {
                        alert("请先选择一行以上数据再进行数据操作！")
                        return false;
                    }
                    var str = [];
                    for (var i = 0; i < oRows.length; i++) {
                        str.push(oRows[i].get("user_id"));
                    }
                    str = str.toString();
                    fn_btn_ajax('<%=ModName%>_update.jsp?&Action=3', 'sGid=' + sGid + '&id=' + str, reload)
                }
                function remove() {
                    var oRows = grid.getSelectionModel().getSelections();
                    if (oRows.length < 1) {
                        alert("请先选择一行以上数据再进行数据操作！")
                        return false;
                    }
                    var str = [];
                    for (var i = 0; i < oRows.length; i++) {
                        str.push(oRows[i].get("user_id"));
                    }
                    str = str.toString();
                    fn_btn_ajax('<%=ModName%>_update.jsp?&Action=4', 'sGid=' + sGid + '&id=' + str, reload)
                }
            });
        </script>
        <style>
            .Lb1 {
                border: none;
                border-left: 1px solid #7db45c;
            }
        </style>
    </head>
    <body>
        <div id='<%=ModName%>_content' class='my_grid'></div>
        <div id='win' class='my_win'></div>
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