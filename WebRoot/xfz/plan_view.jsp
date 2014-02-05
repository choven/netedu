<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*"%>
<%@ page import="com.swufe.toolkit.*"%>
<%@ page import="com.swufe.module.xfz"%>
<jsp:useBean id="Data" scope="page" class="com.swufe.data.SQLServer" />
<jsp:useBean id="stringUtil" scope="page" class="com.swufe.toolkit.StringUtil" />
<%
	request.setCharacterEncoding("UTF-8");
	String id = StringUtil.nullValue(request.getParameter("id"), "");
	int ActionID = stringUtil.convertAction(request.getParameter("Action"));
	int groupId = stringUtil.convertAction(request.getParameter("groupId"));
	switch (ActionID) {
	case 5:
		response.setHeader("Cache-Control", "no-cache");
		out.print(xfz.getJson(xfz.validatePlan(id),xfz.err));
		break;
	case 2:
		response.setHeader("Cache-Control", "no-cache");
		ResultSet rs = null;
		String sql = "";
		StringBuffer sb = new StringBuffer();
		sql = " SELECT p.id ";
		sql += "       ,p.title ";
		sql += "       ,p.base_major_code ";
		sql += "       ,CONVERT(varchar(16),p.created_date,111) as created_date,p.is_pub,p.status ";
		sql += "       ,pd.max_xq ,pd.kc_total,pd.xf_total,xf.kclx_total,xf.min_xf_total,m.title+m.major_direction as major";
		sql += "   FROM swufe_ems.dbo.xfz_plan_info as p ";
		sql += "   left join (SELECT  MAX(xq) as max_xq,count(1) as kc_total,sum(xf) as xf_total, plan_id ";
		sql += "   			FROM swufe_ems.dbo.xfz_plan_detail where is_open=1 group by plan_id  ) as pd on p.id=pd.plan_id ";
		sql += "  left join (SELECT  require_id,count(1) as kclx_total,sum(min_xf) as min_xf_total ";
		sql += " 		    FROM swufe_ems.dbo.xfz_xf_require_detail group by require_id ) as xf on xf.require_id=p.xf_require_id  ";
		sql += "  left join  swufe_online.dbo.major_info m on m.major_code=p.base_major_code ";
		sql += " WHERE  p.id IN (" + StringUtil.strComma2Singlequotes(id) + ")";
		sql += " order by p.id desc  ";
		try {
			rs = Data.executeQuery(sql);
			if (rs.next()) {
				do {
					out.print("<h3 class='title'>"+rs.getString("title")+"</h3>");
					out.print("<h3 class='no'>NO."+rs.getString("id")+"</h3>");
					out.print("<div class='s_info'>");
					out.print("所属专业：<span class='bb'>"+rs.getString("major")+"</span>最长学期：<span class='bb'>"+rs.getInt("max_xq")+"</span>");
					out.print("最低学分要求：<span class='bb'>"+rs.getInt("min_xf_total")+"</span>供选学分：<span class='bb'>"+rs.getInt("xf_total")+"</span>");
					out.print("供选课程：<span class='bb'>"+rs.getInt("kc_total")+"</span>课程类型数：<span class='bb'>"+rs.getInt("kclx_total")+"</span>");
					
					
					out.print("</div>");
					out.print("<table  class='table' id='t"+rs.getString("id")+"'>");
					out.print("	<tr>");

					out.print(groupId==1?"		<th width='15%'>课程类型</th>":"<th width='9%'>学期</th>");
					out.print("		<th width='10%'>代码</th>");
					out.print("		<th class='tdL'>课程名称</th>");
					out.print(groupId==1?"		<th width='9%'>学期</th>":"<th width='15%'>课程类型</th>");
					out.print("		<th width='9%'> 学分</th>");
					out.print("		<th width='13%'> 考核方式</th>");
					out.print("		<th width='13%'> 平时成绩</th>");
					out.print("	</tr>");
		
					sql = " SELECT pd.id, pd.course_code, pd.course_name, pd.course_type_code, pd.xq, pd.xf, pd.xs, pd.exam_type, pd.is_open,sp.title as sptitle";
					sql += " ,t.title as course_type_name,xf.is_optional,xf.min_xf,e.title as exam_title ";
					sql += " FROM xfz_plan_detail pd ";
					sql += " inner join xfz_plan_info p on p.id=pd.plan_id ";
					sql += " inner join xfz_course_type t on t.code=pd.course_type_code ";
					sql += " inner join xfz_exam_type e on e.code=pd.exam_type ";
					sql += " left join xfz_score_policy sp on sp.id=pd.score_policy_id ";
					sql += " left join xfz_xf_require_detail xf on xf.require_id=p.xf_require_id and xf.course_type_code=pd.course_type_code ";
					sql += " WHERE pd.plan_id="+rs.getInt("id")+"  and pd.is_open=1  ";
					sql +=  (groupId==1?" order by pd.course_type_code,pd.xq ": "order by pd.xq,pd.course_type_code "  )+",pd.course_code";
					ResultSet rs2 = Data.executeQuery(sql);
					while (rs2.next()) {
						out.print("	<tr>");
						if(groupId==1){
							out.print("		<td>" + rs2.getString("course_type_name") + "<br/>"+(rs2.getInt("is_optional")==1?"（选修课）":"（必修课）")+"<br/>最低需"+rs2.getInt("min_xf")+"学分</td>");
						}else{
							out.print("		<td>第" + rs2.getInt("xq")  + "学期</td>");
						}
						out.print("		<td>" + rs2.getString("course_code") + "</td>");
						out.print("		<td class='tdL'>" + rs2.getString("course_name") + "</td>");

						out.print(groupId==1?" <td>" + rs2.getInt("xq") + "</td>":"<td>" + rs2.getString("course_type_name") + "</td>");

						out.print("		<td>" + rs2.getInt("xf") + "</td>");
						out.print("		<td "+(rs2.getInt("exam_type")==1?"":" class=i")+">" + rs2.getString("exam_title") + "</td>");
						out.print("		<td>" + rs2.getString("sptitle") + "</td>");
						out.print("	</tr>");
					}
				out.print("</table>");
				} while (rs.next());
	
			} else {
				out.print("没有数据！");
			}
		} catch (Exception e) {
			out.print(e.toString());
			out.print(Data.err);
		} finally {
			Data.close();
		}
		break;
		case 1:
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link rel="stylesheet" type="text/css" href="/file/gfm/style.css"/>
<script language="javascript" type="text/javascript" src="/file/jquery/jquery-1.4.2.min.js"></script>
<script language="javascript" type="text/javascript" src="/file/jquery/jquery.mergetable.js"></script>
<title>西财在线-查看人才培养方案</title>
</head>
<body>
<style type="text/css">
body{
	padding:10px;
}
.info {
	border-bottom: 1px dotted;
	font-weight:600;
}
/*210mm×297mm*/
#ct{
	width:210mm;
}
.title{
	text-align:center;
	font-family:'黑体';
	font-size:18px;
	line-height:24px;
	padding:0;
	margin:0;
	margin-top:5px;
}
.no{
	text-align:center;
	font-family:"Arial Black";
	font-size:16px;
	letter-spacing:2px;
	padding:0;
	margin:0;
	}
