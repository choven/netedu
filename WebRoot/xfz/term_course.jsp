<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%@ page import="com.swufe.module.xfz"%>
<%
	try {
		switch (ActionID) {
		case 3:
			sql = "   	SELECT rm.batch_code,ti.xq ";
			sql += " 	,'【'+left(rm.batch_code,4)+case RIGHT(rm.batch_code,1)  when '9' then '秋' else'春' end+'】'+case rm.learning_level_code when '1' then '高起本' when '2' then '专升本'else'专科' end as nj ";
			sql += " 	from swufe_online.dbo.recruit_major rm ";
			sql += " 	inner join [swufe_ems].[dbo].[xfz_term_info]  ti on  ti.batch_code=rm.batch_code and ti.learning_type_code=rm.learning_type_code ";
			sql += " 	inner join  [swufe_ems].[dbo].[xfz_term_xz] xz on xz.learning_level_code=rm.learning_level_code ";
			sql += " 	where ti.xq<=xz.max_xq_base  and ti.term_code='"+term_code+"'";
			sql += " 	group by rm.batch_code,rm.learning_level_code,ti.xq ";
			sql += "    order by rm.batch_code desc, rm.learning_level_code ";
			rs = Data.executeQuery(sql);
			out.print("<div class='stat' style='width:100%;'> \n");
			out.print("<table width=\"100%\" border=\"1\" id=\"t\">\n");
			out.print("<tr>\n");
			out.print("<th width='100' nowrap>年级</th>\n");
			out.print("<th width='80' nowrap >学期</th>\n");
			out.print("<th class='thL'>层次</th>\n");
			out.print("</tr>\n");
			i = 0;
			while (rs.next()) {
				out.print("<tr>\n");
				out.print("<td>" + rs.getString("batch_code") +"</td>\n");
				out.print("<td>" +rs.getString("xq") + "</td>\n");
				out.print("<td class='tdL'>" + rs.getString("nj") + "</td>\n");
				out.print("</tr>\n");
			}
			out.print("</table>\n");
			out.print("</div>\n");
			out.print(sb.toString());
		
		break;
		case 2:
		String show_stu = StringUtil.nullValue(request.getParameter("show_stu"), "0");
		sql = " SELECT sb.[batch_code] ";
		sql += "       ,sb.[title] ";
		sql += "       ,tc.course_num ";
		sql += "       ,ti.batch_num ";
		if("1".equals(show_stu)){ 
			sql += "      ,stu_num ";
		}
		sql += "   FROM [swufe_ems].[dbo].[xfz_select_batch] sb ";
		sql += "   left join ( ";
		sql += "   select term_code ,COUNT(1) as course_num from [swufe_ems].[dbo].[xfz_term_course] group by term_code) tc ";
		sql += "   on tc.term_code=sb.batch_code ";
		sql += "   left join ";
		sql += "   (SELECT  term_code,COUNT(distinct(batch_code)) as batch_num  FROM [swufe_ems].[dbo].[xfz_term_info] group by term_code) ti";
		sql += "   on sb.batch_code=ti.term_code ";
		if("1".equals(show_stu)){ 
			sql += "   left join ";
			sql += "   (select term_code,count(distinct student_id) as stu_num from [swufe_ems].[dbo].xfz_stu_course group by term_code) sc ";
			sql += "   on sc.term_code=sb.batch_code ";
			}
		sql += "   where sb.status>=3 order by sb.batch_code desc ";
			sb.append(Data.queryJSON(sql, "list", true));
			break;
		case 1:
			/* 通用权限不用限制。
		if(!login.hasUrlPerm()){
			out.print("没有权限访问此功能");
			return;
			}
			*/
		String curr_term=xfz.getCurrTermCode();
		boolean learning_course_set=login.hasPerm("learning_course_set");
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>西财在线</title>
<%@ include file="../ext-3.3.0.jsp" %>
<script language="javascript" type="text/javascript" src="/file/jquery/jquery-1.4.2.min.js"></script>
<script language="javascript" type="text/javascript" src="/file/jquery/jquery.mergetable.js"></script>
<script type="text/javascript">
	var win,viewNJ,viewKC,linkKC,vv=0,curr_term='<%=curr_term%>'
	Ext.onReady(function(){
		var tbar = new Ext.Toolbar({
			items: ['-', {
			text: '刷新',
			iconCls: 'myicon my_refresh',
			handler: function(){
				grid.store.reload();
			}
		},'-', {
				text: '统计选课人数',
				iconCls: 'myicon my_unchecked',
				handler: function(){
					vv=vv^1;
					if(vv==1){
						this.setIconClass("myicon my_checked");
						grid.store.setBaseParam('show_stu', 1);
						grid.store.load();
						
					}else{
						this.setIconClass("myicon my_unchecked")
						grid.store.setBaseParam('show_stu', '');
						grid.store.load();
					}
				}
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
			"header": "编码"
		}, {
			"sortable": true,
			"dataIndex": "title",
			"header": "学期",
			renderer:function(v,m,r){
				return "<div>"+v+(r.data.batch_code==curr_term?"<span class='red'>（当前学期）</span>":"")+"</div>"
			}
		}, {
			"sortable": true,
			"dataIndex": "course_num",
			"header": "开设课程",
			renderer:function(v,m,r){
				return "<div>"+v+"门<a class='op' href='javascript:viewKC("+r.data.batch_code+")'>【详情】</a></div>";
			}
		}, {
			"sortable": true,
			"dataIndex": "batch_code",
			"header": "操作选项",
			renderer:function(v){
				var html="";
				<%if(learning_course_set){%>
				html+="<a class='op' href='javascript:linkKC("+v+")'>【在线课程】</a>";
				<%}%>
				return html;
			}
		}, {
			"sortable": true,
			"dataIndex": "batch_num",
			"header": "行课年级",
			renderer:function(v,m,r){
				return "<div>"+v+"个<a class='op' href='javascript:viewNJ("+r.data.batch_code+")'>【详情】</a></div>"
			}
		}, {
			"sortable": true,
			"dataIndex": "stu_num",
			"header": "行课学生"
		}])
		var grid = new netedu.grid({
			tbar: tbar,
			sm:sm,
			cm:cm,
			renderTo: '<%=ModName%>_content',
			border: false
		});
		grid.store.load();
		
		function ok(){
			if (win) win.close();
			grid.store.reload();
		}
		
		viewNJ=function(term_code){
		if (win) win.close();
		win = new Ext.Window({
			x: 50,
			y: 10,
			closeAction: 'close',
			layout: 'fit',
			title: term_code+'学期行课年级',
			width: 400,
			autoScroll: true,
			autoLoad: {url:'<%=ModName%>.jsp?Action=3&term_code=' + term_code,callback:function(){_w_table_rowspan('#t', 1);_w_table_rowspan('#t', 2);}},
			border: true,
			frame: true,
			bodyStyle: 'padding:5px;',
			plain: true,
			buttonAlign: 'center',
			buttons: [{
				text: '关闭窗口',
				handler: function(){
					win.close()
					}
				}]
		})
		win.show();
			
		}
		viewKC =function(term_code){//专门做统计
				window.parent.openApp("term_course_detail","xfz/term_course_detail.jsp?term_code=" +term_code,term_code+'学期课程',false,true)
		}
		linkKC=function(term_code){//设置在线课程
				window.parent.openApp("learning_course_link","edu/learning_course_link.jsp?term_code=" +term_code,term_code+'学期课程链接',false,true)
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