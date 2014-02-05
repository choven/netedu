<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
	try {
		switch (ActionID) {
		case 3://罗列在线课程
		String course_code = StringUtil.nullValue(request.getParameter("course_code"));
		String is_auto = StringUtil.nullValue(request.getParameter("is_auto"));
		sql = " SELECT  c.course_id as value,c.course_name  as text";
		sql += "   FROM [learning_swufe].[dbo].[course] c ";
		sql += "   left join [swufe_ems].[dbo].[xfz_term_course] tc on tc.learning_course_id is not null   and c.global_id like '%[_]'+tc.learning_course_id+'' ";
		sql += "    where  c.course_name like '%"+term_code+"%'  and  c.course_name like '%"+query+"%'";
		if("1".equals(is_auto)){
			sql += "    and  tc.course_code='"+course_code+"' ";
		}
		sql += "    group by c.course_id,c.course_name ";
		sql += "    order by course_id desc ";
			sb.append(Data.queryJSON(sql, "list", true));
		break;
		case 2:
			String keys = StringUtil.nullValue(request.getParameter("key"), "");
			sql = " with t as ( ";
			sql += " SELECT ";
			sql += " pd.course_code ";
			sql += " ,max(xf.is_optional) as is_optional ";
			sql += " ,count( distinct xf.is_optional) as optional_type ";
			sql += " ,min(pd.exam_type) as exam_type ";
			sql += " from swufe_online.dbo.recruit_major rm ";
			sql += " inner join [swufe_ems].[dbo].[xfz_term_info]  ti on  ti.term_code='"+term_code+"' and ti.batch_code=rm.batch_code and ti.learning_type_code=rm.learning_type_code ";
			sql += " inner join  swufe_ems.dbo.xfz_plan_apply  pa on pa.recruit_major_id=rm.recruit_major_id and apply_level=3 ";
			sql += " inner join swufe_ems.dbo.xfz_plan_detail pd on pd.plan_id=pa.plan_id and  (pd.xq=ti.xq or(pd.xq=0 and ti.xq>1) ) and is_open=1 ";
			sql += " inner join swufe_ems.dbo.xfz_xf_require_detail xf on xf.course_type_code=pd.course_type_code ";
			sql += " group by pd.course_code ";
			sql += " ) ";
			sql += " SELECT tc.id, tc.term_code,tc.course_code,tc.course_name,tc.learning_course_id,t.is_optional,t.optional_type,t.exam_type,sc.stu_num ";
			sql += " ,case when t.is_optional=0 then '单一必修' else (case when t.optional_type=1 then '单一选修' else '选修及必修' end ) end as optional_type_title  ";
			sql += " from [swufe_ems].[dbo].xfz_term_course tc ";
			sql += " inner join t on t.course_code=tc.course_code and tc.term_code='"+term_code+"' ";
			sql += " left join (select course_code,count(1) as stu_num from swufe_ems.dbo.xfz_stu_course  where term_code='"+term_code+"' group by course_code) sc on sc.course_code=tc.course_code ";
			sql += " inner join  swufe_ems.dbo.xfz_course_info c on c.code=tc.course_code";
			sql += " where 1=1 ";
			if (!"".equals(keys)) {
				sql += " AND (tc.course_code LIKE '%" + keys + "%' OR tc.course_name LIKE '%" + keys + "%' OR c.title LIKE '%" + keys + "%' OR c.py LIKE '%" + keys + "%' )";
			}
			sb.append(Data.queryJSON(sql, "list", true));
			break;
		case 1:
		if(!login.hasPerm("learning_course_set")){
			out.print("没有权限访问此功能");
			return;
			}
		String curr_term = Data.queryScalar("SELECT  MAX(term_code)FROM [swufe_ems].[dbo].[xfz_term_info]  where is_curr =1 and is_max=0");  

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>西财在线</title>
<%@ include file="../ext-3.3.0.jsp" %>
<script type="text/javascript">
	var win, it1, it2, it3, it4, it5, it6, it7,vv=1,link_course;
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
			}),'-', {
				text: '按选修类型分组',
				iconCls: 'myicon my_checked',
				handler: function(){
					vv=vv^1;
					if(vv==1){
						this.setIconClass("myicon my_checked");
						grid.store.groupBy('optional_type_title',true);
						
					}else{
						this.setIconClass("myicon my_unchecked")
						grid.store.clearGrouping();
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
			"dataIndex": "learning_course_id",
			"header": "在线课程管理",
			renderer:function(v,m,r){
				var html="<a class='op' href=javascript:link_course("+r.data.id+",'"+r.data.course_code+"','"+r.data.course_name+"')>【请链接】</a>";
				 if(v!=""){
				 	html+="<a class='op' target='_blank' href='../enterLearning.jsp?learning_course_id="+v+"&course_name="+encodeURI(r.data.course_name)+"'>【进入】</a>"
				 	}
				return html;
			},
			width: 200,
			fixed: true
		},{
			"sortable": true,
			"dataIndex": "stu_num",
			"header": "选课人数",
			width: 80,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "optional_type_title",
			"header": "选课类型",
			width: 100,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "exam_type",
			"header": "是否考试",
			width: 80,
			fixed: true,
			renderer:FormatYesNo//这里取的exam_type的最小值，
		}])
		var grid = new netedu.grid({
			tbar: tbar,
			store: new Ext.data.GroupingStore({
				url: '<%=ModName%>.jsp?Action=2&term_code=<%=term_code%>',
				reader: new Ext.data.JsonReader(),
				autoLoad: false,
				groupField: 'optional_type_title'
				}),
			_groupTpl: '{text} (共有{[values.rs.length]} {["门课程"]})',
			sm:sm,
			cm:cm,
			autoHeight: false,
			height: document.body.clientHeight,
			renderTo: '<%=ModName%>_content',
			border: false
		});
		grid.store.load();
		//grid.on('rowdblclick', edit);
		
		function ok(){
			if (win) win.close();
			grid.store.reload();
		}
		link_course =function(id,course_code,course_name){
			if (win) win.close();
			it1= new Ext.form.TextField({
				fieldLabel: '课程代码',
				name: 'course_code',
				allowBlank: false,
				value:course_code,
				readOnly:true
			});
			it2= new Ext.form.TextField({
				fieldLabel: '计划课程',
				name: 'course_name',
				value:course_name,
				allowBlank: false,
				readOnly:true
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
			it4= new Ext.form.Checkbox({
				fieldLabel: '自动关联',
				name: 'is_auto',
				boxLabel: '自动关联复制的在线课程',
				inputValue: 1,
				listeners:{
					'check':function(c,checked){
						it3.store.setBaseParam('is_auto',checked?1:0);
						it3.store.load({
							callback:function(rs){
								if(checked&&rs.length>0){
									it3.setValue(rs[0].data.value);
								}
							}
						});
					}
				}
			});
			win = new netedu.formWin({
				title: '链接在线课程',
				width: 400,
				_it: [it1,it2,it3,it4],
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