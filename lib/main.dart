import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/app/database/database_adm_connection.dart';
import 'package:todo_list/app/modules/new_task/new_task_controller.dart';
import 'package:todo_list/app/modules/new_task/new_task_page.dart';

import 'app/database/connection.dart';
import 'app/modules/home/home_controller.dart';
import 'app/modules/home/home_page.dart';
import 'app/repositories/todos_repository.dart';

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  //só da dispose quando o App fecha
  //* WidgetBindingObserver = Fica observando o app, precisa estar em um stateful component
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  DatabaseAdmConnection databaseAdmConnection = DatabaseAdmConnection();
  @override
  void initState() {
    super.initState();
    Connection().instance;
    WidgetsBinding.instance.addObserver(databaseAdmConnection);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(databaseAdmConnection);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //* Quando quero prover para o app todo, tem que envolver o MaterialApp com MultipleProvider ou Provider
    return MultiProvider(
      providers: [
        //prover a instancia para todas as classes
        Provider(create: (_)  => TodosRepository())
      ],
      child: MaterialApp(
        title: 'Todo list',
        theme: ThemeData(
          primaryColor: Color(0xFFFF9129),
          buttonColor: Color(0xFFFF9129),
          textTheme: GoogleFonts.robotoTextTheme().copyWith(),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routes: {
          NewTaskPage.routerName: (_) => ChangeNotifierProvider(
            //* injeção de dependecia(todosrepository)
                create: (context) {
                  //*Pegando o argumento da rota
                  var day = ModalRoute.of(_).settings.arguments;
                   return NewTaskController(repository: _.read<TodosRepository>(), day: day);
                },
                child: NewTaskPage(),
              ),
        },
        home: ChangeNotifierProvider(
          child: HomePage(),
          //*Define qual classe irá ficar escutando, no caso a controller.
          create: (_) {
            //* Recuperando uma instancia de TodosRepository
            //* versão do provider anterior á 4.1
            // var repository = Provider.of<TodosRepository>(_);
            //*Versão do provider a partir da 4.1
            var repository = _.read<TodosRepository>();
            return HomeController(repository: repository);
          } 
        ),
      ),
    );
  }
}
