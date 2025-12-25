import unittest
from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from main import app
from middleware import get_current_user

# Mock data
MOCK_USER = MagicMock()
MOCK_USER.id = "test-user-id"

MOCK_HISTORY_DATA = [
    {"question_id": "q1", "correct": True},
    {"question_id": "q1", "correct": False},
    {"question_id": "q2", "correct": True},
    {"question_id": "q1", "correct": True},
    {"question_id": "q3", "correct": False},
]

class TestHistoryEndpoint(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)
        # Override dependency to return mock user
        app.dependency_overrides[get_current_user] = lambda: MOCK_USER

    def tearDown(self):
        app.dependency_overrides = {}

    @patch("history.get_supabase")
    def test_get_answered_questions(self, mock_get_supabase):
        # Setup mock Supabase response
        mock_supabase = MagicMock()
        mock_get_supabase.return_value = mock_supabase
        
        # Correctly mock the chain
        mock_response = MagicMock()
        mock_response.data = MOCK_HISTORY_DATA
        
        # Path for supabase.postgrest.auth(token).from_("user_questions_history").select("question_id, correct").eq("user_id", user_id).execute()
        mock_chain = mock_supabase.postgrest.auth.return_value.from_.return_value.select.return_value.eq.return_value.execute
        mock_chain.return_value = mock_response

        # Call the endpoint
        response = self.client.get("/history/questions/answered", headers={"Authorization": "Bearer dummy-token"})
        
        if response.status_code != 200:
            print(f"\nResponse Body: {response.json()}")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        
        self.assertIn("answered_questions", data)
        answered_questions = data["answered_questions"]
        
        # Verify aggregation logic
        # q1: 3 attempts, 2 correct
        # q2: 1 attempt, 1 correct
        # q3: 1 attempt, 0 correct
        
        q_stats = {item["question_id"]: item for item in answered_questions}
        
        self.assertEqual(len(q_stats), 3)
        
        self.assertEqual(q_stats["q1"]["total_attempts"], 3)
        self.assertEqual(q_stats["q1"]["correct_answers"], 2)
        
        self.assertEqual(q_stats["q2"]["total_attempts"], 1)
        self.assertEqual(q_stats["q2"]["correct_answers"], 1)
        
        self.assertEqual(q_stats["q3"]["total_attempts"], 1)
        self.assertEqual(q_stats["q3"]["correct_answers"], 0)

if __name__ == "__main__":
    unittest.main()
