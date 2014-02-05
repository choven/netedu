package com.swufe.toolkit;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;

public final class PathUtil {

	public PathUtil() {
	}

	/**
	 * @param sUrl
	 * @return
	 */
	public static String encodeURL(String sUrl) {
		return encodeURLUTF8(sUrl);
	}

	/**
	 * @param sUrl
	 * @param sEnc
	 * @return
	 */
	public static String encodeURL(String sUrl, String sEnc) {
		try {
			if (sEnc.equalsIgnoreCase("UTF-8"))
				return encodeURLUTF8(sUrl);
			else {
				return StringUtil.replace(URLEncoder.encode(sUrl, sEnc), "+", "%20");
			}
		} catch (Exception e) {
			return sUrl;
		}
	}

	/**
	 * @param sUrl
	 * @return
	 */
	public static String decodeURL(String sUrl) {
		return decodeURLUTF8(sUrl);
	}

	/**
	 * @param sUrl
	 * @param sEnc
	 * @return
	 */
	public static String decodeURL(String sUrl, String sEnc) {
		try {
			if (sEnc.equalsIgnoreCase("UTF-8"))
				return decodeURLUTF8(sUrl);
			else {
				return URLDecoder.decode(sUrl, sEnc);
			}
		} catch (UnsupportedEncodingException e1) {
			return sUrl;
		}

	}

	/**
	 * @param sUrl
	 * @return
	 */
	public static String getURLRoot(String sUrl) {
		String sBase = "";
		int pos1 = sUrl.indexOf("?");
		int pos2 = sUrl.indexOf("#");
		if (pos1 == -1 && pos2 == -1)
			sBase = sUrl;
		if (pos1 == -1 && pos2 != -1)
			sBase = sUrl.substring(0, pos2);
		if (pos1 != -1)
			sBase = sUrl.substring(0, pos1);
		return sBase;
	}

	/**
	 * @param sUrl
	 * @return
	 */
	public static String getURLQuery(String sUrl) {
		String sParams = "";
		int pos1 = sUrl.indexOf("?");
		int pos2 = sUrl.indexOf("#");
		if (pos1 != -1 && pos2 == -1)
			sParams = sUrl.substring(pos1 + 1);
		if (pos1 != -1 && pos2 != -1)
			sParams = sUrl.substring(pos1 + 1, pos2);
		return sParams;
	}

	/**
	 * @param sUrl
	 * @return
	 */
	public static String getURLAnchor(String sUrl) {
		String sAnchor = "";
		int pos2 = sUrl.indexOf("#");
		if (pos2 != -1)
			sAnchor = sUrl.substring(pos2 + 1);
		return sAnchor;
	}

	/**
	 * @param sUrl
	 * @return
	 */
	public static String encodeURLPath(String sUrl) {
		return encodeURLPath(sUrl, "UTF-8");
	}

	/**
	 * @param sUrl
	 * @param sEnc
	 * @return
	 */
	public static String encodeURLPath(String sUrl, String sEnc) {
		String sRet = "";
		String sBase = getURLRoot(sUrl);
		String sParams = getURLQuery(sUrl);
		String sAnchor = getURLAnchor(sUrl);
		String aPath[] = StringUtil.split(sBase, "/");
		int nCharCode = 0;
		for (int i = 0; i < aPath.length; i++) {
			if (i > 0) {
				sRet = sRet + "/";
			}
			for (int j = 0; j < aPath[i].length(); j++) {
				nCharCode = aPath[i].charAt(j);
				if (nCharCode < 0 || nCharCode >= 128) {
					sRet = sRet + encodeURL(aPath[i].substring(j, j + 1), sEnc);
					continue;
				}
				if ("+=&? _".indexOf(aPath[i].charAt(j)) != -1)
					sRet = sRet + encodeURL(aPath[i].substring(j, j + 1), sEnc);
				else
					sRet = sRet + aPath[i].substring(j, j + 1);
			}

		}

		if (sParams.length() > 0)
			sRet = sRet + "?" + sParams;
		if (sAnchor.length() > 0)
			sRet = sRet + "#" + sAnchor;
		return sRet;
	}

	/**
	 * @param sPath
	 * @return
	 */
	public static String format(String sPath) {
		return format(sPath, '/');
	}

	/**
	 * @param sPath
	 * @param sDelimiter
	 * @return
	 */
	public static String format(String sPath, char sDelimiter) {
		int nPosPre = 0;
		String sRet = "";
		if (sPath.toLowerCase().startsWith("http://") || sPath.toLowerCase().startsWith("file://"))
			nPosPre = 7;
		if (sPath.toLowerCase().startsWith("ftp://"))
			nPosPre = 6;
		if (sPath.toLowerCase().startsWith("file:///"))
			nPosPre = 8;
		for (int i = nPosPre; i < sPath.length(); i++) {
			char c = sPath.charAt(i);
			if (c == '\\' || c == '/') {
				if (i == 0) {
					sRet = sRet + sDelimiter;
					continue;
				}
				if (sRet.charAt(sRet.length() - 1) != '\\' && sRet.charAt(sRet.length() - 1) != '/')
					sRet = sRet + sDelimiter;
			} else {
				sRet = sRet + c;
			}
		}

		if (nPosPre != 0)
			sRet = sPath.substring(0, nPosPre) + sRet;
		return sRet;
	}

	/**
	 * @param sFileName
	 * @return
	 */
	public static String getFileExtName(String sFileName) {
		String sFileNameStr = sFileName;
		sFileNameStr = format(sFileNameStr);
		int nPosSep = sFileNameStr.lastIndexOf("/");
		int nPosDot = sFileNameStr.lastIndexOf(".");
		if (nPosDot <= nPosSep)
			return "";
		else
			return sFileNameStr.substring(nPosDot + 1);
	}

