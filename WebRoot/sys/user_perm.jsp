<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
    String sUid = StringUtil.nullValue(request.getParameter("sUid"), "");
    String sGid = StringUtil.nullValue(request.getParameter("sGid"), "");
    if (!login.hasUrlPerm()) {
        out.print("没有权限访问此功能");
        return;
    }
%>
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>用户管理</title>
        <%@ include file="../ext-3.3.0.jsp" %>
        <script type="text/javascript" src="/file/ext-3.3.0/ux/treegrid/TreeGridSorter.js"></script>
        <script type="text/javascript" src="/file/ext-3.3.0/ux/treegrid/TreeGridColumnResizer.js"></script>
        <script type="text/javascript" src="/file/ext-3.3.0/ux/treegrid/TreeGridNodeUI.js"></script>
        <script type="text/javascript" src="/file/ext-3.3.0/ux/treegrid/TreeGridLoader.js"></script>
        <script type="text/javascript" src="/file/ext-3.3.0/ux/treegrid/TreeGridColumns.js"></script>
        <script type="text/javascript" src="/file/ext-3.3.0/ux/treegrid/TreeGrid.js"></script>
        <link rel="stylesheet" type="text/css" href="/file/ext-3.3.0/ux/treegrid/treegrid.css" rel="stylesheet" />
        <script type="text/javascript">
            var add;
            function mod() {
                var pageHeight = document.body.clientHeight < 100 ? document.documentElement.clientHeight - 29 : document.body.clientHeight - 4;
                var sUid = '<%=sUid%>', sGid = '<%=sGid%>';//用于页面外部传递参数
                var myMask = new Ext.LoadMask(Ext.getBody(), {
                    msg: "数据加载中，请您耐心等待..."
                });
                var userComb = new netedu.comb({
                    tpl: '<tpl for="."><div class="x-combo-list-item">{[xindex]}、{text}（{value}）</div></tpl>',
                    allowBlank: true,
                    store: new Ext.data.JsonStore({
                        url: '../dataUtil.jsp?Action=1',
                        autoLoad: false
                    }),
                    editable: true,
                    width: 300,
                    pageSize: 10,
                    mode: 'remote',
                    triggerClass: '',
                    listeners: {
                        'select': function(c, e, i) {
                            userGroupComb.reset();
                            sGid = '';
                            sUid = c.getValue();
                            reload(true, sUid)
                        }
                    },
                    emptyText: '用关键字查询选择一个帐户分配权限...'
                })
                var userGroupComb = new netedu.comb({
                    tpl: '<tpl for="."><div class="x-combo-list-item">{[xindex]}、{text}（{num}）</div></tpl>',
                    allowBlank: true,
                    store: new Ext.data.JsonStore({
                        url: '../dataUtil.jsp?Action=3',
                        autoLoad: true
                    }),
                    listeners: {
                        'select': function(c, e, i) {
                            userComb.reset();
                            sUid = ''
                            sGid = c.getValue();
                            reload(false, sGid)
                        }
                    },
                    emptyText: '选择一个用户组分配权限...'
                })
                var tbar = new Ext.Toolbar({
                    items: ['-', {
                            text: '刷新',
                            iconCls: 'myicon my_refresh',
                            handler: function() {
                                if (sUid != "") {
                                    reload(true, sUid);
                                    return;
                                }
                                reload(false, sGid)
                            }
                        }, '-', '当前用户：', userComb, '-', '当前用户组：', userGroupComb]
                });
                //注册方法
                Ext.apply(Ext.tree.TreeNode.prototype, {
                    ckChildren: function() {
                        var ch = this.attributes.checked;
                        if (!Ext.isBoolean(ch))
                            return;
                        Ext.each(this.childNodes, function(n) {
                            n.getUI().toggleCheck(ch);
                            n.ckChildren();
                        });
                    }
                });
                var tree = new Ext.ux.tree.TreeGrid({
                    border: false,
                    tbar: tbar,
                    renderTo: '<%=ModName%>_content',
                    height: pageHeight,
                    columns: [{
                            header: '模块名称',
                            dataIndex: 'text'
                        }, {
                            header: '用户所在组是否已具备该权限',
                            dataIndex: 'group_checked',
                            tpl: new Ext.XTemplate('{group_checked:this.format}', {
                                format: FormatYesNo
                            })
                        }, {
                            header: '是否启用',
                            dataIndex: 'status',
                            tpl: new Ext.XTemplate('{status:this.format}', {
                                format: FormatTrueFalse
                            })

                        }],
                    //enableAllCheck: true,//级联
                    //animate: true,
                    useArrows: true,
                    loader: new Ext.tree.TreeLoader({
                        dataUrl: '../dataUtil.jsp?Action=4',
                        listeners: {
                            'beforeload': function() {
                                myMask.show();
                                this.baseParams.sUid = sUid;
                                this.baseParams.sGid = sGid;
                            },
                            'load': function() {
                                myMask.hide();
                                tree.getRootNode().setId(-1)//gridTree不能设置root属性，所以在这里设置rootId以便过滤根节点
                            }
                        }
                    }),
                    buttonAlign: 'center',
                    buttons: [{
                            text: '提 交',
                            handler: function() {
                                if (sUid == "" && sGid == "") {
                                    alert("请先选择一个帐户或者用户组！");
                                    return;
                                }
                                var str = [];
                                var cklNodes = tree.getChecked();
                                Ext.each(cklNodes, function(n) {
                                    //msg += node.text;
                                    if (n.id != -1) {//过滤根节点
                                        str.push(n.id);
                                    }
                                });
                                if (str.length == 0) {
                                    if (!confirm("确认要清除当前帐户的所有权限么？")) {
                                        return;
                                    }
                                }
                                if (sUid != "") {
                                    fn_btn_ajax('<%=ModName%>_update.jsp?Action=3', 'nodes=' + str.toString() + '&sUid=' + sUid, function() {
                                        reload(true, sUid)
                                    });
                                }
                                if (sGid != "") {
                                    fn_btn_ajax('<%=ModName%>_update.jsp?Action=4', 'nodes=' + str.toString() + '&sGid=' + sGid, function() {
                                        reload(false, sGid)
                                    });
                                }
                            }
                        }, {
                            text: '全 选',
                            handler: function() {
                                tree.root.attributes.checked = true;
                                tree.root.ckChildren();
                            }
                        }, {
                            text: '全不选',
                            handler: function() {
                                tree.root.attributes.checked = false;
                                tree.root.ckChildren();
                            }
                        }, {
                            text: '指定目录全选',
                            handler: function() {
                                var se = tree.getSelectionModel().getSelectedNode();
                                if (!se) {
                                    alert("先选择一个父节点作为指定目录！");
                                    return;
                                }
                                se.getUI().toggleCheck(true);
                                se.ckChildren();
                            }
                        }, {
                            text: '指定目录全不选',
                            handler: function() {
                                var se = tree.getSelectionModel().getSelectedNode();
                                if (!se) {
                                    alert("先选择一个父节点作为指定目录！");
                                    return;
                                }
                                se.getUI().toggleCheck(false);
                                se.ckChildren();
                            }
                        }]
                })
                new Ext.ux.tree.TreeGridSorter(tree, {
                    folderSort: true,
                    dir: "asc",
                    sortType: function(node) {
                        //return node.list_no;
                        return parseInt(node.id, 10);
                    }
                });
                function reload(is_user, value) {
                    if (is_user) {
                        tree.getLoader().baseParams.sUid = value;
                        tree.getLoader().baseParams.sGid = '';
                    }
                    else {
                        tree.getLoader().baseParams.sUid = '';
                        tree.getLoader().baseParams.sGid = value;
                    }
                    tree.root.reload();

                }
                //初始赋值
                if (sUid != "") {
                    userComb.doQuery(sUid);
                    userComb.store.on('load', function(s, rs) {
                        if (rs.length == 0) {
                            alert("该用户不存在或者被禁用");
                            return;
                        }
                        userComb.setValue(sUid)
                    })
                }
                if (sGid != "") {
                    userGroupComb.store.on('load', function(s, rs) {
                        userGroupComb.setValue(sGid)
                    })
                }
            }
            Ext.onReady(mod);
        </script>
    </head>
    <body>
        <div id='<%=ModName%>_content' class='my_grid'></div>
        <div id='win' class='my_win'></div>
    </body>
</html>
