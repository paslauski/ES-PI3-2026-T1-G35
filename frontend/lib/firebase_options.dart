// isabela
// (gerado via flutterfire cli)
// objetivo: guardar as configurações do firebase do projeto
//
// obs importante pra apresentação:
// aqui não fica senha de usuário e nem token secreto.
// essas informações são mais tipo o “endereço” do firebase do projeto.
//
// tipo:
// - qual é o projeto no firebase?
// - qual é o app web?
// - qual é o app android?
// - qual é o app ios?
//
// a segurança de verdade não fica nesse arquivo.
// quem protege os dados mesmo são:
// - firebase auth;
// - regras do firestore;
// - regras do storage;
// - validações no backend/functions.
//
// analogia:
// esse arquivo é tipo o endereço da escola no gps.
// ele mostra onde é o firebase do projeto,
// mas não significa que qualquer pessoa pode entrar em qualquer sala.
// pra entrar nas salas, precisa de login, permissão e regra de segurança.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

// esse import pega umas ferramentas do flutter pra descobrir
// onde o app está rodando.
//
// defaulttargetplatform:
// descobre se é android, ios, windows, macos, linux etc.
//
// kisweb:
// fala se o app está rodando no navegador/chrome.
// se for web, ele retorna true.
// se não for web, retorna false.
//
// targetplatform:
// é tipo uma lista de plataformas possíveis:
// android, ios, windows, macos, linux...
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

// essa classe não é uma tela.
// ela não aparece pro usuário.
// ela só guarda as configurações do firebase.
//
// quem usa essa classe?
// normalmente o main.dart usa assim:
//
// await firebase.initializeapp(
//   options: defaultfirebaseoptions.currentplatform,
// );
//
// ou seja:
// quando o app liga, o main.dart pergunta:
// “qual configuração do firebase eu tenho que usar nessa plataforma?”
//
// analogia:
// essa classe é tipo uma recepcionista.
// ela olha onde o app está rodando e fala:
// “se é web, usa essa chave aqui”
// “se é android, usa essa outra aqui”
// “se é ios, usa essa outra aqui”
class DefaultFirebaseOptions {
  // esse método descobre onde o app está rodando.
  //
  // static:
  // quer dizer que eu posso chamar direto pela classe,
  // sem precisar criar um objeto dela.
  //
  // exemplo:
  // defaultfirebaseoptions.currentplatform
  //
  // não precisa fazer:
  // defaultfirebaseoptions opcoes = defaultfirebaseoptions();
  //
  // firebaseoptions:
  // é o tipo de coisa que esse método vai devolver.
  // ele precisa devolver uma configuração do firebase.
  //
  // get:
  // faz esse método parecer uma variável.
  // por fora a gente chama como se fosse um atributo,
  // mas por dentro ele roda uma lógica.
  //
  // o que ele retorna?
  // ele retorna a configuração certa:
  // - web;
  // - android;
  // - ios;
  // - macos;
  // - windows.
  static FirebaseOptions get currentPlatform {
    // primeiro ele vê se está rodando na web.
    //
    // kisweb == true significa:
    // “o app está rodando no navegador”.
    //
    // se for web, já devolve a configuração web.
    if (kIsWeb) {
      return web; // usa as configurações da web
    }

    // se não for web, ele olha o sistema/plataforma.
    //
    // switch é tipo um “escolhe o caminho certo”.
    //
    // analogia:
    // é como perguntar:
    // “você está no android? então vai pra configuração android.”
    // “você está no ios? então vai pra configuração ios.”
    // “você está no windows? então vai pra configuração windows.”
    switch (defaultTargetPlatform) {
      // se estiver rodando em android, usa as configs android.
      case TargetPlatform.android:
        return android;

      // se estiver rodando em iphone/ipad, usa as configs ios.
      case TargetPlatform.iOS:
        return ios;

      // se estiver rodando em mac, usa as configs macos.
      case TargetPlatform.macOS:
        return macos;

      // se estiver rodando em windows, usa as configs windows.
      case TargetPlatform.windows:
        return windows;

      // se estiver rodando em linux, dá erro.
      //
      // por quê?
      // porque esse projeto não foi configurado pra linux no flutterfire cli.
      //
      // unsupportederror:
      // é um erro que significa:
      // “isso aqui não está preparado pra essa plataforma”.
      case TargetPlatform.linux:
        throw UnsupportedError(
          'defaultfirebaseoptions não foi configurado para linux - '
          'rode o flutterfire cli de novo se quiser configurar.',
        );

      // caso caia em alguma plataforma estranha ou não prevista,
      // também dá erro.
      //
      // isso é melhor do que tentar abrir o firebase com configuração errada.
      default:
        throw UnsupportedError(
          'defaultfirebaseoptions não suporta essa plataforma.',
        );
    }
  }

