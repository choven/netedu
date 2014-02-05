<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<jsp:useBean id="Ext" scope="page" class="com.swufe.data.Ext" />
<%
	String nj = StringUtil.nullValue(request.getParameter("nj"), "");
	String site = StringUtil.nullValue(request.getParameter("site"), "");
	String spe = StringUtil.nullValue(request.getParameter("spe"), "");
	try {
		switch (ActionID) {
		case 4://站点
			sql = "SELECT origin_site_id AS value, title as text ";
			sql += " from [swufe_online].[dbo].[recruit_site]   where is_link=1  and batch_code+learning_type_code='" + nj + "' order by title ";
			sb.append(Data.queryJSON(sql, "list", true));
			break;
		case 3://年级
			sql = "SELECT batch_code+learning_type_code AS value, title as text ,batch_code,learning_type_code ";
			sql += " from [swufe_online].[dbo].[recruit_batch]   where status>2 order by batch_code desc,learning_type_code ";
			sb.append(Data.queryJSON(sql, "list", true));
			break;
		case 2:
			sql = " with batch as ( ";
			sql += " SELECT  learning_type_code,batch_code ";
			sql += "   FROM [swufe_ems].[dbo].[xfz_term_info] ";
			sql += " group by learning_type_code,batch_code ";
			sql += "  having MAX(is_curr)=0 ";
			
			if (!login.hasPerm("site_plan_apply_xq1")) {
				sql += "   or SUM( case when is_curr=1 and xq=1 then 1 else 0 end )=1 ";//允许开学后的第一学期之内申报计划
			 }
			
			 if (login.hasPerm("site_plan_apply_all")) {
				sql += "   or SUM( case when is_curr=1 and is_max=0 then 1 else 0 end )=1 ";//允许申报所有未结束行课的年级的计划
			 }
			
			sql += "  ),stu as ( ";
			sql += " SELECT  si.zy_id as recruit_major_id,si.zd_id as recruit_site_id,MAX(rs.title )as site_name,si.site_code ";
			sql += " ,COUNT(1) as lq_num ";
			sql += " ,SUM(case when si.class_no is not null then 1 else 0 end ) as xj_num ";
			sql += "   FROM [swufe_online].[dbo].[student_info] si ";
			sql += "   inner join [swufe_online].[dbo].[recruit_site]  rs on rs.recruit_site_id=si.recruit_site_id ";
			sql += "   inner join batch on si.batch_code=batch.batch_code and si.learning_type_code=batch.learning_type_code ";
			sql += "   where si.is_admission=2   and  rs.parent_id='"+curr_site_id+"' ";
			sql += "   group by si.zy_id,si.zd_id,si.site_code ";
			sql += "  ) ";
			sql += " SELECT  stu.recruit_major_id,stu.recruit_site_id,stu.lq_num,stu.xj_num,rm.batch_code,rm.learning_type_code,stu.site_name ";
			sql += "   ,'【'+stu.site_name+'】'+'【'+case rm.learning_type_code when '7' then '网教' else'成教' end+left( rm.batch_code,4)+case RIGHT(rm.batch_code,1)  when '9' then '秋' else'春' end+'】【'+case rm.learning_level_code when '1' then '高起本' when '2' then '专升本'else'专科' end +'】'+rm.title+rm.major_direction as title ";
			sql += "   ,spa.plan_id ";
			sql += "   ,spa.status ";
			sql += "   FROM stu ";
			sql += "  inner join swufe_online.dbo.recruit_major rm on rm.recruit_major_id=stu.recruit_major_id ";
			sql += "   left join [swufe_ems].[dbo].xfz_site_plan_apply spa on spa.recruit_major_id=stu.recruit_major_id and spa.recruit_site_id=stu.recruit_site_id ";
			sql += "  order by rm.batch_code desc,stu.site_code,rm.learning_level_code,rm.title";
			sb.append(Data.queryJSON(sql, "list", true));
			
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
var win, it1, it2, it3, it4, it5, it6, it7,nj="",vv=0;
var disabled=<%=(!login.hasUrlPerm("plan_edit"))%>;//控制编辑权限
Ext.onReady(function(){
	var pageHeight = document.body.clientHeight;
	var siteStore=new Ext.data.JsonStore({
		url: '<%=ModName%>.jsp?Action=4',
		autoLoad: false
	});
	var tbar = new Ext.Toolbar({
		items: ['-',{
			text: '过滤：',
			xtype: 'tbtext'
		}]
	});
	var sm = new Ext.grid.CheckboxSelectionModel();
	var cm = new Ext.grid.ColumnModel([new Ext.grid.RowNumberer({
		width: 45
	}), sm,{
		"sortable": true,
		"dataIndex": "batch_code",
		width: 80,
		fixed: true,
		"header": "招生年级"
	},{
		"sortable": true,
		"dataIndex": "site_name",
		width: 80,
		fixed: true,
		"header": "报名点"
	}, {
		"sortable": true,
		"dataIndex": "title",
		"header": "班级名称",
		renderer: function(v){
			return "<span>"+v+"</span>"
		}
	},{
		"sortable": true,
		"dataIndex": "lq_num",
		width: 80,
		fixed: true,
		"header": "录取人数"
	},{
		"sortable": true,
		"dataIndex": "xj_num",
		width: 80,
		fixed: true,
		"header": "学籍人数"
	},{
		"sortable": true,
		"dataIndex": "recruit_site_id",
		width: 80,
		fixed: true,
		"header": "专业计划",
			renderer: function(v){
			if (v == "") { return "<span class='red'>未指定计划</span>"} 
			return v;
		}
	},{
		"sortable": true,
		"dataIndex": "plan_id",
		width: 80,
		fixed: true,
		"header": "班级计划",
		renderer: function(v,m,r){
			return r.data.is_spe_plan=="1"?v:"继承"
		}
	}, {
		"sortable": true,
		"dataIndex": "is_spe_plan",
		"header": "特殊计划",
		width: 65,
		fixed: true,
		renderer: FormatYesNo
	}])
		var grid = new netedu.grid({
			tbar: tbar,
			store: new Ext.data.GroupingStore({
				url: '<%=ModName%>.jsp?Action=2',
				reader: new Ext.data.JsonReader(),
				autoLoad: false,
				groupField: 'site_name'
				}),
			_groupTpl: '{text} (共有{[values.rs.length]} {["个班"]})',
			sm:sm,
			cm:cm,
			autoHeight: false,
			height: document.body.clientHeight,
			renderTo: '<%=ModName%>_content',
			border: false
		});
	grid.store.load();
	function set(){
		var rows = grid.initSeChk(1);
		if (!rows) return false;
		if (rows[0].data.plan_id != "") {
			if (!confirm("该班级已经有一个对应的教学计划，重新指定计划将会影响该班级下的所有学生！是否需要重新指定该班级的教学计划？")) { return; }
		}
		if (win) win.close();
		win = new netedu.formWin({
			width:550,
			title: '设置教学计划',
			_it: [new Ext.form.TextField({
				fieldLabel: '班级全称',
				name: 'title',
				value:rows[0].data.batch_code+rows[0].data.class_name+rows[0].data.cc+rows[0].data.zy,
				disabled:true
			}),new Ext.form.TextField({
				fieldLabel: '班级编号',
				name: 'class_no',
				value:rows[0].data.class_no,
				readOnly:true
			}), new netedu.comb({
			fieldLabel: '教学计划',
			emptyText :' 选择教学计划,不选为取消特殊计划',
			name: 'plan_id',
			allowBlank:true,
			tpl: '<tpl for="."><div class="x-combo-list-item" >{text}（{kc}课程/{xq}学期）</div></tpl>',
			store: new Ext.data.JsonStore({
				url: 'plan_major.jsp?Action=4&zy='+rows[0].data.major_code,
				autoLoad: true
			}),
			listeners:{
				'beforeselect':function(c,r,i){
					 if(r.data.value==rows[0].data.old_plan_id){
						alert("你选择的计划与专业计划相同，无需单独指定特殊计划！")
						return false;
					 }
					
				}
			}
		})],
			_url: 'plan_info_update.jsp?Action=11',
			_suc: ok
		});
		win.show();
	}
	function edit(){
		var rows = grid.initSeChk(1);
		if (!rows) return false;
		var plan_id=rows[0].data.is_spe_plan=="1"?rows[0].data.plan_id:rows[0].data.old_plan_id
		if(plan_id){
		window.parent.openApp("plan_edit", "plan/plan_edit.jsp?id="+plan_id, "编辑教学计划", false,true)
		}else{
			alert("没有指定任何专业计划或者班级计划！")
		}
	}
	function view(){
		var rows = grid.initSeChk(1);
		if (!rows) return false;
		var plan_id=rows[0].data.is_spe_plan=="1"?rows[0].data.plan_id:rows[0].data.old_plan_id
		if(plan_id){
		window.parent.openApp("plan_view", "plan/plan_view.jsp?plan_id="+plan_id, "查看教学计划", false,true)}
		else{
			alert("没有指定任何专业计划或者班级计划！")
		}
	}
	function ok(){
		if (win) win.close();
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