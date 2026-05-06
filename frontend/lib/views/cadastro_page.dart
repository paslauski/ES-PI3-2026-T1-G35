// isabela

// view = tela/interface do usuário
//
// esse arquivo representa a tela de cadastro do mesclainvest.
//
// responsabilidade dessa tela:
// - mostrar os campos de cadastro;
// - pegar os dados digitados pelo usuário;
// - validar se os campos estão preenchidos;
// - criar um objeto usuario;
// - chamar o authservice para cadastrar no firebase;
// - mostrar mensagem de sucesso ou erro;
// - voltar para a tela de login depois do cadastro.
//
// importante:
// essa tela não deve ter regra pesada de firebase dentro dela.
// ela só cuida da interface e chama o service.
//
// analogia:
// pensa nessa tela como uma ficha de inscrição.
// a pessoa preenche nome, e-mail, cpf, telefone, tipo e senha.
// depois a tela entrega essa ficha para o authservice,
// que é quem realmente vai registrar no sistema.

import 'package:flutter/material.dart';

// importa o model usuario.
//
// o model é o molde dos dados do usuário.
// ele define quais informações um usuário precisa ter.
//
// exemplo:
// nome, email, senha, cpf, telefone e tipo.
//
// analogia:
// a classe usuario é a ficha em branco.
// quando a gente cria um objeto usuario,
// é como preencher essa ficha com dados reais.
import '../models/usuario_model.dart';

// importa o authservice.
//
// o authservice é o arquivo/classe que conversa com o firebase.
//
// aqui a tela não fala diretamente com firebase auth ou firestore.
// ela chama o service.
//
// isso deixa o código mais organizado:
//
// cadastro_page.dart = cuida da tela;
// usuario_model.dart = define o formato do usuário;
// auth_service.dart = faz o cadastro no firebase.
import '../services/auth_service.dart';

// statefulwidget = tela que pode mudar, ou seja, tem estado dinâmico.
//
// por que essa tela é stateful?
// porque algumas coisas mudam nela:
//
// - o usuário digita nos campos;
// - a variável _carregando muda;
// - o tipo selecionado no dropdown muda;
// - a tela precisa atualizar quando o cadastro começa ou termina.
//
// se fosse uma tela parada, poderia ser statelesswidget.
// mas como tem mudança, precisa ser statefulwidget.
class CadastroPage extends StatefulWidget {
  // construtor da tela.
  //
  // const:
  // ajuda o flutter a otimizar o widget quando possível.
  //
  // super.key:
  // passa a key para a classe pai.
  // a key ajuda o flutter a identificar widgets na árvore da interface.
  const CadastroPage({super.key});

  // createstate cria o estado dessa tela.
  //
  // a classe cadastropage é a tela em si.
  // a classe _cadastropagestate é onde ficam os dados e métodos internos.
  //
  // quem chama esse método?
  // o próprio flutter chama automaticamente quando precisa montar a tela.
  //
  // retorno:
  // retorna um state ligado à cadastropage.
  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

// state = onde ficam os dados e a lógica da tela.
//
// essa classe começa com underline.
// em dart, isso significa que ela é privada dentro deste arquivo.
//
// outros arquivos conseguem abrir a tela cadastropage,
// mas não acessam diretamente o estado interno dela.
//
// analogia:
// cadastropage é a frente do caixa eletrônico.
// _cadastropagestate é a parte interna, com os fios e lógica funcionando.
class _CadastroPageState extends State<CadastroPage> {
  // formkey controla e valida o formulário.
  //
  // globalkey<formstate>:
  // é uma chave que permite acessar o estado do form.
  //
  // com isso conseguimos chamar:
  //
  // _formKey.currentState!.validate()
  //
  // isso roda a validação de todos os campos do formulário.
  //
  // analogia:
  // é tipo um fiscal olhando todos os campos antes de deixar enviar.
  final _formKey = GlobalKey<FormState>();

  // controllers = capturam o que o usuário digita.
  //
  // texteditingcontroller:
  // controla o texto de um campo.
  //
  // cada campo tem seu próprio controller:
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
  // final:
  // significa que o controller em si não será trocado.
  // o texto dentro dele pode mudar, mas o objeto controller continua o mesmo.
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();

