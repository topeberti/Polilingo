# Email Templates for Supabase

Copy these templates into your Supabase Dashboard → Authentication → Email Templates

---

## 1. Confirm Signup Template

**Template Name:** Confirm signup

**Paste this into the template editor:**

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verify Your Email | Polilingo</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            width: 100% !important;
            height: 100% !important;
            background-color: #0F172A;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            -webkit-font-smoothing: antialiased;
        }
        table {
            border-spacing: 0;
            border-collapse: collapse;
        }
        td {
            padding: 0;
        }
        img {
            border: 0;
        }
        .wrapper {
            width: 100%;
            table-layout: fixed;
            background-color: #0F172A;
            padding-bottom: 40px;
        }
        .main {
            background-color: #1E293B;
            margin: 0 auto;
            width: 100%;
            max-width: 600px;
            border-spacing: 0;
            color: #F8FAFC;
            border-radius: 16px;
            overflow: hidden;
            border: 1px solid rgba(255, 255, 255, 0.05);
        }
        .header {
            padding: 40px 0 20px;
            text-align: center;
        }
        .content {
            padding: 0 40px 40px;
            text-align: center;
        }
        h1 {
            font-size: 24px;
            font-weight: 800;
            margin: 0 0 16px;
            color: #FFFFFF;
            letter-spacing: -0.025em;
        }
        p {
            font-size: 16px;
            line-height: 24px;
            margin: 0 0 24px;
            color: #94A3B8;
        }
        .button-container {
            padding: 20px 0 30px;
        }
        .button {
            background-color: #4F46E5;
            color: #FFFFFF !important;
            padding: 14px 32px;
            text-decoration: none;
            border-radius: 10px;
            font-weight: 600;
            font-size: 16px;
            display: inline-block;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
        }
        .footer {
            padding: 30px 40px;
            text-align: center;
            font-size: 12px;
            color: #64748B;
        }
        .divider {
            height: 1px;
            background-color: rgba(255, 255, 255, 0.05);
            margin: 0 40px;
        }
    </style>
</head>
<body>
    <center class="wrapper">
        <table class="main" width="100%">
            <tr>
                <td class="header">
                    <div style="font-size: 28px; font-weight: 800; color: #4F46E5;">
                        Polilingo
                    </div>
                </td>
            </tr>
            <tr>
                <td class="content">
                    <h1>Confirm your signup</h1>
                    <p>Welcome to Polilingo! We're excited to have you on board. To start your journey towards exam success, please confirm your email address.</p>
                    <div class="button-container">
                        <a href="{{ .ConfirmationURL }}" class="button">Verify Email Address</a>
                    </div>
                    <p style="font-size: 14px;">If you didn't create an account with us, you can safely ignore this email.</p>
                    <p style="font-size: 12px; color: #64748B; margin-top: 20px;">
                        If the button doesn't work, copy this link: {{ .ConfirmationURL }}
                    </p>
                </td>
            </tr>
            <tr>
                <td><div class="divider"></div></td>
            </tr>
            <tr>
                <td class="footer">
                    <p style="margin: 0; font-size: 12px;">&copy; 2026 Polilingo. All rights reserved.</p>
                </td>
            </tr>
        </table>
    </center>
</body>
</html>
```

---

## 2. Reset Password Template

**Template Name:** Reset Password

**This template is already updated in `password_reset_email.html`**

The button now points to: `{{ .SiteURL }}/auth/confirm`

---

## 3. Password Changed Template

**Template Name:** Password Changed

**Paste this into the template editor:**

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Password Changed - Polilingo</title>
</head>
<body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background-color: #0a0a0a;">
    <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #0a0a0a; padding: 40px 20px;">
        <tr>
            <td align="center">
                <table width="600" cellpadding="0" cellspacing="0" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 16px; overflow: hidden; box-shadow: 0 10px 40px rgba(0,0,0,0.3);">
                    <tr>
                        <td style="padding: 40px 40px 30px 40px; text-align: center;">
                            <h1 style="margin: 0; color: #ffffff; font-size: 32px; font-weight: 700; letter-spacing: -0.5px;">Polilingo</h1>
                            <p style="margin: 8px 0 0 0; color: rgba(255,255,255,0.9); font-size: 14px; font-weight: 500;">Master Languages, Unlock Worlds</p>
                        </td>
                    </tr>
                    <tr>
                        <td style="background-color: #ffffff; padding: 40px;">
                            <div style="text-align: center; margin-bottom: 30px;">
                                <div style="width: 60px; height: 60px; background: #f0fdf4; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; margin: 0 auto;">
                                    <span style="font-size: 30px;">🔐</span>
                                </div>
                            </div>
                            <h2 style="margin: 0 0 20px 0; color: #1a1a1a; font-size: 24px; font-weight: 600; text-align: center;">Your password has been changed</h2>
                            <p style="margin: 0 0 20px 0; color: #4a4a4a; font-size: 16px; line-height: 1.6; text-align: center;">This is a confirmation that the password for your account <strong style="color: #667eea;">{{ .Email }}</strong> has just been changed.</p>
                            <div style="background-color: #fff9f0; border-left: 4px solid #f59e0b; padding: 15px; margin: 30px 0; border-radius: 4px;">
                                <p style="margin: 0; color: #92400e; font-size: 14px; line-height: 1.5;"><strong>If you did not make this change</strong>, please contact our support team immediately or reset your password to secure your account.</p>
                            </div>
                            <p style="margin: 0; color: #6b6b6b; font-size: 14px; line-height: 1.6; text-align: center;">You can now log in to the app with your new password.</p>
                        </td>
                    </tr>
                    <tr>
                        <td style="background-color: #1a1a1a; padding: 30px 40px; text-align: center;">
                            <p style="margin: 0; color: rgba(255,255,255,0.5); font-size: 12px;">© 2026 Polilingo. All rights reserved.</p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
```

---

## Configuration Required

**Before saving:** Go to Authentication → URL Configuration and set:

- **Site URL**: `http://localhost:8000`
- **Redirect URLs**: Add `http://localhost:8000/auth/confirm`

All templates will now redirect to the same unified handler which automatically routes based on the type!
