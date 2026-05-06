// isabela

// view = tela visual para recuperação de senha
//
// esse arquivo representa a tela de "esqueci minha senha".
//
// responsabilidade dessa tela:
// - mostrar um campo para o usuário digitar o e-mail;
// - validar se o campo não está vazio;
// - chamar o authservice para pedir ao firebase o envio do e-mail de recuperação;
// - mostrar mensagem de sucesso ou erro;
// - voltar para a tela de login depois que o e-mail for enviado.
//
// importante:
// essa tela não cria senha nova diretamente.
// ela apenas pede para o firebase enviar um link de recuperação para o e-mail.
//
// analogia:
// é tipo falar para o sistema:
// "manda um link para o e-mail dessa pessoa, porque ela esqueceu a senha".
// quem realmente envia e controla esse processo é o firebase auth.

import 'package:flutter/material.dart';

// importa o authservice.
//
// o authservice é a classe responsável por conversar com o firebase.
// essa tela não fala diretamente com o firebase.
// ela chama o método recuperarsenha dentro do authservice.
//
// isso deixa o código mais organizado:
// - tela cuida da interface;
// - service cuida da regra/comunicação com firebase.
import '../services/auth_service.dart';

// statefulwidget = tela que muda de estado
//
// essa tela precisa ser stateful porque ela tem uma variável que muda:
//
// _carregando
//
// quando _carregando é false:
// aparece o botão "enviar".
//
// quando _carregando é true:
// aparece a bolinha de carregamento.
//
// então a tela muda enquanto o app está rodando.
class EsqueciSenhaPage extends StatefulWidget {
  // construtor da tela.
  //
  // const:
  // ajuda o flutter a otimizar quando esse widget não muda.
  //
  // super.key:
  // passa a key para a classe pai.
  // a key ajuda o flutter a identificar widgets na árvore de widgets.
  const EsqueciSenhaPage({super.key});

  // createstate cria o estado dessa tela.
  //
  // a classe esquecisenhapage é a parte "fixa" da tela.
  // a classe _esquecisenhapagestate é onde ficam os dados e a lógica que mudam.
  //
  // quem chama esse método?
  // o próprio flutter chama automaticamente quando precisa montar a tela.
  @override
  State<EsqueciSenhaPage> createState() => _EsqueciSenhaPageState();
}

// state = lógica da tela
//
// essa classe começa com underline.
// em dart, isso significa que ela é privada dentro deste arquivo.
//
// ou seja:
// outros arquivos usam esquecisenhapage,
// mas não mexem diretamente em _esquecisenhapagestate.
//
// analogia:
// a page é a parte que a pessoa vê.
// o state é a parte interna, tipo os fios e mecanismos por trás.
class _EsqueciSenhaPageState extends State<EsqueciSenhaPage> {
  // controller = pega o que o usuário digita
  //
  // texteditingcontroller controla o texto de um campo.
  //
  // aqui ele controla o campo de e-mail.
  //
  // quando o usuário digita no textfield,
  // conseguimos pegar o texto usando:
  //
  // _emailController.text
  //
  // final:
  // significa que essa variável não vai trocar de controller depois.
  // o conteúdo digitado pode mudar, mas o objeto controller continua o mesmo.
  final _emailController = TextEditingController();

  // service = conversa com firebase
  //
  // cria um objeto authservice para usar os métodos de autenticação.
  //
  // nesse arquivo, usamos principalmente:
  //
  // _authService.recuperarSenha(email)
  //
  // essa tela pede.
  // o authservice executa.
  // o firebase envia o e-mail.
  final AuthService _authService = AuthService();

  // variável que controla o loading.
  //
  // false:
  // não está carregando, então mostra o botão.
  //
  // true:
  // está enviando o e-mail, então mostra a bolinha de carregamento.
  //
  // isso evita que o usuário clique várias vezes no botão enquanto a requisição roda.
  bool _carregando = false;

