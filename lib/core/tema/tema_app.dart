// =============================================================================
// tema_app.dart — tema visual global (cores, fonte e estilo das barras).
//
// O ThemeData é herdado por todos os widgets: um Text sem estilo próprio
// já sai com a fonte Archivo e a cor de texto do mockup.
// =============================================================================
import 'package:flutter/material.dart';

import 'cores.dart';

/// Fábrica do tema do app.
abstract final class TemaApp {
  /// Tema claro (o único do MVP).
  static ThemeData claro() {
    // ColorScheme.fromSeed gera uma paleta Material 3 inteira a partir de uma
    // cor "semente"; depois sobrescrevemos as cores que o mockup define.
    final esquema = ColorScheme.fromSeed(
      seedColor: CoresApp.principal,
      primary: CoresApp.principal,
      surface: CoresApp.fundo,
      onSurface: CoresApp.texto,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: CoresApp.fundo,
      // Nome da família declarada no pubspec.yaml (seção "fonts").
      // Se a fonte ainda não foi adicionada, o Flutter usa a padrão sem erro.
      fontFamily: 'Archivo',
      appBarTheme: const AppBarTheme(
        backgroundColor: CoresApp.fundo,
        foregroundColor: CoresApp.texto,
        centerTitle: false,
      ),
    );
  }
}
