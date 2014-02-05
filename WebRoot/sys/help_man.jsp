<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
    if (!login.hasUrlPerm()) {
        out.print("没有权限访问此功能");
        return;
    }
    String id = StringUtil.nullValue(request.getParameter("id"));
    String keys = StringUtil.nullValue(request.getParameter("key"));
    String module_id = StringUtil.nullValue(request.getParameter("module_id"));
    sql = "SELECT a.id, isnull(b.name,case when a.module_id=-1 then '根目录/全局' else '模块不存在' end ) as c_模块,a.title AS c_标题";
    sql += " ,CONVERT(varchar(16),a.asw_date,111) AS c_更新时间";
    sql += " FROM dbo.help_center as a left join  module_info as b on a.module_id=b.id ";
    sql += " WHERE a.is_system=1 ";
    if (!"".equals(keys)) {
        sql += " AND (a.title LIKE '%" + keys + "%')";
    }
    if (!"".equals(module_id)) {
        sql += " AND (a.module_id = '" + module_id + "')";
    }
    try {
        switch (ActionID) {
            case 3:
                sql = "select asw_content from help_center where id='" + id + "' and is_system=1";
                sb.append(Data.queryJSON(sql, "list", true));
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
        <script type="text/javascript" src="/file/ext-3.3.0/ux/ComboBoxTree.js"></script>
        <script type="text/javascript" src="/file/fckeditor2.6.5/fckeditor/fckeditor.js"></script>
        <script type="text/javascript" src="/file/SWFUpload_v2.2.0.1/swfupload.js"></script>
        <script type="text/javascript">
            var modTitle = '根目录/全局', module_id = '-1', id = '', Action = '';
            Ext.onReady(function() {
                var pageHeight = document.body.clientHeight < 100 ? document.documentElement.clientHeight - 29 : document.body.clientHeight - 4;
                var modTree = new Ext.ux.ComboBoxTree({
                    width: 238,
                    emptyText: '选择模块筛选数据，默认显示全部...',
                    fieldLabel: '对应模块',
                    tree: new Ext.tree.TreePanel({
                        rootVisible: true,
                        //singleExpand:true,
                        loader: new Ext.tree.TreeLoader({
                            dataUrl: '../dataUtil.jsp?Action=5',
                            listeners: {
                                'load': function(o, node) {
                                }
                            }
                        }),
                        root: {
                            nodeType: 'async',
                            text: '根目录/全局',
                            id: '-1'
                        }
                    }),
                    //selectNodeModel: 'leaf', //只选叶子
                    selectNodeModel: 'all',
                    listeners: {
                        beforeselect: function(comboxtree, rs) {
                            if (rs.attributes.type == "1") {
                                alert("权限节点无需注册到控制面板");
                                return false;
                            }
                        },
                        select: function(comboxtree, rs) {
                            grid.store.setBaseParam('key', "");
                            grid.store.setBaseParam('module_id', rs.id);
                            grid.store.load()
                            modTitle = rs.text;
                            module_id = rs.id;
                        }
                    }
                });
                var tbar = new Ext.Toolbar({
                    items: [ '-', {
                            text: '刷新',
                            iconCls: 'myicon my_refresh',
                            handler: function() {
                                grid.store.reload();
                            }
                        }, '-',{
                            text: '添加',
                            iconCls: 'myicon my_add2',
                            handler: add
                        }, '-', {
                            text: '编辑',
                            iconCls: 'myicon my_edit',
                            handler: edit
                        }, '-', {
                            iconCls: 'myicon my_find',
                            text: '显示全部',
                            handler: function() {
                                modTree.reset();
                                grid.store.setBaseParam('key', "");
                                grid.store.setBaseParam('module_id', "");
                                grid.store.load();
                            }
                        }, '-', '按模块筛选：', modTree, '-', '搜索全部：', new netedu.search({
                            emptyText: '输入关键字查询...',
                            _t1Click: function() {
                                grid.store.setBaseParam('key', "");
                                grid.store.load();
                            },
                            _t2Click: function() {
                                modTree.reset();
                                grid.store.setBaseParam('module_id', "");
                                grid.store.setBaseParam('key', this.getValue());
                                grid.store.load();
                            }
                        }), '->', {
                            text: '删除',
                            iconCls: 'myicon my_del',
                            handler: function() {
                                grid.initDel('id', '<%=ModName%>_update.jsp?Action=5', ok)
                            }
                        },'-', {
                            text: '导出数据',
                            iconCls: 'myicon my_excel2',
                            handler: function() {
                                grid.initExport()
                            }
                        }]
                });
                var grid = new netedu.grid({
                    tbar: tbar,
                    border: false,
                    autoHeight: false,
                    height: pageHeight,
                    _pageSize: Math.floor((pageHeight - 20) / 23),
                    _cm: '<%=cm%>'
                });
                grid.store.load();
                grid.on('rowdblclick', edit);
                var form = new netedu.form({
                    title: '添加帮助',
                    frame: false,
                    border: false,
                    width: 800,
                    defaults: {
                        anchor: '100%',
                        blankText: '不能为空，请正确填写！',
                        selectOnFocus: true
                    },
                    items: [new Ext.form.TextField({
                            fieldLabel: '节点标题',
                            allowBlank: false,
                            name: 'title'
                        }), {
                            xtype: "textarea",
                            name: 'fck',
                            fieldLabel: '节点帮助',
                            listeners: {
                                'afterrender': function() {
                                    oFCKeditor = new FCKeditor('fck');
                                    oFCKeditor.BasePath = '/file/fckeditor2.6.5/fckeditor/';
                                    oFCKeditor.Height = (document.body.clientHeight - 150 < 300 ? 300 : document.body.clientHeight - 150);
                                    oFCKeditor.ToolbarSet = 'admin';
                                    //oFCKeditor.Config["FontFormats"] = "" ;
                                    oFCKeditor.Config.FontFormats = 'p;h2';
                                    oFCKeditor.Value = '123';
                                    oFCKeditor.ReplaceTextarea();//用FCK编辑器替换Ext中的textarea 
                                }
                            }
                        }],
                    buttons: [{
                            text: '提 交',
                            handler: function() {
                                if (form.getForm().isValid()) {
                                    form.getForm().submit({
                                        url: '<%=ModName%>_update.jsp',
                                        method: 'POST',
                                        params: {
                                            Action: Action,
                                            id: id,
                                            module_id: module_id,
                                            asw_content: FCKeditorAPI.GetInstance("fck").GetXHTML(true)
                                        },
                                        success: function() {
                                            grid.store.reload();
                                            p.getLayout().setActiveItem(0);
                                        },
                                        failure: function(form, action) {
                                            Ext.Msg.alert('操作错误提示', action.result.errors);
                                        },
                                        waitMsg: '正在保存数据，请稍后...'
                                    });
                                }
                                else {
                                    alert('请检查右侧的错误提示信息！');
                                }
                            }
                        }, {
                            text: '返 回',
                            handler: function() {
                                form.getForm().reset();
                                FCKeditorAPI.GetInstance("fck").SetHTML("");
                                p.getLayout().setActiveItem(0);

                            }
                        }]

                })
                var p = new Ext.Panel({
                    layout: 'card',
                    renderTo: '<%=ModName%>_content',
                    items: [grid, form],
                    border: false,
                    activeItem: 0
                })

                function ok() {
                    grid.store.reload();
                }
                function add() {
                    Action = 3;
                    p.getLayout().setActiveItem(1);
                    form.setTitle('为《' + modTitle + '》添加帮助');
                    form.getForm().findField("title").setValue('《' + modTitle + '》模块使用说明');
                }
                function edit() {
                    var rows = grid.initSeChk(1);
                    if (!rows)
                        return false;

                    new Ext.data.JsonStore({
                        url: '<%=ModName%>.jsp?Action=3&id=' + rows[0].get('id'),
                        autoLoad: true,
                        listeners: {
                            'load': function(store, records) {
                                if (records.length > 0) {
                                    Action = 4;
                                    id = rows[0].get('id');
                                    form.getForm().findField("title").setValue(rows[0].get('c_标题'));
                                    form.setTitle('编辑《' + modTitle + '》的帮助');
                                    FCKeditorAPI.GetInstance("fck").SetHTML(records[0].data.asw_content);
                                    p.getLayout().setActiveItem(1);
                                }
                                else {
                                    alert("该帮助不存在，请刷新数据。")
                                }
                            }
                        }
                    });

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
        out.print(sb.toString());
    }%>