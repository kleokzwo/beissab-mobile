import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../core/config.dart';

class ApiException implements Exception { final String message; final int? status; final dynamic data; ApiException(this.message,{this.status,this.data}); @override String toString()=>message; }
class ApiClient {
  ApiClient({http.Client? client}): _client=client??http.Client();
  final http.Client _client; final _storage=const FlutterSecureStorage();
  Future<String?> token()=>_storage.read(key:'token');
  Future<void> setToken(String value)=>_storage.write(key:'token',value:value);
  Future<void> clearToken()=>_storage.delete(key:'token');
  Uri _uri(String path)=>Uri.parse('${AppConfig.apiBaseUrl}${path.startsWith('/')?path:'/$path'}');
  Future<dynamic> request(String method,String path,{Object? body,Map<String,String>? headers}) async {
    final t=await token(); final h={'Content-Type':'application/json',if(t!=null)'Authorization':'Bearer $t',...?headers};
    final req=http.Request(method,_uri(path)); req.headers.addAll(h); if(body!=null) req.body=jsonEncode(body);
    final streamed=await _client.send(req); final response=await http.Response.fromStream(streamed);
    dynamic data; try { data=response.body.isEmpty?null:jsonDecode(response.body); } catch(_){ data=response.body; }
    if(response.statusCode<200||response.statusCode>=300){ if(response.statusCode==401) await clearToken(); final msg=data is Map?(data['message']??data['error']??'API Anfrage fehlgeschlagen.').toString():'API Anfrage fehlgeschlagen.'; throw ApiException(msg,status:response.statusCode,data:data); }
    return data;
  }
  Future<dynamic> get(String p)=>request('GET',p); Future<dynamic> post(String p,[Object? b])=>request('POST',p,body:b); Future<dynamic> put(String p,[Object? b])=>request('PUT',p,body:b); Future<dynamic> patch(String p,[Object? b])=>request('PATCH',p,body:b); Future<dynamic> delete(String p)=>request('DELETE',p);
}
final api=ApiClient();