  // cria uma instância do authservice.
  //
  // essa variável será usada para chamar o método de cadastro:
  //
  // _authService.cadastrarNovoUsuario(usuario)
  //
  // a tela prepara os dados.
  // o service manda para o firebase.
  final AuthService _authService = AuthService();

  // controla se a tela está carregando.
  //
  // false:
  // mostra o botão cadastrar.
  //
  // true:
  // mostra a bolinha de carregamento.
  //
  // isso evita clique duplo enquanto o cadastro está acontecendo.
  bool _carregando = false;

  // guarda o tipo de usuário selecionado.
  //
  // valor inicial:
  // investidor.
  //
  // o usuário pode trocar para empreendedor no dropdown.
  //
  // esse valor entra no objeto usuario e depois pode ser salvo no firestore.
  String _tipoSelecionado = 'investidor';

  // libera memória quando sai da tela, boa prática.
  //
  // dispose é chamado automaticamente quando essa tela é destruída.
  //
  // controllers precisam ser descartados porque ficam ligados aos campos.
  //
  // analogia:
  // terminou de usar, limpa a mesa e fecha a sala.
  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();

    // chama o dispose da classe pai também.
    // isso deixa o flutter fazer as limpezas internas dele.
    super.dispose();
  }

  // método principal do botão.
  //
  // esse método roda quando o usuário clica em "cadastrar".
  //
  // future<void>:
  // quer dizer que é uma função assíncrona.
  // ela pode demorar porque depende do firebase/internet.
  //
  // void:
  // significa que ela não retorna um valor final.
  //
  // async:
  // permite usar await dentro da função.
  //
  // quem chama esse método?
  // o botão:
  //
  // onPressed: _fazerCadastro
  //
  // dependências desse método:
  // - _formKey para validar o formulário;
  // - controllers para pegar os textos;
  // - usuario para montar o objeto;
  // - authservice para cadastrar no firebase;
  // - scaffoldmessenger para mostrar mensagens;
  // - navigator para voltar ao login;
  // - setstate para atualizar o loading.
  Future<void> _fazerCadastro() async {
    // valida o formulário.
    //
    // validate():
    // chama todos os validators dos campos dentro do form.
    //
    // se algum campo estiver errado, validate retorna false.
    // se todos estiverem certos, retorna true.
    //
    // se retornar false, o return para o método aqui.
    //
    // isso impede de cadastrar usuário com dados incompletos.
    if (!_formKey.currentState!.validate()) return;

    // liga o loading.
    //
    // setstate avisa o flutter que uma variável mudou
    // e que a tela precisa ser redesenhada.
    //
    // aqui _carregando vira true.
    //
    // resultado:
    // o botão cadastrar some e aparece a bolinha.
    setState(() => _carregando = true);

    try {
      // cria objeto usuario com os dados da tela.
      //
      // final usuario:
      // cria uma variável que guarda um objeto usuario.
      //
      // objeto:
      // é a classe preenchida na prática.
      //
      // classe usuario:
      // é o molde.
      //
      // objeto usuario:
      // é uma ficha real com os dados digitados.
      //
      // trim():
      // remove espaços no começo e no fim do texto.
      //
      // exemplo:
      // "  isabela  "
      // vira:
      // "isabela"
      final usuario = Usuario(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text.trim(),
        cpf: _cpfController.text.trim(),
        telefone: _telefoneController.text.trim(),
        tipo: _tipoSelecionado,
      );

      // chama o service, que faz o cadastro no firebase.
      //
      // aqui a tela entrega o objeto usuario para o authservice.
      //
      // normalmente, dentro do authservice, acontece algo assim:
      // - cria usuário no firebase auth com email e senha;
      // - salva os dados extras no firestore, como nome, cpf, telefone e tipo.
      //
      // await:
      // espera o cadastro terminar.
      //
      // se der certo, continua para a mensagem de sucesso.
      // se der erro, pula para o catch.
      await _authService.cadastrarNovoUsuario(usuario);

      // mounted verifica se a tela ainda existe.
      //
      // isso importa porque o cadastro pode demorar.
      // nesse tempo, o usuário pode sair da tela.
      //
      // se a tela não existir mais, não podemos usar context.
      if (!mounted) return;

      // mensagem de sucesso.
      //
      // scaffoldmessenger mostra uma snackbar.
      //
      // snackbar:
      // mensagem temporária na tela.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário cadastrado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // redirecionamento.
      //
      // navigator.pop() = volta para a tela anterior, que nesse fluxo é o login.
      //
      // por que pop?
      // porque a tela de cadastro normalmente foi aberta com navigator.push
      // a partir da tela de login.
      //
      // então, para voltar, basta fechar a tela atual.
      //
      // diferença:
      //
      // push:
      // abre uma nova tela.
      //
      // pop:
      // fecha a tela atual.
      //
      // pushreplacement:
      // troca a tela atual por outra.
      Navigator.pop(context);
    } catch (e) {
      // se algo der errado, cai no catch.
      //
      // possíveis erros:
      // - e-mail já cadastrado;
      // - senha fraca;
      // - internet ruim;
      // - erro no firebase auth;
      // - erro no firestore;
      // - regra de segurança bloqueando;
      // - algum dado incompatível com o model/service.
      if (!mounted) return;

      // mostra o erro na tela.
      //
      // aqui ele mostra o erro bruto.
      // em uma versão mais bonitinha, poderia traduzir o erro,
      // como foi feito na tela de login.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    } finally {
      // finally sempre executa.
      //
      // ele roda tanto se deu certo quanto se deu erro.
      //
      // aqui é usado para desligar o loading no final.
      if (!mounted) return;

      // desliga o loading.
      //
      // _carregando volta para false.
      //
      // resultado:
      // a bolinha some e o botão cadastrar volta.
      setState(() => _carregando = false);
    }
  }

