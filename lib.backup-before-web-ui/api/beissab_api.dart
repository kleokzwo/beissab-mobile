import 'api_client.dart';
String _q(Map<String,dynamic> p)=>Uri(queryParameters:p.map((k,v)=>MapEntry(k,'$v'))).query;
List<dynamic> _arr(dynamic v)=>v is List?v:<dynamic>[];
Map<String,dynamic> _map(dynamic v)=>v is Map<String,dynamic>?v:Map<String,dynamic>.from(v is Map?v:{});

class AuthApi {
 Future<dynamic> register(String email,String password)=>api.post('/auth/register',{'email':email,'password':password});
 Future<dynamic> login(String email,String password)=>api.post('/auth/login',{'email':email,'password':password});
 Future<dynamic> verify(String email,String code)=>api.post('/auth/verify-email',{'email':email,'code':code});
 Future<dynamic> resend(String email)=>api.post('/auth/resend-code',{'email':email});
 Future<dynamic> forgot(String email)=>api.post('/users/forgot-password',{'email':email});
 Future<dynamic> reset(String token,String password)=>api.post('/users/reset-password',{'token':token,'newPassword':password});
}
class UserApi {
 Future<Map<String,dynamic>> me() async { final r=await api.get('/users/me'); return _map(r is Map&&r['user']!=null?r['user']:r); }
 Future<dynamic> onboarding(Map<String,dynamic> p)=>api.patch('/users/me/onboarding',p);
 Future<dynamic> household(Map<String,dynamic> p)=>api.patch('/users/me/household',p);
 Future<dynamic> notification(String v)=>api.patch('/users/me/settings',{'notificationPreference':v});
}
class MealApi {
 Future<List<dynamic>> suggestions({required String householdType,required String dietType,required int maxCookingTime,required int refreshKey,List<dynamic> excludeIds=const[]}) async { final p={'householdType':householdType,'dietType':dietType,'maxCookingTime':maxCookingTime,'refreshKey':refreshKey,if(excludeIds.isNotEmpty)'excludeIds':excludeIds.join(',')}; final r=await api.get('/meals/suggestions?${_q(p)}'); if(r is List)return r; if(r is Map){return _arr(r['data']??r['meals']??r['suggestions']);} return []; }
 Future<List<dynamic>> steps(dynamic id) async {final r=await api.get('/meals/$id/steps'); return _arr(r is Map?(r['data']??r['steps']):r);}
 Future<List<dynamic>> ingredients(dynamic id) async {final r=await api.get('/meals/$id/ingredients'); return _arr(r is Map?(r['data']??r['ingredients']):r);}
 Future<dynamic> status(dynamic id,String status)=>api.patch('/meal-suggestions/$id/status',{'status':status});
}
Map<String,dynamic> normalizeWeek(dynamic response){ final raw=_map(response is Map&&response['data']!=null?response['data']:response); final days=_arr(raw['days']??raw['weekDays']??raw['week_days']??raw['weeklyPlan']??raw['plan']??raw['entries']??raw['items']); final shopping=_arr(raw['shoppingItems']??raw['shoppingList']??raw['shopping_items']); return {...raw,'days':days,'shoppingItems':shopping}; }
class WeekApi {
 Future<Map<String,dynamic>> active() async=>normalizeWeek(await api.get('/weeks/active'));
 Future<Map<String,dynamic>> create(List<dynamic> ids) async=>normalizeWeek(await api.post('/weeks',{'selectedMealIds':ids}));
 Future<void> remove()=>api.delete('/weeks/active');
 Future<dynamic> check(dynamic id,bool checked)=>api.patch('/weeks/active/shopping-items/$id',{'isChecked':checked});
 Future<dynamic> edit(dynamic id,String name,dynamic quantity,String category)=>api.put('/weeks/active/shopping-items/$id',{'name':name,'quantity':quantity,'category':category});
 Future<dynamic> deleteItem(dynamic id)=>api.delete('/weeks/active/shopping-items/$id');
}
final authApi=AuthApi(), userApi=UserApi(), mealApi=MealApi(), weekApi=WeekApi();
