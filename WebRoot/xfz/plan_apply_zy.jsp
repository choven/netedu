<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
try {
	switch (ActionID) {
	case 3:
		sql = " select id as value,title as text from swufe_ems.dbo.xfz_plan_info  ";
		sql += " where id in(select plan_id from swufe_ems.dbo.xfz_plan_apply  where  apply_level=1) ";
		sb.append(Data.queryJSON(sql, "list", true));
		break;
	case 2:
		sql = " SELECT m.major_code";
		sql += "       ,m.[learning_level_code]  ";
		sql += "       ,m.[title]+m.major_direction as title ";
		sql += "       ,pa.plan_id ";
		sql += "       ,p.is_pub,pd.max_xq ,pd.kc,pd.xf ";
		sql += "       ,xf.min_xf ";
		sql += "   FROM [swufe_online].[dbo].[major_info] as m ";
		sql += "   left join [swufe_ems].[dbo].xfz_plan_apply as pa on pa.apply_level=1 and pa.major_code=m.major_code ";
		sql += "   left join  swufe_ems.dbo.xfz_plan_info  p  on p.id=pa.plan_id";
		sql += "   left join (SELECT  MAX(xq) as max_xq,count(1) as kc,sum(xf) as xf, plan_id ";
		sql += " 			 FROM swufe_ems.dbo.xfz_plan_detail where is_open=1 group by plan_id  ) as pd on pa.plan_id=pd.plan_id ";
		sql += "  left join (SELECT  require_id,count(1) as kclx,sum(min_xf) as min_xf ";
		sql += " 		    FROM swufe_ems.dbo.xfz_xf_require_detail group by require_id ) as xf on xf.require_id=p.xf_require_id  ";
		sql += "   where m.status=1 ";
		sql += "   order by m.title ";
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
var win, it1, it2, it3, it4, it5, it6, it7,copy,edit,view;
Ext.onReady(function(){
	var pageHeight = document.body.clientHeight;
	var tbar = new Ext.Toolbar({
		items: ['-', {
			text: '刷新',
			iconCls: 'myicon my_refresh',
			handler: function(){
				grid.store.reload();
			}
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
		"dataIndex": "plan_id",
		"header": "培养方案管理",
		renderer: function(v, m, r){
			if (v == "") { return "<span class='red'>尚未设置<a class='op' href=javascript:copy('"+r.data.major_code+"')>【复制】</a></span>"} 
			var html="";
				html+="<a class='op' href='javascript:edit("+v+",1)'>【调整】</a>";
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
		sm: sm
	});
	grid.store.load();
	function formIt(){
		it1 = new netedu.comb({
			store: new Ext.data.JsonStore({
				url: '<%=ModName%>.jsp?Action=3',
				autoLoad: true
			}),
			allowBlank: false,
			fieldLabel: '选择复制源',
			name: 'source_id',
			listeners: {
				'select': function(){
					it2.setValue(this.getRawValue());
				}
			}
		})
		it2=new Ext.form.TextField({
				fieldLabel:'设置新标题',
				name:'title',
				allowBlank:false
			});
			return [it1,it2]
	}
	copy= function(major_code){
		if (win) win.close();
			win=new netedu.formWin({
				title:'复制培养方案',
				width:500,
				_it:formIt(),
				_url:'plan_info_update.jsp?Action=11&major_code='+major_code,
				_id:'',
				_suc:ok
			});
			win.show();
	}
	edit=function(plan_id,apply_level){
		window.parent.openApp("plan_edit_zy", "xfz/plan_edit.jsp?id="+plan_id+"&apply_level="+apply_level, "编辑培养方案", false,true);
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