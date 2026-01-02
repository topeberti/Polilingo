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
        refresh_token = data.get("session", {}).get("refresh_token")
        if access_token and refresh_token:
            print("Login successful!")
            save_session(access_token, refresh_token)
            return access_token
        else:
            print("Login failed: Incomplete session data received.")
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

def save_session(access_token, refresh_token, profile_created=None):
    """Saves the bearer and refresh tokens to a local file, along with profile status."""
    try:
        # Preserve existing profile_created if not provided
        if profile_created is None:
            existing = load_session()
            if existing:
                profile_created = existing.get("profile_created", False)
            else:
                profile_created = False

        with open(SESSION_FILE, "w") as f:
            json.dump({
                "access_token": access_token,
                "refresh_token": refresh_token,
                "profile_created": profile_created
            }, f)
    except Exception as e:
        print(f"Error saving session: {e}")

def load_session():
    """Loads the tokens from a local file if it exists."""
    if os.path.exists(SESSION_FILE):
        try:
            with open(SESSION_FILE, "r") as f:
                data = json.load(f)
                return data # Returns dict with access_token and refresh_token
        except Exception as e:
            print(f"Error loading session: {e}")
    return None

def refresh_session(refresh_token):
    """
    Calls the backend refresh endpoint to get a new access token.
    Updates the local session file.
    """
    url = "http://localhost:8000/auth/refresh"
    payload = {"refresh_token": refresh_token}
    
    try:
        response = requests.post(url, json=payload)
        response.raise_for_status()
        data = response.json()
        
        session = data.get("session", {})
        new_access = session.get("access_token")
        new_refresh = session.get("refresh_token")
        
        if new_access and new_refresh:
            save_session(new_access, new_refresh)
            return new_access
        return None
    except Exception as e:
        print(f"Error refreshing session: {e}")
        return None

def authenticated_request(method, url, **kwargs):
    """
    Wrapper for requests that automatically handles authentication and token refresh.
    """
    session = load_session()
    if not session:
        raise Exception("No active session. Please log in.")
    
    token = session.get("access_token")
    headers = kwargs.get("headers", {})
    headers["Authorization"] = f"Bearer {token}"
    kwargs["headers"] = headers
    
    # First attempt
    response = requests.request(method, url, **kwargs)
    
    # If unauthorized, try to refresh
    if response.status_code == 401:
        refresh_t = session.get("refresh_token")
        if refresh_t:
            print("Token expired. Attempting refresh...")
            new_token = refresh_session(refresh_t)
            if new_token:
                # Retry request with new token
                headers["Authorization"] = f"Bearer {new_token}"
                kwargs["headers"] = headers
                response = requests.request(method, url, **kwargs)
    
    return response

def logout():
    """Clears the local session and optionally notifies the backend."""
    if os.path.exists(SESSION_FILE):
        try:
            # Load token for backend logout if needed
            session_data = load_session()
            if session_data:
                token = session_data.get("access_token")
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
