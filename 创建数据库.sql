USE swufe_netedu
--�û���
CREATE TABLE [dbo].[user_info](
	id int IDENTITY (1,1),
	[user_id] [varchar](50) NOT NULL  PRIMARY KEY ,
	[login_name] [varchar](50)  NOT NULL UNIQUE,
	[pwd] [varchar](50) NOT NULL,
	[user_name] [varchar](50) NOT NULL,
	[user_setting] [varchar](500) NULL,
	[user_type_id] [tinyint] NOT NULL ,
	[site_code] [varchar](50) NULL,
	[mobile] [varchar](20) NULL,
	[email] [varchar](200) NULL,
	[photo_url] [varchar](200) NULL,
	[last_login] [datetime] NULL,
	[last_logout] [datetime] NULL,
	[online_flag] [tinyint] NULL,
	[remark] [varchar](200) NULL,
	[uTimes] [int] NULL  DEFAULT(0),
	[created_date] [datetime] NULL DEFAULT(getdate()),
	[created_user] [varchar](50) NULL,
	[status] [tinyint] NULL DEFAULT (1),
) 
go
--Ϊ�����������Ϣ 
exec sp_addextendedproperty N'MS_Description', '�û���Ϣ��', N'user', N'dbo', N'table', N'user_info', NULL, NULL  
--Ϊ�ֶ�a1���������Ϣ 
exec sp_addextendedproperty N'MS_Description', '˳���ţ���ʵ������', N'user', N'dbo', N'table', N'user_info', N'column', N'id'  
exec sp_addextendedproperty N'MS_Description', 'ϵͳ�˺ţ����ɸ���', N'user', N'dbo', N'table', N'user_info', N'column', N'user_id'  
exec sp_addextendedproperty N'MS_Description', '��½�˺�', N'user', N'dbo', N'table', N'user_info', N'column', N'login_name'  
exec sp_addextendedproperty N'MS_Description', '�˻����ͣ���ɫ', N'user', N'dbo', N'table', N'user_info', N'column', N'user_type_id'  

--�û�����
CREATE TABLE [dbo].[user_type](
	[id] [tinyint] NOT NULL PRIMARY KEY,
	[name] [varchar](50) NOT NULL,
	[remark] [varchar](200) NULL,
	[created_date] [datetime] NULL DEFAULT(getdate()),
	[created_user] [varchar](50) NULL,
	[status] [tinyint] NULL DEFAULT (1),
) 
exec sp_addextendedproperty N'MS_Description', '�û����ͣ���ɫ', N'user', N'dbo', N'table', N'user_type', NULL, NULL  

--�û���
CREATE TABLE [dbo].[user_group](
	[id] int NOT NULL PRIMARY KEY,
	[name] [varchar](50) NOT NULL,
	[remark] [varchar](200) NULL,
	[created_date] [datetime] NULL DEFAULT(getdate()),
	[created_user] [varchar](50) NULL,
	[status] [tinyint] NULL DEFAULT (1),
 )
 exec sp_addextendedproperty N'MS_Description', '�û���', N'user', N'dbo', N'table', N'user_group', NULL, NULL  
