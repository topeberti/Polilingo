# Password Reset Configuration for Supabase

## Step 1: Update Supabase Email Template

1. Go to your **Supabase Dashboard**
2. Navigate to **Authentication** → **Email Templates**
3. Select **"Reset Password"** template (also called "Change Email Address" or "Magic Link")
4. Replace the template with the content from `templates/password_reset_email.html`
5. Click **Save**

## Step 2: Configure Redirect URL

1. Go to **Authentication** → **URL Configuration**  
2. Set **Site URL** to: `http://localhost:8000`
3. Add to **Redirect URLs**:
   - `http://localhost:8000/auth/password/reset`
   - `http://localhost:8000/auth/reset-success`

**IMPORTANT**: Supabase will append the access token as a URL fragment (hash):

```
http://localhost:8000/auth/password/reset#access_token=xxx&type=recovery
```

## Step 3: Test the Flow

1. Use the mobile app forgot password feature
2. Enter your email address
3. Check your email for the reset link
4. Click the link - it should open a browser with the password reset form
5. Enter your new password (twice)
6. Submit the form
7. You should see a success message
8. Return to the mobile app and log in with your new password

## Email Template Variables

Supabase provides these variables for email templates:

- `{{ .ConfirmationURL }}` - Complete URL with token (use this!)
- `{{ .Token }}` - Just the token value
- `{{ .Email }}` - User's email address
- `{{ .SiteURL }}` - Your site URL from Supabase settings

## Backend Endpoints

The password reset flow uses these endpoints:

1. **POST /auth/password/reset/request** - Mobile app calls this to send reset email
2. **GET /auth/password/reset** - Serves the HTML form (user clicks email link)
3. **POST /auth/password/reset/confirm** - Form submits to this to update password
4. **GET /auth/reset-success** - Success confirmation page

## For Production

When deploying to production:

1. Update Site URL to your domain
2. Add production redirect URLs
3. The email template will automatically use your production domain
