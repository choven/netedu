<%@ page contentType="text/html;charset=UTF-8"%>
<%@ page import="com.swufe.module.*"%>
<%@ include file="../baseParameter.jsp"%>
<%
	try {
		switch (ActionID) {
		case 2://
			sql = " select '【'+case rm.learning_type_code when '7' then '网教' else'成教' end+left(rm.batch_code,4)+case RIGHT(rm.batch_code,1)  when '9' then '秋' else'春' end+'】' ";
			sql += " +'【' +case rm.learning_level_code when '1' then '高起本' when '2' then '专升本'else'专科' end +'】' ";
			sql += " +rm.title+rm.major_direction  as title ,rm.recruit_major_id,p.is_pub,pa.plan_id,p.title as plan_title";
			sql += "   from  [swufe_online].[dbo].recruit_major  rm  ";
			sql += "   inner join  (select count(1) as stu,recruit_major_id from [swufe_online].[dbo].student_info  where class_no is not null group by recruit_major_id) si  on si.recruit_major_id=rm.recruit_major_id  ";
			sql += "   left join  xfz_plan_apply pa on pa.recruit_major_id=rm.recruit_major_id  ";
			sql += "   left join  xfz_plan_info p on p.id = pa.plan_id ";
			sql += "    where  rm.batch_code>'200503'  and  (pa.plan_id is null  or p.is_pub=0) and si.stu>0";
			sql += "    order by rm.batch_code desc ";
			rs = Data.executeQuery(sql);
			while (rs.next()) {
				if(rs.getInt("plan_id")==0){
					out.print("<li><span class='red'>未设置></span>"+rs.getString("title")+"教学计划。</li>");
				}else	
					if(rs.getInt("is_pub")==0){
					out.print("<li><a class='op' href='plan_view.jsp?id="+rs.getString("plan_id")+"' target='_blank'>未发布></a>编号为"+rs.getString("plan_id")+"的计划。</li>");
				}
			}
			break;
		case 3:
			sql = " select  pa.plan_id";
			sql += "   from  xfz_plan_apply pa ";
			sql += "   inner join  xfz_plan_info p on p.id = pa.plan_id ";
			//sql += "    where p.status=1 ";
			sql += "    group by  pa.plan_id order by   pa.plan_id desc";
			rs = Data.executeQuery(sql);
			
			while (rs.next()) {
				if(xfz.validatePlan(rs.getString("plan_id"))==false){
					out.print("<li><a class='op' href='plan_view.jsp?id="+rs.getString("plan_id")+"' target='_blank'>数据错误></a>"+xfz.err+"</li>");
				}
			}
	
			break;
		case 1:
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>教学计划</title><%@ include file="../ext-3.3.0.jsp"%>
<script type="text/javascript">
var win;
Ext.onReady(function(){
	function loadCt(){
		Ext.get("apply").load({
			url:'<%=ModName%>.jsp?Action=2'
		})
		Ext.get("data").load({
			url:'<%=ModName%>.jsp?Action=3'
		})
	}
	var tbar = new Ext.Toolbar({
		items: ['-',{
				text:'刷新',iconCls:'myicon my_refresh',
				handler:loadCt
			},'-'],
		renderTo: 'tbar'

	});
	
	loadCt();
});
</script>
<style>
.line{
border-top:1px solid #7db45c;
font-size:2px;
height:2px;
width:100%;
}
#tool{
	margin:2px 2px 2px 5px;
}
#tool h3{
line-height:24px;
}
#tool h3 span{
 display:block;
}
#tool h3 span.right{
	cursor:hand;
}
#tool li{
	line-height:24px;
}
.block2{
	margin-bottom:5px;
}
.ct_block{
	float:left;
	width:49%;
	margin-right:5px;
}
.ct_block ul{
	padding-left:10px;
	height:500px;
	overflow:auto;
	list-style:decimal;
	padding-left:30px;
}
</style>
</head>
<body>
<div id='tbar'></div>
<div class='line'></div>

<div id="tool">

<div class="ct_block">
	<b class="tl"></b><b class="tr"></b>
	<div class="block2">
		<h3>教学计划设置情况检查</h3>
		<ul id="apply" class="clear"></ul>
	</div>
</div>
<div class="ct_block">
	<b class="tl"></b><b class="tr"></b>
	<div class="block2">
		<h3>教学计划数据校验</h3>
		<ul id="data" class="clear"></ul>
	</div>
</div>
</div>


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