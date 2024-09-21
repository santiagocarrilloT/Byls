// ignore: depend_on_referenced_packages
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client;

  SupabaseService._internal(this.client);

  static final SupabaseService _instance = SupabaseService._internal(SupabaseClient(
      'https://vjfdvqliwmkhlkigitnt.supabase.co/',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZqZmR2cWxpd21raGxraWdpdG50Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU5MDQyMTMsImV4cCI6MjA0MTQ4MDIxM30._Q3oHnqPGwFElb9N-VL2KgW0_-V6LNjy1uygEQDIRrI'));
  factory SupabaseService() {
    return _instance;
  }
}
