package com.swufe.toolkit;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

public final class DateUtil {

	public static final String YYMMDD = "YY-MM-DD";
	public static final String YYMMDD_CHS = "YY年MM月DD日";
	public static final String HHMISS = "HH24:MI:SS";
	public static final String HHMISS_CHS = "HH24点MI分SS秒";
	public static final String YYMMDD_HHMISS = "YY-MM-DD HH24:MI:SS";
	public static final String YYMMDD_HHMISS_CHS = "YY年MM月DD日HH24点MI分SS秒";

	public DateUtil() {
	}
	/**
	 * @param sDate
	 * @return
	 */
	public static String getYear(String sDate) {
		if (StringUtil.nullValue(sDate).length() == 0)
			return "";
		int pos1 = sDate.indexOf(45);
		if (pos1 == -1)
			return "";
		else
			return sDate.substring(0, pos1);
	}

	/**
	 * @param sDate
	 * @return
	 */
	public static String getMonth(String sDate) {
		int pos1 = sDate.indexOf(45);
		if (pos1 == -1)
			return "";
		int pos2 = sDate.indexOf(45, pos1 + 1);
		if (pos2 == -1)
			return "";
		int nMonth = Convertor.toInt(sDate.substring(pos1 + 1, pos2), 0);
		if (nMonth < 1 || nMonth > 12)
			return "";
		else
			return "" + nMonth;
	}

	/**
	 * @param sDate
	 * @return
	 */
	public static String getDate(String sDate) {
		int pos1 = sDate.indexOf(45);
		if (pos1 == -1)
			return "";
		pos1 = sDate.indexOf(45, pos1 + 1);
		if (pos1 == -1)
			return "";
		int pos2 = sDate.indexOf(32, pos1);
		if (pos2 == -1)
			pos2 = sDate.length();
		int nDate = Convertor.toInt(sDate.substring(pos1 + 1, pos2), 0);
		if (nDate < 1 || nDate > 31)
			return "";
		else
			return "" + nDate;
	}

	/**
	 * @param sDate
	 * @return
	 */
	public static String getHour(String sDate) {
		int pos1 = sDate.indexOf(32);
		if (pos1 == -1)
			return "0";
		int pos2 = sDate.indexOf(58, pos1 + 1);
		if (pos2 == -1)
			return "0";
		int nHour = Convertor.toInt(sDate.substring(pos1 + 1, pos2), -1);
		if (nHour < 0 || nHour > 59)
			return "";
		else
			return "" + nHour;
	}

	/**
	 * @param sDate
	 * @return
	 */
	public static String getMinute(String sDate) {
		sDate = sDate.trim();
		int pos1 = sDate.indexOf(" ");
		if (pos1 == -1)
			return "0";
		pos1 = sDate.indexOf(":", pos1);
		if (pos1 == -1)
			return "0";
		int pos2 = sDate.indexOf(":", pos1 + 1);
		if (pos2 == -1)
			pos2 = sDate.length();
		return sDate.substring(pos1 + 1, pos2);
	}

	/**
	 * @param sDate
	 * @return
	 */
	public static String getSecond(String sDate) {
		sDate = sDate.trim();
		int pos1 = sDate.indexOf(" ");
		if (pos1 == -1)
			return "0";
		pos1 = sDate.indexOf(":", pos1);
		if (pos1 == -1)
			return "0";
		pos1 = sDate.indexOf(":", pos1 + 1);
		if (pos1 == -1)
			return "0";
		int pos2 = sDate.indexOf(".", pos1 + 1);
		if (pos2 == -1)
			pos2 = sDate.length();
		return sDate.substring(pos1 + 1, pos2);
	}

	/**
	 * @param str
	 * @return
	 */
	public static boolean isDate(String str) {
		if (str == null)
			return false;
		if (str.length() == 0)
			return false;
		int pos = str.indexOf(32);
		String sDate = "";
		String sTime = "";
		if (pos == -1) {
			sDate = str;
		} else {
			sDate = str.substring(0, pos);
			sTime = str.substring(pos + 1);
		}
		String aDate[] = StringUtil.split(sDate, "-");
		if (aDate.length != 3)
			return false;
		if (Convertor.toInt(aDate[0], -1) < 0 || Convertor.toInt(aDate[1], 0) < 1 || Convertor.toInt(aDate[1], 0) > 12 || Convertor.toInt(aDate[1], 0) < 1 || Convertor.toInt(aDate[1], 0) > 31)
			return false;
		if (sTime.length() > 0) {
			pos = sTime.indexOf(".");
			if (pos != -1) {
				String sMillSec = sTime.substring(pos + 1);
				if (!Convertor.isInt(sMillSec))
					return false;
				sTime = sTime.substring(0, pos);
			}
			String aTime[] = StringUtil.split(sTime, ":");
			if (aTime.length != 3)
				return false;
			for (int i = 0; i < 3; i++)
				if (Convertor.toInt(aTime[i], -1) < 0 || Convertor.toInt(aTime[i], -1) > 59)
					return false;
		}
		return true;
	}

	/**
	 * @param sBeginDate
	 * @param sEndDate
	 * @param sFormat
	 * @return
	 */
	public static String getDateString(String sBeginDate, String sEndDate, String sFormat) {
		return getDateString(sBeginDate, sEndDate, sFormat, "~");
	}

