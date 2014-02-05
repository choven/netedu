package com.swufe.toolkit;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.Random;
import java.util.Vector;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.json.JSONObject;

public final class StringUtil {

    /**
     * 产生一个随机数
     */
    public static Random random = new Random(System.currentTimeMillis());

    /**
     *
     */
    public StringUtil() {
    }

    /**
     * 判断字符串是否全为字母
     *
     * @param str
     * @return
     */
    public static boolean isLetters(String str) {
        return str.matches("[[a-z]|[A-Z]]*");
    }

    /**
     * @param str
     * @return
     */
    public static boolean isNumeric(String str) {
        if (str == null) {
            return false;
        }
        if (str.length() == 0) {
            return false;
        }
        try {
            Double.parseDouble(str);
        } catch (Exception e) {
            return false;
        }
        return true;
    }

    /**
     * @param str
     * @return
     */
    public static boolean isInt(String str) {
        return str != null && str.indexOf('.') == -1 && isNumeric(str) && str.length() <= 10;
    }

    /**
     * @param str
     * @return
     */
    public static boolean isLong(String str) {
        return str != null && str.indexOf('.') == -1 && isNumeric(str);
    }

    /**
     * @param obj
     * @return
     */
    public static String nullValue(Object obj) {
        return nullValue(obj, "");
    }

    /**
     * @param obj
     * @param sDefault
     * @return
     */
    public static String nullValue(Object obj, String sDefault) {
        if (obj == null) {
            return sDefault;
        }
        String sRet = obj.toString();
        if (sRet.length() == 0) {
            return sDefault;
        } else {
            return sRet;
        }
    }

    /**
     * @param s
     * @param sDefault
     * @return
     */
    public static String nullValue(String s, String sDefault) {
        return nullValue(s, sDefault, true);
    }

    /**
     * @param s
     * @param sDefault
     * @param checkSQL
     * @return
     */
    public static String nullValue(String s, String sDefault, boolean checkSQL) {
        if (s == null || s.length() == 0) {
            return sDefault;
        }
        s = s.replaceAll("'", "\"");
        s = s.replaceAll("xp_", "xp-");
        s = s.replaceAll("--", "__");
        if (!checkSQL) {
            return s;
        }
        String s2 = s.toLowerCase();
        String key = "exec|insert|select|delete|update|master|truncate|drop|declare";
        String k[] = split(key, "|");
        for (int i = 0; i < k.length; i++) {
            if (s2.indexOf(k[i]) >= 0) {
                return "sql hack";
            }
        }
        return s;
    }

    /**
     * @param str
     * @param pattern
     * @return
     */
    public static String[] split(String str, String pattern) {
        if (str == null) {
            str = "";
        }
        Vector<String> strset = new Vector<String>();
        int s = 0;
        for (int e = 0; (e = str.indexOf(pattern, s)) >= 0;) {
            strset.addElement(str.substring(s, e));
            s = e + pattern.length();
        }
        if (s != str.length()) {
            strset.addElement(str.substring(s, str.length()));
        } else if (s == 0) {
            strset.addElement("");
        } else {
            strset.addElement("");
        }
        int len = strset.size();
        String result[] = new String[len];
        for (int i = 0; i < len; i++) {
            result[i] = (String) strset.elementAt(i);
        }
        return result;
    }

    /**
     * @param str
     * @param sPattern
     * @param sReplaceBy
     * @return
     */
    public static final String replace(String str, String sPattern, String sReplaceBy) {
        if (str == null) {
            return "";
        }
        int s = 0;
        int e = 0;
        StringBuffer bufRet = new StringBuffer();
        while ((e = str.indexOf(sPattern, s)) >= 0) {
            bufRet.append(str.substring(s, e));
            bufRet.append(sReplaceBy);
            s = e + sPattern.length();
        }
        bufRet.append(str.substring(s));
        return bufRet.toString();
    }

    public static final String lpad(int ns, char c, int len) {
        return lpad(ns, c, len);
    }

    /**
     * @param s
     * @param c
     * @param len
     * @return
     */
    public static final String lpad(String s, char c, int len) {
        String sRet;
        for (sRet = s; sRet.length() < len; sRet = c + sRet) {
            ;
        }
        return sRet;
    }

    /**
     * 调用：lpad(12, 5, "0")
     *
     * @param s
     * @param len
     * @param c
     * @return
     */
    public static final String lpad(int s, int len, String c) {
        return lpad(Integer.toString(s), len, c);
    }

