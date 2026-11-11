// =============================================================================
// app.dart — widget raiz e navegação inferior com as 4 abas do mockup:
// Início, Mapa, Ajuda e Ajustes.
//
// Em Flutter "tudo é widget": telas, botões, espaçamentos e até o tema.
// Um widget é parecido com um componente de interface que sabe se desenhar.
// =============================================================================
import 'package:flutter/material.dart';

import 'core/tema/tema_app.dart';
import 'ui/ajuda/ajuda_view.dart';
import 'ui/ajustes/ajustes_view.dart';
import 'ui/ajustes/ajustes_view_model.dart';
import 'ui/inicio/inicio_view.dart';
import 'ui/inicio/inicio_view_model.dart';
import 'ui/mapa/mapa_view.dart';
import 'ui/marcar_ponto/marcar_ponto_view_model.dart';

/// Widget raiz do aplicativo.
///
/// É "Stateless" (sem estado): só monta o MaterialApp com o tema e a tela
/// inicial. Quem guarda estado (qual aba está aberta) é [NavegacaoPrincipal].
class AlertaCheiaApp extends StatelessWidget {
  /// Cria o app com os ViewModels já montados (ver main.dart).
  const AlertaCheiaApp({
    super.key,
    required this.inicioViewModel,
    required this.ajustesViewModel,
    this.criarMarcarPonto,
  });

  /// ViewModel entregue à tela Início.
  final InicioViewModel inicioViewModel;

  /// ViewModel entregue à tela Ajustes.
  final AjustesViewModel ajustesViewModel;

  /// Repassado à aba Mapa (RF03, ciclo 23). É null quando o Firebase não
  /// ligou: o botão "Marcar rua alagada" aparece desativado.
  final MarcarPontoViewModel Function()? criarMarcarPonto;

  @override
  Widget build(BuildContext context) {
    // MaterialApp configura tema, título e a primeira tela exibida.
    return MaterialApp(
      title: 'Alerta Cheia Itajaí',
      debugShowCheckedModeBanner: false, // esconde a faixa "DEBUG" no canto
      theme: TemaApp.claro(),
      home: NavegacaoPrincipal(
        inicioViewModel: inicioViewModel,
        ajustesViewModel: ajustesViewModel,
        criarMarcarPonto: criarMarcarPonto,
      ),
    );
  }
}

/// Estrutura com a barra de navegação inferior.
///
/// É "Stateful" (com estado) porque precisa lembrar qual aba está
/// selecionada e se redesenhar quando o usuário toca em outra.
class NavegacaoPrincipal extends StatefulWidget {
  /// Cria a navegação com os ViewModels das telas.
  const NavegacaoPrincipal({
    super.key,
    required this.inicioViewModel,
    required this.ajustesViewModel,
    this.criarMarcarPonto,
  });

  /// ViewModel entregue à tela Início.
  final InicioViewModel inicioViewModel;

  /// ViewModel entregue à tela Ajustes.
  final AjustesViewModel ajustesViewModel;

  /// Repassado à aba Mapa; null quando o Firebase não ligou.
  final MarcarPontoViewModel Function()? criarMarcarPonto;

  @override
  State<NavegacaoPrincipal> createState() => _NavegacaoPrincipalState();
}

class _NavegacaoPrincipalState extends State<NavegacaoPrincipal> {
  // Índice da aba aberta: 0 = Início, 1 = Mapa, 2 = Ajuda, 3 = Ajustes.
  // O "_" no começo do nome deixa o campo privado ao arquivo (como "private").
  int _abaAtual = 0;

  @override
  Widget build(BuildContext context) {
    // Lista das telas, na mesma ordem dos botões da barra inferior.
    // Deixou de ser "const" no ciclo 7: a tela Início recebe o ViewModel.
    final telas = <Widget>[
      InicioView(
        viewModel: widget.inicioViewModel,
        // D15: o convite leva à aba Ajustes, onde o bairro é escolhido.
        aoEscolherBairro: () => setState(() => _abaAtual = 3),
      ),
      // Ciclo 23: a aba Mapa recebe como criar a tela de marcar (RF03).
      MapaView(criarMarcarPonto: widget.criarMarcarPonto),
      const AjudaView(),
      AjustesView(viewModel: widget.ajustesViewModel),
    ];

    return Scaffold(
      // Mostra só a tela da aba selecionada.
      // (Se no futuro o mapa precisar manter o zoom ao trocar de aba,
      // trocamos por um IndexedStack, que mantém todas as telas vivas.)
      body: telas[_abaAtual],

      // Barra inferior no padrão Material 3.
      bottomNavigationBar: NavigationBar(
        selectedIndex: _abaAtual,
        // setState avisa o Flutter que o estado mudou e a tela deve ser
        // redesenhada com a nova aba.
        onDestinationSelected: (indice) => setState(() => _abaAtual = indice),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.help_outline),
            selectedIcon: Icon(Icons.help),
            label: 'Ajuda',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
