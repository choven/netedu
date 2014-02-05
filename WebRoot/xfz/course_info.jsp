<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
	try {
	switch (ActionID) {
		case 4:
			sql = "SELECT code as value, title AS text";
			sql += " FROM dbo.[xfz_course_class] ";
			sb.append(Data.queryJSON(sql, "list", true));
			break;
		case 3:
			sql = "SELECT code as value, title AS text";
			sql += " FROM dbo.[xfz_exam_type] ";
			sb.append(Data.queryJSON(sql, "list", true));
			break;
		case 2:
			String keys = StringUtil.nullValue(request.getParameter("key"), "");
			String status = StringUtil.nullValue(request.getParameter("status"), "");
			String class_code = StringUtil.nullValue(request.getParameter("class_code"), "");
			sql = " SELECT c.[id] ";
			sql += "       ,c.[code] ";
			sql += "       ,c.[title] ";
			sql += "       ,c.[short] ";
			sql += "       ,c.[py] ";
			sql += "       ,c.[base_xf] ";
			sql += "       ,c.[base_xs],c.base_exam_type,e.title as exam_type,c.course_class_code,cs.title as  course_class";
			sql += "       ,c.[status] ";
			sql += "       ,convert(varchar(10),c.created_date,120) as created_date ";
			sql += "       ,c.[created_user] ";
			sql += "   FROM [swufe_ems].[dbo].[xfz_course_info] c ";
			sql += "   left join  [swufe_ems].[dbo].xfz_exam_type e on e.code=c.base_exam_type" ;
			sql += "   left join  [swufe_ems].[dbo].xfz_course_class cs on cs.code=c.course_class_code" ;
			sql += " WHERE 1=1";
			if (!"".equals(keys)) {
				sql += " AND (c.code LIKE '%" + keys + "%' OR c.title LIKE '%" + keys + "%' OR c.py LIKE '%" + keys + "%')";
			}
			if (!"".equals(status)) {
				sql += " AND  c.status='"+status+"'";
			}
			if (!"".equals(class_code)) {
				sql += " AND  c.course_class_code='"+class_code+"'";
			}
			out.print(Data.queryJSON(sql, "order by code desc", request));
			break;
		case 1:
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>西财在线</title>
<%@ include file="../ext-3.3.0.jsp" %>
<script language="javascript" type="text/javascript" src="/file/js/py.js"></script>
<script type="text/javascript">
	var win, it1, it2, it3, it4, it5, it6, it7
	Ext.onReady(function(){
		var pageHeight=document.body.clientHeight;
		var typeStore=new Ext.data.JsonStore({
				url: '<%=ModName%>.jsp?Action=3',
				autoLoad: true
		})
		var classStore=new Ext.data.JsonStore({
				url: '<%=ModName%>.jsp?Action=4',
				autoLoad: true
		})
		var statusStore=new Ext.data.SimpleStore({
					fields:['text','value'],
					data:[['启用','1'],['禁用','0']]
				})
		var tbar=new Ext.Toolbar({
			items: [ '-',{
				text:'添加',
				iconCls:'myicon my_add2',
				handler:add
			},'-',{
				text:'编辑',
				iconCls:'myicon my_edit',
				handler:edit
			},'-', '课程搜索','-',new netedu.search({
				emptyText:'输入关键字查询...',
				_t1Click:function(){
					//
					grid.store.setBaseParam('key', "");
					grid.store.load();
				},
				_t2Click:function(){
					grid.store.setBaseParam('key', this.getValue());
					grid.store.load();
				}
			}),'-','状态筛选','-',new netedu.comb({
				store: statusStore,
				width:120,
				allowBlank: true,
				listeners:{
					'select':function(){
					grid.store.setBaseParam('status', this.getValue());
					grid.store.load();
					}
				}
			}),'-','分类筛选','-',new netedu.comb({
				store: classStore,
				width:120,
				allowBlank: true,
				listeners:{
					'select':function(){
					grid.store.setBaseParam('class_code', this.getValue());
					grid.store.load();
					}
				}
			}),'-',{
				text:'清空条件',iconCls:'myicon my_refresh',
				handler:function(){
					window.location.reload();
				}
			},'->','-',{
				text:'禁用',
				iconCls:'myicon my_del',
				handler:function(){
					grid.initDel('id','<%=ModName%>_update.jsp?Action=5',ok)
				}
			},'-',{
				text:'导出数据',
				iconCls:'myicon my_excel2',
				handler:function(){
					grid.initExport()
				}
			}]
		});
		var sm = new Ext.grid.CheckboxSelectionModel();
		var cm = new Ext.grid.ColumnModel([new Ext.grid.RowNumberer({
			width: 45
		}), sm, {
			"sortable": true,
			"dataIndex": "code",
			"header": "代码",
			width: 100,
			fixed: true,
			renderer:function(v){
				return "<div>"+v+"</div>"
			}
		}, {
			"sortable": true,
			"dataIndex": "title",
			"header": "名称",
			renderer:function(v){
				return "<div>"+v+"</div>"
			}
		}, {
			"sortable": true,
			"dataIndex": "py",
			"header": "拼音",
			width: 100,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "base_xf",
			"header": "基本学分",
			width: 80,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "base_xs",
			"header": "基本学时",
			width: 80,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "exam_type",
			"header": "考核类型",
			width: 80,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "course_class",
			"header": "课程分类",
			width: 80,
			fixed: true
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
			"header": "添加时间",
			width: 80,
			fixed: true
		}, {
			"sortable": true,
			"dataIndex": "created_user",
			"header": "添加人",
			width: 80,
			fixed: true
		}])
		var grid=new netedu.grid({
			tbar:tbar,
			cm:cm,
			sm:sm,
			renderTo:'<%=ModName%>_content',
			border:false,
			autoHeight:false,
			height:pageHeight,
			_pageSize:Math.floor((pageHeight - 20) / 23)
		});
		grid.store.load();
		grid.on('rowdblclick', edit);
		function formIt(){
			it1=new Ext.form.TextField({
				fieldLabel:'代码',
				name:'code',
				allowBlank:false
			});
			it2=new Ext.form.TextField({
				fieldLabel:'名称',
				name:'title',
				allowBlank:false,
				listeners:{
					'change':function(){
						it3.setValue(getFirstSpell(this.getValue()))
					},
					'blur':function(){
						it3.setValue(getFirstSpell(this.getValue()))
					}
				}
			});
			it3=new Ext.form.TextField({
				fieldLabel:'拼音',
				name:'py',
				allowBlank:false
			});
			it4 = new Ext.form.NumberField({
				fieldLabel: '基本学分',
				name: 'base_xf',
				allowBlank: false,
				allowDecimals: true,//
				allowNegative: false
			});
			
			it5 = new Ext.form.NumberField({
				fieldLabel: '基本学时',
				name: 'base_xs',
				allowBlank: false,
				allowDecimals: true,//
				allowNegative: false
			});
			it6 =new netedu.comb({
				store: typeStore,
				allowBlank: false,
				fieldLabel: '基本考试类型',
				name: 'base_exam_type'
			})
			
			it7=new netedu.comb({
				store:statusStore,
				fieldLabel:'是否启用',
				name:'status',
				value:1
			
			})
			it8 =new netedu.comb({
				tpl: '<tpl for="."><div class="x-combo-list-item">{text}（{value}）</div></tpl>',
				store: classStore,
				allowBlank: false,
				fieldLabel: '课程分类',
				name: 'course_class_code',
				listeners:{
					'select':function(){
						if(this.getValue()!=it1.getValue().substring(0,1)){
							alert("课程代码必须与课程分类相匹配！第一位请设置为"+this.getValue())
						}
					}
				}
			})
			return [it1,it2,it3,it4,it5,it6,it8,it7]
		}
		function ok(){
			if (win) win.close();
			grid.store.reload();
		}
		function add(){
			if (win) win.close();
			win=new netedu.formWin({
				title:'添加用户',
				_it:formIt(),
				_url:'<%=ModName%>_update.jsp?Action=3',
				_id:'',
				_suc:ok
			});
			win.show();
		}
		function edit(){
			var rows=grid.initSeChk(1);
			if (!rows) return false;
			if (win) win.close();
			pkid=rows[0].get('id');
			win=new netedu.formWin({
				title:'编辑信息',
				width:400,
				_it:formIt(),
				_url:'<%=ModName%>_update.jsp?Action=4',
				_id:pkid,
				_suc:ok
			});
			it1.setReadOnly(true);
			win.items.itemAt(0).getForm().loadRecord(rows[0]);
			win.show();
		}
	});
</script>
<style type="text/css">
#l div{padding-top:5px;}
</style>
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