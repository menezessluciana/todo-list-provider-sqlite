import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/app/repositories/todos_repository.dart';

class NewTaskController extends ChangeNotifier {
  //* Valores estáticos ocupam memória
  final formKey = GlobalKey<FormState>();
  final dateFormat = DateFormat('dd/MM/yyyy');
  final TodosRepository repository;
  DateTime daySelected;
  TextEditingController nomeTaskController = TextEditingController();
  bool saved = false;
  bool loading = false;
  String error;

  String get dayFormated => dateFormat.format(daySelected);

  NewTaskController({this.repository, String day}) {
    daySelected = dateFormat.parse(day);
  }

  Future<void> save() async {
    try {
      if (formKey.currentState.validate()) {
            loading = true;
            saved = false;
            // ignore: await_only_futures
            await repository.saveTodo(daySelected, nomeTaskController.text);
            saved = true;
            loading = false;
      }
    } catch (e) {
      error = 'Erro ao salvar todo';
    }
    notifyListeners();
  }
}
