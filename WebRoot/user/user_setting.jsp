<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
try {
switch (ActionID) {
case 2:
break;
case 1:
//sb.append(sql); %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" " http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns=" http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>用户管理</title>
<%@ include file="../ext-3.3.0.jsp" %>
<script type="text/javascript">
	var win, it1, it2, it3, it4, it5, it6, it7
	Ext.onReady(function(){
		var pageHeight = document.body.clientHeight;
		//var user_set = Ext.decode(Ext.util.Cookies.get("user_setting"), true);//netedu3.js加载顺序问题，其中改写的cookie类没有生效？？？
		var temp='<%=login.getCookie("user_setting")%>';
		temp = (temp=='') ? null : temp;
		var user_set = Ext.decode(temp, true);
		var Employee = Ext.data.Record.create([{
			name: 'defaultCls'
		}, {
			name: 'isShowAssi'
		}, {
			name: 'isVoiceTip'
		}, {
			name: 'maxTab'
		}]);
		var re = new Employee(user_set);
		function formIt(){
			it1 = new netedu.comb({
				width: 300,
				tpl: '<tpl for="."><div class="x-combo-list-item">{[xindex]}、{name}</div></tpl>',
				fieldLabel: '左侧默认展开栏目',
				name: 'defaultCls',
				valueField: 'id',
				displayField: 'name',
				store: new Ext.data.JsonStore({
					url: '../dataUtil.jsp?Action=7',
					autoLoad: true,
					listeners: {
						'load': function(){
							it1.setValue(re.get("defaultCls"))
						}
					}
				}),
				allowBlank: true,
				emptyText: '选择一个栏目作为登录系统后默认展开的栏目...'
			})
			
			it2 = new Ext.form.NumberField({
				width: 300,
				allowDecimals: false, //小数
				allowNegative: false, //负数
				fieldLabel: '最多并行模块数量',
				emptyText: '中间面板的最大数，设置为0时所有页面跳出框架',
				name: 'maxTab'
			});
			it3 = new Ext.form.Checkbox({
				fieldLabel: '默认打开系统助手',
				boxLabel: '登录系统后自动打开系统助手',
				inputValue: 1,
				name: 'isShowAssi'
			});
			it4 = new Ext.form.Checkbox({
				fieldLabel: '关闭消息语音提示',
				name: 'isVoiceTip',
				boxLabel: '关闭未读站内消息的语音提示',
				inputValue: 1
			});
			it5 = new Ext.form.Checkbox({
				fieldLabel: '异地登陆手机预警',
				name: 'isSmsExceLogin',
				boxLabel: '如有其他城市的IP使用我的帐户登陆给发送预警短信到我绑定手机',
				disabled: true,
				inputValue: 1
			});
			return [it1, it3, it4, it5, it2]
		}
		var f = new Ext.FormPanel({
			title: '个人化设置 （请打开系统助手查看设置说明）',
			//tbar: tbar,
			labelWidth: 120,
			anchor: '98%',
			labelAlign: "right",
			labelSeparator: '：',
			labelPad: 0,
			frame: false,
			border: false,
			bodyStyle: 'padding:5px',
			autoHeight: true,
			buttonAlign: 'left',
			renderTo: '<%=ModName%>_content',
			items: formIt(),
			buttons: [{
				style: {
					marginLeft: '100px',
					marginRight: '20px'
				},
				text: '提 交',
				handler: function(){
					var f = this.ownerCt.ownerCt;
					var s = f.getForm().getValues(true) //得到URL形式字符串
					s = Ext.urlDecode(s);//将URL形式字符串转换为json
					//
					//if(!Ext.isNumber(s.maxTab)){
					if (-9 == Ext.num(s.maxTab, -9)) {
						s.maxTab = ''
					}
					s = Ext.encode(s)//将json转换为字符串
					fn_btn_ajax('<%=ModName%>_update.jsp?Action=3', 'setting=' + s, function(){
						alert("设置成功，你下次登录该设置有效，或者请点页面最上方的刷新缓存按钮。")
					});
					return;
				}
			}, {
				text: '清 除',
				id: 'f_reset',
				handler: function(){
					this.ownerCt.ownerCt.getForm().reset();
				}
			}],
			listeners: {
				'afterrender': function(){
				
					this.getForm().loadRecord(re)
				}
			}
		})
		
	});
</script>
</head>
<body>
<div id='<%=ModName%>_content' class='my_grid'></div>
<div id='win'></div>
</body>
</html>
<%break;
}
} catch (Exception e) {
out.print(e.toString());
} finally {
Data.close();
out.print(sb.toString());
} %>