package com.swufe.user;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.swufe.data.Config;
import com.swufe.data.SQLServer;
import com.swufe.toolkit.PathUtil;
import com.swufe.toolkit.StringUtil;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.sql.ResultSet;
import org.apache.commons.codec.binary.Base64;

public class LoginModel {

    private HttpServletRequest req;
    private HttpServletResponse res;
    public String err;

    /**
     * 构造LoginModel
     *
     * @param request
     * @param response
     */
    public LoginModel(HttpServletRequest request, HttpServletResponse response) {
        this.req = request;
        this.res = response;
        this.err = "";
    }

    /**
     * 账户登陆。保存的全局变量包括：user_id,login_name,user_name,user_type_id,site_code。<br>使用cookie保存user_setting。<br>如果开启cookie模式，还将保存用户的权限模块对应的URL到cookie的modUrl对象。
     *
     * @param 用户名
     * @param 密码
     */
    public boolean login(String login_name, String pwd) {
        SQLServer data = new SQLServer();
        boolean result = false;
        //String login_name = StringUtil.nullValue(req.getParameter("uid"));
        //String pwd = StringUtil.nullValue(req.getParameter("pwd"));
        try {
            String sql = " SELECT   ui.user_id,ui.user_name, ui.pwd,ui.user_setting,ui.user_type_id,ui.site_code,ui.status";
            sql += " FROM  user_info ui  ";
            sql += " WHERE ui.login_name='" + login_name + "'  ";
            ResultSet rs = data.executeQuery(sql);
            if (!rs.next()) {
                err = "该账户不存在！";
                return false;
            }
            if (!pwd.equals(rs.getString("pwd"))) {
                err = "密码错误！";
                return false;
            }
            if (rs.getInt("status") != 1) {
                err = "该账户被禁用！";
                return false;
            }
            setSession("user_id", rs.getString("user_id"));
            setValue("user_id", rs.getString("user_id"));
            setValue("login_name", login_name);
            setValue("user_name", rs.getString("user_name"));
            setValue("user_type_id", rs.getString("user_type_id"));
            setValue("site_code", rs.getString("site_code"));
            setCookie("user_setting", rs.getString("user_setting"));
            if ("cookie".equalsIgnoreCase(Config.storageType)) {
                setCookie("modUrl", Perm.getUserPerm(rs.getString("user_id"), "url"));//将权限的URL（getFileBaseName）列表写入cookie,
            }
            result = true;
            addLoginLog(rs.getString("user_id"), rs.getString("user_name"));
        } catch (Exception e) {
            err = e.toString();
            result = false;
        } finally {
            data.close();
            return result;
        }
    }

    /**
     * 设置加密的全局对象值。根据config中的设置，判定是使用cookie还是session来保存对象值。
     *
     * @param 对象名
     * @param 对象值
     */
    public void setValue(String sKey, String sValue) {
        if (sValue == null || "null".equals(sValue)) {
            sValue = "";
        }
        try {
            sValue = new String(Base64.encodeBase64(sValue.getBytes()));
        } catch (Exception ex) {
        }
        if ("cookie".equalsIgnoreCase(Config.storageType)) {
            setCookie(sKey, sValue);
        } else {
            setSession(sKey, sValue);
        }
    }

    /**
     * 根据对象名，获取全局对象值并解密。
     *
     * @param 对象名
     * @return 对象值（字符型）
     * @exception 空值（不是NULL）
     */
    public String getValue(String sKey) {
        String sValue = "";
        if ("cookie".equalsIgnoreCase(Config.storageType)) {
            sValue = getCookie(sKey);
        } else {
            sValue = getSession(sKey);
        }
        try {
            sValue = new String(Base64.decodeBase64(sValue));

        } catch (Exception ex) {
        }
        return sValue;
    }

    /**
     * 获取用户的系统账户
     *
     * @return user_id 作为主要的全局变量，该值使用session保存。
     * @exception 空值（不是NULL）
     */
    public String getUserId() {
        return getSession("user_id");
    }

    /**
     * 获取用户登录账号
     *
     * @return login_id
     * @exception 空值（不是NULL）
     */
    public String getLoginId() {
        return getValue("login_id");
    }

