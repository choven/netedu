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
	StringBuffer sb = new StringBuffer();
	String sError = "没有添加或更新数据！";
	int ActionID = stringUtil.convertAction(request.getParameter("Action"));
	String uid = (String) session.getAttribute("sUserName");
	String nj = StringUtil.nullValue(request.getParameter("nj"));
	String lb = StringUtil.nullValue(request.getParameter("lb"));
	String n = StringUtil.nullValue(request.getParameter("n"),"0");

	LoginModel login = new LoginModel(request, response,false);
	try {
		if (!login.hasUrlPerm("term_info")) {
			err.add("你没有权限操作数据！");
		} else {
		int result = 0;
		switch (ActionID) {
		case 3://修复所有的is_max和is_curr
		 sql = " declare @curr_term  varchar(50) ";
		sql += "  select @curr_term =DATENAME(YY,GETDATE())+case when MONTH(getdate()) >=9  then '09' else '03' end ";
		sql += " update [swufe_ems].[dbo].[xfz_term_info] set is_curr=0,is_max=0; ";
		sql += "  update [swufe_ems].[dbo].[xfz_term_info] ";
		sql += "  set is_max=(case when maxXQ.xq is null then 0 else 1 end), ";
		sql += "  is_curr=(case when (term_code=@curr_term  or (maxXQ.xq is not null and term_code< @curr_term)) then 1 else 0 end) ";
		sql += "  from [swufe_ems].[dbo].[xfz_term_info] t2 ";
		sql += " left  join(select  batch_code,learning_type_code,MAX(xq) as xq from  [swufe_ems].[dbo].[xfz_term_info] group by batch_code,learning_type_code) maxXQ ";
		sql += "  on  t2.batch_code=maxXQ.batch_code and t2.learning_type_code=maxXQ.learning_type_code and t2.xq=maxXQ.xq ";
			break;
		case 4://开学就是把理论学期（curr_xq2）设置为 is_curr=1,别的学期设置为0。
			sql=" update xfz_term_info set is_curr=(case when xq="+n+" then 1 else 0 end) where learning_type_code='"+lb+"' and batch_code='"+nj+"'";
			break;
		case 5://取消开学就是把当前学期的上一个学期（如果存在）设置为1，,别的学期设置为0。
			sql=" update xfz_term_info set is_curr=(case when xq="+(Integer.parseInt(n)-1)+" then 1 else 0 end) where  learning_type_code='"+lb+"' and batch_code='"+nj+"'";
			
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