import 'package:dependentdropdowntutorial/post.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'user.dart';

//* p1 - importar biblioteca http
//* p2 - criar models user e post
//* p3 - criar a requisição http para buscar users
//* p4 - criar a requisição http para buscar posts
//* p5 - criar função para buscar users no início do app
//* p6 - buscar users no initState
//* p7 - criar variável que guarda o user selecionado no dropdown
//* p8 - criar dropdownbutton de users
//* p9 - criar hint do dropdownbutton de users
//* p10 - tratar tempo de espera do servidor no dropdown de users
//* p11 - tratar erro do servidor no dropdown de users
//* p12 - criar função para buscar posts
//* p13 - buscar posts ao mudar dropdown de users
//* p14 - criar variável que guarda o post selecionado no dropdown
//* p15 - criar dropdownbutton de posts
//* p16 - tratar tempo de espera do servidor no dropdown de posts
//* p17 - tratar erro do servidor no dropdown de posts

Future<List<User>> fetchUsers() async {
  final response =
      await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
  if (response.statusCode == 200) {
    // return Future.delayed(const Duration(seconds: 2),
    //     () => throw Exception('Erro ao buscar usuários.'));
    return Future.delayed(
        const Duration(seconds: 2), () => userFromJson(response.body));
    // return userFromJson(response.body);
  } else {
    throw Exception('Erro ao buscar usuários.');
  }
}

Future<List<Post>> fetchPosts(userId) async {
  final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/posts?userId=$userId'));
  if (response.statusCode == 200) {
    // return Future.delayed(const Duration(seconds: 2),
    //     () => throw Exception('Erro ao buscar posts.'));
    return Future.delayed(
        const Duration(seconds: 2), () => postFromJson(response.body));
    // return postFromJson(response.body);
  } else {
    throw Exception('Erro ao buscar postagens.');
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<User> users = [];
  List<Post> posts = [];
  User? usersDropdownValue;
  Post? postsDropdownValue;
  late bool loadingUsers;
  bool loadingError = false;

  @override
  void initState() {
    super.initState();
    fetchUsersDropdown();
  }

  fetchUsersDropdown() async {
    loadingUsers = true;
    await fetchUsers().then((data) {
      setState(() {
        users = data;
        loadingUsers = false;
      });
    }).onError((error, stackTrace) {
      setState(() {
        loadingUsers = false;
        loadingError = true;
      });
    });
  }

  fetchPostsDropdown(userId) async {
    buildShowDialog(context);
    await fetchPosts(userId).then((data) {
      setState(() {
        posts = data;
        postsDropdownValue = posts[0];
        Navigator.pop(context);
      });
    }).onError((error, stackTrace) {
      setState(() {
        Navigator.pop(context);
        loadingError = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dependent Dropdown Tutorial'),
      ),
      body: Center(
        child: loadingUsers
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : loadingError
                ? const Center(
                    child: Text('Erro ao carregar dados da tela.'),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        DropdownButton(
                          isExpanded: true,
                          hint: const Text('Selecione um usuário'),
                          value: usersDropdownValue,
                          items: users
                              .map<DropdownMenuItem<User>>((user) =>
                                  DropdownMenuItem<User>(
                                      value: user, child: Text(user.name)))
                              .toList(),
                          onChanged: (User? value) => setState(() {
                            usersDropdownValue = value!;
                            fetchPostsDropdown(value.id);
                          }),
                        ),
                        DropdownButton(
                          isExpanded: true,
                          hint: const Text('Selecione um post'),
                          value: postsDropdownValue,
                          items: posts
                              .map<DropdownMenuItem<Post>>((post) =>
                                  DropdownMenuItem<Post>(
                                      value: post, child: Text(post.title)))
                              .toList(),
                          onChanged: (Post? value) => setState(() {
                            postsDropdownValue = value!;
                          }),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

buildShowDialog(BuildContext context) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      });
}
