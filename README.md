# IProfit Complete Mobile API CURL Commands Guide

## Base Configuration

**Base URL:** `https://your-iprofit-domain.com`  
**Authentication:** Bearer Token (JWT)  
**Required Headers:** `x-device-id`, `x-fingerprint` for user operations

---

## 1. Authentication APIs

### 1.1 User Registration

```bash
curl -X POST "https://your-domain.com/api/auth/register" \
  -H "Content-Type: application/json" \
  -H "x-device-id: DEVICE_ID_HERE" \
  -H "x-fingerprint: DEVICE_FINGERPRINT" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1234567890",
    "password": "SecurePass123!",
    "confirmPassword": "SecurePass123!",
    "deviceId": "unique_device_id_123",
    "planId": "507f1f77bcf86cd799439011",
    "referralCode": "REF123",
    "dateOfBirth": "1990-01-01",
    "address": {
      "street": "123 Main St",
      "city": "New York",
      "state": "NY",
      "country": "USA",
      "zipCode": "10001"
    },
    "acceptTerms": true,
    "acceptPrivacy": true
  }'
```

### 1.2 User Login

```bash
curl -X POST "https://your-domain.com/api/auth/login" \
  -H "Content-Type: application/json" \
  -H "x-device-id: DEVICE_ID_HERE" \
  -d '{
    "email": "john@example.com",
    "password": "SecurePass123!",
    "userType": "user",
    "deviceId": "unique_device_id_123",
    "rememberMe": true,
    "twoFactorToken": "123456"
  }'
```

### 1.3 Logout

```bash
curl -X POST "https://your-domain.com/api/auth/logout" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE"
```

### 1.4 Refresh Token

```bash
curl -X POST "https://your-domain.com/api/auth/refresh" \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "your_refresh_token_here"
  }'
```

---

## 2. User Dashboard

### 2.1 Get Dashboard Data

```bash
curl -X GET "https://your-domain.com/api/users/dashboard" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE"
```

---

## 3. User Profile & Management

### 3.1 Get User Profile

```bash
curl -X GET "https://your-domain.com/api/users/507f1f77bcf86cd799439011" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE"
```

### 3.2 Update User Profile

```bash
curl -X PUT "https://your-domain.com/api/users/507f1f77bcf86cd799439011" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -d '{
    "name": "John Updated",
    "phone": "+1234567899",
    "address": {
      "street": "789 New Street",
      "city": "Boston",
      "state": "MA",
      "country": "USA",
      "zipCode": "02101"
    },
    "dateOfBirth": "1990-01-01"
  }'
```

### 3.3 Update User Preferences

```bash
curl -X PUT "https://your-domain.com/api/users/preferences" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE" \
  -d '{
    "notifications": {
      "email": {
        "kyc": true,
        "transactions": true,
        "loans": true,
        "referrals": true,
        "tasks": true,
        "system": true,
        "marketing": false,
        "security": true
      },
      "push": {
        "kyc": true,
        "transactions": true,
        "loans": true,
        "referrals": true,
        "tasks": true,
        "system": true,
        "marketing": false,
        "security": true
      },
      "sms": {
        "kyc": false,
        "transactions": true,
        "loans": true,
        "referrals": false,
        "tasks": false,
        "system": true,
        "marketing": false,
        "security": true
      },
      "inApp": {
        "kyc": true,
        "transactions": true,
        "loans": true,
        "referrals": true,
        "tasks": true,
        "system": true,
        "marketing": true,
        "security": true
      }
    },
    "privacy": {
      "profileVisibility": "private",
      "showBalance": false,
      "showTransactions": false,
      "showReferrals": false,
      "allowContact": true
    },
    "app": {
      "language": "en",
      "currency": "USD",
      "theme": "auto",
      "biometricLogin": false,
      "autoLock": true,
      "autoLockDuration": 5,
      "soundEnabled": true,
      "vibrationEnabled": true
    }
  }'
```

---

## 4. Wallet Operations

### 4.1 Create Deposit (CoinGate)