  @override
  void dispose() {
    // libera memória quando sair da tela
    //
    // quando a tela sai da árvore de widgets,
    // o flutter chama dispose automaticamente.
    //
    // o controller precisa ser descartado porque ele ocupa recurso de memória.
    //
    // analogia:
    // saiu da sala, apaga a luz e fecha a porta.
    _emailController.dispose();

    // chama o dispose da classe pai.
    // isso é importante para o flutter fazer as limpezas internas dele também.
    super.dispose();
  }

  // método principal
  //
  // esse método roda quando o usuário clica no botão "enviar".
  //
  // future<void>:
  // significa que é uma função assíncrona.
  // ela pode demorar porque depende de internet/firebase.
  //
  // void:
  // significa que ela não retorna um valor final para quem chamou.
  //
  // async:
  // permite usar await dentro da função.
  //
  // quem chama esse método?
  // o botão elevatedbutton chama aqui:
  //
  // onPressed: _enviarEmail
  //
  // dependências desse método:
  // - _emailController, para pegar o e-mail digitado;
  // - _authService, para pedir ao firebase o e-mail de recuperação;
  // - scaffoldmessenger, para mostrar mensagem na tela;
  // - navigator, para voltar para a tela anterior;
  // - mounted, para conferir se a tela ainda existe;
  // - setstate, para ligar e desligar o loading.
  Future<void> _enviarEmail() async {
    // validação simples
    //
    // aqui ele verifica se o campo está vazio.
    //
    // _emailController.text:
    // pega o texto digitado.
    //
    // trim():
    // remove espaços do começo e do fim.
    //
    // exemplo:
    // "   "
    // vira:
    // ""
    //
    // isso evita o usuário enviar só espaços.
    if (_emailController.text.trim().isEmpty) {
      // scaffoldmessenger:
      // mostra uma snackbar na tela.
      //
      // snackbar:
      // mensagem temporária, geralmente aparece embaixo.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o e-mail'),
          backgroundColor: Colors.red,
        ),
      );

