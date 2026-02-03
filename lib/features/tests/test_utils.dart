import 'test_result_model.dart';

class TestUtils {
  static TestResult avaliarDR({
    required bool disparou,
    required double tempoMs,
  }) {
    if (!disparou) {
      return const TestResult(
        title: 'Teste do DR',
        status: 'REPROVADO',
        description:
            'O DR não disparou durante o teste. Risco grave de choque elétrico.',
      );
    }

    if (tempoMs <= 300) {
      return const TestResult(
        title: 'Teste do DR',
        status: 'OK',
        description:
            'DR disparou corretamente em tempo adequado conforme NBR 5410.',
      );
    }

    return const TestResult(
      title: 'Teste do DR',
      status: 'ATENCAO',
      description:
          'DR disparou, porém com tempo acima do recomendado. Verificar o dispositivo.',
    );
  }
}
