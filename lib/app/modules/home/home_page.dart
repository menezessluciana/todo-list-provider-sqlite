import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/app/modules/home/home_controller.dart';
import 'package:todo_list/app/modules/new_task/new_task_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _scaffoldKey = GlobalKey<ScaffoldState>();
   void initState() {
    super.initState();
    //*Esse metodo é chamado assim que o build é montado, assim pode utilizar o contexto sem problemas
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //*Verifica as alterações do controllers
      Provider.of<HomeController>(context, listen: false).addListener(() {
        var controller = context.read<HomeController>();

        if (controller.error != null) {
          _scaffoldKey.currentState
              .showSnackBar(SnackBar(content: Text(controller.error)));
        }

        if (controller.deleted) {
          _scaffoldKey.currentState.showSnackBar(
              SnackBar(content: Text('Excluido com sucesso!')));
          Future.delayed(Duration(seconds: 1), () => Navigator.pop(context));
        }
      });
    });
  }

  @override
  void dispose() {
    Provider.of<HomeController>(context, listen: false)
        .removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
        builder: (_, HomeController controller, __) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            'Atividades',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          backgroundColor: Colors.white,
        ),
        bottomNavigationBar: FFNavigationBar(
          selectedIndex: controller.selectedTab,
          onSelectTab: (index) => controller.changeSelectedTab(_, index),
          theme: FFNavigationBarTheme(
            itemWidth: 60,
            barHeight: 70,
            barBackgroundColor: Theme.of(context).primaryColor,
            unselectedItemIconColor: Colors.white,
            unselectedItemLabelColor: Colors.white,
            selectedItemBorderColor: Colors.white,
            selectedItemIconColor: Colors.white,
            selectedItemBackgroundColor: Theme.of(context).primaryColor,
            selectedItemLabelColor: Colors.black,
          ),
          items: [
            FFNavigationBarItem(
                iconData: Icons.check_circle, label: 'Finalizados'),
            FFNavigationBarItem(iconData: Icons.view_week, label: 'Semanal'),
            FFNavigationBarItem(
                iconData: Icons.calendar_today, label: 'Selecionar Data')
          ],
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: ListView.builder(
            itemCount: controller.listTodos?.keys?.length ?? 0,
            itemBuilder: (_, index) {
              var dateFormat = DateFormat('dd/MM/yyyy');
              //*key é interable, não há como pegar pelo indice, e sim com elementAt(index)
              var listTodos = controller.listTodos;
              var dayKey = listTodos.keys.elementAt(index);
              var day = dayKey;
              var todos = listTodos[dayKey];

              if (todos.isEmpty && controller.selectedTab == 0) {
                return Center(
                  child: Text('Sem tarefas para esse dia'),
                );
              }

              var today = DateTime.now();

              if (dayKey == dateFormat.format(today)) {
                day = 'HOJE';
              } else if (dayKey ==
                  dateFormat.format(today.add(Duration(days: 1)))) {
                day = 'AMANHÃ';
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 20),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            day,
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                            onPressed: () async {
                              await Navigator.of(context).pushNamed(
                                  NewTaskPage.routerName,
                                  arguments: dayKey);
                              controller.update();
                            },
                            icon: Icon(
                              Icons.add_circle,
                              size: 30,
                            ),
                            color: Theme.of(context).primaryColor),
                      ],
                    ),
                  ),
                  ListView.builder(
                      //*necessário o uso quando tem uma lista dentro de outra, a lista de fora que controla o tamanho
                      shrinkWrap: true,
                      //*desabilita o scrollview da lista
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: todos.length,
                      itemBuilder: (_, index) {
                        var todo = todos[index];
                        return ListTile(
                          leading: Checkbox(
                            activeColor: Theme.of(context).primaryColor,
                            value: todo.finalizado,
                            onChanged: (bool value) =>
                                controller.checkedOrUncheck(todo),
                          ),
                          title: Text(
                            todo.descricao,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                decoration: todo.finalizado
                                    ? TextDecoration.lineThrough
                                    : null),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${todo.dataHora.hour.toString().padLeft(2, '0')}:${todo.dataHora.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    decoration: todo.finalizado
                                        ? TextDecoration.lineThrough
                                        : null),
                              ),
                              SizedBox(width: 10),
                              IconButton(
                                  onPressed: () async => { 
                                    await controller.deleteTodo(_,todo),
                                    controller.update()
                                    },
                                  icon:
                                      Icon(Icons.delete, color: Colors.black)),
                            ],
                          ),
                        );
                      }),
                ],
              );
            },
          ),
        ),
      );
    });
  }
}
