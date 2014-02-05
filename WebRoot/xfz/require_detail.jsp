<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
	try {
		switch (ActionID) {
		case 3:
			sql = "SELECT code as value, title AS text ,status";
			sql += " FROM dbo.xfz_course_type ";
			sql += " ORDER BY status desc, code desc ";
			sb.append(Data.queryJSON(sql, "list", true));
			break;
		case 2:
			sql = " SELECT a.[id] ";
			sql += "       ,a.[require_id],a.is_optional ";
			sql += "       ,a.[course_type_code] ";
			sql += "       ,b.title as course_type_name ";
			sql += "       ,[min_xf] ";
			sql += "       ,a.[created_user] ";
			sql += "       ,convert(varchar(10),a.created_date,120) as created_date";
			sql += "   FROM [swufe_ems].[dbo].[xfz_xf_require_detail] as a ";
			sql += "   inner join  [swufe_ems].[dbo].[xfz_course_type]  as b on a.[course_type_code]=b.code ";
			sql += "        where a.require_id='"+id+"'";
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
		var typeStore=new Ext.data.JsonStore({
				url: '<%=ModName%>.jsp?Action=3',
				autoLoad: true
			})
		var tbar = new Ext.Toolbar({
			items: [{
				text: '添加',
				iconCls: 'myicon my_add2',
				handler: add
			}, '-', {
				text: '编辑',
				iconCls: 'myicon my_edit2',
				handler: edit
			}, '->',{
				text:'删除',
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
			"dataIndex": "course_type_code",
			"header": "课程类型代码"
		}, {
			"sortable": true,
			"dataIndex": "course_type_name",
			"header": "课程类型"
		}, {
			"sortable": true,
			"dataIndex": "is_optional",
			"header": "是否选修",
			renderer:function(v){
				return v==1?"<span class=green>选修<span/>":"<span class=red>必修<span/>"
			}
		
		}, {
			"sortable": true,
			"dataIndex": "min_xf",
			"header": "最低学分要求"
		
		}, {
			"sortable": true,
			"dataIndex": "created_date",
			"header": "添加时间"
		}, {
			"sortable": true,
			"dataIndex": "created_user",
			"header": "添加人"
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
			it1 =new netedu.comb({
				tpl: '<tpl for="."><div class="x-combo-list-item <tpl if="status!=1"> gray</tpl>">{[xindex]}、{text}({value})</div></tpl>',
				store: typeStore,
				allowBlank: false,
				fieldLabel: '课程类型',
				name: 'course_type_code'
			})
			it2 = new Ext.form.NumberField({
				fieldLabel: '最低学分',
				name: 'min_xf',
				allowBlank: false,
				allowDecimals: true,//
				allowNegative: false
			});
			it3 = new netedu.comb({
				store: new Ext.data.SimpleStore({
					fields: ['text', 'value'],
					data: [['选修', '1'], ['必修', '0']]
				}),
				fieldLabel: '是否选修',
				name: 'is_optional',
				value: 0
			
			})
			
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
				_url: '<%=ModName%>_update.jsp?Action=3&require_id=<%=id%>',
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