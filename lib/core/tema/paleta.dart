// =============================================================================
// paleta.dart — as cores de cada tema (claro e escuro) num só lugar
// (passo 56, REFATORAR).
//
// Separado do tema_app.dart para cada arquivo ficar abaixo de ~200 linhas
// (CLAUDE.md, seção 4). O tema_app.dart monta o ThemeData a partir daqui.
// =============================================================================
import 'package:flutter/material.dart';

import 'cores.dart';

/// Cores de um dos temas. Os dois temas usam o mesmo "molde" e mudam só a
/// paleta, como dois objetos da mesma classe de configuração no Java.
class Paleta {
  const Paleta({
    required this.brilho,
    required this.fundo,
    required this.superficie,
    required this.superficieVariante,
    required this.borda,
    required this.texto,
    required this.textoSecundario,
    required this.principal,
    required this.textoNoPrincipal,
    required this.principalSuave,
    required this.textoNoPrincipalSuave,
    required this.cabecalho,
  });

  final Brightness brilho;
  final Color fundo;
  final Color superficie;
  final Color superficieVariante;
  final Color borda;
  final Color texto;
  final Color textoSecundario;
  final Color principal;
  final Color textoNoPrincipal;
  final Color principalSuave;
  final Color textoNoPrincipalSuave;
  final Color cabecalho;
}

/// Paleta do tema claro.
const paletaClara = Paleta(
  brilho: Brightness.light,
  fundo: CoresApp.fundo,
  superficie: CoresApp.superficie,
  superficieVariante: CoresApp.superficieVariante,
  borda: CoresApp.borda,
  texto: CoresApp.texto,
  textoSecundario: CoresApp.textoSecundario,
  principal: CoresApp.principal,
  textoNoPrincipal: Colors.white,
  principalSuave: CoresApp.principalSuave,
  textoNoPrincipalSuave: CoresApp.principal,
  cabecalho: CoresApp.principal,
);

/// Paleta do tema escuro, que segue o modo escuro do celular.
const paletaEscura = Paleta(
  brilho: Brightness.dark,
  fundo: CoresApp.fundoEscuro,
  superficie: CoresApp.superficieEscura,
  superficieVariante: CoresApp.superficieVarianteEscura,
  borda: CoresApp.bordaEscura,
  texto: CoresApp.textoEscuro,
  textoSecundario: CoresApp.textoSecundarioEscuro,
  principal: CoresApp.principalEscuro,
  textoNoPrincipal: CoresApp.fundoEscuro,
  principalSuave: CoresApp.principalSuaveEscuro,
  textoNoPrincipalSuave: CoresApp.textoPrincipalSuaveEscuro,
  cabecalho: CoresApp.cabecalhoEscuro,
);