    /**
     * 获取用户姓名
     *
     * @return user_name
     * @exception 空值（不是NULL）
     */
    public String getUserName() {
        return getValue("user_name");
    }

    /**
     * 获取用户类型（角色）ID
     *
     * @return user_type_id
     * @exception 空值（不是NULL）
     */
    public String getUserTypeId() {
        return getValue("user_type_id");
    }

    /**
     * 设置cookie值，生命周期为关闭浏览器
     *
     * @param 对象名
     * @param 对象值
     */
    public void setCookie(String sKey, String sValue) {
        //int n = 60 * 60 * 24 * 30;
        setCookie(sKey, sValue, 0);
    }

    /**
     * 设置cookie值
     *
     * @param 对象名
     * @param 对象值
     * @param 生命周期（单位为秒）
     */
    public void setCookie(String sKey, String sValue, int nLifeCly) {
        // sValue = PathUtil.encodeURL(sValue);
        try {
            sValue = URLEncoder.encode(sValue, "UTF-8");
        } catch (Exception e) {
        }
        Cookie cookie = new Cookie(sKey, sValue);
        cookie.setPath(Config.sContextPath);
        if (nLifeCly > 0) {
            cookie.setMaxAge(nLifeCly);
        }
        this.res.addCookie(cookie);
    }

    /**
     * 设置Session值
     *
     * @param 对象名
     * @param 对象值
     */
    public void setSession(String sKey, String sValue) {
        HttpSession session = this.req.getSession(true);
        session.setAttribute(sKey, sValue);
    }

    /**
     * 根据对象名，获取Cookie对象值。
     *
     * @param 对象名
     * @return 对象值 如果为null，将返回空值
     */
    public String getCookie(String sKey) {
        String sValue = "";
        try {
            Cookie[] cookies = this.req.getCookies();
            int l = (cookies == null) ? 0 : cookies.length;
            for (int i = 0; i < l; ++i) {
                if (cookies[i].getName().equalsIgnoreCase(sKey)) {
                    // sValue = PathUtil.decodeURL(cookies[i].getValue());
                    sValue = cookies[i].getValue();
                    if (sValue == null) {
                        sValue = "";
                    }
                    sValue = URLDecoder.decode(sValue, "UTF-8");
                    return sValue;//直接跳出
                }
            }
        } catch (Exception e) {
        }
        return sValue;
    }

    /**
     * 根据对象名，获取Session对象值。
     *
     * @param 对象名
     * @return 对象值 如果为null，将返回空值
     */
    public String getSession(String sKey) {
        HttpSession session = this.req.getSession(true);
        String sValue = (String) session.getAttribute(sKey);
        if (sValue == null) {
            sValue = "";
        }
        return sValue;
    }

