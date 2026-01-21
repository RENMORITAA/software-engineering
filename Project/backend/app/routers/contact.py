from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
import smtplib
from email.mime.text import MIMEText
from email.utils import formatdate

router = APIRouter(prefix="/contact", tags=["contact"])

# リクエストボディの定義
class ContactRequest(BaseModel):
    category: str
    content: str
    user_email: str
    target_email: str

@router.post("")
async def send_contact_email(request: ContactRequest):
    # --- 【重要】メール送信設定 ---
    # 送信元のGmailアドレスと、Googleで発行した「アプリパスワード」を入力してください
    SENDER_EMAIL = "kut.stellarworks@gmail.com" 
    SENDER_PASSWORD = "psbc jbnb thpj lolr" # 16桁のアプリパスワード

    # メールの本文作成
    body = f"""
    アプリからのお問い合わせを受け付けました。

    【送信元ユーザー】: {request.user_email}
    【カテゴリー】: {request.category}
    【内容】:
    {request.content}
    """
    
    msg = MIMEText(body)
    msg['Subject'] = f"【お問い合わせ】{request.category}"
    msg['From'] = SENDER_EMAIL
    msg['To'] = request.target_email # kut.stellarworks@gmail.com
    msg['Date'] = formatdate(localtime=True)

    try:
        # GmailのSMTPサーバー経由で送信
        with smtplib.SMTP_SSL('smtp.gmail.com', 465) as server:
            server.login(SENDER_EMAIL, SENDER_PASSWORD)
            server.send_message(msg)
        return {"status": "success", "message": "Email sent successfully"}
    except Exception as e:
        print(f"SMTP Error: {e}")
        raise HTTPException(status_code=500, detail="メール送信に失敗しました")