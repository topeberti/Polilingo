from auth import login, signup, load_session, logout, authenticated_request
from learning_path import show_learning_path
import sys
import json

def get_user_profile():
    """Fetches key user profile data for the menu."""
    try:
        response = authenticated_request("GET", "http://localhost:8000/users/profile")
        if response.status_code == 200:
            return response.json()
    except Exception as e:
        print(f"Error fetching profile: {e}")
    return None

def show_user_profile(profile_data):
    """Displays full user profile information."""
    if not profile_data:
        print("No profile data available.")
        input("Press Enter to continue...")
        return

    user = profile_data.get("user", {})
    stats = profile_data.get("user_gamification_stats", {})
    
    print("\n=== User Profile ===")
    print(f"Username: {user.get('username')}")
    print(f"Full Name: {user.get('full_name')}")
    print(f"Email: {user.get('email')}")
    print(f"Joined: {user.get('date_joined', '').split('T')[0]}")
    
    print("\n--- Gamification Stats ---")
    if stats:
        print(f"Level: {stats.get('current_level')}")
        print(f"Total XP: {stats.get('total_xp')}")
        print(f"XP to Next Level: {stats.get('xp_to_next_level')}")
        print(f"Current Streak: {stats.get('current_streak')} days")
        print(f"Longest Streak: {stats.get('longest_streak')} days")
        print(f"Lessons Completed: {stats.get('total_lessons_completed')}")
        print(f"Questions Answered: {stats.get('total_questions_answered')}")
        print(f"Correct Answers: {stats.get('total_correct_answers')}")
    else:
        print("No gamification stats available yet.")
        
    input("\nPress Enter to return to menu...")

def authenticated_menu(token):
    while True:
        # Refresh profile data each time menu is shown to keep stats up to date
        profile_data = get_user_profile()
        username = "Unknown"
        level = "?"
        
        if profile_data:
            username = profile_data.get("user", {}).get("username", "Unknown")
            stats = profile_data.get("user_gamification_stats", {})
            if stats:
                level = stats.get("current_level", "?")
                
        print("\n=== Polilingo Main Menu (Authenticated) ===")
        print(f"Logged in as: {username} [Level {level}]")
        print("1. Learning Path")
        print("2. View Profile")
        print("3. Logout")
        print("4. Exit")
        
        choice = input("\nSelect an option (1-4): ")
        
        if choice == '1':
            show_learning_path(token)
        elif choice == '2':
            show_user_profile(profile_data)
        elif choice == '3':
            logout()
            break
        elif choice == '4':
            print("Exiting application. Goodbye!")
            sys.exit(0)
        else:
            print("Invalid choice.")

def main():
    # Check for existing session on startup
    session = load_session()
    if session:
        print("\nRestoring previous session...")
        token = session.get("access_token")
        
        # Try a simple authenticated request to verify/refresh token
        # We'll use /users/profile as a health check and to preload data
        try:
            profile = get_user_profile()
            if profile:
                # Token is valid (or was refreshed successfully)
                new_session = load_session() # Reload in case it was refreshed
                authenticated_menu(new_session.get("access_token"))
            else:
                print("Session expired or invalid. Please log in again.")
        except Exception as e:
            print(f"Could not restore session: {e}")

    while True:
        print("\n=== Polilingo App Selection Menu ===")
        print("1. Login")
        print("2. Signup")
        print("3. Exit")
        
        choice = input("\nSelect an option (1-3): ")
        
        if choice == '1':
            token = login()
            if token:
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