    /**
     * 调用：lpad("12", 5, "0")
     *
     * @param s
     * @param len
     * @param c
     * @return
     */
    public static final String lpad(String s, int len, String c) {
        String sRet;
        if (c.equals("")) {
            c = " ";
        }
        while (s.length() < len) {
            s = c + s;
        }
        sRet = s;
        return sRet;
    }

    /**
     * @param s
     * @param c
     * @param len
     * @return
     */
    public static final String rpad(String s, char c, int len) {
        String sRet;
        for (sRet = s; sRet.length() < len; sRet = sRet + c) {
            ;
        }
        return sRet;
    }

    /**
     * @param str
     * @return
     */
    public static final int getBitLength(String str) {
        int nRet = 0;
        for (int i = 0; i < str.length(); i++) {
            char c = str.charAt(i);
            if (c > 0 && c < '\200') {
                nRet++;
            } else {
                nRet += 2;
            }
        }
        return nRet;
    }

    /**
     * @param nLen
     * @return
     */
    public static final String randomString(int nLen) {
        return randomString(nLen, "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ");
    }

    /**
     * @param nLen
     * @param sAvailChar
     * @return
     */
    public static final String randomString(int nLen, String sAvailChar) {
        char numbersAndLetters[] = sAvailChar.toCharArray();
        if (nLen < 1) {
            return null;
        }
        char randBuffer[] = new char[nLen];
        for (int i = 0; i < randBuffer.length; i++) {
            randBuffer[i] = numbersAndLetters[random.nextInt(numbersAndLetters.length - 1)];
        }
        return new String(randBuffer);
    }

