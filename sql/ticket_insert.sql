-- 코드 생성
INSERT INTO code_list (comm_cd,comm_nm,comm_parent) VALUES ('TH00','연극', null);         
INSERT INTO code_list (comm_cd,comm_nm,comm_parent) VALUES ('MU00','뮤지컬', null);      
INSERT INTO code_list (comm_cd,comm_nm,comm_parent) VALUES ('CN01','콘서트', 'CN00');
INSERT INTO code_list (comm_cd,comm_nm,comm_parent) VALUES ('CN02','음악', 'CN00');
INSERT INTO code_list (comm_cd,comm_nm,comm_parent) VALUES ('CN03','클래식', 'CN00');
INSERT INTO code_list (comm_cd,comm_nm,comm_parent) VALUES ('CN04','오페라', 'CN00');
INSERT INTO code_list (comm_cd,comm_nm,comm_parent) VALUES ('CN05','국악', 'CN00');
INSERT INTO code_list (comm_cd,comm_nm,comm_parent) VALUES ('DN00','무용/발레', null);    
INSERT INTO code_list (comm_cd,comm_nm,comm_parent) VALUES ('DN01','무용', 'DN00');
INSERT INTO code_list (comm_cd,comm_nm,comm_parent) VALUES ('DN02','발레', 'DN00');
INSERT INTO code_list (comm_cd,comm_nm,comm_parent) VALUES ('EX00','전시', null);        
INSERT INTO code_list (comm_cd,comm_nm,comm_parent) VALUES ('ETC','기타', null);          