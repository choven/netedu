package com.swufe.data;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import com.swufe.toolkit.StringUtil;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.json.JSONObject;

import javax.naming.Context;
import javax.naming.NamingException;
import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;

public class SQLServer {

    Connection conn = null;
    public String err = "";//抛出的异常错误
    /*
     * *
     * 构造函数。构造时不初始化。
     */

    public SQLServer() {
        //连接池的获取
        this.err = "";
    }

    /**
     * 初始化连接池。 注意1、配置项目中的META-INF/context.xml 数据源名与此保持一致。2、将JDBC驱动装入TOMCAT/LIB。
     */
    public void init() {
        err = "";
        try {
            if (conn == null) {
                Context context = new InitialContext();
                DataSource ds = (DataSource) context.lookup("java:comp/env/jdbc/sqlServer");
                conn = ds.getConnection();
            }
        } catch (NamingException e) {
            err = "数据源不存在 " + e.getMessage();
        } catch (SQLException ex) {
            err = "连接失败 " + ex.getMessage();
        }
    }

    /**
     * @param sql
     * @return
     * @throws SQLException
     */
    public String getPrepareStmt(String sql, String sPara) throws SQLException {
        init();
        String sRet = "";
        String aPara[] = sPara.split(",");
        PreparedStatement pStmt = conn.prepareStatement(sql);
        for (int i = 0; i < aPara.length; i++) {
            pStmt.setString(i + 1, aPara[i]);
        }
        if (pStmt.execute()) {
            sRet = pStmt.toString();
        }
        return sRet;
    }

    /**
     * 执行SQL查询.
     *
     * @param sql
     * @return 数据集ResultSet
     * @exception err+sql
     */
    public ResultSet executeQuery(String sql) {
        init();
        ResultSet rs = null;
        Statement stmt = null;
        try {
            stmt = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
            rs = stmt.executeQuery(sql);
        } catch (SQLException ex) {
            err = ex.toString().replaceAll("\"", " ") + sql;
        }
        return rs;

    }

    /**
     * 执行SQL更新.
     *
     * @param sql
     * @return 数据集ResultSet
     * @exception err+sql
     */
    public ResultSet executeQueryUpdatable(String sql) {
        init();
        ResultSet rs = null;
        Statement stmt = null;
        try {
            stmt = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
            rs = stmt.executeQuery(sql);
        } catch (SQLException ex) {
            err = ex.toString().replaceAll("\"", " ") + sql;
        }
        return rs;
    }

    /**
     * 执行SQL更新.
     *
     * @param sql
     * @return 记录数
     * @exception err+sql
     */
    public int executeUpdate(String sql) {
        init();
        int result = 0;
        Statement stmt = null;
        try {
            stmt = conn.createStatement();
            result = stmt.executeUpdate(sql);
        } catch (SQLException ex) {
            err = ex.toString().replaceAll("\"", " ");
        } finally {
            try {
                stmt.close();
            } catch (SQLException ex) {
            }
        }
        return result;
    }

    /**
     * 关闭连接
     */
    public void close() {
        if (conn != null) {
            try {
                conn.close();
                conn = null;
            } catch (SQLException e) {
            }
        }
    }

    /**
     * 返回单记录单字段的对象值.
     * <br/>如果是多字段或者多记录，将只返回第一个字段的第一条记录值。
     * <br/>如果是null值或者记录为空，返回NULL对象。
     *
     * @param sql
     * @return 该字段的值（OBJECT）
     * @exception err+sql
     */
    public Object queryObject(String sql) {
        Object sRet = null;
        try {
            ResultSet rs = executeQuery(sql);
            if (rs.next()) {
                sRet = rs.getObject(1);
                rs.close();
            }
        } catch (SQLException e) {
        }
        return sRet;
    }

    /**
     * 返回单记录单字段的查询值.
     * <br/>如果是多字段或者多记录，将只返回第一个字段的第一条记录值。
     * <br/>如果是null值，将返回空值。
     *
     * @see queryScalar()
     * @param sql
     * @return 该字段的值（字符型）
     * @exception err+sql
     */
    public String queryString(String sql) {
        return queryScalar(sql);
    }

