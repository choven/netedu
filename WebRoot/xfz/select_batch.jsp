<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
	try {
		switch (ActionID) {
		case 2:
			sql = "SELECT id, batch_code,title,status";
			//sql += " ,(select sum(min_xf) from xfz_xf_require_detail where require_id=dbo.xfz_xf_require.id ) as xf ";
			sql += ", CONVERT(varchar(10),created_date,120) AS created_date,created_user ";
			sql += " FROM dbo.xfz_select_batch ";
			sql += " ORDER BY batch_code desc ";
			sb.append(Data.queryJSON(sql, "list", true));
			break;
		case 1:
		if(!login.hasUrlPerm()){
			out.print("没有权限访问此功能");
			return;
			}
		String nYear=StringUtil.showDateTodayFormat("yyyy");
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>西财在线</title>
<%@ include file="../ext-3.3.0.jsp" %>
<script type="text/javascript">
	var win, it1, it2, it3, it4, it5, it6, it7,status,view,select_course_set
	Ext.onReady(function(){
		var tbar = new Ext.Toolbar({
			items: [{
				text: '添加',
				iconCls: 'myicon my_add2',
				handler: add
			}, '-', {
				text: '编辑',
				iconCls: 'myicon my_edit2',
				handler: edit
			}, '->', {
				text: '导出数据',
				iconCls: 'myicon my_excel2',
				handler: function(){
					grid.initExport()
				}
			}]
		});
		var sm = new Ext.grid.CheckboxSelectionModel();
		var cm = new Ext.grid.ColumnModel([new Ext.grid.RowNumberer({
			width: 45
		}), sm, {
			"sortable": true,
			"dataIndex": "batch_code",
			"header": "编码",
			width: 100,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "title",
			"header": "标题",
			renderer:function(v){
				return "<div>"+v+"</div>"
			}
		}, {
			"sortable": true,
			"dataIndex": "status",
			"header": "批次状态",
			renderer:function(v,m,r){
				switch(v){
					case 1 :
						return '准备中'
					break;
					case 2 :
						return '<span class=red>已开放</span>'
					break;
					case 3:
						return '<span class=green>已结束</span>'
					break;
				}
			}
		}, {
			"sortable": true,
			"dataIndex": "status",
			"header": "批次操作",
			renderer:function(v,m,r){
				switch(v){
					case 1 :
						return " <a class='op' href='javascript:status(2,"+r.data.batch_code+")'>【开放选课】</a><a class='op' href=javascript:select_course_set('"+r.data.title+"',"+r.data.batch_code+")>【课程设置】</a>"
					break;
					case 2 :
						return " <a class='op' href='javascript:status(3,"+r.data.batch_code+")'>【结束选课】</a><a class='op' href='javascript:status(2,"+r.data.batch_code+")'>【查看统计】</a>"
					break;
					case 3 :
						return " <a class='op' href='javascript:view("+r.data.batch_code+")'> 【查看统计】</a>"
					break;
				}
			}
		}, {
			"sortable": true,
			"dataIndex": "xf",
			"header": "参选年级",
			width: 100,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "xf",
			"header": "参选课程",
			width: 100,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "created_date",
			"header": "添加时间",
			width: 100,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "created_user",
			"header": "添加人",
			width: 100,
			fixed: true
		}])
		var grid = new netedu.grid({
			tbar: tbar,
			sm:sm,
			cm:cm,
			renderTo: '<%=ModName%>_content',
			border: false
		});
		grid.store.load();
		grid.on('rowdblclick', edit);
		function formIt(){
			var nYear=<%=nYear%>;
			it1 = new netedu.comb({
				store: new Ext.data.SimpleStore({
					fields: ['text', 'value'],
					data: [[nYear+'年', nYear], [1+nYear+'年', 1+nYear]]
				}),
				fieldLabel: '选课年份',
				listeners:{
					select:function(){
						it3.setValue(it1.getValue()+it2.getValue());
						it4.setValue(it1.getRawValue()+it2.getRawValue());
					}
					}
			})
			it2 = new netedu.comb({
				store: new Ext.data.SimpleStore({
					fields: ['text', 'value'],
					data: [['春期', '03'], ['秋期', '09']]
				}),
				fieldLabel: '选课学期',
				listeners:{
					select:function(){
						it3.setValue(it1.getValue()+it2.getValue());
						it4.setValue(it1.getRawValue()+it2.getRawValue());
					}
				}
			})
			it3= new Ext.form.TextField({
				fieldLabel: '批次编码',
				name: 'batch_code',
				allowBlank: false,
				readOnly:true
			});
			it4 = new Ext.form.TextField({
				fieldLabel: '批次标题',
				name: 'title',
				allowBlank: false,
				readOnly:true
			});
			return [it1, it2,it3,it4]
		}
		function ok(){
			if (win) win.close();
			grid.store.reload();
		}
		function add(){
			if (win) win.close();
			win = new netedu.formWin({
				title: '添加数据',
				_it: formIt(),
				_url: '<%=ModName%>_update.jsp?Action=3',
				_id: '',
				_suc: ok
			});
			win.show();
		}
		function edit(){
			var rows = grid.initSeChk(1);
			if (!rows) return false;
			if (win) win.close();
			if(rows[0].data.status!=1){
				alert("该批次已不在准备状态，不允许更改！");
				return;
			}
			pkid = rows[0].get('id');
			win = new netedu.formWin({
				title: '编辑数据',
				width: 400,
				_it: formIt(),
				_url: '<%=ModName%>_update.jsp?Action=4',
				_id: pkid,
				_suc: ok
			});
			win.items.itemAt(0).getForm().loadRecord(rows[0]);
			it1.setValue(rows[0].data.batch_code.substring(0,4));
			it2.setValue(rows[0].data.batch_code.substring(4,6));
			win.show();
		}
		status=function(v,batch_code){
			//检查计划：同步课程到term_course:同步必修课到stu_course:新生如何操作？生成学籍时？学籍异动时?
			
		}
		view=function(batch_code){
			
		}
		select_course_set =function(title,batch_code){
				window.parent.openApp("select_course_set","xfz/select_course_set.jsp?batch_code=" +batch_code,title+'供选课程',false,true)
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
	}
%>