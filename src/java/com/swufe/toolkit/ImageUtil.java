package com.swufe.toolkit;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import javax.swing.ImageIcon;

import com.sun.image.codec.jpeg.ImageFormatException;
import com.sun.image.codec.jpeg.JPEGCodec;
import com.sun.image.codec.jpeg.JPEGImageEncoder;

public class ImageUtil {

	/**
	 * 调整图片文件的大小为160*120
	 * 
	 * @param srcPath
	 * @param destPath
	 * @return
	 */
	public static boolean to160120(String srcPath, String destPath) {
		return toSize(srcPath, destPath, 160, 120);
	}

	/**
	 * 调整图片文件的大小为160*120
	 * 
	 * @param srcPath
	 * @param destPath
	 * @param _b
	 * @return
	 */
	public static boolean to160120(String srcPath, String destPath, boolean _b) {
		return toSize(srcPath, destPath, 160, 120, _b);
	}

	/**
	 * 调整图片文件的大小，直接使用指定尺寸
	 * 
	 * @param srcPath
	 * @param destPath
	 * @param _h
	 * @param _w
	 * @return
	 */
	public static boolean toSize(String srcPath, String destPath, int _h, int _w) {
		return toSize(srcPath, destPath, _h, _w, true);
	}

	/**
	 * 调整图片文件的大小
	 * 
	 * @param srcPath
	 * @param destPath
	 * @param _h
	 * @param _w
	 * @param _b
	 *            使用强制使用指定大小
	 * @return
	 */
	public static boolean toSize(String srcPath, String destPath, int _h, int _w, boolean _b) {
		java.io.File file = null;
		Image src = null;
		try {
			file = new java.io.File(srcPath);
			src = javax.imageio.ImageIO.read(file);
		} catch (IOException e) {
			System.out.println(srcPath + " 源文件未找到");
		}
		int old_w = src.getWidth(null);
		int old_h = src.getHeight(null);
		if (old_w > _w && old_h > _w) {
			int new_w = 0;
			int new_h = 0;
			if (_b == false) {
				float dCoefficient;
				if (old_w > old_h) {
					dCoefficient = old_w * 1f / _h;
				} else {
					dCoefficient = old_h * 1f / _h;
				}
				new_w = Math.round(old_w / dCoefficient);
				new_h = Math.round(old_h / dCoefficient);
			} else {
				new_w = _w;
				new_h = _h;
			}
			BufferedImage bi = new BufferedImage(new_w, new_h, BufferedImage.TYPE_INT_RGB);
			bi.getGraphics().drawImage(src, 0, 0, new_w, new_h, null);
			FileOutputStream newimage = null;
			try {
				newimage = new FileOutputStream(destPath);
				JPEGImageEncoder encoder = JPEGCodec.createJPEGEncoder(newimage);
				try {
					encoder.encode(bi);
				} catch (ImageFormatException e) {
					System.out.println("文件格式错误：" + e.toString());
				} catch (IOException e) {
					System.out.println("IOException错误：" + e.toString());
				}
				try {
					newimage.close();
				} catch (IOException e) {
					System.out.println("IOException错误：" + e.toString());
				}
			} catch (FileNotFoundException e) {
				System.out.println("FileNotFoundException错误：" + e.toString());
			}
		} else {
			if (!destPath.equalsIgnoreCase(srcPath)) {
				ImageUtil.CopyPicture(srcPath, destPath);
			}
		}
		return true;
	}

	/**
	 * 复制图片文件
	 * 
	 * @param srcPath
	 * @param destPath
	 */
	public static void CopyPicture(String srcPath, String destPath) {
		File file = null;
		FileInputStream fio = null;
		FileOutputStream fout = null;
		try {
			file = new File(srcPath);
			fio = new FileInputStream(file);
		} catch (FileNotFoundException e) {
			System.out.println("源文件没有找到：" + e.toString());
		}
		try {
			// 利用FileInputStream的read方法读入二进制文件并输出到另一个文件中
			// 这样我们可以完成文件的拷贝工作
			fout = new FileOutputStream(destPath);
		} catch (FileNotFoundException e) {
			System.out.println("目标文件没有找到文件" + e.toString());
		}
		int readCount = 0;
		byte[] buffer = new byte[1024];
		try {
			while ((readCount = fio.read(buffer)) >= 0)// 最多读取buffer的长度
			{
				fout.write(buffer, 0, readCount);
			}
			fio.close();
			fout.close();

		} catch (IOException e) {
			System.out.println("IOException: " + e.toString());
		}
	}

	/**
	 * 文件删除
	 * 
	 * @param filePath
	 */
	public static void DelImages(String filePath) {
		File file = null;
		file = new File(filePath);
		if (file.exists()) {
			file.delete();
		}
	}

