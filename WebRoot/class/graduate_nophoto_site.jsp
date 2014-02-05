<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
	String keys = StringUtil.nullValue(request.getParameter("key"), "");
	sql = " SELECT ps.id,si.student_name ";
	sql += " ,si.register_id ";
	sql += " ,si.[admission_no] ";
	sql += " ,si.batch_code ";
	sql += " ,rs.title as bj ";
	sql += " ,rs2.title as bmd ";
	sql += " ,rm.title as zy ";
	sql += " ,case  si.learning_level_code when 1 then '高起本'  when 2 then '本科' else '专科' end as cc ";
	sql += " ,si.mobile ";
	sql += "   FROM [swufe_ems].[dbo].[graduate_nophoto_stu] as ps ";
	sql += "   inner join [swufe_online].[dbo].[student_info] as si on si.student_id=ps.student_id ";
	sql += "   inner join [swufe_online].[dbo].recruit_site as rs on rs.site_code=si.bj_code and rs.learning_type_code=si.learning_type_code and rs.batch_code=si.batch_code ";
	sql += "   inner join [swufe_online].[dbo].recruit_site as rs2 on rs2.site_code=si.bmd_code and rs2.learning_type_code=si.learning_type_code and rs2.batch_code=si.batch_code ";
	sql += "   inner join [swufe_online].[dbo].recruit_major as rm on rm.major_code=si.zy_code and rm.learning_type_code=si.learning_type_code and rm.batch_code=si.batch_code ";
	sql += "   where  si.bj_code='"+curr_bj_bm+"' and isnull(si.learning_status,0) =0 and si.class_no is not null ";
	
	if (!"".equals(keys)) {
		sql += " AND (si.register_id  LIKE '%" + keys + "%' OR si.[admission_no] LIKE '%" + keys + "%' OR si.[student_name] LIKE '%" + keys + "%')";
	}
	
	try {
		switch (ActionID){
					
		case 3://导出
		rs = Data.executeQuery(sql);
		if (rs.next()) {
			String filename=java.net.URLEncoder.encode(curr_bj_mc+"毕业生未采集照片名单","UTF-8")+".xls";
			response.setHeader("Content-Type","application/vnd.ms-excel");
			response.setHeader("Content-disposition","attachment; filename="+filename);
			out.clear();
		    out.print("<html xmlns:x=\"urn:schemas-microsoft-com:office:excel\">");
	        out.print(" <head>");
	        out.print(" <!--[if gte mso 9]><xml>");
	        out.print("<x:ExcelWorkbook>");
	        out.print("<x:ExcelWorksheets>");
	        out.print("<x:ExcelWorksheet>");
	        out.print("<x:Name></x:Name>"); 
	        out.print("<x:WorksheetOptions>");
	        out.print("<x:Print>");            
	        out.print("<x:ValidPrinterInfo />");
	        out.print(" </x:Print>"); 
	        out.print("</x:WorksheetOptions>");
	        out.print("</x:ExcelWorksheet>");
	        out.print("</x:ExcelWorksheets>");
	        out.print("</x:ExcelWorkbook>");
	        out.print("</xml>");
	        out.print("<![endif]-->"); 
	        out.print(" </head>"); 
	        out.print("<body>");
				out.print("<table>");
				out.print("	<tr>");
				out.print("		<th>姓名</th>");
				out.print("		<th>学号</th>");
				out.print("		<th>注册号</th>");
				out.print("		<th>年级</th>");
				out.print("		<th>专业</th>");
				out.print("		<th>站点</th>");
				out.print("		<th>报名点</th>");
				out.print("		<th>手机</th>");
				out.print("	</tr>");
				do {
					out.print("	<tr >");
					out.print("		<td>" + rs.getString("student_name") + "</td>");
					out.print("		<td>&nbsp;" + rs.getString("register_id") + "</td>");
					out.print("		<td>&nbsp;" + rs.getString("admission_no") + "</td>");
					out.print("		<td>&nbsp;" + rs.getString("batch_code") + "</td>");
					out.print("		<td>" + rs.getString("zy") + "</td>");
					out.print("		<td>" + rs.getString("bj") + "</td>");
					out.print("		<td>" + rs.getString("bmd") + "</td>");
					out.print("		<td>&nbsp;" + rs.getString("mobile") + "</td>");
					out.print("	</tr>");
				} while (rs.next());
				out.print("</table>");
			
			out.print("</body>");
	        out.print("</html>");
			
		} else {
			sb.append("没有数据！");
		}
		break;
		case 2:
			tblName = "( " + sql + ") tmp";
			strGetFields = "*";
			strWhere = " 1=1 ";
			strOrder = " id desc";
			String startStr = request.getParameter("start");
			String limitStr = request.getParameter("limit");
			int start = 0;
			if (startStr != null) {
				start = Integer.parseInt(startStr);
			}
			if (limitStr != null) {
				pageSize = Integer.parseInt(limitStr);
			}
			int pageIndex = 1;
			pageIndex = start / pageSize + 1;
			sb.append(Data.queryJSON(tblName, strGetFields, strWhere, strOrder, pageIndex, pageSize, "list", true, false));
			break;
		case 1:
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>毕业生缺少照片数据</title>
<%@ include file="../ext-3.3.0.jsp" %>
<script type="text/javascript">
	Ext.onReady(function(){
		var pageHeight = document.body.clientHeight;
		var tbar = new Ext.Toolbar({
		items: ['-', {
			text: '刷新',
			iconCls: 'myicon my_refresh',
			handler: function(){
				grid.store.reload();
			}
		},'-', new netedu.search({
			width:200,
			emptyText: '输入学号、姓名、注册号查询...',
			_t1Click: function(){
				//
				grid.store.setBaseParam('key', "");
				grid.store.load();
			},
			_t2Click: function(){
				grid.store.setBaseParam('key', this.getValue());
				grid.store.load();
			}
		}),'-',{
			text: '导出本页数据',
			iconCls: 'myicon my_excel2',
			handler: function(){
				grid.initExport()
			}
		},'-',{
			text: '下载全部数据',
			iconCls: 'myicon my_rar',
			handler: function(){
				window.open('<%=ModName%>.jsp?Action=3&r='+Math.random());
			}
		}]
	});
		var sm = new Ext.grid.CheckboxSelectionModel();
		var cm = new Ext.grid.ColumnModel([new Ext.grid.RowNumberer({
			width: 45
		}), sm, {
			"sortable": true,
			"dataIndex": "student_name",
			"header": "姓名",
			width: 100,
			fixed: true,
			renderer:function(v){
				return "<div>"+v+"</div>"
			}
		}, {
			"sortable": true,
			"dataIndex": "register_id",
			"header": "学号",
			width: 100,
			fixed: true,
			renderer:function(v){
				return "<div>"+v+"</div>"
			}
		}, {
			"sortable": true,
			"dataIndex": "admission_no",
			"header": "注册号",
			width: 150,
			fixed: true,
			renderer:function(v){
				return "<div>"+v+"</div>"
			}
		}, {
			"sortable": true,
			"dataIndex": "batch_code",
			"header": "年级"
		}, {
			"sortable": true,
			"dataIndex": "zy",
			"header": "专业"
		}, {
			"sortable": true,
			"dataIndex": "bj",
			"header": "站点"
		}, {
			"sortable": true,
			"dataIndex": "bmd",
			"header": "报名点"
		}, {
			"sortable": true,
			"dataIndex": "mobile",
			"header": "手机"
		}])
		var grid = new netedu.grid({
			tbar: tbar,
			renderTo: 'ct',
			border: false,
			autoHeight: false,
			cm: cm,
			sm:sm,
			height: pageHeight,
			_pageSize: Math.floor((pageHeight - 20) / 23)
		})
		grid.store.load();
	function ok(){
		if (win) win.close();
		grid.store.reload();
	}
	function add(){
		if (win) win.close();
		win = new netedu.formWin({
			width: 400,
			title: '添加单个数据',
			_it: [ new Ext.form.TextField({
				name:'fields',
				fieldLabel: '学号或注册号',
				name: 'values',
				allowBlank:false
			})],
			_url: '<%=ModName%>_update.jsp?Action=7',
			_suc: ok
		});
		win.show();
	}
	function insert(){
		if (grid.store.getCount()>0&&!confirm("导入数据将会删除目前已有的数据，是否继续？ ")) {
			 return; 
		}
		if (win) win.close();
		win = new netedu.formWin({
			width: 700,
			title: '导入数据',
			_it: [ new Ext.form.TextField({
				name:'fields',
				value: '按行分割的注册号',
				fieldLabel: '数据格式',
				disabled:true
			}), new Ext.form.TextArea({
				name: 'values',
				height: 300,
				fieldLabel: '学员数据',
				allowBlank:false
			})],
			_url: '<%=ModName%>_update.jsp?Action=6',
			_suc: ok
		});
		win.show();
	}
	});
</script>
</head>
<body>
	
<div id='ct' class='my_grid'></div>
</body>
</html>
<%
	break;
		}
	} catch (Exception e) {
		out.print(e.toString());
	} finally {
		Data.close();
		out.print(sb.toString());
	}
%>