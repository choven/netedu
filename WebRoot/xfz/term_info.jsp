<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%try {
	String all = StringUtil.nullValue(request.getParameter("all"), "");
	switch (ActionID) {
	case 2:
		sql = " SELECT a.[learning_type_code] + a. batch_code as code,a.title,a.learning_type_code as lb";
		sql += "       ,a.[batch_code] as nj ";
		sql += "       ,b.maxcc ";
		sql += "       ,b.xz_xq_total ";
		sql += "       ,c.term_code as  curr_term_code";
		sql += "       ,isnull(c.xq,0) as  curr_xq,isnull(c.is_max,0) as is_max ";
		sql += "   ,((datediff(mm, a.batch_code+'01',GETDATE())+1)/6)+1 as  curr_xq2";//按理论时间算出来的学期数，忽略学制限制
		sql += "   FROM [swufe_online].[dbo].[recruit_batch]  as a ";
		sql += "   inner join  ( SELECT min(rm.learning_level_code)as maxcc,max(xz.max_xq_base) as xz_xq_total,rm.batch_code,rm.learning_type_code FROM [swufe_online].[dbo].[recruit_major] rm  inner join [swufe_ems].[dbo].[xfz_term_xz] xz on xz.learning_level_code=rm.learning_level_code group by rm.learning_type_code,rm.batch_code) as b ";
		sql += "   on a.batch_code=b.batch_code and a.learning_type_code=b.learning_type_code ";
		sql += "   left join [swufe_ems].[dbo].[xfz_term_info] c on c.is_curr=1 and  a.batch_code=c.batch_code and a.learning_type_code=c.learning_type_code ";
		sql += "  where a.status>2 ";
		if(!"1".equals(all)){//默认只显示学制未满的年级。
			//sql += "  and b.xz_xq_total>= ((datediff(mm, a.batch_code+'01',GETDATE())+1)/6)+1 ";//学制中的学期数量>=当前理论学期数，说明学制未满。
			sql += "  and  isnull(c.is_max,0)=0 ";//原理和上面一样，只不过这个简单一些，如果学期数据 is_max=1 and is_curr=1 那么说明这个年级学制已经满了。
		}
		sql += "   order by a.learning_type_code desc,a.[batch_code] desc ";
		//out.print(sql);
		sb.append(Data.queryJSON(sql, "list", true));
		break;
	case 1:
		if(!login.hasUrlPerm()){
			out.print("没有权限访问此功能");
			return;
		}
		//同步新的招生年级
		sql = " with t as ( ";
		sql += " SELECT  rm.batch_code,rm.learning_type_code,xz.xq,CONVERT(varchar(6),DATEADD(MM,6*(xz.xq-1), rm.batch_code+'01'),112) as term_code,max(xz.is_max) as is_max ";
		sql += "   FROM [swufe_online].[dbo].[recruit_major] rm ";
		sql += "   inner join [swufe_ems].[dbo].xfz_term_base xz on xz.learning_level_code=rm.learning_level_code ";
		sql += "   group by rm.batch_code,rm.learning_type_code,xz.xq ";
		sql += "  ) ";
		sql += " insert into  [swufe_ems].[dbo].[xfz_term_info] (batch_code,learning_type_code,xq,term_code, is_curr,is_max) ";
		sql += "   select batch_code,learning_type_code,xq,term_code,0 as is_curr, is_max from t    where  not exists ";
		sql += "   ( ";
		sql += "   select batch_code,learning_type_code,xq,term_code from  [swufe_ems].[dbo].[xfz_term_info] ";
		sql += "   where batch_code=t.batch_code and learning_type_code=t.learning_type_code and xq=t.xq and term_code=t.term_code ";
		sql += "   ) ";
		Data.executeUpdate(sql);
		
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>教学计划</title>
<%@ include file="../ext-3.3.0.jsp" %>
<script type="text/javascript">
	var win, it1, it2, it3, it4, it5, it6, it7,vv=0,openTerm,cancelTerm,fix;
	Ext.onReady(function(){
		var pageHeight = document.body.clientHeight;
		var rs2;
		var tbar = new Ext.Toolbar({
			items: ['-', {
				text: '显示学制已满年级',
				iconCls: 'myicon my_unchecked',
				handler: function(){
					vv=vv^1;
					if(vv==1){
						this.setIconClass("myicon my_checked");
						grid.store.setBaseParam('all', 1);
						grid.store.load();
						
					}else{
						this.setIconClass("myicon my_unchecked")
						grid.store.setBaseParam('all', '');
						grid.store.load();
					}
				}
			},'-',{
				text: '批量开学',
				iconCls: 'myicon my_add2',
				handler: fix
			}]
		});
		var sm = new Ext.grid.CheckboxSelectionModel();
		var cm = new Ext.grid.ColumnModel([new Ext.grid.RowNumberer({
			width: 45
		}), sm, {
			"sortable": true,
			"dataIndex": "lb",
			"header": "学习形式",
			renderer: function(v){
				return v=='7'?"网教":"成教"
				}
			
		}, {
			"sortable": true,
			"dataIndex": "title",
			"header": "招生年级"
		}, {
			"sortable": true,
			"dataIndex": "maxcc",
			"header": "所含招生专业最长学制",
			renderer: function(v,m,r){
				switch (v) {
				case "1":
					return '<span class=green>高起本（'+r.data.xz_xq_total+' 学期）</span>';
				case "2":
					return '专升本（'+r.data.xz_xq_total+' 学期）';
				case "3":
					return '专     科（'+r.data.xz_xq_total+' 学期）';
				}
			}
		}, {
			"sortable": true,
			"dataIndex": "curr_xq",
			"header": "当前学期",
			renderer:function(v,m,r){
				var html="";
				if(v==0){
					html+= "<span class='red'>未开学</span>"
				}else{
					
				 	html+= '<span class="b">'+v+'</span> ('+r.data.curr_term_code+')'
				 }
				 return html;
				 
			}
		}, {
			"sortable": true,
			"dataIndex": "curr_xq2",
			"header": "开学管理",
			renderer:function(v,m,r){
				var html="";
				  //if(v>r.data.curr_xq&&v<=r.data.xz_xq_total){//理论学期大于当前学期，且理论学期在学制范围之内：可以新开学。
				  if(v>r.data.curr_xq&&r.data.is_max==0){//原理同上
				 		html+= '<a class=op href=javascript:openTerm()>【开学】</a>';
				 //} else if (v <= r.data.xz_xq_total){//学制未满的可以取消开学
				 } else if (r.data.is_max==0){
				 		html+= '<a  class=op href=javascript:cancelTerm()>【回退一学期】</a>'
				 }
				 return html;
			}
		}, {
			"sortable": true,
			"dataIndex": "curr_xq2",
			"header": "理论当前学期"
		}, {
			"sortable": true,
			"dataIndex": "curr_xq2",
			"header": "数据诊断",
			renderer:function(v,m,r){
				 if(v>r.data.curr_xq&&r.data.is_max==0){
				 		return '<span class="green">有新学期可以开学</span>';
				 }
				 if (r.data.is_max==1) {
				 	return '<span class="gray">所有专业学制已满</span>';
				 }
				 return "数据正常"
			}
		}])
		var grid = new netedu.grid({
			tbar: tbar,
			store: new Ext.data.GroupingStore({
				url: '<%=ModName%>.jsp?Action=2',
				reader: new Ext.data.JsonReader(),
				autoLoad: true,
				sortInfo: {
					field: "nj",
					direction: "desc"
				},
				groupField: 'lb'
			}),
			_groupTpl: '{text}/共有{[values.rs.length]} 个年级',
			renderTo: '<%=ModName%>_content',
			border: false,
			autoHeight: false,
			height: pageHeight,
			cm: cm,
			sm: sm
		});
		grid.store.load();
		openTerm=function(){
			var rows = grid.initSeChk(1);
			if (!rows) return false;
			var r=rows[0];
			var n=r.data.curr_xq2;//开学就是把理论学期（curr_xq2）设置为实际的当前学期。
			fn_btn_ajax('<%=ModName%>_update.jsp?&Action=4&n='+n+'&nj=' + rows[0].data.nj+'&lb='+rows[0].data.lb, '', ok)
		}
		cancelTerm=function (){
			var rows = grid.initSeChk(1);
			if (!rows) return false;
			var r=rows[0];
			if (!confirm("回退后，该年级所有学生将以上一个学期为当前学期进行学习，点击确定以继续！")) { return; }
			var n=r.data.curr_xq;//取消开学就是把当前学期的的is_curr属性设置为0，把当前学期的上一个学期（如果存在）设置为1
			fn_btn_ajax('<%=ModName%>_update.jsp?&Action=5&n='+n+'&nj=' + rows[0].data.nj+'&lb='+rows[0].data.lb, '', ok)
		}
		function fix(){
			if (!confirm("批量开学将按当前日期，让所有学制未满的年级开学，点击确定以继续！")) { return; }
			fn_btn_ajax('<%=ModName%>_update.jsp?&Action=3', '', ok);
		}
		function ok(){
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
<%break;
}
} catch (Exception e) {
out.print(e.toString());
} finally {
Data.close();
out.print(sb.toString());
} %>