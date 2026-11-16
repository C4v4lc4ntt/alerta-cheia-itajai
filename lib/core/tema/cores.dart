// =============================================================================
// cores.dart — paleta oficial do app, tirada do mockup.
//
// Centralizar as cores aqui evita "números mágicos" espalhados pelas telas:
// se uma cor mudar, muda em um lugar só.
// Formato Color(0xAARRGGBB): "FF" no começo = 100% opaco, depois o hex do mockup.
// Passo 56 (REFATORAR, visual novo): entram as cores de superfície, borda e
// texto secundário do mockup "sério e confiável", e a paleta do modo escuro,
// que segue o tema do celular. Os estágios não mudam.
// =============================================================================
import 'package:flutter/material.dart';

/// Constantes de cor do Alerta Cheia Itajaí.
///
/// `abstract final class` = classe que não pode ser instanciada nem herdada;
/// serve só para agrupar constantes (como uma classe utilitária com
/// construtor privado no Java).
abstract final class CoresApp {
  // --- Base ---------------------------------------------------------------
  static const Color fundo = Color(0xFFF3F5F4);
  static const Color texto = Color(0xFF0F1E2A);
  static const Color principal = Color(0xFF0A5C73); // azul-petróleo

  // --- Superfícies do visual novo (passo 56) -----------------------------
  // Cartões brancos com borda fina sobre o fundo cinza-esverdeado.
  static const Color superficie = Color(0xFFFFFFFF);
  static const Color superficieVariante = Color(0xFFE8EEEC);
  static const Color borda = Color(0xFFD6DEDB);
  // Texto de apoio: contraste de ~6,9:1 sobre o branco e ~6,3:1 sobre o fundo.
  static const Color textoSecundario = Color(0xFF4A5A66);
  // Fundo do item escolhido (navegação, filtros); texto em CoresApp.principal.
  static const Color principalSuave = Color(0xFFDCEBEF);
  // Texto claro do cabeçalho azul (contraste de ~5,4:1 sobre o principal).
  static const Color cabecalhoSecundario = Color(0xFFCFE3E9);

  // --- Modo escuro (passo 56) --------------------------------------------
  // Fundo azul-noite. Os textos claros passam de 7:1 sobre as superfícies.
  static const Color fundoEscuro = Color(0xFF0E171D);
  static const Color superficieEscura = Color(0xFF15222A);
  static const Color superficieVarianteEscura = Color(0xFF1C2B33);
  static const Color bordaEscura = Color(0xFF2A3B45);
  static const Color textoEscuro = Color(0xFFE6EEF1);
  static const Color textoSecundarioEscuro = Color(0xFFA9B9C2);
  // Azul mais claro para os botões no escuro; o texto deles fica escuro.
  static const Color principalEscuro = Color(0xFF7CC6DA);
  static const Color principalSuaveEscuro = Color(0xFF163541);
  static const Color textoPrincipalSuaveEscuro = Color(0xFF9FD6E5);
  static const Color cabecalhoEscuro = Color(0xFF0F2C37);

  // --- Estágios de alerta (RF01) -----------------------------------------
  // Todas têm contraste suficiente (≥ 4,5:1) com texto BRANCO por cima,
  // nos dois temas.
  // Nomes iguais aos estágios oficiais da Defesa Civil (D01).
  static const Color estagioMonitoramento = Color(0xFF1E6B45);
  static const Color estagioAtencao = Color(0xFF8A5A00);
  static const Color estagioAlerta = Color(0xFFC2410C);
  static const Color estagioEmergencia = Color(0xFF9B1C1C);

  // --- Altura da água nos pontos do mapa (RF03/RF04) ----------------------
  // Atenção (acessibilidade): canela e joelho são claras demais para texto
  // branco — use texto escuro (CoresApp.texto) sobre elas.
  static const Color aguaCanela = Color(0xFFE0A100);
  static const Color aguaJoelho = Color(0xFFD9661F);
  static const Color aguaCintura = Color(0xFF7F1D1D);
}
