// =============================================================================
// consulta_json.dart — converte a ConsultaGuardada em texto JSON e de volta
// (D21).
//
// ETAPA VERDE (passo 57): código mínimo para os testes passarem.
// O shared_preferences só guarda textos e números, por isso a consulta vira
// um texto JSON, como um ObjectMapper do Jackson faria no Java.
// =============================================================================
import 'dart:convert';

import '../../domain/models/boletim_oficial.dart';
import '../../domain/models/consulta_guardada.dart';
import '../../domain/models/leitura_nivel.dart';

/// Texto JSON da [consulta], para guardar no celular.
String consultaParaJson(ConsultaGuardada consulta) {
  final boletim = consulta.boletim;
  return jsonEncode({
    'consultadoEm': consulta.consultadoEm.toIso8601String(),
    'leituras': [
      for (final leitura in consulta.leituras)
        {
          'codigoEstacao': leitura.codigoEstacao,
          'nivel': leitura.nivel,
          'medidoEm': leitura.medidoEm.toIso8601String(),
        },
    ],
    'boletim': boletim == null
        ? null
        : {
            'codigo': boletim.codigo,
            'situacao': boletim.situacao,
            'texto': boletim.texto,
            'atualizadoEm': boletim.atualizadoEm.toIso8601String(),
          },
  });
}

/// A consulta lida de um [texto] JSON; null se o texto estiver corrompido.
///
/// D21: dado ruim no celular não pode derrubar a tela, então qualquer erro
/// de leitura vira "nada guardado".
ConsultaGuardada? consultaDeJson(String texto) {
  try {
    final dados = jsonDecode(texto) as Map<String, dynamic>;
    return ConsultaGuardada(
      consultadoEm: DateTime.parse(dados['consultadoEm'] as String),
      leituras: [
        for (final item in dados['leituras'] as List<dynamic>)
          _leitura(item as Map<String, dynamic>),
      ],
      boletim: _boletim(dados['boletim'] as Map<String, dynamic>?),
    );
  } catch (_) {
    // Inclui FormatException (texto ou data inválida) e TypeError (campo
    // faltando ou de outro tipo).
    return null;
  }
}

LeituraNivel _leitura(Map<String, dynamic> dados) => LeituraNivel(
  codigoEstacao: dados['codigoEstacao'] as String,
  nivel: (dados['nivel'] as num).toDouble(),
  medidoEm: DateTime.parse(dados['medidoEm'] as String),
);

BoletimOficial? _boletim(Map<String, dynamic>? dados) => dados == null
    ? null
    : BoletimOficial(
        codigo: dados['codigo'] as String,
        situacao: dados['situacao'] as String,
        texto: dados['texto'] as String,
        atualizadoEm: DateTime.parse(dados['atualizadoEm'] as String),
      );