  // validações, regras de entrada.
  //
  // essa função valida campos obrigatórios.
  //
  // parâmetros:
  //
  // value:
  // texto digitado no campo.
  //
  // campo:
  // nome usado na mensagem de erro.
  //
  // retorno:
  // string se tiver erro.
  // null se estiver tudo certo.
  //
  // regra do validator no flutter:
  // - retornou string: campo inválido;
  // - retornou null: campo válido.
  String? _validarObrigatorio(String? value, String campo) {
    // se o valor for nulo ou vazio depois do trim,
    // retorna mensagem de erro.
    if (value == null || value.trim().isEmpty) {
      return 'Informe $campo';
    }

    // se chegou aqui, está válido.
    return null;
  }

  // valida a senha.
  //
  // regra:
  // senha precisa existir e ter pelo menos 6 caracteres.
  //
  // aqui tem uma diferença:
  // ele não usa trim antes de medir o tamanho.
  // então uma senha com espaços também conta.
  //
  // para projeto real, poderia usar value.trim().isEmpty também,
  // mas para a regra básica do firebase, o tamanho mínimo já ajuda.
  String? _validarSenha(String? value) {
    // se value for nulo ou tiver menos de 6 caracteres,
    // retorna erro.
    if (value == null || value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }

    // se passou pela regra, está ok.
    return null;
  }

