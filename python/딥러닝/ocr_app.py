import base64
import cv2
import easyocr
import numpy as np
from flask import Flask, request, jsonify
from ocr_util import auto_detect_card,extract_contact_info
from flask_cors import CORS
app = Flask(__name__)
CORS(app)
reader = easyocr.Reader(['ko','en'])

@app.route("/ocr", methods=['POST'])
def process_image():
    info = {}
    # 요청에 'image' 파일이 있는지 확인
    if 'image' not in request.files:
        return jsonify({"error": "이미지 파일 없음!!"}), 400

    file = request.files['image']

    try:
        # 이미지 파일 내용을 메모리로 직접 읽기
        img_bytes = file.read()
        # 읽어온 데이터 -> OpenCV 이미지 형식으로 변환
        nparr = np.frombuffer(img_bytes, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        # 이미지 디코딩 실패 시 오류 반환
        if img is None:
             return jsonify({"error": "이미지 처리 실패"}), 400

        # 이미지의 티켓 영역 자동 검출 및 보정
        warped_img, success = auto_detect_card(img)
        if success:
            print("티켓 감지 및 보정 완료")
            process_target_img = warped_img
        else:
            print("티켓 감지 실패, 원본 이미지 사용")
            process_target_img = img

        # EasyOCR로 텍스트 추출
        results = reader.readtext(process_target_img)
        text_lines = [''.join(text) if isinstance(text, list) else text for _, text, _ in results]
        print("추출된 텍스트: ")
        for line in text_lines:
            print("-", line)
        info = extract_contact_info(text_lines)

        # 이미지 → Base64 인코딩
        _, buffer = cv2.imencode('.jpg', process_target_img)
        img_base64 = base64.b64encode(buffer).decode('utf-8')
        img_uri = f"data:image/jpeg;base64,{img_base64}"

        # 추출된 정보 -> JSON 형태로
        return jsonify({
            "title": info.get("title"),
            "date": info.get("date"),
            "image": img_uri
        })

    except Exception as e:
        print(f"이미지 처리 중 오류 발생: {e}")
        return jsonify({"error": "이미지 처리 중 오류 발생!!"}), 500


if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=5000)