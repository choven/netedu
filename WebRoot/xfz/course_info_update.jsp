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

	LoginModel login = new LoginModel(request, response,false);
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
			// 新添
			sql = "";
			while (e.hasMoreElements()) {
				n = (String) e.nextElement();
				if (!"Action".equals(n) && !"btn".equals(n) && !"id".equals(n) && !n.startsWith("ext-")) {
					v = StringUtil.nullValue(request.getParameter(n), "");
					sql += ("".equals(sql) ? "" : ",") + "'" + v + "' AS " + n;
				}
			}
			sql = " WITH T1 AS ( SELECT " + sql;
			sql += " ) ";
			sql += " INSERT INTO xfz_course_info(code,title,py,base_xf,base_xs,base_exam_type,course_class_code,status,created_user) ";
			sql += " SELECT code,title,py,base_xf,base_xs,base_exam_type,course_class_code,status,'"+uid+"' FROM T1 ";
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
			sql = "UPDATE xfz_course_info SET " + sql;
			sql += " WHERE id='" + id + "' ";
			break;
		case 5:
			sql += " UPDATE xfz_course_info SET status=0 WHERE id IN (" + com.swufe.toolkit.StringUtil.strComma2Singlequotes(id) + ")";   
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