<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
	try {
		switch (ActionID) {
		case 2:
		sql = "SELECT learning_level_code , title,  max_xq_base,max_xq_xz";
		sql += " FROM dbo.xfz_term_xz ";
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
			items: ['-', {
			text: '刷新',
			iconCls: 'myicon my_refresh',
			handler: function(){
				grid.store.reload();
			}
		},'->', {
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
			"dataIndex": "learning_level_code",
			"header": "代码"
		}, {
			"sortable": true,
			"dataIndex": "title",
			"header": "名称",
			renderer:function(v){
				return "<div>"+v+"</div>"
			}
		}, {
			"sortable": true,
			"dataIndex": "max_xq_base",
			"header": "最长行课学期"
		}, {
			"sortable": true,
			"dataIndex": "max_xq_xz",
			"header": "最长学制学期"
		}])
		var grid = new netedu.grid({
			cm:cm,
			sm:sm,
			tbar: tbar,
			renderTo: '<%=ModName%>_content',
			border: false
		});
		grid.store.load();

		
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