<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
	try {
		switch (ActionID) {
		case 2:
			sql = "SELECT id, title,remark,status";
			sql += " ,(select sum(min_xf) from xfz_xf_require_detail where require_id=dbo.xfz_xf_require.id ) as xf ";
			sql += ", CONVERT(varchar(10),created_date,120) AS created_date,created_user ";
			sql += " FROM dbo.xfz_xf_require ";
			sql += " ORDER BY id desc ";
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
			items: [{
				text: '添加',
				iconCls: 'myicon my_add2',
				handler: add
			}, '-', {
				text: '编辑',
				iconCls: 'myicon my_edit2',
				handler: edit
			}, '-', {
				text: '设置内容',
				iconCls: 'myicon my_edit',
				handler: set
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
			"dataIndex": "id",
			"header": "编号",
			width: 100,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "title",
			"header": "名称",
			renderer:function(v){
				return "<div>"+v+"</div>"
			}
		}, {
			"sortable": true,
			"dataIndex": "remark",
			"header": "备注"
		}, {
			"sortable": true,
			"dataIndex": "xf",
			"header": "总学分",
			width: 100,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "status",
			"header": "状态",
			width: 100,
			fixed: true,
			renderer:FormatTrueFalse
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
		grid.on('rowdblclick', set);
		function formIt(){
			it1 = new Ext.form.TextField({
				fieldLabel: '名称',
				name: 'title',
				allowBlank: false
			});
			it2 = new netedu.comb({
				store: new Ext.data.SimpleStore({
					fields: ['text', 'value'],
					data: [['启用', '1'], ['禁用', '0']]
				}),
				fieldLabel: '是否启用',
				name: 'status',
				value: 1
			
			})
			it3 = new Ext.form.TextArea({
				fieldLabel: '备注',
				name: 'remark'
			});
			return [it1, it2,it3]
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
			win.items.itemAt(0).getForm().loadRecord(rows[0]);
			win.show();
		}
		function set(){
			var rows=grid.initSeChk(1);
			if (!rows) return false;
			window.parent.openApp("require_detail","xfz/require_detail.jsp?id=" + rows[0].get('id'),rows[0].get('title'),false,true)
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