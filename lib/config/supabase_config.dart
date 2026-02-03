class SupabaseConfig {
  static const String url = 'https://mnxpdzlylkohdgbtybfk.supabase.co';

  // ⚠️ Isso aqui precisa estar entre aspas.
  // OBS: essa "sb_publishable..." não parece ser a anon key do Supabase,
  // mas pelo menos vai compilar. Já já te mostro como pegar a certa.
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1ueHBkemx5bGtvaGRnYnR5YmZrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk1ODM5NDcsImV4cCI6MjA4NTE1OTk0N30.fwpRS5hVEieAGEmjpdRMWwcpvqdWohp6AD8VIEfYk6s';

  static const String tableServiceRequests = 'service_requests';
}
