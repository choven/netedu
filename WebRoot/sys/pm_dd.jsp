<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
    String table = stringUtil.nullValue(request.getParameter("table"));
    sql = " SELECT   id=a.colorder, pro_id=g.major_id ,";
    sql += "   table_name= d.name , ";
    // sql += "  表说明=case   when   a.colorder=1   then   isnull(cast(f.value as varchar),'')   else   ''   end , ";
    sql += "   c_字段名=a.name, ";
    sql += "   c_标识=case   when   COLUMNPROPERTY(   a.id,a.name,'IsIdentity')=1   then   '√' else   ''   end, ";
    sql += "   c_主键=case   when   exists(SELECT   1   FROM   sysobjects   where   xtype='PK'   and   name   in   ( ";
    sql += "   SELECT   name   FROM   sysindexes   WHERE   indid   in( ";
    sql += "   SELECT   indid   FROM   sysindexkeys   WHERE   id   =   a.id   AND   colid=a.colid ";
    sql += "   )))   then   '√'   else   ''   end, ";
    sql += "   c_类型=b.name, ";
    // sql += "   c_占用字节数=a.length, ";
    sql += "   c_长度=COLUMNPROPERTY(a.id,a.name,'PRECISION'), ";
    //sql += "   c_小数位数=isnull(COLUMNPROPERTY(a.id,a.name,'Scale'),0), ";
    sql += "   c_允许空=case   when   a.isnullable=1   then   '√' else   ''   end, ";
    sql += "   c_默认值=isnull(e.text,''),";
    sql += "  c_字段说明=isnull(cast(g.[value] as varchar),'')  ";
    sql += "   FROM   syscolumns   a ";
    sql += "   left   join   systypes   b   on   a.xtype=b.xusertype ";
    sql += "   inner   join   sysobjects   d   on   a.id=d.id     and   d.xtype='U'   and     d.name<>'dtproperties' ";
    sql += "   left   join   syscomments   e   on   a.cdefault=e.id ";
    sql += "   left   join   sys.extended_properties g   on   a.id=g.major_id   and   a.colid=g.minor_id ";
    sql += "   left   join   sys.extended_properties f   on   d.id=f.major_id   and   f.minor_id   =0 ";
    sql += "   where   d.name='" + table + "' ";
    sql += "   order   by   a.id,a.colorder ";
    try {
        switch (ActionID) {
            case 3:
                sql = "   select d.name as value, d.name+ '：'+cast(isnull(f.value,'') as varchar) as text from sysobjects d ";
                sql += "   left   join   sys.extended_properties f   on   d.id=f.major_id   and   f.minor_id   =0 ";
                sql += "   where d.xtype='U'   and     d.name<>'dtproperties' ";
                sql += "   order by d.name ";
                out.print(Data.queryJSON(sql, "list", true));
                break;
            case 2:
                out.print(Data.queryJSON(sql));
                break;
            case 1:
                if (!login.hasUrlPerm()) {
                    out.print("没有权限访问此功能");
                    return;
                }
                String cm = Data.getCMByDB(sql);
%>
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>用户管理</title>
        <%@ include file="../ext-3.3.0.jsp" %>
        <script type="text/javascript">
            var win, it1, it2, it3, it4, it5, it6, it7
            Ext.onReady(function() {
                var pageHeight = document.body.clientHeight;
                var table = "user_info";
                var tableComb = new netedu.comb({
                    tpl: '<tpl for="."><div class="x-combo-list-item">{[xindex]}、{text}</div></tpl>',
                    allowBlank: false,
                    store: new Ext.data.JsonStore({
                        url: '<%=ModName%>.jsp?Action=3',
                        autoLoad: false
                    }),
                    width: 220,
                    listeners: {
                        'select': function() {
                            grid.store.setBaseParam('table', this.getValue());
                            grid.store.load();
                        }
                    }
                })
                var tbar = new Ext.Toolbar({
                    items: ['-', {
                            text: '刷新', iconCls: 'myicon my_refresh',
                            handler: function() {
                                grid.store.reload();
                            }
                        }, '-', tableComb, '->', {
                            text: '导出数据',
                            iconCls: 'myicon my_excel2',
                            handler: function() {
                                grid.initExport()
                            }
                        }]
                });
                var grid = new netedu.grid({
                    tbar: tbar,
                    renderTo: '<%=ModName%>_content',
                    border: false,
                    autoHeight: false,
                    height: pageHeight,
                    _cm: '<%=cm%>'
                });
                var editor = new Ext.grid.GridEditor(new Ext.form.TextField({
                    allowBlank: true
                }), {
                    ignoreNoChange: true,
                    completeOnEnter: true,
                    cancelOnEsc: true
                });
                var cm = grid.getColumnModel();
                cm.setEditor(cm.findColumnIndex('c_字段说明'), editor);
                grid.on('afteredit', function(e){
                    var actionId=4;//修改
                    if( e.record.get("pro_id")==""){
                        actionId=3;//创建
                    }
                  fn_btn_ajax('pm_update.jsp?&Action='+actionId, 'title='  + e.value +'&table=' +  e.record.get('table_name') + '&column=' +  e.record.get('c_字段名'),  function(){grid.store.reload()})
                }, this );
                tableComb.store.load({
                    callback: function() {
                        grid.store.setBaseParam('table', table);
                        grid.store.load();
                        tableComb.setValue(table);
                    }
                });
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
    }
%>