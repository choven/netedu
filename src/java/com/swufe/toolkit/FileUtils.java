package com.swufe.toolkit;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.RandomAccessFile;
import java.text.SimpleDateFormat;
import java.util.Calendar;

public class FileUtils {

	/**
	 * 根据文件完成路径，判断文件是否存在
	 * 
	 * @param filePath
	 * @return
	 */
	public static boolean fileExists(String filePath) {
		File file = new File(filePath);
		return file.exists();
	}

	/**
	 * @param filePath
	 * @return
	 */
	public static String fileExists2Str(String filePath) {
		String retVal = "<font face=\"Arial Black\" color=\"#FF0000\">NO </font>";
		File file = new File(filePath);
		if (file.exists()) {
			retVal = "<font face=\"Arial Black\" color=\"#008000\">YES</font>";
		}
		return retVal;
	}

	/**
	 * 创建新目录
	 * 
	 * @param folderPath
	 * @return
	 */
	public static boolean createFolder(String folderPath) {
		boolean retVal = false;
		String txt = folderPath;
		try {
			java.io.File myFilePath = new java.io.File(txt);
			if (!myFilePath.exists()) {
				myFilePath.mkdir();
				retVal = true;
			} else {
				retVal = false;
			}
		} catch (Exception e) {
			retVal = false;
		}
		return retVal;
	}

	/**
	 * 复制单个文件
	 * 
	 * @param src
	 *            准备复制的文件源
	 * @param dest
	 *            拷贝到新绝对路径带文件名
	 * @return
	 */
	public static boolean copyFile(String src, String dest) {
		boolean retVal = false;
		try {
			int bytesum = 0;
			int byteread = 0;
			File oldfile = new File(src);
			if (oldfile.exists()) {
				InputStream inStream = new FileInputStream(src);
				FileOutputStream fs = new FileOutputStream(dest);
				byte[] buffer = new byte[1024];
				while ((byteread = inStream.read(buffer)) != -1) {
					bytesum += byteread;
					System.out.println(bytesum);
					fs.write(buffer, 0, byteread);
				}
				inStream.close();
				retVal = true;
			}
		} catch (Exception e) {
			retVal = false;
		}
		return retVal;
	}

	/**
	 * 复制文件目录，包括空文件夹
	 * 
	 * @param sSource
	 * @param sDestination
	 * @param bOverwrite
	 * @param bMkdirs
	 * @return
	 */
	public static boolean copyFolder(String sSource, String sDestination, boolean bOverwrite, boolean bMkdirs) {
		boolean bSucceed = true;
		File file = new File(sSource);
		if (!file.exists()) {
			return false;
		}
		if (!file.isDirectory()) {
			return FileUtils.copyFile(sSource, sDestination, bOverwrite);
		}
		String aSubDirs[] = file.list();
		File fileDest = null;
		fileDest = new File(sDestination);
		if (fileDest.exists() == false && bMkdirs) {
			fileDest.mkdirs();
		}
		for (int i = 0; i < aSubDirs.length; i++) {
			if (!aSubDirs[i].equals(".") && !aSubDirs[i].equals("..")) {
				fileDest = new File(sDestination + "\\" + aSubDirs[i]);
				if (fileDest.exists() == false && bMkdirs) {
					fileDest.mkdirs();
				}
				bSucceed = copyFolder(sSource + "\\" + aSubDirs[i], sDestination + "\\" + aSubDirs[i], bOverwrite, bMkdirs) && bSucceed;
			}
		}
		return bSucceed;
	}

	/**
	 * 移动文件目录，包括空文件夹
	 * 
	 * @param sSource
	 * @param sDestination
	 * @param bOverwrite
	 * @param bMkdirs
	 * @return
	 */
	public static boolean moveFolder(String sSource, String sDestination, boolean bOverwrite, boolean bMkdirs) {
		boolean bSucceed = true;
		bSucceed = copyFolder(sSource, sDestination, bOverwrite, bMkdirs);
		if (bSucceed) {
			bSucceed = FileUtils.delete(sSource);
		}
		return bSucceed;
	}

	/**
	 * 获得当前文件目录大小
	 * 
	 * @param file
	 * @return
	 */
	public static long getSizeCurrentDirectory(File file) {
		long lRet = 0L;
		if (!file.exists())
			return 0L;
		if (file.isDirectory()) {
			File files[] = file.listFiles();
			for (int i = 0; i < files.length; i++) {
				if (files[i].isFile()) {
					lRet += files[i].length();
				}
			}
		} else {
			return file.length();
		}
		return lRet;
	}

