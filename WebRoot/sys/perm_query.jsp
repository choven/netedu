<%@page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%

    try {
        switch (ActionID) {
            case 2://按功能节点查看
                sql = " SELECT mi.id,mi.parent_id,mi.name as text,mi.is_public,cast(1 as bit) as expanded";
                sql += " ,(SELECT distinct b.name +'、' AS \"text()\" FROM [user_perm] as a left join user_group as b on a.user_group_id=b.id where a.module_id =mi.id and a.is_user_group=1 FOR XML PATH ('')) as groups";
                sql += " ,(SELECT distinct b.user_name +'、' AS \"text()\" FROM [user_perm] as a left join user_info as b on a.user_id=b.user_id where  a.module_id =mi.id and a.is_user_group=0 FOR XML PATH ('')) as users";
                sql += "  from module_info as mi ";
                out.print(Data.queryJSONTree(sql, -1, "order by id"));
                break;
            case 3:
                sql = " SELECT  mp.id,mp.list_no,mp.group_no, mp.module_info_id, mp.parent_id, mp.name as text,mi.is_public,cast(1 as bit) as expanded";
                sql += " ,(SELECT distinct b.name +'、' AS \"text()\" FROM [user_perm] as a left join user_group as b on a.user_group_id=b.id where a.module_id =mi.id and a.is_user_group=1 FOR XML PATH ('')) as groups";
                sql += " ,(SELECT distinct b.user_name +'、' AS \"text()\" FROM [user_perm] as a left join user_info as b on a.user_id=b.user_id where  a.module_id =mi.id and a.is_user_group=0 FOR XML PATH ('')) as users";
                sql += "  from module_panel as mp LEFT OUTER JOIN  module_info as mi on mp.module_info_id=mi.id ";
                out.print(Data.queryJSONTree(sql, -1, "order by group_no,list_no"));
                break;
            case 1:
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
                    buttonAlign: 'center',
                    items: ['-', {
                            text: '按功能模块查看',
                            handler: function() {
                                if (!this.pressed) {
                                    this.toggle();
                                    return;
                                }
                                tree.getLoader().baseParams.Action = 2;
                                tree.root.reload();
                            },
                            enableToggle: true,
                            pressed: true,
                            toggleGroup: 'views'
                        }, {
                            text: '按控制面板查看',
                            handler: function() {
                                if (!this.pressed) {
                                    this.toggle();
                                    return;
                                }
                                tree.getLoader().baseParams.Action = 3;
                                tree.root.reload();
                            },
                            enableToggle: true,
                            toggleGroup: 'views'
                        }, '-']
                });
                var tree = new Ext.ux.tree.TreeGrid({
                    renderTo: '<%=ModName%>_content',
                    enableDD: false,
                    border: false,
                    rootVisible: false,
                    tbar: tbar,
                    columns: [{
                            header: '模块名称',
                            dataIndex: 'text'
                        }, {
                            header: '已授权用户组',
                            dataIndex: 'groups'
                        }, {
                            header: '已授权用户 ',
                            dataIndex: 'users'
                        }, {
                            header: '是否通用权限 ',
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
                        }],
                    loader: new Ext.tree.TreeLoader({
                        dataUrl: '<%=ModName%>.jsp',
                        baseParams: {
                            'Action': 2
                        },
                        listeners: {
                            'beforeload': function() {
                                myMask.show();
                            },
                            'load': function() {
                                myMask.hide();
                            }
                        }
                    })
                })
                new Ext.ux.tree.TreeGridSorter(tree, {
                    folderSort: true,
                    dir: "asc",
                    sortType: function(node) {
                        return parseInt(node.id, 10);
                    }
                });
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
