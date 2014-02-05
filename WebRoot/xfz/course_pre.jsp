<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
	try {
		switch (ActionID) {
		case 2:
		String keys = StringUtil.nullValue(request.getParameter("key"), "");
		sql = "SELECT pre.id, pre.course_code,c1.title as course_name , pre.pre_course_code,c2.title as pre_course_name ,pre.created_user  from xfz_course_pre  pre";
		sql += " inner join  xfz_course_info as c1 on c1.code=pre.course_code";
		sql += " inner join  xfz_course_info as c2 on c2.code=pre.pre_course_code";
		if (!"".equals(keys)) {
				sql += " AND (c1.code LIKE '%" + keys + "%' OR c1.title LIKE '%" + keys + "%' OR c1.py LIKE '%" + keys + "%')";
		}
		sql += " ORDER BY pre.id desc ";
		//out.print(sql);
		sb.append(Data.queryJSON(sql, "list", true));
			break;
		case 1:
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>用户类型管理</title>
<%@ include file="../ext-3.3.0.jsp" %>
<script type="text/javascript">
	var win, it1, it2, it3, it4, it5, it6, it7
	Ext.onReady(function(){
		var tbar = new Ext.Toolbar({
			items: ['-', '课程搜索','-',new netedu.search({
				emptyText:'输入关键字查询...',
				_t1Click:function(){
					//
					grid.store.setBaseParam('key', "");
					grid.store.load();
				},
				_t2Click:function(){
					grid.store.setBaseParam('key', this.getValue());
					grid.store.load();
				}
			}),{
				text: '添加',
				iconCls: 'myicon my_add2',
				handler: add
			}, '-', {
				text: '编辑',
				iconCls: 'myicon my_edit',
				handler: edit
			},'->','-',{
				text:'删除',
				iconCls:'myicon my_del',
				handler:function(){
					grid.initDel('id','<%=ModName%>_update.jsp?Action=5',ok)
				}
			},'-',{
				text:'导出数据',
				iconCls:'myicon my_excel2',
				handler:function(){
					grid.initExport()
				}
			}]
		});
		var sm = new Ext.grid.CheckboxSelectionModel();
		var cm = new Ext.grid.ColumnModel([new Ext.grid.RowNumberer({
			width: 45
		}), sm, {
			"sortable": true,
			"dataIndex": "course_code",
			"header": "课程代码"
		}, {
			"sortable": true,
			"dataIndex": "course_name",
			"header": "课程名称"
		},{
			"sortable": true,
			"dataIndex": "pre_course_code",
			"header": "先行课程代码"
		}, {
			"sortable": true,
			"dataIndex": "pre_course_name",
			"header": "先行课程名称"
		}, {
			"sortable": true,
			"dataIndex": "created_user",
			"header": "添加人",
			width: 100,
			fixed: true
		}])
		var grid = new netedu.grid({
			cm:cm,
			sm:sm,
			tbar: tbar,
			renderTo: '<%=ModName%>_content',
			border: false
		});
		grid.store.load();
		grid.on('rowdblclick', edit);
		function formIt(){
			it1=new netedu.comb({
				tpl: '<tpl for="."><div class="x-combo-list-item">{[xindex]}、{text}（{value}）</div></tpl>',
				store: new Ext.data.JsonStore({
					url: 'plan_edit.jsp?Action=4',
					autoLoad: false
				}),
				fieldLabel: '选择课程',
				name: 'course_code',
				allowBlank: false,
				editable: true,
				pageSize: 10,
				mode: 'remote',
				emptyText: '用关键字查询...'
			});
			it2=new netedu.comb({
				tpl: '<tpl for="."><div class="x-combo-list-item">{[xindex]}、{text}（{value}）</div></tpl>',
				store: new Ext.data.JsonStore({
					url: 'plan_edit.jsp?Action=4',
					autoLoad: false
				}),
				fieldLabel: '先行课程',
				name: 'pre_course_code',
				allowBlank: false,
				editable: true,
				pageSize: 10,
				mode: 'remote',
				emptyText: '用关键字查询...'
			});
			return [it1, it2]
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
			pkid = rows[0].get('id');
			win = new netedu.formWin({
				title: '编辑数据',
				width: 400,
				_it: formIt(),
				_url: '<%=ModName%>_update.jsp?Action=4',
				_id: pkid,
				_suc: ok
			});
			win.show();
			win.items.itemAt(0).getForm().loadRecord(rows[0]);
			it1.setRawValue(rows[0].data.course_name);
			it2.setRawValue(rows[0].data.pre_course_name);
			
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