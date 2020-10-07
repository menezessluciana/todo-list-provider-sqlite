
import 'package:flutter/material.dart';
import 'package:todo_list/app/database/connection.dart';

class DatabaseAdmConnection with WidgetsBindingObserver {
  
  //*METODO DISPONIVEL APENAS COM WIDGETSBINDINGOBSERVER
//*É chamado sempre que um state muda

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    var connection = Connection();
    switch(state){
      case AppLifecycleState.resumed:
      //* Não há necessidade de abrir uma conexão quando abre o app e sim abrir conexão sob demanda.
      break;
      case AppLifecycleState.inactive:
      //*Fechar a conexão do banco quando o app ficar inativo evitando que corrompa o BD.
      connection.closeConnection();
      break;
      case AppLifecycleState.paused:
      //*Fechar a conexão do banco quando o app ficar pausado
      connection.closeConnection();
      break;
      case AppLifecycleState.detached:
      //*Fechar a conexão do banco quando o app ficar matado
      connection.closeConnection();
      break;
    }
    super.didChangeAppLifecycleState(state);
  }
}