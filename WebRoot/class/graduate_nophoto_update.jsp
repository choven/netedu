<%@ page contentType="text/html;charset=UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="org.json.*"%>
<%@ page import="com.swufe.toolkit.*"%>
<%@ page import="com.swufe.user.*"%>
<jsp:useBean id="Data" scope="page" class="com.swufe.data.SQLServer" />
<jsp:useBean id="stringUtil" scope="page" class="com.swufe.toolkit.StringUtil" />
<%
	request.setCharacterEncoding("UTF-8");
	response.setHeader("Cache-Control", "no-cache");
	String sql = "";
	List<String> err = new ArrayList<String>();
	boolean uFlags = false;
	JSONObject json = new JSONObject();
	String sError = "没有添加或更新数据！";
	int ActionID = stringUtil.convertAction(request.getParameter("Action"));
	String id = StringUtil.nullValue(request.getParameter("id"), "");
	String uid = (String) session.getAttribute("sUserName");
	String values = StringUtil.nullValue(request.getParameter("values"), "");
	LoginModel login = new LoginModel(request, response, false);

	try {
		if (!login.hasUrlPerm("graduate_nophoto")) {
			err.add("你没有权限操作数据！");
		} else {
			int result = 0;
			switch (ActionID) {
			case 3://录入成绩
				sql = " update ks_list_apply ";
				//sql += " set ks_fs='"+value+"' ";
				sql += " where   id='"+id+"'";
				//sql += " ; insert into cj_input_log ([list_id] ,[student_id],[kc_bm],[ks_fs],oper_type,[oper_user],oper_sys) values ('"+id+"','"+student_id+"','"+kc_bm+"','"+value+"','input','"+uid+"','"+login.getIpAddr()+"')";
				break;
			case 5:
				sql = " delete from [swufe_ems].[dbo].[graduate_nophoto_stu]  where id in(" + com.swufe.toolkit.StringUtil.strComma2Singlequotes(id) + ")";
				break;
			case 6:
				if(!"".equals(values)){
				//Data.executeUpdate("");
				values = values.replaceAll("\r\n", ",");//IE
				values = values.replaceAll("\n", ",");
				sql = "  delete from [swufe_ems].[dbo].[graduate_nophoto_stu] ";
				sql += "   ;insert into  [swufe_ems].[dbo].[graduate_nophoto_stu] ";
				sql += "   ([student_id],[admission_no]) ";
				sql += "   select student_id,[admission_no] from [swufe_online].[dbo].[student_info]   where  [admission_no] in (SELECT string  FROM swufe_online.dbo.uf_StrSplit_max('" + values + "', ',')) group by student_id,[admission_no] ";
				}
				//out.print(sql);
				break;
			case 7:
				sql += "   insert into  [swufe_ems].[dbo].[graduate_nophoto_stu] ";
				sql += "   ([student_id],[admission_no]) ";
				sql += "   select student_id,[admission_no] from [swufe_online].[dbo].[student_info]   where  [admission_no]='"+values+"' or register_id  ='"+values+"' group by student_id,[admission_no] ";
				break;
			}
			result = Data.executeUpdate(sql);
			if (Data.err.length() == 0) {
				uFlags = true;

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