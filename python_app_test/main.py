import sys
import requests
from auth import login, signup

def get_questions_for_session(token, session):
    """
    Resolves the hierarchy (Block -> Topic -> Heading -> Concept -> Questions)
    and applies difficulty filters.
    """
    headers = {"Authorization": f"Bearer {token}"}
    base_url = "http://localhost:8000/syllabus"
    
    concept_ids = []
    
    try:
        if session.get('concept_id'):
            print("Filtering by Concept ID...")
            concept_ids = [session.get('concept_id')]
        elif session.get('heading_id'):
            print(f"Filtering by Heading ID: {session.get('heading_id')}...")
            resp = requests.get(f"{base_url}/concepts/query?heading_ids={session.get('heading_id')}", headers=headers)
            resp.raise_for_status()
            concept_ids = resp.json().get("ids", [])
        elif session.get('topic_id'):
            print(f"Filtering by Topic ID: {session.get('topic_id')}...")
            resp = requests.get(f"{base_url}/headings/query?topic_ids={session.get('topic_id')}", headers=headers)
            resp.raise_for_status()
            heading_ids = resp.json().get("ids", [])
            if heading_ids:
                resp = requests.get(f"{base_url}/concepts/query?heading_ids={','.join(heading_ids)}", headers=headers)
                resp.raise_for_status()
                concept_ids = resp.json().get("ids", [])
        elif session.get('block_id'):
            print(f"Filtering by Block ID: {session.get('block_id')}...")
            resp = requests.get(f"{base_url}/topics/query?block_ids={session.get('block_id')}", headers=headers)
            resp.raise_for_status()
            topic_ids = resp.json().get("ids", [])
            if topic_ids:
                resp = requests.get(f"{base_url}/headings/query?topic_ids={','.join(topic_ids)}", headers=headers)
                resp.raise_for_status()
                heading_ids = resp.json().get("ids", [])
                if heading_ids:
                    resp = requests.get(f"{base_url}/concepts/query?heading_ids={','.join(heading_ids)}", headers=headers)
                    resp.raise_for_status()
                    concept_ids = resp.json().get("ids", [])
        
        if not concept_ids:
            return []

        # Final question query with difficulty filters
        query_params = {
            "concept_ids": ",".join(concept_ids),
        }
        if session.get('min_difficulty') is not None:
            query_params["difficulty_min"] = session.get('min_difficulty')
        if session.get('max_difficulty') is not None:
            query_params["difficulty_max"] = session.get('max_difficulty')
            
        print(f"Querying questions for {len(concept_ids)} concepts with params: {query_params}")
        resp = requests.get(f"{base_url}/questions/query", params=query_params, headers=headers)
        resp.raise_for_status()
        return resp.json().get("ids", [])

    except requests.exceptions.RequestException as e:
        print(f"Error during hierarchical resolution: {e}")
        return []

def get_next_session_info(token):
    """
    Fetches the next session ID and then its details from the backend.
    """
    headers = {"Authorization": f"Bearer {token}"}
    
    try:
        # 1. Get next session ID
        print("\nFetching next session ID...")
        response = requests.get("http://localhost:8000/history/sessions/next", headers=headers)
        response.raise_for_status()
        next_session_data = response.json()
        session_id = next_session_data.get("session_id")
        
        if not session_id:
            print("No next session found or you have completed all sessions!")
            return

        # 2. Get session details
        print(f"Fetching details for session: {session_id}...")
        details_url = f"http://localhost:8000/learning-path/sessions/fetch?ids={session_id}"
        details_response = requests.get(details_url, headers=headers)
        details_response.raise_for_status()
        details_data = details_response.json()
        
        sessions = details_data.get("sessions", [])
        if not sessions:
            print("Could not find details for the next session.")
            return
        
        session = sessions[0]
        
        print("\n=== Next Session Information ===")
        print(f"ID:       {session.get('id')}")
        print(f"Name:     {session.get('name')}")
        print(f"Order:    {session.get('order')}")
        print(f"Questions to show: {session.get('number_of_questions')}")
        print(f"Strategy: {session.get('question_selection_strategy')}")
        
        # Ranges and Hierarchical Filters
        print("\n--- Constraints ---")
        if session.get('min_difficulty') is not None or session.get('max_difficulty') is not None:
            print(f"Difficulty Range: {session.get('min_difficulty', 'Any')} - {session.get('max_difficulty', 'Any')}")
        
        for key in ['block_id', 'topic_id', 'heading_id', 'concept_id']:
            if session.get(key):
                print(f"{key.replace('_', ' ').title()}: {session.get(key)}")

        # 3. Get matching questions
        print("\n--- Matching Questions ---")
        question_ids = get_questions_for_session(token, session)
        print(f"Total matching questions found: {len(question_ids)}")
        if question_ids:
            print("Question IDs:")
            for qid in question_ids[:10]: # Limit display to 10
                print(f"  - {qid}")
            if len(question_ids) > 10:
                print(f"  ... and {len(question_ids) - 10} more.")
        else:
            print("No questions match the current session constraints.")

    except requests.exceptions.RequestException as e:
        print(f"An error occurred while fetching session info: {e}")
        if hasattr(e, 'response') and e.response is not None:
            try:
                error_detail = e.response.json().get("detail", "No error detail provided")
                print(f"Details: {error_detail}")
            except ValueError:
                print(f"Status Code: {e.response.status_code}")

def authenticated_menu(token):
    """
    Menu for logged-in users.
    """
    while True:
        print("\n=== Polilingo User Menu ===")
        print("1. Get Next Session Info")
        print("2. Logout (Back to Main Menu)")
        print("3. Exit")
        
        choice = input("\nSelect an option (1-3): ")
        
        if choice == '1':
            get_next_session_info(token)
        elif choice == '2':
            print("Logging out...")
            break
        elif choice == '3':
            print("Exiting application. Goodbye!")
            sys.exit(0)
        else:
            print("Invalid choice. Please enter 1, 2, or 3.")

def main():
    while True:
        print("\n=== Polilingo App Selection Menu ===")
        print("1. Login")
        print("2. Signup")
        print("3. Exit")
        
        choice = input("\nSelect an option (1-3): ")
        
        if choice == '1':
            token = login()
            if token:
                print(f"Success! Stored token prefix: {token[:10]}...")
                authenticated_menu(token)
        elif choice == '2':
            signup()
        elif choice == '3':
            print("Exiting application. Goodbye!")
            sys.exit(0)
        else:
            print("Invalid choice. Please enter 1, 2, or 3.")

if __name__ == "__main__":
    main()