	/**
	 * @param sFileName
	 * @return
	 */
	public static String getFileBaseName(String sFileName) {
		sFileName = format(sFileName);
		int nPosSep = sFileName.lastIndexOf("/");
		int nPosDot = sFileName.lastIndexOf(".");
		if (nPosDot < nPosSep || nPosDot == -1)
			nPosDot = sFileName.length();
		return sFileName.substring(nPosSep + 1, nPosDot);
	}

	/**
	 * @param sPathName
	 * @return
	 */
	public static String getFileName(String sPathName) {
		sPathName = format(sPathName, '/');
		int pos = sPathName.lastIndexOf("/");
		return sPathName.substring(pos + 1);
	}

	/**
	 * @param sFileName
	 * @return
	 */
	public static String getFilePath(String sFileName) {
		sFileName = format(sFileName, '/');
		int pos = sFileName.lastIndexOf("/");
		if (pos == -1)
			pos = 0;
		return sFileName.substring(0, pos);
	}

	/**
	 * @param sPath
	 * @param sBase
	 * @return
	 */
	public static String getRelativePath(String sPath, String sBase) {
		return getRelativePath(sPath, sBase, true);
	}

	/**
	 * @param sPath
	 * @param sBase
	 * @param bEngoreCase
	 * @return
	 */
	public static String getRelativePath(String sPath, String sBase, boolean bEngoreCase) {
		String sRet = "";
		sPath = format(sPath);
		sBase = format(sBase);
		if (sBase.charAt(sBase.length() - 1) != '/')
			sBase = sBase + '/';
		int pos1 = sBase.length();
		int pos2 = pos1;
		do {
			pos1 = sBase.lastIndexOf("/", pos2);
			if (pos1 == -1)
				break;
			pos2 = pos1 - 1;
			if (!bEngoreCase) {
				if (sPath.substring(0, pos1).equals(sBase.substring(0, pos1)))
					break;
				sRet = sRet + "../";
				continue;
			}
			if (sPath.substring(0, pos1).equalsIgnoreCase(sBase.substring(0, pos1)))
				break;
			sRet = sRet + "../";
		} while (true);
		return sRet + sPath.substring(pos1 + 1);
	}

	/**
	 * @param sUrl
	 * @return
	 */
	private static String encodeURLUTF8(String sUrl) {
		if (sUrl == null)
			return "";
		char aChar[] = sUrl.toCharArray();
		String sRet = "";
		String sHex = "";
		int nHex = 0;
		for (int i = 0; i < aChar.length; i++) {
			if (aChar[i] == ' ') {
				sRet = sRet + "%20";
				continue;
			}
			if (aChar[i] > 0 && aChar[i] < '\200') {
				if (aChar[i] >= 'A' && aChar[i] <= 'Z' || aChar[i] >= 'a' && aChar[i] <= 'z' || aChar[i] >= '0' && aChar[i] <= '9') {
					sRet = sRet + aChar[i];
					continue;
				}
				sHex = Integer.toString(aChar[i], 16);
				if (sHex.length() == 1)
					sHex = "0" + sHex;
				sRet = sRet + "%" + sHex;
				continue;
			}
			if (aChar[i] > 0 && aChar[i] < '\u0800') {
				nHex = (aChar[i] & 0xfc0) / 64 + 192;
				sRet = sRet + "%" + Integer.toString(nHex, 16);
				nHex = (aChar[i] & 0x3f) + 128;
				sRet = sRet + "%" + Integer.toString(nHex, 16);
				continue;
			}
			if (aChar[i] > 0 && aChar[i] < '\0') {
				nHex = (aChar[i] & 0xf000) / 4096 + 224;
				sRet = sRet + "%" + Integer.toString(nHex, 16);
				nHex = (aChar[i] & 0xfc0) / 64 + 128;
				sRet = sRet + "%" + Integer.toString(nHex, 16);
				nHex = (aChar[i] & 0x3f) + 128;
				sRet = sRet + "%" + Integer.toString(nHex, 16);
			} else {
				sRet = sRet + aChar[i];
			}
		}
		return sRet;
	}

	/**
	 * @param sUrl
	 * @return
	 */
	private static String decodeURLUTF8(String sUrl) {
		String sRet = "";
		char aChar[] = sUrl.toCharArray();
		int nAsc = 0;
		int nHex = 0;
		String sHex = "";
		for (int i = 0; i < aChar.length; i++) {
			if (aChar[i] == '+') {
				sRet = sRet + ' ';
				continue;
			}
			if (aChar[i] == '%') {
				sHex = sUrl.substring(i + 1, i + 3);
				nHex = Integer.parseInt(sHex, 16);
				if (nHex < 128) {
					sRet = sRet + (char) nHex;
					i += 2;
					continue;
				}
				if (nHex < 224) {
					nAsc = (nHex - 192) * 64;
					sHex = sUrl.substring(i + 4, i + 6);
					nHex = Integer.parseInt(sHex, 16);
					nAsc += nHex - 128;
					sRet = sRet + (char) nAsc;
					i += 5;
					continue;
				}
				if (nHex < 240) {
					nAsc = (nHex - 224) * 4096;
					sHex = sUrl.substring(i + 4, i + 6);
					nHex = Integer.parseInt(sHex, 16);
					nAsc += (nHex - 128) * 64;
					sHex = sUrl.substring(i + 7, i + 9);
					nHex = Integer.parseInt(sHex, 16);
					nAsc += nHex - 128;
					sRet = sRet + (char) nAsc;
					i += 8;
				}
			} else {
				sRet = sRet + aChar[i];
			}
		}
		return sRet;
	}

}
