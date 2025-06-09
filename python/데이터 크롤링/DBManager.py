import cx_Oracle
class DBManager:

    def __init__(self):
        self.conn = None

    def get_connection(self):
        try:
            if self.conn is None or self.conn.closed:
                self.conn = cx_Oracle.connect("ticket","ticket","localhost:1521/xe")
            return self.conn
        except Exception as e:
            return None

    def __del__(self):
        if self.conn:
            self.conn.close()
            print("db 연결이 정상적으로 종료되었습니다")

    def insert(self, query, param):
        cursor = None
        try:
            if self.conn is None:
                self.get_connection()
            cursor = self.conn.cursor()
            cursor.execute(query, param)
            self.conn.commit()
        except Exception as e:
            print(f"오류 : {e}")
            if self.conn:
                self.conn.rollback()
        finally:
            if cursor:
                cursor.close()

if __name__ == '__main__':
    db = DBManager()
    conn = db.get_connection()
    if conn:
        db.insert("INSERT INTO culture(comm_cd,title,loc) VALUES(:1,:2,:3)",['MU00', '빨래', '인터파크 홀'])