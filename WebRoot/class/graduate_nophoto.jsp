<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
	if (!login.hasUrlPerm()) {
		out.print("没有权限访问此功能");
		return;
	}
	//String t = Data.queryScalar("select title from [ks_pc] where  ks_pc_bm='"+ks_pc+"'"); 
	//String info[][] = Data.queryArray("select  top 1 ks_kd_mc,kc_mc from ks_list_apply where ( exam_sign_id ='"+qdb+"' or ks_sign_bm ='"+qdb+"' ) and ks_pc_bm='"+ks_pc+"' ");   
	String keys = StringUtil.nullValue(request.getParameter("key"), "");
	sql = " SELECT ps.id,si.student_name ";
	sql += " ,si.register_id ";
	sql += " ,si.[admission_no] ";
	sql += " ,si.batch_code ";
	sql += " ,rs.title as bj ";
	sql += " ,rm.title as zy ";
	sql += " ,case  si.learning_level_code when 1 then '高起本'  when 2 then '本科' else '专科' end as cc ";
	sql += " ,si.mobile ";
	sql += "   FROM [swufe_ems].[dbo].[graduate_nophoto_stu] as ps ";
	sql += "   inner join [swufe_online].[dbo].[student_info] as si on si.student_id=ps.student_id ";
	sql += "   inner join [swufe_online].[dbo].recruit_site as rs on rs.site_code=si.bj_code and rs.learning_type_code=si.learning_type_code and rs.batch_code=si.batch_code ";
	sql += "   inner join [swufe_online].[dbo].recruit_major as rm on rm.major_code=si.zy_code and rm.learning_type_code=si.learning_type_code and rm.batch_code=si.batch_code ";
	sql += "   where 1=1 ";
	
	if (!"".equals(keys)) {
		sql += " AND (si.register_id  LIKE '%" + keys + "%' OR si.[admission_no] LIKE '%" + keys + "%' OR si.[student_name] LIKE '%" + keys + "%')";
	}
	
	try {
		switch (ActionID){
		case 2:
			tblName = "( " + sql + ") tmp";
			strGetFields = "*";
			strWhere = " 1=1 ";
			strOrder = " id  desc";
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
		}), '-', {
			text: '导入数据',
			iconCls: 'myicon my_excel2',
			handler: insert
		}, '-', {
			text: '添加单个数据',
			iconCls: 'myicon my_add2',
			handler: add
		}, '->',{
			text: '删除数据',
			iconCls: 'myicon my_del',
			handler: function(){
				grid.initDel('id', '<%=ModName%>_update.jsp?Action=5', ok)
			}
		},{
			text: '导出数据',
			iconCls: 'myicon my_excel2',
			handler: function(){
				grid.initExport()
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