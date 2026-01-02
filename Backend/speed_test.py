import httpx
import time
import os
import asyncio
from typing import List, Dict, Any, Optional
from datetime import datetime
from dotenv import load_dotenv

# Load environment variables
# Prioritize speed_test.env if it exists
if os.path.exists("speed_test.env"):
    load_dotenv("speed_test.env")
else:
    load_dotenv()

# Configuration
API_BASE_URL = os.getenv("API_BASE_URL", "http://localhost:8000")
TEST_EMAIL = os.getenv("TEST_EMAIL")
TEST_PASSWORD = os.getenv("TEST_PASSWORD")

if not TEST_EMAIL or not TEST_PASSWORD:
    print("Error: TEST_EMAIL and TEST_PASSWORD environment variables must be set.")
    exit(1)

async def test_endpoint(client: httpx.AsyncClient, method: str, path: str, name: str, token: str = None, json_data: Dict = None) -> Dict[str, Any]:
    url = f"{API_BASE_URL}{path}"
    headers = {}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    
    start_time = time.perf_counter()
    try:
        if method == "GET":
            response = await client.get(url, headers=headers)
        elif method == "POST":
            response = await client.post(url, headers=headers, json=json_data)
        else:
            return {"name": name, "path": path, "status": "error", "time": 0, "error": f"Unsupported method {method}", "data": None}
            
        end_time = time.perf_counter()
        duration = end_time - start_time
        
        try:
            resp_data = response.json()
        except:
            resp_data = None

        return {
            "name": name,
            "path": path,
            "status": response.status_code,
            "time": duration,
            "error": None if response.status_code < 400 else response.text[:100],
            "data": resp_data
        }
    except Exception as e:
        return {
            "name": name,
            "path": path,
            "status": "exception",
            "time": 0,
            "error": str(e),
            "data": None
        }

async def run_speed_test():
    print(f"Starting Speed Test against {API_BASE_URL}")
    print("-" * 60)
    
    async with httpx.AsyncClient(timeout=30.0) as client:
        # 1. Health Check (Public)
        health_result = await test_endpoint(client, "GET", "/health", "Health Check")
        
        # 2. Login
        login_result = await test_endpoint(
            client, 
            "POST", 
            "/auth/login", 
            "Login", 
            json_data={"email": TEST_EMAIL, "password": TEST_PASSWORD}
        )
        
        token = None
        if login_result["status"] == 200:
            token = login_result["data"].get("session", {}).get("access_token")
        
        results = [health_result, login_result]
        
        if token:
            # Informational Endpoints
            authenticated_endpoints = [
                ("GET", "/auth/user", "Get Auth User"),
                ("GET", "/users/profile", "Get User Profile"),
                ("GET", "/history/sessions/available", "Available Sessions"),
                ("GET", "/history/sessions/passed", "Passed Sessions"),
                ("GET", "/history/lessons/passed", "Passed Lessons"),
                ("GET", "/history/sessions/next", "Next Session"),
                ("GET", "/history/lessons/next", "Next Lesson"),
            ]
            
            for method, path, name in authenticated_endpoints:
                res = await test_endpoint(client, method, path, name, token=token)
                results.append(res)

            # Learning Flow Endpoints
            print("\nOrchestrating Learning Flow...")
            
            # 1. Get Next Session ID
            next_session_res = next((r for r in results if r["name"] == "Next Session"), None)
            session_id = None
            if next_session_res and next_session_res["status"] == 200:
                session_data = next_session_res["data"].get("session")
                if session_data:
                    session_id = session_data.get("id")

            if session_id:
                # 2. Get Session Questions
                questions_res = await test_endpoint(client, "GET", f"/learning/session/questions?session_id={session_id}", "Get Questions", token=token)
                results.append(questions_res)

                # 3. Start Session
                start_res = await test_endpoint(client, "POST", "/learning/session/start", "Start Session", token=token, json_data={"session_id": session_id})
                results.append(start_res)

                if start_res["status"] == 201:
                    history_id = start_res["data"].get("id")
                    
                    # 4. Answer Question (if we have questions)
                    if questions_res["status"] == 200 and questions_res["data"].get("questions"):
                        question_id = questions_res["data"]["questions"][0]["id"]
                        answer_data = {
                            "question_id": question_id,
                            "user_session_history_id": history_id,
                            "answer": "a",
                            "started_at": datetime.utcnow().isoformat(),
                            "asked_for_explanation": False
                        }
                        answer_res = await test_endpoint(client, "POST", "/learning/question/answer", "Answer Question", token=token, json_data=answer_data)
                        results.append(answer_res)
                    
                    # 5. Finish Session
                    finish_res = await test_endpoint(client, "POST", "/learning/session/finish", "Finish Session", token=token, json_data={"history_id": history_id, "passed": False})
                    results.append(finish_res)
            else:
                print("Warning: Could not find a next session to test learning flow.")
        else:
            print("Warning: Login failed, skipping authenticated endpoints.")
            
        # Print results
        print("\n" + f"{'Endpoint Name':<25} | {'Path':<30} | {'Status':<8} | {'Time (s)':<10}")
        print("-" * 85)
        for res in results:
            status_str = str(res["status"])
            time_str = f"{res['time']:.4f}" if res['time'] > 0 else "N/A"
            path_display = res["path"] if len(res["path"]) <= 30 else res["path"][:27] + "..."
            print(f"{res['name']:<25} | {path_display:<30} | {status_str:<8} | {time_str:<10}")
            if res["error"]:
                print(f"  Error: {res['error']}")

if __name__ == "__main__":
    asyncio.run(run_speed_test())
