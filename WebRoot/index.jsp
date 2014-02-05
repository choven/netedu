<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="baseParameter.jsp" %>
<%
    String appName = Config.appName;
    String appCode = Config.appCode;
    String userTypeId = login.getUserTypeId();
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" " http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns=" http://www.w3.org/1999/xhtml">
    <head>
        <title>
            <%=appName%> 
        </title>
        <%@ include file="meta_link.jsp" %>
        <%@ include file="ext-3.3.0.jsp" %>
    </head>
    <body>
        <!-- <div style="width:520px; height:70px; border-right:1px solid #000; text-align:right; position:absolute;top:0;left:500px"> </div> -->
        <div id="top70">
            <div class="logo">
                <%=appName%>
            </div>
            <div class="top_right" style="text-align:right;">
                <div id="top_right" class="top_nav">
                    <a class='myicon my_user_off' href='logout.jsp'>退出登录</a>
                    <a class='myicon my_refresh' href=javascript:reLogin()>更新缓存</a>
                    <a class='myicon my_help2' href=javascript:showAssi()>系统助手</a>
                    <a class='myicon my_users' href=javascript:bindLogin() id='bindLogin'>帐户切换</a>
                    <a class='myicon my_search2' href=javascript:query()>学生信息查询</a>
                </div>
                <div class="top_nav_info">
                    您以<span class="red"><%=user_name%></span>的身份登陆，当前站点 <span id="siteChange" onclick="siteChange()" class='red'><%=1%></span><span class='arr_down'onclick="siteChange()">&nbsp;</span>，
                    <a href=javascript:readPm()>
                        有<span id="smsTip" class="red b">0</span>条新的站内消息
                    </a>...
                </div>
            </div>
        </div>
        <div id="pmPlay"></div>

        <script language="javascript" type="text/javascript" src="js/main.js"></script>
        <script type="text/javascript">
                        var openApp, query, showAssi, assiSearch, assiQuery, reLogin, assiAsk, readPm, bindLogin, bindMenu, goApp, siteChange, setCurrSite
                        var name = '<%=user_name%>', sUserType = '<%=userTypeId%>', appCode = '<%=appCode%>'
                        //{"defaultCls":"62","isShowAssi":"1","isVoiceTip":"1","maxTab":"1"}
                        var temp = '<%=login.getCookie("user_setting")%>';
                        temp = (temp == '') ? null : temp;
                        var user_set = Ext.decode(temp, true);
                        var activeItem = 62;
                        //if (user_set.defaultCls && Ext.isNumber(user_set.defaultCls)) {//TMD的isNumber
                        if (user_set.defaultCls && -9 != Ext.num(user_set.defaultCls, -9)) {
                            activeItem = 1 * user_set.defaultCls;
                        }
                        Ext.onReady(function() {
                            var myMask = new Ext.LoadMask(Ext.getBody(), {
                                msg: "数据加载中，请您耐心等待..."
                            });
                            new netedu.frame({
                                _indexTitle: '我的桌面',
                                id: appCode,
                                _autoLoad: true,
                                _activeItem: activeItem,
                                _clsStore: new Ext.data.JsonStore({
                                    url: 'dataUtil.jsp?Action=7',
                                    autoLoad: false
                                }),
                                _listUrl: 'dataUtil.jsp?Action=8',
                                listeners: {
                                    'afterrender': function(t) {
                                        t.left.body.on({
                                            'keydown': {
                                                fn: function(e) {
                                                    this._shiftPress = (e.getCharCode() == 16 || e.getCharCode() == 20)
                                                },
                                                scope: this
                                            }
                                        });
                                        openApp = function(code, url, title, isBlank, is_reload, pid) {
                                            //if (document.documentElement.clientWidth <= 1024 && "cdce_apply_free".indexOf(code) > -1) {
                                            //isBlank = true;
                                            //}
                                            if (t._shiftPress == true) {
                                                isBlank = true;
                                            }
                                            t.openApp(code, url, title, isBlank, is_reload, pid);
                                            //alert(shift)
                                        }
                                        reLogin = function() {
                                            t.reLogin();
                                        }
                                        showAssi = function() {
                                            t.showAssi();
                                        }//用户设置
                                        if (user_set.isShowAssi && user_set.isShowAssi == "1") {
                                            showAssi()
                                        }
                                        assiSearch = function() {
                                            Ext.get("assi_search").focus()
                                        }
                                        assiQuery = function() {
                                            var key = Ext.get("assi_search").getValue();
                                            if (key.length < 2) {
                                                alert("关键字至少为2个字。");
                                                return;
                                            }
                                            Ext.getCmp("assi_faq").load({
                                                url: 'user/assi_ajax.jsp?Action=2',
                                                params: 'key=' + key
                                            })
                                        }
                                        assiAsk = function() {
                                            Ext.getCmp("assi_ask").expand();
                                        }
                                        readPm = function() {
                                            new Ext.util.DelayedTask(function() {
                                                document.getElementById("smsTip").innerHTML = "0"
                                            }).delay(1000 * 10);
                                            t.openApp("system_sms", "user/system_sms.jsp", "我的站内消息", false, true)
                                        }
                                        goApp = function(id, type) {
                                            window.open("/" + appCode + "/user/goApp.jsp?id=" + id, type == 2 ? "_self" : "_blank")
                                        }
                                        bindLogin = function() {
                                            new Ext.data.JsonStore({
                                                url: 'user/user_bind.jsp?Action=3',
                                                autoLoad: true,
                                                listeners: {
                                                    'beforeload': function() {
                                                        myMask.show();
                                                    },
                                                    'load': function(store, records) {
                                                        myMask.hide();
                                                        if (records.length == 0) {
                                                            alert("你还没有绑定帐户，请到帐户绑定功能中设置帐户绑定！")
                                                            t.openApp("user_bind", "user/user_bind.jsp", "帐户绑定", false, false)
                                                            return;
                                                        }
                                                        bindMenu = new Ext.menu.Menu();
                                                        for (var i = 0; i < records.length; i++) {
                                                            bindMenu.add({
                                                                text: records[i].data.bind_title,
                                                                iconCls: records[i].data.bind_user_type == 'stu' ? 'myicon my_user_stu' : 'myicon my_user_boy',
                                                                //disabled: records[i].data.status == 1 ? true : false,
                                                                href: 'javascript:goApp(' + records[i].data.id + ',' + records[i].data.open_type + ')'
                                                            }, '-');
                                                        }
                                                        bindMenu.show(Ext.get('bindLogin'))
                                                    }
                                                }
                                            })
                                        }
                                        setCurrSite = function(code, title) {
                                            t.setCurrSite(code, title)
                                        }
                                        siteChange = function() {
                                            t.siteChange();
                                        }
                                        query = function() {
                                            win = new netedu.win({
                                                autoHeight: false,
                                                height: 300,
                                                autoDestroy: false,
                                                autoLoad: 't2.html'
                                            })
                                            win.show()
                                        }
                                        //定时刷新1
                                        new Ext.util.TaskRunner().start(t.logTask());
                                    }
                                }
                            });
                        });
        </script>
        <style>
            #siteChange,.arr_down{
                cursor:pointer;
            }
            .siteChange{
                background:#ffffff;
                height:auto;
                zoom:1;
                border-top:1px solid #A3BAE9;
                padding:5px;
                overflow:hidden;
            }
            .siteChange li{
                width:140px;
                float:left;
                line-height:20px;
            }
            .siteChange li a{
                line-height:20px;
            }
            .sp{
                height:8px;
                font-size:8px;
            }
        </style>
    </body>
</html>
