<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>

<%
	String apply_level = StringUtil.nullValue(request.getParameter("apply_level"), "1");
	String the_xq = StringUtil.nullValue(request.getParameter("xq"));
	try {
		switch (ActionID) {
		case 8://平时成绩
			sql = "SELECT id as value ,title as text ";
			sql += " FROM [xfz_score_policy]";
			sb.append(Data.queryJSON(sql, "list", true));
			break;
		case 7://考试方式
			sql = "SELECT code as value ,title as text ";
			sql += " FROM [xfz_exam_type]";
			sb.append(Data.queryJSON(sql, "list", true));
			break;
		case 6://课程类型
			sql = "SELECT code as value ,title as text,status ";
			sql += " FROM xfz_course_type order by status desc,id ";
			sb.append(Data.queryJSON(sql, "list", true));
			break;
		case 5://培养要求
			sql = "SELECT id as value ,title as text,status ";
			sql += " FROM xfz_xf_require order by status desc,id desc";
			sb.append(Data.queryJSON(sql, "list", true));
			break;
		case 4://课程
	

			sql = " SELECT code AS value, title AS text,base_xf,base_xs,base_exam_type ";
			sql += " FROM  [swufe_ems].[dbo].[xfz_course_info] ";
			sql += " WHERE  (code LIKE '%" + query + "%' OR title LIKE '%" + query + "%' OR py LIKE '%" + query + "%')  ";
			sql += "  AND status=1 ";
			if(!"5".equals(apply_level)){//apply_level=5时为自主教学计划，非自主教学计划，仅显示代码为1或2打头的课程。
				sql += "   AND  course_class_code < 3";
			}
                        out.print(Data.queryJSON(sql, "order by value desc", request));
			break;
		case 3:
			sql = "SELECT p.title,p.xf_require_id,p.is_pub,ti.xq ";
			sql += " FROM xfz_plan_info   p ";
			sql += "   left join(select MAX(recruit_major_id)as recruit_major_id ,plan_id from  [swufe_ems].[dbo].[xfz_plan_apply]  where recruit_major_id is not null group by plan_id) ";
			sql += " 		 pa on pa.plan_id=p.id ";
			sql += "   left join swufe_online.dbo.recruit_major  rm on rm.recruit_major_id=pa.recruit_major_id ";
			sql += "   left join [swufe_ems].[dbo].xfz_term_info  ti on ti.batch_code=rm.batch_code and  ti.learning_type_code=rm.learning_type_code and ti.is_curr=1 ";
			sql += "  WHERE p.id='" + id + "' ";
			sb.append(Data.queryJSON(sql, "list", true));
			break;
		case 2:
			sql = " SELECT pd.id, pd.course_code, pd.course_name, pd.course_type_code, pd.xq, pd.xf, pd.xs, pd.exam_type, pd.is_open,pd.score_policy_id,sp.title as sptitle";
			//sql += " ,p.title as plan_title,p.xf_require_id ";
			sql += " ,t.title as course_type_name,xf.is_optional,xf.min_xf ";
			sql += " FROM xfz_plan_detail pd ";
			sql += " inner join xfz_plan_info p on p.id=pd.plan_id ";
			sql += " inner join xfz_course_type t on t.code=pd.course_type_code ";
			sql += " left join xfz_score_policy sp on sp.id=pd.score_policy_id ";
			sql += " left join xfz_xf_require_detail xf on xf.require_id=p.xf_require_id and xf.course_type_code=pd.course_type_code ";
			sql += " WHERE pd.plan_id='" + id + "'    ";
			if(!"".equals(the_xq)){
				sql += "   AND  pd.xq='"+the_xq+"'";
			}
			sql += " order by pd.course_type_code,pd.xq,pd.course_code  ";
			sb.append(Data.queryJSON(sql, "list", true));
			break;
		case 1:
		if (!login.hasPerm("xfz_modify_basic_data")) {
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
var win, it1, it2, it3, it4, it5, it6, it7, xq=0,apply_level=<%=apply_level%>,v1=0,v2=0;

Ext.onReady(function(){
	var pageHeight = document.body.clientHeight;
	var rs2;
	var infoStore = new Ext.data.JsonStore({
		url: '<%=ModName%>.jsp?Action=3&id=<%=id%>',
		autoLoad: false,
		listeners: {
			'load': function(store, rs){
				if (rs.length > 0) {
					rs2 = rs;
					document.getElementById("title").innerHTML = rs2[0].data.title;
					xq=rs2[0].data.xq;
					if(rs2[0].data.is_pub==1){
						Ext.getCmp("btn_pub").setDisabled(true);
						if (apply_level > 1) {
							Ext.getCmp("btn_del").setDisabled(true);
							Ext.getCmp("btn_edit2").setDisabled(true);
						}
					}
				}
			}
		}
	})
	var spStore = new Ext.data.JsonStore({
		url: '<%=ModName%>.jsp?Action=8',
		autoLoad: true
	})
		var examStore = new Ext.data.JsonStore({
		url: '<%=ModName%>.jsp?Action=7',
		autoLoad: true
	})
	var typeStore = new Ext.data.JsonStore({
		url: '<%=ModName%>.jsp?Action=6',
		autoLoad: true
	})
	var tbar = new Ext.Toolbar({
		items: ['-',{
			text: '按学期分组',
			iconCls: 'myicon my_unchecked',
			handler: function(){
				v1=v1^1;
				if(v1==1){
					this.setIconClass("myicon my_checked");
					grid.store.groupBy('xq');
				}else{
					this.setIconClass("myicon my_unchecked");
					grid.store.groupBy('course_type_code');
				}
			}
		}, '-',{
			text: '只看当前学期',
			iconCls: 'myicon my_unchecked',
			handler: function(){
				v1=v1^1;
				if(v1==1){
					this.setIconClass("myicon my_checked");
					grid.store.setBaseParam('xq', xq);
					grid.store.load();
				}else{
					this.setIconClass("myicon my_unchecked");
					grid.store.setBaseParam('xq', '');
					grid.store.load();
				}
			}
		},{
			text: '添加课程',
			iconCls: 'myicon my_add2',
			handler: add
		}, '-', {
			text: '修改课程',
			iconCls: 'myicon my_edit',
			handler: edit
		}, '-', {
			text: '删除课程',
			iconCls: 'myicon my_del',
			id:'btn_del',
			handler: function(){
				if(rs2[0].data.is_pub==1&&apply_level>1){
					alert("该计划已发布，不允许删除课程！");
					return;
				}
				grid.initDel('id', 'plan_info_update.jsp?Action=8&plan_id=<%=id%>', ok);
			}
		}, '-', {
			text: '培养要求',
			iconCls: 'myicon my_edit2',
			id:'btn_edit2',
			handler: edit2
		}, '-', {
			text: '发布',
			iconCls: 'myicon my_save',
			id:'btn_pub',
			handler: pub
		}, '-', {
			text: '校验',
			iconCls: 'myicon my_ok2',
			handler: validatePlan
		},'->', '<span id="title"></span>']
	});
	var sm = new Ext.grid.CheckboxSelectionModel();
	var cm = new Ext.grid.ColumnModel([new Ext.grid.RowNumberer({
		width: 45
	}), sm, {
		"sortable": true,
		"dataIndex": "course_code",
		"header": "课程代码",
		width: 80,
		fixed: true
	}, {
		"sortable": true,
		"dataIndex": "course_name",
		"header": "课程名称"
	}, {
		"sortable": true,
		"dataIndex": "course_type_code",
		"header": "课程类型",
		renderer: function(v, m, r){
			return r.data.course_type_name+'/'+v+'/<span class=red>'+( r.data.is_optional==1?"选修":"必修")+'</span>/要求学分<span class=red>'+r.data.min_xf+'</span>';
		}
	}, {
		"sortable": true,
		"dataIndex": "xq",
		"header": "学期",
		width: 80,
		fixed: true
	}, {
		"sortable": true,
		"dataIndex": "xf",
		"header": "学分",
		width: 80,
		fixed: true
	}/*, {
		"sortable": true,
		"dataIndex": "xs",
		"header": "学时",
		width: 80,
		fixed: true
	}*/, {
		"sortable": true,
		"dataIndex": "exam_type",
		"header": "是否考试",
		fixed: true,
		width: 80,
		renderer: FormatYesNo
	}, {
		"sortable": true,
		"dataIndex": "sptitle",
		"header": "平时成绩",
		fixed: true,
		width: 80
	}, {
		"sortable": true,
		"dataIndex": "is_open",
		"header": "是否开放",
		fixed: true,
		width: 80,
		renderer: FormatYesNo
	}, {
		"sortable": true,
		"dataIndex": "xq",
		"header": "行课情况",
		fixed: true,
		width: 80,
		hidden:(apply_level==1),
		renderer: function(v){
			if(v==0){
				return "<span class=gray>不定学期</span>";
			}
			return (v>xq?"<span class=red>未行课</span>":"<span class=green>已行课</span>")
		}
	}])
	var grid = new netedu.grid({
		tbar: tbar,
		store: new Ext.data.GroupingStore({
			url: '<%=ModName%>.jsp?Action=2&id=<%=id%>',
			reader: new Ext.data.JsonReader(),
			autoLoad: true,
			groupField: 'course_type_code'
		}),
		renderTo: '<%=ModName%>_content',
		border: false,
		autoHeight: false,
		height: pageHeight,
		_groupTpl: '{[values.rs[0].course_type_name]}{text}/共有{[values.rs.length]} 门课程',
		cm: cm,
		sm: sm,
		listeners: {
			'afterrender': function(){
				infoStore.load();
			}
		}
	});
	grid.on('rowdblclick', edit);
	function edit2(){
		if(rs2[0].data.is_pub==1&&apply_level>1){
			alert("该计划已发布，不允许重设培养要求！");
			return;
		}
		if (win) win.close();
		win = new netedu.formWin({
			title: rs2[0].data.title,
			_it: [new netedu.comb({
				tpl: '<tpl for="."><div class="x-combo-list-item <tpl if="status!=1"> gray</tpl>">{[xindex]}、{text}</div></tpl>',
				store: new Ext.data.JsonStore({
					url: '<%=ModName%>.jsp?Action=5',
					autoLoad: true
				}),
				fieldLabel: '培养要求',
				name: 'xf_require_id',
				allowBlank: false,
				listeners: {
					'afterrender': function(i){
						this.store.load({
							callback: function(){
								i.setValue(rs2[0].data.xf_require_id)
							}
						})
					}
				}
			})],
			_url: 'plan_info_update.jsp?Action=4',
			_id: '<%=id%>',
			_suc: ok
		});
		win.show();
	}

	function it(){
		it1=new netedu.comb({
			tpl: '<tpl for="."><div class="x-combo-list-item">{[xindex]}、{text}（{value}）</div></tpl>',
			store: new Ext.data.JsonStore({
				url: 'plan_edit.jsp?Action=4&id=<%=id%>&apply_level=<%=apply_level%>',
				autoLoad: false
			}),
			fieldLabel: '选择课程',
			name: 'course_code',
			allowBlank: false,
			editable: true,
			pageSize: 10,
			mode: 'remote',
			listeners: {
				'select': function(c, r, i){
					it2.setValue(this.getRawValue());
					it4.setValue(r.data.base_xf);
					it5.setValue(r.data.base_xs);
					it6.setValue(r.data.base_exam_type);
				}
			},
			emptyText: '用关键字查询...'
		});
		it2= new Ext.form.TextField({
			fieldLabel: '课程名称',
			name: 'course_name',
			allowBlank: false
		});
		it3=new netedu.comb({
			tpl: '<tpl for="."><div class="x-combo-list-item <tpl if="status!=1"> gray</tpl>">{[xindex]}、{text}</div></tpl>',
				store:typeStore,
				fieldLabel:'课程类型',
				name:'course_type_code',
				allowBlank: false
			})
		it4= new Ext.form.NumberField({
			fieldLabel: '课程学分',
			name: 'xf',
			allowDecimals: false, //小数
			allowNegative: false //负数
		})
		it5=new Ext.form.NumberField({
			fieldLabel: '课程学时',
			name: 'xs',
			allowDecimals: false, //小数
			allowNegative: false //负数
		})
		it6=new netedu.comb({
				store:examStore,
				fieldLabel:'考核方式',
				name:'exam_type',
				allowBlank: false
			})
		it9=new netedu.comb({
				store:spStore,
				fieldLabel:'平时成绩',
				name:'score_policy_id',
				allowBlank: false,
				value:2
			})	
		it7= new Ext.form.NumberField({
			fieldLabel: '开设学期',
			name: 'xq',
			allowDecimals: false, 
			allowNegative: false ,
			value:0,	
			listeners: {
				'change': function(){
					if(this.getValue()!=0&&this.getValue()<=xq&&apply_level>1&&rs2[0].data.is_pub==1){//已开学期
						alert("该计划已行课至第"+xq+"学期，请勿在之前添加课程！")
						this.setValue(0);
					}
				}
			}
		})
		it8=new netedu.comb({
				store:new Ext.data.SimpleStore({
					fields:['text','value'],
					data:[['开放','1'],['不开放','0']]
				}),
				fieldLabel:'是否开放',
				name:'is_open',
				allowBlank: false,
				value:1
			})
		return [it1,it2,it4,it5,it6,it9,it3,it7,it8]
	}
	function add(){
		if (win) win.close();
		win = new netedu.formWin({
			title: '添加课程',
			_it: it(),
			_url: 'plan_info_update.jsp?Action=6',
			_id: '<%=id%>',
			_suc: ok
		});
		win.show();
	}
	function edit(){
		var rows = grid.initSeChk(1);
		if (!rows) return false;
		//注意这里，已经开放选课的课程不允许修改数据。
		if(rows[0].data.xq!=0&&rows[0].data.xq<=xq&&apply_level>1&&rs2[0].data.is_pub==1){
			alert("该计划已行课至第"+xq+"学期，禁止修改已开课课程！");
			return;
		}
		if (win) win.close();
		win = new netedu.formWin({
			title: '修改课程',
			_it: it(),
			_url: 'plan_info_update.jsp?Action=7&plan_id=<%=id%>',
			_id: rows[0].data.id,
			_suc: ok
		});
		win.show();
		win.items.itemAt(0).getForm().loadRecord(rows[0]);
		//it1.doQuery("GS",true);
		it1.setRawValue(rows[0].data.course_name);
	}
	function validatePlan(){
			fn_btn_ajax('plan_view.jsp?Action=5', 'id=<%=id%>', function(){
				alert("该计划通过校验！")
		});
	}
	function pub(){
		if(rs2[0].data.is_pub==1){
			alert("该计划已发布，不需重新发布");
			return;
		}
		fn_btn_ajax('plan_view.jsp?Action=5', 'id=<%=id%>', function(){
			if (!confirm("发布计划后，你将失去清除该计划、删除课程、重设培养要求的功能！点击确定继续！")) { return; }
			fn_btn_ajax('plan_info_update.jsp?Action=15', 'id=<%=id%>', function(){
				Ext.getCmp("btn_pub").setDisabled(true);
				Ext.getCmp("btn_del").setDisabled(true);
				Ext.getCmp("btn_edit2").setDisabled(true);
			});
		});
	}
	function ok(){
		if (win) win.close();
		grid.store.reload();
	}
});
</script>
<style>
#title {
	color: red;
	text-indent: 10px;
}
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