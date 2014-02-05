<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
	try {
		switch (ActionID) {
		case 2:
		sql = "SELECT id , title,  study_score,exam_score";
		sql += " FROM dbo.[xfz_score_policy] ";
			sb.append(Data.queryJSON(sql, "list", true));
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
			"dataIndex": "id",
			"header": "代码"
		}, {
			"sortable": true,
			"dataIndex": "title",
			"header": "形成性成绩比例",
			renderer:function(v){
				return "<div>"+v+"</div>"
			}
		}, {
			"sortable": true,
			"dataIndex": "study_score",
			"header": "形成性成绩系数"
		}, {
			"sortable": true,
			"dataIndex": "exam_score",
			"header": "考核成绩系数"
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