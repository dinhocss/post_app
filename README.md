# post_app
Aplicação criada para treinar a utilização dos métodos http (get, post, patch e delete) para realizar operações CRUD em uma API. O projeto utiliza a API JSONPlaceholder para fornecer os dados, e utiliza métodos http para lidar com esses dados.

O objetivo desse projeto é utilizar a API *JSONPlaceholder* para simular as operações de criação, leitura, atualização e remoção de dados em uma aplicação. Para isso utilizaremos os métodos http que acessarão os endpoints da API e farão a troca de dados necessária. 

# Configurações iniciais

Primeiro temos que adicionar a dependência *http*, pois ela nos possibilita utilizar os métodos http para comunicação com servidor. Para isso, adicionamos no arquivo *pubspec.yaml* a seguinte dependência: `http: ^1.2.2`

# Criando a classe Post

Essa classe será responsável por receber o arquivo JSON, mapear para os atributos criados pela classe e guardar cada elemento do post retornado pela API. Os atributos retornados pelo JSON são *userId*, *id*, *title*, *body*, portanto, precisamos criar variáveis que irão receber esses dados. 

Para uma maior flexibilidade e facilidade na hora de mapear os dados, nós utilizamos um construtor do tipo factory. Esse construtor permite que a gente receba os dados em um formato JSON e consiga transformá-los nos atributos da classe, possibilitando criar uma instância da classe diretamente do endpoint da API. 

Segue abaixo o código utilizado para instanciar um objeto de Post:
```
class Post{
  int id;
  int userId;
  String title;
  String body;

  Post(this.id, this.userId, this.title, this.body);

  factory Post.fromJson(Map json){
    return Post(
      json["id"],
      json["userId"],
      json["title"],
      json["body"]
    );
  }
}
```


# Criando o método GET

O metodo get retornará um objeto Future< ListPost < List>> que guardará uma lista contendo todos os posts disponíveis no endpoint *https://jsonplaceholder.typicode.com/posts*. Conforme formos adicionando ou removendo posts, essa lista será atualizada e renderizada de maneira dinâmica através do widget FutureBuilder.

Esse método irá acessar o endpoint  */posts* e fará uma solicitação get para o servidor. O servidor irá retornar uma lista de JSONs contendo todos os posts contidos no banco de dados do servidor. Esses arquivos JSON serão convertidos em um **objeto** do tipo Post e adicionados em uma lista. Segue abaixo o código referente ao método get:

```
Future<List<Post>> getPost() async{
    String url = baseUrl + "posts";

    http.Response response = await http.get(Uri.parse(url));

    var dadosJson = jsonDecode(response.body);
    List<Post> postList = [];

    for(var dado in dadosJson){
      postList.add(Post.fromJson(dado));
    }

    return postList;
  }
```

# Criando o método POST

O método post é utilizado para adicionarmos dados ao servidor através do endpoint fornecido. Como a API não adiciona de fato o dado no seu banco de dados, só será possível simular a operação post. O mesmo vale para os métodos patch e delete. Com estudos posteriores será implementado um banco de dados para os posts fornecidos para implementação completa dos métodos. 

O método post possui uma implementação semelhante ao método get. Portanto, além de definirmos o método como assíncrono, também utilizaremos a url, que será nosso endpoint, como parâmetro. A diferença é que além da url também passaremos um header e um body. O header contém informações sobre qual dado será inserido no servidor e o body contém um Json.Decode que recebe como parâmetro um map<String, dynamic> e será transformada em um JSON. Esse JSON será passado para a variável response. Um setState deveria ser implementado caso o banco de dados da API fosse atualizada, isso faria com que fosse feita novamente a execução do método get, agora com o dado inserido pelo método post.

Segue abaixo a implementação do método post:
```
  void _post() async{
    String url = baseUrl + "posts";

    http.Response response = await http.post(Uri.parse(url),
    headers: {
      "content-type":"application/json;charset=UTF-8"
    },
    body:jsonEncode(
      {
        "id":1,
        "userId":3,
        "title":"Webservices",
        "body":"Post sobre webservices."
      })
    ); 
    
    if(response.statusCode == 201){
      print("Dado criado com sucesso!");
      print(response.body);
    }
  }
```

# Criando o método PATCH

O método patch é responsável por atualizar algum dado presente no servidor. O método put tem a mesma função, com a diferença que no método patch, nós podemos atualizar parcialmente um recurso existente, enquanto em put nós atualizamos o recurso inteiro. 

A implementação é de patch é bem semelhante a post, com a única diferença sendo na passagem do body, onde passaremos apenas o atributo a ser atualizado, e na url. 

Segue abaixo uma implementação do método patch:
```
void _patch() async{

    String url = baseUrl + "posts/1";
    
    http.Response response = await http.patch(Uri.parse(url),
    headers:{
      "content-type":"application/json;charset=UTF-8"
    },
    body: jsonEncode(
      {
      "title":"Atualizando dado!"
      }
    )
    );

    print(response.statusCode.toString());
    print(response.body);
  }
```


