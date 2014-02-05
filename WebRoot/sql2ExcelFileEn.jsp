<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="com.swufe.toolkit.*"%>
<%@ page import="java.util.*"%>
<%@ page import="com.swufe.module.*"%>
<jsp:useBean id="DT" scope="page" class="com.swufe.data.Sql2File" />
<jsp:useBean id="cw" scope="page" class="com.swufe.module.CwUtils" />
<jsp:useBean id="Data" scope="page" class="com.swufe.data.SQLServer" />
<%
	request.setCharacterEncoding("UTF-8");
	response.setHeader("Cache-Control", "no-cache");
	ResultSet rs = null;
	String query = StringUtil.nullValue(request.getParameter("query"), "");
	String year = StringUtil.nullValue(request.getParameter("year"), "");
	String month = StringUtil.nullValue(request.getParameter("month"), "");
	try {
		String sql = "";
		String action = com.swufe.toolkit.StringUtil.nullValue(request.getParameter("Action"), "1");
		String sheetName = com.swufe.toolkit.StringUtil.nullValue(request.getParameter("sheetName"), "No1");
		String filePath = application.getRealPath("/") + "webDocs\\Excel\\";
		String fileName = com.swufe.toolkit.StringUtil.nullValue(request.getParameter("fileName"), "");
		if (fileName == null || fileName.equals("")) {
			fileName = DT.makeFileName() + ".xls";
		}
		Calendar cal = Calendar.getInstance();
		if ("1".equalsIgnoreCase(action)) {
			sql = " SELECT name, sfzh, uid, pwd, bankbook, mobile ";
			sql += " FROM swufe_cw.dbo.user_info  ";
			sql += " WHERE gid=3 ";
			if (!"".equals(query)) {
				sql += " AND ( name LIKE '%" + query + "%' OR sfzh LIKE '%" + query + "%' ) ";
			}
			sheetName = "教师工资查询用户信息";
		} else if ("2".equalsIgnoreCase(action)) {
			// 上课教师工资汇总（劳务费）
			fileName = "wages_sheet_serviceCharge_" + year + "_" + month + "_" + StringUtil.showDateToday() + ".xls";
			CwUtils.ExportServiceCharge(year, month, filePath + fileName);
		} else if ("3".equalsIgnoreCase(action)) {
			// 上课教师工资汇总（稿费）
			fileName = "wages_sheet_authorCharge_" + year + "_" + month + "_" + StringUtil.showDateToday() + ".xls";
			CwUtils.ExportAuthorCharge(year, month, filePath + fileName);
		} else if ("4".equalsIgnoreCase(action)) {
			// 上课教师工资汇总（劳务费和稿费）
			fileName = "wages_sheet_all_" + year + "_" + month + "_" + StringUtil.showDateToday() + ".xls";
			CwUtils.ExportCharge(year, month, filePath + fileName);
		} else {
			sql = request.getParameter("tsql");
		}
		try {
			if (!"".equals(sql)) {
				sql = sql.replace("％", "%");
				rs = Data.executeQuery(sql);
				if (rs != null) {
					String strErr = "";
					strErr = DT.dataSql2Excel_Adv(rs, filePath + fileName, sheetName);
					if (!strErr.equalsIgnoreCase("OK")) {
						out.print("数据导出过程中出错，转出失败！" + strErr);
					} else {
						response.sendRedirect("./webDocs/Excel/" + fileName);
					}
				} else {
					out.print("在形成记录集过程中出错，数据导出失败!");
				}
			} else {
				response.sendRedirect("./webDocs/Excel/" + fileName + "?" + System.currentTimeMillis());
			}
		} catch (Exception ex) {
			out.print("SQL Error：" + ex.getMessage() + "\n" + sql);
		}
	} catch (Exception e) {
		out.print(e.toString());
	} finally {
		if (rs != null) {
			rs.close();
		}
		Data.close();
	}
%>