.table {
	border: solid #000 1px;
	text-align: left;
	width: 98%;
	margin-left:5px;
	margin-top:10px;
	border-collapse:collapse;border-spacing:0;
}
.table td,.table th {
	font-size:14px;
	line-height: 2em;
	border: solid #000 1px;
	text-align:center;
	text-indent:0.5em;
}
.table th{
	font-family:'黑体';
	letter-spacing:0.3em;
}
.tdL{
	text-align:left !important;
}
.s_info{
	margin-top:5px;
	font-size:14px;
	text-align:center;
}
.s_info span{
	font-size:14px;
	display:inline-block;
	margin-right:10px;
}
.bb{
	border-bottom:solid #000 1px;
}
</style>
<style media="print">
/*打印机专用CSS，设置边距*/
body,html{
	padding:0;
	margin:0;
}
.info, .notice {
	display: none;
}
</style>
<div class="info">
	<a href="/">西财在线</a>      >     查看计划（可打印版本）    <a href="javascript:loadPlan(1)" class="op">【按课程类型分组查看】</a>    <a href="javascript:loadPlan(2)" class="op">【按学期分组查看】</a>   <a href="javascript:validatePlan()" class="op">【校验该计划】</a>

</div>
<div id="ct">.</div>
<script type='text/javascript'>
function validatePlan(){
	$.ajax({
		cache:false,
		url: 'plan_view.jsp?id=<%=id%>&Action=5',
		success: function(m){
			var json = eval('[' + m + ']')
			if (json[0].success == true) {
				alert("计划<%=id%>通过校验！");
			}else{
				alert(json[0].errors);
			}
		}
	});
}
function loadPlan(groupId){
	$('#ct').html("正在加载数据...");
	$.ajax({
		url: 'plan_view.jsp?id=<%=id%>&Action=2&groupId='+groupId,
		success: function(html){
			$('#ct').html(html);
			try{
				var ids = '<%=id%>'.split(',');
				for (var i = 0; i < ids.length; i++) {
					_w_table_rowspan('#t' + ids[i], 1);
				}
			}catch(e){
				alert(e);
			}
			
		}
	});
}
$(function(){
	loadPlan(1);

})
</script>

</body>
</html>
<%	
	break;
	}
%>
