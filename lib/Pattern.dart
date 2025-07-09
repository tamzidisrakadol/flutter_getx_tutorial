/*
// Step 1: Sealed Class for API Response
sealed class ApiResponse<T> {
  const ApiResponse();
}

class Loading<T> extends ApiResponse<T> {
  const Loading();
}

class Success<T> extends ApiResponse<T> {
  final T data;
  final String? message;
  final int statusCode;

  const Success({
    required this.data,
    this.message,
    required this.statusCode,
  });
}

class Failure<T> extends ApiResponse<T> {
  final String message;
  final int? statusCode;
  final dynamic error;

  const Failure({
    required this.message,
    this.statusCode,
    this.error,
  });
}

// Step 2: Generic API Response Handler
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class ApiResponseHandler {
  static Future<ApiResponse<T>> handleApiCall<T>(
      Future<Response> Function() apiCall,
      T Function(dynamic) parser,
      ) async {
    try {
      final response = await apiCall();

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return Success<T>(
          data: parser(response.data),
          message: response.data['message'] ?? 'Success',
          statusCode: response.statusCode!,
        );
      } else {
        return Failure<T>(
          message: response.data['message'] ?? 'Request failed',
          statusCode: response.statusCode,
          error: response.data,
        );
      }
    } on DioException catch (e) {
      return _handleDioException<T>(e);
    } catch (e) {
      return Failure<T>(
        message: 'Unexpected error occurred: ${e.toString()}',
        error: e,
      );
    }
  }

  static Failure<T> _handleDioException<T>(DioException e) {
    String message;
    int? statusCode = e.response?.statusCode;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout';
        break;
      case DioExceptionType.badCertificate:
        message = 'Bad certificate';
        break;
      case DioExceptionType.badResponse:
        message = e.response?.data['message'] ?? 'Bad response from server';
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled';
        break;
      case DioExceptionType.connectionError:
        message = 'Connection error';
        break;
      case DioExceptionType.unknown:
        message = 'Unknown error occurred';
        break;
    }

    return Failure<T>(
      message: message,
      statusCode: statusCode,
      error: e,
    );
  }
}

// Step 3: Dio Setup with Interceptors
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  late Dio _dio;
  final GetStorage _storage = GetStorage();

  Dio get dio => _dio;

  void initialize({
    required String baseUrl,
    int connectTimeout = 30000,
    int receiveTimeout = 30000,
    int sendTimeout = 30000,
  }) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(milliseconds: connectTimeout),
      receiveTimeout: Duration(milliseconds: receiveTimeout),
      sendTimeout: Duration(milliseconds: sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(LoggingInterceptor());
    _dio.interceptors.add(ErrorInterceptor());
  }
}

// Auth Interceptor for Token Management
class AuthInterceptor extends Interceptor {
  final GetStorage _storage = GetStorage();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _storage.read('auth_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Add additional headers
    options.headers['X-App-Version'] = '1.0.0';
    options.headers['X-Platform'] = 'mobile';

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expired, redirect to login
      _storage.remove('auth_token');
      Get.offAllNamed('/login');
    }
    super.onError(err, handler);
  }
}

// Logging Interceptor
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🚀 REQUEST: ${options.method} ${options.uri}');
    print('Headers: ${options.headers}');
    if (options.data != null) {
      print('Data: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    print('Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ ERROR: ${err.message}');
    print('Status Code: ${err.response?.statusCode}');
    super.onError(err, handler);
  }
}

// Error Interceptor
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle global errors
    if (err.response?.statusCode == 500) {
      Get.snackbar('Error', 'Internal Server Error');
    } else if (err.response?.statusCode == 404) {
      Get.snackbar('Error', 'Resource not found');
    }
    super.onError(err, handler);
  }
}

// Step 4: Repository Class
abstract class BaseRepository {
  final DioClient _dioClient = DioClient();
  Dio get dio => _dioClient.dio;
}

// Example User Model
class User {
  final int id;
  final String name;
  final String email;
  final String? avatar;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
    };
  }
}

// User Repository
class UserRepository extends BaseRepository {
  // Get all users
  Future<ApiResponse<List<User>>> getUsers() async {
    return ApiResponseHandler.handleApiCall<List<User>>(
          () => dio.get('/users'),
          (data) => (data['users'] as List)
          .map((user) => User.fromJson(user))
          .toList(),
    );
  }

  // Get user by ID
  Future<ApiResponse<User>> getUserById(int id) async {
    return ApiResponseHandler.handleApiCall<User>(
          () => dio.get('/users/$id'),
          (data) => User.fromJson(data['user']),
    );
  }

  // Create user
  Future<ApiResponse<User>> createUser(User user) async {
    return ApiResponseHandler.handleApiCall<User>(
          () => dio.post('/users', data: user.toJson()),
          (data) => User.fromJson(data['user']),
    );
  }

  // Update user
  Future<ApiResponse<User>> updateUser(int id, User user) async {
    return ApiResponseHandler.handleApiCall<User>(
          () => dio.put('/users/$id', data: user.toJson()),
          (data) => User.fromJson(data['user']),
    );
  }

  // Delete user
  Future<ApiResponse<String>> deleteUser(int id) async {
    return ApiResponseHandler.handleApiCall<String>(
          () => dio.delete('/users/$id'),
          (data) => data['message'] ?? 'User deleted successfully',
    );
  }

  // Login
  Future<ApiResponse<Map<String, dynamic>>> login(String email, String password) async {
    return ApiResponseHandler.handleApiCall<Map<String, dynamic>>(
          () => dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      }),
          (data) => {
        'token': data['token'],
        'user': User.fromJson(data['user']),
      },
    );
  }
}

// Step 5: Controller Class extending GetxController
class UserController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();

  // Observable variables
  final RxList<User> users = <User>[].obs;
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Getters
  List<User> get userList => users.toList();
  User? get user => currentUser.value;
  bool get loading => isLoading.value;
  String get error => errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  // Load all users
  Future<void> loadUsers() async {
    isLoading.value = true;
    errorMessage.value = '';

    final response = await _userRepository.getUsers();

    switch (response) {
      case Loading():
        isLoading.value = true;
        break;
      case Success<List<User>>():
        users.assignAll(response.data);
        isLoading.value = false;
        break;
      case Failure<List<User>>():
        errorMessage.value = response.message;
        isLoading.value = false;
        Get.snackbar('Error', response.message);
        break;
    }
  }

  // Get user by ID
  Future<void> getUserById(int id) async {
    isLoading.value = true;
    errorMessage.value = '';

    final response = await _userRepository.getUserById(id);

    switch (response) {
      case Loading():
        isLoading.value = true;
        break;
      case Success<User>():
        currentUser.value = response.data;
        isLoading.value = false;
        break;
      case Failure<User>():
        errorMessage.value = response.message;
        isLoading.value = false;
        Get.snackbar('Error', response.message);
        break;
    }
  }

  // Create user
  Future<void> createUser(User user) async {
    isLoading.value = true;
    errorMessage.value = '';

    final response = await _userRepository.createUser(user);

    switch (response) {
      case Loading():
        isLoading.value = true;
        break;
      case Success<User>():
        users.add(response.data);
        isLoading.value = false;
        Get.snackbar('Success', 'User created successfully');
        break;
      case Failure<User>():
        errorMessage.value = response.message;
        isLoading.value = false;
        Get.snackbar('Error', response.message);
        break;
    }
  }

  // Update user
  Future<void> updateUser(int id, User user) async {
    isLoading.value = true;
    errorMessage.value = '';

    final response = await _userRepository.updateUser(id, user);

    switch (response) {
      case Loading():
        isLoading.value = true;
        break;
      case Success<User>():
        final index = users.indexWhere((u) => u.id == id);
        if (index != -1) {
          users[index] = response.data;
        }
        isLoading.value = false;
        Get.snackbar('Success', 'User updated successfully');
        break;
      case Failure<User>():
        errorMessage.value = response.message;
        isLoading.value = false;
        Get.snackbar('Error', response.message);
        break;
    }
  }

  // Delete user
  Future<void> deleteUser(int id) async {
    isLoading.value = true;
    errorMessage.value = '';

    final response = await _userRepository.deleteUser(id);

    switch (response) {
      case Loading():
        isLoading.value = true;
        break;
      case Success<String>():
        users.removeWhere((user) => user.id == id);
        isLoading.value = false;
        Get.snackbar('Success', response.data);
        break;
      case Failure<String>():
        errorMessage.value = response.message;
        isLoading.value = false;
        Get.snackbar('Error', response.message);
        break;
    }
  }

  // Login
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    final response = await _userRepository.login(email, password);

    switch (response) {
      case Loading():
        isLoading.value = true;
        break;
      case Success<Map<String, dynamic>>():
        final token = response.data['token'];
        final user = response.data['user'] as User;

        // Store token
        final GetStorage storage = GetStorage();
        await storage.write('auth_token', token);

        currentUser.value = user;
        isLoading.value = false;
        Get.snackbar('Success', 'Login successful');
        Get.offAllNamed('/dashboard');
        break;
      case Failure<Map<String, dynamic>>():
        errorMessage.value = response.message;
        isLoading.value = false;
        Get.snackbar('Error', response.message);
        break;
    }
  }

  // Logout
  Future<void> logout() async {
    final GetStorage storage = GetStorage();
    await storage.remove('auth_token');
    currentUser.value = null;
    users.clear();
    Get.offAllNamed('/login');
  }

  // Refresh data
  Future<void> refresh() async {
    await loadUsers();
  }
}

// Step 6: GetX Bindings for Dependency Injection
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize Dio Client
    DioClient().initialize(
      baseUrl: 'https://api.example.com/v1',
      connectTimeout: 30000,
      receiveTimeout: 30000,
      sendTimeout: 30000,
    );

    // Register repositories
    Get.lazyPut<UserRepository>(() => UserRepository());

    // Register controllers
    Get.lazyPut<UserController>(() => UserController());
  }
}

// Additional bindings for specific features
class UserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserRepository>(() => UserRepository());
    Get.lazyPut<UserController>(() => UserController());
  }
}

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserRepository>(() => UserRepository());
    Get.lazyPut<UserController>(() => UserController());
  }
}

// Main App Setup
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Industrial App',
      initialBinding: AppBinding(),
      initialRoute: '/splash',
      getPages: [
        GetPage(
          name: '/splash',
          page: () => SplashScreen(),
          binding: AppBinding(),
        ),
        GetPage(
          name: '/login',
          page: () => LoginScreen(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: '/dashboard',
          page: () => DashboardScreen(),
          binding: UserBinding(),
        ),
        GetPage(
          name: '/users',
          page: () => UsersScreen(),
          binding: UserBinding(),
        ),
      ],
    );
  }
}

// Usage Example in a Widget
class ExampleUsage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: Text('Users')),
          body: controller.loading
              ? Center(child: CircularProgressIndicator())
              : controller.error.isNotEmpty
              ? Center(child: Text('Error: ${controller.error}'))
              : ListView.builder(
            itemCount: controller.userList.length,
            itemBuilder: (context, index) {
              final user = controller.userList[index];
              return ListTile(
                title: Text(user.name),
                subtitle: Text(user.email),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => controller.deleteUser(user.id),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => controller.refresh(),
            child: Icon(Icons.refresh),
          ),
        );
      },
    );
  }
}*/