	/**
	 * @param sFileName
	 * @return
	 */
	public static long getSizeCurrentDirectory(String sFileName) {
		File file = new File(sFileName);
		return getSizeCurrentDirectory(file);
	}

	/**
	 * @param file
	 * @return
	 */
	public static String getSizeCurrentDirectoryStr(File file) {
		long lSize = getSizeCurrentDirectory(file);
		return FileUtils.toSizeStr(lSize);
	}

	/**
	 * @param sFileName
	 * @return
	 */
	public static String getSizeCurrentDirectoryStr(String sFileName) {
		long lSize = getSizeCurrentDirectory(sFileName);
		return FileUtils.toSizeStr(lSize);
	}

	/**
	 * 将字符串数组转换为 File 类型的数组
	 * 
	 * @param sArr
	 * @return
	 */
	public static File[] sArr2fArr(String[] sArr) {
		File[] fArr = new File[sArr.length];
		for (int i = 0; i < sArr.length; i++) {
			fArr[i] = new File(sArr[i]);
		}
		return fArr;
	}

	/**
	 * @param sBasePath
	 * @param sRelativePath
	 *            可以是逗号分隔的
	 * @return
	 */
	public static String[] SplitJointPath(String sBasePath, String sRelativePath) {
		if (sBasePath.endsWith(File.separator)) {
			sBasePath = sBasePath.substring(0, sBasePath.length() - 1);
		}
		String[] sPathArr = sRelativePath.split(",");
		for (int i = 0; i < sPathArr.length; i++) {
			if (!sPathArr[i].startsWith(File.separator)) {
				sPathArr[i] = File.separator + sPathArr[i];
			}
			sPathArr[i] = sBasePath + sPathArr[i];
		}
		return sPathArr;
	}

	/**
	 * @return
	 */
	public static String makeFileName() {
		Calendar cal = Calendar.getInstance();
		SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
		return formatter.format(cal.getTime());
	}

	/**
	 * @param file
	 * @return
	 */
	public static boolean delete(File file) {
		if (!file.exists())
			return true;
		boolean bsucceed = true;
		if (file.isDirectory()) {
			File files[] = file.listFiles();
			for (int i = 0; files.length > 0 && i < files.length; i++)
				bsucceed = delete(files[i]) && bsucceed;

		}
		return file.delete() && bsucceed;
	}

	/**
	 * @param sFileName
	 * @return
	 */
	public static boolean delete(String sFileName) {
		File file = new File(sFileName);
		return delete(file);
	}

	/**
	 * @param sSource
	 * @param sDestination
	 * @param bOverwrite
	 * @return
	 */
	public static boolean copyFile(String sSource, String sDestination, boolean bOverwrite) {
		if (!bOverwrite && (new File(sDestination)).exists())
			return true;
		boolean bSucceed = true;
		RandomAccessFile rafSrc = null;
		RandomAccessFile rafDest = null;
		try {
			File fileDest = new File(PathUtil.getFilePath(sDestination));
			if (!fileDest.exists())
				fileDest.mkdirs();
			delete(sDestination);
			fileDest = null;
			rafSrc = new RandomAccessFile(sSource, "r");
			rafDest = new RandomAccessFile(sDestination, "rw");
			long lLen = rafSrc.length();
			long lSizeRead = 0L;
			byte bytes[] = null;
			while (lSizeRead < lLen) {
				if (lSizeRead + 0x1000000L <= lLen)
					bytes = new byte[0x1000000];
				else
					bytes = new byte[(int) (lLen - lSizeRead)];
				lSizeRead += 0x1000000L;
				rafSrc.read(bytes);
				rafDest.write(bytes);
			}

		} catch (Exception e) {
			bSucceed = false;
			e.printStackTrace();
		}
		try {
			if (rafSrc != null)
				rafSrc.close();
			if (rafDest != null)
				rafDest.close();
		} catch (Exception e) {
			bSucceed = false;
			e.printStackTrace();
		}
		return bSucceed;
	}

	/**
	 * @param sSource
	 * @param sDestination
	 * @return
	 */
	public static boolean moveFile(String sSource, String sDestination) {
		return moveFile(sSource, sDestination, true);
	}

