// isabela

// view = tela visual do app
//
// esse arquivo representa a tela de cadastro do usuário.
//
// responsabilidade dessa tela:
// - mostrar os campos de cadastro;
// - pegar nome, e-mail, cpf, telefone, senha e tipo do usuário;
// - validar se os campos obrigatórios foram preenchidos;
// - criar um objeto usuario com esses dados;
// - chamar o authservice para cadastrar no firebase;
// - mostrar mensagem de sucesso ou erro;
// - voltar para a tela de login depois do cadastro.
//
// importante:
// essa tela não salva diretamente no firebase.
// ela só coleta os dados e manda para o authservice.
// quem conversa com firebase auth/firestore é o service.
//
// analogia:
// essa tela é tipo uma ficha de cadastro.
// o usuário preenche a ficha,
// a tela organiza os dados,
// cria um objeto usuario,
// e entrega para o authservice cadastrar no sistema.

import 'package:flutter/material.dart';

// importa o model usuario.
//
// usuario_model.dart é o arquivo que define o molde do usuário.
//
// esse molde diz quais informações um usuário tem:
// nome, email, senha, cpf, telefone, tipo etc.
//
// analogia:
// o model é tipo a ficha em branco.
// aqui na tela a gente preenche essa ficha com os dados digitados.
import '../models/usuario_model.dart';

// importa o authservice.
//
// o authservice é a classe responsável por conversar com o firebase.
//
// essa tela não deve ter código direto de firebase,
// porque a responsabilidade dela é cuidar da interface.
//
// separação boa:
// cadastro_page.dart = tela
// usuario_model.dart = molde dos dados
// auth_service.dart = comunicação com firebase
import '../services/auth_service.dart';

// statefulwidget = tela que muda de estado
// ex: loading, erro, texto digitado
//
// essa tela precisa ser stateful porque algumas coisas mudam:
//
// - o usuário digita texto nos campos;
// - o botão pode virar loading;
// - o tipo selecionado pode mudar entre investidor e empreendedor;
// - a tela precisa atualizar quando setstate é chamado.
//
// se fosse uma tela parada, poderia ser statelesswidget.
// mas como ela tem estado interno, usamos statefulwidget.
class CadastroPage extends StatefulWidget {
  // construtor da tela.
  //
  // const:
  // ajuda o flutter a otimizar esse widget quando ele não muda.
  //
  // super.key:
  // manda a key para a classe pai.
  // a key ajuda o flutter a identificar widgets dentro da árvore de widgets.
  const CadastroPage({super.key});

  // createstate cria o estado dessa tela.
  //
  // cadastro_page é a parte "pública" da tela.
  // _cadastropagestate é onde ficam os dados e métodos internos.
  //
  // quem chama esse método?
  // o próprio flutter chama quando precisa montar a tela.
  //
  // retorno:
  // retorna um state ligado à cadastropage.
  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

// state = parte que guarda a lógica e os dados da tela
//
// essa classe começa com underline.
// em dart, underline no começo deixa privado dentro do arquivo.
//
// isso quer dizer:
// outros arquivos usam CadastroPage,
// mas não acessam diretamente _CadastroPageState.
//
// analogia:
// CadastroPage é a parte que o app chama.
// _CadastroPageState é a parte interna, tipo os fios atrás da parede.
class _CadastroPageState extends State<CadastroPage> {
  // controla e valida o formulário
  //
  // globalkey<formstate>:
  // é uma chave que permite controlar o formulário.
  //
  // com ela, conseguimos chamar:
  //
  // _formKey.currentState!.validate()
  //
  // isso manda todos os campos rodarem suas validações.
  //
  // analogia:
  // é tipo o fiscal da ficha de cadastro.
  // antes de enviar, ele passa em campo por campo vendo se está ok.
  final _formKey = GlobalKey<FormState>();

  // controllers = pegam o texto digitado nos campos
  //
  // texteditingcontroller:
  // controla o texto de um campo.
  //
  // cada campo tem seu próprio controller.
  //
  // _nomecontroller:
  // pega o nome digitado.
  //
  // _emailcontroller:
  // pega o e-mail digitado.
  //
  // _cpfcontroller:
  // pega o cpf digitado.
  //
  // _telefonecontroller:
  // pega o telefone digitado.
  //
  // _senhacontroller:
  // pega a senha digitada.
  //
  // por que usa final?
  // porque o controller em si não será trocado.
  // o texto dentro dele muda, mas o objeto controller continua o mesmo.
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();