```bash
curl -X POST "https://your-domain.com/api/users/wallet/deposit" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE" \
  -d '{
    "amount": 100.00,
    "currency": "USD",
    "gateway": "CoinGate",
    "depositMethod": "cryptocurrency",
    "deviceId": "unique_device_id_123",
    "gatewayData": {
      "cryptoCurrency": "bitcoin",
      "urgentProcessing": false,
      "walletAddress": "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"
    },
    "acceptTerms": true,
    "confirmAmount": true
  }'
```

### 4.2 Create Deposit (UddoktaPay)

```bash
curl -X POST "https://your-domain.com/api/users/wallet/deposit" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE" \
  -d '{
    "amount": 5000.00,
    "currency": "BDT",
    "gateway": "UddoktaPay",
    "depositMethod": "mobile_banking",
    "deviceId": "unique_device_id_123",
    "gatewayData": {
      "mobileProvider": "bkash",
      "mobileNumber": "+8801712345678",
      "urgentProcessing": true
    },
    "acceptTerms": true,
    "confirmAmount": true
  }'
```

### 4.3 Create Withdrawal

```bash
curl -X POST "https://your-domain.com/api/users/wallet/withdraw" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE" \
  -d '{
    "amount": 500.00,
    "currency": "USD",
    "withdrawalMethod": "bank_transfer",
    "accountDetails": {
      "accountNumber": "9876543210",
      "routingNumber": "021000021",
      "bankName": "Chase Bank",
      "accountHolderName": "John Doe",
      "bankAddress": "123 Bank St, New York, NY 10001"
    },
    "urgentWithdrawal": false,
    "deviceId": "unique_device_id_123",
    "twoFactorToken": "123456"
  }'
```

### 4.4 Get Wallet History

```bash
curl -X GET "https://your-domain.com/api/users/wallet/history?page=1&limit=20&type=all&status=all&gateway=all&sortBy=createdAt&sortOrder=desc&includeMetadata=true" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE"
```

---

## 5. Portfolio Management

### 5.1 Get Portfolio Overview

```bash
curl -X GET "https://your-domain.com/api/users/portfolio?includeAnalytics=true&period=monthly" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE"
```

---

## 6. Loans & EMI

### 6.1 Get User Loans

```bash
curl -X GET "https://your-domain.com/api/users/loans?page=1&limit=10&status=all&sortBy=createdAt&sortOrder=desc" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE"
```

### 6.2 Apply for Loan

```bash
curl -X POST "https://your-domain.com/api/users/loans" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE" \
  -d '{
    "amount": 5000.00,
    "currency": "USD",
    "purpose": "Business Investment",
    "tenure": 12,
    "monthlyIncome": 3000.00,
    "employmentStatus": "Full-time Employee",
    "employmentDetails": {
      "companyName": "Tech Corp",
      "position": "Software Engineer",
      "experience": "3 years",
      "workAddress": "123 Tech St, Silicon Valley, CA"
    },
    "personalDetails": {
      "fullName": "John Doe",
      "dateOfBirth": "1990-01-01",
      "maritalStatus": "Single",
      "education": "Bachelor\'s Degree",
      "dependents": 0
    },
    "financialDetails": {
      "bankName": "Chase Bank",
      "accountNumber": "1234567890",
      "monthlyExpenses": 1500.00,
      "otherLoans": [],
      "creditScore": 750
    },
    "documents": [
      {
        "type": "Identity Proof",
        "url": "https://example.com/id-card.jpg",
        "filename": "national_id.jpg"
      },
      {
        "type": "Income Certificate",
        "url": "https://example.com/salary-slip.pdf",
        "filename": "salary_certificate.pdf"
      }
    ]
  }'
```

### 6.3 Calculate EMI

```bash
curl -X POST "https://your-domain.com/api/loans/emi-calculator" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -d '{
    "loanAmount": 5000.00,
    "interestRate": 12.5,
    "tenure": 12
  }'
```

### 6.4 Get Loan Repayment Schedule

```bash
curl -X GET "https://your-domain.com/api/users/loans/507f1f77bcf86cd799439011/repayment-schedule" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE"
```

---

## 7. Tasks & Earnings

### 7.1 Get Available Tasks

