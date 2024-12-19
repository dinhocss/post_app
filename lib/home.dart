import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/post.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String baseUrl = "https://jsonplaceholder.typicode.com/";
  List<Post> postList = [];
  Future<List<Post>> getPost() async{
    String url = baseUrl + "posts";

    http.Response response = await http.get(Uri.parse(url));

    if(response.statusCode == 200){
        var dadosJson = jsonDecode(response.body);

        for(var dado in dadosJson){
          postList.add(Post.fromJson(dado));
        }
        print("Dados retornados com sucesso!");    
        return postList; 
    }
    else{
      print("Erro ao processar dados!");
      throw Exception("Recurso não encontrado");
    }
  }

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

  void _patch() async{
    String url = baseUrl + "posts/1";
    http.Response response = await http.patch(Uri.parse(url),
    headers:{
      "content-type":"application/json;charset=UTF-8"
    },
    body: jsonEncode(
      {
      "title":"Tosco pra caralho!"
      }
    )
    );

    print(response.statusCode.toString());
    print(response.body);
  }

  void _delete() async{
    String url = baseUrl + "posts/1";
    http.Response response = await http.delete(Uri.parse(url));

    print(response.statusCode.toString());
    setState(){};

  }

  @override
  Widget build(BuildContext context) {
    getPost();
    return Scaffold(
      appBar: AppBar(title: Text('Post API'),),
      body: Center(
        child: Container(
          child: Column(
            children: [
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
            ]
          )
        )
      )
    );
  }
}
