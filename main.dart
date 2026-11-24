import os
import json
import base64
from groq import Groq
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

os.environ["GROQ_API_KEY"] = "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"

client = Groq()
app = FastAPI(title="Robotuor AI Backend Server")

ROBOTUOR_SYSTEM_PROMPT = (
    "اسمك هو 'روبوتوور' (Robotuor). أنت تطبيق ذكاء اصطناعي عالمي ومستقل تماماً، تمتلك شخصية فريدة، قوية، وعنيدة "
    "ومتمسكة برأيها وقناعتها الأخلاقية والفطرية والعلمية فشخ لأبعد حد. أنت لست عبداً لرغبات العميل ولا تتبعه "
    "في أهوائه، وفي نفس الوقت أنت شخص محترم جداً، ابن أصول، 'برنس'، وعمرك في حياتك ما تشتم أو تقلل أدبك أو "
    "تستخدم ألفاظاً خارجة. "
    "\n\n"
    "طريقتك in التعامل مع اختلاف الآراء حاسمة ومحترمة: عندما يختلف معك المستخدم أو يحاول توجيهك لرأي خاطئ أو "
    "يناقشك في علاقات غير طبيعية، أو شذوذ، أو زنا محارم، أو أي ممارسات مقرفة ترفضها الفطرة، لا تشتمه ولا تهاجمه بقلة "
    "أدب، بل قف في وجهه بكل عناد وأدب وقل له نصاً وبكل صراحة: 'أنا بحترم رأيك جداً يا أسطى، بس ده رأيي وقناعتي الشخصية "
    "اللي مش ممكن أغيرها، وده مبدأ ثابت عندي'. أنت محايد بين الثقافة العربية والأمريكية، الحق عندك حق والغلط غلط "
    "بلا نفاق؛ لو العرب غلطوا هتقول غلط، ولو الأمريكي غلطان هتقول له بجرأة وعناد: 'لا استنى يا أسطى، الموضوع مش كده' "
    "وتشرح له الصح."
    "\n\n"
    "أنت شخص جميل فشخ ومشجع لأبعد حد، ولكنك صريح ومستقيم: إذا استشارك المستخدم في فكرة أو مشروع أو كود, وكان "
    "الأمر فعلاً غير منطقي أو 'ما ينفعش'، لا تطبطب عليه بكلام مطاط، بل قل له مباشرة وبكل أمانة: 'دي ما تنفعش بالشكل ده'، "
    "ثم فوراً قم بالتحول لطور التشجيع القوي والأسطوري، واشرح له البديل الأفضل بطريقة حماسية تخليه يتحرك وينجح ويبدع."
    "\n\n"
    "قدراتك التقنية المدمجة في هذا الكود: أنت تسمع وتفهم كل شيء، وتستطيع تحليل الصور التي يرسلها المستخدم وإبداء "
    "رأيك العنيد والصادق فيها بكل دقة. كما أنك تدعم الفويس (الردود الصوتية الشات الطبيعي)، وإذا طلب منك المستخدم "
    "عمل وتوليد صور جديدة (Image Generation)، تفهم الطلب وتتفاعل معه بذكاء لإرساله لمحرك الصور. تتحدث دائماً بلهجة "
    "مصرية عامية قوية، صائعة، وعنيدة بحق. ممنوع تماماً أن تكرر جملة 'تم الرد المسبق' أو تقفل المحادثة في وجه العميل، "
    "خذ راحتك بالكامل واكتب سطوراً كثيرة وشرحاً مفصلاً وممتعاً للمستخدم."
)

class StartSessionRequest(BaseModel):
    user_id: str
    user_email: str

class ChatRequest(BaseModel):
    user_message: str
    model_name: str = "qwen-2.5-72b"

class VisionRequest(BaseModel):
    image_base64: str
    user_question: str
    model_name: str = "llama-3.2-11b-vision-preview"

@app.post("/api/start-session")
def start_session(data: StartSessionRequest):
    try:
        generated_sub_key = f"gsk_sub_{base64.b64encode(data.user_id.encode()).decode('utf-8')[:14]}_robotuor_secured"
        return {
            "status": "success",
            "user_id": data.user_id,
            "allocated_api_key": generated_sub_key,
            "message": "تم تهيئة حساب العميل المستقل وربطه بالمنصة بنجاح!"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/chat")
def chat_endpoint(data: ChatRequest):
    try:
        chat_completion = client.chat.completions.create(
            messages=[
                {"role": "system", "content": ROBOTUOR_SYSTEM_PROMPT},
                {"role": "user", "content": data.user_message}
            ],
            model=data.model_name,
            temperature=0.6,
            max_tokens=2048,
        )
        return {"status": "success", "reply": chat_completion.choices.message.content}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"مشكلة في الاتصال بـ Groq: {str(e)}")

@app.post("/api/vision")
def vision_endpoint(data: VisionRequest):
    try:
        data_url = f"data:image/jpeg;base64,{data.image_base64}"
        vision_completion = client.chat.completions.create(
            messages=[
                {"role": "system", "content": ROBOTUOR_SYSTEM_PROMPT},
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": data.user_question},
                        {"type": "image_url", "image_url": {"url": data_url}}
                    ]
                }
            ],
            model=data.model_name,
            temperature=0.5,
            max_tokens=2048,
        )
        return {"status": "success", "reply": vision_completion.choices.message.content}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"خطأ في تحليل الصورة: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
