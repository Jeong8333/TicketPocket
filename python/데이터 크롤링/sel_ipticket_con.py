from selenium import webdriver
from selenium.webdriver.common.by import By
import time
import csv
from bs4 import BeautifulSoup
import ssl
import re
from DBManager import DBManager

# =======================
#          콘서트
# =======================

mydb = DBManager()
conn = mydb.get_connection()

ssl._create_default_https_context = ssl._create_unverified_context

# sql문
sql = """
    INSERT INTO ip_ticket(comm_cd, title, poster, period_date, loc)
    VALUES(:1,:2,:3,:4,:5)
"""

csv_filename = 'concert.csv'      # 크롤링 공연 정보 저장 파일명

def sanitize_filename(name):
    # 한글, 영어, 숫자, 언더바만 남기고 모두 제거
    name = re.sub(r'[^\w\s]', '', name)  # 특수기호 제거
    name = name.strip().replace(' ', '_')  # 띄어쓰기를 언더바로
    return name

url = 'https://tickets.interpark.com/contents/genre/concert?app_header_state=hide'    # 인터파크 티켓 - 콘서트 페이지 URL
# 백그라운드 실행
# option = webdriver.ChromeOptions()
# option.add_argument('--headless')
# driver = webdriver.Chrome(options=option)

driver = webdriver.Chrome()
driver.implicitly_wait(3)
driver.get(url)
time.sleep(1)

# '전체' 탭 클릭
driver.find_element(By.XPATH, '//*[@id="contents"]/article[1]/section/div/div/div/button[1]').click()
time.sleep(1)

scraped_info = set()  # 중복된 정보를 저장할 set 생성

with open(csv_filename, mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file, delimiter='|')
    writer.writerow(['포스터','제목', '장소', '기간'])
    while True:
        # 스크롤로 보여진 정보 csv 파일에 저장
        soup = BeautifulSoup(driver.page_source, 'html.parser')
        target_div = soup.select_one('div[aria-label="상품 리스트"]')
        a_arr = target_div.find_all("a")
        for a in a_arr:
            title = a.select_one(".TicketItem_goodsName__Ju76j").text.strip()  # 공연 제목
            poster = a.select_one(".TicketItem_image__U6xq6")['src']  # 공연 포스터
            period_date = a.select_one(".TicketItem_playDate__5ePr2").text.strip()  # 공연 날짜
            loc = a.select_one(".TicketItem_placeName__ls_9C").text  # 공연 장소
            performance_info = (poster, title, loc, period_date)

            # 중복데이터 확인.중복 X: set에 추가 +  CSV 파일에 기록 + DB 저장
            if performance_info not in scraped_info:
                scraped_info.add(performance_info)
                writer.writerow([poster, title, loc, period_date])
                mydb.insert(sql, ["CN01", title, poster, period_date, loc])

        # 현재 높이 저장
        current_height = driver.execute_script("return document.body.scrollHeight")

        # 하단으로 이동
        current_position = driver.execute_script("return window.pageYOffset;")
        scroll_increment = 500  # 스크롤 간격 조절
        if current_position + scroll_increment < current_height:
            driver.execute_script(f"window.scrollTo(0, {current_position + scroll_increment});")
        else:
            driver.execute_script(f"window.scrollTo(0, {current_height});")
        # 로딩 시간 대기
        time.sleep(1)

        # 스크롤 후 높이 다시 확인
        # new_height = driver.execute_script("return document.body.scrollHeight")
        new_height = 0
        print(f"{current_height} -> {new_height}")
        # 변화 없으면 종료
        if new_height == current_height:
            break

driver.quit()
conn.commit()
conn.close()