<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
	String keys = StringUtil.nullValue(request.getParameter("key"), "");
	String recruit_site_id = StringUtil.nullValue(request.getParameter("recruit_site_id"), "");
	String recruit_major_id = StringUtil.nullValue(request.getParameter("recruit_major_id"), "");
	try {
		switch (ActionID) {
		case 3:
			sql = " SELECT c.class_no as value ";
			sql += " ,'【'+case rm.learning_type_code when '7' then '网教' else'成教' end+left(rm.batch_code,4)+case RIGHT(rm.batch_code,1)  when '9' then '秋' else'春' end+'】【'+case LEFT(rm.major_code,1) when '1' then '高起本' when '2' then '专升本'else'专科' end +'】'+rm.title+rm.major_direction+c.class_name as text ";
			sql += "   FROM [swufe_online].[dbo].[class_info] as c ";
			sql += "   inner join  [swufe_online].[dbo].recruit_major as rm on rm.recruit_major_id=c.recruit_major_id ";
			sql += "    where  c.recruit_major_id='"+recruit_major_id+"' and c.recruit_site_id='"+recruit_site_id+"' ";
			sql += "     ";
			sb.append(Data.queryJSON(sql, "list", true));
			break;
		case 2:
			sql = " SELECT p.id  as plan_id,ci.class_name,ci.class_no,ci.batch_code";
			sql += "       ,p.title ";
			sql += "       ,p.is_pub,pd.max_xq ,pd.kc,pd.xf,pa.is_system ";
			sql += "       ,xf.min_xf,ti.xq, left(pa.major_code,1) as learning_level_code ";
			sql += "   FROM swufe_ems.dbo.xfz_plan_info as p ";
			sql += "  inner join  [swufe_ems].[dbo].[xfz_plan_apply] as pa on pa.apply_level=5 and  pa.plan_id=p.id ";
			sql += "  inner join  [swufe_online].[dbo].[class_info] as ci on ci.class_no=pa.class_no ";
			sql += "   left join (SELECT  MAX(xq) as max_xq,count(1) as kc,sum(xf) as xf, plan_id ";
			sql += " 			 FROM swufe_ems.dbo.xfz_plan_detail where is_open=1 group by plan_id  ) as pd on pa.plan_id=pd.plan_id ";
			sql += "  left join (SELECT  require_id,count(1) as kclx,sum(min_xf) as min_xf ";
			sql += " 		    FROM swufe_ems.dbo.xfz_xf_require_detail group by require_id ) as xf on xf.require_id=p.xf_require_id  ";
			sql += "   left join [swufe_ems].[dbo].xfz_term_info  ti on ti.batch_code=ci.batch_code and  ti.learning_type_code=ci.learning_type_code and ti.is_curr=1 ";
			sql += " WHERE 1=1 ";
			if (!"".equals(keys)) {
				sql += " AND  p.title like '%"+keys+"%' ";
			}
			out.print(Data.queryJSON(sql, "order by  batch_code desc,class_no desc", request));
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
<title>教学计划</title>
<%@ include file="../ext-3.3.0.jsp" %>
<script type="text/javascript">
	var win, it1, it2, it3, it4, it5, it6, it7,edit,del;
	Ext.onReady(function(){
		var pageHeight = document.body.clientHeight;
		var majorStore = new Ext.data.JsonStore({
			url: '<%=ModName%>.jsp?Action=3',
			autoLoad: true
		})
		var tbar = new Ext.Toolbar({
			items: ['-', '搜索：','-',new netedu.search({
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
			}), '-', {
				text: '添加自主教学计划',
				iconCls: 'myicon my_add2',
				handler: add
			}, '-', {
			text: '批量校验',
			iconCls: 'myicon my_ok2',
			handler: validatePlan
		},'-', {
			text: '批量打印',
			iconCls: 'myicon my_print',
			handler: print
		}]
		});
		var sm = new Ext.grid.CheckboxSelectionModel();
		var cm = new Ext.grid.ColumnModel([new Ext.grid.RowNumberer({
			width: 20
		}), sm, {
			"sortable": true,
			"dataIndex": "class_no",
			"header": "班号",
			width: 120,
			fixed: true,
			hidden:true
		}, {
			"sortable": true,
			"dataIndex": "class_name",
			"header": "使用班级",
			width: 120,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "title",
			"header": "所使用的计划名称"
		}, {
			"sortable": true,
			"dataIndex": "is_system",
			"header": "系统分配",
			width: 60,
			fixed: true,
			renderer: FormatYesNo
		}, {
			"sortable": true,
			"dataIndex": "plan_id",
			"header": "计划管理",
			renderer: function(v, m, r){
				var html="";
				if (r.data.is_pub == 0&&r.data.is_system==0 ) {
					html+="<a class='op' href='javascript:del("+v+")'>【清除】</a>";
				}
				var maxxq=(r.data.learning_level_code==1?8:4)//排除毕业环节，高起本8学期，专升本4学期；
				if(r.data.xq<maxxq&&r.data.is_system==0){//已经开完所有课程的专业，锁定计划不允许编辑。
					html+="<a class='op' href='javascript:edit("+v+",5)'>【调整】</a>";
				}
				html += "<a class='op' href='plan_view.jsp?id=" + v + "' target='_blank'>【查看】</a>";
				return html;
			}
		}, {
			"sortable": true,
			"dataIndex": "kc",
			"header": "供选课程",
			width: 60,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "xf",
			"header": "供选学分",
			width: 60,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "min_xf",
			"header": "要求学分",
			width: 60,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "max_xq",
			width: 60,
			fixed: true,
			"header": "最大学期"
		}, {
			"sortable": true,
			"dataIndex": "xq",
			"header": "当前学期",
			width: 60,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "is_pub",
			"header": "是否发布",
			width: 60,
			fixed: true,
			renderer: FormatYesNo
		}])
		var grid = new netedu.grid({
			tbar: tbar,
			renderTo: '<%=ModName%>_content',
			border: false,
			autoHeight: false,
			height: pageHeight,
			_pageSize: Math.floor((pageHeight - 20) / 23),
			cm: cm,
			sm: sm
		});
		grid.store.load();
		function add(){
			if (win) {
				win.show();
				return;
			}
			var box=new netedu.xjbox ({});
			var major= new Ext.form.Hidden({
				name:"major_code"
			});
			var recruit_major= new Ext.form.Hidden({
				name:"recruit_major_id"
			});
			var title= new Ext.form.Hidden({
				name:"title"
			});
			var class_it = new netedu.comb({
				store: new Ext.data.JsonStore({
					url: '<%=ModName%>.jsp?Action=3',
					autoLoad: false
				}),
				fieldLabel: '班级',
				name:'class_no',
				allowBlank: false,
				listeners: {
					'select': function(){
					},
					'focus': function(){
						if(box.recruit_site_id==""){
							alert("请先选择报名点")
							box.bmd_it.focus();
							return;
						}
						if(box.recruit_major_id==""){
							alert("请先选择专业")
							box.major_it.focus();
							return;
						}
						this.store.setBaseParam('recruit_site_id', box.recruit_site_id);
						this.store.setBaseParam('recruit_major_id', box.recruit_major_id);
						this.store.load({
							callback:function(rs){
								if(rs.length==0){
									alert("该报名点没有开设该专业！如果是新生年级，注意等学籍分班后才能制定特殊计划！")
									return;
								}
								class_it.setValue(rs[0].data.value);
								title.setValue(rs[0].data.text+'计划');
								recruit_major.setValue(box.recruit_major_id);
								major.setValue(box.major_code );
							}
						});
					}
				}
			
			})
			win = new netedu.formWin({
				title: '添加自主教学计划',
				_it: [box.learning_type_it,box.batch_it,box.site_it,box.bmd_it,box.cc_it,box.major_it,class_it,title,recruit_major,major],
				closeAction:'hide',
				_url: 'plan_info_update.jsp?Action=12&source_level=3',
				_suc: function(){
					ok();
				}
			});
			win.show();
		}
		function selPlans(){
		var str = [];
		var oRows = grid.getSelectionModel().getSelections();
		if (oRows.length > 0) {
			for (var i = 0; i < oRows.length; i++) {
				if (oRows[i].data.plan_id != "") {
					str.push(oRows[i].data.plan_id);
				}
			}
		}
		else {
			grid.store.each(function(rs){
				if (rs.data.plan_id != "") {
					str.push(rs.data.plan_id);
				}
			})
		}
		return str;
		
	}
	function validatePlan(){
		var str=selPlans();
		var n=str.length;
		if(n==0){
			alert("没有选择有效的计划！");
			return;
		}
			fn_btn_ajax('plan_view.jsp?Action=5', 'id=' + str.toString(), function(){
				alert("您所选择的" + n + "个计划通过校验！")
			});
	}
	function print(){
		var str=selPlans();
		var n=str.length;
		if(n==0){
			alert("没有选择有效的计划！");
			return;
		}
		window.open('plan_view.jsp?id='+str.toString(),'_blank');
	}
	edit=function(plan_id,apply_level){
		window.parent.openApp("plan_edit", "xfz/plan_edit.jsp?id="+plan_id+"&apply_level="+apply_level, "编辑教学计划", false,true);
	}
	del= function(plan_id){
		fn_btn_ajax('plan_info_update.jsp?&Action=14', 'id='+plan_id, ok);
	}
		function ok(){
			//if (win) win.close();
			grid.store.reload();
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