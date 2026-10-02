# React → Flutter migration matrix

| Original React frontend | Native Flutter destination | Status |
|---|---|---|
| App.jsx | `lib/main.dart`, `lib/core/session.dart`, `lib/screens/shell.dart` | Migrated |
| api/httpClient.js | `lib/api/api_client.dart` | Migrated; secure token storage |
| api/authApi.js | `lib/api/beissab_api.dart` (`AuthApi`) | Migrated |
| api/userApi.js | `lib/api/beissab_api.dart` (`UserApi`) | Migrated |
| api/mealApi.js | `lib/api/beissab_api.dart` (`MealApi`) | Migrated |
| api/weekApi.js | `lib/api/beissab_api.dart` (`WeekApi`, `normalizeWeek`) | Migrated |
| api/preferenceApi.js | User/household mobile settings | Covered by native settings flow |
| LoginPage.jsx | `auth_screens.dart` / `LoginScreen` | Migrated |
| RegisterPage.jsx | `auth_screens.dart` / `RegisterScreen` | Migrated |
| VerifyEmailPage.jsx | `auth_screens.dart` / `VerifyEmailScreen` | Migrated |
| ForgotPasswordPage.jsx | `auth_screens.dart` / `ForgotPasswordScreen` | Migrated |
| ResetPasswordPage.jsx | `auth_screens.dart` / `ResetPasswordScreen` | Migrated |
| onboarding/OnboardingPage.jsx | `onboarding_screen.dart` | Migrated |
| today/TodayPage.jsx + EmptySwipeState.jsx | `today_screen.dart` | Migrated |
| components/FilterBar.jsx | Native filter controls in `TodayScreen` | Migrated |
| components/MealCard.jsx | Native meal card in `TodayScreen` | Migrated |
| RecipeDetailPage.jsx | `recipe_screen.dart` | Migrated |
| plan/PlanPage.jsx | `plan_screen.dart` | Migrated |
| shopping/ShoppingPage.jsx | `shopping_screen.dart` | Migrated |
| shopping/ShoppingListItem.jsx | Native CheckboxListTile/Dismissible | Migrated |
| shopping/EditShoppingItemModal.jsx | Native AlertDialog editor | Migrated |
| MobileBottomNav.jsx | Material 3 `NavigationBar` in `shell.dart` | Migrated |
| more/MorePage.jsx | `more_screens.dart` / `MoreScreen` | Migrated |
| more/SettingsPage.jsx | `SettingsScreen` | Migrated |
| more/FamilyPage.jsx | `FamilyScreen` | Migrated |
| more/NotificationSettingsPage.jsx | `NotificationScreen` | Migrated |
| more/PrivacyPage.jsx | `PrivacyScreen` | Migrated for mobile |
| more/ChangelogPage.jsx | `ChangelogScreen` | Migrated |
| React localStorage auth | `flutter_secure_storage` | Replaced with native-secure equivalent |
| Browser navigation | `go_router` | Replaced with native Flutter routing |
| Framer Motion/Tailwind | Flutter widgets/theme | Replaced; no web runtime |
| Recipe/brand images | `assets/images`, `assets/brand` | Copied |

## Web-only pages
`LandingPage.jsx`, public FAQ, Impressum, AGB and the public website Privacy page are website content rather than authenticated application flows. They remain on the public BeissAb website; the mobile client contains an in-app privacy screen and can be extended with native legal screens/links before store submission.
