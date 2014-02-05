<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="com.swufe.toolkit.*"%>
<jsp:useBean id="DT" scope="page" class="com.swufe.data.Sql2File" />
<jsp:useBean id="Data" scope="page" class="com.swufe.data.SQLServer" />
<%
	ResultSet rs = null;
	String sign_in_info_id = StringUtil.nullValue(request.getParameter("sign_in_info_id"), "");
	String sWhere = "";
	if (!"".equals(sign_in_info_id)) {
		sWhere += " AND sign_in_info_id='" + sign_in_info_id + "' ";
	}
	try {
		String sql = "";
		String action = com.swufe.toolkit.StringUtil.nullValue(request.getParameter("Action"), "1");
		String sheetName = com.swufe.toolkit.StringUtil.nullValue(request.getParameter("sheetName"), "No1");
		if ("1".equalsIgnoreCase(action)) {
			sql = " SELECT RANK() OVER (ORDER BY uid) AS id, uid,name ";
			//sql += "     , created_date, created_user, status ";
			sql += " FROM sign_in_data ";
			sql += " WHERE status=1 ";
			sql += sWhere;
			sheetName = "签到名单";
		} else if ("2".equalsIgnoreCase(action)) {
		} else if ("4".equalsIgnoreCase(action)) {
		} else if ("5".equalsIgnoreCase(action)) {
		} else if ("6".equalsIgnoreCase(action)) {
		} else {
			sql = request.getParameter("tsql");
		}
		sql = sql.replace("％", "%");
		String filePath = application.getRealPath("/") + "webDocs\\excel\\";
		String fileName = com.swufe.toolkit.StringUtil.nullValue(request.getParameter("fileName"), "");
		if (fileName == null || fileName.equals("")) {
			fileName = DT.makeFileName() + ".xls";
		}
		try {
			rs = Data.executeQuery(sql);
			if (rs != null) {
				String strErr = "";
				strErr = DT.dataSql2Excel_Adv(rs, filePath + fileName, sheetName);
				if (!strErr.equalsIgnoreCase("OK")) {
					out.print("数据导出过程中出错，转出失败！" + strErr);
				} else {
					response.sendRedirect("./webDocs/excel/" + fileName);
				}
			} else {
				out.print("在形成记录集过程中出错，数据导出失败!"+sql);
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
