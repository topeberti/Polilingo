import os
import asyncio
import httpx
from datetime import datetime, timezone
from supabase import create_client, Client
from dotenv import load_dotenv

load_dotenv(".env")
if os.path.exists("speed_test.env"):
    load_dotenv("speed_test.env")

supabase_url = os.getenv("SUPABASE_URL")
supabase_key = os.getenv("SUPABASE_SERVICE_KEY")

supabase: Client = create_client(supabase_url, supabase_key)

async def diagnostic():
    email = os.getenv("TEST_EMAIL")
    password = os.getenv("TEST_PASSWORD")
    
    anon_client: Client = create_client(supabase_url, os.getenv("SUPABASE_KEY"))
    res = anon_client.auth.sign_in_with_password({"email": email, "password": password})
    token = res.session.access_token
    user_id = res.user.id
    
    print(f"User: {user_id}")
    
    stat = supabase.from_("user_gamification_stats").select("*").eq("user_id", user_id).single().execute()
    print(f"DB Before: lives={stat.data['lives']}")
    
    async with httpx.AsyncClient() as client:
        headers = {"Authorization": f"Bearer {token}"}
        
        avail = await client.get("http://localhost:8000/history/sessions/available", headers=headers)
        session_id = avail.json()['sessions'][0]['id']
        start = await client.post("http://localhost:8000/learning/session/start", headers=headers, json={"session_id": session_id})
        history_id = start.json()['id']
        qs = await client.get(f"http://localhost:8000/learning/session/questions?session_id={session_id}", headers=headers)
        q = qs.json()['questions'][0]
        q_id = q['id']
        q_db = supabase.from_("questions").select("correct_option").eq("id", q_id).single().execute()
        correct = q_db.data['correct_option']
        wrong = 'a' if correct != 'a' else 'b'
        
        print(f"Testing AnswerQuestion with WRONG answer '{wrong}'")
        payload = {
            "question_id": q_id,
            "answer": wrong,
            "user_session_history_id": history_id,
            "started_at": datetime.now(timezone.utc).isoformat(),
            "asked_for_explanation": False
        }
        
        ans = await client.post("http://localhost:8000/learning/question/answer", headers=headers, json=payload)
        res = ans.json()
        print(f"Answer Response: correct={res['correct']} lives_remaining={res['lives_remaining']}")
        
        stat2 = supabase.from_("user_gamification_stats").select("*").eq("user_id", user_id).single().execute()
        print(f"DB After: lives={stat2.data['lives']}")

if __name__ == "__main__":
    asyncio.run(diagnostic())