    /**
     * 返回单记录单字段的查询值.
     * <br/>如果是多字段或者多记录，将只返回第一个字段的第一条记录值。
     * <br/>如果是null值，将返回空值。
     *
     * @param sql
     * @return 该字段的值（字符型）
     * @exception err+sql
     */
    public String queryScalar(String sql) {
        String sRet = "";
        try {
            ResultSet rs = executeQuery(sql);
            if (rs.next()) {
                sRet = rs.getString(1);
                rs.close();
            }

        } catch (SQLException e) {
        }
        if (sRet == null) {
            sRet = "";
        }
        return sRet;
    }

    /**
     * 将数据记录集转换为二维数组. 如果某项是null值，将转换为空值。如果记录为空或者抛出，返回空数组。
     *
     * @param sql
     * @return 二维数组
     * @exception err+sql
     */
    public String[][] queryArray(String sql) {
        ResultSet rs = null;
        try {
            rs = executeQuery(sql);
            if (rs == null) {
                return (String[][]) null;
            }
            int nColumnCount = rs.getMetaData().getColumnCount();
            // rs.last()
            // int nRowCount = rs.getRow();
            ArrayList list = new ArrayList();
            // List<Object> list = new ArrayList<Object>();
            for (int row = 0; rs.next(); row++) {
                List content = new ArrayList();
                for (int i = 1; i <= nColumnCount; i++) {
                    String sValue = rs.getString(i);
                    if (sValue == null) {
                        sValue = "";
                    }
                    content.add(sValue);
                }
                list.add(content);
            }
            String aResult[][] = new String[list.size()][nColumnCount];
            for (int i = 0; i < list.size(); i++) {
                // aResult[i] =(String[])list.toArray(); 
                //  aResult[i] = list.get(i).toArray(new String[list.get(i).size()]);   
                ArrayList tempArray = (ArrayList) list.get(i);
                aResult[i] = (String[]) tempArray.toArray(new String[tempArray.size()]);
            }
            rs.close();
            return aResult;
        } catch (Exception e) {
            return (String[][]) null;
        }
    }

    /**
     * 将数据记录集转换为二维数组格式的字符串. 如果某项是null值，将转换为空值。如果记录为空或者抛出，返回字符：[][]。
     *
     * @param sql
     * @return 字符串（二维数组格式）
     * @exception err+sql
     */
    public String queryArrayStr(String sql) {
        ResultSet rs = null;
        StringBuffer sb = new StringBuffer();
        sb.append("[");
        try {
            rs = executeQuery(sql);
            if (rs == null) {
                return "";
            }
            int nColumnCount = 1;
            ResultSetMetaData rsmd = rs.getMetaData();
            for (int row = 0; rs.next(); row++) {
                if (row > 0) {
                    sb.append(",[");
                } else {
                    sb.append("[");
                }
                nColumnCount = rsmd.getColumnCount();
                for (int i = 1; i <= nColumnCount; i++) {
                    if (i > 1) {
                        sb.append(",");
                    }
                    String sValue = rs.getString(i);
                    if (sValue == null) {
                        sValue = "";
                    }
                    // 需要按照类型进行处理
                    switch (rsmd.getColumnType(i)) {
                        case 12: // varchar
                        case 93: // smalldatetime datetime
                            sValue = "'" + sValue + "'";
                            break;
                    }
                    sb.append(sValue);
                }
                sb.append("]");
            }
            sb.append("]");
            rs.close();
        } catch (Exception e) {
            return "[][]";
        }
        return sb.toString();
    }

    /**
     * 将数据记录集转换为附加表头的二维数组格式的字符串. 如果某项是null值，将转换为空值。如果记录为空或者抛出，返回字符：[][]。
     * <br/>第一行为表头名（字段名）
     *
     * @param sql
     * @return 字符串（二维数组格式）
     * @exception err+sql
     */
    public String queryArrayStrCol(String sql) {
        ResultSet rs = null;
        StringBuffer sb = new StringBuffer();
        sb.append("[[");
        try {
            rs = executeQuery(sql);
            if (rs == null) {
                return "";
            }
            int nColumnCount = 1;
            ResultSetMetaData rsmd = rs.getMetaData();
            nColumnCount = rsmd.getColumnCount();
            for (int i = 1; i <= nColumnCount; i++) {
                if (i > 1) {
                    sb.append(",");
                }
                sb.append("'" + rsmd.getColumnName(i) + "'");
            }
            sb.append("],");
            for (int row = 0; rs.next(); row++) {

                if (row > 0) {
                    sb.append(",[");
                } else {
                    sb.append("[");
                }
                for (int i = 1; i <= nColumnCount; i++) {
                    if (i > 1) {
                        sb.append(",");
                    }
                    String sValue = rs.getString(i);
                    if (sValue == null) {
                        sValue = "";
                    }
                    // 需要按照类型进行处理
                    switch (rsmd.getColumnType(i)) {
                        case 12: // varchar
                        case 93: // smalldatetime datetime
                            sValue = "'" + sValue + "'";
                            break;
                    }
                    sb.append(sValue);
                }
                sb.append("]");
            }
            sb.append("]");
            rs.close();
        } catch (Exception e) {
            return "[][]";
        }
        return sb.toString();
    }