	/**
	 * 获得图片文件的宽度和高度
	 * 
	 * @param fileName
	 * @return
	 */
	public static String getPhotoSize(String fileName) {
		String valStr = "";
		try {
			java.io.File file = new java.io.File(fileName); // 读入文件
			Image src = javax.imageio.ImageIO.read(file); // 构造Image对象
			int width = src.getWidth(null); // 得到图宽
			int height = src.getHeight(null); // 得到图长
			valStr = width + "×" + height;
			return valStr;
		} catch (Exception e) {
			System.out.print("Error：" + e.toString());
		}
		return valStr;
	}

	/**
	 * 获得宽度
	 * 
	 * @param fileName
	 * @return
	 */
	public static int getPhotoSizeX(String fileName) {
		int width = 0;
		try {
			java.io.File file = new java.io.File(fileName); // 读入文件
			Image src = javax.imageio.ImageIO.read(file); // 构造Image对象
			width = src.getWidth(null); // 得到图宽
		} catch (Exception e) {
			width = -1;
		}
		return width;
	}

	/**
	 * 获得高度
	 * 
	 * @param fileName
	 * @return
	 */
	public static int getPhotoSizeY(String fileName) {
		int height = 0;
		try {
			java.io.File file = new java.io.File(fileName); // 读入文件
			Image src = javax.imageio.ImageIO.read(file); // 构造Image对象
			height = src.getHeight(null); // 得到图长
		} catch (Exception e) {
			height = -1;
		}
		return height;
	}

	/**
	 * @param srcFileName
	 * @return
	 */
	/**
	 * @param srcFileName
	 * @return
	 */
	public static boolean resize_zoom(String srcFileName) {
		return true;
	}

	private static final int WIDTH = 50; // 缩略图宽度
	private static final int HEIGHT = 50;// 缩略图高度

	/**
	 * @param srcFileName
	 * @return
	 */
	public static BufferedImage zoom(String srcFileName) {
		// 使用源图像文件名创建ImageIcon对象。
		ImageIcon imgIcon = new ImageIcon(srcFileName);
		// 得到Image对象。
		Image img = imgIcon.getImage();
		return zoom(img);
	}

	/**
	 * @param srcImage
	 * @return
	 */
	public static BufferedImage zoom(Image srcImage) {
		// 构造一个预定义的图像类型的BufferedImage对象。
		BufferedImage buffImg = new BufferedImage(WIDTH, HEIGHT, BufferedImage.TYPE_INT_RGB);
		// buffImg.flush();
		// 创建Graphics2D对象，用于在BufferedImage对象上绘图。
		Graphics2D g = buffImg.createGraphics();

		// 设置图形上下文的当前颜色为白色。
		g.setColor(Color.WHITE);
		// 用图形上下文的当前颜色填充指定的矩形区域。
		g.fillRect(0, 0, WIDTH, HEIGHT);
		// 按照缩放的大小在BufferedImage对象上绘制原始图像。
		g.drawImage(srcImage, 0, 0, WIDTH, HEIGHT, null);
		// 释放图形上下文使用的系统资源。
		g.dispose();
		// 刷新此 Image 对象正在使用的所有可重构的资源.
		srcImage.flush();

		return buffImg;
	}

	/**
	 * 生成缩略图
	 * 
	 * @param url
	 * @param w
	 * @param h
	 * @param thumbnailUrl
	 */
	public static void getToThumbnail(String url, int w, int h, String thumbnailUrl) {
		url = url.replace("\\", "/");
		String[] urls = url.split(",");
		for (int i = 0; i < urls.length; i++) {
			//thumbnailUrl = urls[i].substring(0, url.indexOf("d") + 10);
			//thumbnailUrl = thumbnailUrl + "/thumbnail" + urls[i].substring(url.indexOf("d") + 10, urls[i].length());
			File dirFile = new File(thumbnailUrl.substring(0, thumbnailUrl.lastIndexOf("/")));
			if (!dirFile.exists()) { // 判断文件夹是否存在，不存在则创建它
				dirFile.mkdirs();
			}
			try {
				File _file = new File(urls[i]); // 读入文件
				Image src = javax.imageio.ImageIO.read(_file); // 构造Image对象
				int wideth = src.getWidth(null); // 得到源图宽
				int height = src.getHeight(null); // 得到源图长
				if (wideth < w) {
					w = wideth;
				}
				if (height < h) {
					h = height;
				}
				BufferedImage tag = new BufferedImage(w, h, BufferedImage.TYPE_INT_RGB);
				tag.getGraphics().drawImage(src, 0, 0, w, h, null); // 绘制缩小后的图
				FileOutputStream out = new FileOutputStream(thumbnailUrl); // 输出到文件流
				JPEGImageEncoder encoder = JPEGCodec.createJPEGEncoder(out);
				encoder.encode(tag); // 近JPEG编码
				out.close();
			} catch (Exception e) {
				System.out.println(e.toString());
			}
		}
	}

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		String fileName = "";
		fileName = "D:/webapp/ssos/WebRoot/gallery/spss_01/DSC03500.JPG.jpg";
		ImageUtil.getToThumbnail(fileName, 50,50, "c:/1.jpg");
	}

}
