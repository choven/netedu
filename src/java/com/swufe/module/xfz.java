package com.swufe.module;

import java.sql.ResultSet;
import java.sql.SQLException;
import com.swufe.data.SQLServer;
import com.swufe.toolkit.StringUtil;

import org.json.JSONObject;

public class xfz {

    public static String err = "";

    /*
     * 学期数据是按照不同学习形式不同年级分开开学的，这里的当前学期实际上取的已经开学的最大学期值。 return：201309
     */
    public static String getCurrTermCode() {

        SQLServer data = new SQLServer();
        return data.queryScalar("SELECT  MAX(term_code)FROM [swufe_ems].[dbo].[xfz_term_info]  where is_curr =1 and is_max=0");
    }

    /*
     * 根据学期代码清理学期课程表：这里面包含了整体的年级教学计划+自主教学计划。所以可能包含自主教学课程。
     */
    public static void syncTermCourse(String term_code) {
        SQLServer data = new SQLServer();
        String sql = "";
        sql = " with t as ( ";
        sql += " SELECT ti.term_code,pd.course_code,MAX(pd.course_name) as course_name from swufe_online.dbo.recruit_major rm ";
        sql += " inner join [swufe_ems].[dbo].[xfz_term_info]  ti on  ti.term_code='" + term_code + "' and ti.batch_code=rm.batch_code and ti.learning_type_code=rm.learning_type_code ";
        sql += " inner join  swufe_ems.dbo.xfz_plan_apply  pa on pa.recruit_major_id=rm.recruit_major_id and apply_level in(3,5) ";
        sql += " inner join  swufe_ems.dbo.xfz_plan_info  p on p.id=pa.plan_id and p.is_pub=1 ";
        sql += " inner join swufe_ems.dbo.xfz_plan_detail pd on pd.plan_id=pa.plan_id and  (pd.xq=ti.xq or (pd.xq=0 and ti.xq>1) ) and is_open=1  ";
        sql += " group by pd.course_code,ti.term_code ";
        sql += " ) ";
        sql += " insert into [swufe_ems].[dbo].[xfz_term_course] (term_code,course_code,course_name) ";
        sql += " select term_code,course_code,course_name from t where not exists( select * from [swufe_ems].[dbo].[xfz_term_course]  where term_code=t.term_code and course_code=t.course_code) ";
        data.executeUpdate(sql);
        // 删除多余的数据
        sql = " with t as ( ";
        sql += " SELECT ti.term_code,pd.course_code,MAX(pd.course_name) as course_name from swufe_online.dbo.recruit_major rm ";
        sql += " inner join [swufe_ems].[dbo].[xfz_term_info]  ti on  ti.term_code='" + term_code + "' and ti.batch_code=rm.batch_code and ti.learning_type_code=rm.learning_type_code ";
        sql += " inner join  swufe_ems.dbo.xfz_plan_apply  pa on pa.recruit_major_id=rm.recruit_major_id and apply_level in(3,5) ";
        sql += " inner join  swufe_ems.dbo.xfz_plan_info  p on p.id=pa.plan_id and p.is_pub=1 ";
        sql += " inner join swufe_ems.dbo.xfz_plan_detail pd on pd.plan_id=pa.plan_id and  (pd.xq=ti.xq or (pd.xq=0 and ti.xq>1) ) and is_open=1 ";
        sql += " group by pd.course_code,ti.term_code ";
        sql += " ) ";
        sql += " delete [swufe_ems].[dbo].[xfz_term_course] from [swufe_ems].[dbo].[xfz_term_course] tc   where  not exists( select * from  t  where term_code=tc.term_code and course_code=tc.course_code) and term_code='" + term_code + "' ";
        data.executeUpdate(sql);
        data.close();
    }

    /*
     * 校验教学计划的合理性 参数：以逗号分隔的计划代号，如10001或者10001,10002 返回：true or false ;如果为false,则附加错误xfz.err 检查内容：1、是否设置了培养要求，2、是否满足培养要求，3、必修课是否设置了学期、选修课学期是否为0,4、选修课是否全部为考查课程。
     */
    public static boolean validatePlan(String plan_id) {
        SQLServer data = new SQLServer();
        String sql = "";
        ResultSet rs = null;
        boolean result = false;
        try {
            sql = " SELECT p.id  as plan_id,xf.[course_type_code] ,ct.title as course_type_name ,xf.is_optional ";
            sql += "  ,SUM(case when xf.is_optional=1 and pd.course_type_code=xf.course_type_code and pd.exam_type<>2 then 1 else 0 end) as exam_err ";
            sql += "  ,SUM(case when  pd.course_type_code=xf.course_type_code and ((xf.is_optional=1 and pd.xq<>0 ) or(xf.is_optional=0 and pd.xq=0))then 1 else 0 end) as xq_err ";
            sql += "  ,xf.min_xf as xf_need ";
            sql += "  ,SUM(case when pd.course_type_code=xf.course_type_code then xf else 0 end) as xf_has ";
            sql += "  FROM [swufe_ems].[dbo].[xfz_plan_info] p ";
            sql += "  inner join [swufe_ems].[dbo].[xfz_xf_require_detail] xf on xf.require_id=p.xf_require_id ";
            sql += "  inner join [swufe_ems].[dbo].[xfz_course_type] ct on ct.code=xf.course_type_code ";
            sql += "  left  join [swufe_ems].[dbo].[xfz_plan_detail] pd on pd.plan_id=p.id ";
            sql += "  where p.id in ( " + plan_id + ") ";
            sql += "  and pd.is_open=1 group by p.id,xf.course_type_code,ct.title,xf.is_optional,xf.min_xf ,p.xf_require_id ";
            rs = data.executeQuery(sql);
            if (rs.next()) {
                do {
                    if (rs.getInt("xf_has") < rs.getInt("xf_need")) {
                        result = false;
                        err = "编号为" + plan_id + "的计划中，" + rs.getString("course_type_name") + "学分不足。";
                        return result;
                    }
                    if (rs.getInt("xq_err") > 0) {//
                        result = false;
                        err = "编号为" + plan_id + "的计划中，学期设置有误！选修课程请勿设置学期，必修课程请指定学期。";
                        return result;
                    }
                    if (rs.getInt("exam_err") > 0) {//
                        result = false;
                        err = "编号为" + plan_id + "的计划中，考试设置有误！选修课程请设置为考核。";
                        return result;
                    }
                    result = true;
                } while (rs.next());
            } else {
                err = "编号为" + plan_id + "的计划中，无培养要求。";
                result = false;
            }
            rs.close();
        } catch (Exception e) {
            err = e.toString() + sql;
            result = false;
        } finally {
            data.close();

        }
        return result;
    }
}