# Criando o método DELETE

O método delete possui a implementação mais simples, pois precisamos apenas passar o método com a url no qual o recurso a ser deletado está contida. No caso, o endpoint seria um dado específico.

Segue abaixo a implementação de delete:
```
  void _delete() async{
    String url = baseUrl + "posts/1";

    http.Response response = await http.delete(Uri.parse(url));

    print(response.statusCode.toString());
  }
```

**OBS:** Em todos os métodos deveria ser utilizado o setState para atualizar o estado da aplicação e refletir as mudanças feitas no banco de dados, porém a APIé utilizada apenas para simulação das operações. 

# A interface e o método FutureBuilder

 O widget responsável por implementar os dados retornados da API para a tela é o FutureBuilder, que utilizado em conjunto com a classe Future, possibilitam um widget para construção dinâmica dos dados presentes no recurso. O método FutureBuilder tem como parâmetro um *future* e um *builder*. Esse *builder* recebe como parâmetro o *context* , que refere-se a posição do widget na tela ,e um *snapshot* que refere-se ao estado atual da requisição get. O snapshot nos fornece os códigos de status de uma requisição e também os dados retornados pela API. O método presente no *builder* quando a conexão é feita com sucesso constrói dinâmicamente os dados na tela, portanto, precisamos de uma interface que consiga lidar com esses dados. 

## O uso do widget expanded

 A chave para uma interface gráfica dinâmica e responsiva está no uso combinado de expanded com listView e listTile. Antes de retornar a interface propriamente dita é necessário criar a lista que receberá os dados da API e em seguida, o retorno é um expanded, que é um widget que possibilita adição dinâmica de dados. Seus atributos são flex, que possibilita que o widget seja duas vezes maior que os widgets padrão, e child que contém um widget do tipo ListView.

## O uso do widget ListView.builder e ListTile

o ListView é um widget que ajusta os widgets filhos em forma de lista, onde seus widgets filhos são roláveis, e a renderização de itens é otimizada. Seus filhos são itemCount, usada para fornecer o número de itens que o widget terá, e itemBuilder, responsável por criar cada widget filho. O builder terá uma função responsável por criar dinamicamente a interface. Será no builder que cada itém será atribuido a lista de itens retornados pela API, e o retorno dessa builder será um ListTile, que é utilizado em conjunto com ListView para criar itens de forma estruturada. ListTile tem como parâmetros leading, que é o id dos posts, title, que é o titulo, e o subtitulo, que é o usuário que fez o post. 

Um outro atributo é utilizado aqui, que é o *onTap*. Nele será passado como função anonima um showDialog, que possui como parâmetros um context e um builder. Esse builder retornará um alertDialog, que será responsável por exibir o título e o conteúdo dos dados retornados pela API, junto com um botão para fechar o Dialog.

Segue abaixo a implementação do widget FutureBuilder:
```
FutureBuilder<List<Post>>(
                future: getPost(),
                builder: (context, snapshot){
                  if(snapshot.connectionState == ConnectionState.done){
                    if(snapshot.hasError){
                      print("Erro ao acessar os dados da API");
                      return Text("erro");
                    }
                    else{
                      List<Post>? postList = snapshot.data;
                      return Expanded(
                        flex: 2,
                        child: ListView.builder(
                          itemCount: postList!.length,
                          itemBuilder: (context, index){
                            Post post = postList[index];
                            return ListTile(
                              leading: Text(post.id.toString()),
                              title: Text(post.title),
                              subtitle: Text(post.userId.toString()),
                              onTap: (){
                                showDialog(
                                  context: context,
                                  builder: (context){
                                    return AlertDialog(
                                      title: Text(post.title),
                                      content: Text(post.body),
                                      actions: [
                                        TextButton(
                                          onPressed: (){
                                            Navigator.pop(context);
                                          },
                                          child: Text("Fechar")
                                        )
                                      ]
                                    );
                                  }
                                );
                              }
                            );
                          }
                        )
                      );
                    }
                  }else if(snapshot.connectionState == ConnectionState.waiting){
                    return CircularProgressIndicator();
                  }
                  return Text("Sem carregamento");
                }
              )
```

# Os outros métodos

Para os métodos *post*, *patch* e *delete* foram criados três botões, porém não é possível verificar uma mudança visual na tela devido a limitação da API. Segue abaixo a implementação dos outros botões:
```
Row(
	children: [
		ElevatedButton(
	       onPressed: _post,
           child: Text("Salvar")),
        ElevatedButton(
           onPressed: _patch,
           child: Text("Atualizar")
         ),
        ElevatedButton(
            onPressed: _delete,
            child: Text("Deletar"))
        ]
 ),
```

