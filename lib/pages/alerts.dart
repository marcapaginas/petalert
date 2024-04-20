import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_clean/blocs/alerts_cubit.dart';
import 'package:pet_clean/models/alert_model.dart';
import 'package:pet_clean/sample_data.dart';

class Alerts extends StatefulWidget {
  const Alerts({super.key});

  @override
  State<Alerts> createState() => _AlertsState();
}

class _AlertsState extends State<Alerts> {
  @override
  Widget build(BuildContext context) {
    final alertsCubit = context.watch<AlertsCubit>();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AlertModel newAlert = AlertModel(
            id: alertsCubit.state.length + 1,
            title: 'Alerta ${alertsCubit.state.length + 1}',
            description:
                'Descripción de la alerta ${alertsCubit.state.length + 1}',
            date: DateTime.now(),
          );
          setState(() {
            alertsCubit.addAlert(newAlert);
          });
        },
        child: const Icon(Icons.add),
      ),
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        itemCount: alertsCubit.state.length,
        itemBuilder: (context, index) {
          AlertModel item = alertsCubit.state[index];
          var title = item.title;

          return Dismissible(
            key: Key(item.id.toString()),
            direction: DismissDirection.startToEnd,
            onDismissed: (direction) {
              setState(() {
                alertsCubit.removeAlert(item);
              });

              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(' Quitada alerta: $title')));
            },
            // Show a red background as the item is swiped away.
            background: Container(
              alignment: AlignmentDirectional.centerStart,
              color: Colors.transparent,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 8.0), // Agrega margen alrededor del ListTile
              decoration: BoxDecoration(
                color: Colors.white, // Establece el color de fondo a gris
                borderRadius:
                    BorderRadius.circular(10.0), // Redondea los bordes
              ),
              child: ListTile(
                title: Text(alertsCubit.state[index].title),
                subtitle: Text(alertsCubit.state[index].description),
              ),
            ),
          );
        },
      ),
    );
  }
}
