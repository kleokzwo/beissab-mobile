import 'package:flutter_test/flutter_test.dart';import 'package:beissab_mobile/api/beissab_api.dart';
void main(){test('normalizes legacy week payload',(){final w=normalizeWeek({'data':{'weekDays':[{'name':'Montag'}],'shoppingList':[{'name':'Tomate'}]}});expect((w['days'] as List).length,1);expect((w['shoppingItems'] as List).length,1);});}
