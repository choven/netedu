<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
	try {
	switch (ActionID) {
		case 2:
			sql = "  SELECT tc.course_code,tc.course_name ";
			sql += "  ,sc.stu_num ";
			sql += "  ,sc.nj_num ";
			sql += "  ,sc.zy_num ";
			sql += "  ,sc.nj_zy_num ";
			sql += "  ,sc.bj_num ";
			sql += "  from [swufe_ems].[dbo].xfz_term_course tc ";
			sql += " 	left join (select sc2.course_code,count(1) as stu_num,count(distinct si.batch_code) as nj_num ";
			sql += " 	         ,count(distinct si.major_code) as zy_num  ";
			sql += " 	         ,count(distinct si.zy_id) as nj_zy_num  ";
			sql += " 	         ,count(distinct si.bj_code) as bj_num  ";
			sql += " 	        from swufe_ems.dbo.xfz_stu_course sc2 ";
			sql += " 			inner join  [swufe_online].[dbo].[student_info] si on  si.student_id=sc2.student_id ";
			sql += " 			where sc2.term_code='"+term_code+"'  and si.class_no is not null and isnull(si.learning_status,0)=0 group by sc2.course_code) sc" ;
			sql += "   on sc.course_code=tc.course_code ";
			sql += "   where tc.term_code='"+term_code+"' ";
			if (!"".equals(key)) {
				sql += " AND (tc.course_code LIKE '%" + key + "%' OR  tc.course_name LIKE '%" + key + "%')";
			}
			out.print(Data.queryJSON(sql, "order by  course_code ", request));
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
			"dataIndex": "course_code",
			"header": "课程代码",
			width: 100,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "course_name",
			"header": "课程名称"
		}, {
			"sortable": true,
			"dataIndex": "stu_num",
			"header": "选课人数",
			width: 100,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "nj_num",
			"header": "选课年级数",
			width: 80,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "zy_num",
			"header": "专业数",
			width: 80,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "nj_zy_num",
			"header": "年级专业",
			width: 80,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "bj_num",
			"header": "选课站点",
			width: 80,
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