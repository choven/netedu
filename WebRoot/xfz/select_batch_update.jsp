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
	String title = StringUtil.nullValue(request.getParameter("title"), "");
	String batch_code = StringUtil.nullValue(request.getParameter("batch_code"), "");
	String status = StringUtil.nullValue(request.getParameter("status"), "");
	String uid = (String) session.getAttribute("sUserName");

	LoginModel login = new LoginModel(request, response,false);
	try {
		if (!login.hasUrlPerm("select_batch")) {
			err.add("你没有权限操作数据！");
		} else {
		int result = 0;
		switch (ActionID) {
		case 3:
			// 新添
		
			sql = " INSERT INTO xfz_select_batch(batch_code,title,created_user) ";
			sql += "  values('"+batch_code+"','"+title+"','"+uid+"') ";
			break;
		case 4:
			// 编辑
			sql = "UPDATE xfz_select_batch SET " ;
			sql += "batch_code='" + batch_code + "' ";
			sql += " ,title='" + title + "' ";
			sql += " WHERE id='" + id + "' ";
			break;
		case 5://开放
			sql += " UPDATE xfz_select_batch SET  status="+status+" where id="+id;   
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