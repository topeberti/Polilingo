from auth import login, signup, load_session, logout
from learning_path import show_learning_path
import sys

def authenticated_menu(token):
    while True:
        print("\n=== Polilingo Main Menu (Authenticated) ===")
        print(f"Logged in as: [Active Session]")
        print("1. Learning Path")
        print("2. Logout")
        print("3. Exit")
        
        choice = input("\nSelect an option (1-3): ")
        
        if choice == '1':
            show_learning_path(token)
        elif choice == '2':
            logout()
            break
        elif choice == '3':
            print("Exiting application. Goodbye!")
            sys.exit(0)
        else:
            print("Invalid choice.")

def main():
    # Check for existing session on startup
    token = load_session()
    if token:
        print("\nRestoring previous session...")
        authenticated_menu(token)

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
