// =============================================================================
// tema_app.dart — tema visual global (cores, fonte e estilo dos componentes).
//
// O ThemeData é herdado por todos os widgets: um Text sem estilo próprio
// já sai com a fonte Archivo e a cor de texto do mockup.
// Passo 56 (REFATORAR, visual novo "sério e confiável"): cabeçalho
// azul-petróleo, cartões com borda, botões com 48 px de altura, filtros e
// barra de navegação com o item escolhido em azul-claro, e um tema escuro com
// as mesmas regras. Só muda a aparência; o comportamento e os testes não.
// =============================================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'cores.dart';
import 'paleta.dart';

/// Fábrica do tema do app.
abstract final class TemaApp {
  // Cantos arredondados usados nos cartões e nos botões.
  static const double _raioCartao = 16;
  static const double _raioBotao = 12;

  // Botões com pelo menos 48 px de altura (CLAUDE.md, seção 7).
  static const Size _tamanhoMinimoBotao = Size(48, 48);

  /// Tema claro.
  static ThemeData claro() => _montar(paletaClara);

  /// Tema escuro, usado quando o celular está no modo escuro.
  static ThemeData escuro() => _montar(paletaEscura);

  // Monta o ThemeData a partir de uma paleta.
  static ThemeData _montar(Paleta p) {
    // ColorScheme.fromSeed gera uma paleta Material 3 inteira a partir de uma
    // cor "semente"; depois sobrescrevemos as cores que o mockup define.
    final esquema = ColorScheme.fromSeed(
      seedColor: CoresApp.principal,
      brightness: p.brilho,
      primary: p.principal,
      onPrimary: p.textoNoPrincipal,
      surface: p.fundo,
      onSurface: p.texto,
      onSurfaceVariant: p.textoSecundario,
      outlineVariant: p.borda,
      surfaceContainerHighest: p.superficieVariante,
      secondaryContainer: p.principalSuave,
      onSecondaryContainer: p.textoNoPrincipalSuave,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: p.fundo,
      // Nome da família declarada no pubspec.yaml (seção "fonts").
      fontFamily: 'Archivo',
    );

    return base.copyWith(
      textTheme: _textos(base.textTheme),
      appBarTheme: _cabecalho(p),
      cardTheme: _cartoes(p),
      filledButtonTheme: FilledButtonThemeData(style: _estiloBotao()),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _estiloBotao().copyWith(
          side: WidgetStatePropertyAll(
            BorderSide(color: p.principal, width: 1.5),
          ),
        ),
      ),
      chipTheme: _filtros(base.chipTheme, p),
      navigationBarTheme: _navegacao(p),
      inputDecorationTheme: _campos(p),
      dividerTheme: DividerThemeData(color: p.borda),
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

  // Cabeçalho azul com texto branco; os ícones da barra de status ficam
  // claros para aparecerem sobre o azul.
  static AppBarTheme _cabecalho(Paleta p) => AppBarTheme(
    backgroundColor: p.cabecalho,
    foregroundColor: Colors.white,
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    titleTextStyle: const TextStyle(
      fontFamily: 'Archivo',
      fontSize: 22,
      fontWeight: FontWeight.w800,
      color: Colors.white,
    ),
  );

  // Cartões sem sombra, com borda fina e cantos de 16 px.
  static CardThemeData _cartoes(Paleta p) => CardThemeData(
    color: p.superficie,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    margin: const EdgeInsets.symmetric(vertical: 6),
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.all(Radius.circular(_raioCartao)),
      side: BorderSide(color: p.borda),
    ),
  );

  // Base comum dos botões: 48 px de altura, cantos de 12 px e texto firme.
  static ButtonStyle _estiloBotao() => const ButtonStyle(
    minimumSize: WidgetStatePropertyAll(_tamanhoMinimoBotao),
    padding: WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    ),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(_raioBotao)),
      ),
    ),
    textStyle: WidgetStatePropertyAll(
      TextStyle(
        fontFamily: 'Archivo',
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  // Filtros (ChoiceChip): pílulas na cor do cartão; a escolhida fica
  // azul-clara.
  static ChipThemeData _filtros(ChipThemeData base, Paleta p) => base.copyWith(
    backgroundColor: p.superficie,
    selectedColor: p.principalSuave,
    side: BorderSide(color: p.borda),
    shape: const StadiumBorder(),
    labelStyle: TextStyle(
      fontFamily: 'Archivo',
      fontWeight: FontWeight.w600,
      color: p.texto,
    ),
    showCheckmark: false,
  );

  // Barra de navegação na cor do cartão; a aba atual ganha a pílula
  // azul-clara.
  static NavigationBarThemeData _navegacao(Paleta p) => NavigationBarThemeData(
    backgroundColor: p.superficie,
    surfaceTintColor: Colors.transparent,
    indicatorColor: p.principalSuave,
    elevation: 0,
    labelTextStyle: WidgetStateProperty.resolveWith(
      (estados) => TextStyle(
        fontFamily: 'Archivo',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: estados.contains(WidgetState.selected)
            ? p.texto
            : p.textoSecundario,
      ),
    ),
    iconTheme: WidgetStateProperty.resolveWith(
      (estados) => IconThemeData(
        color: estados.contains(WidgetState.selected)
            ? p.textoNoPrincipalSuave
            : p.textoSecundario,
      ),
    ),
  );

  // Campos de texto com borda arredondada, como a busca de bairros.
  static InputDecorationTheme _campos(Paleta p) {
    OutlineInputBorder borda(Color cor, double largura) => OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(_raioBotao)),
      borderSide: BorderSide(color: cor, width: largura),
    );
    return InputDecorationTheme(
      filled: true,
      fillColor: p.superficie,
      border: borda(p.borda, 1.5),
      enabledBorder: borda(p.borda, 1.5),
      focusedBorder: borda(p.principal, 2),
    );
  }
}
