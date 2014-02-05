<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
try {
	String xs = StringUtil.nullValue(request.getParameter("xs"), "7");
	String nj = StringUtil.nullValue(request.getParameter("nj"), "");
	switch (ActionID) {
	case 3:
		sql = " SELECT rb.batch_code AS value, rb.title AS text,zy_num,plan_num,isnull(ti.xq,0) as xq  FROM swufe_online.dbo.recruit_batch as rb ";
		sql += " left join( ";
		sql += " SELECT rm.[learning_type_code],rm.[batch_code],COUNT(1) as zy_num,SUM(case when pa.plan_id is null then 0 else 1 end) as plan_num ";
		sql += "      FROM [swufe_online].[dbo].[recruit_major] as rm ";
		sql += " 		left join [swufe_ems].[dbo].xfz_plan_apply as pa on pa.apply_level=3 and pa.recruit_major_id=rm.recruit_major_id ";
		sql += " 		group by rm.[learning_type_code],rm.[batch_code] ";
		sql += " ) as r on r.batch_code=rb.batch_code  and r.learning_type_code=rb.learning_type_code";
		sql += " left join [swufe_ems].[dbo].xfz_term_info as ti on ti.is_curr=1 and ti.[learning_type_code]=rb.learning_type_code and ti.batch_code=rb.batch_code ";
		sql += "  ";
		sql += " WHERE rb.status >2 AND rb.learning_type_code ='" + xs + "' ";
		sql += " ORDER by rb.batch_code DESC ";
		sb.append(Data.queryJSON(sql, "list", true));
		break;
	case 2:
		sql = " SELECT rm.[recruit_major_id] ";
		sql += "       ,rm.[learning_level_code] ,rm.[major_code] ";
		sql += "       ,rm.[batch_code] ";
		sql += "       ,rm.[learning_type_code] ";
		sql += "       ,rm.[title]+rm.major_direction as title ";
		sql += "       ,pa.plan_id ";
		sql += "       ,p.is_pub,pd.max_xq ,pd.kc,pd.xf ";
		sql += "       ,xf.min_xf";
		sql += "       ,si.stu";
		//sql += "       ,(select count(1) from swufe_online.dbo.student_info WHERE class_no IS NOT NULL AND (learning_status='0' OR learning_status IS NULL) and zy_id=rm.recruit_major_id) as stu ";
		sql += "   FROM [swufe_online].[dbo].[recruit_major] as rm ";

		sql += "   left join  (select count(1) as stu,recruit_major_id from [swufe_online].[dbo].student_info  where class_no is not null group by recruit_major_id) si  on si.recruit_major_id=rm.recruit_major_id  ";

		sql += "   left join [swufe_ems].[dbo].xfz_plan_apply as pa on pa.apply_level=3 and pa.recruit_major_id=rm.recruit_major_id ";
		sql += "   left join  swufe_ems.dbo.xfz_plan_info  p  on p.id=pa.plan_id";
		sql += "   left join (SELECT  MAX(xq) as max_xq,count(1) as kc,sum(xf) as xf, plan_id ";
		sql += " 			 FROM swufe_ems.dbo.xfz_plan_detail where is_open=1 group by plan_id  ) as pd on pa.plan_id=pd.plan_id ";
		sql += "  left join (SELECT  require_id,count(1) as kclx,sum(min_xf) as min_xf ";
		sql += " 		    FROM swufe_ems.dbo.xfz_xf_require_detail group by require_id ) as xf on xf.require_id=p.xf_require_id  ";
		sql += "   where rm.batch_code='"+nj+"' and rm.learning_type_code='"+xs+"' ";
		sql += "   order by rm.batch_code desc,rm.title ";
		//sb.append(sql);
		sb.append(Data.queryJSON(sql, "list", true));
		break;
	case 1:
	if(!login.hasUrlPerm()){
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
var win, it1, it2, it3, it4, it5, it6, it7,xs,nj,xq,importPlan,del,edit,view;
Ext.onReady(function(){
	function loadGrid(xs1,nj1,xq1){
		xs=xs1;nj=nj1;xq=xq1//保存为全局变量方便使用
		grid.store.setBaseParam('xs', xs);
		grid.store.setBaseParam('nj',nj);
		grid.store.load();
	}
	var pageHeight = document.body.clientHeight;
	var batchStore = new Ext.data.JsonStore({
		url: '<%=ModName%>.jsp?Action=3&xs=7',
		autoLoad: false
	})
	var tbar = new Ext.Toolbar({
		items: ['-', {
			text: '刷新',
			iconCls: 'myicon my_refresh',
			handler: function(){
				grid.store.reload();
			}
		}, '-', '切换招生批次：', new netedu.comb({
			emptyText: ' 切换网教批次',
			width: 170,
			allowBlank: true,
			id: 'nj7',
			store: batchStore,
			tpl: '<tpl for="."><div class="x-combo-list-item">{text}<span  class="green <tpl if="zy_num!=plan_num"> blue b</tpl>">（{zy_num}/{plan_num}）</span></div></tpl>',
			listeners: {
				'select': function(comb, rs){
					Ext.getCmp("nj5").setValue(null);
					loadGrid('7', this.getValue(), rs.data.xq);
				}
			}
		}), '-', new netedu.comb({
			emptyText: ' 切换成教批次',
			allowBlank: true,
			width: 170,
			id: 'nj5',
			store: new Ext.data.JsonStore({
				url: '<%=ModName%>.jsp?Action=3&xs=5',
				autoLoad: true
			}),
			tpl: '<tpl for="."><div class="x-combo-list-item">{text}<span  class="green <tpl if="zy_num!=plan_num"> blue b</tpl>">（{zy_num}/{plan_num}）</span></div></tpl>',
			listeners: {
				'select': function(comb, rs){
					Ext.getCmp("nj7").setValue(null);
					loadGrid('5', this.getValue(), rs.data.xq);
				}
			}
		}), '-', {
			text: '批量校验',
			iconCls: 'myicon my_ok2',
			handler: validatePlan
		}, '-', {
			text: '批量发布',
			iconCls: 'myicon my_save',
			handler: pub
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
		"dataIndex": "learning_level_code",
		"header": "层次",
		renderer: function(v){
			return (v==1?"高起本":(v==2?"专升本":"专科"));
		}
	}, {
		"sortable": true,
		"dataIndex": "title",
		"header": "专业名称"
	}, {
		"sortable": true,
		"dataIndex": "stu",
		"header": "学籍人数",
		width: 60,
		fixed: true
	}, {
		"sortable": true,
		"dataIndex": "plan_id",
		"header": "计划管理",
		renderer: function(v, m, r){
			if (v == "") { return "<a class='op' href='javascript:importPlan("+r.data.recruit_major_id+",3)'>【从上年级导入】</a><a class='op' href='javascript:importPlan("+r.data.recruit_major_id+",1)'>【从培养方案导入】</a>"} 
			var html="";
			if(r.data.is_pub==0){
				html+="<a class='op' href='javascript:del("+v+")'>【清除】</a>";
			}
			var maxxq=(r.data.learning_level_code==1?8:4)//排除毕业环节，高起本8学期，专升本4学期；
			if(xq<maxxq){//已经开完所有课程的专业，锁定计划不允许编辑。
				html+="<a class='op' href='javascript:edit("+v+",3)'>【调整】</a>";
			}
			html+="<a class='op' href='plan_view.jsp?id="+v+"' target='_blank'>【查看】</a>";
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
			"dataIndex": "learning_level_code",
			"header": "当前学期",
			width: 60,
			fixed: true,
			renderer: function(v){
				return xq;
		}
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
		store: new Ext.data.GroupingStore({
			url: '<%=ModName%>.jsp?Action=2&id=<%=id%>',
			reader: new Ext.data.JsonReader(),
			autoLoad: false,
			groupField: 'learning_level_code'
		}),
		renderTo: '<%=ModName%>_content',
		border: false,
		autoHeight: false,
		height: pageHeight,
		_groupTpl: '{text} (共有{[values.rs.length]} {["个专业"]})',
		cm: cm,
		sm: sm,
		listeners: {
			'afterrender': function(){
				batchStore.load({
					callback: function(rs){
						if (rs.length > 0) {
							Ext.getCmp("nj7").setValue(rs[0].data.value);
							loadGrid('7', rs[0].data.value,rs[0].data.xq);
						}
					}
				})
			}
		}
	});
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
	function pub(){
		var str=selPlans();
		var n=str.length;
		if(n==0){
			alert("没有选择有效的计划！");
			return;
		}
		var id=str.toString();
		fn_btn_ajax('plan_view.jsp?Action=5', 'id='+id, function(){
			if (!confirm("发布计划后，你将失去清除该计划、删除课程、重设培养要求的功能！点击确定继续！")) { return; }
			fn_btn_ajax('plan_info_update.jsp?Action=15', 'id='+id, ok);
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
	importPlan= function(recruit_major_id,source_level){
		fn_btn_ajax('plan_info_update.jsp?&Action=13&apply_level=3', 'recruit_major_id='+recruit_major_id+'&source_level='+source_level, ok);
		
	}
	edit=function(plan_id,apply_level){
		window.parent.openApp("plan_edit_nj", "xfz/plan_edit.jsp?id="+plan_id+"&apply_level="+apply_level, "编辑教学计划", false,true);
	}
	del= function(plan_id){
		fn_btn_ajax('plan_info_update.jsp?&Action=14', 'id='+plan_id, ok);
	}
	
	function ok(){
		if (win) win.close();
		grid.store.reload();
	}
});
</script>
<style>
#title {
	color: red;
	text-indent: 10px;
}
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