import 'package:byls_app/services/supabase_service.dart';
import 'package:byls_app/src/pages/home.dart';
import 'package:byls_app/src/pages/sigIn.dart';
import 'package:byls_app/src/pages/signUp.dart';
import 'package:byls_app/src/pages/resetPassword.dart';
import 'package:byls_app/src/pages/transaccion.dart';
import 'package:flutter/material.dart';

Map<String, WidgetBuilder> customRoutes(SupabaseService supabaseService) {
  return {
    "SignIn": (context) => SignIn(supabaseService: supabaseService),
    "Home": (context) => Home(supabaseService: supabaseService),
    "Transaccion": (context) => Transaccion(supabaseService:supabaseService),
    "SignUp": (context) => SignUp(supabaseService: supabaseService),
    "ResetPass": (context) => ResetPass(supabaseService: supabaseService),
    // Agrega más rutas aquí según sea necesario
  };
}
