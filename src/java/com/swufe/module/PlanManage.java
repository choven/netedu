package com.swufe.module;

import java.sql.ResultSet;
import com.swufe.data.SQLServer;
import com.swufe.toolkit.StringUtil;
import com.swufe.user.LoginModel;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class PlanManage {

    public String err = "";
    private String user_id = "";
    /*
     * *
     * 构造函数
     */

    public PlanManage(HttpServletRequest request, HttpServletResponse response) {
        LoginModel login = new LoginModel(request, response);
        this.user_id = login.getUserId();
    }
    /*
     * 记录操作日志
     */

    public void recordLog(String plan_id, String title) {
        SQLServer data = new SQLServer();
        String sql = "";
        sql = " insert into xfz_plan_log (plan_id,title, sql, op_user) values('" + plan_id + "','" + title + "','" + sql.replaceAll("'", "&#39;") + "','" + user_id + "') ";
        data.executeUpdate(sql);
        data.close();
    }

    /*
     * 删除计划:仅仅删除计划及计划内容。如果该计划有对象在使用，数据库的外键将导致删除失败。
     */
    public boolean delPlan(String plan_id) {
        SQLServer data = new SQLServer();
        String n = data.queryScalar("select  count(1) from xfz_plan_apply where plan_id='" + plan_id + "'");
        data.close();
        if ("".equals(n)) {
            return delPlan(plan_id, true);
        } else {
            return false;
        }
    }

    /*
     * 删除计划:删除计划及计划的所有应用。注意慎用， 一个计划可能有多个对象在应用，别误删了。
     */
    public boolean delPlan(String plan_id, boolean force) {
        SQLServer data = new SQLServer();
        boolean result = false;
        String sql = "";
        try {
            sql = " delete from xfz_plan_apply where plan_id=" + plan_id;
            sql += "  ;delete from xfz_plan_detail where plan_id=" + plan_id;
            sql += "   ;delete from xfz_plan_info where id=" + plan_id;
            data.executeUpdate(sql);
            if (data.err.length() == 0) {
                result = true;
                recordLog(plan_id, "删除计划");
            } else {
                err = data.err;
            }
        } catch (Exception e) {
            err = "delPlan:" + e.toString();
            result = false;
        } finally {
            data.close();
        }
        return result;
    }

    /*
     * 应用计划 注意保持数据库的null值
     */
    public boolean applyPlan(String plan_id, String apply_level, String major_code, String recruit_major_id, String class_no) {
        SQLServer data = new SQLServer();
        boolean result = false;
        String sql = "";
        try {
            sql = "  insert into[swufe_ems].[dbo].[xfz_plan_apply] (plan_id,apply_level,major_code,recruit_major_id,class_no,created_user) ";
            sql += "   values(" + plan_id + "," + apply_level + "," + major_code + "," + recruit_major_id + "," + class_no + ",'," + user_id + "')";
            data.executeUpdate(sql);
            if (data.err.length() == 0) {
                result = true;
                recordLog(plan_id, "应用计划");
            } else {
                err = data.err;
            }
        } catch (Exception e) {
            err = "applyPlan:" + e.toString();
            result = false;
        } finally {
            data.close();
        }
        return result;

    }

    /*
     * 复制计划：已知道源计划
     */
    public int copyPlan(String source_id, String title, String major_code) {
        SQLServer data = new SQLServer();
        int result = 0;
        String sql = "";
        try {
            String newid = data.sequence("xfz_plan_info", "id");
            sql = " insert into [swufe_ems].[dbo].[xfz_plan_info](id,xf_require_id,source_plan_id,title,base_major_code,is_pub,status,created_user) ";
            sql += " SELECT " + newid + ",xf_require_id,'" + source_id + "' as source_plan_id ";
            sql += "       ,'" + title + "'as title ";
            sql += "       ,'" + major_code + "' as base_major_code ";
            sql += "       ,0 as is_pub ";
            sql += "       ,1 as status ";
            sql += "       ,'" + user_id + "' ";
            sql += "   FROM [swufe_ems].[dbo].[xfz_plan_info] where id='" + source_id + " '";

            sql += "   ;insert into [swufe_ems].[dbo].[xfz_plan_detail]( plan_id, course_code, course_name, course_type_code, xq, xf, xs, exam_type, is_open, created_user) ";
            sql += "   select  " + newid + ", course_code, course_name, course_type_code, xq, xf, xs, exam_type, is_open, '" + user_id + "' from [swufe_ems].[dbo].[xfz_plan_detail] where plan_id=" + source_id + " ";
            sql += "   and is_open=1 ";

            data.executeUpdate(sql);
            if (data.err.length() == 0) {
                result = Integer.parseInt(newid);
                recordLog(newid, "复制计划");
            } else {
                err = data.err + sql;
            }
        } catch (Exception e) {
            err = "copyPlan:" + e.toString() + sql;
            result = 0;
        } finally {
            data.close();
        }
        return result;

    }

    /*
     * 导入计划：用于年级选课计划的设置。 source_level：源计划的级别，1是从培养方案导入，3是从上一个年级导入（注意形式）
     */
    public boolean importPlanNJ(String source_level_str, String recruit_major_id) {
        SQLServer data = new SQLServer();
        ResultSet rs = null;
        String sql = "";
        boolean result = false;
        int source_id = 0;
        String major_code = "";
        String title = "";
        try {
            int source_level = Integer.parseInt(source_level_str);
            switch (source_level) {
                case 1:// 从培养方案导入
                    sql = " select  top 1  pa.plan_id,rm.major_code ";
                    sql += " ,'【'+case rm.learning_type_code when '7' then '网教' else'成教' end+left(rm.batch_code,4)+case RIGHT(rm.batch_code,1)  when '9' then '秋' else'春' end+'】' ";
                    sql += " +'【' +case rm.learning_level_code when '1' then '高起本' when '2' then '专升本'else'专科' end +'】' ";
                    sql += " +rm.title+rm.major_direction+'选课计划'  as title ";

                    sql += " from  [swufe_ems].[dbo].xfz_plan_apply  pa ";
                    sql += " inner join [swufe_online].[dbo].recruit_major rm on  rm.major_code=pa.major_code ";
                    sql += "  where   rm.recruit_major_id='" + recruit_major_id + "' and pa.apply_level =1 ";
                    sql += "  order by pa.plan_id desc ";
                    rs = data.executeQuery(sql);
                    while (rs.next()) {
                        source_id = rs.getInt("plan_id");
                        major_code = rs.getString("major_code");
                        title = rs.getString("title");
                    }
                    break;
                case 3:// 从最近一个年级导入（注意形式）

                    sql = "   select top 1 pa.plan_id,rm.major_code";
                    sql += "   from [swufe_online].[dbo].recruit_major  rm ";
                    sql += "   left join [swufe_ems].[dbo].xfz_plan_apply   pa on pa.recruit_major_id=rm.recruit_major_id ";
                    sql += "    where exists( select major_code,learning_type_code from [swufe_online].[dbo].recruit_major ";
                    sql += " 		where  major_code=rm.major_code and learning_type_code=rm.learning_type_code and  recruit_major_id='" + recruit_major_id + "') ";
                    sql += "     and pa.plan_id is not null and pa.apply_level=3 and rm.recruit_major_id <>'" + recruit_major_id + "' ";
                    sql += "     order by rm.batch_code desc ";
                    rs = data.executeQuery(sql);
                    while (rs.next()) {
                        source_id = rs.getInt("plan_id");
                        major_code = rs.getString("major_code");
                        sql = " select '【'+case rm.learning_type_code when '7' then '网教' else'成教' end+left(rm.batch_code,4)+case RIGHT(rm.batch_code,1)  when '9' then '秋' else'春' end+'】' ";
                        sql += " +'【' +case rm.learning_level_code when '1' then '高起本' when '2' then '专升本'else'专科' end +'】' ";
                        sql += " +rm.title+rm.major_direction+'选课计划'  as title ";
                        sql += "   from [swufe_online].[dbo].recruit_major  rm where  recruit_major_id='" + recruit_major_id + "' ";
                        title = data.queryScalar(sql);
                    }
                    break;
            }
            if (source_id == 0) {// 前面没有取到计划
                err = "无法找到相关的计划！";
                return false;
            }
            int new_id = copyPlan("" + source_id, title, major_code);
            if (new_id == 0) {
                err = "复制计划失败:" + err;
                return false;
            }
            if (applyPlan("" + new_id, "3", major_code, recruit_major_id, "null") == false) {// 注意保持class_no的null值，是字符null而不是null;
                err = "应用计划失败:" + err;
                delPlan("" + source_id);// 注意删除刚复制的计划；
                return false;
            }
            result = true;
            if (rs != null) {
                rs.close();
            }

        } catch (Exception e) {
            err = "importPlanNJ:" + e.toString() + sql;
            result = false;
        } finally {
            data.close();

        }
        return result;

    }
    /*
     * 导入计划：用于年级选课计划的设置。 source_level：源计划的级别，1是从培养方案导入，3是从上一个年级导入（注意形式）
     */

    public boolean importPlanClass(String source_level_str, String class_no) {
        SQLServer data = new SQLServer();
        ResultSet rs = null;
        String sql = "";
        boolean result = false;
        int source_id = 0;
        String major_code = "";
        String recruit_major_id = "";
        String title = "";
        try {
            int source_level = Integer.parseInt(source_level_str);
            switch (source_level) {
                case 3:// 从年级教学计划导入
                    sql = " select  top 1  pa.plan_id,pa.major_code,pa.recruit_major_id,p.title,ci.class_name ";
                    sql += " from  [swufe_online].[dbo].class_info ci  ";
                    sql += " inner join  [swufe_ems].[dbo].xfz_plan_apply  pa  on pa.recruit_major_id=ci.recruit_major_id ";
                    sql += " inner join  [swufe_ems].[dbo].xfz_plan_info p  on p.id=pa.plan_id ";
                    sql += "  where   ci.class_no='" + class_no + "' and pa.apply_level =3 ";
                    sql += "  order by pa.plan_id desc ";//其实数据库设置了一个招生专业只能有一个计划，以防万一
                    rs = data.executeQuery(sql);
                    while (rs.next()) {
                        source_id = rs.getInt("plan_id");
                        major_code = rs.getString("major_code");
                        recruit_major_id = rs.getString("recruit_major_id");
                        title = rs.getString("title") + "【" + rs.getString("class_name") + "专用】";
                    }
                    break;
                case 5:// 从最近一个年级的班级中导入（站点,年纪，专业）

                    sql = " SELECT   pa.plan_id,pa.major_code,pa.recruit_major_id,p.title,left(ci.batch_code,4)+case RIGHT(ci.batch_code,1)  when '9' then '秋' else'春' end as  batch_title";
                    sql += "   FROM [swufe_online].[dbo].[class_info] ci ";
                    sql += "    left join [swufe_ems].[dbo].xfz_plan_apply   pa on pa.class_no=ci.class_no ";
                    sql += "    inner join  [swufe_ems].[dbo].xfz_plan_info p  on p.id=pa.plan_id ";
                    sql += "   where  exists(select class_no from [swufe_online].[dbo].[class_info] ";
                    sql += " 		where RIGHT(class_no,3)=RIGHT(ci.class_no,3) and sub_site_code=ci.sub_site_code and  class_no='" + class_no + "') ";
                    sql += " 		 and pa.plan_id is not null and pa.apply_level=5 and ci.class_no <>'" + class_no + "' ";
                    sql += "   order by ci.batch_code desc ";
                    rs = data.executeQuery(sql);
                    while (rs.next()) {
                        source_id = rs.getInt("plan_id");
                        major_code = rs.getString("major_code");
                        String batch1 = rs.getString("batch_title");
                        String batch2 = data.queryScalar("select left(batch_code,4)+case RIGHT(batch_code,1)  when '9' then '秋' else'春' end  from [swufe_online].[dbo].[class_info]  where class_no='" + class_no + "'");
                        title = rs.getString("title").replace(batch1, batch2);
                    }
                    break;
            }
            if (source_id == 0) {// 前面没有取到计划
                err = "无法找到相关的计划！";
                return false;
            }
            int new_id = copyPlan("" + source_id, title, major_code);
            if (new_id == 0) {
                err = "复制计划失败:" + err;
                return false;
            }
            if (applyPlan("" + new_id, "5", major_code, recruit_major_id, class_no) == false) {// 注意保持class_no的null值，是字符null而不是null;
                err = "应用计划失败:" + err;
                delPlan("" + source_id);// 注意删除刚复制的计划；
                return false;
            }
            result = true;
            if (rs != null) {
                rs.close();
            }

        } catch (Exception e) {
            err = "importPlanNJ:" + e.toString() + sql;
            result = false;
        } finally {
            data.close();
        }
        return result;

    }
}
