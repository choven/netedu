package com.swufe.user;

import java.sql.ResultSet;
import com.swufe.data.SQLServer;
import com.swufe.toolkit.PathUtil;

public class Perm {

    /**
     * 根据用户组获取权限代码
     *
     * @param 用户组ID
     * @return -字符分隔的字符串（NULL将替换为空值）
     */
    public static String getGroupPerm(int user_group_id) {
        SQLServer data = new SQLServer();
        ResultSet rs = null;
        String sql = "";
        String sRet = "";
        try {
            sql = " SELECT DISTINCT mi.code AS module_code ";
            sql += " FROM user_perm up INNER JOIN module_info mi ON up.module_id=mi.id ";
            sql += " WHERE up.user_group_id=" + user_group_id + " AND up.is_user_group=1 ";
            sql += "  and  mi.status=1 and  up.status=1 ";
            sql += " ORDER BY code ";
            rs = data.executeQuery(sql);
            while (rs.next()) {
                sRet = sRet + rs.getString("module_code") + "-";
            }
            rs.close();
        } catch (Exception e) {
        } finally {
            data.close();
        }
        return sRet;
    }

    /**
     * 根据用户ID获取权限代码列表
     *
     * @see getUserPerm(user_id,"code");
     * @param 用户ID
     * @return -字符分隔的字符串（NULL将替换为空值）
     */
    public static String getUserPerm(String user_id) {
        return getUserPerm(user_id, "code");
    }

    /**
     * 根据用户ID获取权限的指定属性列表
     *
     * @see getUserPerm(user_id, field, "-");
     * @param user_id
     * @param 模块属性
     * @return -字符分隔的字符串（NULL将替换为空值）
     */
    public static String getUserPerm(String user_id, String field) {
        return getUserPerm(user_id, field, "-");
    }

    /**
     * 根据用户ID获取权限的指定属性列表。包含is_public=1的通用权限模块，如果角色为系统管理员将返回所有已启用的模块。
     *
     * @param user_id
     * @param 模块属性
     * @param 分隔符
     * @return 分隔符分隔的字符串（NULL将替换为空值）
     */
    public static String getUserPerm(String user_id, String field, String sp) {
        SQLServer data = new SQLServer();
        ResultSet rs = null;
        String sql = "";
        String sRet = "";
        String str = "";
        int row = 0;
        String user_type_id = data.queryString("select user_type_id from user_info where user_id='" + user_id + "'");
        try {
            sql = " SELECT  distinct " + field + " AS str ";
            sql += " FROM module_info ";
            sql += " WHERE (id IN (";
            sql += "     SELECT DISTINCT module_id ";
            sql += "     FROM user_perm ";
            sql += "     WHERE user_id='" + user_id + "' OR user_group_id in(SELECT user_group_id FROM user_group_user WHERE user_id='" + user_id + "') ";
            sql += " ) ";
            sql += "  or  is_public=1 ";//通用权限模块
            if ("1".equals(user_type_id)) {
                sql += "  or  1=1 ";//系统管理员权限
            }
            sql += " ) ";
            sql += "  and status =1   and " + field + " is not null and " + field + " <>'' ";
            rs = data.executeQuery(sql);
            while (rs.next()) {
                str = rs.getString("str");
                if ("url".equals(field) && str.length() > 0) {
                    str = PathUtil.getFileBaseName(str);
                }
                sRet = sRet + (row == 0 ? "" : sp) + str;
                //sRet = sRet + str + sp;//2011-8-25修改，使用-分割，urldecode时减少容量，注意与hasPerm匹配
                row++;
            }
            rs.close();
        } catch (Exception e) {
        } finally {
            data.close();
        }
        return sRet;
    }
}
