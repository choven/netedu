<%@page contentType="text/html;charset=UTF-8"%>
<%@ include file="../baseParameter.jsp" %>
<%
    response.setHeader("Cache-Control", "no-cache");
    request.setCharacterEncoding("UTF-8");
    String online = StringUtil.nullValue(request.getParameter("online"), "");
    String code = StringUtil.nullValue(request.getParameter("code"), "");
    String key = StringUtil.nullValue(request.getParameter("key"), "");
    ResultSet rs = null;
    try {
        // 分类处理
        switch (ActionID) {
            case 0://系统消息提醒
                sql = " SELECT count(1) as sms  from system_sms  ";
                sql += "  where uidTo='" + user_id + "' and is_readed=0  and status=1";
                out.print(Data.queryJSON(sql, "list", true));
                login.refreshOnlineFlag();
                break;
            case 1://用户列表
                sql = " SELECT a.user_id , a.user_name, a.online_flag,b.name as typeName ";
                sql += " FROM  user_info  a  left outer join  user_type as b on a.user_type_id =b.id";
                sql += " where 1=1";
                if ("1".equals(online)) {
                    sql += " and a.online_flag =1";
                }
                sql += " order by a.user_name ";
                rs = Data.executeQuery(sql);
                out.print("<ul>");
                while (rs.next()) {
                    out.print("<li class='myicon my_user_boy'>" + rs.getString("user_name") + "</li> ");
                }
                out.print("</ul>");
                rs.close();
                break;
            case 2://系统帮助列表
                String info[][] = Data.queryArray("select id,parent_id from module_info where code='" + code + "'");
                sql = " SELECT  id, title, is_system, status, is_good ,module_id";
                sql += " FROM  help_center   ";
                if ("".equals(key)) {
                    sql += " where (is_system=1 or is_good=1  )  and (module_id =-1 ";
                    if (info.length > 0) {
                        sql += " or module_id='" + info[0][0] + "' or  module_id='" + info[0][1] + "'  ";
                    }
                    sql += ")";
                } else {
                    sql += " where title like '%" + key + "%' ";
                }
                sql += " order  by  module_id  desc";
                //out.print(sql);
                out.print("<ul>");
                rs = Data.executeQuery(sql);
                if (rs.next()) {
                    do {
                        out.print("<li class='" + (info.length > 0 && rs.getString("module_id").equals(info[0][0]) ? "curr" : "") + "' title='" + rs.getString("title") + "'>");

                        out.print("<a href='user/show_help.jsp?id=" + rs.getString("id") + "' target='_blank'>" + stringUtil.ellipsis(rs.getString("title"), 17) + "</a></li> ");
                    } while (rs.next());
                } else {
                    out.print("<li>没有相关的帮助与咨询。</li>");
                }
                out.print("<ul class='assi_faq_op'>您还可以：");
                out.print("<li><a href='javascript:showAssi()'>刷新当前功能帮助</a></li>");
                out.print("<li><a href='javascript:assiSearch()'>搜索帮助文档与常见问题</a></li>");
                out.print("<li><a href='javascript:assiAsk()'>反馈您的问题</a></li>");
                out.print("<li><a href='javascript:openApp(\"support_center\", \"user/support.jsp\", \"支持与帮助中心\", false, true, 62)'>打开帮助中心获得更多帮助</a></li>");
                out.print("</ul>");
                rs.close();
                break;
        }
    } catch (Exception e) {
        out.print(e.toString());
    } finally {
        Data.close();
    }
%>
