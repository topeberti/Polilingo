# Polilingo Terminal Auth Utility

This directory contains a simple terminal-based authentication client for the Polilingo Backend API. It allows users to register and authenticate directly from the command line.

## Files

### [auth.py](file:///c:/Users/berti/Documents/Polilingo/python_app_test/auth.py)

A module containing the core authentication logic.

- **`login()`**:
  - Prompts for email and password.
  - Uses `getpass` to hide input.
  - Returns the JWT `access_token` on success.
- **`signup()`**:
  - Prompts for email, password, and full name.
  - Registers a new user with the Polilingo backend.

### [main.py](file:///c:/Users/berti/Documents/Polilingo/python_app_test/main.py)

The entry point for the utility.

- Implements a selection menu loop:
    1. **Login**: Calls `auth.login()`. If successful, the token is stored and the loop exits.
    2. **Signup**: Calls `auth.signup()`. Returns to the menu after completion.
    3. **Exit**: Gracefully terminates the script.

## Requirements

- Python 3.10+
- `requests` library

```bash
pip install requests
```

## Usage

Run the main application from the terminal:

```bash
python main.py
```

## API Interaction

Both functions interact with the local backend server (default: `http://localhost:8000`).

- Login Endpoint: `/auth/login`
- Signup Endpoint: `/auth/signup`
