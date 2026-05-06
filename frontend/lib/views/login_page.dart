// isabela

// importante:
// view = tela visual do app, ou seja, aquilo que o usuário realmente vê.
//
// esse arquivo representa a tela de login do mesclainvest.
//
// responsabilidade dessa tela:
// - mostrar os campos de e-mail e senha;
// - validar se o usuário preencheu os campos;
// - chamar o authservice para tentar fazer login no firebase;
// - mostrar mensagem de sucesso ou erro;
// - redirecionar o usuário para a tela de startups se o login der certo;
// - permitir ir para cadastro;
// - permitir ir para recuperação de senha.
//
// analogia simples:
// essa tela é tipo a porta de entrada do sistema.
// o usuário digita e-mail e senha,
// a tela confere se está tudo preenchido,
// manda os dados para o "porteiro" authservice,
// e se estiver tudo certo libera a entrada para o catálogo de startups.

import 'package:flutter/material.dart';

// importa o service, que é responsável por falar com o firebase.
//
// essa tela não conversa diretamente com o firebase.
// quem faz isso é o authservice.
//
// por que isso é bom?
// porque separa as responsabilidades:
//
// login_page.dart:
// cuida da tela, botão, campos e mensagens.
//
// auth_service.dart:
// cuida da autenticação e comunicação com firebase.
//
// analogia:
// a tela é o balcão de atendimento.
// o authservice é o funcionário que vai lá no sistema conferir os dados.
import '../services/auth_service.dart';

// telas que vamos navegar.
//
// cadastro_page:
// tela para criar conta.
//
// esqueci_senha_page:
// tela para recuperar senha.
//
// startup_list_page:
// tela que aparece depois que o login dá certo.
import 'cadastro_page.dart';
import 'esqueci_senha_page.dart';
import 'startups/startup_list_page.dart';

// statefulwidget = tela que pode mudar enquanto o app está rodando.
//
// por que essa tela é stateful?
// porque ela tem coisas que mudam:
//
// - texto digitado no e-mail;
// - texto digitado na senha;
// - loading quando está entrando;
// - mensagens de erro;
// - mudança de estado quando o login começa e termina.
//
// se fosse uma tela totalmente parada, sem mudança,
// poderia ser statelesswidget.
//
// analogia:
// statelesswidget é tipo um cartaz colado na parede.
// statefulwidget é tipo uma tela de caixa eletrônico,
// porque muda conforme a pessoa digita e interage.
class LoginPage extends StatefulWidget {
  // construtor da tela.
  //
  // const:
  // indica que, se os dados não mudarem,
  // o flutter pode reutilizar essa tela de forma mais otimizada.
  //
  // super.key:
  // passa a chave para a classe pai.
  // essa key ajuda o flutter a identificar widgets na árvore de widgets.
  //
  // na prática iniciante:
  // pode entender como uma identidade interna do widget.
  const LoginPage({super.key});

  // createState cria o estado dessa tela.
  //
  // o loginpage é a "casca" da tela.
  // o _loginpagestate é onde fica a lógica e os dados que mudam.
  //
  // retorno:
  // retorna um objeto do tipo state<LoginPage>.
  //
  // quem chama?
  // o próprio flutter chama automaticamente quando precisa montar essa tela.
  @override
  State<LoginPage> createState() => _LoginPageState();
}

// state = onde fica a lógica da tela.
//
// essa classe começa com underline:
// _LoginPageState
//
// isso significa que ela é privada dentro deste arquivo.
// ou seja, outros arquivos não acessam diretamente essa classe.
//
// por que deixar privada?
// porque quem deve ser usado de fora é o LoginPage.
// o estado interno é controle da própria tela.
//
// analogia:
// o usuário vê o caixa eletrônico por fora,
// mas não acessa o motor e os fios por dentro.
class _LoginPageState extends State<LoginPage> {
  // formkey = controla e valida o formulário.
  //
  // globalkey<formstate>:
  // é uma chave que permite acessar o estado do formulário.
  //
  // com ela, conseguimos chamar:
  // _formKey.currentState!.validate()
  //
  // isso manda todos os campos do formulário rodarem seus validators.
  //
  // analogia:
  // é tipo o fiscal do formulário.
  // antes de enviar, ele passa em todos os campos e pergunta:
  // "esse campo está certo?"
  final _formKey = GlobalKey<FormState>();

