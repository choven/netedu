<%@ page contentType="text/html;charset=UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="org.json.*"%>
<%@ page import="com.swufe.toolkit.*"%>
<%@ page import="com.swufe.user.*"%>
<jsp:useBean id="Data" scope="page" class="com.swufe.data.SQLServer" />
<jsp:useBean id="stringUtil" scope="page" class="com.swufe.toolkit.StringUtil" />
<%
	String ModName = com.swufe.toolkit.PathUtil.getFileBaseName(request.getRequestURL().toString());
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
	String uid = (String) session.getAttribute("sUserName");
	String term_code = StringUtil.nullValue(request.getParameter("term_code"), "");

	LoginModel login = new LoginModel(request, response,false);
	try {
		if (!login.hasPerm("learning_course_set")) {
			err.add("你没有权限操作数据！");
		} else {
		int result = 0;
		String n = "";
		String v = "";
		Enumeration<String> e = request.getParameterNames();
		switch (ActionID) {
		case 3://批量设置
			sql = " with t as ( ";
			sql += " SELECT  tc.course_code,MAX(c.course_id)  as course_id ";
			sql += "   FROM [swufe_ems].[dbo].[xfz_term_course] tc ";
			sql += "  inner join [learning_swufe].[dbo].[course] c ";
			sql += "      on c.global_id like '%[_]'+tc.learning_course_id  and c.course_name like '%"+term_code+"%' ";
			sql += "   where learning_course_id is not null ";
			sql += "   group by tc.course_code ";
			sql += "   ) ";
			sql += "   update [swufe_ems].[dbo].[xfz_term_course] ";
			sql += "   set learning_course_id=t.course_id ";
			sql += "   from [swufe_ems].[dbo].[xfz_term_course] tc ";
			sql += "   inner join t on tc.course_code=t.course_code ";
			sql += "    where  term_code='"+term_code+"' and learning_course_id is null ";
			break;
		case 4:
			// 编辑
			sql = "";
			while (e.hasMoreElements()) {
				n = (String) e.nextElement();
				if (!"Action".equals(n) && !"btn".equals(n) && !"id".equals(n)) {
					v = StringUtil.nullValue(request.getParameter(n), "");
					sql += ("".equals(sql) ? "" : ",") + n + "='" + v + "' ";
				}
			}
			sql = "UPDATE xfz_term_course SET " + sql;
			sql += " WHERE id='" + id + "' ";
			break;
		case 5:
			sql = " UPDATE xfz_term_course SET learning_course_id=null WHERE term_code='"+term_code+"'";   
			break;
		}
			result = Data.executeUpdate(sql);
			if (Data.err.length() == 0) {
				uFlags = true;
				if (result < 1) {
					err.add(sError);
				}
			} else {
				err.add("<br>" + sql);
				err.add("<br>" + Data.err);
			}
		}
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