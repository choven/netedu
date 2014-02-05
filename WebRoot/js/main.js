netedu.frame = Ext.extend(Ext.Viewport, {
    _indexTitle: '我的桌面',
    _autoLoad: true,
    _activeItem: 1,
    _listUrl: '',
    _shiftPress: false,
    layout: 'border',
    cls: 'gfm',
    top: new Ext.BoxComponent({
        region: 'north',
        el: 'top70'
    }),
    _clsStore: new Ext.data.JsonStore({
        autoLoad: false
    }),
    _smsStore: new Ext.data.JsonStore({
        url: 'user/assi_ajax.jsp?Action=0',
        autoLoad: false,
        listeners: {
            load: function(s, rs) {
                var n = rs[0].get("sms");
                if (Ext.isNumber(n) && n > 0) {
                    //用户设置
                    if (user_set.isVoiceTip != "1") {
                        n = n + '<embed type="application/x-shockwave-flash" flashvars="sFile=pm.mp3" src="player.swf"  height="0" width="0" >';
                    }
                    document.getElementById("smsTip").innerHTML = n;
                }
            }
        }
    }),
    left: new Ext.Panel({
        region: 'west',
        split: true,
        collapseMode: 'mini',
        width: 220,
        border: false,
        layout: 'accordion',
        layoutConfig: {
            collapseFirst: false,
            titleCollapse: true,
            activeOnTop: false
        }
    }),
    center: new Ext.TabPanel({
        region: 'center',
        margins: '-30 0 0 -7',
        activeTab: 0,
        deferredRender: true,
        enableTabScroll: true,
        items: [new Ext.Panel({
                title: '-',
                id: 'main',
                html: '<iframe name="main" src="main.jsp" width="100%" height="100%" frameBorder="0"></iframe>',
                autoScroll: true
            })]
    }),
    initComponent: function() {
        this.center.getItem(0).setTitle(this._indexTitle)
        var url = this._listUrl;
        this._clsStore.on('load', function(s, rs) {
            if (rs.length > 0) {
                var firstItem = 0;
                for (var i = 0; i < rs.length; i++) {
                    if (i == 0) {
                        firstItem = rs[i].get("id");//得到第一个分类的ID，用于默认展开
                    }
                    this.left.body.update();//清空，用于更新缓存时刷新数据
                    this.left.add(new Ext.Panel({
                        border: false,
                        autoScroll: true,
                        tools: [{
                                id: 'refresh',
                                handler: function(event, toolEl, pane) {
                                    pane.getUpdater().refresh();
                                }
                            }],
                        loaded: false,
                        title: rs[i].get("name"),
                        id: 'left_' + rs[i].get("id"),
                        url: url + '&parent_id=' + rs[i].get("id"),
                        listeners: {
                            'expand': function() {
                                if (this.loaded) {
                                    return;
                                }
                                this.load({
                                    url: this.url,
                                    scope: this,
                                    callback: function() {
                                        this.loaded = true;
                                    }
                                })
                            }
                        }
                    }))
                }
                //this.left.getLayout().setActiveItem(this._activeItem);
                this.left.doLayout();
                var t = Ext.getCmp("left_" + this._activeItem)
                if (!t || this._activeItem == firstItem) {
                    t = Ext.getCmp("left_" + firstItem)//当指定的参数不存在时，默认展开第一个
                    t.expand();
                    t.fireEvent("expand")//若指定的分类为第一个，EXT会默认展开，不会触发expand事件
                }
                else {
                    t.expand();
                }
            }
        }, this)

        this.items = [this.top, this.left, this.center]
        this.on('afterrender', function() {
            if (this._autoLoad) {
                this._clsStore.load()
            }
        })
        netedu.frame.superclass.initComponent.call(this);
    },
    openApp: function(code, url, title, isBlank, is_reload, pid) {
        //用户设置
        //alert(Ext.EventObject.getKey())
        if (isBlank == true || (user_set.maxTab && user_set.maxTab == "0")) {
            //window.open(url, "_blank","fullscreen=1,toolbar=0,location=0,directories=0,status=0,menubar=0,resizable=0,top=10000,left=10000");
            this._shiftPress = false;
            window.open(url, "_blank", "fullscreen=1");
            //window.open(url, "_blank");
            return;
        }
        if (is_reload == undefined || is_reload == null) {
            is_reload = false;
        }
        if (pid == undefined || pid == null) {
            pid = code;
        }
        var obj = Ext.getCmp(code);
        if (obj) {
            this.center.setActiveTab(obj);
            if (is_reload == true) {
                obj.setTitle(title)
                //window.parent[code].location.reload();
                //解决url参数发生变化的情况
                obj.body.update('<iframe name="' + code + '" src="' + url + '" width="100%" height="100%" frameBorder="0"></iframe>');
            }
            return;
        }
        //用户设置  桌面常开
        if (user_set.maxTab && -9 != Ext.num(user_set.maxTab, -9) && 1 * user_set.maxTab > 0 && this.center.items.getCount() > 1 * user_set.maxTab) {
            this.center.items.itemAt(1).destroy();
        }
        var tab = new Ext.Panel({
            id: code,
            title: title,
            html: '<iframe name="' + code + '" src="' + url + '" width="100%" height="100%" frameBorder="0"></iframe>',
            closable: true,
            autoDestroy: true,
            listeners: {
                scope: this,
                'activate': function() {
                    if (pid && Ext.getCmp("left_" + pid)) {
                        Ext.getCmp("left_" + pid).expand();
                    }
                    if (this.assiWin && this.assiWin.hidden == false) {//如果没打开面板，或者隐藏的面板，不刷新， 因为打开面板和显示面板均会触发刷新事件
                        this.refreshAssi();
                    }
                }
            }
        });
        this.center.add(tab);
        this.center.setActiveTab(tab);
    },
    getActiveMod: function() {
        return this.center.getActiveTab();
    },
    siteChange: function() {
        if (this.win) {
            this.win.destroy();
        }
        this.win = new netedu.win({
            autoHeight: true,
            width: 600,
            title: '切换当前查看的学习中心/函授站',
            x: document.body.clientWidth - 130 - 600,
            y: 50,
            bodyStyle: "background:#fff",
            autoLoad: 'dataUtil.jsp?Action=9&lb_bm=7',
            cls: 'org',
            tbar: new Ext.Toolbar({
                items: [{
                        text: '网络教育',
                        iconCls: 'myicon my_refresh',
                        toggleGroup: 'views',
                        pressed: true,
                        handler: function() {
                            if (!this.pressed) {
                                this.toggle();
                                return;
                            }
                            this.ownerCt.ownerCt.load({url: 'dataUtil.jsp?Action=9&lb_bm=7'})
                        }
                    }, '-', {
                        text: '成人教育',
                        iconCls: 'myicon my_refresh',
                        toggleGroup: 'views',
                        handler: function() {
                            if (!this.pressed) {
                                this.toggle();
                                return;
                            }
                            ;
                            this.ownerCt.ownerCt.load({url: 'dataUtil.jsp?Action=9&lb_bm=5'})
                        }
                    }, '-', {
                        text: '自学考试',
                        iconCls: 'myicon my_refresh',
                        toggleGroup: 'views',
                        handler: function() {
                            if (!this.pressed) {
                                this.toggle();
                                return;
                            }
                            ;
                            this.ownerCt.ownerCt.load({url: 'dataUtil.jsp?Action=9&lb_bm=4'})
                        }
                    }]
            })
        })
        this.win.show()
    },
    setCurrSite: function(code, title) {
        //Ext.util.Cookies.set("curr_bj_bm",code)
        //Ext.util.Cookies.set("curr_bj_mc",title)
        //注意 path，不带入别的应用
        Ext.util.Cookies.set('curr_bj_bm', code, null, '/ems/')
        Ext.util.Cookies.set('curr_bj_mc', title, null, '/ems/')
        //alert(Ext.util.Cookies.get("curr_bj_mc"))
        this.win.close();
        document.getElementById("siteChange").innerHTML = title;
        window.parent[this.getActiveMod().id].location.reload();
    },
    initAssi: function() {
        this.assiWin = new Ext.Window({
            x: document.documentElement.clientWidth - 310,
            y: 98,
            layout: 'accordion',
            autoHeight: false,
            width: 260,
            height: 500,
            id: 'assi',
            headerCfg: {
                tag: 'div',
                cls: 'assi_win_header',
                html: '<div class="assi_title">系统助手V1.1</div><form action="javascript:void(0);" onsubmit="assiQuery()"><div class="assi_search"><input id="assi_search" onfocus=this.value="" onblur=this.value=(this.value==""?"请输入关键字搜索":this.value) type="text"></form></div>'
            },
            closeAction: 'hide',
            border: true,
            frame: true,
            bodyStyle: 'padding:5px;background:#fff ',
            defaults: {
                border: false,
                autoScroll: true,
                headerCfg: {
                    tag: 'div',
                    cls: 'assi_panel_header'
                }
            },
            items: [new Ext.Panel({
                    title: '系统帮助',
                    id: 'assi_faq'
                }), new Ext.Panel({
                    title: '在线用户',
                    id: 'assi_user',
                    autoLoad: 'user/assi_ajax.jsp?Action=1&online=1',
                    listeners: {
                        'expand': function() {
                            this.getUpdater().refresh();
                        }
                    }
                }), new netedu.form({
                    title: '问题反馈',
                    frame: false,
                    labelWidth: 30,
                    id: 'assi_ask',
                    labelAlign: 'left',
                    hideLabels: true,
                    items: [new Ext.form.TextArea({
                            name: 'content',
                            blankText: '不能为空，请正确填写！',
                            allowBlank: false,
                            autoScroll: false
                        })],
                    buttonAlign: 'center',
                    buttons: [{
                            text: '提 交',
                            scope: this, //回到主框架
                            handler: function(b) {
                                var f = b.ownerCt.ownerCt;
                                var mod = this.getActiveMod();
                                if (f.getForm().isValid()) {
                                    if (!confirm("您当前所在的模块为《" + mod.title + "》，是否是针对该模块咨询问题？如不是，请先打开问题对应的模块再提交问题，以方便我们解决问题！")) {
                                        return;
                                    }
                                    f.getForm().submit({
                                        url: 'user/help_update.jsp?Action=3',
                                        method: 'POST',
                                        params: {
                                            title: mod.title,
                                            code: mod.id,
                                            url: window.frames[mod.id].document.location.href
                                        },
                                        success: function() {
                                            f.getForm().reset();
                                            alert("问题提交成功，管理人员在回复后，将发送站内消息给您！")
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
                        }]
                }), new Ext.Panel({
                    title: '我的事务',
                    autoLoad: 'user/assi_ajax.jsp?Action=3'
                })]
        })
    },
    showAssi: function() {
        var mod = this.getActiveMod();
        if (!this.assiWin) {
            this.initAssi();
        }
        this.assiWin.show();
        this.refreshAssi();
    },
    refreshAssi: function() {
        var str = '当前显示关于“' + this.getActiveMod().title + '”的帮助';
        Ext.get("assi_search").set({
            value: str
        })
        Ext.getCmp("assi_faq").load({
            url: 'user/assi_ajax.jsp?Action=2&code=' + this.getActiveMod().id
        })
        if (Ext.getCmp("assi_user").collapsed == false) {
            Ext.getCmp("assi_user").getUpdater().refresh();
        }
    },
    reLogin: function() {
        var s = this._clsStore;
        fn_btn_ajax('dataUtil.jsp?Action=-1', '', function() {
            s.reload();
            user_set = Ext.decode(Ext.util.Cookies.get("user_setting"), true);//更新系统变量
        })
    },
    logTask: function() {
        task = {
            scope: this,
            run: function() {
                this._smsStore.load();
                //当打开了助手、且未隐藏、且已切换到在线用户面板 时自动刷新在线用户   //另外一个刷新动作，在线用户面板被展开时
                if (Ext.getCmp("assi_user") && Ext.getCmp("assi_user").isVisible() == true && Ext.getCmp("assi_user").collapsed == false) {
                    Ext.getCmp("assi_user").getUpdater().refresh();
                }
            },
            interval: 1000 * 60 * 16
        }
        return task;
    }
});