	/**
	 * @param sSource
	 * @param sDestination
	 * @param bOverwrite
	 * @return
	 */
	public static boolean moveFile(String sSource, String sDestination, boolean bOverwrite) {
		return copyFile(sSource, sDestination, bOverwrite) && delete(sSource);
	}

	/**
	 * @param sSource
	 * @param sDestination
	 * @return
	 */
	public static boolean copyFolder(String sSource, String sDestination) {
		return copyFolder(sSource, sDestination, true);
	}

	/**
	 * @param sSource
	 * @param sDestination
	 * @param bOverwrite
	 * @return
	 */
	public static boolean copyFolder(String sSource, String sDestination, boolean bOverwrite) {
		boolean bSucceed = true;
		File file = new File(sSource);
		if (!file.exists())
			return false;
		if (!file.isDirectory())
			return copyFile(sSource, sDestination, bOverwrite);
		String aSubDirs[] = file.list();
		for (int i = 0; i < aSubDirs.length; i++)
			if (!aSubDirs[i].equals(".") && !aSubDirs[i].equals(".."))
				bSucceed = copyFolder(sSource + "/" + aSubDirs[i], sDestination + "/" + aSubDirs[i]) && bSucceed;

		return bSucceed;
	}

	/**
	 * @param sSource
	 * @param sDestination
	 * @return
	 */
	public static boolean moveFolder(String sSource, String sDestination) {
		return moveFolder(sSource, sDestination, true);
	}

	/**
	 * @param sSource
	 * @param sDestination
	 * @param bOverwrite
	 * @return
	 */
	public static boolean moveFolder(String sSource, String sDestination, boolean bOverwrite) {
		return copyFolder(sSource, sDestination, bOverwrite) && delete(sSource);
	}

	/**
	 * @param sParentFolder
	 * @param sOldFileName
	 * @return
	 */
	public static String getTempFileName(String sParentFolder, String sOldFileName) {
		String sSuffix = PathUtil.getFileExtName(sOldFileName);
		if (sSuffix.length() > 0)
			sSuffix = "." + sSuffix;
		return getTempName(sParentFolder, sSuffix);
	}

	/**
	 * @param sParentFolder
	 * @return
	 */
	public static String getTempName(String sParentFolder) {
		return getTempName(sParentFolder, "");
	}

	/**
	 * @param sParentFolder
	 * @param sSuffix
	 * @return
	 */
	public static String getTempName(String sParentFolder, String sSuffix) {
		@SuppressWarnings("unused")
		String AVAIL_CHARS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_";
		sParentFolder = PathUtil.format(sParentFolder);
		if (!sParentFolder.endsWith("/"))
			sParentFolder = sParentFolder + "/";
		String sNewName = "";
		File file;
		do {
			int nPos = (int) Math.floor((double) "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_".length() * Math.random());
			sNewName = sNewName + "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_".substring(nPos, nPos + 1);
			file = new File(sParentFolder + sNewName + sSuffix);
		} while (file.exists());
		return sNewName + sSuffix;
	}

	/**
	 * @param file
	 * @return
	 */
	public static long getSize(File file) {
		long lRet = 0L;
		if (!file.exists())
			return 0L;
		if (file.isDirectory()) {
			File files[] = file.listFiles();
			for (int i = 0; i < files.length; i++)
				lRet += getSize(files[i]);

		} else {
			return file.length();
		}
		return lRet;
	}

	/**
	 * @param sFileName
	 * @return
	 */
	public static long getSize(String sFileName) {
		File file = new File(sFileName);
		return getSize(file);
	}

	/**
	 * @param file
	 * @return
	 */
	public static String getSizeStr(File file) {
		long lSize = getSize(file);
		return toSizeStr(lSize);
	}

	/**
	 * @param sFileName
	 * @return
	 */
	public static String getSizeStr(String sFileName) {
		long lSize = getSize(sFileName);
		return toSizeStr(lSize);
	}

	/**
	 * @param lSize
	 * @return
	 */
	public static String toSizeStr(long lSize) {
		double d = 0.0D;
		if (lSize < 1024L)
			return lSize + " byte";
		if (lSize < 0x100000L) {
			d = (double) lSize / 1024D;
			return Math.floor(d * 100D) / 100D + " KB";
		}
		if (lSize < 0x40000000L) {
			d = (double) lSize / 1048576D;
			return Math.floor(d * 100D) / 100D + " M";
		} else {
			d = (double) lSize / 1073741824D;
			return Math.floor(d * 100D) / 100D + " G";
		}
	}

