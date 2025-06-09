import cv2
import numpy as np
import re

def auto_detect_card(image):
    # 이미지 복사 및 축소
    orig = image.copy()
    ratio = image.shape[0] / 500.0
    image = cv2.resize(image, (int(image.shape[1] / ratio), 500))

    # 그레이 변환, 블러, 엣지
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    gray = cv2.GaussianBlur(gray, (5, 5), 0)  # 노이즈 제거
    edged = cv2.Canny(gray, 75, 200)          # 엣지 검출

    # 윤곽선 탐지
    contours, _ = cv2.findContours(edged.copy(), cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
    contours = sorted(contours, key=cv2.contourArea, reverse=True)[:5]

    screenCnt = None
    for c in contours:
        peri = cv2.arcLength(c, True)
        approx = cv2.approxPolyDP(c, 0.02 * peri, True)
        if len(approx) == 4:
            screenCnt = approx
            break

    if screenCnt is None:
        print("티켓 감지 불가")
        return None, False

    # 점 정렬
    pts = screenCnt.reshape(4, 2)
    rect = np.zeros((4, 2), dtype="float32")

    s = pts.sum(axis=1)
    rect[0] = pts[np.argmin(s)]
    rect[2] = pts[np.argmax(s)]

    diff = np.diff(pts, axis=1)
    rect[1] = pts[np.argmin(diff)]
    rect[3] = pts[np.argmax(diff)]

    # 원본 이미지 비율 적용
    rect *= ratio

    # 투시 변환
    (tl, tr, br, bl) = rect
    # 변환 이미지 너비 계산
    widthA = np.linalg.norm(br - bl)
    widthB = np.linalg.norm(tr - tl)
    maxWidth = max(int(widthA), int(widthB))
    # 변환 이미지 높이 계산
    heightA = np.linalg.norm(tr - br)
    heightB = np.linalg.norm(tl - bl)
    maxHeight = max(int(heightA), int(heightB))
    # 변환 후 꼭짓점 좌표 설정 (좌상단이 (0,0)이 되도록)
    dst = np.array([
        [0, 0],
        [maxWidth - 1, 0],
        [maxWidth - 1, maxHeight - 1],
        [0, maxHeight - 1]],
        dtype="float32")

    # 원본 이미지(orig)에서 계산된 사각형 영역(rect)을 새로운 좌표(dst) 기준으로 투시 변환하여 반듯한 이미지 생성
    M = cv2.getPerspectiveTransform(rect, dst)
    warped = cv2.warpPerspective(orig, M, (maxWidth, maxHeight))

    return warped, True


def extract_contact_info(text_lines):
    """
    OCR 결과에서 공연명, 날짜 정보 추출
    """
    title_pattern = re.compile(r"^[\[\(<]?[가-힣A-Za-z0-9\s]{2,}[\]\)>]?[\s가-힣A-Za-z0-9\[\]()<>{}]{0,}$",re.MULTILINE)
    date_pattern = re.compile(r"\d{4}[-.\s]?\d{2}[-.\s]?\d{2}")

    title = None
    date = None

    for line in text_lines:
        if title is None:
            match = title_pattern.search(line)
            if match:
                title = match.group().strip()

        if date is None:
            match = date_pattern.search(line)
            if match:
                date = match.group().replace(" ", "-").replace(".", "-").strip()

        if title and date:
            break

    return {
        "title": title,
        "date": date
    }

