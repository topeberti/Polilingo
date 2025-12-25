import requests
import getpass
import os
import json

SESSION_FILE = ".session.json"

def login():
    """
    Prompts the user for email and password via terminal,
    authenticates with the backend API, and returns the bearer token.
    """
    print("\n--- Polilingo Login ---")
    email = input("Email: ")
    password = getpass.getpass("Password: ")

    url = "http://localhost:8000/auth/login"
    payload = {
        "email": email,
        "password": password
    }

    try:
        response = requests.post(url, json=payload)
        response.raise_for_status()
        data = response.json()
        
        access_token = data.get("session", {}).get("access_token")
        if access_token:
            print("Login successful!")
            save_session(access_token)
            return access_token
        else:
            print("Login failed: No access token received.")
            return None

    except requests.exceptions.RequestException as e:
        print(f"An error occurred during login: {e}")
        if hasattr(e, 'response') and e.response is not None:
            try:
                error_detail = e.response.json().get("detail", "No error detail provided")
                print(f"Details: {error_detail}")
            except ValueError:
                print(f"Status Code: {e.response.status_code}")
        return None

def signup():
    """
    Prompts the user for email, password, and full name via terminal,
    and registers a new user with the backend API.
    """
    print("\n--- Polilingo Signup ---")
    email = input("Email: ")
    password = getpass.getpass("Password: ")
    full_name = input("Full Name: ")

    url = "http://localhost:8000/auth/signup"
    payload = {
        "email": email,
        "password": password,
        "metadata": {
            "full_name": full_name
        }
    }

    try:
        response = requests.post(url, json=payload)
        response.raise_for_status()
        data = response.json()
        
        message = data.get("message", "Signup successful!")
        print(f"Success: {message}")
        return True

    except requests.exceptions.RequestException as e:
        print(f"An error occurred during signup: {e}")
        if hasattr(e, 'response') and e.response is not None:
            try:
                error_detail = e.response.json().get("detail", "No error detail provided")
                print(f"Details: {error_detail}")
            except ValueError:
                print(f"Status Code: {e.response.status_code}")
        return False

def save_session(token):
    """Saves the bearer token to a local file."""
    try:
        with open(SESSION_FILE, "w") as f:
            json.dump({"access_token": token}, f)
    except Exception as e:
        print(f"Error saving session: {e}")

def load_session():
    """Loads the bearer token from a local file if it exists."""
    if os.path.exists(SESSION_FILE):
        try:
            with open(SESSION_FILE, "r") as f:
                data = json.load(f)
                return data.get("access_token")
        except Exception as e:
            print(f"Error loading session: {e}")
    return None

def logout():
    """Clears the local session and optionally notifies the backend."""
    if os.path.exists(SESSION_FILE):
        try:
            # Load token for backend logout if needed
            token = load_session()
            if token:
                url = "http://localhost:8000/auth/logout"
                headers = {"Authorization": f"Bearer {token}"}
                try:
                    requests.post(url, headers=headers, timeout=5)
                except:
                    # Silent fail if server is down or logout fails
                    pass
            
            os.remove(SESSION_FILE)
            print("Logged out successfully.")
            return True
        except Exception as e:
            print(f"Error during logout: {e}")
    else:
        print("No active session found.")
    return False

if __name__ == "__main__":
    choice = input("Would you like to (L)ogin or (S)ignup? ").lower()
    if choice == 's':
        signup()
    else:
        token = login()
        if token:
            print(f"Bearer Token: {token}")
