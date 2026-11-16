// =============================================================================
// tema_app.dart — tema visual global (cores, fonte e estilo dos componentes).
//
// O ThemeData é herdado por todos os widgets: um Text sem estilo próprio
// já sai com a fonte Archivo e a cor de texto do mockup.
// Passo 56 (REFATORAR, visual novo "sério e confiável"): cabeçalho
// azul-petróleo, cartões brancos com borda, botões com 48 px de altura,
// filtros e barra de navegação com o item escolhido em azul-claro. Só muda a
// aparência; o comportamento das telas e os testes continuam iguais.
// =============================================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'cores.dart';

/// Fábrica do tema do app.
abstract final class TemaApp {
  // Cantos arredondados usados nos cartões e nos botões.
  static const double _raioCartao = 16;
  static const double _raioBotao = 12;

  // Botões com pelo menos 48 px de altura (CLAUDE.md, seção 7).
  static const Size _tamanhoMinimoBotao = Size(48, 48);

  /// Tema claro.
  static ThemeData claro() {
    // ColorScheme.fromSeed gera uma paleta Material 3 inteira a partir de uma
    // cor "semente"; depois sobrescrevemos as cores que o mockup define.
    final esquema = ColorScheme.fromSeed(
      seedColor: CoresApp.principal,
      primary: CoresApp.principal,
      surface: CoresApp.fundo,
      onSurface: CoresApp.texto,
      onSurfaceVariant: CoresApp.textoSecundario,
      outlineVariant: CoresApp.borda,
      secondaryContainer: CoresApp.principalSuave,
      onSecondaryContainer: CoresApp.principal,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: CoresApp.fundo,
      // Nome da família declarada no pubspec.yaml (seção "fonts").
      fontFamily: 'Archivo',
    );

    return base.copyWith(
      textTheme: _textos(base.textTheme),
      appBarTheme: _cabecalho(),
      cardTheme: _cartoes(),
      filledButtonTheme: FilledButtonThemeData(style: _estiloBotao()),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _estiloBotao().copyWith(
          side: const WidgetStatePropertyAll(
            BorderSide(color: CoresApp.principal, width: 1.5),
          ),
        ),
      ),
      chipTheme: _filtros(base.chipTheme),
      navigationBarTheme: _navegacao(),
      inputDecorationTheme: _campos(),
      dividerTheme: const DividerThemeData(color: CoresApp.borda),
      // Sem as linhas que o ExpansionTile desenha ao abrir.
      expansionTileTheme: const ExpansionTileThemeData(
        shape: Border(),
        collapsedShape: Border(),
      ),
    );
  }

  // Títulos mais pesados, para a hierarquia ficar clara à primeira vista.
  static TextTheme _textos(TextTheme base) => base.copyWith(
    displaySmall: base.displaySmall?.copyWith(fontWeight: FontWeight.w800),
    headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
    titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
  );

  // Cabeçalho azul-petróleo com texto branco; os ícones da barra de status
  // ficam claros para aparecerem sobre o azul.
  static AppBarTheme _cabecalho() => const AppBarTheme(
    backgroundColor: CoresApp.principal,
    foregroundColor: Colors.white,
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    titleTextStyle: TextStyle(
      fontFamily: 'Archivo',
      fontSize: 22,
      fontWeight: FontWeight.w800,
      color: Colors.white,
    ),
  );

  // Cartões brancos, sem sombra, com borda fina e cantos de 16 px.
  static CardThemeData _cartoes() => const CardThemeData(
    color: CoresApp.superficie,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    margin: EdgeInsets.symmetric(vertical: 6),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(_raioCartao)),
      side: BorderSide(color: CoresApp.borda),
    ),
  );

  // Base comum dos botões: 48 px de altura, cantos de 12 px e texto firme.
  static ButtonStyle _estiloBotao() => ButtonStyle(
    minimumSize: const WidgetStatePropertyAll(_tamanhoMinimoBotao),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    ),
    shape: const WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(_raioBotao)),
      ),
    ),
    textStyle: const WidgetStatePropertyAll(
      TextStyle(
        fontFamily: 'Archivo',
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  // Filtros (ChoiceChip): pílulas brancas; a escolhida fica azul-clara.
  static ChipThemeData _filtros(ChipThemeData base) => base.copyWith(
    backgroundColor: CoresApp.superficie,
    selectedColor: CoresApp.principalSuave,
    side: const BorderSide(color: CoresApp.borda),
    shape: const StadiumBorder(),
    labelStyle: const TextStyle(
      fontFamily: 'Archivo',
      fontWeight: FontWeight.w600,
      color: CoresApp.texto,
    ),
    showCheckmark: false,
  );

  // Barra de navegação branca; a aba atual ganha a pílula azul-clara.
  static NavigationBarThemeData _navegacao() => NavigationBarThemeData(
    backgroundColor: CoresApp.superficie,
    surfaceTintColor: Colors.transparent,
    indicatorColor: CoresApp.principalSuave,
    elevation: 0,
    labelTextStyle: WidgetStateProperty.resolveWith(
      (estados) => TextStyle(
        fontFamily: 'Archivo',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: estados.contains(WidgetState.selected)
            ? CoresApp.texto
            : CoresApp.textoSecundario,
      ),
    ),
    iconTheme: WidgetStateProperty.resolveWith(
      (estados) => IconThemeData(
        color: estados.contains(WidgetState.selected)
            ? CoresApp.principal
            : CoresApp.textoSecundario,
      ),
    ),
  );

  // Campos de texto brancos com borda arredondada, como a busca de bairros.
  static InputDecorationTheme _campos() => const InputDecorationTheme(
    filled: true,
    fillColor: CoresApp.superficie,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(_raioBotao)),
      borderSide: BorderSide(color: CoresApp.borda, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(_raioBotao)),
      borderSide: BorderSide(color: CoresApp.borda, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(_raioBotao)),
      borderSide: BorderSide(color: CoresApp.principal, width: 2),
    ),
  );
}