```bash
curl -X GET "https://your-domain.com/api/users/tasks?page=1&limit=20&category=all&difficulty=all&rewardMin=5&rewardMax=100&sortBy=rewardAmount&sortOrder=desc" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE"
```

### 7.2 Submit Task

```bash
curl -X POST "https://your-domain.com/api/users/tasks/507f1f77bcf86cd799439011/submit" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE" \
  -d '{
    "proof": [
      {
        "type": "screenshot",
        "url": "https://example.com/screenshot1.jpg",
        "description": "Screenshot of completed follow action"
      },
      {
        "type": "link",
        "url": "https://instagram.com/my-profile",
        "description": "Link to my Instagram profile showing follow"
      }
    ],
    "completionNotes": "Successfully followed @iprofit_official and liked their latest post",
    "completedAt": "2024-01-01T10:30:00.000Z"
  }'
```

### 7.3 Get Task Submissions

```bash
curl -X GET "https://your-domain.com/api/users/tasks/submissions?page=1&limit=20&status=all&sortBy=createdAt&sortOrder=desc" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE"
```

---

## 8. Referrals & Earnings

### 8.1 Get Referral Overview

```bash
curl -X GET "https://your-domain.com/api/users/referrals?page=1&limit=20&status=all&sortBy=createdAt&sortOrder=desc" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE"
```

### 8.2 Get Referral Link

```bash
curl -X GET "https://your-domain.com/api/users/referrals/link" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE"
```

### 8.3 Get Referral Earnings

```bash
curl -X GET "https://your-domain.com/api/users/referrals/earnings?period=monthly&page=1&limit=50" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE"
```

---

## 9. Profits & Analytics

### 9.1 Get Profit History

```bash
curl -X GET "https://your-domain.com/api/users/profits?period=monthly&page=1&limit=50" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE"
```

### 9.2 Get Earnings Summary

```bash
curl -X GET "https://your-domain.com/api/users/earnings?type=all&period=monthly&includeBreakdown=true" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE"
```

---

## 10. KYC & Verification

### 10.1 Upload KYC Documents

```bash
curl -X POST "https://your-domain.com/api/users/kyc/upload" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE" \
  -F "documentType=national_id" \
  -F "file=@/path/to/national_id.jpg" \
  -F "documentNumber=ID123456789"
```

### 10.2 Submit KYC Application

```bash
curl -X POST "https://your-domain.com/api/users/kyc/submit" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE" \
  -d '{
    "personalInfo": {
      "fullName": "John Doe",
      "dateOfBirth": "1990-01-01",
      "nationality": "US",
      "occupation": "Software Engineer",
      "monthlyIncome": "3000-5000"
    },
    "documents": [
      {
        "type": "national_id",
        "number": "ID123456789",
        "url": "https://example.com/national_id.jpg",
        "expiryDate": "2030-01-01"
      },
      {
        "type": "utility_bill",
        "url": "https://example.com/utility_bill.pdf",
        "issueDate": "2023-12-01"
      },
      {
        "type": "selfie_with_id",
        "url": "https://example.com/selfie_with_id.jpg"
      }
    ],
    "address": {
      "street": "123 Main St",
      "city": "New York",
      "state": "NY",
      "country": "USA",
      "zipCode": "10001"
    }
  }'
```

### 10.3 Get KYC Status

```bash
curl -X GET "https://your-domain.com/api/users/kyc/status" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE"
```

---

## 11. Achievements & Gamification

### 11.1 Get User Achievements

```bash
curl -X GET "https://your-domain.com/api/users/achievements?category=all&status=all&includeProgress=true" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE"
```

---

## 12. Notifications

### 12.1 Get User Notifications

```bash
curl -X GET "https://your-domain.com/api/users/notifications?page=1&limit=20&type=all&read=all&sortBy=createdAt&sortOrder=desc" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE"
```

### 12.2 Mark Notification as Read

```bash
curl -X PATCH "https://your-domain.com/api/users/notifications/507f1f77bcf86cd799439011/read" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE"
```

### 12.3 Register FCM Device Token

