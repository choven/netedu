<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%@ page import="com.swufe.module.xfz"%>
<%
	try {
		switch (ActionID) {
		case 3://罗列在线课程
		String course_code = StringUtil.nullValue(request.getParameter("course_code"));
		sql = " SELECT  c.course_id as value,c.course_name  as text";
		sql += "   FROM [learning_swufe].[dbo].[course] c ";
		sql += "    where  c.course_name like '%"+term_code+"%'  and  c.course_name like '%"+query+"%'";
		sql += "    group by c.course_id,c.course_name ";
		sql += "    order by c.course_name";
			sb.append(Data.queryJSON(sql, "list", true));
		break;
		case 2:
			String keys = StringUtil.nullValue(request.getParameter("key"), "");
			sql = "  SELECT tc.id, tc.term_code,tc.course_code,tc.course_name,tc.learning_course_id ";
			sql += "  ,sc.stu_num ";
			sql += "  ,c.course_name as learning_course_name ";
			sql += "       ,isnull(csc.course_scorm_count,0) as course_scorm_count ";
			sql += "       ,isnull(csc.exercise_count,0) as exercise_count ";
			sql += "  from [swufe_ems].[dbo].xfz_term_course tc ";
			sql += " 	left join  [learning_swufe].[dbo].[course] c on c.course_id=tc.learning_course_id ";

			sql += " 	left join (select sc2.course_code,count(1) as stu_num from swufe_ems.dbo.xfz_stu_course sc2 ";
			sql += " 			inner join  [swufe_online].[dbo].[student_info] si on  si.student_id=sc2.student_id ";
			sql += " 			where sc2.term_code='"+term_code+"'  and si.class_no is not null and isnull(si.learning_status,0)=0 group by sc2.course_code) sc" ;
			sql += "   on sc.course_code=tc.course_code ";
			
			sql += "  left join ";
			sql += "   (select COUNT(1) as course_scorm_count,courseware_id ,sum(case lc.content_type when 'exercise' then 1 else 0 end) as exercise_count from  [learning_swufe].[dbo].[scorm_item_info]  as s1 ";
			sql += " 		inner join [learning_swufe].[dbo].learn_content as lc on s1.item_id =lc.scorm_item_id and lc.parent_id>=0 and lc.content_type<>'scorm_node' ";
			sql += " 			where  status=1 and ISNULL([type],'')<>'' ";
			sql += " 	group by courseware_id) as csc on c.scorm_courseware_id=csc.courseware_id ";
			sql += " where  tc.term_code='"+term_code+"' ";
			if (!"".equals(keys)) {
				sql += " AND (tc.course_code LIKE '%" + keys + "%' OR tc.course_name LIKE '%" + keys + "%' OR c.course_name LIKE '%" + keys + "%' )";
			}
			sql += " order by tc.course_code ";
			sb.append(Data.queryJSON(sql, "list", true));
			//out.print(sql);
			break;
		case 1:
		if(!login.hasPerm("learning_course_set")){
			out.print("没有权限访问此功能");
			return;
		}
		xfz.syncTermCourse(term_code);
		String curr_term=xfz.getCurrTermCode();

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>西财在线</title>
<%@ include file="../ext-3.3.0.jsp" %>
<script type="text/javascript">
	var win, it1, it2, it3, it4, it5, it6, it7,vv=1,link_course;
	var dislink=('<%=term_code%>'<'<%=curr_term%>');
	var is_curr=('<%=term_code%>'=='<%=curr_term%>');
	Ext.onReady(function(){
		var tbar = new Ext.Toolbar({
			items: ['-', {
			text: '刷新',
			iconCls: 'myicon my_refresh',
			handler: function(){
				grid.store.reload();
			}
			},'-', '课程搜索','-',new netedu.search({
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
			}),'-', {
				text: '批量智能链接',
				iconCls: 'myicon my_find',
				handler: auto,
				disabled:dislink
			},'-', {
				text: '批量清空链接',
				iconCls: 'myicon my_del2',
				handler: clear,
				disabled:dislink
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
			"dataIndex": "course_code",
			"header": "课程代码",
			width: 100,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "course_name",
			"header": "课程名称",
			renderer:function(v){
				return "<div>"+v+"</div>"
			}
		}, {
			"sortable": true,
			"dataIndex": "learning_course_name",
			"header": "在线课程",
			renderer:function(v){
				return v==""?"-":"<div>"+v+"</div>"
			}
		}, {
			"sortable": true,
			"dataIndex": "learning_course_id",
			"header": "操作选项",
			renderer:function(v,m,r){
				var html="";
				if(!dislink){
					html+="<a class='op' href=javascript:link_course("+r.data.id+",'"+r.data.course_code+"','"+r.data.course_name+"')>【链接】</a>";
				 }
				 if(v!=""){
				 	html+="<a class='op' target='_blank' href='../enterLearning.jsp?learning_course_id="+v+"&course_name="+encodeURI(r.data.course_name)+"'>【进入】</a>"
				 	}
				return html;
			},
			width: 140,
			fixed: true
		},{
			"sortable": true,
			"dataIndex": "stu_num",
			"header": "选课人数",
			width: 80,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "course_scorm_count",
			"header": "课程节点",
			width: 100,
			fixed: true,
			renderer:FormatNum
		}, {
			"sortable": true,
			"dataIndex": "exercise_count",
			"header": "作业",
			width: 80,
			fixed: true,
			renderer:FormatNum
		}])
		var grid = new netedu.grid({
			tbar: tbar,
			sm:sm,
			cm:cm,
			autoHeight: false,
			height: document.body.clientHeight,
			renderTo: '<%=ModName%>_content',
			border: false
		});
		grid.store.load();
		//grid.on('rowdblclick', edit);
		function FormatNum(v){
			return v==0?"<span class='red b'>"+v+"</span>":v;
		}
		function checkTerm(){
			var ret=true;
			if(dislink){alert("该学期已结束，无法设置在线课程！");ret=false; return}
			if (is_curr&&!confirm("你选中的学期<%=curr_term%>学期为当前学期，更改在线课程会造成学习进度影响！点击确定以继续...")) { ret=false; return }
			return ret;	
		}
		function ok(){
			if (win) win.close();
			grid.store.reload();
		}
		function auto(){
			if(!checkTerm()){
				return;
			}
			fn_btn_ajax('<%=ModName%>_update.jsp?Action=3', 'term_code=<%=term_code%>', ok)		
		}
		function clear(){
			if(!checkTerm()){
				return;
			}
			fn_btn_ajax('<%=ModName%>_update.jsp?Action=5', 'term_code=<%=term_code%>', ok)	
		}
		link_course =function(id,course_code,course_name){
			if(!checkTerm()){
				return;
			}
			if (win) win.close();
			it1= new Ext.form.TextField({
				fieldLabel: '课程代码',
				value:course_code,
				disabled:true
			});
			it2= new Ext.form.TextField({
				fieldLabel: '计划课程',
				value:course_name,
				disabled:true
			});
			it3= new netedu.comb({
				emptyText:'请下拉选择或者输入关键字查询...',
				store:new Ext.data.JsonStore({
					url: '<%=ModName%>.jsp?Action=3&term_code=<%=term_code%>&course_code='+course_code,
					autoLoad: true,
					listeners: {
						'load': function(store, rs){
							if (rs.length == 0) {
								alert("没有检索到相关联的在线课程！注意在添加在线课程时请包含<%=term_code%>字样。")
							}
						}
					}
				}),
						editable: true,
			mode: 'remote',
				fieldLabel:'在线课程',
				name:'learning_course_id',
				allowBlank: false
			})
			win = new netedu.formWin({
				title: '链接在线课程',
				width: 400,
				_it: [it1,it2,it3],
				_url: '<%=ModName%>_update.jsp?Action=4',
				_id: id,
				_suc: ok
			});
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