/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.swufe.data;

import javax.servlet.http.HttpServletRequest;

/**
 *
 * @author Administrator
 */
public class Config {
    public static String sContextPath = "/netedu";
    public static String appName = "综合管理系统";
    public static String appCode = "netedu";
    public static int appId = 19;
    public static String storageType = "cookie"; //seesion//database

    /**
     * 对应线路跳转WEB服务器的另外一个域。
     *
     * @param request
     * @return url,无法匹配则返回主域名(www.swufe-online.com)。
     */
    public static String getOtherWebHost(HttpServletRequest request) throws Exception {
        String s = "www.swufe-online.com";
        String[][] a = {
            {"10.10.3.3", "10.10.3.5"},
            {"www.swufe-online.com", "www1.swufe-online.com"}};
        for (int i = 0; i < a.length; i++) {
            for (int j = 0; j < a[i].length; j++) {
                if (request.getServerName().equals(a[i][j])) {
                    s = a[i][j == 0 ? j + 1 : 0];
                    return s;
                }
            }
        }
        return s;
    }

    public static String getFieldById(String field, String id, String[][] a) throws Exception {
        String s = "";
        int k = 0;
        for (int i = 0; i < a.length; i++) {
            for (int j = 0; j < a[i].length; j++) {
                if (k == 0 && field.equals(a[0][j])) {
                    s = a[2][j];
                    k = 1;
                }//先取第三个值电信线路作为默认，以防止计划外的URL访问时，配对不成功
                if (id.equals(a[i][0]) && field.equals(a[0][j])) {
                    s = a[i][j];
                }
            }
        }
        return s;
    }

    public static String[][] hostList() {
        String[][] a = {
            {"web", "admin", "file", "media"},
            {"10.10.3.3", "10.10.3.119", "10.10.3.120", "10.10.3.4"},
            {"www.swufe-online.com", "w1.swufe-online.com", "f1.swufe-online.com", "m1.swufe-online.com"},
            //{ "www.swufe-online.net","w1.swufe-online.com", "f1.swufe-online.com", "m1.swufe-online.com" }, 
            //{ "www2.swufe-online.com","w2.swufe-online.com", "f2.swufe-online.com", "m2.swufe-online.com" }, 
            {"www3.swufe-online.com", "w3.swufe-online.com", "f3.swufe-online.com", "m3.swufe-online.com"}};
        return a;
    }

    /**
     * 对应线路跳转各个业务服务器。
     *
     * @param request
     * @param 服务器类型 "web", "admin", "file", "media"
     * @return url,无法匹配则返回主线路
     */
    public static String getHost(HttpServletRequest request, String type) throws Exception {
        String[][] a = hostList();
        String url = getFieldById(type, request.getServerName(), a);
        return url;
    }
}