```bash
curl -X POST "https://your-domain.com/api/notifications/register-device" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE" \
  -d '{
    "fcmToken": "fcm_registration_token_here_very_long_string",
    "deviceId": "unique_device_id_123",
    "platform": "android",
    "appVersion": "1.0.0",
    "osVersion": "13",
    "deviceModel": "Samsung Galaxy S21",
    "deviceBrand": "Samsung"
  }'
```

---

## 13. Mobile Device Management

### 13.1 Get User Devices

```bash
curl -X GET "https://your-domain.com/api/mobile/devices?includeStats=true&includeHistory=true" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE"
```

### 13.2 Update Device Information

```bash
curl -X PUT "https://your-domain.com/api/mobile/device-update" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE" \
  -d '{
    "deviceId": "unique_device_id_123",
    "updates": {
      "deviceName": "John\'s Phone",
      "appVersion": "1.0.1",
      "osVersion": "13.1",
      "fcmToken": "new_fcm_token_here",
      "locationInfo": {
        "country": "US",
        "city": "New York",
        "timezone": "America/New_York"
      }
    }
  }'
```

### 13.3 Remove Device

```bash
curl -X DELETE "https://your-domain.com/api/mobile/devices/unique_device_id_123" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE"
```

---

## 14. Support & Help

### 14.1 Create Support Ticket

```bash
curl -X POST "https://your-domain.com/api/users/support/tickets" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE" \
  -d '{
    "subject": "Unable to withdraw funds",
    "message": "I am trying to withdraw $500 but getting an error message",
    "category": "Payment Problems",
    "priority": "Medium",
    "attachments": [
      {
        "filename": "error_screenshot.jpg",
        "url": "https://example.com/screenshot.jpg",
        "mimeType": "image/jpeg",
        "size": 1024000
      }
    ]
  }'
```

### 14.2 Get Support Tickets

```bash
curl -X GET "https://your-domain.com/api/users/support/tickets?page=1&limit=20&status=all&category=all&sortBy=createdAt&sortOrder=desc" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE"
```

### 14.3 Reply to Support Ticket

```bash
curl -X POST "https://your-domain.com/api/users/support/tickets/507f1f77bcf86cd799439011/replies" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE" \
  -d '{
    "message": "Thank you for the help. The issue is now resolved.",
    "attachments": []
  }'
```

---

## 15. File Upload

### 15.1 Upload Profile Picture

```bash
curl -X POST "https://your-domain.com/api/users/upload/profile" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE" \
  -F "file=@/path/to/profile.jpg" \
  -F "resize=true" \
  -F "quality=80"
```

### 15.2 Upload Document

```bash
curl -X POST "https://your-domain.com/api/users/upload/document" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE" \
  -F "file=@/path/to/document.pdf" \
  -F "documentType=income_certificate" \
  -F "category=kyc_documents"
```

---

## 16. Plans & Subscriptions

### 16.1 Get Available Plans

```bash
curl -X GET "https://your-domain.com/api/plans?active=true" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE"
```

### 16.2 Upgrade Plan

```bash
curl -X POST "https://your-domain.com/api/users/plan/upgrade" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE" \
  -d '{
    "planId": "507f1f77bcf86cd799439012",
    "paymentMethod": "wallet_balance",
    "confirmUpgrade": true
  }'
```

---

## 17. News & Updates

### 17.1 Get News Feed

```bash
curl -X GET "https://your-domain.com/api/users/news?page=1&limit=20&category=all&sortBy=publishedAt&sortOrder=desc" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE"
```

### 17.2 Get News Article

```bash
curl -X GET "https://your-domain.com/api/users/news/507f1f77bcf86cd799439011" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE"
```

---

## 18. Two-Factor Authentication

### 18.1 Setup 2FA

```bash
curl -X POST "https://your-domain.com/api/users/2fa/setup" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE"
```

### 18.2 Enable 2FA

```bash
curl -X POST "https://your-domain.com/api/users/2fa/enable" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE" \
  -d '{
    "token": "123456",
    "backupCodes": ["backup1", "backup2", "backup3"]
  }'
```

### 18.3 Disable 2FA

