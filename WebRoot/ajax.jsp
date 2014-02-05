<%@page contentType="text/html;charset=UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="com.swufe.toolkit.*"%>

<jsp:useBean id="Data" scope="page" class="com.swufe.data.SQLServer" />
<jsp:useBean id="stringUtil" scope="page" class="com.swufe.toolkit.StringUtil" />

<%
	response.setHeader("Cache-Control", "no-cache");
	request.setCharacterEncoding("UTF-8");
	
	ResultSet rs = null;
	String sql = "";
	StringBuffer sb = new StringBuffer();
	String Action = request.getParameter("Action");
	int ActionID = stringUtil.convertAction(Action);

	String learning_type_code = StringUtil.nullValue(request.getParameter("learning_type_code"), "");
	String batch_code = StringUtil.nullValue(request.getParameter("batch_code"), "");
	String site_code = StringUtil.nullValue(request.getParameter("site_code"), "");
	String recruit_site_id = StringUtil.nullValue(request.getParameter("recruit_site_id"), "");
	String learning_level_code = StringUtil.nullValue(request.getParameter("learning_level_code"), "");
	try {
		// 分类处理
		switch (ActionID) {
 		case 1://切换招生批次/  输入
			sql = " SELECT batch_code as value ,title as text";
			sql += "  FROM swufe_online.dbo.recruit_batch   where  learning_type_code='"+learning_type_code+"'  order by batch_code desc";
			//out.print(sql);
			sb.append(Data.queryJSON(sql, "list", true)); 
			break;
		case 2://切换招生站点/
			sql = " SELECT   site_code as value ,MAX(title) as text FROM [swufe_online].[dbo].[recruit_site] ";
			sql += "   where   is_link=1  and status =1 and learning_type_code='"+learning_type_code+"' ";
			if(!"".equals(batch_code)){
				sql += "   and batch_code='"+batch_code+"' ";
			}
			sql += "   group by site_code order by MAX(is_center)desc,MAX(title) ";
			sb.append(Data.queryJSON(sql, "list", true)); 
			break;
		case 3://切换报名点
			sql = " SELECT  recruit_site_id AS value ,title AS text";
			sql += "   FROM [swufe_online].[dbo].[recruit_site]   where    is_link=0  and batch_code='"+batch_code+"' and parent_id= ";
			sql += "   (select origin_site_id from [swufe_online].[dbo].[recruit_site] where site_code='"+site_code+"' and batch_code='"+batch_code+"' )  ";
			//out.print(sql);
			sb.append(Data.queryJSON(sql, "list", true)); 
			break;

		case 4://切换专业
			sql = " SELECT '【'+case  learning_level_code when 1 then '高起本' when '2' then '专升本' else '专科' end +'】' +MAX(title)+MAX(major_direction) as text ";
			sql += " ,major_code as value,case COUNT(1) when 1 then MAX( recruit_major_id)  else null end as  recruit_major_id ";
			sql += "   FROM [swufe_online].[dbo].[recruit_major] ";
			sql += "     where   learning_type_code='"+learning_type_code+"' ";
			sql += "     and learning_level_code like '%"+learning_level_code+"%' ";
			sql += "     and batch_code like '%"+batch_code+"%' ";
			if("".equals(batch_code)&&"".equals(recruit_site_id)){//无年级属性，则屏蔽几个禁用的专业。
				sql += "     and major_code not in (SELECT major_code FROM [swufe_online].[dbo].[major_info] where status=0) ";
			}
			/*recruit_site_major  数据不全，这条取消。
			if(!"".equals(recruit_site_id)){
				sql += "     and recruit_major_id in(SELECT [recruit_major_id] FROM [swufe_online].[dbo].[recruit_site_major]   where recruit_site_id='"+recruit_site_id+"') ";
			}
			*/
			sql += "     group by major_code,learning_level_code order by  learning_level_code,max(title) ";
			sb.append(Data.queryJSON(sql, "list", true)); 
			//out.print(sql);
			break;
	
		}
	} catch (Exception e) {
		out.print(e.toString());
	} finally {
		Data.close();
		out.print(sb.toString());
	}
%>