	/**
	 * @param sFileName
	 * @return
	 * @throws IOException
	 */
	public static String read(String sFileName) throws IOException {
		return read(sFileName, "ASCII");
	}

	/**
	 * @param sFileName
	 * @param sCharSet
	 * @return
	 * @throws IOException
	 */
	public static String read(String sFileName, String sCharSet) throws IOException {
		File file = new File(sFileName);
		if (!file.exists())
			return "";
		byte b[];
		RandomAccessFile raf = new RandomAccessFile(file, "r");
		b = new byte[(int) file.length()];
		raf.read(b);
		return new String(b);
	}

	/**
	 * @param sFileName
	 * @param sContent
	 * @return
	 */
	public static boolean write(String sFileName, String sContent) {
		try {
			File f = new File(sFileName);
			if (f.exists())
				f.delete();
			RandomAccessFile file = new RandomAccessFile(sFileName, "rw");
			file.write(sContent.getBytes());
			file.close();
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
		return true;
	}

	/**
	 * 删除文件夹
	 * 
	 * @param folderPath
	 *            文件夹完整绝对路径
	 */
	public static void delFolder(String folderPath) {
		try {
			delAllFile(folderPath); // 删除完里面所有内容
			String filePath = folderPath;
			filePath = filePath.toString();
			java.io.File myFilePath = new java.io.File(filePath);
			myFilePath.delete(); // 删除空文件夹
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * 删除指定文件夹下所有文件
	 * 
	 * @param path
	 *            文件夹完整绝对路径
	 * @return
	 */
	public static boolean delAllFile(String path) {
		boolean flag = false;
		File file = new File(path);
		if (!file.exists()) {
			return flag;
		}
		if (!file.isDirectory()) {
			return flag;
		}
		String[] tempList = file.list();
		File temp = null;
		for (int i = 0; i < tempList.length; i++) {
			if (path.endsWith(File.separator)) {
				temp = new File(path + tempList[i]);
			} else {
				temp = new File(path + File.separator + tempList[i]);
			}
			if (temp.isFile()) {
				temp.delete();
			}
			if (temp.isDirectory()) {
				delAllFile(path + "/" + tempList[i]);// 先删除文件夹里面的文件
				delFolder(path + "/" + tempList[i]);// 再删除空文件夹
				flag = true;
			}
		}
		return flag;
	}

	/**
	 * 获取指定文件目录下的文件名列表
	 * 
	 * @param strDir
	 * @param tmpExtend
	 * @return
	 */
	public static String getFolderFileNameList(String strDir, String tmpExtend) {
		StringBuffer sb = new StringBuffer();
		File objFile = new File(strDir);
		File list[] = objFile.listFiles();
		String tmpFileName = "";
		for (int i = 0; i < list.length; i++) {
			tmpFileName = list[i].getName();
			if (list[i].isFile()) {
				tmpExtend = PathUtil.getFileExtName(tmpFileName);
				if (tmpExtend.toUpperCase().indexOf(tmpExtend.toUpperCase()) > -1) {
					sb.append(tmpFileName + "\n");
				}
			}
		}
		return sb.toString();
	}

	/**
	 * 获取指定文件目录下的文件目录名列表
	 * 
	 * @param strDir
	 * @return
	 */
	public static String getFolderNameList(String strDir) {
		StringBuffer sb = new StringBuffer();
		File objFile = new File(strDir);
		File list[] = objFile.listFiles();
		String tmpFileName = "";
		for (int i = 0; i < list.length; i++) {
			tmpFileName = list[i].getName();
			if (list[i].isDirectory()) {
				System.out.println(tmpFileName);
			}
		}
		return sb.toString();
	}

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// 复制单个文件
		String src = "\\\\10.10.3.3\\d\\WebPub\\netArticle\\Upload_2007\\XueJinBo_72024152010968_4.doc";
		String dest = "c:\\d\1.doc";
		// System.out.println(FileUtils.createFolder("c:\\d"));
		// src =
		// "\\\\10.10.3.3\\d\\WebPub\\netArticle\\Upload_2006\\ZongDaWei_72021152012127_2.doc";
		// dest =
		// "\\\\10.10.3.120\\d\\uploadFiles\\article\\1\\ZongDaWei_72021152012127_2.doc";
// System.out.println(FileUtils.copyFile(src, dest));
		src = "w:\\mp4";
		System.out.println(getFolderFileNameList(src, ".mp4"));

	}

}
