-- ticket ���� ����
ALTER SESSION SET "_ORACLE_SCRIPT"=true;
CREATE USER ticket IDENTIFIED BY ticket;
GRANT CONNECT, RESOURCE TO ticket;
GRANT UNLIMITED TABLESPACE TO ticket;


-- �з� �ڵ�
CREATE TABLE code_list(
     comm_cd      VARCHAR2(4)   PRIMARY KEY  --�з��ڵ�
    ,comm_nm      VARCHAR2(16)               --�о߸�
    ,comm_parent  VARCHAR2(4)                
);


-- ��ȭ���� api
CREATE TABLE culture(
     comm_cd              VARCHAR2(4)       --�з��׸�            
    ,title                VARCHAR2(1000)    --����         
    ,poster               VARCHAR2(1000)    --�̹���(����� �ּ�)     
    ,period_date          VARCHAR2(50)      --�Ⱓ      
    ,addr                 VARCHAR2(1000)    --��� 
    ,culture_description  CLOB
    ,CONSTRAINT fk_culture_comm_cd FOREIGN KEY (comm_cd) REFERENCES code_list(comm_cd)
);


-- ������ũ Ƽ�� ũ�Ѹ�
CREATE TABLE ip_ticket(
     comm_cd     VARCHAR2(4)          --�з��׸�
    ,title       VARCHAR2(1000)       --����
    ,poster      VARCHAR2(1000)       --�̹���(����� �ּ�)
    ,period_date VARCHAR2(50)         --�Ⱓ
    ,addr         VARCHAR2(1000)      --���
    ,CONSTRAINT fk_ip_ticket_comm_cd FOREIGN KEY (comm_cd) REFERENCES code_list(comm_cd)
);


-- ȸ�� ����
CREATE TABLE members (
     mem_id         VARCHAR2(1000)    PRIMARY KEY         -- ȸ�� ID
    ,mem_pw         VARCHAR2(1000)    NOT NULL            -- ȸ�� ��й�ȣ
    ,mem_nm         VARCHAR2(1000)    NOT NULL            -- ȸ�� �̸�
    ,mem_nick       VARCHAR2(1000)    NOT NULL            -- ȸ�� �г���
    ,mem_addr       VARCHAR2(1000)    NOT NULL            -- ȸ�� ���� �ּ�
    ,profile_img    VARCHAR2(1000)                        -- ������ �̹��� URL �Ǵ� ���
    ,create_date    DATE              DEFAULT SYSDATE     -- ���� ������
    ,update_date    DATE              DEFAULT SYSDATE     -- ���� ������
    ,use_yn         VARCHAR2(1)       DEFAULT 'Y'         -- ��� ����(Y �Ǵ� N)
); 

-- ip_ticket, culture ���̺� ������ ���� id(PRIMARY KEY) �ο��� ���� ���ο� ���̺� ����
CREATE TABLE TB_TICKET AS 
SELECT rownum as ticket_no, COMM_CD,TITLE,POSTER,PERIOD_DATE,LOC
FROM (
        SELECT COMM_CD,TITLE,POSTER,PERIOD_DATE,LOC, substr(period_date,1,4) as yy
        FROM ip_ticket
        ORDER BY to_number(yy) ASC
     );


CREATE TABLE TB_CULTURE AS 
SELECT rownum as culture_no, COMM_CD,TITLE,POSTER,PERIOD_DATE,LOC,CULTURE_DESCRIPTION
FROM (
        SELECT COMM_CD,TITLE,POSTER,PERIOD_DATE,LOC,CULTURE_DESCRIPTION, substr(period_date,1,4) as yy
        FROM culture
        ORDER BY to_number(yy) ASC
      );

ALTER TABLE TB_TICKET ADD CONSTRAINT pk_ip_ticket_id PRIMARY KEY (ticket_no);
ALTER TABLE TB_CULTURE ADD CONSTRAINT pk_culture_id PRIMARY KEY (culture_no);


-- �ı� �ۼ� ���� ���� table
CREATE TABLE reviews(
      review_no     NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1 NOCACHE)
     ,mem_id        VARCHAR2(1000)          -- ȸ�� id
     ,ticket_no     NUMBER                  -- ������ũ Ƽ�� ���̺� id
     ,culture_no    NUMBER                  -- ��ȭ ���̺� id
     ,comm_code     VARCHAR2(4)             -- �з��ڵ�
     ,comm_name     VARCHAR2(16)            -- �з� �׸�
     ,title         VARCHAR2(1000)          -- ������
     ,poster        VARCHAR2(1000)          -- �̹���(����� �ּ�)
     ,addr           VARCHAR2(1000)         -- ���
     ,viewing_date  DATE                    -- ������
     ,review_date   DATE DEFAULT SYSDATE    -- �ۼ���
     ,update_date   DATE DEFAULT SYSDATE    -- ������
     ,friend        VARCHAR2(100)           -- ������
     ,rating        NUMBER                  -- ����
     ,review        CLOB                    -- ������
     ,photo         CLOB                    -- ÷�� ���� ���
     ,del_yn         VARCHAR2(1)  DEFAULT 'N'   -- ���� ����(Y �Ǵ� N)
     ,PRIMARY KEY (review_no)
     ,CONSTRAINT fk_review_mem_id       FOREIGN KEY (mem_id)        REFERENCES members(mem_id)   
     ,CONSTRAINT fk_review_ticket_no    FOREIGN KEY (ticket_no)     REFERENCES tb_ticket(ticket_no)   
     ,CONSTRAINT fk_review_culture_no   FOREIGN KEY (culture_no)    REFERENCES tb_culture(culture_no)   
);


-- Ƽ�� �̹��� ����
CREATE TABLE ticket_books(
     scrap_no       NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1 NOCACHE)
    ,mem_id         VARCHAR2(1000)
    ,title          VARCHAR2(1000)
    ,viewing_date   DATE
    ,ticket_img     CLOB
    ,use_yn         VARCHAR2(1)  DEFAULT 'Y'
    ,PRIMARY KEY (scrap_no)
    ,CONSTRAINT fk_img_mem_id  FOREIGN KEY (mem_id)   REFERENCES members(mem_id)
);