import 'package:flutter/material.dart';
import 'package:todo_list/app/models/todo_model.dart';
import 'package:todo_list/app/repositories/todos_repository.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

class HomeController extends ChangeNotifier {
  String nome = 'Luciana';

  final formKey = GlobalKey<FormState>();
  final TodosRepository repository;
  int selectedTab = 1;
  DateTime daySelected = DateTime.now();
  var dateFormat = DateFormat('dd/MM/yyyy');
  DateTime startFilter;
  DateTime endFilter;
  Map<String, List<TodoModel>> listTodos;
  bool loading = false;
  String error;
  bool deleted = false;

  HomeController({@required this.repository}) {
    findAllForWeek();
    // repository.saveTodo(DateTime.now().subtract(Duration(days: 2)), 'nova task');
  }

  Future<void> changeSelectedTab(BuildContext context, int index) async {
    selectedTab = index;
    switch (index) {
      case 0:
        filterFinalized();
        break;
      case 1:
        findAllForWeek();
        break;
      case 2:
        var day = await showDatePicker(
            context: context,
            initialDate: daySelected,
            firstDate: DateTime.now().subtract(Duration(days: (360 * 3))),
            lastDate: DateTime.now().add(Duration(days: (360 * 10))));

        if (day != null) {
          daySelected = day;
          findTodosBySelectedDay();
        }
        break;
    }
    notifyListeners();
  }

  Future<void> findAllForWeek() async {
    daySelected = DateTime.now();

    startFilter = DateTime.now();
    if (startFilter.weekday != DateTime.monday) {
      //* Se o dia for 7, 7-6 = 1(primeiro dia da semana)
      startFilter =
          startFilter.subtract(Duration(days: (startFilter.weekday - 1)));
    }
    endFilter = startFilter.add(Duration(days: 6));

    var todos = await repository.findByPeriod(startFilter, endFilter);

    if (todos.isEmpty) {
      //* Se a lista estiver vazia, adiciona o cabeçalho com o dia de hoje, se não, não será possivel adicionar tasks
      listTodos = {dateFormat.format(DateTime.now()): []};
    } else {
      //* package collection - groupby - agrupando por data
      listTodos =
          groupBy(todos, (TodoModel todo) => dateFormat.format(todo.dataHora));
    }

    this.notifyListeners();
  }

  void checkedOrUncheck(TodoModel todo) {
    todo.finalizado = !todo.finalizado;
    this.notifyListeners();
    repository.checkOrUnchedTodo(todo);
  }

  void filterFinalized() {
    listTodos = listTodos.map((key, value) {
      print('key $key');
      print('key $value');
      var todosFinalized = value.where((t) => t.finalizado).toList();
      return MapEntry(key, todosFinalized);
    });
    print('listTodo MapEntry $listTodos');
    this.notifyListeners();
  }

  Future<void> findTodosBySelectedDay() async {
    var todos = await repository.findByPeriod(daySelected, daySelected);

    if (todos.isEmpty) {
      //* Se a lista estiver vazia, adiciona o cabeçalho com o dia de hoje, se não, não será possivel adicionar tasks
      listTodos = {dateFormat.format(daySelected): []};
    } else {
      //* package collection - groupby - agrupando por data
      listTodos =
          groupBy(todos, (TodoModel todo) => dateFormat.format(todo.dataHora));
    }
    this.notifyListeners();
  }

  void update() {
    if (selectedTab == 1) {
      this.findAllForWeek();
    } else if (selectedTab == 2) {
      print('selected tab 2');
      this.findTodosBySelectedDay();
    }
  }

  Future<void> deleteTodo(BuildContext context, TodoModel todo) async {
    var deleteCheckAnswer;
    Widget cancelButton = FlatButton(
      child: Text("Cancelar"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Continar"),
      onPressed: () {
        deleteCheckAnswer = true;
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Deseja realmente excluir?"),
      content: Text("Essa ação não pode ser desfeita."),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    try {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
      if (deleteCheckAnswer) {
        loading = true;
        await repository.deleteTodo(todo);
        print('sucesso');
        loading = false;
        deleted = true;
        notifyListeners();
      } else{
      }
    } catch (e) {
      error = 'Erro ao salvar todo';
      print('erro delete todo $e');
    }
  }
}
