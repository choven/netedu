<%@page contentType="text/html;charset=UTF-8"%>
<%@ include file="baseParameter.jsp" %>

<%
    response.setHeader("Cache-Control", "no-cache");
    request.setCharacterEncoding("UTF-8");

    String sUid = StringUtil.nullValue(request.getParameter("sUid"), "");
    String sGid = StringUtil.nullValue(request.getParameter("sGid"), "");
    String parent_id = StringUtil.nullValue(request.getParameter("parent_id"), "");

    String query = StringUtil.nullValue(request.getParameter("query"), "");
    ResultSet rs = null;

    try {
        // 分类处理
        switch (ActionID) {
            case -1://更新缓存
                sql = " SELECT login_name,pwd FROM  user_info WHERE user_id='" + user_id + "'";
                String ui[][] = Data.queryArray(sql);
                out.print(StringUtil.getResultJson(login.login(ui[0][0], ui[0][1]), login.err));
                break;
            case 1://用户查询
                sql = " SELECT id,user_id AS value, user_name AS text,created_date";
                sql += " FROM  user_info ";
                sql += " WHERE ( user_name LIKE '%" + query + "%' OR login_name LIKE '%" + query + "%' ) ";
                sql += "     AND status=1 ";
                out.print(Data.queryJSON(sql, "order by id desc", request));
                break;

            case 3://用户组列表
                sql = " SELECT id as value ,name as text";
                sql += " ,(select count(1) from user_group_user where user_group_id=user_group.id) as num ";
                sql += " FROM  user_group ";
                sql += " WHERE  status='1' ";
                sql += " order by id desc ";
                out.print(Data.queryJSON(sql));
                break;
            case 104://用户类型列表
                sql = " SELECT id as value ,name as text";
                sql += " FROM  user_type ";
                sql += " WHERE  status='1' ";
                sql += " order by id desc ";
                out.print(Data.queryJSON(sql));
                break;
            case 4://模块树，用于权限分配
                sql = " SELECT id,parent_id,name as text,code ,cast(1 as bit) as expanded";
                String user_perm=Perm.getUserPerm(sUid, "id", ",");
                if (!"".equals(sUid)) {
                    sql += ",cast (CASE WHEN (SELECT top 1 id FROM  user_perm WHERE user_id ='" + sUid + "'  and is_user_group=0 AND module_id=module_info.id ) IS NULL THEN 0  ELSE 1 END as bit) AS checked ";
                    sql += ",CASE WHEN (SELECT top 1 id FROM  user_perm WHERE user_group_id in (select user_group_id from user_group_user where user_id='" + sUid + "') and is_user_group=1 AND module_id=module_info.id ) IS NULL THEN 0 ELSE 1 END AS group_checked ";
                }
                if (!"".equals(sGid)) {
                    sql += ",cast(CASE WHEN (SELECT top 1 id FROM  user_perm WHERE user_group_id ='" + sGid + "' and is_user_group=1  AND module_id=module_info.id ) IS NULL THEN 0 ELSE 1 END as bit) AS checked ";
                    sql += ",CASE WHEN (SELECT top 1 id FROM  user_perm WHERE user_group_id ='" + sGid + "' and is_user_group=1  AND module_id=module_info.id ) IS NULL THEN 0 ELSE 1 END AS group_checked ";
                }
                if ("".equals(sUid) && "".equals(sGid)) {
                    sql += ",cast(0 as bit) as checked";
                    sql += ",0 as group_checked";
                }
                sql += " FROM  module_info where is_public<>1 ";
                //out.print(sql);
                out.print(Data.queryJSONTree(sql, -1,"order by id"));
                break;
            case 5://模块树--用于模块管理
                sql = " SELECT  id, parent_id, name as text, code, url, is_finish, is_public, is_blank, is_reload, type, status ";
                sql += " ,case when type=1 then  'myicon my_key' else '' end as  iconCls ";
                sql += " ,(select count(1) from module_panel where module_info_id=module_info.id ) as regNum ";
                sql += "  from module_info ";
                out.print(Data.queryJSONTree(sql, -1,"order by id"));
                break;
            case 6://控制面板树
                sql = " SELECT  a.id, a.list_no,a.group_no, a.module_info_id, a.parent_id, a.name as text, isnull(b.name,'--') AS mod_title, isnull(b.code,'--') as code ";
                sql += "  FROM  module_panel AS a LEFT OUTER JOIN module_info AS b ON a.module_info_id = b.id";
                out.print(Data.queryJSONTree(sql, -1,"order by group_no,list_no"));
                break;

            case 7://框架面板分类
                sql = " SELECT id ,name ,iconCls";
                sql += " FROM  module_panel ";
                sql += " WHERE parent_id='-1' ";
                sql += " and id in (";
                sql += " SELECT  distinct(parent_id) ";
                sql += "   FROM module_panel  where module_info_id in (" + Perm.getUserPerm(user_id, "id", ",") + ") ";
                sql += ")  ";
                sql += " order by list_no ";
                // out.print(sql);
                out.print(Data.queryJSON(sql, "list", true));
                break;
            case 8://框架分类列表
                sql = " SELECT ";
                sql += "       mp.[name], mp.group_no,mp.iconCls ";
                sql += "       ,mi.url,mi.code ";
                sql += "       ,mi.is_finish, mi.is_blank,  mi.is_reload ";
                sql += "   FROM [module_info] mi ";
                sql += "   left join   user_perm  up  on up.module_id=mi.id ";
                sql += "   inner join module_panel mp on mp.module_info_id=mi.id ";
                sql += "   where mp.parent_id='" + parent_id + "'";
                sql += "    and  mi.id  in (" + Perm.getUserPerm(user_id, "id", ",") + ") ";
                sql += " order by mp.group_no, mp.list_no ";
                //out.print(sql);
                out.print("<ul class='fm_node_list'>");
                rs = Data.executeQuery(sql);
                int group_no = 0;
                while (rs.next()) {
                    if (group_no > 0 && group_no != rs.getInt("group_no")) {
                        out.print("<div class='sp'></div>");
                    }
                    group_no = rs.getInt("group_no");
                    out.print("<li><span class='num fm_node_num" + rs.getString("is_finish") + "'>" + rs.getRow() + "</span><a href=javascript:openApp('" + rs.getString("code") + "','" + rs.getString("url") + "','" + rs.getString("name") + "'," + rs.getString("is_blank") + "," + rs.getString("is_reload") + ",'" + parent_id + "')>" + rs.getString("name") + "</a></li> ");
                }
                out.print("</ul>");
                break;
            case 9://切换站点
                /*
                 String s_4 = "";
                 out.print("<ul class='siteChange'>");
                 if ("1".equals(login.getUserTypeId()) || "2".equals(login.getUserTypeId())) {
                 out.print("<li>0、<a href=javascript:setCurrSite('','所有站点') " + ("".equals(login.getCookie("curr_bj_bm")) ? "  class='red b'" : "") + ">所有站点</a></li> ");
                 sql = " SELECT site_code,case when LEN(short_name)>1 then short_name else title end as title ";
                 sql += " FROM [swufe_online].[dbo].[site_info] where is_link=1 and learning_type_code like '%" + lb_bm + "' and (status =1 or site_id IN (59,15,1610)) "; // 新都学习中心 59 河南学习中心 15 江苏盐城学习中心 1610
                 sql += " order by status DESC,[is_center] desc,[province_id] ";
                 // 追加一个自学考试校本部站点 001 成教院
                 s_4 = "";
                 if ("4".equals(lb_bm)) {
                 s_4 = "<li>1、<a href=javascript:setCurrSite('001','成教院') " + ">成教院</a></li> ";
                 }
                 } else if ("1".equals(is_multi)) {
                 sql = " SELECT site_code,case when LEN(short_name)>1 then short_name else title end as title ";
                 sql += " FROM swufe_online.dbo.site_info where is_link=1 and learning_type_code like '%" + lb_bm + "' and (site_code IN (SELECT string FROM swufe_online.dbo.uf_StrSplit('" + zds + "',',')) ) "; // 管理多个站点
                 sql += " order by status DESC,is_center desc,province_id ";
                 //out.print(sql);
                 }
                 rs = Data.executeQuery(sql);
                 while (rs.next()) {
                 out.print("<li title='" + rs.getString("site_code") + "'>" + rs.getRow() + "、<a href=javascript:setCurrSite('" + rs.getString("site_code") + "','" + rs.getString("title") + "') " + (rs.getString("site_code").equals(login.getCookie("curr_bj_bm")) ? " class='red b'" : "") + ">" + rs.getString("title") + "</a></li> ");
                 }
                 out.print(s_4);
                 out.print("</ul>");
                 * */
                break;

        }
    } catch (Exception e) {
        out.print(e.toString());
    } finally {
        Data.close();
    }
%>
