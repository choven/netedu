<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
	try {
	switch (ActionID) {
		case 2:
			sql = " SELECT l.[id] ";
			sql += " 	  ,l.plan_id ";
			sql += " 	  ,p.title as plan_title ";
			sql += "       ,l.[title] ";
			sql += "       ,l.[sql] ";
			sql += "       ,ui.name ";
			sql += "       ,convert(varchar(16),l.op_date,120) as op_date ";
			sql += "   FROM [swufe_ems].[dbo].[xfz_plan_log] l ";
			sql += "   left join swufe_ems.dbo.user_info ui on ui.uid=l.op_user ";
			sql += "   left join swufe_ems.dbo.[xfz_plan_info] p on p.id=l.plan_id ";
			sql += "    where 1=1 ";
			if (!"".equals(key)) {
				sql += " AND (ui.name LIKE '%" + key + "%' OR l.title like '%" + key + "%' OR l.op_user like'%" + key + "%')";
			}
			
		out.print(Data.queryJSON(sql, "order by  id  desc", request));
			break;
		case 1:
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>西财在线</title>
<%@ include file="../ext-3.3.0.jsp" %>
<script type="text/javascript">
	var win, it1, it2, it3, it4, it5, it6, it7
	Ext.onReady(function(){
		var pageHeight=document.body.clientHeight;
		
		var tbar=new Ext.Toolbar({
			items: [ '-', {
			text: '刷新',
			iconCls: 'myicon my_refresh',
			handler: function(){
				grid.store.reload();
			}
		},'-', '搜索','-',new netedu.search({
				width:200,
				emptyText:'输入姓名、类型关键字查询...',
				_t1Click:function(){
					//
					grid.store.setBaseParam('key', "");
					grid.store.load();
				},
				_t2Click:function(){
					grid.store.setBaseParam('key', this.getValue());
					grid.store.load();
				}
			}),'->',{
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
			"dataIndex": "id",
			"header": "编号",
			width: 100,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "plan_id",
			"header": "计划编号",
			width: 100,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "title",
			"header": "操作类型",
			width: 100,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "plan_title",
			"header": "计划名称"
		}, {
			"sortable": true,
			"dataIndex": "name",
			"header": "操作用户",
			width: 100,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "op_date",
			"header": "操作时间",
			width: 120,
			fixed: true
		}])
		var grid=new netedu.grid({
			tbar:tbar,
			cm:cm,
			sm:sm,
			renderTo:'<%=ModName%>_content',
			border:false,
			autoHeight:false,
			height:pageHeight,
			_pageSize:Math.floor((pageHeight - 20) / 23)
		});
		grid.store.load();
		grid.on('rowdblclick', view);
		function view(){
			if (win) win.close();
			var rows = grid.initSeChk(1);
			if (!rows) return false;
			win = new netedu.win({
				title: '查看日志',
				html:"<div style='background:#fff;padding:10px;'>"+rows[0].data.sql+"</div>"
				
			})
		win.show();

		}
		
	});
</script>
<style type="text/css">
#l div{padding-top:5px;}
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
		out.print(sb.toString());
	}
%>