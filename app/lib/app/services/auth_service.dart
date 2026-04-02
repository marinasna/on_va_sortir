import 'package:pocketbase/pocketbase.dart';
import 'package:create_good_app/app/core/db.dart';
class AuthService {
  static Future<void> login(String email, String password) async {
    try {
      await pb.collection('users').authWithPassword(email, password);
    } on ClientException catch (e) {
      throw Exception(e.response['message'] ?? 'Email ou mot de passe incorrect');
    } catch (e) {
      throw Exception('Erreur de connexion');
    }
  }

  static Future<void> register(Map<String, dynamic> data) async {
    try {
      final email = data['email'] as String;
      final password = data['password'] as String;
      final name = data['name'] as String;
      
      final username = email.split('@')[0].replaceAll(RegExp(r'[^a-zA-Z0-9]'), '') + DateTime.now().millisecondsSinceEpoch.toString().substring(9);
      final body = <String, dynamic>{
        "username": username.toLowerCase(),
        "email": email,
        "emailVisibility": true,
        "password": password,
        "passwordConfirm": password,
        "name": name,
        "age": int.tryParse(data['age'] ?? '0') ?? 0,
        "gender": data['gender'] ?? '',
        "location": data['location'] ?? '',
        "phone": data['phone'] ?? '',
        "school": "",
        "events_count": 0,
        "friends_count": 0,
        "groups_count": 0,
        "interests": data['interests'] ?? [],
      };
      
      await pb.collection('users').create(body: body);
      await login(email, password);
    } on ClientException catch (e) {
      String errorMsg = e.response['message'] ?? 'Erreur lors de l\'inscription';
      final data = e.response['data'];
      if (data is Map<String, dynamic> && data.isNotEmpty) {
        final List<String> fieldErrors = [];
        data.forEach((field, errorData) {
          if (errorData is Map<String, dynamic> && errorData['message'] != null) {
            String fName = field;
            if (field == 'password') fName = 'Mot de passe';
            if (field == 'email') fName = 'Email';
            if (field == 'name') fName = 'Nom';
            fieldErrors.add('• $fName : ${errorData['message']}');
          }
        });
        if (fieldErrors.isNotEmpty) {
          errorMsg = 'Attention :\n${fieldErrors.join('\n')}';
        }
      }
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Une erreur inattendue est survenue: $e');
    }
  }

  static void logout() {
    pb.authStore.clear();
  }

  static bool get isAuthenticated => pb.authStore.isValid;
}
