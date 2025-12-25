import requests
import json

def get_available_sessions(token):
    """
    Fetches available sessions from the backend API.
    Returns a tuple of (sessions_list, lessons_dict, passed_session_ids) or None on error.
    """
    url = "http://localhost:8000/history/sessions/available"
    headers = {"Authorization": f"Bearer {token}"}
    
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        data = response.json()
        
        sessions = data.get("sessions", [])
        lessons = data.get("lessons", [])
        
        # Create a dictionary of lessons for easy lookup
        lessons_dict = {lesson["id"]: lesson for lesson in lessons}
        
        # Get passed sessions from the backend
        passed_sessions = get_passed_sessions(token)
        passed_session_ids = set(session["id"] for session in passed_sessions)
        
        return sessions, lessons_dict, passed_session_ids
    
    except requests.exceptions.RequestException as e:
        print(f"\nError fetching available sessions: {e}")
        if hasattr(e, 'response') and e.response is not None:
            try:
                error_detail = e.response.json().get("detail", "No error detail provided")
                print(f"Details: {error_detail}")
            except ValueError:
                print(f"Status Code: {e.response.status_code}")
        return None

def get_passed_sessions(token):
    """
    Fetches passed sessions from the backend API.
    Returns a list of passed sessions or empty list on error.
    """
    url = "http://localhost:8000/history/sessions/passed"
    headers = {"Authorization": f"Bearer {token}"}
    
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        data = response.json()
        # The API returns {"sessions": [...]}
        return data.get("sessions", [])
    except requests.exceptions.RequestException:
        return []

def show_session_details(session):
    """
    Displays detailed information about a session.
    """
    print("\n" + "=" * 60)
    print("SESSION DETAILS")
    print("=" * 60)
    print(f"Name: {session['name']}")
    print(f"Number of Questions: {session['number_of_questions']}")
    print(f"Question Selection Strategy: {session['question_selection_strategy']}")
    
    if session.get('min_difficulty') is not None:
        print(f"Minimum Difficulty: {session['min_difficulty']}")
    
    if session.get('max_difficulty') is not None:
        print(f"Maximum Difficulty: {session['max_difficulty']}")
    
    print("=" * 60)
    input("\nPress Enter to continue...")

def show_learning_path(token):
    """
    Main function to display the learning path menu.
    Shows all available sessions in order with pass/fail status.
    """
    result = get_available_sessions(token)
    
    if result is None:
        print("\nFailed to load learning path. Returning to main menu.")
        input("\nPress Enter to continue...")
        return
    
    sessions, lessons_dict, passed_session_ids = result
    
    if not sessions:
        print("\nNo sessions available yet.")
        input("\nPress Enter to continue...")
        return
    
    while True:
        print("\n" + "=" * 60)
        print("LEARNING PATH")
        print("=" * 60)
        
        # Display sessions grouped by lesson
        current_lesson_id = None
        session_number = 1
        session_map = {}  # Maps display number to session
        
        for session in sessions:
            lesson_id = session["lesson_id"]
            
            # Display lesson header when we encounter a new lesson
            if lesson_id != current_lesson_id:
                current_lesson_id = lesson_id
                lesson = lessons_dict.get(lesson_id, {})
                lesson_name = lesson.get("name", "Unknown Lesson")
                print(f"\n📚 Lesson: {lesson_name}")
                print("-" * 60)
            
            # Determine if session is passed
            is_passed = session["id"] in passed_session_ids
            status = "✅ PASSED" if is_passed else "⬜ NOT PASSED"
            
            # Display session
            print(f"{session_number}. {session['name']} - {status}")
            session_map[session_number] = session
            session_number += 1
        
        print("\n" + "=" * 60)
        print(f"Total Sessions: {len(sessions)}")
        print(f"Passed: {len(passed_session_ids)}")
        print(f"Remaining: {len(sessions) - len(passed_session_ids)}")
        print("=" * 60)
        print("\nEnter a session number to view details, or 'b' to go back")
        
        choice = input("\nYour choice: ").strip().lower()
        
        if choice == 'b':
            break
        
        try:
            session_num = int(choice)
            if session_num in session_map:
                show_session_details(session_map[session_num])
            else:
                print(f"\nInvalid session number. Please enter a number between 1 and {len(sessions)}.")
                input("\nPress Enter to continue...")
        except ValueError:
            print("\nInvalid input. Please enter a number or 'b' to go back.")
            input("\nPress Enter to continue...")