	public static String getDateString(String sBeginDate, String sEndDate, String sFormat, String sConcat) {
		if (sBeginDate.length() == 0 && sEndDate.length() == 0)
			return "";
		if (sBeginDate.length() == 0)
			return getDateString(sEndDate, sFormat);
		if (sEndDate.length() == 0)
			return getDateString(sBeginDate, sFormat);
		String sEndFomat = sFormat;
		if (sEndFomat.indexOf("YY") != -1 && sEndFomat.indexOf("MM") != -1 && getYear(sEndDate).equalsIgnoreCase(getYear(sBeginDate))) {
			sEndFomat = sEndFomat.substring(sEndFomat.indexOf("MM"));
			if (sFormat.indexOf("DD") != -1 && getMonth(sEndDate).equalsIgnoreCase(getMonth(sBeginDate))) {
				sEndFomat = sEndFomat.substring(sEndFomat.indexOf("DD"));
				if (sFormat.indexOf("HH") != -1 && getDate(sEndDate).equalsIgnoreCase(getDate(sBeginDate)))
					sEndFomat = sEndFomat.substring(sEndFomat.indexOf("HH"));
			}
		}
		return getDateString(sBeginDate, sFormat) + sConcat + getDateString(sEndDate, sEndFomat);
	}

	/**
	 * @param sDate
	 * @param sFormat
	 * @return
	 */
	public static String getDateString(String sDate, String sFormat) {
		if (sDate.length() == 0) {
			return "";
		} else {
			String sRet = sFormat;
			sRet = StringUtil.replace(sRet, "YY", getYear(sDate));
			sRet = StringUtil.replace(sRet, "MM", getMonth(sDate));
			sRet = StringUtil.replace(sRet, "DD", getDate(sDate));
			String sHour = getHour(sDate);
			sRet = StringUtil.replace(sRet, "HH24", sHour);
			sRet = StringUtil.replace(sRet, "HH", sHour);
			sRet = StringUtil.replace(sRet, "MI", getMinute(sDate));
			sRet = StringUtil.replace(sRet, "SS", getSecond(sDate));
			return sRet;
		}
	}

	/**
	 * @param calendar
	 * @param sFormat
	 * @return
	 */
	public static String getDateString(Calendar calendar, String sFormat) {
		String sDate = calendar.get(1) + "-" + (calendar.get(2) + 1) + "-" + calendar.get(5) + " " + calendar.get(11) + ":" + calendar.get(12) + ":" + calendar.get(13);
		return getDateString(sDate, sFormat);
	}
/**
	 * 格式化日期
	 * 
	 * @return
	 */
	public static String showDateFormat(String date, String format) throws Exception {
		// Calendar cal = Calendar.getInstance();
		SimpleDateFormat formatter = new SimpleDateFormat(format);
		Date date2 = new SimpleDateFormat("yyyy-MM-dd").parse(date);
		return formatter.format(date2);
	}

	/**
	 * 显示当天日期，格式：自定义
	 * 
	 * @return
	 */
	public static String showDateTodayFormat(String format) {
		Calendar cal = Calendar.getInstance();
		SimpleDateFormat formatter = new SimpleDateFormat(format);
		return formatter.format(cal.getTime());
	}

	/**
	 * 显示当天日期，格式：2009-05-18
	 * 
	 * @return
	 */
	public static String showDateToday() {
		Calendar cal = Calendar.getInstance();
		SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
		return formatter.format(cal.getTime());
	}

	/**
	 * 显示当天日期，格式：2009-05-18
	 * 
	 * @return
	 */
	public static String showDateTodayCh() {
		Calendar cal = Calendar.getInstance();
		SimpleDateFormat formatter = new SimpleDateFormat("yyyy年MM月dd日");
		return formatter.format(cal.getTime());
	}

	/**
	 * @param date
	 * @return
	 */
	public static String showDateToday(Date date) {
		Calendar cal = Calendar.getInstance();
		cal.setTime(date);
		SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
		return formatter.format(cal.getTime());
	}
	/**
	 * @param sDate1
	 * @param sDate2
	 * @return
	 */
	public static int compareDate(String sDate1, String sDate2) {
		if (sDate1 == null)
			sDate1 = "";
		if (sDate2 == null)
			sDate2 = "";
		sDate1 = toEngDateString(sDate1);
		sDate2 = toEngDateString(sDate2);
		return sDate1.compareTo(sDate2);
	}

	/**
	 * @param sDate
	 * @return
	 */
	private static String toEngDateString(String sDate) {
		sDate = sDate.replace('年', '-');
		sDate = sDate.replace('月', '-');
		sDate = sDate.replace('日', '-');
		sDate = sDate.replace(' ', '-');
		sDate = sDate.replace(':', '-');
		String aDateInfo[] = StringUtil.split(sDate, "-");
		String sRet = "";
		int nDatePart = 0;
		for (int i = 0; i < aDateInfo.length; i++) {
			if (aDateInfo[i].length() == 0)
				continue;
			if (nDatePart != 0)
				if (nDatePart < 3)
					sRet = sRet + "-";
				else if (nDatePart == 3)
					sRet = sRet + " ";
				else
					sRet = sRet + ":";
			if (nDatePart == 0 && aDateInfo[i].length() == 2)
				sRet = sRet + "20";
			if (aDateInfo[i].length() == 1)
				sRet = sRet + "0";
			sRet = sRet + aDateInfo[i];
			nDatePart++;
		}
		return sRet;
	}
        
}
