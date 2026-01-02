# Supabase Email Templates Configuration

## Overview

Both email verification and password reset use a **unified handler** at `/auth/confirm` that automatically routes users based on the authentication type.

## Configuration Steps

### 1. Set Redirect URL in Supabase

**Supabase Dashboard → Authentication → URL Configuration:**

- **Site URL**: `http://localhost:8000`
- **Redirect URLs**: Add `http://localhost:8000/auth/confirm`

### 2. Update Email Templates

**Both templates** (Email Verification & Password Reset) should use:

```html
<a href="{{ .SiteURL }}/auth/confirm">Verify Email / Reset Password</a>
```

The unified handler reads the `type` parameter from the URL fragment to route correctly:

- `type=signup` or `type=email` → Email verification
- `type=recovery` → Password reset

## How It Works

1. **User clicks email link** → Opens `http://localhost:8000/auth/confirm#access_token=xxx&type=recovery`
2. **Unified handler** (`auth_confirm.html`) checks the `type` parameter
3. **Routes automatically**:
   - Email verification: Calls `POST /auth/verify-email` → Success page
   - Password reset: Redirects to `/auth/password/reset` form

## Endpoints

- `GET /auth/confirm` - Unified authentication handler (routing page)
- `POST /auth/verify-email` - Email verification endpoint
- `GET /auth/verify-success` - Email verification success page
- `GET /auth/password/reset` - Password reset form
- `POST /auth/password/reset/confirm` - Password reset submission
- `GET /auth/reset-success` - Password reset success page

## For Production

Update **Site URL** to your production domain:

```
https://your-domain.com
```

The email templates will automatically use the production URL.
