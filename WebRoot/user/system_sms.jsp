<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
    String s = StringUtil.nullValue(request.getParameter("s"), "1");
    try {
        switch (ActionID) {
            case 2:
                sql = "SELECT sms.id , sms.title , sms.uidFrom, sms.uidTo ";
                sql += "   ,ui.user_name as Nfrom  ";
                sql += "   ,ui2.user_name as Nto  ";
                sql += "   , sms.is_readed , CONVERT(varchar(16),sms.created_date,120) AS time   ";
                sql += " FROM  system_sms    sms  ";
                sql += "  left join  user_info ui  on ui.user_id=sms.uidFrom ";
                sql += "  left join  user_info ui2  on ui2.user_id=sms.uidTo ";
                sql += "  where sms.status=1  ";
                if ("1".equals(s)) {
                    sql += "  and sms.uidTo='" + user_id + "' ";
                }
                if ("2".equals(s)) {
                    sql += "  and sms.uidFrom='" + user_id + "'";
                }
                out.print(Data.queryJSON(sql, "order by id desc", request));
                break;
            case 1:
//sb.append(sql); %>
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>用户组管理</title>
        <%@ include file="../ext-3.3.0.jsp" %>
        <style>
          
            .mailbox{
                 padding-left: 23px;
                 background-image: url("/file/ext-3.3.0/resources/images/default/tree/folder-open.gif");
                 background-repeat: no-repeat;
                 background-position: 3px 0;
            }
            .mailboxlist{
                 padding-left: 23px;
                 background-image: url("/file/ext-3.3.0/resources/images/default/tree/folder.gif");
                 background-repeat: no-repeat;
                 background-position: 3px 2px;
            }
        </style>
        <script type="text/javascript">
            var win, it1, it2, it3, it4, it5, it6, it7
            Ext.onReady(function() {
                var pageHeight = document.body.clientHeight;
                var tbar = new Ext.Toolbar({
                    items: ['-', '切换文件夹：', new netedu.comb({
                            cls :"mailbox",
                            tpl: '<tpl for="."><div class="x-combo-list-item mailboxlist ">{[xindex]}、{text}</div></tpl>',
                            store: new Ext.data.SimpleStore({
                                fields: ['text', 'value'],
                                data: [['我的收件箱', '1'], ['我的发件箱', '2']]
                            }),
                            value: 1,
                            listeners: {
                                'select': function(c, e, i) {
                                    grid.store.setBaseParam('s', c.getValue());
                                    grid.store.load();
                                }
                            },
                            emptyText: '选择一个用户类型筛选数据...'
                        }), '-', {
                            text: '阅读消息',
                            iconCls: 'myicon my_ok2',
                            handler: read
                        }, '-', {
                            text: '回复消息',
                            iconCls: 'myicon my_add2',
                            handler: re
                        }, '-', {
                            text: '发送消息',
                            iconCls: 'myicon my_email',
                            handler: function() {
                                window.parent.openApp("user_list", "user/user_list.jsp", "用户列表", false, false)
                            }
                        }, '->', {
                            text: '删除消息',
                            iconCls: 'myicon my_del',
                            handler: del
                        }, '-', {
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
                        "dataIndex": "title",
                        "header": "标题"
                    }, {
                        "sortable": true,
                        "dataIndex": "Nfrom",
                        width: 180,
                        fixed: true,
                        "header": "来自"
                    }, {
                        "sortable": true,
                        "dataIndex": "Nto",
                        width: 180,
                        fixed: true,
                        "header": "发往"
                    }, {
                        "sortable": true,
                        "dataIndex": "is_readed",
                        "header": "是否已读",
                        width: 65,
                        fixed: true,
                        renderer: FormatYesNo
                    }, {
                        "sortable": true,
                        "dataIndex": "time",
                        "header": "发送时间",
                        fixed: true,
                        width: 110
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
                grid.on('rowdblclick', read);
                function formIt() {
                    it1 = new Ext.form.TextField({
                        fieldLabel: '对象',
                        name: 'to',
                        disabled: true,
                        allowBlank: false
                    });
                    it2 = new Ext.form.TextField({
                        fieldLabel: '标题',
                        name: 'title',
                        allowBlank: false
                    });
                    it3 = new Ext.form.TextArea({
                        fieldLabel: '内容',
                        name: 'content',
                        allowBlank: false
                    });
                    return [it1, it2, it3]
                }
                function ok() {
                    if (win)
                        win.close();
                    grid.store.reload();
                }
                function re() {
                    var rows = grid.initSeChk(1);
                    if (!rows)
                        return false;
                    if (rows[0].get('uidTo') != '<%=user_id%>') {
                        alert("这不是发送给你的消息，不用回复！")
                        return;
                    }
                    if (win)
                        win.close();
                    win = new netedu.formWin({
                        title: '回复系统消息',
                        _it: formIt(),
                        _url: 'system_sms_update.jsp?Action=3',
                        _id: rows[0].get('uidFrom'),
                        _suc: ok
                    });
                    win.show();
                    it1.setValue(rows[0].get('Nfrom'));
                    it2.setValue('re:' + rows[0].get('title'));
                }
                function read() {
                    var rows = grid.initSeChk(1);
                    if (!rows)
                        return false;
                    if (win)
                        win.close();
                    pkid = rows[0].get('id');
                    win = new netedu.win({
                        autoHeight: false,
                        height: 300,
                        html: '<iframe name="main" src="show_pm.jsp?id=' + pkid + '" width="100%" height="100%" frameBorder="0"></iframe>',
                        buttons: [{
                                text: '回复',
                                handler: re
                            }, {
                                text: '关闭',
                                id: 'f_reset',
                                handler: ok
                            }]
                    })
                    win.show();
                }
                function del() {
                    var rows = grid.initSeChk();
                    if (!rows)
                        return false;
                    if (rows[0].get('uidTo') != '<%=user_id%>') {
                        alert("这不是发送给你的消息，不能删除！")
                        return;
                    }
                    fn_btn_ajax('<%=ModName%>_update.jsp?Action=5', 'id=' + rows[0].get('id'), ok);
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