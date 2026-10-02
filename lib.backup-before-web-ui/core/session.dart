import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart'; import '../api/beissab_api.dart';
class Session extends ChangeNotifier {
 bool loading=true; Map<String,dynamic>? user;
 bool get signedIn=>user!=null;
 Future<void> bootstrap() async { loading=true; notifyListeners(); if(await api.token()!=null){try{user=await userApi.me();}catch(_){user=null;}} loading=false; notifyListeners(); }
 Future<void> acceptToken(String token) async {await api.setToken(token); user=await userApi.me(); notifyListeners();}
 Future<void> logout() async {await api.clearToken(); user=null; notifyListeners();}
 Future<bool> onboardingDone() async {if(user==null)return false; final id=user!['id']??user!['userId']??user!['email']; final server=user!['onboardingCompleted']??user!['onboarded']; if(server==true||server==1||server=='1')return true; final p=await SharedPreferences.getInstance(); return p.getBool('mealplan_onboarding_completed:$id')??false;}
 Future<void> markOnboarding() async {if(user==null)return; final id=user!['id']??user!['userId']??user!['email']; final p=await SharedPreferences.getInstance(); await p.setBool('mealplan_onboarding_completed:$id',true); user={...user!,'onboardingCompleted':true}; notifyListeners();}
}
final session=Session();
