// =============================================================================
// cores.dart — paleta oficial do app, tirada do mockup.
//
// Centralizar as cores aqui evita "números mágicos" espalhados pelas telas:
// se uma cor mudar, muda em um lugar só.
// Formato Color(0xAARRGGBB): "FF" no começo = 100% opaco, depois o hex do mockup.
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

  // --- Estágios de alerta (RF01) -----------------------------------------
  // Todas têm contraste suficiente (≥ 4,5:1) com texto BRANCO por cima.
  static const Color estagioNormal = Color(0xFF1E6B45);
  static const Color estagioAtencao = Color(0xFF8A5A00);
  static const Color estagioAlerta = Color(0xFFC2410C);
  static const Color estagioMaximo = Color(0xFF9B1C1C);

  // --- Altura da água nos pontos do mapa (RF03/RF04) ----------------------
  // Atenção (acessibilidade): canela e joelho são claras demais para texto
  // branco — use texto escuro (CoresApp.texto) sobre elas.
  static const Color aguaCanela = Color(0xFFE0A100);
  static const Color aguaJoelho = Color(0xFFD9661F);
  static const Color aguaCintura = Color(0xFF7F1D1D);
}