  // service = conversa com firebase
  //
  // cria um authservice para usar o método de cadastro.
  //
  // aqui vamos usar:
  //
  // _authService.cadastrarNovoUsuario(usuario)
  //
  // a tela monta o objeto usuario.
  // o service cadastra de verdade no firebase.
  final AuthService _authService = AuthService();

  // variável de loading.
  //
  // false:
  // não está carregando, então mostra o botão cadastrar.
  //
  // true:
  // está cadastrando, então mostra a bolinha de carregamento.
  //
  // isso evita clique duplo e mostra que o app está trabalhando.
  bool _carregando = false;

  // tipo selecionado no cadastro.
  //
  // começa como investidor.
  //
  // esse valor muda quando o usuário escolhe outra opção no dropdown.
  //
  // opções atuais:
  // - investidor;
  // - empreendedor.
  //
  // esse valor depois entra no objeto usuario.
  String _tipoSelecionado = 'investidor';

  @override
  void dispose() {
    // libera memória quando sair da tela
    //
    // quando a tela é fechada,
    // o flutter chama dispose automaticamente.
    //
    // controllers precisam ser descartados
    // porque eles ficam ligados aos campos de texto.
    //
    // analogia:
    // acabou de usar a sala, apaga a luz e fecha a porta.
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();

    // chama o dispose da classe pai.
    //
    // isso é necessário para o flutter fazer a limpeza interna dele também.
    super.dispose();
  }

  // método principal do cadastro
  //
  // esse método roda quando o usuário clica no botão "cadastrar".
  //
  // future<void>:
  // significa que é uma função assíncrona.
  // ela pode demorar porque depende do firebase/internet.
  //
  // void:
  // significa que ela não retorna um valor final para quem chamou.
  //
  // async:
  // permite usar await dentro da função.
  //
  // quem chama?
  // o botão elevatedbutton:
  //
  // onPressed: _fazerCadastro
  //
  // dependências desse método:
  // - _formKey, para validar o formulário;
  // - controllers, para pegar os textos digitados;
  // - usuario_model, para criar o objeto usuario;
  // - authservice, para cadastrar no firebase;
  // - scaffoldmessenger, para mostrar mensagens;
  // - navigator, para voltar para o login;
  // - setstate, para ligar/desligar loading.
  Future<void> _fazerCadastro() async {
    // valida os campos antes de continuar
    //
    // validate():
    // chama todos os validators dos campos do formulário.
    //
    // se algum campo retornar uma string de erro,
    // validate retorna false.
    //
    // se todos retornarem null,
    // validate retorna true.
    //
    // se estiver inválido, o return para a função aqui.
    //
    // assim o app não tenta cadastrar dados incompletos.
    if (!_formKey.currentState!.validate()) return;

    // liga o loading.
    //
    // setstate avisa o flutter:
    // "mudou alguma coisa, redesenha a tela".
    //
    // aqui _carregando vira true.
    //
    // resultado:
    // o botão some e aparece o circularprogressindicator.
    setState(() => _carregando = true);

    try {
      // cria um objeto usuario com os dados da tela
      //
      // aqui pegamos o que foi digitado nos campos
      // e transformamos em um objeto usuario.
      //
      // trim():
      // remove espaços no começo e no fim.
      //
      // exemplo:
      // "  isabela  "
      // vira:
      // "isabela"
      //
      // isso evita salvar dados com espaço sem querer.
      //
      // usuario:
      // é uma instância da classe Usuario.
      //
      // analogia:
      // a classe Usuario é o molde.
      // essa variável usuario é a ficha preenchida.
      final usuario = Usuario(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text.trim(),
        cpf: _cpfController.text.trim(),
        telefone: _telefoneController.text.trim(),
        tipo: _tipoSelecionado,
      );

      // chama o service que cadastra no firebase
      //
      // aqui a tela entrega o objeto usuario para o authservice.
      //
      // o authservice provavelmente faz duas coisas:
      // - cria o login no firebase auth;
      // - salva os dados extras no firestore.
      //
      // await:
      // espera o cadastro terminar.
      //
      // se der certo, continua.
      // se der erro, pula para o catch.
      await _authService.cadastrarNovoUsuario(usuario);

      // mounted:
      // verifica se a tela ainda existe.
      //
      // isso é importante porque o cadastro pode demorar.
      // nesse tempo, o usuário pode sair da tela.
      //
      // se a tela não existir mais,
      // não podemos usar context, snackbar ou navigator.
      if (!mounted) return;

      // mostra mensagem de sucesso
      //
      // scaffoldmessenger:
      // mostra uma snackbar na tela.
      //
      // snackbar:
      // mensagem temporária para avisar algo ao usuário.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário cadastrado com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // redireciona para a tela anterior (login)
      // como o cadastro foi aberto a partir do login com navigator.push,
      // o pop() volta para o login
      //
      // futuredelayed:
      // espera 2 segundos antes de voltar.
      //
      // por que esperar?
      // para o usuário conseguir ler a mensagem de sucesso.
      Future.delayed(const Duration(seconds: 2), () {
        // confere de novo se a tela ainda existe.
        if (!mounted) return;

        // navigator.pop:
        // fecha a tela atual e volta para a tela anterior.
        //
        // nesse caso, volta para login.
        Navigator.pop(context);
      });
    } catch (e) {
      // se der erro no cadastro, cai aqui.
      //
      // possíveis erros:
      // - e-mail já cadastrado;
      // - senha fraca;
      // - internet ruim;
      // - erro nas regras do firebase;
      // - erro no firestore;
      // - algum campo incompatível com o model/service.
      if (!mounted) return;

      // mostra erro caso algo dê errado
      //
      // aqui o erro é mostrado direto.
      //
      // para ficar mais bonito, daria para criar uma função de tradução
      // igual foi feito no login.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    } finally {
      // finally sempre executa.
      //
      // executa se deu certo ou se deu erro.
      //
      // aqui serve para desligar o loading no final.
      if (!mounted) return;

      // desliga o loading.
      //
      // resultado:
      // a bolinha some e o botão cadastrar volta.
      setState(() => _carregando = false);
    }
  }

