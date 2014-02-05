package com.swufe.toolkit;

import javax.servlet.jsp.PageContext;
import java.io.File;
import java.util.Enumeration;
import javax.servlet.http.HttpServletRequest;
import com.oreilly.servlet.MultipartRequest;
import com.oreilly.servlet.multipart.FileRenamePolicy;
public class UploadUtils {
	@SuppressWarnings("unused")
	private static final String CONTENT_TYPE = "text/html; charset=UTF-8";
	public static String sPrompt = "";
	public static String sFileName = "";
	public static String sFileType = "";
	public static String sFileSize = "";
	
	//改写文件命名策略
	public static class FileRenameUtil implements FileRenamePolicy {
                @Override
		public File rename(File file) {
			String body = DateUtil.showDateTodayFormat("yyyyMMdd") + StringUtil.randomString(5, "0123456789");
			String ext =PathUtil.getFileExtName(file.getName()).toLowerCase();
			String newName = body +"."+ ext;
			file = new File(file.getParent(), newName);//对文件进行重命名
			return file;
		}
	}
	public static boolean attachmentUploadFile(PageContext pageContext, String saveurl) {
		return attachmentUploadFile(pageContext,saveurl,5*1024 * 1024);
	}
	public static boolean attachmentUploadFile(PageContext pageContext, String saveurl,int maxPostSize) {
		//这里都只考虑到单文件上传，如果是多文件同时上传，为了便于控制结果，建议在客户端分批异步上传，见文档管理。
		boolean bRet = false;
		MultipartRequest multirequest = null;
		String imgType = "jpg,jpeg,gif,png";
		String folder = DateUtil.showDateTodayFormat("yyyy-MM-dd");
		saveurl += folder + "/";
		File fileDir = new File(saveurl);
		if (!fileDir.exists()) {
			fileDir.mkdirs();
		}
		// 上传文件重命名策略
		FileRenamePolicy  rfrp = new FileRenameUtil();  
		try {
			multirequest = new MultipartRequest((HttpServletRequest)pageContext.getRequest(), saveurl, maxPostSize, "utf-8",rfrp); // GBK中文编码模式上传文件
			Enumeration<String> filedFileNames = multirequest.getFileNames();
			String filedName = null;
			if (null != filedFileNames) {
				while (filedFileNames.hasMoreElements()) {
					filedName = filedFileNames.nextElement();// 文件文本框的名称
					// 获取该文件框中上传的文件，即对应到上传到服务器中的文件
					File uploadFile = multirequest.getFile(filedName);
					if (null != uploadFile && uploadFile.length() > 0) {
						bRet = true;//上传成功
						sFileSize=Long.toString(uploadFile.length()/1024);//单位为K
						sFileName=folder+"/"+uploadFile.getName();
						sFileType=PathUtil.getFileExtName(sFileName).toLowerCase();
						if (imgType.indexOf(sFileType) >= 0)
							sFileType = "image";
					}
					// 获取未重命名的文件名称
					//String Originalname = multirequest.getOriginalFileName(filedName);
				}
				multirequest = null;
			}
		} catch (Exception e) {
			sPrompt=e.toString();
		}
		return  bRet;
	}
}