  // configuração do firebase para web.
  //
  // static:
  // pertence à classe, então dá pra acessar direto.
  //
  // const:
  // é fixo, não muda enquanto o app roda.
  //
  // firebaseoptions:
  // é o objeto que guarda as informações que o firebase precisa.
  //
  // apiKey:
  // não é senha de usuário.
  // é uma chave pública de identificação/configuração do app.
  //
  // appId:
  // identifica esse app dentro do firebase.
  //
  // messagingSenderId:
  // id ligado ao envio de mensagens/notificações.
  //
  // projectId:
  // é o nome/id do projeto no firebase.
  //
  // authDomain:
  // domínio usado pelo login/autenticação na web.
  //
  // storageBucket:
  // lugar onde ficariam arquivos/imagens no firebase storage.
  //
  // measurementId:
  // usado pra analytics/medição.
  //
  // analogia:
  // esse bloco é tipo a ficha cadastral da versão web do app.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCdRNTr7bDWA8_JMD1j9bEIdIVREwn33kU',
    appId: '1:696645311566:web:262642b6ec4224f562771f',
    messagingSenderId: '696645311566',
    projectId: 'pi-3--mescla-invest',
    authDomain: 'pi-3--mescla-invest.firebaseapp.com',
    storageBucket: 'pi-3--mescla-invest.firebasestorage.app',
    measurementId: 'G-B5W3JSPEYB',
  );

  // configuração do firebase para android.
  //
  // quando o app rodar no celular android,
  // é esse bloco aqui que vai ser usado.
  //
  // mesmo sendo o mesmo projeto firebase,
  // cada plataforma tem seu próprio appid.
  //
  // analogia:
  // é o mesmo projeto, mas cada plataforma tem seu próprio crachá.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCOiDdJl8swPGfy8OLQTz2boyZ19fo5I1U',
    appId: '1:696645311566:android:990b5a04d47eacf262771f',
    messagingSenderId: '696645311566',
    projectId: 'pi-3--mescla-invest',
    storageBucket: 'pi-3--mescla-invest.firebasestorage.app',
  );

  // configuração do firebase para ios.
  //
  // ios é usado em iphone/ipad.
  //
  // iosbundleid:
  // é o identificador do pacote do app no ecossistema apple.
  //
  // analogia:
  // é tipo o rg do app dentro do mundo da apple.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCVY18Woc3V9BPjmo28NvPuq0dFGQRkNZc',
    appId: '1:696645311566:ios:393bb380c9e23bbf62771f',
    messagingSenderId: '696645311566',
    projectId: 'pi-3--mescla-invest',
    storageBucket: 'pi-3--mescla-invest.firebasestorage.app',
    iosBundleId: 'com.example.frontend',
  );

  // configuração do firebase para macos.
  //
  // macos é usado quando o app roda em computador mac.
  //
  // aqui ele está bem parecido com o ios,
  // porque os dois são plataformas da apple.
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCVY18Woc3V9BPjmo28NvPuq0dFGQRkNZc',
    appId: '1:696645311566:ios:393bb380c9e23bbf62771f',
    messagingSenderId: '696645311566',
    projectId: 'pi-3--mescla-invest',
    storageBucket: 'pi-3--mescla-invest.firebasestorage.app',
    iosBundleId: 'com.example.frontend',
  );

  // configuração do firebase para windows.
  //
  // usada quando o app roda como aplicativo desktop no windows.
  //
  // repara que o appid é diferente do web normal.
  // isso acontece porque o firebase separa os apps por plataforma.
  //
  // mesmo projeto, mas registros diferentes.
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCdRNTr7bDWA8_JMD1j9bEIdIVREwn33kU',
    appId: '1:696645311566:web:8ff7261d8c8dd63362771f',
    messagingSenderId: '696645311566',
    projectId: 'pi-3--mescla-invest',
    authDomain: 'pi-3--mescla-invest.firebaseapp.com',
    storageBucket: 'pi-3--mescla-invest.firebasestorage.app',
    measurementId: 'G-F7Y8CK12Z2',
  );
}
