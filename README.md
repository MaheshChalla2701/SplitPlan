# SplitPlan 💰

**A social expense-sharing app that makes splitting bills with friends effortless.**

SplitPlan helps you track shared expenses, manage group spending, and settle debts with friends—all in one place. No more awkward conversations about who owes what!

---

## 💡 The Concept

Have you ever gone on a trip with friends, had group dinners, or shared apartment costs and struggled to keep track of who paid for what? SplitPlan solves this by:

1. **Creating Groups**: Organize expenses by context (trips, roommates, events)
2. **Tracking Contributions**: Record who paid and how much
3. **Auto-Calculating Splits**: Automatically divide costs equally among participants
4. **Settling Up**: See exactly who owes whom and track payments

### How It Works

```
Create Group → Add Friends → Log Expenses → Split Automatically → Settle Debts
```

#### Example Scenario

**Weekend Trip with Friends**
1. You create a group called "Beach Trip 2026" with 3 friends
2. Friend A pays $200 for the hotel → Add expense, select all 4 people
3. You pay $80 for groceries → Add expense, select all 4 people
4. Friend B pays $40 for gas → Add expense, select all 4 people
5. **SplitPlan calculates**: Each person should pay $80 total
   - Friend A gets back $120 (paid $200, owes $80)
   - You get back $0 (paid $80, owes $80)
   - Friend B owes $40 (paid $40, owes $80)
   - Friend C owes $80 (paid $0, owes $80)

---

## ✨ Core Features

### 👥 Social Layer
- **Friend System**: Add friends by username or phone number
- **Friend Requests**: Send and accept connection requests
- **Profile Management**: Customize your name, username, and contact info

### 💸 Expense Management
- **Group Creation**: Organize expenses into contexts (trips, dinners, rent)
- **Bill Splitting**: Divide costs equally among selected members
- **Payment History**: Track all transactions within a group
- **Balance Tracking**: See who owes what at a glance

### 🔐 Secure & Private
- **Email Authentication**: Secure login with Firebase Auth
- **Password Management**: Change password anytime
- **Private Groups**: Only invited members can see group expenses
- **Real-time Sync**: Changes sync instantly across all devices

---

## 🏗️ Architecture

### Tech Stack
- **Frontend**: Flutter (Dart)
- **State Management**: Riverpod
- **Backend**: Firebase (Firestore, Auth)
- **Architecture**: Clean Architecture + Domain-Driven Design

### Key Design Principles

1. **Separation of Concerns**: Features are isolated (auth, friends, groups, payments)
2. **Real-time Updates**: Firestore streams ensure everyone sees changes instantly
3. **Offline-First**: Local caching for better performance
4. **Type Safety**: Leveraging Dart's strong typing for reliability

### Project Structure
```
lib/
├── features/
│   ├── auth/           # Login, signup, profile
│   ├── friends/        # Friend management & search
│   ├── groups/         # Group creation & expenses
│   └── payments/       # Payment requests & tracking
└── core/               # Shared utilities
```

---

## 🎯 Use Cases

### 1. **Roommate Expenses**
Track rent, utilities, groceries, and household items. See monthly balances and settle up easily.

### 2. **Group Trips**
Manage hotel, food, gas, and activity costs. Everyone knows exactly what they owe.

### 3. **Regular Dinners**
Split restaurant bills, takeout, and bar tabs with your regular dining group.

### 4. **Event Planning**
Coordinate costs for parties, celebrations, or group activities.

---

## 🚀 Workflow

### Adding Friends
1. Search by `@username` or phone number
2. Send a friend request
3. Friend accepts → You're connected!

### Creating a Group
1. Tap "New Group"
2. Name your group (e.g., "Weekend Trip")
3. Select friends to add
4. Start logging expenses

### Splitting an Expense
1. Open your group
2. Tap "Add Expense"
3. Enter:
   - **Amount**: How much was spent
   - **Description**: What it was for
   - **Paid by**: Who paid
   - **Split among**: Who shares the cost
4. SplitPlan calculates individual shares automatically

### Settling Debts
- View balances in each group
- Send payment requests to friends
- Mark payments as complete when settled

---

## 🔒 Data Model

