<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
	try {
		switch (ActionID) {
		case 3:
			String theXS = StringUtil.nullValue(request.getParameter("learning_type_code"));
			sql = " SELECT site_code AS value, title AS text ";
			sql += " FROM  [swufe_online].[dbo].[site_info] ";
			sql += " where   is_link=1  and status =1 and learning_type_code='"+theXS+"'  and (site_code LIKE '%" + query + "%' OR title LIKE '%" + query + "%')  ";
			sql += "  order by is_center desc,province_id ";
			
			sb.append(Data.queryJSON(sql, "list", true));
			break;
		case 2:
			sql = "SELECT a.id, a.site_code,a.start_batch_code,a.target_xs,a.remark,a.status";
			sql += ", CONVERT(varchar(10),a.created_date,120) AS created_date,a.created_user ";
			sql += " ,b.title ";
			sql += " FROM dbo.xfz_plan_apply_xs a ";
			sql += " left join [swufe_online].[dbo].[site_info] b on b.site_code=a.site_code ";
			sql += " ORDER BY a.id desc ";
			sb.append(Data.queryJSON(sql, "list", true));
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
				iconCls: 'myicon my_edit',
				handler: edit
			}, '->',{
				text:'禁用',
				iconCls:'myicon my_del',
				handler:function(){
					grid.initDel('id','<%=ModName%>_update.jsp?Action=5',ok)
				}
			},'-', {
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
			"dataIndex": "site_code",
			"header": "站点代码",
			width: 100,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "title",
			"header": "站点名称",
			renderer:function(v){
				return "<div>"+v+"</div>"
			}
		}, {
			"sortable": true,
			"dataIndex": "start_batch_code",
			"header": "开始年级",
			width: 100,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "target_xs",
			"header": "应用形式",
			width: 100,
			fixed: true,
			renderer:function(v){
				return v=="7"?"网络教育":"成人教育";
			}
		}, {
			"sortable": true,
			"dataIndex": "remark",
			"header": "备注"
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
		grid.on('rowdblclick', edit);
		function formIt(){
		it1=new netedu.comb({
			tpl: '<tpl for="."><div class="x-combo-list-item">{[xindex]}、{text}（{value}）</div></tpl>',
			store: new Ext.data.JsonStore({
				url: '<%=ModName%>.jsp?Action=3&learning_type_code=5',
				autoLoad: false
			}),
			fieldLabel: '选择站点',
			name: 'site_code',
			allowBlank: false,
			editable: true,
			mode: 'remote',
			emptyText: '用关键字查询...'
		});
			it2 = new Ext.form.TextField({
				fieldLabel: '开始年级',
				name: 'start_batch_code',
				allowBlank: false
			});
			it3 = new netedu.comb({
				fieldLabel: '应用形式',
				name: 'target_xs',
				//readOnly:true,
				store: new Ext.data.SimpleStore({
					fields: ['text', 'value'],
					data: [['网络教育', '7'], ['成人教育', '5']]
				}),
				value: 7
			});
			it4 = new netedu.comb({
				store: new Ext.data.SimpleStore({
					fields: ['text', 'value'],
					data: [['启用', '1'], ['禁用', '0']]
				}),
				fieldLabel: '是否启用',
				name: 'status',
				value: 1
			
			})
			it5 = new Ext.form.TextArea({
				fieldLabel: '备注',
				name: 'remark'
			});
			return [it1, it2,it3,it4,it5]
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