    /**
     * 执行SQL更新后返回JOSN格式字符
     *
     * @param sql
     * @return 字符串（JSON字符串）
     * {"success":true}||{"errors":"操作失败，错误代码为....","success":false}
     */
    public String updateJSON(String sql) {
        JSONObject json = new JSONObject();
        boolean bet = false;
        this.err = "";
        try {
            executeUpdate(sql);
            if (this.err.length() == 0) {
                bet = true;
            } else {
                json.put("errors", this.err + sql);
            }
            json.put("success", bet);
        } catch (Exception e) {
        }
        return json.toString();
    }

    /**
     * 将数据记录集转换为JSON格式的字符串. 如果字符类型的数据项是null值，将转换为空值。
     *
     * @see queryJSON(sql, "r", true)
     * @param sql
     * @return 字符串（JSON字符串）
     * @exception err+sql
     */
    public String queryJSON(String sql) {
        return queryJSON(sql, "list", true);
    }

    /**
     * 将数据记录集转换为JSON格式的字符串. 如果字符类型的数据项是null值，将转换为空值。
     *
     * @param sql
     * @param 数据集的根节点名称
     * @param 是否附加头数据（头数据中包含根节点位置，记录长度，ID标识等）
     * @return 字符串（JSON字符串）
     * @exception err+sql
     */
    public String queryJSON(String sql, String rootString, boolean metaDataBool) {
        String rootStr = "list";
        if (!"".equals(rootString)) {
            rootStr = rootString;
        }
        ResultSet rs = null;
        JSONObject json = new JSONObject();
        JSONObject metaJson = new JSONObject();
        JSONObject fieldsJson;
        JSONObject valueJson;
        try {
            rs = executeQuery(sql);
            if (rs != null) {
                ResultSetMetaData rsmd = rs.getMetaData();
                int nColumnCount = rsmd.getColumnCount();
                for (int i = 1; i <= nColumnCount; i++) {
                    fieldsJson = new JSONObject();
                    fieldsJson.put("name", rsmd.getColumnName(i));
                    metaJson.append("fields", fieldsJson);
                }
                int row;
                for (row = 0; rs.next(); row++) {
                    valueJson = new JSONObject();
                    for (int i = 1; i <= nColumnCount; i++) {
                        valueJson.put(rsmd.getColumnName(i), rs.getString(i) == null ? "" : rs.getObject(i));//字符型的类型替换NULL值，其他类型返回OBJECT
                    }
                    json.append(rootStr, valueJson);
                }
                if (row == 0) {
                    //json.put(rootStr, "");
                    json.put(rootStr, new JSONObject());
                }
                if (metaDataBool) {
                    // 输出元数据
                    metaJson.put("totalProperty", "count");
                    metaJson.put("id", rsmd.getColumnName(1));
                    metaJson.put("root", rootStr);
                    json.put("metaData", metaJson);
                    json.put("count", row);
                }
                rs.close();
            }

            if ("".equals(rootString)) {
                return json.getString(rootStr);
            }
            return json.toString();

        } catch (Exception e) {
            return e.toString() + err + ":" + sql;
        }
    }

    /**
     * 分页将数据记录集转换为JSON格式的字符串. 如果字符类型的数据项是null值，将转换为空值。
     *
     * @param sql
     * @param 排序字符串，形如 "order by id desc"
     * @param request  请求格式为EXT分页标准，包含参数start（起始数据数），limit（分页大小数）
     * @return 字符串（JSON字符串）
     * @exception err+sql
     */
    public String queryJSON(String sql, String strOrder, HttpServletRequest request) {
        String startStr = request.getParameter("start");
        String limitStr = request.getParameter("limit");
        int start = 0;
        int pageSize = 10;
        if (startStr != null) {
            start = Integer.parseInt(startStr);
        }
        if (limitStr != null) {
            pageSize = Integer.parseInt(limitStr);
        }
        int pageIndex = start / pageSize + 1;
        return queryJSON(sql, strOrder, pageIndex, pageSize);
    }

