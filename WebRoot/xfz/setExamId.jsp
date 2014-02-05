<%@ page contentType="text/html;charset=UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="org.json.*"%>
<%@page import="java.sql.*"%>  
<%@ page import="com.swufe.toolkit.*"%>
<%@ page import="com.swufe.user.*"%>
<%@ page import="com.swufe.data.*"%>
<jsp:useBean id="Data" scope="page" class="com.swufe.data.SQLServer" />
<jsp:useBean id="stringUtil" scope="page" class="com.swufe.toolkit.StringUtil" />
<%!
boolean checkExamId(int i,String course_code,String term_code){
	boolean uFlags = false;
	SQLServer data= new SQLServer();
	String sql = " with t as ( ";
	sql += " SELECT  pa.id,  case when pd.course_code='"+course_code+"' then "+i+" else tc.exam_id end as exam_id from swufe_online.dbo.recruit_major rm ";
	sql += " 	inner join [swufe_ems].[dbo].[xfz_term_info]  ti on  ti.term_code='"+term_code+"' and ti.batch_code=rm.batch_code and ti.learning_type_code=rm.learning_type_code ";
	sql += " 	inner join  swufe_ems.dbo.xfz_plan_apply  pa on pa.recruit_major_id=rm.recruit_major_id and apply_level=3 ";
	sql += " 	inner join swufe_ems.dbo.xfz_plan_detail pd on pd.plan_id=pa.plan_id and  (pd.xq=ti.xq or (pd.xq=0 and ti.xq>1) ) and is_open=1 ";
	sql += " 	inner join [swufe_ems].[dbo].xfz_term_course tc on tc.term_code=ti.term_code and tc.course_code=pd.course_code ";
	sql += " ) ";
	sql += " select  id from t  where exam_id is not null ";
	sql += " group by  id,exam_id having COUNT(1)>1 ";
	try{
		ResultSet rs = data.executeQuery(sql);    
			if (data.err.length() == 0&&!rs.next()) { 
				uFlags = true;
			}
	}catch(Exception e){
	}
	return uFlags;
}
%>

<%
	request.setCharacterEncoding("UTF-8");
	response.setHeader("Cache-Control", "no-cache");
	String sql = "";
	 ResultSet rs = null; 
	List<String> err = new ArrayList<String>();
	boolean uFlags = false;
	JSONObject json = new JSONObject();
	StringBuffer sb = new StringBuffer();
	String sError = "没有添加或更新数据！";
	int ActionID = stringUtil.convertAction(request.getParameter("Action"));
	String uid = (String) session.getAttribute("sUserName");
	String term_code = StringUtil.nullValue(request.getParameter("term_code"),"201409");

	LoginModel login = new LoginModel(request, response,false);
	try {
		if (!login.hasUrlPerm("select_batch")) {
			err.add("你没有权限操作数据！");
		} else {
		int result = 0;
		switch (ActionID) {
		case 1:
			sql = " 	SELECT  pa.plan_id,ti.xq,p.title as p_title from swufe_online.dbo.recruit_major rm ";
			sql += " 	inner join [swufe_ems].[dbo].[xfz_term_info]  ti on  ti.term_code='"+term_code+"' and ti.batch_code=rm.batch_code and ti.learning_type_code=rm.learning_type_code ";
			sql += " 	inner join swufe_ems.dbo.xfz_plan_apply  pa on pa.recruit_major_id=rm.recruit_major_id and apply_level=3 ";
			sql += "    inner join [swufe_ems].[dbo].[xfz_term_xz] xz on xz.learning_level_code=rm.learning_level_code ";
			sql += "    inner join [swufe_ems].[dbo].[xfz_plan_info] p on p.id=pa.plan_id ";
			sql += " 	 where  ti.xq< xz.max_xq_base ";  
			sql += "     and rm.learning_type_code='7'   ";  //分春秋安排
			//sql += "     and ti.xq % 2 =0     ";
			sql += " 	  order by rm.recruit_major_id desc  "; 
			//out.print(sql);
			rs = Data.executeQuery(sql);  
			while (rs.next()){    
				sql = " 	 select tc.id as tc_id,pd.course_code,tc.exam_id from  swufe_ems.dbo.xfz_plan_detail  pd ";
				sql += " 	 inner join [swufe_ems].[dbo].xfz_term_course tc on tc.term_code='"+term_code+"' and tc.course_code=pd.course_code ";
				sql += " 	 where  pd.plan_id="+rs.getInt("plan_id")+" and   (pd.xq="+rs.getInt("xq")+" or (pd.xq=0 and "+rs.getInt("xq")+" >1) ) and pd.is_open=1 and pd.exam_type=1 and pd.xq>0 ";
				sql += " order by tc.exam_id  desc"; //先将已安排好考试的排在最前面，先形成数组examList。
				ArrayList examList = new ArrayList();
				int i=0;
				ResultSet rs2 = Data.executeQuery(sql);   
				while (rs2.next()){ 
					//out.print(rs2.getInt("exam_id"));
					 if(rs2.getInt("exam_id")!=0){
						examList.add(rs2.getInt("exam_id"));
					 }else{
						 i++;
						 while(examList.contains(i)||checkExamId(i,rs2.getString("course_code"),term_code)==false){
							 i++;
						 }
						 Data.executeUpdate("update [swufe_ems].[dbo].xfz_term_course set exam_id="+i+" where  id='"+rs2.getInt("tc_id")+"'  ");
					 }
				}
				out.print(rs.getString("p_title")+":"+examList.toString()+"<br/>");
			
			}  
		
			
		break;
		}
			//result = Data.executeUpdate(sql);
			if (Data.err.length() == 0) {
				uFlags = true;
			} else {
				err.add("<br>" + sql);
				err.add("<br>" + Data.err);
			}
		}//perm end
			if (uFlags) {
				json.put("success", new Boolean(true));
			} else {
				json.put("success", new Boolean(false));
				json.put("errors", StringUtil.filterBrackets(err.toString()));
			}
			out.print(json);
		out.flush();
	} catch (Exception e) {
		err.add("<br>抛出错误：" + e.toString());
	} finally {
		Data.close();
	}
%>