  // padrão visual dos campos.
  //
  // essa função cria a decoração dos textformfields.
  //
  // por que usar função?
  // para não repetir o mesmo código em todos os campos.
  //
  // parâmetro:
  // label é o texto que aparece no campo.
  //
  // retorno:
  // retorna um inputdecoration.
  //
  // analogia:
  // é tipo um molde visual para todos os campos ficarem no mesmo estilo.
  InputDecoration _decoracao(String label) {
    return InputDecoration(
      // texto exibido no campo.
      labelText: label,

      // borda ao redor do campo com canto arredondado.
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // build = monta a tela.
  //
  // o flutter chama o build quando precisa desenhar a interface.
  //
  // ele também chama de novo quando algum setstate acontece.
  //
  // retorno:
  // retorna um widget.
  //
  // nesse caso, retorna um scaffold.
  @override
  Widget build(BuildContext context) {
    // scaffold:
    // estrutura base de uma tela no flutter.
    //
    // pode ter:
    // - appbar;
    // - body;
    // - drawer;
    // - floatingactionbutton;
    // e outras partes.
    return Scaffold(
      // appbar:
      // barra superior da tela.
      appBar: AppBar(title: const Text('Criar Conta - MesclaInvest')),

      // body:
      // conteúdo principal da tela.
      body: SingleChildScrollView(
        // singlechildscrollview:
        // permite rolar a tela.
        //
        // isso é importante porque o cadastro tem muitos campos.
        // se a tela for pequena ou o teclado abrir, o usuário consegue rolar.
        padding: const EdgeInsets.all(20),

        child: Form(
          // conecta esse formulário com a formkey.
          //
          // assim conseguimos validar tudo de uma vez.
          key: _formKey,

          child: Column(
            // column organiza os widgets um embaixo do outro.
            children: [
              // campo nome.
              TextFormField(
                // controller que pega o nome digitado.
                controller: _nomeController,

                // decoração visual do campo.
                decoration: _decoracao('Nome'),

                // valida se o nome foi preenchido.
                validator: (v) => _validarObrigatorio(v, 'o nome'),
              ),

              // espaço entre os campos.
              const SizedBox(height: 16),

              // campo e-mail.
              TextFormField(
                // controller que pega o e-mail digitado.
                controller: _emailController,

                // decoração visual.
                decoration: _decoracao('E-mail'),

                // valida se o e-mail foi preenchido.
                //
                // observação:
                // aqui não valida formato de e-mail,
                // só valida se está vazio.
                validator: (v) => _validarObrigatorio(v, 'o e-mail'),
              ),

              const SizedBox(height: 16),

              // campo cpf.
              TextFormField(
                // controller que pega o cpf digitado.
                controller: _cpfController,

                // decoração visual.
                decoration: _decoracao('CPF'),

                // valida se o cpf foi preenchido.
                //
                // observação:
                // aqui não valida se o cpf é real,
                // apenas se foi informado.
                validator: (v) => _validarObrigatorio(v, 'o CPF'),
              ),

              const SizedBox(height: 16),

              // campo telefone.
              TextFormField(
                // controller que pega o telefone digitado.
                controller: _telefoneController,

                // decoração visual.
                decoration: _decoracao('Telefone'),

                // valida se o telefone foi preenchido.
                validator: (v) => _validarObrigatorio(v, 'o telefone'),
              ),

              const SizedBox(height: 16),

              // dropdownbuttonformfield:
              // campo de seleção dentro de um formulário.
              //
              // aqui serve para o usuário escolher o tipo da conta.
              //
              // opções:
              // - investidor;
              // - empreendedor.
              DropdownButtonFormField<String>(
                // value:
                // valor atualmente selecionado.
                //
                // começa com investidor.
                value: _tipoSelecionado,

                // decoração visual.
                decoration: _decoracao('Tipo'),

                // items:
                // lista de opções do dropdown.
                items: const [
                  DropdownMenuItem(
                    // valor salvo internamente.
                    value: 'investidor',

                    // texto mostrado para o usuário.
                    child: Text('Investidor'),
                  ),
                  DropdownMenuItem(
                    value: 'empreendedor',
                    child: Text('Empreendedor'),
                  ),
                ],

                // onchanged:
                // executa quando o usuário muda a opção.
                onChanged: (value) {
                  // value pode ser nulo, então verifica antes.
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
                // controller que pega a senha digitada.
                controller: _senhaController,

                // decoração visual.
                decoration: _decoracao('Senha'),

                // obscuretext esconde a senha.
                //
                // em vez de aparecer o texto real,
                // aparecem bolinhas/pontos.
                obscureText: true,

                // usa a função específica de validação de senha.
                validator: _validarSenha,
              ),

              const SizedBox(height: 30),

              // aqui decide se mostra loading ou botão.
              //
              // isso é um operador ternário:
              //
              // condição ? se_for_verdadeiro : se_for_falso
              //
              // se _carregando for true:
              // mostra circularprogressindicator.
              //
              // se _carregando for false:
              // mostra botão cadastrar.
              _carregando
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      // botão ocupa toda a largura disponível.
                      width: double.infinity,

                      // altura fixa do botão.
                      height: 50,

                      child: ElevatedButton(
                        // quando clica, chama o método principal.
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