    /**
     * 分页将数据记录集转换为JSON格式的字符串. 如果字符类型的数据项是null值，将转换为空值。
     *
     * @param sql
     * @param 排序字符串，形如 "order by id desc"
     * @param 当前页码
     * @param 分页大小
     * @return 字符串（JSON字符串）
     * @exception err+sql
     */
    public String queryJSON(String sql, String strOrder, int pageIndex, int pageSize) {
        JSONObject json = null;
        try {
            Object n = queryObject("select count(1) from (" + sql + ") n ");
            StringBuilder sb = new StringBuilder();
            sb.append(" select TOP ").append(pageSize).append("  * from   ( ");
            sb.append("  select top  ").append(pageSize * pageIndex).append(" *, row_number()over( ").append(strOrder).append(" )as rn  from ( ").append(sql).append(") t1 )t2 ");
            sb.append("    where rn>'").append(pageSize * (pageIndex - 1)).append("' ");
            sb.append("  ORDER BY rn  ");
            json = new JSONObject(queryJSON(sb.toString()));
            json.put("count", n);
        } catch (Exception e) {
            return e.toString() + err + ":" + sql;
        }
        return json.toString();
    }

    /**
     * 得到用于构造树的JSON.。
     *
     * @param sql-
     * 注意SQL中必须包含id,parent_id,code,text4个字段。<br>Ext中自匹配checked,expanded,iconCls等字段，详见ExtTree
     * API。<br>需要取得布尔值，则需要在SQL中将字段转为BIT类型，比如cast(status as bit) as status
     * 。<br>如果SQL中指定了order by ，需要在前面加 TOP 100 PERCENT
     * @param 根节点ID值
     * @param 排序语句，形如order by id
     * @return Object
     * @exception err
     */
    public Object queryJSONTree(String sql, int rootId, String order) {
        String sql1 = "select  distinct parent_id from (" + sql + ")   AS tmp  where  parent_id <> '" + rootId + "' order by parent_id ";
        String sql2 = "select * from (" + sql + ")   AS tmp  where  parent_id= '" + rootId + "'  " + order;
        StringBuffer pidBuffer = new StringBuffer();
        ResultSet rs = null;
        Object resultObject = null;
        JSONObject json = new JSONObject();
        JSONObject valueJson;
        try {
            pidBuffer.append("|");
            rs = executeQuery(sql1);
            while (rs.next()) {
                pidBuffer.append(rs.getString(1));
                pidBuffer.append("|");
            }
            rs = executeQuery(sql2);
            if (rs != null) {
                ResultSetMetaData rsmd = rs.getMetaData();
                int nColumnCount = rsmd.getColumnCount();
                for (int row = 0; rs.next(); row++) {
                    valueJson = new JSONObject();
                    for (int i = 1; i <= nColumnCount; i++) {
                        valueJson.put(rsmd.getColumnName(i), rs.getString(i) == null ? "" : rs.getObject(i));//字符型的类型替换NULL值，其他类型返回OBJECT
                    }
                    if (pidBuffer.indexOf("|" + rs.getString("id") + "|") >= 0) {//有子节点
                        valueJson.put("children", queryJSONTree(sql, rs.getInt("id"), order));
                        valueJson.put("cls", "folder");
                        valueJson.put("leaf", false);
                    } else {
                        valueJson.put("cls", "file");
                        valueJson.put("leaf", true);
                    }
                    json.append("root", valueJson);
                }
                rs.close();
            }
            resultObject = json.get("root");

        } catch (Exception e) {
            return e.toString() + err + ":" + sql;
        }
        return resultObject;
    }

    /**
     * 根据SQL生成EXT的cm。需要显示的字段使用C_打头作为别名，如 select code as c_代码
     *
     * @param sql
     * @return cm
     * @throws Exception
     */
    public String getCMByDB(String sql) {
        try {
            ResultSet rs = null;
            List<Object> list = new ArrayList<Object>();
            list.add("new Ext.grid.RowNumberer({width:45})");
            list.add("new Ext.grid.CheckboxSelectionModel()");
            rs = executeQuery(sql);
            int nColumnCount = 1;
            ResultSetMetaData rsmd = rs.getMetaData();
            nColumnCount = rsmd.getColumnCount();
            for (int i = 1; i <= nColumnCount; i++) {
                if ("C_".equalsIgnoreCase(rsmd.getColumnName(i).substring(0, 2))) {
                    JSONObject obj = new JSONObject();
                    obj.put("header", rsmd.getColumnName(i).substring(2, rsmd.getColumnName(i).length()));
                    obj.put("dataIndex", rsmd.getColumnName(i));
                    obj.put("sortable", true);
                    list.add(obj);
                }
            }
            rs.close();
            return list.toString();
        } catch (Exception ex) {
            return err;
        }
    }

