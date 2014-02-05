<%@ page contentType="text/html;charset=UTF-8"%>
<%@ page import="com.swufe.module.*"%>
<%@ include file="../baseParameter.jsp"%>
<%
	String the_batch_code = StringUtil.nullValue(request.getParameter("batch_code"));
	try {
		switch (ActionID) {
		case 3:
		sql = " SELECT  batch_code as value ,title as text from  [xfz_select_batch]  where status>1";
		sql += " order by batch_code desc";
		sb.append(Data.queryJSON(sql, "list", true));
		break;
		case 2://
			sql = "  SELECT tc.course_code,tc.course_name ";
			sql += "  ,sc.stu_num ";

			sql += "  from [swufe_ems].[dbo].xfz_term_course tc ";
			sql += " 	left join (select sc2.course_code,count(1) as stu_num from swufe_ems.dbo.xfz_stu_course sc2 ";
			sql += " 			inner join  [swufe_online].[dbo].[student_info] si on  si.student_id=sc2.student_id ";
			sql += " 			where sc2.term_code='"+the_batch_code+"'  and si.class_no is not null and isnull(si.learning_status,0)=0 group by sc2.course_code) sc" ;
			sql += "   on sc.course_code=tc.course_code ";
			sql += "   where tc.term_code='"+the_batch_code+"' ";
			rs = Data.executeQuery(sql);
			//out.print(sql);
			while (rs.next()) {
				
					out.print("<td>"+rs.getString("course_name")+"</td>");
				
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
var win,batch_code='<%=the_batch_code%>';
Ext.onReady(function(){
	var batchStore = new Ext.data.JsonStore({
		url: '<%=ModName%>.jsp?Action=3',
		autoLoad: true,
			listeners:{
			'load':function(store,rs){
				if (rs.length > 0&&batch_code=="") {
					batch_code=rs[0].data.value;
				}
				batchComb.setValue(batch_code);
				loadCt();

			}
		}
	})
		var  batchComb=new netedu.comb({
			store: batchStore,
			listeners: {
				'select': function(comb, rs){
					batch_code=this.getValue();
					loadCt();
				}
			}
		})
	function loadCt(){
		Ext.get("tool").load({
			url:'<%=ModName%>.jsp?Action=2&batch_code='+batch_code
		})
	}
	var tbar = new Ext.Toolbar({
		items: ['-',{
				text:'刷新',iconCls:'myicon my_refresh',
				handler:loadCt
				}, '-',
				'切换选课批次：', batchComb],
		renderTo: 'tbar'

	});
	
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

</style>
</head>
<body>
<div id='tbar'></div>
<div class='line'></div>

<div id="tool">


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