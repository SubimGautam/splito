// class AuthViewModel extends ChangeNotifier {
//   final AuthRepository authRepository;

//   bool isLoading = false;
//   String? errorMessage;

//   AuthViewModel(this.authRepository);

//   Future<void> signup(String username, String password) async {
//     isLoading = true;
//     errorMessage = null;
//     notifyListeners();

//     try {
//       await authRepository.signup(username, password);
//     } catch (e) {
//       errorMessage = e.toString();
//     }

//     isLoading = false;
//     notifyListeners();
//   }

//   Future<void> login(String username, String password) async {
//     isLoading = true;
//     errorMessage = null;
//     notifyListeners();

//     try {
//       await authRepository.login(username, password);
//     } catch (e) {
//       errorMessage = "Invalid username or password";
//     }

//     isLoading = false;
//     notifyListeners();
//   }
// }