    /**
     * 根据指定的表和字段返回新的序列值.
     *
     * @see sequence(sTableName, sIdField, "");
     * @param sql
     * @param 表
     * @param 字段
     * @return 新的序列值（步长为1）
     * @exception err+sql
     */
    public String sequence(String sTableName, String sIdField) {
        return sequence(sTableName, sIdField, "");
    }

    /**
     * 取得有前缀规则的序列值.
     *
     * @see sequence(sTableName, sIdField, sPrefix, 0)
     * @param 表
     * @param 字段
     * @param 前缀规则字符串
     * @return 新的序列值（步长为1）
     * @exception err+sql
     */
    public String sequence(String sTableName, String sIdField, String sPrefix) {
        return sequence(sTableName, sIdField, sPrefix, 0);
    }

    /**
     * 取得固定长度的序列值.
     *
     * @see sequence(sTableName, sIdField, sPrefix, sLen, "1=1");
     * @param 表
     * @param 字段
     * @param 前缀规则字符串
     * @param 固定长度
     * @return 新的序列值（步长为1）
     * @exception err+sql
     */
    public String sequence(String sTableName, String sIdField, String sPrefix, int sLen) {
        return sequence(sTableName, sIdField, sPrefix, sLen, "1=1");
    }

    /**
     * 取得序列值. 如果固定长度>0，则以0补足序列值，返回固定长度的值
     *
     * @param 表
     * @param 字段
     * @param 前缀规则字符串
     * @param 固定长度
     * @param sql条件
     * @return 新的序列值（步长为1）
     * @exception err+sql
     */
    public String sequence(String sTableName, String sIdField, String sPrefix, int sLen, String filter) {
        String sRet = "";
        String sql = "";
        sql += "SELECT TOP 1 " + sIdField + " FROM " + sTableName + " ";
        sql += " WHERE " + filter;
        if (sPrefix.length() > 0) {
            sql += "     AND " + sIdField + " LIKE '" + sPrefix + "%' ";
            sql += " ORDER BY CAST(REPLACE(" + sIdField + ",'" + sPrefix + "','') AS INT) DESC ";
        } else {
            sql += " ORDER BY " + sIdField + " DESC ";
        }
        //System.out.println(sql);
        ResultSet rs = executeQuery(sql);
        try {
            if (rs != null && rs.next()) {
                if ("".equalsIgnoreCase(sPrefix)) {
                    sRet = Integer.toString(rs.getInt(sIdField) + 1);
                } else {
                    if (sLen > 0) {
                        sRet = sPrefix + StringUtil.lpad((Integer.parseInt(rs.getString(sIdField).substring(sPrefix.length())) + 1), sLen, "0");
                    } else {
                        sRet = sPrefix + Integer.toString(Integer.parseInt(rs.getString(sIdField).substring(sPrefix.length())) + 1);
                    }
                }
            } else {
                if ("".equalsIgnoreCase(sPrefix)) {
                    sRet = "1";
                } else {
                    if (sLen > 0) {
                        sRet = sPrefix + StringUtil.lpad(1, sLen, "0");
                    } else {
                        sRet = sPrefix + "1";
                    }
                }
            }
        } catch (SQLException e) {
            err = e.toString();
        }
        return sRet;
    }
    /**
     * @param args
     * @throws SQLException
     */
    /*
     public static void main(String[] args) {
     SQLServer Data = new SQLServer();
     try {
     // String sql = "select top 3 * from swufe_ems.dbo.xfz_plan_info ";
     String sql = "SELECT  top 3 id,parent_id,code,name as text,0 as checked,cast(status as bit) as status  FROM swufe_ems.dbo.module_info";
     //System.out.print(StringUtil.getArrayString(Data.queryArray(sql)[0]));
     System.out.print(Data.queryJSONTree(sql, -1));
     } catch (Exception e) {
     System.out.print(e.toString());
     System.out.print(Data.err);
     }
     }
     * */
}
