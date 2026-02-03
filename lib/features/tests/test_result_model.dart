class TestResult {
  final String title;
  final String status; // OK | ATENCAO | REPROVADO
  final String description;

  const TestResult({
    required this.title,
    required this.status,
    required this.description,
  });
}
