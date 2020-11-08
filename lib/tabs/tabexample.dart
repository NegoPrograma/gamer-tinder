
Abaixo, um exemplo de como utilizar abas em flutter

>começamos colocando um widget TabBar no atributo bottom de um appbar.
>esse atributo possui um parametro chamado tabs, que espera um vetor de widgets
do tipo tab.

>no body, utilizamos agora o TabBarView, que assim como um column possui um parametro children com o conteúdo de cada aba.
>porém, é necessário um controlador pra dizer exatamente que conteúdo está ligado a cada aba.
>o controlador das abas deve ser iniciado com alguns parametros: length, a quantidade de abas e o vsync.
>o vsync pelo o que eu entendi depois de pesquisar serve pra auxiliar na animação de transição entre as abas, ele diz que alguma tela deveria ficar responsavel por isso e atualizar a mesma. Como ele é um parâmetro que exige um tickerprovider, é necessário utilizarmos o mixin singletickerproviderstatemixin .
>E como a classe que recebe esse ticker é a mesma onde ele está inserido, basta dizer que o listener é this, similar aqueles event listeners em java.

```
import 'package:flutter/material.dart';
import 'package:tabbar/PrimeiraPagina.dart';
import 'package:tabbar/SegundaPagina.dart';
import 'package:tabbar/TerceiraPagina.dart';

void main() => runApp(MaterialApp(
  home: Home(),
));

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>
    with SingleTickerProviderStateMixin {

  TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
        length: 3,
        vsync: this,
      initialIndex: 0
    );

  }

  @override
  void dispose() {

    super.dispose();
    _tabController.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Abas"),
        bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(
              //text: "Home",
              icon: Icon(Icons.home),
            ),
            Tab(
              //text: "Email",
              icon: Icon(Icons.email),
            ),
            Tab(
              //text: "Conta",
              icon: Icon(Icons.account_circle),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          PrimeiraPagina(),
          SegundaPagina(),
          TerceiraPagina()
        ],
      ),
    );
  }
}
```
