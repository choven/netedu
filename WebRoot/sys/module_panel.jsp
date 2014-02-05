<%@page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
    try {
        switch (ActionID) {
            case 2:
                sql = " SELECT id AS value, name AS text";
                sql += " FROM  module_panel ";
                sql += " WHERE  parent_id='-1'";
                sql += " order by list_no";
                out.print(Data.queryJSON(sql, "list", true));
                break;
            case 1:
                if (!login.hasUrlPerm()) {
                    out.print("没有权限访问此功能");
                    return;
                }
//sb.append(sql); %>
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
        <script type="text/javascript" src="/file/ext-3.3.0/ux/ComboBoxTree.js"></script>
        <script type="text/javascript">
            var win, it1, it2, it3, it4, it5, it6, thePid, theId;
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
                            text: '添加分类',
                            iconCls: 'myicon my_add2',
                            handler: add
                        }, '-', {
                            text: '添加节点',
                            iconCls: 'myicon my_add2',
                            handler: addNode
                        }, '-', {
                            text: '修改数据',
                            iconCls: 'myicon my_edit',
                            handler: edit
                        }, '->', '-', {
                            text: '删除数据',
                            iconCls: 'myicon my_del',
                            handler: del
                        }, '-']
                });
                var tree = new Ext.ux.tree.TreeGrid({
                    renderTo: '<%=ModName%>_content',
                    border: false,
                    //singleExpand:true,
                    enableDD: true, //总开关
                    //enableDrag :true,//整体拖拽
                    enableDrop: true, //仅允许节点交换
                    dropConfig: {
                        allowContainerDrop: true,
                        //appendOnly:true,
                        overClass: 'debug'
                    },
                    rootVisible: false,
                    tbar: tbar,
                    columns: [{
                            header: '组序号',
                            dataIndex: 'group_no',
                            width: 150
                        }, {
                            header: '排序号',
                            dataIndex: 'list_no',
                            width: 150
                        }, {
                            header: '面板名称',
                            dataIndex: 'text'
                        }, {
                            header: '对应模块名称 ',
                            dataIndex: 'mod_title'
                        }, {
                            header: '对应模块代码',
                            dataIndex: 'code'
                        }],
                    loader: new Ext.tree.TreeLoader({
                        dataUrl: '../dataUtil.jsp?Action=6',
                        listeners: {
                            'beforeload': function() {
                                myMask.show();
                            },
                            'load': function() {
                                myMask.hide();
                                tree.getRootNode().setId(-1)//gridTree不能设置root属性，所以在这里设置rootId以便后续操作
                            }
                        }
                    }),
                    listeners: {
                        'beforenodedrop': function(obj) {
                            if (obj.point != "above" || obj.target.parentNode != obj.dropNode.parentNode) {//禁止跨节点
                                obj.cancel = true;
                                obj.dropStatus = true;
                                return false;
                            }
                            var target_index = obj.target.parentNode.indexOf(obj.target)
                            var index = obj.dropNode.parentNode.indexOf(obj.dropNode)
                            var dir = (target_index < index ? 'up' : 'down');//判断方向
                            fn_btn_ajax('<%=ModName%>_update.jsp?&Action=6', 'dir=' + dir + '&id=' + obj.dropNode.id + '&parent_id=' + obj.dropNode.parentNode.id + '&index=' + target_index + '&oIndex=' + index, ok)
                        },
                        'dblclick': edit
                    }

                });
                new Ext.ux.tree.TreeGridSorter(tree, {
                    folderSort: true,
                    dir: "asc",
                    sortType: function(node) {
                        return parseInt(node.list_no, 10);
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
                        if (cid && tree.getNodeById(cid)) {
                            tree.getNodeById(cid).expand();
                            //se.parentNode.expand()
                            //tree.getNodeById(se.id).parentNode.expand();
                            //if(tree.getNodeById(se.id)){
                            //tree.getNodeById(se.id).select();
                            //}
                        }
                    })
                }
                function formIt(fid) {
                    it1 = new Ext.form.TextField({
                        fieldLabel: '面板名称',
                        name: 'name',
                        allowBlank: false
                    });
                    it2 = new netedu.comb({
                        tpl: '<tpl for="."><div class="x-combo-list-item">{[xindex]}、{text}</div></tpl>',
                        fieldLabel: '所属分类',
                        store: new Ext.data.JsonStore({
                            url: '<%=ModName%>.jsp?Action=2',
                            autoLoad: true,
                            listeners: {
                                'load': function() {
                                    var se = tree.getSelectionModel().getSelectedNode();
                                    if (se) {
                                        it2.setValue(se.attributes.parent_id == '-1' ? se.id : se.attributes.parent_id)
                                    }
                                }
                            }
                        }),
                        emptyText: '选择一个分类...',
                        name: 'parent_id'
                    });
                    it3 = new Ext.ux.ComboBoxTree({
                        width: 238,
                        emptyText: '设置对应的模块...',
                        fieldLabel: '对应模块',
                        tree: new Ext.tree.TreePanel({
                            rootVisible: false,
                            //singleExpand:true,
                            loader: new Ext.tree.TreeLoader({
                                dataUrl: '../dataUtil.jsp?Action=5',
                                listeners: {
                                    'load': function(o, node) {
                                        //node.expandChildNodes();
                                        //node.findChild("id",it3.getValue() )
                                    }
                                }
                            }),
                            root: {
                                nodeType: 'async'
                            }
                        }),
                        selectNodeModel: 'leaf', //只选叶子
                        listeners: {
                            beforeselect: function(comboxtree, rs) {
                                if (rs.attributes.type == "1") {
                                    alert("权限节点无需注册到控制面板");
                                    return false;
                                }
                            },
                            select: function(comboxtree, rs) {
                                //if(!it1.getValue()){
                                it1.setValue(this.getRawValue());
                                //}
                            }
                        },
                        hiddenName: 'module_info_id'

                    });
                    it4 = new Ext.form.NumberField({
                        fieldLabel: '分组序号',
                        name: 'group_no',
                        allowBlank: false
                    });
                    it5 = new Ext.form.NumberField({
                        fieldLabel: '排序序号',
                        name: 'list_no',
                        allowBlank: false
                    });
                    it6 = new Ext.form.Hidden({
                        name: 'group_no',
                        value: 0
                    });
                    if (fid == -1) {
                        return [it1, it6]
                    }
                    else {
                        return [it3, it1, it2, it4, it5]
                    }
                }

                function add() {
                    if (win)
                        win.close();
                    win = new netedu.formWin({
                        title: '添加分类',
                        _it: formIt(-1),
                        _url: '<%=ModName%>_update.jsp?Action=3&parent_id=-1&module_info_id=-1',
                        _id: '',
                        _suc: ok
                    })
                    win.show()
                }
                function addNode() {
                    if (win)
                        win.close();
                    win = new netedu.formWin({
                        title: '添加子节点',
                        _it: formIt(0),
                        _url: '<%=ModName%>_update.jsp?Action=3',
                        _id: '',
                        _suc: ok
                    })
                    win.show()
                }
                function edit() {
                    var se = tree.getSelectionModel().getSelectedNode();
                    if (!se) {
                        alert("先选择一个需要修改的节点！");
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
                    it1.setValue(se.text);
                    it4.setValue(se.attributes.group_no);
                    it5.setValue(se.attributes.list_no);
                    it3.on('afterrender', function() {
                        it3.setValue(new Ext.tree.TreeNode({
                            id: se.attributes.module_info_id,
                            text: se.attributes.mod_title
                        }));
                    })

                    win.show()
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
<%
                break;
        }
    } catch (Exception e) {
        out.print(e.toString());
    } finally {
        Data.close();
    }%>
