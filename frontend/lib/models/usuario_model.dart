// isabela

// classe = "molde" de um objeto
// aqui estamos dizendo: todo usuário do sistema tem esses dados.
//
// esse arquivo é um model.
//
// model:
// é uma classe que representa dados do sistema.
//
// nesse caso, o model usuario representa os dados de uma pessoa cadastrada
// no mesclainvest.
//
// responsabilidade dessa classe:
// - definir quais atributos um usuário possui;
// - obrigar que certos dados sejam informados ao criar um usuário;
// - transformar o objeto usuario em map para salvar no firestore.
//
// importante:
// essa classe não cria tela.
// essa classe não fala com firebase diretamente.
// essa classe não faz login.
// ela só representa os dados do usuário.
//
// analogia:
// pensa nessa classe como uma ficha de cadastro em branco.
// a ficha tem campos obrigatórios:
// nome, e-mail, senha, cpf, telefone e tipo.
// quando a pessoa preenche essa ficha, nasce um objeto usuario.

class Usuario {
  // atributos = características do objeto
  //
  // atributo:
  // é uma informação guardada dentro do objeto.
  //
  // aqui estamos dizendo que todo usuario terá:
  // - nome;
  // - email;
  // - senha;
  // - cpf;
  // - telefone;
  // - tipo.
  //
  // todos são string.
  //
  // string:
  // tipo usado para texto.
  //
  // exemplo:
  // nome = "isabela"
  // email = "isabela@email.com"
  // cpf = "12345678900"
  // telefone = "19999999999"
  // tipo = "investidor"

  // nome do usuário.
  //
  // exemplo:
  // "isabela santos"
  String nome;

  // e-mail do usuário.
  //
  // usado no cadastro e login.
  //
  // exemplo:
  // "isabela@email.com"
  String email;

  // senha do usuário.
  //
  // usada só para criar no auth.
  // não vai para o firestore.
  //
  // explicação importante:
  // a senha entra nesse objeto porque a tela de cadastro precisa mandar
  // a senha para o authservice.
  //
  // o authservice usa essa senha para criar a conta no firebase auth.
  //
  // mas quando o método paramapa() monta os dados para o firestore,
  // a senha não aparece no map.
  //
  // ou seja:
  // a senha passa pelo objeto,
  // mas não é salva no banco de perfil.
  //
  // quem cuida da senha é o firebase auth.
  //
  // analogia:
  // a senha é tipo uma chave que você mostra para o porteiro criar seu acesso,
  // mas ela não fica escrita na ficha pública do usuário.
  String senha;

  // cpf do usuário.
  //
  // no código atual, ele é salvo como string.
  //
  // por que string e não int?
  // porque cpf não é usado para fazer conta matemática.
  //
  // além disso, cpf pode ter zero na frente.
  // se fosse número, poderia perder esse zero.
  //
  // exemplo:
  // "01234567890"
  String cpf;

  // telefone do usuário.
  //
  // também fica como string porque telefone não é número para cálculo.
  //
  // além disso, pode ter ddd, +55, parênteses, traços etc.
  //
  // exemplo:
  // "(19) 99999-9999"
  String telefone;

  // tipo do usuário.
  //
  // no projeto, pode ser:
  // - investidor;
  // - empreendedor.
  //
  // esse campo ajuda o sistema a saber o papel daquele usuário.
  //
  // exemplo:
  // um investidor pode navegar no catálogo.
  // um empreendedor poderia ter outro tipo de acesso, dependendo da regra.
  String tipo;

  // construtor = função que cria o objeto na memória
  // "required" = obrigatório passar esse valor ao criar o usuário
  //
  // construtor:
  // é chamado quando usamos:
  //
  // Usuario(...)
  //
  // ele serve para montar/preencher o objeto.
  //
  // exemplo:
  //
  // final usuario = Usuario(
  //   nome: "isabela",
  //   email: "isabela@email.com",
  //   senha: "123456",
  //   cpf: "12345678900",
  //   telefone: "19999999999",
  //   tipo: "investidor",
  // );
  //
  // this.nome:
  // significa que o valor recebido no construtor vai para o atributo nome
  // desta própria classe.
  //
  // required:
  // obriga quem for criar um usuario a passar aquele campo.
  //
  // se esquecer um campo required, o dart reclama antes mesmo de rodar.
  //
  // analogia:
  // é como uma ficha obrigatória.
  // não dá para criar usuário sem preencher os campos principais.
  Usuario({
    required this.nome,
    required this.email,
    required this.senha,
    required this.cpf,
    required this.telefone,
    required this.tipo,
  });

  // método = função dentro da classe
  // converte o objeto em um mapa, formato que o firebase entende
  //
  // método:
  // é uma função que pertence à classe.
  //
  // esse método se chama paramapa.
  //
  // objetivo:
  // transformar o objeto usuario em map.
  //
  // por que precisa disso?
  // porque o firestore salva dados em formato chave:valor.
  //
  // objeto usuario:
  // usuario.nome
  // usuario.email
  // usuario.cpf
  //
  // map:
  // {
  //   'nome': 'isabela',
  //   'email': 'isabela@email.com',
  //   'cpf': '12345678900'
  // }
  //
  // retorno:
  // retorna Map<String, dynamic>.
  //
  // Map:
  // estrutura de chave e valor.
  //
  // String:
  // as chaves são textos.
  //
  // dynamic:
  // os valores podem ser de tipos diferentes.
  //
  // exemplo:
  // nome é string.
  // dataCadastro também é string nesse código.
  //
  // quem chama esse método?
  // o authservice chama quando salva no firestore:
  //
  // usuario.paraMapa()
  //
  // ponto importante:
  // esse método não coloca senha no map.
  // isso é certo, porque senha não deve ir para o firestore.
  Map<String, dynamic> paraMapa() {
    // return:
    // devolve o map pronto para quem chamou.
    return {
      // chave 'nome':
      // será o nome do campo no firestore.
      //
      // valor nome:
      // é o atributo nome deste objeto.
      'nome': nome,

      // salva o e-mail no firestore.
      //
      // o e-mail também existe no auth,
      // mas salvar no perfil facilita exibir e consultar depois.
      'email': email,

      // salva o cpf no firestore.
      'cpf': cpf,

      // salva o telefone no firestore.
      'telefone': telefone,

      // salva o tipo de usuário.
      //
      // exemplo:
      // investidor ou empreendedor.
      'tipo': tipo,

      // salva a data do cadastro
      //
      // DateTime.now():
      // pega a data e hora atual do aparelho/sistema no momento do cadastro.
      //
      // toIso8601String():
      // transforma a data em texto no padrão iso 8601.
      //

      // exemplo aproximado:
      // "2026-05-05T20:30:00.000"
      //
      // por que usar esse formato?
      // porque é um formato organizado e fácil de ler/ordenar.
      //
      // observação de banca:
      // aqui a data vem do aparelho/app.
      // em um sistema mais robusto, poderia usar timestamp do servidor
      // para evitar diferença de horário do dispositivo.
      'dataCadastro': DateTime.now().toIso8601String(),
    };
  }
}
