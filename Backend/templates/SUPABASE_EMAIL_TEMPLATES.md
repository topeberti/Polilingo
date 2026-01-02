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

## Configuration Required

**Before saving:** Go to Authentication → URL Configuration and set:

- **Site URL**: `http://localhost:8000`
- **Redirect URLs**: Add `http://localhost:8000/auth/confirm`

Both templates will now redirect to the same unified handler which automatically routes based on the type!