    /**
     * 去除指定字符串中的所有中英文小括号
     *
     * @param s
     * @return
     */
    public static String wipeOffBracket(String s) {
        try {
            String tmpStr = s;
            tmpStr = tmpStr.replace("(", "");
            tmpStr = tmpStr.replace(")", "");
            tmpStr = tmpStr.replace("（", "");
            tmpStr = tmpStr.replace("）", "");
            return tmpStr;
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * @param s
     * @return
     */
    public static String escapeHTML(String s) {
        s = s.replaceAll("&", "&amp;");
        s = s.replaceAll("<", "&lt;");
        s = s.replaceAll(">", "&gt;");
        s = s.replaceAll("\"", "&quot;");
        s = s.replaceAll("'", "&apos;");
        s = s.replaceAll("\n", "<br>");
        s = s.replaceAll("\r", "");
        return s;
    }

    /**
     * @param s
     * @return
     */
    public static String unescapeHTML(String s) {
        s = s.replaceAll("&amp;", "&");
        s = s.replaceAll("&lt;", "<");
        s = s.replaceAll("&gt;", ">");
        s = s.replaceAll("&quot;", "\"");
        s = s.replaceAll("&apos;", "'");
        return s;
    }

    /**
     * @param s
     * @return
     */
    public static String escapeHTML2(String s) {
        if (s != null) {
            s = s.replaceAll("&", "&amp;");
            s = s.replaceAll("\"", "&quot;");
            s = s.replaceAll("'", "&#39;");
            s = s.replaceAll(",", "&#44;");
            s = s.replaceAll("%", "&#37;");
            s = s.replaceAll("\n", "");
            s = s.replaceAll("\r", "");
            // s = s.replaceAll("\r\n", "<br>");
        } else {
            s = "";
        }
        return s;
    }

    /**
     * 利用正则表达式去除html标记
     *
     * @param strHtml
     * @return
     */
    public static String StripHTML(String strHtml) {
        String strOutput = strHtml;
        String regEx = "<[^>]+>|</[^>]+>";
        Pattern p = Pattern.compile(regEx);
        Matcher m = p.matcher(strOutput);
        strOutput = m.replaceAll("");
        return strOutput;
    }

    /**
     * 删除字符串中的html格式
     *
     * 2010-05-11
     *
     * @param strHtml
     * @param length
     * @return
     */
    public static String stripTags(String strHtml) {
        return stripTags(strHtml, 0);
    }

    public static String stripTags(String strHtml, int length) {
        if (strHtml == null || strHtml.trim().equals("")) {
            return "";
        }
        // 去掉所有html元素,
        String str = strHtml.replaceAll("\\&[a-zA-Z]{1,10};", "").replaceAll("<[^>]*>", "");
        str = str.replaceAll("[(/>)<]", "");
        int len = str.length();
        if (len <= length) {
            return str;
        } else {
            if (length > 0) {
                str = str.substring(0, length);
                str += "......";
            }
        }
        return str;
    }

    /**
     * 对双引号进行转义 " \"
     *
     * @param str
     * @return
     */
    public static String transferredQuotation(String str) {
        String sRet = "";
        str = str.replaceAll("\"", "\\\"");
        sRet = str;
        return sRet;
    }

    // 按照指定字符折分
    /**
     * @param strStns
     * @param splitStr
     * @return
     */
    public static Vector<String> splitV(String strStns, String splitStr) {
        if (strStns.equals(null)) {
            return null;
        }
        Vector<String> vSplit = new Vector<String>();
        while (strStns.indexOf(splitStr) > 0) {
            vSplit.addElement(new String(strStns.substring(0, strStns.indexOf(splitStr))));
            strStns = strStns.substring(strStns.indexOf(splitStr) + splitStr.length(), strStns.length());
        }
        vSplit.addElement(strStns);
        return vSplit;
    }

    /**
     * 将逗号分割的字符串转换为单引号逗号分割的字符串 "2002,2003,2004" =〉'2002', '2003', '2004'
     *
     * @param strComma
     * @return
     */
    public static String strComma2Singlequotes(String strComma) {
        String retVal = "";
        if (strComma == "") {
            return "''";
        } else {
            // 将逗号分隔的字段串进行折分
            Vector<String> vSplit = new Vector<String>();
            vSplit = splitV(strComma, ",");
            for (int i = 0; i < vSplit.size(); i++) {
                retVal = retVal + "'" + vSplit.elementAt(i).toString() + "',";
            }
            retVal = retVal.substring(0, retVal.length() - 1);
            return retVal;
        }
    }

    /**
     * 将字符串数组转换为逗号分隔的字符串
     *
     * @param strArray
     * @return
     */
    public String stringArrayToStr(String[] strArray) {
        if (strArray.length == 0) {
            return "";
        } else {
            String sRet = "";
            for (int i = 0, size = strArray.length; i < size - 1; i++) {
                sRet += strArray[i] + ",";
            }
            sRet += strArray[strArray.length] + ",";
            return sRet;
        }
    }

    /**
     * 将下划线、中划线相连的字符串转换为驼峰形式
     *
     * @param s
     * @return
     */
    public static String camelize(String s) {
        return camelize(camelize(s, "-"), "_");
    }

    /**
     * 将指定字符相连的字符串转换为驼峰形式
     *
     * @param s
     * @return
     */
    public static String camelize(String s, String regex) {
        String[] parts = s.split(regex);
        int len = parts.length;
        if (len == 1) {
            return parts[0];
        }
        String camelized = s.substring(0, 1) == regex ? s.substring(0, 1).toUpperCase() + parts[0].substring(1) : parts[0];
        for (int i = 1; i < len; i++) {
            camelized += parts[i].substring(0, 1).toUpperCase() + parts[i].substring(1);
        }
        return camelized;
    }

    public static String htmlEncode(String str) {
        if (str == null) {
            return "";
        } else {
            String s = str;
            s = StringUtil.replace(s, "&", "&amp;");
            s = StringUtil.replace(s, "<", "&lt;");
            s = StringUtil.replace(s, ">", "&gt;");
            return s;
        }
    }

    public static String htmlDecode(String str) {
        if (str == null) {
            return "";
        } else {
            String s = str;
            s = StringUtil.replace(s, "&lt;", "<");
            s = StringUtil.replace(s, "&gt;", ">");
            s = StringUtil.replace(s, "&nbsp;", " ");
            s = StringUtil.replace(s, "&quot;", "\"");
            s = StringUtil.replace(s, "&amp;", "&");
            return s;
        }
    }

    /**
     * 将十进制数转换为二进制字符串
     *
     * @param dec
     * @return
     */
    public static String Dec2Bin(int dec) {
        return Integer.toBinaryString(dec);
    }

    /**
     * 将十进制数转换为2的指数函数的数的和的逗号分隔的字符串
     *
     * @param dec
     * @return
     */
    public static String Dec2BinPower(int dec) {
        String strBin = Integer.toBinaryString(dec);
        String strBinNum = "";
        for (int i = 0, len = strBin.length(); i < len; i++) {
            if ("1".equals(strBin.substring(i, i + 1))) {
                strBinNum += ((int) Math.pow(2, len - 1 - i)) + ",";
            }
        }
        strBinNum = strBinNum.substring(0, strBinNum.length() - 1);
        return strBinNum;
    }

    /**
     * @param dec
     * @return
     */
    public static String Dec2BinNumStr(int dec) {
        return Dec2BinPower(dec);
    }

    /**
     * 将数字 0 替换为空
     *
     * @param num
     * @return
     */
    public static String Zero2Blank(int num) {
        if (num == 0) {
            return "";
        } else {
            return Integer.toString(num);
        }
    }

    /**
     * 将数字字符 0 替换为空
     *
     * @param numStr
     * @return
     */
    public static String Zero2Blank(String numStr) {
        return Zero2Blank(Integer.parseInt(numStr));
    }

    public static String GetNo2Chs(String sNo) {
        return GetNo2Chs(Integer.parseInt(sNo), false);
    }

    public static String GetNo2Chs(String sNo, boolean isUpcase) {
        return GetNo2Chs(Integer.parseInt(sNo), isUpcase);
    }

    public static String GetNo2Chs(int No) {
        return GetNo2Chs(No, false);
    }

    /**
     * 得到0-9的中文数字
     *
     * @param No 数字/序号(范围：0-9)
     * @param isUpcase 是否为大写数字
     * @return
     */
    public static String GetNo2Chs(int No, boolean isUpcase) {
        String No2Chs = "十一二三四五六七八九";
        if (isUpcase) {
            No2Chs = "零壹贰叁肆伍陆柒捌玖";
        }
        return No2Chs.substring(No % 10, No % 10 + 1);
    }

    /**
     * 得到0-9的中文数字
     *
     * @param No 数字/序号(范围：0-9)
     * @return
     */
    public static String GetChsNo(int No) {
        String[] chsNo = new String[]{"十", "一", "二", "三", "四", "五", "六", "七", "八", "九"};
        return chsNo[No % 10];
    }
    static String[] units = {"", "十", "百", "千", "万", "十", "百", "千", "亿"};
    static String[] nums = {"一", "二", "三", "四", "五", "六", "七", "八", "九", "十"};

    /**
     * 数字转中文
     *
     * @param a 原始数字
     * @return String 中文字符串
     */
    public static String N2C(int a) {
        String result = "";
        if (a < 0) {
            result = "负";
            a = Math.abs(a);
        }
        String t = String.valueOf(a);
        for (int i = t.length() - 1; i >= 0; i--) {
            int r = (int) (a / Math.pow(10, i));
            if (r % 10 != 0) {
                String s = String.valueOf(r);
                String l = s.substring(s.length() - 1, s.length());
                result += nums[Integer.parseInt(l) - 1];
                result += (units[i]);
            } else {
                if (!result.endsWith("零")) {
                    result += "零";
                }
            }
        }
        return result;
    }

    /**
     * @param iNumber
     * @param bOnlyNum
     * @return
     */
    public static String toUpNum(int iNumber, boolean bOnlyNum) {
        return toUpNum(Integer.toString(iNumber), bOnlyNum);
    }

    /**
     * @param sNumber
     * @param bOnlyNum
     * @return
     */
    public static String toUpNum(String sNumber, boolean bOnlyNum) {
        String[] aNumBig = StringUtil.split("〇,一,二,三,四,五,六,七,八,九", ",");
        if (sNumber.length() == 0) {
            return "";
        }
        String sCh = "";
        String sRet = "";
        String sLastCh = "";
        if (!bOnlyNum) {
            while (sNumber.substring(0, 1).equals("0")) {
                sNumber = sNumber.substring(1);
            }
            if (sNumber.length() == 0) {
                return "〇";
            }
        }
        for (int i = 0; i < sNumber.length(); i++) {
            sCh = sNumber.substring(sNumber.length() - i - 1, sNumber.length() - i);
            if (sCh.equals("0") && sLastCh.equals("0") && !bOnlyNum) {
                continue;
            }
            sRet = (!bOnlyNum && (sCh.equals("1") && i > 0 || sCh.equals("0") && i == 0) ? "" : aNumBig[Convertor.toInt(sCh)]) + (bOnlyNum ? "" : (i == 1 ? "十" : (i == 2 ? "百" : (i == 3 ? "千" : (i == 4 ? "万" : ""))))) + sRet;
            sLastCh = sCh;
        }
        return sRet;
    }

    /**
     * @param s
     * @return
     */
    public int convertAction(String s) {
        int val = 1;
        if (Convertor.isInt(s)) {
            val = Integer.parseInt(s);
        }
        return val;
    }

    /**
     * 获取指定汉字字符串的首字母，默认为大写
     *
     * @param str
     * @return
     */
    public static String getFirstSpell(String str) {
        return getFirstSpell(str, true);
    }

    /**
     * 获取指定汉字字符串的首字母
     *
     * @param str
     * @param bUpperCase
     * @return
     */
    public static String getFirstSpell(String str, boolean bUpperCase) {
        return CnToSpell.getFirstSpell(str, bUpperCase);
    }

    /**
     * 格式化金额数字
     *
     * @param str
     * @return
     */
    public static String getCurrency(String str) {
        NumberFormat n = NumberFormat.getCurrencyInstance();
        double d;
        String outStr = null;
        try {
            d = Double.parseDouble(str);
            outStr = n.format(d);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return outStr;
    }

    /**
     * @param str
     * @return
     */
    public String getDecimalFormat(String str) {
        DecimalFormat fmt = new DecimalFormat("##,###,###,###,##0.00000");
        String outStr = null;
        double d;
        try {
            d = Double.parseDouble(str);
            outStr = fmt.format(d);
        } catch (Exception e) {
        }
        return outStr;
    }

    /**
     * @param str
     * @return
     */
    public String getFormatter(String str) {
        NumberFormat n = NumberFormat.getNumberInstance();
        double d;
        String outStr = null;
        try {
            d = Double.parseDouble(str);
            outStr = n.format(d);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return outStr;
    }

    /**
     * @param value
     * @param len
     * @param word
     * @return
     */
    public String ellipsis(String value, int len, boolean word) {
        if (value.length() > len) {
            if (word) {
                String vs = value.substring(0, len - 2);
                // int index = Math.max(vs.lastIndexOf(' '),
                // vs.lastIndexOf('.'), vs.lastIndexOf('!'),
                // vs.lastIndexOf('?'));.
                int index = Math.max(vs.lastIndexOf(' '), vs.lastIndexOf('.'));
                index = Math.max(index, vs.lastIndexOf('!'));
                index = Math.max(index, vs.lastIndexOf('?'));
                if (index == -1 || index < (len - 15)) {
                    return value.substring(0, len - 3) + "...";
                } else {
                    return vs.substring(0, index) + "...";
                }
            } else {
                return value.substring(0, len - 3) + "...";
            }

        } else {
            return value;
        }
    }

    /**
     * @param value
     * @param len
     * @return
     */
    public String ellipsis(String value, int len) {
        return ellipsis(value, len, false);
    }

    /**
     * @param doubleValue
     * @param scale
     * @return
     */
    public static Double round(Double doubleValue, int scale) {
        Double flag = null;
        String text = doubleValue.toString();
        BigDecimal bd = new BigDecimal(text).setScale(scale, BigDecimal.ROUND_HALF_UP);
        flag = bd.doubleValue();
        return flag;
    }

    /**
     * @param a
     * @return
     */
    public static String getArrayString(String a[]) {
        StringBuffer sb = new StringBuffer();
        sb.append("[");
        for (int i = 0; i < a.length; i++) {
            sb.append(" " + a[i] + " ");
        }
        sb.append("]");
        return sb.toString();
    }

    /**
     * 返回结果JSON字符串
     *
     * @see getResultJson(bet, "");
     * @param 结果状态true or false
     * @return JSONObject
     */
    public static JSONObject getResultJson(boolean bet) throws Exception {
        return getResultJson(bet, "");
    }

    /**
     * 返回结果JSON字符串
     *
     * @param 结果状态true or false
     * @param 结果提示
     * @return
     * {"tips":"操作成功","success":true}||{"errors":"操作失败，错误代码为....","success":false}
     */
    public static JSONObject getResultJson(boolean bet, String msg) throws Exception {
        JSONObject json = new JSONObject();
        json.put("success", bet);
        if (bet == false) {
            json.put("errors", msg);
        } else {
            json.put("tips", msg);
        }
        return json;
    }

   
    /**
     * @param args
     */
     /*
    public static void main(String[] args) {
        try {
            //System.out.println(StringUtil.getResultJson(true,"操作陈宫"));
        } catch (Exception e) {
        }
    }
    */
}