  // valida campo obrigatório
  //
  // essa função evita repetir a mesma validação em vários campos.
  //
  // parâmetros:
  //
  // value:
  // valor digitado no campo.
  //
  // campo:
  // nome do campo usado na mensagem.
  //
  // retorno:
  // - retorna string se tiver erro;
  // - retorna null se estiver tudo certo.
  //
  // regra do validator no flutter:
  // string = erro
  // null = válido
  String? _validarObrigatorio(String? value, String campo) {
    // se o valor for nulo ou vazio,
    // retorna mensagem de erro.
    if (value == null || value.trim().isEmpty) {
      return 'Informe $campo';
    }

    // se está preenchido, retorna null.
    return null;
  }

  // valida senha
  //
  // essa função valida a senha digitada.
  //
  // regra atual:
  // - não pode estar vazia;
  // - precisa ter pelo menos 6 caracteres.
  //
  // isso combina com a exigência básica do firebase auth,
  // que normalmente pede senha com mínimo de 6 caracteres.
  String? _validarSenha(String? value) {
    // verifica se está vazia.
    if (value == null || value.trim().isEmpty) {
      return 'Informe a senha';
    }

    // verifica tamanho mínimo.
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }

    // se passou nas regras, está válida.
    return null;
  }

  // padrão visual dos campos
  //
  // essa função cria uma decoração padrão para os campos.
  //
  // por que fazer isso?
  // para não repetir o mesmo código visual em todos os textformfields.
  //
  // parâmetro:
  // label é o texto exibido no campo.
  //
  // retorno:
  // retorna um inputdecoration.
  //
  // analogia:
  // é tipo um molde visual para todos os campos ficarem combinando.
  InputDecoration _decoracao(String label) {
    return InputDecoration(
      // texto que aparece no campo.
      labelText: label,

      // borda do campo com canto arredondado.
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  // build monta a tela.
  //
  // o flutter chama o build quando precisa desenhar a interface.
  //
  // ele também chama de novo quando setstate muda algo.
  //
  // retorno:
  // retorna um widget.
  //
  // nesse caso, retorna um scaffold.
  Widget build(BuildContext context) {
    // scaffold:
    // estrutura base da tela.
    //
    // pode ter appbar, body, botão flutuante, drawer etc.
    return Scaffold(
      // appbar:
      // barra superior da tela.
      appBar: AppBar(title: const Text('Criar Conta - MesclaInvest')),

      // body:
      // conteúdo principal.
      body: SingleChildScrollView(
        // singlechildscrollview:
        // permite rolar a tela.
        //
        // isso é importante porque o cadastro tem muitos campos.
        // se a tela for pequena ou o teclado abrir,
        // o usuário ainda consegue rolar.
        padding: const EdgeInsets.all(20),

        child: Form(
          // conecta o formulário com a formkey.
          //
          // assim conseguimos chamar:
          // _formKey.currentState!.validate()
          key: _formKey,

          child: Column(
            // column organiza os widgets na vertical.
            children: [
              // campo nome.
              //
              // textformfield:
              // campo de texto com suporte a validação.
              TextFormField(
                // pega/controla o texto digitado no campo nome.
                controller: _nomeController,

                // aplica o visual padrão.
                decoration: _decoracao('Nome'),

                // valida se o campo foi preenchido.
                validator: (v) => _validarObrigatorio(v, 'o nome'),
              ),

              // espaço entre campos.
              const SizedBox(height: 16),

              // campo e-mail.
              TextFormField(
                // pega/controla o texto digitado no campo e-mail.
                controller: _emailController,

                // visual padrão.
                decoration: _decoracao('E-mail'),

                // teclado apropriado para e-mail.
                //
                // em celular, facilita aparecer o @.
                keyboardType: TextInputType.emailAddress,

                // valida se o e-mail foi preenchido.
                //
                // observação:
                // aqui só valida se está vazio.
                // não valida formato de e-mail.
                validator: (v) => _validarObrigatorio(v, 'o e-mail'),
              ),

              const SizedBox(height: 16),

              // campo cpf.
              TextFormField(
                // pega/controla o cpf digitado.
                controller: _cpfController,

                // visual padrão.
                decoration: _decoracao('CPF'),

                // teclado numérico.
                //
                // ajuda no celular, mas não impede totalmente letras
                // em todas as plataformas.
                keyboardType: TextInputType.number,

                // valida se cpf foi preenchido.
                //
                // observação:
                // aqui não valida se o cpf é real,
                // só se foi informado.
                validator: (v) => _validarObrigatorio(v, 'o CPF'),
              ),

              const SizedBox(height: 16),

              // campo telefone.
              TextFormField(
                // pega/controla o telefone digitado.
                controller: _telefoneController,

                // visual padrão.
                decoration: _decoracao('Telefone'),

                // teclado de telefone.
                keyboardType: TextInputType.phone,

                // valida se telefone foi preenchido.
                validator: (v) => _validarObrigatorio(v, 'o telefone'),
              ),

              const SizedBox(height: 16),

              // dropdown = campo de seleção
              //
              // dropdownbuttonformfield:
              // é um campo de formulário que permite escolher uma opção.
              //
              // aqui o usuário escolhe o tipo:
              // - investidor;
              // - empreendedor.
              //
              // por ser formfield, ele poderia ter validator também,
              // mas como já começa com "investidor",
              // sempre existe um valor selecionado.
              DropdownButtonFormField<String>(
                // value:
                // valor atualmente selecionado.
                //
                // começa como "investidor".
                value: _tipoSelecionado,

                // decoração visual do campo.
                decoration: _decoracao('Tipo'),

                // items:
                // lista de opções que aparecem no dropdown.
                items: const [
                  DropdownMenuItem(
                    // valor real salvo na variável.
                    value: 'investidor',

                    // texto que aparece para o usuário.
                    child: Text('Investidor'),
                  ),
                  DropdownMenuItem(
                    value: 'empreendedor',
                    child: Text('Empreendedor'),
                  ),
                ],

                // onchanged:
                // executa quando o usuário escolhe uma opção.
                onChanged: (value) {
                  // como value pode ser nulo,
                  // conferimos antes.
                  if (value != null) {
                    // atualiza o tipo selecionado.
                    //
                    // setstate redesenha a tela com o novo valor.
                    setState(() => _tipoSelecionado = value);
                  }
                },
              ),

              const SizedBox(height: 16),

              // campo senha.
              TextFormField(
                // pega/controla a senha digitada.
                controller: _senhaController,

                // visual padrão.
                decoration: _decoracao('Senha'),

                // esconde o texto digitado.
                //
                // em vez de mostrar a senha,
                // mostra bolinhas/pontos.
                obscureText: true,

                // usa a validação específica de senha.
                validator: _validarSenha,
              ),

              const SizedBox(height: 30),

              // botão cadastrar ou loading.
              //
              // operador ternário:
              //
              // condição ? se_verdadeiro : se_falso
              //
              // se _carregando for true:
              // mostra a bolinha de carregamento.
              //
              // se _carregando for false:
              // mostra o botão cadastrar.
              _carregando
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      // ocupa toda a largura disponível.
                      width: double.infinity,

                      // altura fixa do botão.
                      height: 50,

                      child: ElevatedButton(
                        // quando clica, chama o método principal de cadastro.
                        onPressed: _fazerCadastro,

                        // texto do botão.
                        child: const Text('CADASTRAR'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
