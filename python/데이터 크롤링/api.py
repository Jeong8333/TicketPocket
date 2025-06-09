import requests
from bs4 import BeautifulSoup

from DBManager import DBManager
mydb = DBManager()
conn = mydb.get_connection()

sql = """
    INSERT INTO culture(comm_cd, title, poster, period_date, loc, culture_description)
    VALUES(:1,:2,:3,:4,:5,:6)
"""

API_KEY="6c01e70c-b7d5-45a8-87ad-9266be5e7ae9"
culture_types = {'연극':'TH00', '뮤지컬':'MU00', '콘서트':'CN01', '음악':'CN02', '오페라':'CN04', '국악':'CN05', '무용':'DN01', '전시':'EX00' ,'기타':'ETC'}
for k, v in culture_types.items():
    for number in range(1,11):
        url = f"http://api.kcisa.kr/openapi/CNV_060/request?serviceKey={API_KEY}&numOfRows=50&pageNo={number}&dtype={k}"
        res = requests.get(url)
        if res.status_code == 200:
            soup = BeautifulSoup(res.content, 'xml')
            items = soup.select('item')
            for item in items:
                title = item.select_one('title').text
                poster = item.select_one('imageObject').text
                period_date = item.select_one('period').text
                loc = item.select_one('eventSite').text
                culture_description_with_tags = item.select_one('description').text
                desc_soup = BeautifulSoup(culture_description_with_tags, 'html.parser')
                culture_description = desc_soup.get_text(separator='\n', strip=True)
                mydb.insert(sql, [v, title, poster, period_date, loc, culture_description])


conn.commit()
conn.close()