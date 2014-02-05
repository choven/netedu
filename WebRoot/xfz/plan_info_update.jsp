<%@ page contentType="text/html;charset=UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="org.json.*"%>
<%@ page import="com.swufe.toolkit.*"%>
<%@ page import="com.swufe.user.*"%>
<%@ page import="com.swufe.module.*"%>
<jsp:useBean id="Data" scope="page" class="com.swufe.data.SQLServer" />
<jsp:useBean id="stringUtil" scope="page"
	class="com.swufe.toolkit.StringUtil" />
<%
	request.setCharacterEncoding("UTF-8");
	response.setHeader("Cache-Control", "no-cache");
	String sql = "";
	List<String> err = new ArrayList<String>();
	boolean uFlags = false;
	JSONObject json = new JSONObject();
	StringBuffer sb = new StringBuffer();
	String sError = "没有添加或更新数据！";
	int ActionID = stringUtil.convertAction(request.getParameter("Action"));
	String id = StringUtil.nullValue(request.getParameter("id"), "");
	String title = StringUtil.nullValue(request.getParameter("title"), "");
	String uid = (String) session.getAttribute("sUserName");
	
	String class_no = StringUtil.nullValue(request.getParameter("class_no"));
	String plan_id = StringUtil.nullValue(request.getParameter("plan_id"));


	String major_code = StringUtil.nullValue(request.getParameter("major_code"));
	String recruit_major_id = StringUtil.nullValue(request.getParameter("recruit_major_id"));
	String is_pub = StringUtil.nullValue(request.getParameter("is_pub"), "");
	String source_level = StringUtil.nullValue(request.getParameter("source_level"));//来源级别 
	String source_id = StringUtil.nullValue(request.getParameter("source_id"));//来源级别 

	LoginModel login = new LoginModel(request, response, false);
	PlanManage pm = new PlanManage(request, response);
	try {
		if (!login.hasPerm("xfz_modify_basic_data")) {
			err.add("你没有权限操作数据！");
		} else {
			int result = 0;
			String n = "";
			String v = "";
			Enumeration<String> e = request.getParameterNames();
			switch (ActionID) {
			case 3: 
				
				break;
			case 4://更新计划属性 //记录日志
				String xf_require_id = StringUtil.nullValue(request.getParameter("xf_require_id"), "");
				sql = " update  xfz_plan_info  set ";
				sql += "  xf_require_id='" + xf_require_id + "'";
				sql += "  where id='" + id + "'";
				sql += " ; insert into xfz_plan_log ( plan_id,title, sql, op_user) values('"+id+"','更改计划属性','"+sql.replaceAll("'","&#39;")+"','"+uid+"') ";
				break;
			case 6:
				// 新添课程
				while (e.hasMoreElements()) {
					n = (String) e.nextElement();
					if (!"Action".equals(n) && !"btn".equals(n) && !"id".equals(n) && !n.startsWith("ext-") && !"fck".equals(n)) {
						v = StringUtil.nullValue(request.getParameter(n), "");//对应该参数名的值
						sql += ("".equals(sql) ? "" : ",") + "'" + v + "' AS " + n;
					}
				}
				sql = " WITH T1 AS ( SELECT " + sql;
				sql += " ) ";
				sql += " INSERT INTO xfz_plan_detail (plan_id, course_code, course_name, course_type_code, xq, xf, xs, exam_type,score_policy_id, is_open, created_user) ";
				sql += " SELECT '" + id + "', course_code, course_name, course_type_code, xq, xf, xs, exam_type,score_policy_id, is_open,'" + uid + "' FROM T1 ";
				sql += " ; insert into xfz_plan_log ( plan_id,title, sql, op_user) values('"+id+"','添加课程','"+sql.replaceAll("'","&#39;")+"','"+uid+"') ";
				break;
			case 7: //编辑教学计划中的课程
				while (e.hasMoreElements()) {
					n = (String) e.nextElement();
					if (!"Action".equals(n) && !"btn".equals(n) && !"id".equals(n) && !"fck".equals(n)) {
						v = StringUtil.nullValue(request.getParameter(n), "");
						sql += ("".equals(sql) ? "" : ",") + n + "='" + v + "' ";
					}
				}
				sql = "UPDATE xfz_plan_detail SET " + sql;
				sql += " WHERE id='" + id + "' ";
				sql += " ; insert into xfz_plan_log ( plan_id,title, sql, op_user) values('"+plan_id+"','编辑课程','"+sql.replaceAll("'","&#39;")+"','"+uid+"') ";
				break;
			case 8:
				// 删除课程，仅未发布的计划可以删除，已发布的计划只允许关闭课程。
				is_pub=Data.queryScalar("select  is_pub from xfz_plan_info where id='"+plan_id+"'");
				if(!"0".equals(is_pub)){
					err.add("该计划已发布，不允许删除课程！" );
				}else{
					sql = " delete from  xfz_plan_detail where id  IN (" + StringUtil.strComma2Singlequotes(id) + ")";
					sql += " ; insert into xfz_plan_log ( plan_id,title, sql, op_user) values('"+plan_id+"','删除课程','"+sql.replaceAll("'","&#39;")+"','"+uid+"') ";
				}
				break;
			case 11://复制培养计划
				int new_id=pm.copyPlan(source_id,title,major_code);
				if(new_id==0){
					out.print(xfz.getJson(false,pm.err));
					return;
				}
				if(pm.applyPlan(""+new_id, "1",  major_code, "null", "null")==false){//注意使用字符串null
					out.print(xfz.getJson(false,pm.err));
					return;
				}
				if(1==1){
					out.print(xfz.getJson(true));
					return;
				}
				break;
			case 12://导入班机计划 ,3:从年级计划倒入 5:从上一个年级到如
				if(pm.importPlanClass(source_level,class_no)==false){
					out.print(xfz.getJson(false,pm.err));
					return;
				}
				if(1==1){
					out.print(xfz.getJson(true));
					return;
				}
				break;
			case 13://导入年级计划 1:从培养计划到如,3:从上个年级到如
				if(pm.importPlanNJ(source_level,recruit_major_id)==false){
					out.print(xfz.getJson(false,pm.err));
					return;
				}
				if(1==1){
					out.print(xfz.getJson(true));
					return;
				}
				break;
			case 14://清除计划 只允许删除未发布的，有外键约束,注意删除顺序。
				is_pub=Data.queryScalar("select  is_pub from xfz_plan_info where id='"+id+"'");
				if(!"0".equals(is_pub)){
					out.print(xfz.getJson(false,"该计划已发布，不允许删除！"));
					return;
				}
				if(pm.delPlan(id,true)==false){
					out.print(xfz.getJson(false,pm.err));
					return;
				}
				if(1==1){
					out.print(xfz.getJson(true));
					return;
				}
						
				break;
			case 15://发布计划
				sql = " update  xfz_plan_info  set ";
				sql += "  is_pub=1 ";
				sql += "  where  id  IN (" + StringUtil.strComma2Singlequotes(id) + ")";
				break;
			}
			result = Data.executeUpdate(sql);
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