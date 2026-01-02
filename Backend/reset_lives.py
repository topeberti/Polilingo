import os
import asyncio
from supabase import create_client, Client
from dotenv import load_dotenv

load_dotenv(".env")
if os.path.exists("speed_test.env"):
    load_dotenv("speed_test.env")

supabase_url = os.getenv("SUPABASE_URL")
supabase_key = os.getenv("SUPABASE_KEY")
test_email = os.getenv("TEST_EMAIL")

supabase: Client = create_client(supabase_url, supabase_key)

async def reset_lives():
    # Use service key if available or just find the user by email
    res = supabase.from_("users").select("id").eq("email", "albertovicentedelegido@gmail.com").single().execute()
    user_id = res.data['id']
    
    print(f"Resetting lives for user {user_id}")
    supabase.from_("user_gamification_stats").update({"lives": 5}).eq("user_id", user_id).execute()
    print("Done.")

if __name__ == "__main__":
    asyncio.run(reset_lives())
