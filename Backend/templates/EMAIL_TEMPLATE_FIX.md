# ⚠️ IMPORTANT: Email Template Update Required

## Issue Fixed

The email template was using `{{ .SiteURL }}` which caused Supabase to add `/auth/verify` prefix to the URL.

## Solution

Updated the template to use the full hardcoded URL:

```html
http://localhost:8000/auth/password/reset?token={{ .Token }}
```

## Action Required

1. Go to Supabase Dashboard → Authentication → Email Templates
2. Select "Reset Password" template
3. Copy the UPDATED content from `templates/password_reset_email.html`
4. Paste it and click Save
5. Test again from the mobile app

## For Production

When deploying to production, change the URL in the template from:

```
http://localhost:8000/auth/password/reset?token={{ .Token }}
```

To:

```
https://your-production-domain.com/auth/password/reset?token={{ .Token }}
```

## URL Structure

- ✅ CORRECT: `http://localhost:8000/auth/password/reset?token=xyz`
- ❌ WRONG: `/auth/verify/auth/password/reset?token=xyz` (what was happening before)
