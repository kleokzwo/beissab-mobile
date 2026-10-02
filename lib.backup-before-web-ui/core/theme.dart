import 'package:flutter/material.dart';
class BeissAbTheme {
 static ThemeData get light => ThemeData(
   useMaterial3: true,
   colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF111827), brightness: Brightness.light),
   scaffoldBackgroundColor: const Color(0xFFF8FAFC),
   inputDecorationTheme: const InputDecorationTheme(filled:true, fillColor:Colors.white, border:OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(18)))),
   cardTheme: const CardThemeData(elevation:0, color:Colors.white, margin:EdgeInsets.zero, shape:RoundedRectangleBorder(borderRadius:BorderRadius.all(Radius.circular(24)))),
 );
}
