-- ticket 계정 생성
ALTER SESSION SET "_ORACLE_SCRIPT"=true;
CREATE USER ticket IDENTIFIED BY ticket;
GRANT CONNECT, RESOURCE TO ticket;
GRANT UNLIMITED TABLESPACE TO ticket;


-- 분류 코드
CREATE TABLE code_list(
     comm_cd      VARCHAR2(4)   PRIMARY KEY  --분류코드
    ,comm_nm      VARCHAR2(16)               --분야명
    ,comm_parent  VARCHAR2(4)                
);


-- 문화포털 api
CREATE TABLE culture(
     comm_cd              VARCHAR2(4)       --분류항목            
    ,title                VARCHAR2(1000)    --제목         
    ,poster               VARCHAR2(1000)    --이미지(썸네일 주소)     
    ,period_date          VARCHAR2(50)      --기간      
    ,addr                 VARCHAR2(1000)    --장소 
    ,culture_description  CLOB
    ,CONSTRAINT fk_culture_comm_cd FOREIGN KEY (comm_cd) REFERENCES code_list(comm_cd)
);


-- 인터파크 티켓 크롤링
CREATE TABLE ip_ticket(
     comm_cd     VARCHAR2(4)          --분류항목
    ,title       VARCHAR2(1000)       --제목
    ,poster      VARCHAR2(1000)       --이미지(썸네일 주소)
    ,period_date VARCHAR2(50)         --기간
    ,addr         VARCHAR2(1000)      --장소
    ,CONSTRAINT fk_ip_ticket_comm_cd FOREIGN KEY (comm_cd) REFERENCES code_list(comm_cd)
);


-- 회원 정보
CREATE TABLE members (
     mem_id         VARCHAR2(1000)    PRIMARY KEY         -- 회원 ID
    ,mem_pw         VARCHAR2(1000)    NOT NULL            -- 회원 비밀번호
    ,mem_nm         VARCHAR2(1000)    NOT NULL            -- 회원 이름
    ,mem_nick       VARCHAR2(1000)    NOT NULL            -- 회원 닉네임
    ,mem_addr       VARCHAR2(1000)    NOT NULL            -- 회원 메일 주소
    ,profile_img    VARCHAR2(1000)                        -- 프로필 이미지 URL 또는 경로
    ,create_date    DATE              DEFAULT SYSDATE     -- 정보 생성일
    ,update_date    DATE              DEFAULT SYSDATE     -- 정보 수정일
    ,use_yn         VARCHAR2(1)       DEFAULT 'Y'         -- 사용 여부(Y 또는 N)
); 

-- ip_ticket, culture 테이블에 각각의 고유 id(PRIMARY KEY) 부여를 위한 새로운 테이블 생성
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


-- 후기 작성 정보 저장 table
CREATE TABLE reviews(
      review_no     NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1 NOCACHE)
     ,mem_id        VARCHAR2(1000)          -- 회원 id
     ,ticket_no     NUMBER                  -- 인터파크 티켓 테이블 id
     ,culture_no    NUMBER                  -- 문화 테이블 id
     ,comm_code     VARCHAR2(4)             -- 분류코드
     ,comm_name     VARCHAR2(16)            -- 분류 항목
     ,title         VARCHAR2(1000)          -- 공연명
     ,poster        VARCHAR2(1000)          -- 이미지(썸네일 주소)
     ,addr           VARCHAR2(1000)         -- 장소
     ,viewing_date  DATE                    -- 관람일
     ,review_date   DATE DEFAULT SYSDATE    -- 작성일
     ,update_date   DATE DEFAULT SYSDATE    -- 수정일
     ,friend        VARCHAR2(100)           -- 동행인
     ,rating        NUMBER                  -- 별점
     ,review        CLOB                    -- 관람평
     ,photo         CLOB                    -- 첨부 사진 경로
     ,del_yn         VARCHAR2(1)  DEFAULT 'N'   -- 삭제 여부(Y 또는 N)
     ,PRIMARY KEY (review_no)
     ,CONSTRAINT fk_review_mem_id       FOREIGN KEY (mem_id)        REFERENCES members(mem_id)   
     ,CONSTRAINT fk_review_ticket_no    FOREIGN KEY (ticket_no)     REFERENCES tb_ticket(ticket_no)   
     ,CONSTRAINT fk_review_culture_no   FOREIGN KEY (culture_no)    REFERENCES tb_culture(culture_no)   
);


-- 티켓 이미지 저장
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