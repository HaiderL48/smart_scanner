# Smart Scanner

A Flutter application that scans and extracts structured data from credit/debit cards 
and bank passbooks using OCR and custom parsing logic.

---

## Steps to Run the Project

### Prerequisites
- Flutter SDK (3.0.0 or above)
- Android Studio / VS Code
- Android device or emulator (API level 21+)
- USB debugging enabled (for physical device)

### Steps

1. **Clone the repository**
```bash
   git clone https://github.com/your-username/smart_scanner.git
   cd smart_scanner
```

2. **Install dependencies**
```bash
   flutter pub get
```

3. **Run the app**
```bash
   flutter run
```

4. **Run tests**
```bash
   flutter test
```

---

## Libraries Used

| Library | Version | Purpose |
|---|---|---|
| `google_mlkit_text_recognition` | ^0.11.0 | On-device OCR — converts camera image to raw text |
| `image_picker` | ^1.0.7 | Pick image from camera or gallery |
| `camera` | ^0.10.5+9 | Live camera access |
| `permission_handler` | ^11.3.0 | Request camera and storage permissions at runtime |
| `go_router` | ^13.2.0 | Navigation and routing between screens |

### Why these libraries?

- **ML Kit** was chosen over Tesseract because it runs fully on-device, 
  is faster, and has better accuracy on Indian bank documents and cards.
- **All parsing logic is written manually** — no library is used to 
  extract card numbers, expiry dates, IFSC codes, or account holder names.

---

## Assumptions Made

### General
- App targets Android only as per assignment requirement. 
  iOS support is not configured.
- Internet connection is not required. 
  All processing is done fully on-device.
- The app is designed for Indian bank passbooks and 
  Indian credit/debit cards only.

### Card Scanner
- Card numbers follow standard formats:
  16 digits (Visa, Mastercard, RuPay) or 15 digits (Amex).
- Expiry date is always in MM/YY, MM/YYYY, MM-YY, or MMYY format.
- Card holder name is printed in capital letters on the card.
- A card number is only accepted if it passes the Luhn algorithm — 
  this filters out phone numbers and other digit sequences 
  that appear on the card.
- OCR commonly misreads `O` as `0`, `I` as `1`, `l` as `1` — 
  these are corrected before Luhn validation.

### Passbook Scanner
- Account holder name is printed in capital letters.
- Account numbers are between 9 and 18 digits as per 
  Indian banking standards.
- IFSC code always follows the RBI standard format — 
  4 letters + 0 + 6 alphanumeric characters.
- The 5th character of IFSC is always `0` (zero) — 
  if OCR reads it as `O` (letter), it is normalized to `0`.
- CIF numbers are excluded from account number extraction 
  by detecting the `CIF` keyword near them.
- Joint account holder names are excluded by detecting 
  the `JOINT` keyword on the same line.
- OCR commonly misreads `m` as `n` in keywords — 
  for example `Customer Name` becomes `Custoner Nane`. 
  The parser handles this using fuzzy keyword matching.

---

## What Was Skipped and Why

### iOS Support
- **Skipped** — Assignment required Android only. 
  ML Kit and camera packages support iOS 
  but permissions and build configuration 
  were not set up for iOS.

### Live Camera Card Scanning (Real-time)
- **Skipped** — Real-time frame-by-frame scanning 
  requires camera streaming and image processing 
  on every frame which significantly increases complexity. 
  Instead, the user captures a single photo which is 
  then processed. This gives the same result with 
  simpler and more stable code.

### Image Preprocessing (Contrast / Sharpening)
- **Skipped** — Libraries like `image` can boost contrast 
  and sharpen blurry photos before passing to ML Kit. 
  This was skipped due to time constraints. 
  ML Kit handles minor blur internally. 
  Very blurry images show a clear error message 
  asking the user to retake the photo.

### Multi-page Passbook Scanning
- **Skipped** — The assignment focuses on single image scanning. 
  Multi-page support would require stitching OCR results 
  across multiple images which is beyond the scope.

### Backend / Cloud OCR
- **Not used by design** — Assignment explicitly requires 
  no backend services. All OCR and parsing runs on-device.

### Parsing Libraries
- **Not used by design** — Assignment explicitly requires 
  all parsing logic to be implemented manually. 
  No library is used for extracting card numbers, 
  expiry dates, names, account numbers, or IFSC codes.

---
