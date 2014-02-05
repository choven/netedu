<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%

    try {
        switch (ActionID) {

            case 2:
                String keys = StringUtil.nullValue(request.getParameter("key"), "");
                String online = StringUtil.nullValue(request.getParameter("online"), "");
                String user_type_id = StringUtil.nullValue(request.getParameter("user_type_id"), "");
                sql = "SELECT id,user_id, user_name,online_flag";
                sql += " FROM dbo.user_info ";
                sql += " WHERE 1=1 ";
                if (!"".equals(keys)) {
                    sql += " AND (login_name LIKE '%" + keys + "%' OR user_name LIKE '%" + keys + "%')";
                }
                if ("1".equals(online)) {
                    sql += " and online_flag =1";
                }
                if (!"".equals(user_type_id)) {
                    sql += " and user_type_id ='" + user_type_id + "'";
                }
                out.print(Data.queryJSON(sql, "order by id desc", request));
                break;
            case 1:
%>
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title></title>
        <%@ include file="../ext-3.3.0.jsp" %>
        <script type="text/javascript" src="/file/ext-3.3.0/ux/SlidingPager.js"></script>
        <script type="text/javascript">
            var win, it1, it2, it3, it4, it5, it6, it7
            Ext.onReady(function() {
                var pageHeight = document.body.clientHeight < 100 ? document.documentElement.clientHeight - 29 : document.body.clientHeight;
                var userTypeComb = new netedu.comb({
                    tpl: '<tpl for="."><div class="x-combo-list-item">{[xindex]}、{text}</div></tpl>',
                    store: new Ext.data.JsonStore({
                        url: '../dataUtil.jsp?Action=104',
                        autoLoad: true
                    }),
                    listeners: {
                        'select': function(c, e, i) {
                            store.setBaseParam('user_type_id', c.getValue());
                            store.load();
                        }
                    },
                    emptyText: '选择一个用户类型筛选数据...'
                })
                var onlineComb = new netedu.comb({
                    width: 80,
                    tpl: '<tpl for="."><div class="x-combo-list-item">{[xindex]}、{text}</div></tpl>',
                    store: new Ext.data.SimpleStore({
                        fields: ['text', 'value'],
                        data: [['在线', '1'], ['全部', '0']]
                    }),
                    value: 0,
                    listeners: {
                        'select': function(c, e, i) {
                            store.setBaseParam('online', c.getValue());
                            store.load();
                        }
                    },
                    emptyText: '选择一个用户类型筛选数据...'
                })
                var tbar = new Ext.Toolbar({
                    items: ['-', '搜索用户：', new netedu.search({
                            emptyText: '输入关键字查询账户...',
                            _t1Click: function() {
                                //
                                store.setBaseParam('key', "");
                                store.load();
                            },
                            _t2Click: function() {
                                store.setBaseParam('key', this.getValue());
                                store.load();
                            }
                        }), '-', '选择状态：', onlineComb, '-', '选择用户类型：', userTypeComb, '-', {
                            text: '发送站内消息',
                            iconCls: 'myicon my_email',
                            handler: sms
                        }]
                });
                var pageSize = Math.floor((document.body.clientWidth - 20) / 170) * Math.floor((pageHeight - 80) / 30);
                //alert(Math.floor((document.body.clientWidth)/170))
                var mask = new Ext.LoadMask(Ext.getBody(), {
                    msg: "正在加载数据，请稍候..."
                })
                var store = new Ext.data.JsonStore({
                    autoLoad: true,
                    baseParams: {
                        start: 0,
                        limit: pageSize
                    },
                    sortInfo: {
                        field: 'online_flag',
                        direction: 'DESC'
                    },
                    url: '<%=ModName%>.jsp?Action=2',
                    listeners: {
                        'beforeload': function() {
                            mask.show();
                        },
                        'load': function() {
                            mask.hide();
                        }
                    }
                })
                var tpl = new Ext.XTemplate('<div class="user_ct"><tpl for=".">', '<div class="user_li myicon my_unchecked"><div class="myicon my_user_off  <tpl if="online_flag==1"> my_user_boy</tpl>">', '<span class="user_name">{user_name}</span></div></div>', '</tpl>', '<div class="x-clear"></div></div>');

                var p = new Ext.Panel({
                    tbar: tbar,
                    renderTo: '<%=ModName%>_content',
                    border: false,
                    autoHeight: false,
                    height: pageHeight,
                    layout: 'fit',
                    items: new Ext.DataView({
                        store: store,
                        tpl: tpl,
                        id: 'user_view',
                        autoHeight: true,
                        multiSelect: true,
                        simpleSelect: true, //多选无需按CTRL
                        overClass: 'x-view-over',
                        itemSelector: 'div.user_li',
                        //loadingText :"123",
                        emptyText: '<span style="margin:10px">没有数据...</san>',
                        prepareData: function(data) {
                            //data.shortName = Ext.util.Format.ellipsis(data.user_name, 15);
                            return data;
                        }
                    }),
                    bbar: new Ext.PagingToolbar({
                        pageSize: pageSize,
                        store: store,
                        displayInfo: true,
                        plugins: new Ext.ux.SlidingPager()
                    })
                })
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
                        allowBlank: false,
                        height: 250
                    });
                    return [it1, it2, it3]
                }
                function sms() {
                    var rs = Ext.getCmp("user_view").getSelectedRecords();
                    if (rs.length < 1) {
                        alert("请洗选择帐户，按住Ctrl键可以多选。");
                        return;
                    }
                    if (win)
                        win.close();
                    var str = [];
                    var strName = [];
                    Ext.each(rs, function(n) {
                        str.push(n.get("user_id"));
                        strName.push(n.get("user_name"));
                    });
                    win = new netedu.formWin({
                        title: '发送系统消息',
                        width: 600,
                        closeAction: 'hide',
                        _it: formIt(),
                        _url: 'system_sms_update.jsp?Action=3',
                        _id: str.toString(),
                        _suc: function() {
                            win.hide();
                            win.getComponent(0).getForm().reset();
                            alert("消息发送成功！");
                        }
                    });
                    it1.setValue(strName.toString());
                    win.show();
                }
            });
        </script>
        <style type="text/css">
            .user_ct {
                padding: 10px;
                zoom: 1;
            }

            .user_li {
                padding: 0;
                padding-left:20px;
                float: left;
                height: 30px;
                line-height: 20px;
                width: 170px;
                overflow: hidden;
                cursor: pointer;
                zoom: 1;
            }

            .user_name {
                margin-left: 20px;
                display: block;
            }

            .x-view-over {
                color: red;
            }
            .x-view-selected {
                color: green;
                text-decoration: underline;
                background-position: 0 -180px !important;
            }
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
    }%>