### Users
- Name, Username, Email, Phone
- Friends list (bidirectional)
- Group memberships

### Groups
- Name, Members, Creation date
- List of expenses
- Calculated balances

### Expenses
- Amount, Description
- Who paid, Who shares the cost
- Split calculation (equal division)
- Timestamp

### Friendships
- Status: pending, accepted
- Bidirectional relationship

---

## 🎨 User Experience

- **Clean Interface**: Minimal, intuitive design
- **Pull to Refresh**: Update data with a swipe
- **Real-time Sync**: See changes as they happen
- **Secure**: Password-protected accounts

---

## 👨‍💻 Author

**Mahesh Challa**  
GitHub: [@MaheshChalla2701](https://github.com/MaheshChalla2701)

---

## 📧 Contact

For questions or feedback: maheshchalla2701@gmail.com

---

**Built with ❤️ using Flutter & Firebase**

## ✨ Features

### 👥 Social & Friends
- **Friend System**: Search and add friends by username or phone number
- **Friend Requests**: Send, receive, accept, or reject friend requests
- **User Profiles**: View and edit your profile with name, username, email, and phone
- **Password Management**: Secure password change functionality

### 💸 Expense Management
- **Group Creation**: Create expense groups with friends
- **Bill Splitting**: Split expenses equally among group members
- **Payment Tracking**: Track who paid and who owes what
- **Payment Requests**: Send and receive payment requests

### 🔐 Authentication
- **Email/Password Login**: Secure authentication with Firebase
- **Profile Management**: Edit name, username, phone number, and password
- **User Search**: Find friends by username with real-time search

### 🎨 User Interface
- **Modern Design**: Clean, intuitive Material Design interface
- **Pull-to-Refresh**: Refresh your data with a simple swipe
- **Real-time Updates**: See changes instantly with Firestore streams

## 🛠️ Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Architecture**: Clean Architecture with Domain-Driven Design
- **Language**: Dart

## 📦 Project Structure

```
lib/
├── core/                    # Core utilities and constants
├── features/
│   ├── auth/               # Authentication (login, signup, profile)
│   ├── friends/            # Friend management and requests
│   ├── groups/             # Group and expense management
│   └── payments/           # Payment requests and tracking
└── main.dart
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 3.0.0)
- Firebase account
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/MaheshChalla2701/SplitPlan.git
   cd SplitPlan
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android/iOS apps to your Firebase project
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the appropriate directories:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`

4. **Enable Firebase Services**
   - **Authentication**: Enable Email/Password sign-in method
   - **Firestore Database**: Create a database in production mode
   - **Storage**: Enable Firebase Storage (optional, for profile pictures)

5. **Deploy Firestore Rules**
   ```bash
   firebase deploy --only firestore:rules
   ```

6. **Create Required Firestore Indexes**
   
   Go to Firebase Console → Firestore → Indexes and create:
   
   - **friendships** collection:
     - Fields: `friendId` (Ascending), `status` (Ascending)
   
   - **payment_requests** collection:
     - Fields: `toUserId` (Ascending), `createdAt` (Descending)
   
   - **groups** collection:
     - Fields: `memberIds` (Array-contains), `createdAt` (Descending)

7. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Usage

### Creating an Account
1. Launch the app
2. Tap "Sign Up"
3. Enter your email, password, name, and username
4. Verify your email (if required)

### Adding Friends
1. Navigate to "Find Friends"
2. Search by username or phone number
3. Send a friend request
4. Wait for acceptance

### Creating a Group
1. Go to "Groups" tab
2. Tap the '+' button
3. Enter group name and select friends
4. Start adding expenses!

### Splitting Expenses
1. Open a group
2. Add a new expense
3. Enter amount and description
4. Select who paid and who's involved
5. The app automatically calculates splits

## 🔒 Security

- Firebase Authentication for secure user management
- Firestore Security Rules to protect user data
- Password validation and secure storage
- Username uniqueness enforcement

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Mahesh Challa**
- GitHub: [@MaheshChalla2701](https://github.com/MaheshChalla2701)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for the backend infrastructure
- Riverpod for state management

## 📧 Support

For support, email maheshchalla2701@gmail.com or open an issue in the repository.

---

**Happy Splitting! 💰**