--�û����Ӧ�û�
CREATE TABLE [dbo].[user_group_user](
	[id] [int] IDENTITY(1,1) NOT NULL,
	user_id [varchar](50) NOT NULL,
	user_group_id [int] NOT NULL,
	[created_date] [datetime] NULL DEFAULT(getdate()),
	[created_user] [varchar](50) NULL,
	foreign key(user_id)references user_info(user_id),
	foreign key(user_group_id)references [user_group](id),
	CONSTRAINT [PK_user_group_user] PRIMARY KEY(user_id,user_group_id) 
)
 exec sp_addextendedproperty N'MS_Description', '���Ա', N'user', N'dbo', N'table', N'user_group_user', NULL, NULL  
 
 --�û��
 CREATE TABLE [dbo].[user_bind](
	[id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	user_id [varchar](50) NOT NULL,
	[bind_uid] [varchar](50) NOT NULL,
	[bind_title] [varchar](50) NULL,
	[bind_pwd] [varchar](50) NOT NULL,
	[bind_user_type] [varchar](20) NULL DEFAULT('admin'),
	[open_type] [tinyint] NULL DEFAULT(1),
	[created_date] [datetime] NULL DEFAULT(getdate()),  
	[status] [tinyint] Not NULL DEFAULT(1),
)
--ģ������

CREATE TABLE [dbo].[module_info](
	[id] [int] NOT NULL UNIQUE,
	[parent_id] [int] NOT NULL DEFAULT (-1),
	[name] [varchar](50) NOT NULL,
	[code] [varchar](50) NOT NULL PRIMARY KEY,
	[url] [varchar](100) NULL,
	[remark] [varchar](1000) NULL,
	[is_finish] [tinyint] NOT NULL DEFAULT (0),
	[is_public] [tinyint] NOT NULL DEFAULT (0),
	[is_blank] [tinyint] NOT NULL DEFAULT (0),
	[is_reload] [tinyint] NOT NULL DEFAULT (0),
	[type] [tinyint] NOT NULL DEFAULT (0),
	[iconCls] [varchar](200) NULL,
	[created_date] [datetime] NULL DEFAULT(getdate()),
	[create_user] [varchar](50) NULL,
	[status] [tinyint] NOT NULL DEFAULT (1),
)
 exec sp_addextendedproperty N'MS_Description', '����ģ��', N'user', N'dbo', N'table', N'module_info', NULL, NULL 
 exec sp_addextendedproperty N'MS_Description', '�Ƿ���Ȩ��', N'user', N'dbo', N'table', N'module_info', N'column', N'is_public' 
 exec sp_addextendedproperty N'MS_Description', '�Ƿ��������', N'user', N'dbo', N'table', N'module_info', N'column', N'is_blank'
 exec sp_addextendedproperty N'MS_Description', '�۽�ʱ�Ƿ�ˢ��', N'user', N'dbo', N'table', N'module_info', N'column', N'is_reload'    
 exec sp_addextendedproperty N'MS_Description', 'ģ������:0���ܣ�1Ȩ��', N'user', N'dbo', N'table', N'module_info', N'column', N'type'  


--ģ�����
CREATE TABLE [dbo].[module_panel](
	[id] [int] NOT NULL PRIMARY KEY,
	[list_no] [int] NULL DEFAULT (1),
	[group_no] [int] NULL DEFAULT (1),
	[module_info_id] [int] NOT NULL,
	[parent_id] [int] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[keyword] [varchar](100) NULL,
	[remark] [varchar](1000) NULL,
	[iconCls] [varchar](200) NULL,
	[created_date] [datetime] NULL DEFAULT(getdate()),
	[create_user] [varchar](50) NULL,
	--foreign key(module_info_id)references module_info(id),
 )
 exec sp_addextendedproperty N'MS_Description', 'ģ����ʾ���', N'user', N'dbo', N'table', N'module_panel', NULL, NULL 

--Ȩ�޷���
CREATE TABLE [dbo].[user_perm](
	[id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	user_id [varchar](50) NULL,
	user_group_id int NULL,
	[is_user_group] [tinyint] NULL,
	[module_id] [int] NOT NULL,
	[created_date] [datetime] NULL DEFAULT(getdate()),
	[created_user] [varchar](50) NULL ,
	[status] [tinyint] NULL  DEFAULT (1),
	CONSTRAINT AK_user_perm UNIQUE(user_id,user_group_id,module_id) ,
	
	foreign key(user_id)references user_info(user_id),
	foreign key(user_group_id)references user_group(id),
	foreign key(module_id)references module_info(id),
)	
--��½��־

CREATE TABLE [dbo].[login_log](
	[id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[SessionID] [varchar](50) NULL,
	[user_id] [varchar](50) NULL,
	[user_name] [varchar](50) NULL,
	[in_time] [datetime] NULL  DEFAULT(getdate()),
	[out_time] [datetime] NULL,
	[stick_time] [int] NULL DEFAULT (0),
	[request_url] [varchar](400) NULL,
)

--ҳ�������־
CREATE TABLE [dbo].[page_click_log](
	[id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	user_id [varchar](50) NULL,
	user_name [varchar](50) NULL,
	user_agent [varchar](500) NULL,
	url [varchar](500) NULL,
	referer_url [varchar](1000) NULL,
	ip [varchar](100) NULL,
	created_date [datetime] NULL DEFAULT(getdate()),
)

--վ�ڶ���
CREATE TABLE [dbo].[system_sms](
	[id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[uidTo] [varchar](50) NOT NULL,
	[uidFrom] [varchar](50) NOT NULL,
	[title] [varchar](100) NOT NULL,
	[content] [varchar](max) NULL,
	[is_readed] [tinyint] NULL DEFAULT (0),
	[created_date] [datetime] NOT NULL DEFAULT(getdate()),
	[status] [tinyint] NULL DEFAULT (1),
)
--��������
CREATE TABLE [dbo].[help_center](
	[id] [int] IDENTITY(1,1) NOT NULL  PRIMARY KEY,
	[module_id] [int] NOT NULL,
	[title] [varchar](200) NULL,
	[ques_content] [varchar](2000) NULL,
	[ques_date] [datetime] NULL DEFAULT(getdate()),
	[ques_uid] [varchar](50) NULL,
	[sys_info] [varchar](2000) NULL,
	[ip] [varchar](50) NULL,
	[asw_content] [varchar](max) NULL,
	[asw_date] [datetime] NULL,
	[asw_uid] [varchar](50) NULL,
	[hits] [int] NULL DEFAULT (0),
	[status] [tinyint] NULL DEFAULT (1),
	[is_good] [tinyint] NULL DEFAULT (0),
	[is_system] [tinyint] NULL DEFAULT (0),
)

--��ӹ���Ա����
insert into [dbo].[user_type] (id,name) values(1,'ϵͳ����Ա')
--���ϵͳ������
insert into [dbo].[user_group] (id,name) values(1,'ϵͳ����')
--��ӹ���Ա�ʻ�
insert into [dbo].[user_info] (user_id,[login_name],pwd,[user_name],[user_type_id]) values('admin','admin','netedu','ϵͳ����Ա',1)
--Ϊ����Ա�ʻ���ӷ���
insert into [dbo].[user_group_user] (user_id,USER_GROUP_ID) values('admin','1')
--���ϵͳ����ģ��
;WITH T1 AS (
SELECT '91' AS [id] ,'-1' AS [parent_id] ,'ϵͳ����' AS [name] ,'0000000091' AS [class_id] ,'sys_mgr' AS [code] ,'' AS [url] ,'1' AS [is_finish] ,'0' AS [is_public] ,'0' AS [is_blank] ,'0' AS [is_reload] ,'0' AS [type] UNION 
SELECT '92' AS [id] ,'91' AS [parent_id] ,'���ܽڵ����' AS [name] ,'00000000910000000092' AS [class_id] ,'module_info' AS [code] ,'sys/module_info.jsp' AS [url] ,'1' AS [is_finish] ,'0' AS [is_public] ,'0' AS [is_blank] ,'0' AS [is_reload] ,'0' AS [type] UNION 
SELECT '93' AS [id] ,'91' AS [parent_id] ,'�û������' AS [name] ,'00000000910000000093' AS [class_id] ,'user_group_manage' AS [code] ,'sys/user_group_manage.jsp' AS [url] ,'1' AS [is_finish] ,'0' AS [is_public] ,'0' AS [is_blank] ,'0' AS [is_reload] ,'0' AS [type] UNION 
SELECT '94' AS [id] ,'91' AS [parent_id] ,'�û�����' AS [name] ,'00000000910000000094' AS [class_id] ,'user_manage' AS [code] ,'sys/user_manage.jsp' AS [url] ,'1' AS [is_finish] ,'0' AS [is_public] ,'0' AS [is_blank] ,'0' AS [is_reload] ,'0' AS [type] UNION 
SELECT '95' AS [id] ,'91' AS [parent_id] ,'Ȩ�޲�ѯ' AS [name] ,'00000000910000000095' AS [class_id] ,'perm_query' AS [code] ,'sys/perm_query.jsp' AS [url] ,'1' AS [is_finish] ,'0' AS [is_public] ,'0' AS [is_blank] ,'0' AS [is_reload] ,'0' AS [type] UNION 
SELECT '96' AS [id] ,'91' AS [parent_id] ,'Ȩ�޷���' AS [name] ,'00000000910000000096' AS [class_id] ,'user_perm' AS [code] ,'sys/user_perm.jsp' AS [url] ,'1' AS [is_finish] ,'0' AS [is_public] ,'0' AS [is_blank] ,'0' AS [is_reload] ,'0' AS [type] UNION 
SELECT '97' AS [id] ,'91' AS [parent_id] ,'���ʵ�¼��־' AS [name] ,'00000000910000000097' AS [class_id] ,'login_log' AS [code] ,'sys/login_log.jsp' AS [url] ,'1' AS [is_finish] ,'0' AS [is_public] ,'0' AS [is_blank] ,'0' AS [is_reload] ,'0' AS [type] UNION 

SELECT '98' AS [id] ,'91' AS [parent_id] ,'��Ŀ����API' AS [name] ,'00000000910000000097' AS [class_id] ,'pm_api' AS [code] ,'sys/pm_api.jsp' AS [url] ,'1' AS [is_finish] ,'0' AS [is_public] ,'0' AS [is_blank] ,'0' AS [is_reload] ,'0' AS [type] UNION 
SELECT '99' AS [id] ,'91' AS [parent_id] ,'��Ŀ�����ֵ�' AS [name] ,'00000000910000000097' AS [class_id] ,'pm_dd' AS [code] ,'sys/pm_dd.jsp' AS [url] ,'1' AS [is_finish] ,'0' AS [is_public] ,'0' AS [is_blank] ,'0' AS [is_reload] ,'0' AS [type] UNION 
SELECT '100' AS [id] ,'91' AS [parent_id] ,'���ݿ���ҵ����' AS [name] ,'00000000910000000097' AS [class_id] ,'pm_datajob' AS [code] ,'sys/pm_datajob.jsp' AS [url] ,'1' AS [is_finish] ,'0' AS [is_public] ,'0' AS [is_blank] ,'0' AS [is_reload] ,'0' AS [type] UNION 
SELECT '113' AS [id] ,'91' AS [parent_id] ,'�����������' AS [name] ,'00000000910000000113' AS [class_id] ,'module_panel' AS [code] ,'sys/module_panel.jsp' AS [url] ,'1' AS [is_finish] ,'0' AS [is_public] ,'0' AS [is_blank] ,'0' AS [is_reload] ,'0' AS [type] UNION 
SELECT '114' AS [id] ,'91' AS [parent_id] ,'�û����Ա����' AS [name] ,'00000000910000000114' AS [class_id] ,'user_group_user' AS [code] ,'sys/user_group_user.jsp' AS [url] ,'1' AS [is_finish] ,'0' AS [is_public] ,'0' AS [is_blank] ,'0' AS [is_reload] ,'0' AS [type] UNION 
SELECT '117' AS [id] ,'91' AS [parent_id] ,'�û����͹���' AS [name] ,'00000000910000000117' AS [class_id] ,'user_type' AS [code] ,'sys/user_type.jsp' AS [url] ,'1' AS [is_finish] ,'0' AS [is_public] ,'0' AS [is_blank] ,'0' AS [is_reload] ,'0' AS [type] UNION 
SELECT '118' AS [id] ,'91' AS [parent_id] ,'ҳ�������־' AS [name] ,'00000000910000000118' AS [class_id] ,'page_log' AS [code] ,'sys/page_log.jsp' AS [url] ,'1' AS [is_finish] ,'0' AS [is_public] ,'0' AS [is_blank] ,'0' AS [is_reload] ,'0' AS [type] UNION 
SELECT '127' AS [id] ,'-1' AS [parent_id] ,'�û��������' AS [name] ,'0000000127' AS [class_id] ,'user_control_panel' AS [code] ,'' AS [url] ,'1' AS [is_finish] ,'0' AS [is_public] ,'0' AS [is_blank] ,'0' AS [is_reload] ,'0' AS [type] UNION 
SELECT '128' AS [id] ,'127' AS [parent_id] ,'������Ϣ' AS [name] ,'00000001270000000128' AS [class_id] ,'user_info' AS [code] ,'' AS [url] ,'0' AS [is_finish] ,'1' AS [is_public] ,'0' AS [is_blank] ,'0' AS [is_reload] ,'0' AS [type] UNION 
SELECT '129' AS [id] ,'127' AS [parent_id] ,'�ҵ�վ����Ϣ' AS [name] ,'00000001270000000129' AS [class_id] ,'system_sms' AS [code] ,'user/system_sms.jsp' AS [url] ,'1' AS [is_finish] ,'1' AS [is_public] ,'0' AS [is_blank] ,'0' AS [is_reload] ,'0' AS [type] UNION 
SELECT '131' AS [id] ,'127' AS [parent_id] ,'�û��б�' AS [name] ,'00000001270000000131' AS [class_id] ,'user_list' AS [code] ,'user/user_list.jsp' AS [url] ,'1' AS [is_finish] ,'1' AS [is_public] ,'0' AS [is_blank] ,'0' AS [is_reload] ,'0' AS [type] UNION 
SELECT '132' AS [id] ,'127' AS [parent_id] ,'���Ի�����' AS [name] ,'00000001270000000132' AS [class_id] ,'user_setting' AS [code] ,'user/user_setting.jsp' AS [url] ,'1' AS [is_finish] ,'1' AS [is_public] ,'0' AS [is_blank] ,'0' AS [is_reload] ,'0' AS [type] UNION 
SELECT '133' AS [id] ,'127' AS [parent_id] ,'֧�����������' AS [name] ,'00000001270000000133' AS [class_id] ,'support_center' AS [code] ,'user/support.jsp' AS [url] ,'0' AS [is_finish] ,'1' AS [is_public] ,'0' AS [is_blank] ,'0' AS [is_reload] ,'0' AS [type] UNION 
SELECT '134' AS [id] ,'91' AS [parent_id] ,'ϵͳ��������' AS [name] ,'00000000910000000134' AS [class_id] ,'help_man' AS [code] ,'sys/help_man.jsp' AS [url] ,'1' AS [is_finish] ,'0' AS [is_public] ,'0' AS [is_blank] ,'0' AS [is_reload] ,'0' AS [type] UNION 
SELECT '135' AS [id] ,'91' AS [parent_id] ,'ϵͳ��ѯ����' AS [name] ,'00000000910000000135' AS [class_id] ,'faq_man' AS [code] ,'sys/faq_man.jsp' AS [url] ,'0' AS [is_finish] ,'0' AS [is_public] ,'0' AS [is_blank] ,'0' AS [is_reload] ,'0' AS [type] UNION 
SELECT '160' AS [id] ,'127' AS [parent_id] ,'�ʻ���' AS [name] ,'00000001270000000160' AS [class_id] ,'user_bind' AS [code] ,'user/user_bind.jsp' AS [url] ,'1' AS [is_finish] ,'1' AS [is_public] ,'0' AS [is_blank] ,'0' AS [is_reload] ,'0' AS [type] 
) 
insert into [dbo].[module_info] ([id],[parent_id],[name] ,[code],[url] ,[is_finish],[is_public],[is_blank],[is_reload] ,[type]) 
SELECT [id],[parent_id],[name] ,[code],[url] ,[is_finish],[is_public],[is_blank],[is_reload] ,[type] FROM T1;
--ע�����
;WITH T2 AS (
SELECT '1' AS [id] ,'1' AS [list_no] ,'0' AS [group_no] ,'-1' AS [module_info_id] ,'-1' AS [parent_id] ,'ϵͳ����' AS [name] UNION 
SELECT '19' AS [id] ,'1' AS [list_no] ,'1' AS [group_no] ,'94' AS [module_info_id] ,'1' AS [parent_id] ,'�û�����' AS [name] UNION 
SELECT '20' AS [id] ,'3' AS [list_no] ,'1' AS [group_no] ,'93' AS [module_info_id] ,'1' AS [parent_id] ,'�û������' AS [name] UNION 
SELECT '35' AS [id] ,'5' AS [list_no] ,'2' AS [group_no] ,'92' AS [module_info_id] ,'1' AS [parent_id] ,'���ܽڵ����' AS [name] UNION 
SELECT '36' AS [id] ,'7' AS [list_no] ,'2' AS [group_no] ,'96' AS [module_info_id] ,'1' AS [parent_id] ,'Ȩ�޷���' AS [name] UNION 
SELECT '37' AS [id] ,'8' AS [list_no] ,'2' AS [group_no] ,'95' AS [module_info_id] ,'1' AS [parent_id] ,'Ȩ�޲�ѯ' AS [name] UNION 
SELECT '38' AS [id] ,'11' AS [list_no] ,'3' AS [group_no] ,'97' AS [module_info_id] ,'1' AS [parent_id] ,'���ʵ�¼��־' AS [name] UNION 
SELECT '49' AS [id] ,'6' AS [list_no] ,'2' AS [group_no] ,'113' AS [module_info_id] ,'1' AS [parent_id] ,'�����������' AS [name] UNION 
SELECT '50' AS [id] ,'4' AS [list_no] ,'1' AS [group_no] ,'114' AS [module_info_id] ,'1' AS [parent_id] ,'���Ա����' AS [name] UNION 
SELECT '54' AS [id] ,'2' AS [list_no] ,'1' AS [group_no] ,'117' AS [module_info_id] ,'1' AS [parent_id] ,'�û����͹���' AS [name] UNION 
SELECT '55' AS [id] ,'12' AS [list_no] ,'3' AS [group_no] ,'118' AS [module_info_id] ,'1' AS [parent_id] ,'ҳ�������־' AS [name] UNION 
SELECT '56' AS [id] ,'1' AS [list_no] ,'4' AS [group_no] ,'98' AS [module_info_id] ,'1' AS [parent_id] ,'��Ŀ����API' AS [name] UNION 
SELECT '57' AS [id] ,'2' AS [list_no] ,'4' AS [group_no] ,'99' AS [module_info_id] ,'1' AS [parent_id] ,'��Ŀ�����ֵ�' AS [name] UNION 
SELECT '58' AS [id] ,'2' AS [list_no] ,'4' AS [group_no] ,'100' AS [module_info_id] ,'1' AS [parent_id] ,'���ݿ���ҵ����' AS [name] UNION 
SELECT '62' AS [id] ,'2' AS [list_no] ,'0' AS [group_no] ,'-1' AS [module_info_id] ,'-1' AS [parent_id] ,'�û��������' AS [name] UNION 
SELECT '63' AS [id] ,'1' AS [list_no] ,'0' AS [group_no] ,'128' AS [module_info_id] ,'62' AS [parent_id] ,'������Ϣ' AS [name] UNION 
SELECT '64' AS [id] ,'2' AS [list_no] ,'0' AS [group_no] ,'132' AS [module_info_id] ,'62' AS [parent_id] ,'���Ի�����' AS [name] UNION 
SELECT '65' AS [id] ,'3' AS [list_no] ,'0' AS [group_no] ,'129' AS [module_info_id] ,'62' AS [parent_id] ,'�ҵ�վ����Ϣ' AS [name] UNION 
SELECT '67' AS [id] ,'6' AS [list_no] ,'0' AS [group_no] ,'131' AS [module_info_id] ,'62' AS [parent_id] ,'�û��б�' AS [name] UNION 
SELECT '68' AS [id] ,'7' AS [list_no] ,'0' AS [group_no] ,'133' AS [module_info_id] ,'62' AS [parent_id] ,'֧�����������' AS [name] UNION 
SELECT '69' AS [id] ,'9' AS [list_no] ,'3' AS [group_no] ,'134' AS [module_info_id] ,'1' AS [parent_id] ,'ϵͳ��������' AS [name] UNION 
SELECT '70' AS [id] ,'10' AS [list_no] ,'3' AS [group_no] ,'135' AS [module_info_id] ,'1' AS [parent_id] ,'ϵͳ��ѯ����' AS [name] 
)
insert into [module_panel] (id,list_no,group_no,module_info_id,parent_id,name)
select id,list_no,group_no,module_info_id,parent_id,name  from T2
--Ϊϵͳ���������������Ȩ��
insert into [dbo].[user_perm]( [USER_GROUP_ID],[is_user_group],[module_id])
select '1' as USER_GROUP_ID, 1 as [is_user_group] , id as  [module_id]  from  [dbo].[module_info]  where  [is_public]=0