      // return:
      // para a função aqui.
      //
      // se o e-mail estiver vazio,
      // ele não continua para o firebase.
      return;
    }

    // liga o loading.
    //
    // setstate avisa o flutter que uma variável mudou
    // e que a tela precisa ser redesenhada.
    //
    // aqui _carregando vira true.
    //
    // resultado visual:
    // o botão "enviar" some e aparece a bolinha de carregamento.
    setState(() => _carregando = true);

    try {
      // chama o firebase para enviar o email de recuperação
      //
      // aqui a tela chama o authservice.
      //
      // o método recuperarsenha provavelmente usa:
      // firebaseauth.instance.sendpasswordresetemail(...)
      //
      // await:
      // espera o firebase responder.
      //
      // se der certo, continua.
      // se der erro, pula para o catch.
      await _authService.recuperarSenha(_emailController.text.trim());

      // mounted:
      // verifica se essa tela ainda existe.
      //
      // por que precisa disso?
      // porque a chamada ao firebase pode demorar.
      // nesse tempo, o usuário pode sair da tela.
      //
      // se a tela já tiver sido fechada,
      // não pode usar context, snackbar ou navigator.
      if (!mounted) return;

      // mensagem de sucesso
      //
      // mostra para o usuário que o e-mail foi enviado.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email de recuperação enviado!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // volta para a tela anterior (login) depois de 2 segundos
      //
      // futuredelayed:
      // espera um tempo antes de executar uma ação.
      //
      // aqui ele espera 2 segundos para dar tempo do usuário ler a mensagem.
      Future.delayed(const Duration(seconds: 2), () {
        // confere de novo se a tela ainda existe.
        if (!mounted) return;

        // navigator.pop:
        // fecha a tela atual e volta para a tela anterior.
        //
        // nesse caso:
        // a tela anterior normalmente é o login.
        //
        // diferença para push:
        // push abre uma tela nova.
        // pop fecha a tela atual.
        Navigator.pop(context);
      });
    } catch (e) {
      // se der erro, cai aqui.
      //
      // exemplo de erro:
      // - e-mail inválido;
      // - problema de internet;
      // - firebase fora;
      // - usuário não encontrado, dependendo da configuração do firebase.
      if (!mounted) return;

      // mensagem de erro
      //
      // aqui mostra o erro direto.
      //
      // observação:
      // para ficar mais bonito, daria para criar uma função de tradução
      // igual foi feito na tela de login.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    } finally {
      // finally sempre executa.
      //
      // executa tanto se deu certo quanto se deu erro.
      //
      // aqui serve para desligar o loading.
      if (!mounted) return;

      // desliga o loading.
      //
      // _carregando vira false.
      //
      // resultado visual:
      // a bolinha some e o botão "enviar" volta.
      setState(() => _carregando = false);
    }
  }

  // padrão visual do campo
  //
  // essa função cria a decoração do campo de texto.
  //
  // por que fazer uma função?
  // para não repetir código visual.
  //
  // parâmetro:
  // label é o texto que aparece no campo.
  //
  // retorno:
  // retorna um inputdecoration.
  //
  // analogia:
  // é tipo um molde de estilo para campos.
  InputDecoration _decoracao(String label) {
    return InputDecoration(
      // texto do campo.
      labelText: label,

      // borda ao redor do campo com canto arredondado.
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  // build monta a tela.
  //
  // sempre que o flutter precisa desenhar ou redesenhar essa tela,
  // ele chama o build.
  //
  // isso pode acontecer:
  // - quando a tela abre;
  // - quando setstate é chamado;
  // - quando alguma parte da interface precisa atualizar.
  //
  // retorno:
  // retorna um widget.
  Widget build(BuildContext context) {
    // scaffold:
    // estrutura base de uma tela no flutter com material design.
    //
    // aqui ele tem:
    // - appbar;
    // - body.
    return Scaffold(
      // appbar:
      // barra superior da tela.
      appBar: AppBar(title: const Text('Recuperar Senha')),

      // body:
      // conteúdo principal da tela.
      body: Padding(
        // padding:
        // espaço interno nas bordas da tela.
        //
        // edgeinsets.all(20):
        // coloca 20 pixels de espaço em todos os lados.
        padding: const EdgeInsets.all(20),

        child: Column(
          // column:
          // organiza os widgets na vertical,
          // um embaixo do outro.
          children: [
            // texto explicando o que o usuário deve fazer.
            const Text(
              'Digite seu e-mail para receber o link de recuperação',
              textAlign: TextAlign.center,
            ),

            // espaço vertical entre o texto e o campo.
            const SizedBox(height: 20),

            // campo onde o usuário digita o e-mail.
            //
            // textfield:
            // campo simples de texto.
            //
            // observação:
            // aqui foi usado textfield, não textformfield.
            // por isso a validação foi feita manualmente dentro de _enviarEmail().
            TextField(
              // liga o campo ao controller.
              controller: _emailController,

              // teclado apropriado para e-mail.
              //
              // em celular, isso ajuda a mostrar @ e opções melhores.
              keyboardType: TextInputType.emailAddress,

              // usa a função de decoração visual.
              decoration: _decoracao('E-mail'),
            ),

            const SizedBox(height: 20),

            // se estiver carregando, mostra a bolinha.
            //
            // se não estiver carregando, mostra o botão enviar.
            //
            // isso é um operador ternário:
            //
            // condição ? coisa_se_verdadeiro : coisa_se_falso
            _carregando
                ? const CircularProgressIndicator()
                : SizedBox(
                    // botão ocupa toda a largura disponível.
                    width: double.infinity,

                    // altura fixa do botão.
                    height: 50,

                    child: ElevatedButton(
                      // ao clicar, chama o método principal.
                      onPressed: _enviarEmail,

                      // texto dentro do botão.
                      child: const Text('ENVIAR'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
