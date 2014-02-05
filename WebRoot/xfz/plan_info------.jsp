<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
	String keys = StringUtil.nullValue(request.getParameter("key"), "");
	String zy = StringUtil.nullValue(request.getParameter("zy"), "");
	status = StringUtil.nullValue(request.getParameter("status"), "4");
	try {
		switch (ActionID) {
		case 3:
			sql = "SELECT major_code AS value,status ";
			sql += " , CASE WHEN learning_level_code='1' THEN '高起本' WHEN learning_level_code='2' THEN '专升本' ELSE '专科' END+title+CASE WHEN LEN(major_direction)>0 THEN '('+major_direction+')' ELSE '' END AS text ";
			sql += " from [swufe_online].[dbo].[major_info]   where status=1 order by  learning_level_code, title";
			sb.append(Data.queryJSON(sql, "list", true));
			break;
		case 2:
			sql = " SELECT p.id ";
			sql += "       ,p.title ";
			sql += "       ,p.base_major_code ";
			sql += "       ,CONVERT(varchar(16),p.created_date,111) as created_date,p.status ";
			sql += "       ,pd.max_xq ,pd.kc,pd.xf,pa.times";
			sql += "   FROM swufe_ems.dbo.xfz_plan_info as p ";
			sql += "   left join (SELECT  MAX(xq) as max_xq,count(1) as kc,sum(xf) as xf, plan_id ";
			sql += "   			FROM swufe_ems.dbo.xfz_plan_detail where is_open=1 group by plan_id  ) as pd on p.id=pd.plan_id ";
			sql += "  left join (select plan_id,count(1) as times from [swufe_ems].[dbo].[xfz_plan_apply] group by plan_id) as pa  on pa.plan_id=p.id ";
			sql += " WHERE 1=1 ";
			//out.print(sql);
			if (!"".equals(zy)) {
				sql += " AND  p.base_major_code = '" + zy + "' ";
			}
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
		if (!login.hasUrlPerm()) {
			out.print("没有权限访问此功能");
			return;
		}
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>教学计划</title>
<%@ include file="../ext-3.3.0.jsp" %>
<script type="text/javascript">
	var win, it1, it2, it3, it4, it5, it6, it7
	Ext.onReady(function(){
		var pageHeight = document.body.clientHeight;
		var majorStore = new Ext.data.JsonStore({
			url: '<%=ModName%>.jsp?Action=3',
			autoLoad: true
		})
		var tbar = new Ext.Toolbar({
			items: ['-', {
				text: '<div class="myicon my_find" style="text-indent:18px;line-height:18px;">按专业筛选：</div>',
				xtype: 'tbtext'
			}, new netedu.comb({
				store: majorStore,
				allowBlank: true,
				id: 'opt_zy',
				_clear: true,
				tpl: '<tpl for="."><div class="x-combo-list-item <tpl if="status!=1"> gray</tpl>">{[xindex]}、{text}</div></tpl>',
				listeners: {
					'select': function(){
						grid.store.setBaseParam('zy', this.getValue());
						grid.store.load();
					},
					'clear': function(){
						grid.store.setBaseParam('zy', '');
						grid.store.load();
					}
				}
			
			}), '-', new Ext.Toolbar.SplitButton({
				id: 'opt_op',
				text: '操作菜单',
				handler: function(){
					this.showMenu();
				},
				iconCls: 'myicon my_edit',
				menu: {
					items: [{
						text: '<span class=ext-color-1>复制选中计划</span>',
						handler: copy
					}, {
						text: '<span class=ext-color-2>编辑选中计划</span>',
						handler: edit
					}, {
						text: '<span class=ext-color-2>删除选中计划</span>',
						handler: del
					}]
				}
			}), '-', new Ext.Toolbar.SplitButton({
				text: '查看菜单',
				id: 'opt_view',
				handler: function(){
					this.showMenu();
				},
				iconCls: 'myicon my_search2',
				menu: {
					items: [{
						text: '<span class=ext-color-1>查看计划详情</span>',
						handler: function(){
							view(1)
						}
					}, {
						text: '<span class=ext-color-2>查看使用的专业</span>',
						handler: function(){
							view(2)
						}
					}, {
						text: '<span class=ext-color-2>查看相关版本</span>',
						handler: function(){
							view(3)
						}
					}]
				}
			}), '-', {
				text: '版本对比',
				iconCls: 'myicon my_ok2',
				handler: function(){
					var oRows = grid.getSelectionModel().getSelections();
					if (oRows.length < 2) {
						alert("请先选择至少两个教学计划进行比较")
						return '';
					}
					var str = [];
					for (var i = 0; i < oRows.length; i++) {
						str.push(oRows[i].get('plan_id'));
					}
					window.parent.openApp("plan_compare", "plan/plan_compare.jsp?plan_id="+str.toString(), "教学计划版本对比", false, true)
				}
			}]
		});
		var sm = new Ext.grid.CheckboxSelectionModel();
		var cm = new Ext.grid.ColumnModel([new Ext.grid.RowNumberer({
			width: 45
		}), sm, {
			"sortable": true,
			"dataIndex": "id",
			"header": "代码",
			width: 60,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "title",
			"header": "名称"
		}, {
			"sortable": true,
			"dataIndex": "times",
			"header": "使用次数",
			width: 80,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "kc",
			"header": "有效课程",
			width: 80,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "xf",
			"header": "有效学分",
			width: 80,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "max_xq",
			width: 80,
			fixed: true,
			"header": "最大学期"
		}, {
			"sortable": true,
			"dataIndex": "status",
			"header": "状态",
			width: 80,
			fixed: true,
			renderer:FormatTrueFalse
		}, {
			"sortable": true,
			"dataIndex": "created_date",
			"header": "创建时间",
			fixed: true,
			width: 100
		}])
		var grid = new netedu.grid({
			tbar: tbar,
			renderTo: '<%=ModName%>_content',
			border: false,
			autoHeight: false,
			height: pageHeight,
			_pageSize: Math.floor((pageHeight - 20) / 23),
			cm: cm,
			sm: sm
		});
		grid.store.load();
		grid.on('rowdblclick', edit);
		function copy(){
			var rows = grid.initSeChk(1);
			if (!rows) return false;
			if (!confirm("确认要复制”" + rows[0].data.title + "”么？")) { return; }
			fn_btn_ajax('<%=ModName%>_update.jsp?&Action=3', 'id=' + rows[0].data.id,ok);
		}
		function edit(){
			var rows = grid.initSeChk(1);
			if (!rows) return false;
			Ext.getCmp("opt_op").hideMenu();
			window.parent.openApp("plan_edit", "xfz/plan_edit.jsp?id=" + rows[0].data.id, "编辑教学计划", false, true)
		}
		function del(){
			var rows = grid.initSeChk(1);
			if (!rows) return false;
			if (!confirm("确认要删除”" + rows[0].data.title + "”么？")) { return; }
			fn_btn_ajax('<%=ModName%>_update.jsp?&Action=5', 'id=' + rows[0].data.id, function(){
				grid.store.load();
			})
		}
		function chk(){
		
		}
		function view(n){
			var rows = grid.initSeChk(1);
			if (!rows) return false;
			switch (n) {
				case 3://清除前面的数据过滤
					Ext.getCmp("opt_zy").setValue(rows[0].data.zy_bm)
					grid.store.setBaseParam('zy', rows[0].data.zy_bm);
					Ext.getCmp('opt_show').setValue(4);
					grid.store.setBaseParam('status', 4);
					grid.store.load();
					return;case 1:
					Ext.getCmp("opt_view").hideMenu();
					window.parent.openApp("plan_view", "plan/plan_view.jsp?plan_id=" + rows[0].data.plan_id, "查看教学计划", false, true)
					return;		}
		}
		function ok(){
			//if (win) win.close();
			grid.store.reload();
		}
	});
</script>
</head>
<body>
<div id='<%=ModName%>_content' class='my_grid'></div>
<div id='win'></div>
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