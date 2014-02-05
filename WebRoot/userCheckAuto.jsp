<%@ page language="java" pageEncoding="UTF-8"%>
<%@ page import="java.text.*"%>
<%@ page import="java.util.*"%>
<%@ page import="com.swufe.toolkit.*"%>
<%@ page import="com.swufe.user.*"%>
<jsp:useBean id="Data" scope="page" class="com.swufe.data.SQLServer" />
<%
	request.setCharacterEncoding("UTF-8");
	String sPage = StringUtil.nullValue(request.getParameter("page"), "");
	String sUserName = (String) session.getAttribute("sUserName");
	//if (sUserName == null || "".equalsIgnoreCase(sUserName)) {
		String uid = com.swufe.toolkit.StringUtil.validityConvert(request.getParameter("uid"));
		String pwd = com.swufe.toolkit.StringUtil.validityConvert(request.getParameter("pwd"));
		UserInfo user = new UserInfo();
		user.AddAccessLog(request, response);
		if (user.userCheck(uid, pwd, "swufe_ems.dbo.user_info") == true) {
			// 记录登录用户名、用户身份
			session.setAttribute("sUserName", user.uid);
			session.setAttribute("sName", user.name);
			session.setAttribute("sUserGroup", user.user_group);
			session.setAttribute("sUserType", user.user_type_id);
			session.setAttribute("auto", "auto");
			// 站点属性 2011-04-02
			String sql = " SELECT TOP 1 ui.bj_bm, ui.bmd_bm, isnull(si.title,'') as bj_mc,ISNULL(zds,''),si.site_id ";
			sql += " FROM swufe_ems.dbo.user_info as ui left join [swufe_online].[dbo].[site_info] as si on ui.bj_bm=si.site_code  ";
			sql += " WHERE ui.uid='" + user.uid + "' ";
			String arr[][] = Data.queryArray(sql);
			session.setAttribute("bj_bm", arr[0][0]);
			session.setAttribute("bmd_bm", arr[0][1]);
			session.setAttribute("zds", arr[0][3]);
			session.setAttribute("is_multi", arr[0][3].indexOf(",")>-1?"1":"0");
			// 更新登录次数
			session.setAttribute("uTimes", Integer.toString(user.uTimes));
			LoginModel login = new LoginModel(request, response,false);
			String modUrl=login.getUserPerm("url");
			login.setCookie("modUrl",modUrl);//将权限的URL（getFileBaseName）列表写入cookie,
			login.setCookie("user_setting",user.user_setting);

			if("1".equals(user.user_type_id)||"2".equals(user.user_type_id)){
				login.setCookie("curr_bj_bm", "001001");
				login.setCookie("curr_bj_mc", "西财网院");
				login.setCookie("curr_site_id", "7");
			} else{
				login.setCookie("curr_bj_bm", arr[0][0]);
				login.setCookie("curr_bj_mc", arr[0][2]);
				login.setCookie("curr_site_id", arr[0][4]);
			}

			// 记录登录日志
			Calendar cal = Calendar.getInstance();
			SimpleDateFormat formatter = new SimpleDateFormat("yyyy-M-d H:mm:ss");
			String tmpDateStr = formatter.format(cal.getTime());
			if (user.updateLog(session.getId(), user.uid, user.name, request.getRequestURL().toString(), tmpDateStr) == false) {
				//out.print("登录日志记录失败！");
			}
			response.sendRedirect(sPage);
		} else {
			out.print(user.getPrompt());
		}
	//} else {
		//response.sendRedirect(sPage);
	//}
%>