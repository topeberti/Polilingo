from auth import login, signup, load_session, logout, authenticated_request, save_session
from learning_path import show_learning_path
import sys
import json
import time

def get_user_profile():
    """Fetches key user profile data for the menu."""
    try:
        response = authenticated_request("GET", "http://localhost:8000/users/profile")
        if response.status_code == 200:
            data = response.json()
            # Cache that profile exists
            session = load_session()
            if session and not session.get("profile_created"):
                save_session(session["access_token"], session["refresh_token"], profile_created=True)
            return data
        elif response.status_code == 404:
            # Profile doesn't exist yet
            return {"profile_missing": True}
        else:
            print(f"Error fetching profile: Status {response.status_code}")
            try:
                print(f"Details: {response.json().get('detail', 'No detail')}")
            except:
                print(f"Response: {response.text[:200]}")
    except Exception as e:
        print(f"Exception fetching profile: {e}")
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
        
        # Lives Info
        lives = stats.get('current_lives', stats.get('lives', 5))
        print(f"\n--- Lives ---")
        print(f"Current Lives: {'❤️' * lives} ({lives})")
        if stats.get('next_life_at'):
            next_life = stats.get('next_life_at')
            seconds = stats.get('seconds_to_next_life')
            
            if seconds is not None:
                mins = seconds // 60
                secs = seconds % 60
                print(f"Next Life In: {mins}m {secs}s")
            else:
                # Fallback to string if seconds not available
                if isinstance(next_life, str):
                    next_life = next_life.split('.')[0].replace('T', ' ')
                print(f"Next Life At: {next_life} (UTC)")
    else:
        print("No gamification stats available yet.")
        
    input("\nPress Enter to return to menu...")

def show_profile_setup(token):
    """Guide the user through creating their profile."""
    print("\n=== Welcome to Polilingo! ===")
    print("It looks like you haven't set up your profile yet.")
    print("Please provide a few details to get started.\n")
    
    while True:
        username = input("Enter a username (3-20 chars): ").strip()
        full_name = input("Enter your full name: ").strip()
        
        if not username or not full_name:
            print("Username and Full Name are required.")
            continue
            
        print("\nWhat is your daily XP goal?")
        print("1. Casual (10 XP)")
        print("2. Regular (30 XP)")
        print("3. Serious (50 XP) - Default")
        print("4. Insane (100 XP)")
        
        goal_choice = input("Select an option (1-4, Default: 3): ")
        daily_goal = 50
        if goal_choice == '1': daily_goal = 10
        elif goal_choice == '2': daily_goal = 30
        elif goal_choice == '3' or goal_choice == '': daily_goal = 50
        elif goal_choice == '4': daily_goal = 100
        
        payload = {
            "username": username,
            "full_name": full_name,
            "daily_goal": daily_goal
        }
        
        try:
            response = authenticated_request("POST", "http://localhost:8000/users/create", json=payload)
            
            if response.status_code == 201:
                print("\nProfile created successfully!")
                # Cache that profile exists
                session = load_session()
                if session:
                    save_session(session["access_token"], session["refresh_token"], profile_created=True)
                input("Press Enter to continue to the Main Menu...")
                return True
            else:
                try:
                    error_detail = response.json().get("detail", "Unknown error")
                except:
                    error_detail = response.text
                print(f"\nFailed to create profile: {error_detail}")
                print("Please try again.\n")
        except Exception as e:
            print(f"Error during profile creation: {e}")
            break
            
    return False

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
                lives = stats.get("current_lives", 5)
                
        print("\n=== Polilingo Main Menu (Authenticated) ===")
        print(f"Logged in as: {username} [Level {level}] | Lives: {'❤️' * lives} ({lives})")
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
        
        # If we already know the profile exists, skip the initial check
        if session.get("profile_created"):
            authenticated_menu(token)
        else:
            # Try a simple authenticated request to verify/refresh token
            # We'll use /users/profile as a health check and to preload data
            try:
                profile = get_user_profile()
                if profile:
                    if profile.get("profile_missing"):
                        if show_profile_setup(token):
                            authenticated_menu(token)
                    else:
                        # Token is valid (or was refreshed successfully)
                        new_session = load_session() # Reload in case it was refreshed/updated
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
                session = load_session()
                if session and session.get("profile_created"):
                    authenticated_menu(token)
                else:
                    profile = get_user_profile()
                    if profile and profile.get("profile_missing"):
                        if show_profile_setup(token):
                            authenticated_menu(token)
                    elif profile:
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