  // controllers = capturam o que o usuário digita.
  //
  // texteditingcontroller:
  // é um objeto que controla o texto de um campo.
  //
  // _emailController:
  // guarda/controla o texto digitado no campo de e-mail.
  //
  // _senhaController:
  // guarda/controla o texto digitado no campo de senha.
  //
  // por que usa final?
  // porque a variável não vai apontar para outro controller depois.
  // o conteúdo do controller muda, mas o controller em si continua sendo o mesmo.
  //
  // analogia:
  // o controller é tipo uma caixinha que guarda o que a pessoa digitou.
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  // service = classe que conversa com firebase.
  //
  // aqui a tela cria um authservice para usar os métodos de autenticação.
  //
  // exemplo:
  // _authService.login(email, senha)
  //
  // isso evita colocar código de firebase direto dentro da tela.
  //
  // analogia:
  // a tela não vai pessoalmente ao firebase.
  // ela pede para o authservice ir lá e resolver.
  final AuthService _authService = AuthService();

  // variável de controle do loading.
  //
  // false:
  // não está carregando.
  //
  // true:
  // está tentando fazer login.
  //
  // essa variável muda a interface:
  // se estiver true, aparece a bolinha de carregamento.
  // se estiver false, aparece o botão entrar.
  //
  // por isso precisa ser statefulwidget.
  bool _carregando = false;

  // libera memória quando sair da tela.
  //
  // dispose é chamado automaticamente pelo flutter
  // quando essa tela/estado deixa de existir.
  //
  // por que precisa dar dispose nos controllers?
  // porque controllers ficam ouvindo e guardando informações.
  // se não liberar, pode gastar memória sem necessidade.
  //
  // analogia:
  // é tipo apagar a luz e fechar a sala quando sai.
  @override
  void dispose() {
    // libera o controller do campo de e-mail.
    _emailController.dispose();

    // libera o controller do campo de senha.
    _senhaController.dispose();

    // chama o dispose da classe pai.
    //
    // isso é importante porque o flutter também tem limpezas internas para fazer.
    super.dispose();
  }

  // mateus
  // criando função private
  // para traduzir os erros.
  //
  // essa função recebe uma string de erro mais técnica
  // e transforma em uma mensagem mais amigável para o usuário.
  //
  // private:
  // o nome começa com underline.
  // então essa função só pode ser usada dentro deste arquivo.
  //
  // parâmetro:
  // erro é uma string com o erro recebido.
  //
  // retorno:
  // retorna uma string com a mensagem traduzida.
  //
  // exemplo:
  // se o firebase devolver "invalid-credential",
  // o usuário vê:
  // "e-mail ou senha incorretos. verifique seus dados."
  //
  // analogia:
  // é tipo um tradutor de linguagem técnica para linguagem humana.
  String _traduzirErro(String erro) {
    // contains verifica se a string contém determinado texto.
    //
    // aqui ele verifica se o erro contém "user-not-found"
    // ou "invalid-credential".
    //
    // user-not-found:
    // usuário não encontrado.
    //
    // invalid-credential:
    // credencial inválida, normalmente e-mail ou senha errado.
    if (erro.contains('user-not-found') ||
        erro.contains('invalid-credential')) {
      return 'E-mail ou senha incorretos. Verifique seus dados.';
    }
    // wrong-password:
    // senha incorreta.
    else if (erro.contains('wrong-password')) {
      return 'Senha incorreta. Tente novamente.';
    }
    // invalid-email:
    // e-mail em formato inválido.
    else if (erro.contains('invalid-email')) {
      return 'O e-mail informado não é válido.';
    }
    // user-disabled:
    // conta desativada no firebase.
    else if (erro.contains('user-disabled')) {
      return 'Esta conta foi desativada. Entre em contato com o suporte.';
    }
    // too-many-requests:
    // muitas tentativas seguidas.
    // o firebase bloqueia temporariamente por segurança.
    else if (erro.contains('too-many-requests')) {
      return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
    }
    // network-request-failed:
    // problema de internet ou conexão.
    else if (erro.contains('network-request-failed')) {
      return 'Sem conexão com a internet. Verifique sua rede.';
    }

    // se não for nenhum erro conhecido,
    // retorna uma mensagem genérica.
    //
    // isso evita mostrar erro técnico feio para o usuário.
    return 'Ocorreu um erro inesperado. Tente novamente.';
  }

