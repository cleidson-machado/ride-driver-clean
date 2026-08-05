// Smoke test da Home (POC — dados mockados).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ride_driver_app_1/main.dart';

void main() {
  testWidgets('Home renderiza seções, botão e navegação', (tester) async {
    await tester.pumpWidget(const RideDriverApp());

    // Seções de métricas.
    expect(find.text('MÉDIAS DO ÚLTIMO PASSEIO'), findsOneWidget);
    expect(find.text('MÉDIAS DA SEMANA'), findsOneWidget);

    // Botão primário.
    expect(find.text('ADICIONAR PASSEIO'), findsOneWidget);

    // Navegação inferior.
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Buscar'), findsOneWidget);
    expect(find.text('Histórico'), findsOneWidget);
    expect(find.text('Lixeira'), findsOneWidget);
  });
}
