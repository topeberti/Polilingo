# Polilingo Backend API

Backend API for Polilingo - a gamified learning application for Spanish police state exam preparation, built with FastAPI and Supabase.

## Features

- **Authentication**: Complete auth system with email/password
  - User signup with email verification
  - Login with session management
  - Password reset flow
  - User account management
- **Supabase Integration**: Serverless backend with PostgreSQL
- **JWT Authentication**: Secure token-based authentication
- **API Documentation**: Auto-generated with FastAPI (Swagger UI)

## Prerequisites

- Python 3.10 or higher
- Supabase account and project
- pip (Python package manager)

## Setup

### 1. Install Dependencies

```bash
cd Backend
pip install -r requirements.txt
```

### 2. Environment Variables

Ensure your `.env` file contains:

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_KEY=your_supabase_anon_key
```

You can find these values in your Supabase project dashboard under Settings > API.

### 3. Configure Supabase

In your Supabase dashboard:

1. **Enable Email Authentication**:
   - Go to Authentication > Providers
   - Enable Email provider
   - Configure email templates if needed

2. **Email Verification** (recommended):
   - Go to Authentication > Settings
   - Enable "Enable email confirmations"

3. **Configure Site URL**:
   - Go to Authentication > URL Configuration
   - Add your frontend URL (e.g., `http://localhost:3000`)

## Running the Server

### Development Mode

```bash
cd Backend
python main.py
```

The server will start at `http://localhost:8000` with auto-reload enabled.

### Production Mode

```bash
cd Backend
uvicorn main:app --host 0.0.0.0 --port 8000
```

## API Documentation

Once the server is running, access the interactive API documentation:

- **Swagger UI**: <http://localhost:8000/docs>
- **ReDoc**: <http://localhost:8000/redoc>

## API Endpoints

### Authentication

All endpoints are prefixed with `/auth`

#### POST /auth/signup

Create a new user account. Sends verification email.

**Request:**

```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "metadata": {
    "full_name": "John Doe"
  }
}
```

#### POST /auth/login

Authenticate and receive session tokens.

**Request:**

```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

**Response:**

```json
{
  "message": "Login successful",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "email_confirmed_at": "2024-01-01T00:00:00Z",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  },
  "session": {
    "access_token": "jwt_token",
    "refresh_token": "refresh_token",
    "expires_in": 3600,
    "token_type": "bearer"
  }
}
```

#### POST /auth/logout

Terminate the current session.

**Headers:**

```
Authorization: Bearer <access_token>
```

#### GET /auth/user

Get current user information.

**Headers:**

```
Authorization: Bearer <access_token>
```

#### POST /auth/password/reset/request

Request password reset email.

**Request:**

```json
{
  "email": "user@example.com"
}
```

#### POST /auth/password/reset/confirm

Confirm password reset with token.

**Request:**

```json
{
  "access_token": "reset_token_from_email",
  "new_password": "NewSecurePassword123!"
}
```

#### DELETE /auth/user

Delete user account (requires admin implementation).

**Headers:**

```
Authorization: Bearer <access_token>
```

## Project Structure

```
Backend/
├── main.py           # FastAPI application entry point
├── auth.py           # Authentication endpoints
├── config.py         # Configuration and Supabase client
├── models.py         # Pydantic models for requests/responses
├── middleware.py     # Authentication middleware
├── requirements.txt  # Python dependencies
├── .env             # Environment variables (gitignored)
└── README.md        # This file
```

## Testing

### Using curl

```bash
# Signup
curl -X POST "http://localhost:8000/auth/signup" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!"}'

# Login
curl -X POST "http://localhost:8000/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!"}'

# Get user (replace TOKEN with actual token from login)
curl -X GET "http://localhost:8000/auth/user" \
  -H "Authorization: Bearer TOKEN"
```

### Using Swagger UI

Navigate to <http://localhost:8000/docs> and use the interactive interface to test all endpoints.

## Troubleshooting

### Email Verification Not Working

- Check Supabase email provider configuration
- Verify email templates are set up
- Check spam folder for verification emails

### CORS Errors

- Add your frontend URL to `cors_origins` in `config.py`
- Make sure your frontend is sending credentials with requests

### Authentication Errors

- Verify Supabase credentials in `.env`
- Check if email confirmation is required in Supabase settings
- Ensure tokens haven't expired (default 1 hour)

## Next Steps

- Implement user profile table and endpoints
- Add OAuth providers (Google, etc.)
- Implement refresh token rotation
- Add rate limiting middleware
- Set up logging and monitoring

## License

This project is part of the Polilingo application.
