
# **BillBucket – Smart Bill Tracking App 🧾💰**

BillBucket is a clean, fast, and privacy-friendly bill-tracking app built with **Flutter**.
It helps users organise their recurring bills, view upcoming payments, track payment history, and calculate weekly budget requirements — all with an elegant UI and a simple workflow.

---

## **🚀 Features**

### 🔹 **Add & Manage Bills**

* Supports **weekly, fortnightly, monthly, and yearly** bill frequency.
* Clean and minimal bill creation form.
* Edit or delete bills at any time.

### 🔹 **Smart Dashboard**

* Shows the **total monthly cost** of all recurring bills.
* Provides a **recommended weekly transfer amount** so users always stay ahead.
* Displays **upcoming bills** for the next 14 days.

### 🔹 **Payment Tracking**

* Mark a bill as paid.
* Automatically calculates the **next due date** based on its frequency.
* Undo accidental payments with one tap.

### 🔹 **Local Storage (No Cloud)**

* Uses **Hive** for fast, secure offline storage.
* No data leaves the device — privacy by default.

### 🔹 **Modern & Adaptive UI**

* Material 3 design.
* Beautiful light/dark themes.
* Smooth animations and responsive layout.

---

## **📱 Screens & Workflow**

### **1. Dashboard**

* Monthly total
* Weekly transfer suggestion
* Upcoming bills list

### **2. Add / Edit Bill**

* Name, amount, frequency
* Next due date picker

### **3. Bill Details**

* Full overview
* Mark as paid / undo
* Edit bill
* Delete bill

### **4. Settings**

* Light / Dark / System theme
* App version & developer info

---

## **🛠️ Tech Stack**

| Layer            | Tools                               |
| ---------------- | ----------------------------------- |
| Frontend         | Flutter (Material 3)                |
| State Management | Provider                            |
| Local Storage    | Hive                                |
| Architecture     | Provider + Clean, modular structure |
| Other Packages   | package_info_plus, url_launcher     |

---

## **📦 Project Structure**

```
lib/
 ├─ models/
 │   └─ bill.dart
 ├─ providers/
 │   ├─ bill_provider.dart
 │   └─ settings_provider.dart
 ├─ screens/
 │   ├─ dashboard_screen.dart
 │   ├─ bill_detail_screen.dart
 │   ├─ add_edit_bill_screen.dart
 │   └─ settings_screen.dart
 ├─ utils/
 │   └─ formatters.dart
 ├─ main.dart
```

---

## **⚙️ Setup & Run**

### **1. Install dependencies**

```
flutter pub get
```

### **2. Generate Hive adapters**

```
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### **3. Run the app**

```
flutter run
```

---

## **🧪 Testing**

### Reset Hive data (optional)

```
flutter clean
rm -rf build/
rm -rf <your_hive_boxes_path>
```

---

## **📄 License**

This project is licensed under the **MIT License** — feel free to use, modify, or build upon it.

---

## **👤 Developer**

**Parth Patel**
📧 Email: [patel.parth2201@gmail.com](mailto:patel.parth2201@gmail.com)
💼 GitHub: [https://github.com/Parth-Patel01](https://github.com/Parth-Patel01)
❤️ Built with Flutter

---

## **⭐ Support**

If you find BillBucket useful, consider starring the GitHub repo to support development.

