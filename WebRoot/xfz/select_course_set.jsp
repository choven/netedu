<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%@ page import="com.swufe.module.xfz"%>
<%
String batch_code = StringUtil.nullValue(request.getParameter("batch_code"), "");
	try {
		switch (ActionID) {
		case 2:
			sql = " with t as ( ";
			sql += " SELECT ";
			sql += " pd.course_code ";
			sql += " ,max(xf.is_optional) as is_optional ";
			sql += " ,count( distinct xf.is_optional) as optional_type ";
			sql += " ,min(pd.exam_type) as exam_type ";
			sql += " from swufe_online.dbo.recruit_major rm ";
			sql += " inner join [swufe_ems].[dbo].[xfz_term_info]  ti on  ti.term_code='"+batch_code+"' and ti.batch_code=rm.batch_code and ti.learning_type_code=rm.learning_type_code ";
			sql += " inner join  swufe_ems.dbo.xfz_plan_apply  pa on pa.recruit_major_id=rm.recruit_major_id and apply_level=3 ";
			sql += " inner join swufe_ems.dbo.xfz_plan_detail pd on pd.plan_id=pa.plan_id and  (pd.xq=ti.xq or(pd.xq=0 and ti.xq>1) ) and is_open=1 ";
			sql += " inner join swufe_ems.dbo.xfz_xf_require_detail xf on xf.course_type_code=pd.course_type_code ";
			sql += " group by pd.course_code ";
			sql += " ) ";
			sql += " SELECT tc.id, tc.term_code,tc.course_code,tc.course_name,t.is_optional,t.optional_type,t.exam_type ";
			sql += " ,case when t.is_optional=0 then '单一必修' else (case when t.optional_type=1 then '单一选修' else '选修及必修' end ) end as optional_type_title  ";
			sql += " from [swufe_ems].[dbo].xfz_term_course tc ";
			sql += " inner join t on t.course_code=tc.course_code and tc.term_code='"+batch_code+"' ";
			sb.append(Data.queryJSON(sql, "list", true));
			break;
		case 1:
		if(!login.hasUrlPerm("select_batch")){
			out.print("没有权限访问此功能");
			return;
		}
		xfz.syncTermCourse(term_code);
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>西财在线</title>
<%@ include file="../ext-3.3.0.jsp" %>
<script type="text/javascript">
	var win, it1, it2, it3, it4, it5, it6, it7,status,view,select_course_set
	Ext.onReady(function(){
		var tbar = new Ext.Toolbar({
			items: [{
				text: '按考试序号分组',
				iconCls: 'myicon my_add2',
				handler: add
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
			"dataIndex": "is_optional",
			"header": "是否选修",//这里取的is_optional最大值
			renderer:FormatYesNo,
			width: 100,
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
			width: 100,
			fixed: true,
			renderer:FormatYesNo//这里取的exam_type的最小值，
		}, {
			"sortable": true,
			"dataIndex": "xf",
			"header": "考试序号",
			width: 100,
			fixed: true
		}])
		var grid = new netedu.grid({
			tbar: tbar,
			store: new Ext.data.GroupingStore({
				url: '<%=ModName%>.jsp?Action=2&batch_code=<%=batch_code%>',
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
		function formIt(){
			it1 = new netedu.comb({
				store: new Ext.data.SimpleStore({
					fields: ['text', 'value'],
					data: [[nYear+'年', nYear], [1+nYear+'年', 1+nYear]]
				}),
				fieldLabel: '选课年份',
				listeners:{
					select:function(){
						it3.setValue(it1.getValue()+it2.getValue());
						it4.setValue(it1.getRawValue()+it2.getRawValue());
					}
					}
			})
			it2 = new netedu.comb({
				store: new Ext.data.SimpleStore({
					fields: ['text', 'value'],
					data: [['春期', '03'], ['秋期', '09']]
				}),
				fieldLabel: '选课学期',
				listeners:{
					select:function(){
						it3.setValue(it1.getValue()+it2.getValue());
						it4.setValue(it1.getRawValue()+it2.getRawValue());
					}
				}
			})
			it3= new Ext.form.TextField({
				fieldLabel: '批次编码',
				name: 'batch_code',
				allowBlank: false,
				readOnly:true
			});
			it4 = new Ext.form.TextField({
				fieldLabel: '批次标题',
				name: 'title',
				allowBlank: false,
				readOnly:true
			});
			return [it1, it2,it3,it4]
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
			if(rows[0].data.status!=1){
				alert("该批次已不在准备状态，不允许更改！");
				return;
			}
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
			it1.setValue(rows[0].data.batch_code.substring(0,4));
			it2.setValue(rows[0].data.batch_code.substring(4,6));
			win.show();
		}
		status=function(v,batch_code){
			
		}
		view=function(batch_code){
			
		}
		select_course_set =function(){
			var rows=grid.initSeChk(1);
			if (!rows) return false;
			window.parent.openApp("select_course_set","xfz/select_course_set.jsp?batch_code=" + rows[0].get('batch_code'),'供选课程设置',false,true)
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