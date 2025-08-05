#  ExpenseBuddy

**ExpenseBuddy** is a SwiftUI iOS app that helps users manage their daily expenses efficiently. It supports offline syncing and integrates with Supabase for backend services.

##  Features

-  Email + OTP Authentication using Supabase
-  Track and filter expenses (Day / Week / Month / Year)
-  Offline sync using Network Monitor
-  Upload profile picture to Supabase Storage
-  Charts with Apple’s Swift Charts framework

##  Folder Structure

###  MVVM (Model-View-ViewModel)

- **Models** (`Models/DataModel/ExpenseBuddy.swift`): Defines the structure for expenses and other domain data.
- **ViewModels** (`ViewModels/AuthViewModel.swift`): Handles business logic, user session state, and binds data to SwiftUI views.
- **Views** (`Views/`, `Profile/`): SwiftUI-based UI components that reflect ViewModel state.

###  Supabase Integration (`Services/SupabaseAuthService.swift`, `ProfileService.swift`, `ExpenseService.swift`)

- **Authentication**: Email + OTP-based login and signup using Supabase Auth.
- **Storage**: Profile images uploaded to Supabase Storage.
- **Database**: Expense data is stored and fetched from Supabase PostgreSQL tables using `ExpenseService`.

###  Offline Sync (`Services/OfflineSyncService.swift`)

- **Connectivity Monitoring**: Uses `NWPathMonitor` from Apple’s `Network` framework to detect online/offline state.
- **Sync Queue**: Locally caches offline actions and automatically syncs when the device regains connectivity.

### Data Persistence (`Services/CoreDataManager.swift`)

- Used to persist data locally if needed (e.g., for offline-first experiences).
- Helps reduce server dependency for frequently accessed data.

###  Profile Management (`Services/ProfileService.swift`, `Profile/*.swift`)

- Handles profile views like edit, about, privacy settings, and support.
- ViewModel logic is abstracted into service layers for clean separation.

###  Charts & Analytics (`Views/AnalyticsView.swift`)

- Apple’s native `Charts` framework is used for rendering expense analytics in a bar chart format.

##  Screenshots

###  Add Expense
![Add Expense](Screenshots/addExpense/addExpense.png)

###  Analysis
![Analysis](Screenshots/analysis/analysis.png)

###  Home
![Home](Screenshots/Home/Home.png)

###  Profile
![Profile](Screenshots/profile/profile.png)

###  Signup
![Signup](Screenshots/signup/signup.png)

