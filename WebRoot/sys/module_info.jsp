<%@page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
    if (!login.hasUrlPerm()) {
        out.print("没有权限访问此功能");
        return;
    }
%>
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>功能节点维护</title>
        <%@ include file="../ext-3.3.0.jsp" %>
        <script type="text/javascript" src="/file/ext-3.3.0/ux/treegrid/TreeGridSorter.js"></script>
        <script type="text/javascript" src="/file/ext-3.3.0/ux/treegrid/TreeGridColumnResizer.js"></script>
        <script type="text/javascript" src="/file/ext-3.3.0/ux/treegrid/TreeGridNodeUI.js"></script>
        <script type="text/javascript" src="/file/ext-3.3.0/ux/treegrid/TreeGridLoader.js"></script>
        <script type="text/javascript" src="/file/ext-3.3.0/ux/treegrid/TreeGridColumns.js"></script>
        <script type="text/javascript" src="/file/ext-3.3.0/ux/treegrid/TreeGrid.js"></script>
        <link rel="stylesheet" type="text/css" href="/file/ext-3.3.0/ux/treegrid/treegrid.css" rel="stylesheet" />
        <script type="text/javascript">
            var win, it1, it2, it3, it4, it5, it6, it7, it8, thePid, theId;
            function Mod() {
                var myMask = new Ext.LoadMask(Ext.getBody(), {
                    msg: "数据加载中，请您耐心等待..."
                });
                var tbar = new Ext.Toolbar({
                    items: ['-', {
                            text: '刷新', iconCls: 'myicon my_refresh',
                            handler: function() {
                                ok();
                            }
                        },'-', {
                            text: '添加同级模块',
                            iconCls: 'myicon my_add2',
                            handler: add
                        }, '-', {
                            text: '添加子模块',
                            iconCls: 'myicon my_add2',
                            handler: addNode
                        }, '-', {
                            text: '修改模块',
                            iconCls: 'myicon my_edit',
                            handler: edit
                        }, '-', {
                            text: '注册到控制面板',
                            iconCls: 'myicon my_edit2',
                            handler: reg
                        }, '->', '-', {
                            text: '删除模块',
                            iconCls: 'myicon my_del',
                            handler: del
                        }, '-']
                });
                var tree = new Ext.ux.tree.TreeGrid({
                    renderTo: '<%=ModName%>_content',
                    enableDD: false,
                    border: false,
                    rootVisible: false,
                    enableSort : true,
                    folderSort: true,
                    //singleExpand: true,
                    tbar: tbar,
                    columns: [{
                            header: 'ID',
                            dataIndex: 'id',
                            width:150
                        },{
                            header: '名称',
                            dataIndex: 'text'
                        }, {
                            header: '代码',
                            dataIndex: 'code'
                        }, {
                            header: '路径 ',
                            dataIndex: 'url'
                        }, {
                            header: '通用权限',
                            dataIndex: 'is_public',
                            tpl: new Ext.XTemplate('{is_public:this.format}', {
                                format: function(v, node) {
                                    if (!node.leaf) {
                                        return '<span class="green">分类目录</span>'
                                    }
                                    else {
                                        return FormatYesNo(v)
                                    }
                                }
                            })

                        }, {
                            header: '面板注册数',
                            dataIndex: 'regNum',
                            tpl: new Ext.XTemplate('{regNum:this.format}', {
                                format: function(v, node) {
                                    if (!node.leaf) {
                                        return '<span class="green">分类目录</span>'
                                    }
                                    else {
                                        return ((1 * v) == 0 ? "<span class=red>未注册</span>" : v)
                                    }
                                }
                            }
                            )
                        }],
                    loader: new Ext.ux.tree.TreeGridLoader({
                        dataUrl: '../dataUtil.jsp?Action=5',
                        listeners: {
                            'beforeload': function() {
                                myMask.show();
                            },
                            'load': function(obj,node) {
                                myMask.hide();
                                 tree.getRootNode().setId(-1)
                            }
                        }
                    }),
                    listeners: {
                        'dblclick': edit
                    }
                })
              new Ext.ux.tree.TreeGridSorter(tree, {
                    folderSort: true,
                    dir: "asc",
                    sortType: function(node) {
                        //return node.list_no;
                      return parseInt(node.id , 10);
                    }
                });
                 //tree.fireEvent('headerClick', tree.columns[0]); 
                function ok() {
                    if (win)
                        win.close();
                    //tree.root.reload();
                    var se = tree.getSelectionModel().getSelectedNode();
                    var cid;
                    if (se) {
                        cid = se.attributes.parent_id == -1 ? se.id : se.attributes.parent_id;
                    }
                    tree.getLoader().load(tree.root, function() {
                        if (cid) {
                            tree.getNodeById(cid).expand();
                            //se.parentNode.expand()
                            //tree.getNodeById(se.id).parentNode.expand();
                            //if(tree.getNodeById(se.id)){
                            //tree.getNodeById(se.id).select();
                            //}
                        }
                    })
                }
                var yesNoStore = new Ext.data.SimpleStore({
                    fields: ['text', 'value'],
                    data: [['是', '1'], ['否', '0']]
                })
                function formIt(fid) {
                    it1 = new Ext.form.TextField({
                        fieldLabel: '模块名称',
                        name: 'name',
                        allowBlank: false
                    });
                    it2 = new Ext.form.TextField({
                        fieldLabel: '模块代码',
                        name: 'code'
                    });
                    it3 = new Ext.form.TextField({
                        fieldLabel: '模块路径',
                        name: 'url'
                    });
                    it4 = new netedu.comb({
                        store: new Ext.data.SimpleStore({
                            fields: ['text', 'value'],
                            data: [['功能', '0'], ['权限', '1']]
                        }),
                        fieldLabel: '模块类型',
                        name: 'type',
                        value: 0

                    })
                    it5 = new netedu.comb({
                        store: yesNoStore,
                        fieldLabel: '是否启用',
                        name: 'status',
                        value: 1

                    })
                    it6 = new netedu.comb({
                        store: yesNoStore,
                        fieldLabel: '是否完成',
                        name: 'is_finish',
                        value: 0

                    })
                    it7 = new netedu.comb({
                        store: yesNoStore,
                        fieldLabel: '跳出框架',
                        name: 'is_blank',
                        value: 0

                    })
                    it8 = new netedu.comb({
                        store: yesNoStore,
                        fieldLabel: '是否刷新',
                        name: 'is_reload',
                        value: 0
                    })
                    it9 = new netedu.comb({
                        store: yesNoStore,
                        fieldLabel: '通用权限',
                        name: 'is_public',
                        value: 0

                    })
                    if (fid == -1) {
                        return [it1, it2]
                    }
                    else {
                        return [it1, it2, it3, it4, it9, it5, it6, it7, it8]
                    }
                }
                function reg() {
                    var se = tree.getSelectionModel().getSelectedNode();
                    if (!se) {
                        alert("先选择一个模块！");
                        return;
                    }
                    if (se.attributes.type == "1") {
                        alert("权限无需注册控制面板！");
                        return;
                    }
                    if (win)
                        win.close();
                    win = new netedu.formWin({
                        title: '注册功能到控制面板',
                        _it: [new Ext.form.TextField({
                                fieldLabel: '面板节点名称',
                                name: 'name',
                                id: 'name',
                                allowBlank: false
                            }), new netedu.comb({
                                tpl: '<tpl for="."><div class="x-combo-list-item">{[xindex]}、{text}</div></tpl>',
                                fieldLabel: '控制面板分类',
                                store: new Ext.data.JsonStore({
                                    url: 'module_panel.jsp?Action=2',
                                    autoLoad: true
                                }),
                                emptyText: '选择一个分类...',
                                name: 'parent_id'
                            })],
                        _url: 'module_panel_update.jsp?Action=3&group_no=0&module_info_id=' + se.id,
                        _id: theId,
                        _suc: ok
                    })
                    Ext.getCmp("name").setValue(se.text);
                    win.show()
                }
                function add() {
                    var se = tree.getSelectionModel().getSelectedNode();
                    if (!se) {
                        alert("先选择一个模块！");
                        return;
                    }
                    if (win)
                        win.close();

                    win = new netedu.formWin({
                        title: '为《' + se.text + '》添加同级模块',
                        _it: formIt(se.attributes.parent_id),
                        _url: '<%=ModName%>_update.jsp?Action=3&parent_id=' + se.attributes.parent_id,
                        _id: theId,
                        _suc: ok
                    })
                    win.show()
                }
                function addNode() {
                    var se = tree.getSelectionModel().getSelectedNode();
                    if (!se) {
                        alert("先选择一个模块！");
                        return;
                    }
                    if (se.attributes.parent_id != '-1') {
                        if (!confirm("该节点不是分类节点，确定还要添加子节点么？")) {
                            return;
                        }
                    }
                    if (win)
                        win.close();
                    win = new netedu.formWin({
                        title: '为《' + se.text + '》添加子模块',
                        _it: formIt(),
                        _url: '<%=ModName%>_update.jsp?Action=3&parent_id=' + se.id,
                        _id: theId,
                        _suc: ok
                    })
                    win.show()
                }
                function edit() {
                    var se = tree.getSelectionModel().getSelectedNode();
                    if (!se) {
                        alert("先选择一个模块！");
                        return;
                    }
                    if (win)
                        win.close();
                    win = new netedu.formWin({
                        title: '编辑模块',
                        _it: formIt(se.attributes.parent_id),
                        _url: '<%=ModName%>_update.jsp?Action=4',
                        _id: se.id,
                        _suc: ok
                    })
                    win.show()
                    it1.setValue(se.text);
                    it2.setValue(se.attributes.code);
                    it3.setValue(se.attributes.url);
                    it4.setValue(se.attributes.type);
                    it5.setValue(se.attributes.status);
                    it6.setValue(se.attributes.is_finish);
                    it7.setValue(se.attributes.is_blank);
                    it8.setValue(se.attributes.is_reload);
                    it9.setValue(se.attributes.is_public);
                }

                function del() {
                    var se = tree.getSelectionModel().getSelectedNode();
                    if (!se) {
                        alert("先选择一个需要删除的节点！");
                        return;
                    }
                    if (se.hasChildNodes()) {
                        alert("该节点拥有子节点，无法删除！");
                        return;
                    }
                    if (!confirm("确认要删除”" + se.text + "”节点么？")) {
                        return;
                    }
                    fn_btn_ajax('<%=ModName%>_update.jsp?&Action=5', 'id=' + se.id, ok)
                }

            }

            Ext.onReady(Mod);
        </script>
    </head>
    <body>
        <div id='<%=ModName%>_content' class='my_grid'></div>
        <div id='win'></div>
    </body>
</html>
