package com.swufe.toolkit;

import java.util.Date;

public final class Convertor {

	public Convertor() {
	}

	/**
	 * @param sVariant
	 * @return
	 */
	public static boolean toBool(String sVariant) {
		return sVariant != null && !sVariant.equalsIgnoreCase("0") && !sVariant.equalsIgnoreCase("false") && !sVariant.equalsIgnoreCase("否") && sVariant.length() != 0;
	}

	/**
	 * @param iVariant
	 * @return
	 */
	public static boolean toBool(int iVariant) {
		return iVariant != 1;
	}

	/**
	 * @param str
	 * @return
	 */
	public static int toInt(String str) {
		return toInt(str, 0);
	}

	/**
	 * @param str
	 * @param nDefault
	 * @return
	 */
	public static int toInt(String str, int nDefault) {
		if (!isNumeric(str))
			return nDefault;
		if (str.indexOf(".") != -1)
			str = str.substring(0, str.indexOf("."));
		return Integer.parseInt(str);
	}

	/**
	 * @param str
	 * @return
	 */
	public static long toLong(String str) {
		return toLong(str, 0L);
	}

	/**
	 * @param str
	 * @param nDefault
	 * @return
	 */
	public static long toLong(String str, long nDefault) {
		if (!isNumeric(str))
			return nDefault;
		if (str.indexOf(".") != -1)
			str = str.substring(0, str.indexOf("."));
		return Long.parseLong(str);
	}

	/**
	 * @param str
	 * @return
	 */
	public static double toDouble(String str) {
		return toDouble(str, 0.0D);
	}

	/**
	 * @param str
	 * @param nDefault
	 * @return
	 */
	public static double toDouble(String str, double nDefault) {
		return toDouble(str, nDefault, 9);
	}

	/**
	 * @param str
	 * @param nDefault
	 * @param nPrecision
	 * @return
	 */
	public static double toDouble(String str, double nDefault, int nPrecision) {
		if (!isNumeric(str)) {
			return nDefault;
		} else {
			double nRet = Double.parseDouble(str);
			nRet = (double) Math.round(nRet * Math.pow(10D, nPrecision)) / Math.pow(10D, nPrecision);
			return nRet;
		}
	}

	/**
	 * @param n
	 * @param nPrecision
	 * @return
	 */
	public static double toDouble(double n, int nPrecision) {
		n = (double) Math.round(n * Math.pow(10D, nPrecision)) / Math.pow(10D, nPrecision);
		return n;
	}

	/**
	 * @param str
	 * @return
	 */
	public static boolean isNumeric(String str) {
		if (str == null)
			return false;
		if (str.length() == 0)
			return false;
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
		return str != null && str.indexOf(46) == -1 && isNumeric(str) && str.length() <= 10;
	}

	/**
	 * @param str
	 * @return
	 */
	public static boolean isLong(String str) {
		return str != null && str.indexOf(46) == -1 && isNumeric(str);
	}

	/**
	 * @param sDate
	 * @return
	 */
	@SuppressWarnings("deprecation")
	public static Date toDate(String sDate) {
		Date d = new Date();
		d.setYear(Integer.parseInt(DateUtil.getYear(sDate)));
		d.setMonth(Integer.parseInt(DateUtil.getMonth(sDate)) - 1);
		d.setDate(Integer.parseInt(DateUtil.getDate(sDate)));
		d.setHours(Integer.parseInt(DateUtil.getHour(sDate)));
		d.setMinutes(Integer.parseInt(DateUtil.getMinute(sDate)));
		d.setSeconds(Integer.parseInt(DateUtil.getSecond(sDate)));
		return d;
	}

	/**
	 * @param nNum
	 * @return
	 */
	public static String numToUpper(int nNum) {
		return numToUpper("" + nNum);
	}

	/**
	 * @param sNum
	 * @return
	 */
	public static String numToUpper(String sNum) {
		String sUnit = "千百十亿千百十万千百十";
		String sNumChar = "零一二三四五六七八九";
		int pos = sNum.indexOf(46);
		String sBeforeDot = "";
		String sAfterDot = "";
		if (pos == -1) {
			sBeforeDot = sNum;
		} else {
			sBeforeDot = sNum.substring(0, pos);
			sAfterDot = sNum.substring(pos + 1);
		}
		String sRet = "";
		char c = '\0';
		for (int i = 0; i < sBeforeDot.length(); i++) {
			c = sBeforeDot.charAt(i);
			if (c == '0') {
				if (i >= sBeforeDot.length() - 1)
					continue;
				String sTmp = sUnit.substring((sUnit.length() - sBeforeDot.length()) + i + 1, (sUnit.length() - sBeforeDot.length()) + i + 2);
				if (sTmp.equals("亿") || sTmp.equals("万")) {
					if (sRet.substring(sRet.length() - 1).equals("零"))
						sRet = sRet.substring(0, sRet.length() - 1);
					if (!sRet.substring(sRet.length() - 1).equals("亿") && !sRet.substring(sRet.length() - 1).equals("万") || !sTmp.equals("万"))
						sRet = sRet + sTmp;
					continue;
				}
				if (!sRet.substring(sRet.length() - 1).equals("零"))
					sRet = sRet + "零";
				continue;
			}
			sRet = sRet + sNumChar.substring(c - 48, (c - 48) + 1);
			if (i < sBeforeDot.length() - 1)
				sRet = sRet + sUnit.substring((sUnit.length() - sBeforeDot.length()) + i + 1, (sUnit.length() - sBeforeDot.length()) + i + 2);
		}

		if (sRet.length() > 2 && sRet.substring(0, 2).equals("一十"))
			sRet = sRet.substring(1);
		if (sRet.substring(sRet.length() - 1).equals("零"))
			sRet = sRet.substring(0, sRet.length() - 1);
		if (sAfterDot.length() > 0) {
			sRet = sRet + "点";
			for (int i = 0; i < sAfterDot.length(); i++) {
				c = sAfterDot.charAt(i);
				sRet = sRet + sNumChar.substring(c - 48, (c - 48) + 1);
			}

		}
		return sRet;
	}
}
