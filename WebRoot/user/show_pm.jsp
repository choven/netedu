<%@page contentType="text/html;charset=UTF-8" %>
<%@ include file="../baseParameter.jsp" %>
<%
    ResultSet rs;
    String id = StringUtil.nullValue(request.getParameter("id"), "");
    sql = " SELECT title,content,is_readed,uidTo ";
    sql += " FROM system_sms ";
    sql += " WHERE id='" + id + "' and  (uidTo='" + login.getUserId() + "'  or uidFrom='" + login.getUserId() + "') and status=1";
    try {
        rs = Data.executeQuery(sql);
        if (rs != null && rs.next()) {
            if (rs.getInt("is_readed") == 0 && rs.getString("uidTo").equals(login.getUserId())) {
                Data.executeUpdate("UPDATE system_sms SET  is_readed=1 where id='" + id + "'");
            }
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <html>
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
            <title>西财在线--<%=rs.getString("title")%></title>
            <style>
                #content{font-size:12px;padding-top:12px;}
                *{
                    font-family:Arial, Helvetica,sans-serif;
                    font-size:12px;
                    line-height:24px;
                }
                html,body{
                    margin:0;
                    padding:0;
                }
                a:link{
                    text-decoration:none;
                    color:#000;
                }
                a:visited{
                    text-decoration:none;
                    color:#000;
                }
                a:active{
                    text-decoration:underline;
                    color:red;
                }
                a:hover{
                    text-decoration:underline;
                    color:red;	
                }
                h3,ul,form{
                    padding:0;
                    margin:0;
                }
                img{border:none;margin:0;}
                /*常用*/
                .red{color: red;}
                .green{color: green;}
                .left{float:left;}
                .clear{clear:both;}
                .right{float:right;}
                .block{display:block;}
                .b{font-weight:600}
                .none{display:none;}
                .hide{visibility: hidden;}

                .ct{
                    padding:5px;
                    text-indent:24px;
                }
            </style>
        </head>
        <body>
            <div class='ct'><%=rs.getString("content")%></div>
        </body>
    </html>
    <%
            rs.close();
            } else {
                out.print("<font size=2>您所访问的内容不存在!</font>");
            }
        } catch (Exception e) {
            out.print(e.toString());
        } finally {
            Data.close();
        }
    %>