    /**
     * 获取客户端的 IP 地址
     *
     * @return 10.10.3.1 如果为null，将返回空值
     */
    public String getIpAddr() {
        String ip = this.req.getHeader("x-forwarded-for");
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = this.req.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = this.req.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = this.req.getRemoteAddr();
        }
        if (ip == null) {
            ip = "";
        }
        return ip;
    }

    /**
     * 获取参数列表
     *
     * @return
     */
    public String getParaValues() {
        StringBuffer sb = new StringBuffer();
        java.util.Enumeration params = this.req.getParameterNames();
        int m = 0;
        while (params.hasMoreElements()) {
            m++;
            if (m > 1) {
                sb.append("&");
            }
            // Get the next parameter name.
            String paramName = (String) params.nextElement();
            // Use getParameterValues in case there are multiple values.
            String paramValues[] = this.req.getParameterValues(paramName);
            // If there is only one value, print it out.
            if (paramValues.length == 1) {
                sb.append(paramName + "=" + paramValues[0]);
            } else {
                // For multiple values, loop through them.
                sb.append(paramName + "=");
                for (int i = 0; i < paramValues.length; i++) {
                    // If this isn't the first value, print a comma to separate
                    // values.
                    if (i > 0) {
                        sb.append(',');
                    }
                    sb.append(paramValues[i]);
                }
            }
        }
        return sb.toString();
    }

    /**
     * 记录登录日志
     *
     * @param user_id
     * @param user_name
     */
    public void addLoginLog(String user_id, String user_name) {
        SQLServer data = new SQLServer();
        try {
            HttpSession session = this.req.getSession(true);
            String request_url = this.req.getHeader("Referer");
            String sql = " INSERT INTO  login_log (SessionID, user_id, user_name, request_url, in_time) ";
            sql += " VALUES ('" + session.getId() + "', '" + user_id + "', '" + user_name + "', '" + request_url + "', getdate() ) ";
            sql += " ;UPDATE  user_info SET online_flag=1, uTimes=uTimes+1, last_login=getDate() WHERE user_id='" + user_id + "' ";
            data.executeUpdate(sql);
        } catch (Exception e) {
        } finally {
            data.close();
        }
    }

    /**
     * 记录页面访问日志
     *
     */
    public void addPageLog() {
        SQLServer data = new SQLServer();
        try {
            // String url = this.req.getRequestURL().toString();
            String url = req.getScheme() + "://" + req.getHeader("host") + req.getRequestURI();
            if (req.getQueryString() != null) {
                url += "?" + req.getQueryString();
            }
            String referer_url = this.req.getHeader("Referer");
            String user_agent = this.req.getHeader("User-Agent");
            String sql = " INSERT INTO  page_click_log ( user_id, user_name, user_agent,url,referer_url, ip) ";
            sql += " VALUES ( '" + getUserId() + "', '" + getUserName() + "', '" + user_agent + "', '" + url + "' , '" + referer_url + "', '" + getIpAddr() + "') ";
            data.executeUpdate(sql);
        } catch (Exception e) {
        } finally {
            data.close();
        }
    }

    /**
     * 刷新在线状态
     */
    public void refreshOnlineFlag() {
        SQLServer data = new SQLServer();
        try {
            HttpSession session = req.getSession(true);
            String sql = " UPDATE  login_log SET out_time=getDate() WHERE SessionID ='" + session.getId() + "' ";
            sql += " ;UPDATE  user_info SET last_logout=getDate() WHERE user_id='" + getUserId() + "' ";
            sql += " ;UPDATE user_info  SET online_flag=0 where online_flag=1 ";
            sql += " ;UPDATE user_info  SET online_flag=1 WHERE user_id IN (SELECT user_id FROM  login_log WHERE DATEDIFF(s, GETDATE(), out_time)>-60*15) ";
            data.executeUpdate(sql);
        } catch (Exception e) {
        } finally {
            data.close();
        }
    }

    /**
     * 根据指定模块代码，判断当前用户是否拥有权限，并记录日志。 如果用户类型（角色）为系统管理员，返回true值。
     *
     * @param 模块代码代码
     * @return true or false
     */
    public boolean hasPerm(String sPermCode) {
        addPageLog();
        if ("1".equals(getUserTypeId())) {
            // return true;
        }
        String sPermList = Perm.getUserPerm(getUserId());
        return ("-" + sPermList).toUpperCase().indexOf("-" + sPermCode.toUpperCase()) != -1;
    }

    /**
     * 根据当前页面名称，判断当前用户是否拥有权限，并记录日志。 如果用户类型（角色）为系统管理员，返回true值
     *
     * @return true or false
     */
    public boolean hasUrlPerm() {
        return hasUrlPerm(PathUtil.getFileBaseName(this.req.getRequestURL().toString()));
    }

    /**
     * 根据指定的页面名称，判断当前用户是否拥有权限，并记录日志。 如果用户类型（角色）为系统管理员，返回true值
     *
     * @param 页面名称，不含后缀名。比如user_manage,而不是user_manage.jsp
     * @return true or false
     */
    public boolean hasUrlPerm(String pageName) {
        addPageLog();
        if ("1".equals(getUserTypeId())) {
            // return true;
        }
        String sPermList = "cookie".equalsIgnoreCase(Config.storageType) ? getCookie("modUrl") : Perm.getUserPerm(getUserId(), "url");
        //sPermList=getCookie("modUrl");  //使用cookie验证
        // sPermList =Perm.getUserPerm(getUserId(),"url");//使用数据库查询验证
        if (sPermList == null || "".equals(sPermList) || "".equals(pageName)) {
            return false;
        } else {
            return ("-" + sPermList).indexOf("-" + pageName) != -1;
        }
    }
}