  // função principal do login.
  //
  // essa função roda quando o usuário clica no botão "entrar".
  //
  // future<void>:
  // significa que é uma função assíncrona.
  // ela pode demorar, porque depende do firebase/internet.
  //
  // void:
  // significa que ela não retorna nenhum valor final para quem chamou.
  //
  // async:
  // permite usar await dentro da função.
  //
  // await:
  // manda o dart esperar uma operação terminar antes de continuar.
  //
  // quem chama essa função?
  // o botão elevatedbutton chama no onpressed:
  // onPressed: _fazerLogin
  //
  // dependências:
  // - _formKey, para validar o formulário;
  // - _emailController, para pegar o e-mail;
  // - _senhaController, para pegar a senha;
  // - _authService, para fazer login;
  // - scaffoldmessenger, para mostrar mensagens;
  // - navigator, para trocar de tela.
  Future<void> _fazerLogin() async {
    // 1. valida se os campos estão preenchidos corretamente.
    //
    // _formKey.currentState:
    // pega o estado atual do formulário.
    //
    // !:
    // diz para o dart:
    // "confia, isso não está nulo".
    //
    // validate():
    // chama todos os validators dos textformfields.
    //
    // se algum validator retornar texto de erro,
    // validate retorna false.
    //
    // se todos retornarem null,
    // validate retorna true.
    //
    // return:
    // para a função aqui.
    //
    // então:
    // se o formulário estiver inválido,
    // ele nem tenta fazer login.
    if (!_formKey.currentState!.validate()) return;

    // 2. ativa o loading.
    //
    // setState:
    // avisa o flutter que uma variável mudou
    // e que a tela precisa ser redesenhada.
    //
    // aqui _carregando vira true.
    //
    // resultado visual:
    // o botão some e aparece o circularprogressindicator.
    setState(() => _carregando = true);

    try {
      // 3. chama o firebase por meio do authservice.
      //
      // trim():
      // remove espaços no começo e no fim.
      //
      // exemplo:
      // "  email@email.com  "
      // vira:
      // "email@email.com"
      //
      // isso evita erro por espaço sem querer.
      //
      // await:
      // espera o login terminar.
      //
      // se der certo, continua.
      // se der erro, pula para o catch.
      await _authService.login(
        _emailController.text.trim(),
        _senhaController.text.trim(),
      );

      // mounted:
      // verifica se a tela ainda existe.
      //
      // por que isso importa?
      // porque operações com firebase podem demorar.
      // nesse meio tempo, o usuário pode sair da tela.
      //
      // se a tela não existir mais,
      // não pode usar context, snackbar ou navigator.
      //
      // return:
      // para a função se a tela já foi destruída.
      if (!mounted) return;

      // 4. mensagem de sucesso.
      //
      // scaffoldmessenger:
      // serve para mostrar snackbar na tela.
      //
      // snackbar:
      // mensagem temporária que aparece embaixo.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // redirecionamento para o catálogo de startups.
      //
      // mateus - navegação para startuplistpage após login.
      //
      // futuredelayed:
      // espera 2 segundos antes de executar a navegação.
      //
      // por que esperar?
      // para dar tempo do usuário ver a mensagem de sucesso.
      //
      // cuidado:
      // isso é escolha visual.
      // se quiser entrar mais rápido, poderia navegar direto.
      Future.delayed(const Duration(seconds: 2), () {
        // de novo verifica se a tela ainda existe.
        if (!mounted) return;

        // navigator:
        // controla a pilha de telas.
        //
        // pushreplacement:
        // troca a tela atual por outra.
        //
        // diferença entre push e pushreplacement:
        //
        // push:
        // empilha uma nova tela em cima.
        // o usuário pode voltar para a tela anterior.
        //
        // pushreplacement:
        // substitui a tela atual.
        // o usuário não volta para o login pelo botão voltar.
        //
        // aqui faz sentido usar pushreplacement,
        // porque depois de logado o usuário não deveria voltar para a tela de login.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StartupListPage()),
        );
      });

      // mateus substitui o antigo catch.
      // agora chama a função e traduz os erros.
    } catch (e) {
      // se a tela já não existir, para a função.
      if (!mounted) return;

      // transforma o erro técnico em mensagem amigável.
      final mensagem = _traduzirErro(e.toString());

      // mostra a mensagem de erro na tela.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // row:
          // organiza os elementos na horizontal.
          //
          // aqui coloca um ícone de erro e o texto lado a lado.
          content: Row(
            children: [
              // ícone visual de erro.
              const Icon(Icons.error_outline, color: Colors.white),

              // espaço entre o ícone e o texto.
              const SizedBox(width: 8),

              // expanded:
              // faz o texto ocupar o espaço restante.
              //
              // isso evita que textos maiores estourem a tela.
              Expanded(child: Text(mensagem)),
            ],
          ),

          // cor de fundo do snackbar de erro.
          backgroundColor: Colors.red,

          // tempo que a mensagem fica aparecendo.
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      // finally sempre executa.
      //
      // executa se der certo ou se der erro.
      //
      // aqui é usado para desligar o loading.
      //
      // exemplo:
      // deu certo? desliga loading.
      // deu erro? desliga loading também.
      if (!mounted) return;

      // 6. desativa loading.
      //
      // _carregando volta para false.
      //
      // resultado visual:
      // para de mostrar a bolinha
      // e volta a mostrar o botão entrar.
      setState(() => _carregando = false);
    }
  }

  // validação de campo obrigatório.
  //
  // essa função serve para evitar repetir lógica
  // em vários campos diferentes.
  //
  // parâmetros:
  //
  // value:
  // texto digitado no campo.
  //
  // campo:
  // nome do campo para montar a mensagem.
  //
  // retorno:
  // retorna string se tiver erro.
  // retorna null se estiver válido.
  //
  // regra do flutter:
  // no validator:
  // - string significa erro;
  // - null significa que está tudo certo.
  String? _validarObrigatorio(String? value, String campo) {
    // se value for null ou estiver vazio depois de tirar espaços,
    // retorna mensagem de erro.
    if (value == null || value.trim().isEmpty) {
      return 'Informe $campo';
    }

    // se passou pela validação, retorna null.
    return null;
  }

  // validação de senha.
  //
  // essa função verifica:
  // - se a senha foi preenchida;
  // - se tem pelo menos 6 caracteres.
  //
  // retorno:
  // string se tiver erro.
  // null se estiver válida.
  String? _validarSenha(String? value) {
    // verifica se o campo está vazio.
    if (value == null || value.trim().isEmpty) {
      return 'Informe a senha';
    }

    // verifica se a senha tem menos de 6 caracteres.
    //
    // isso combina com a regra comum do firebase auth,
    // que exige senha com pelo menos 6 caracteres.
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }

    // senha ok.
    return null;
  }

  // padrão visual dos inputs.
  //
  // essa função existe para não repetir código em todo textformfield.
  //
  // em vez de escrever a decoração inteira no campo de e-mail
  // e depois repetir tudo no campo de senha,
  // criamos uma função que retorna a decoração pronta.
  //
  // parâmetro:
  // label é o texto que aparece no campo.
  //
  // retorno:
  // retorna um objeto inputdecoration.
  //
  // analogia:
  // é tipo criar um molde de campo.
  // todo campo que usar esse molde fica com o mesmo estilo.
  InputDecoration _decoracao(String label) {
    return InputDecoration(
      // texto que aparece dentro/acima do campo.
      labelText: label,

      // borda do campo.
      //
      // outlineinputborder:
      // cria uma borda ao redor.
      //
      // borderradius.circular(12):
      // deixa os cantos arredondados.
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // build = monta a tela.
  //
  // o flutter chama o build sempre que precisa desenhar ou redesenhar a tela.
  //
  // exemplo:
  // quando setstate muda _carregando,
  // o flutter chama build de novo.
  //
  // retorno:
  // retorna um widget.
  //
  // nesse caso, retorna um scaffold,
  // que é a estrutura base da tela.
  @override
  Widget build(BuildContext context) {
    // scaffold:
    // estrutura padrão de uma tela no material design.
    //
    // pode ter:
    // - appbar;
    // - body;
    // - floatingactionbutton;
    // - drawer;
    // e outros elementos.
    return Scaffold(
      // appbar:
      // barra superior da tela.
      appBar: AppBar(title: const Text('Entrar - MesclaInvest')),

      // body:
      // conteúdo principal da tela.
      body: Center(
        // center:
        // centraliza o conteúdo na tela.
        child: SingleChildScrollView(
          // singlechildscrollview:
          // permite rolar a tela caso o conteúdo não caiba.
          //
          // isso é importante em telas pequenas,
          // ou quando o teclado aparece no celular.
          padding: const EdgeInsets.all(20),

          child: ConstrainedBox(
            // constrainedbox:
            // limita o tamanho máximo do formulário.
            //
            // maxwidth: 400:
            // deixa a tela bonita no computador,
            // porque o formulário não fica gigante esticado.
            constraints: const BoxConstraints(maxWidth: 400),

            child: Form(
              // conecta o formulário com a formkey.
              //
              // assim conseguimos validar tudo usando:
              // _formKey.currentState!.validate()
              key: _formKey,

              child: Column(
                // column:
                // organiza os widgets na vertical.
                //
                // ou seja, um embaixo do outro.
                children: [
                  // ícone visual da tela.
                  //
                  // icons.account_balance:
                  // ícone de banco/instituição financeira,
                  // combinando com a ideia de investimento.
                  const Icon(Icons.account_balance, size: 70),

                  // espaço vertical.
                  const SizedBox(height: 16),

                  // título da tela.
                  const Text(
                    'Bem-vinda ao MesclaInvest',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  // espaço menor.
                  const SizedBox(height: 8),

                  // subtítulo/instrução.
                  const Text(
                    'Entre com seu e-mail e senha',
                    textAlign: TextAlign.center,
                  ),

                  // espaço maior antes dos campos.
                  const SizedBox(height: 30),

                  // campo de e-mail.
                  //
                  // textformfield:
                  // campo de texto que funciona dentro de um form
                  // e aceita validator.
                  TextFormField(
                    // controller:
                    // liga este campo ao _emailController.
                    //
                    // assim conseguimos pegar o texto digitado depois.
                    controller: _emailController,

                    // keyboardtype:
                    // indica que o teclado deve ser adequado para e-mail.
                    //
                    // em celular, normalmente aparece @ com mais facilidade.
                    keyboardType: TextInputType.emailAddress,

                    // decoration:
                    // usa o padrão visual criado na função _decoracao.
                    decoration: _decoracao('E-mail'),

                    // validator:
                    // função que valida o campo.
                    //
                    // aqui usamos uma arrow function:
                    // (v) => _validarObrigatorio(v, 'o e-mail')
                    //
                    // v é o valor digitado.
                    validator: (v) => _validarObrigatorio(v, 'o e-mail'),
                  ),

                  const SizedBox(height: 16),

                  // campo de senha.
                  TextFormField(
                    // controller da senha.
                    controller: _senhaController,

                    // obscuretext:
                    // esconde os caracteres digitados.
                    //
                    // exemplo:
                    // em vez de mostrar "123456",
                    // mostra bolinhas/pontos.
                    obscureText: true,

                    // decoração visual do campo.
                    decoration: _decoracao('Senha'),

                    // validação específica de senha.
                    validator: _validarSenha,
                  ),

                  const SizedBox(height: 24),

                  // botão de login ou loading.
                  //
                  // aqui tem um operador ternário:
                  //
                  // condição ? valor_se_true : valor_se_false
                  //
                  // se _carregando for true:
                  // mostra circularprogressindicator.
                  //
                  // se _carregando for false:
                  // mostra o botão entrar.
                  _carregando
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          // width infinity:
                          // ocupa toda a largura disponível.
                          width: double.infinity,

                          // altura fixa do botão.
                          height: 50,

                          child: ElevatedButton(
                            // quando clicar, chama _fazerLogin.
                            onPressed: _fazerLogin,

                            // texto do botão.
                            child: const Text('ENTRAR'),
                          ),
                        ),

                  const SizedBox(height: 12),

                  // botão "esqueci minha senha".
                  //
                  // textbutton:
                  // botão mais simples, sem fundo forte.
                  TextButton(
                    onPressed: () {
                      // navigator.push:
                      // abre uma nova tela por cima da atual.
                      //
                      // aqui usamos push porque o usuário pode voltar
                      // para a tela de login depois.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EsqueciSenhaPage(),
                        ),
                      );
                    },
                    child: const Text('Esqueci minha senha'),
                  ),

                  // botão ir para cadastro.
                  //
                  // quando o usuário ainda não tem conta,
                  // ele clica aqui para abrir a tela de cadastro.
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CadastroPage(),
                        ),
                      );
                    },
                    child: const Text('Não tem conta? Criar cadastro'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