```bash
curl -X POST "https://your-domain.com/api/users/2fa/disable" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE" \
  -d '{
    "token": "123456",
    "password": "current_password"
  }'
```

---

## 19. Security & Account

### 19.1 Change Password

```bash
curl -X POST "https://your-domain.com/api/users/security/change-password" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE" \
  -d '{
    "currentPassword": "old_password",
    "newPassword": "new_secure_password123!",
    "confirmPassword": "new_secure_password123!"
  }'
```

### 19.2 Get Security Settings

```bash
curl -X GET "https://your-domain.com/api/users/security/settings" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE"
```

### 19.3 Get Login History

```bash
curl -X GET "https://your-domain.com/api/users/security/login-history?page=1&limit=20" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "x-device-id: DEVICE_ID_HERE"
```

---

## 20. Complete Response Formats

### Success Response

```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {
    // Response data here
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### Paginated Response

```json
{
  "success": true,
  "data": [
    // Array of items
  ],
  "pagination": {
    "currentPage": 1,
    "totalPages": 10,
    "totalItems": 200,
    "itemsPerPage": 20,
    "hasNextPage": true,
    "hasPreviousPage": false
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### Error Response

```json
{
  "success": false,
  "error": "Error message",
  "code": 400,
  "details": {
    // Additional error details
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### Validation Error Response

```json
{
  "success": false,
  "error": "Validation failed",
  "code": 422,
  "details": [
    {
      "field": "amount",
      "message": "Amount must be positive",
      "code": "invalid_value"
    }
  ],
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

---

## 21. Rate Limiting

Most endpoints have rate limiting. If exceeded:

**Response:**

```json
{
  "success": false,
  "error": "Too many requests",
  "code": 429,
  "details": {
    "limit": 100,
    "remaining": 0,
    "resetTime": "2024-01-01T01:00:00.000Z"
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

---

## 22. Key Constants & Enums

### Transaction Types

- `deposit`, `withdrawal`, `bonus`, `profit`, `penalty`, `referral_bonus`, `task_reward`

### Transaction Status

- `Pending`, `Approved`, `Rejected`, `Processing`, `Failed`, `Cancelled`

### KYC Document Types

- `national_id`, `passport`, `driving_license`, `utility_bill`, `bank_statement`, `selfie_with_id`

### Task Categories

- `Social Media`, `App Installation`, `Survey`, `Review`, `Referral`, `Video Watch`, `Article Read`, `Registration`

### Loan Status

- `Pending`, `Approved`, `Rejected`, `Active`, `Completed`, `Defaulted`

### Currencies

- `USD`, `BDT`

### Payment Gateways

- `CoinGate`, `UddoktaPay`, `Manual`

This comprehensive guide covers all the mobile API endpoints for the iprofit Flutter client implementation. Each endpoint includes complete curl commands with realistic request bodies and expected response formats.

🏗️ Complete Architecture

Clean Architecture with proper separation (data/domain/presentation)
Riverpod for state management with code generation
Go Router with nested routes and authentication guards
shadcn_ui for consistent UI components

📱 Core Features Based on Your API

Authentication (login, register, 2FA)
Dashboard with financial overview
Wallet Operations (deposits, withdrawals, history)
Portfolio Management with analytics
Loans & EMI calculator
Tasks & Earnings system
Referrals management
KYC Verification with document upload
Notifications with FCM
Device Management with fingerprinting

🛠️ Rich Plugin Integration

Device Info Plus for device identification
Connectivity Plus for network monitoring
Local Auth for biometric authentication
Firebase Messaging for push notifications
Image/File Picker for document uploads
FL Chart for portfolio visualizations
QR Code for referral links
Secure Storage for sensitive data

🔧 Key Technical Features

API Client with automatic token refresh and device headers
Error Handling with custom exceptions
Network Monitoring with connectivity checks
Device Fingerprinting for security
Secure Token Storage with encryption
Route Guards for authentication
Loading States and error management

📂 Organized Structure

80+ files properly organized by feature
Type-safe models for all API responses
Repository pattern for data access
Provider-based state management
Reusable widgets and services
