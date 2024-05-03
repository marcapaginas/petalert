import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_clean/blocs/alerts_cubit.dart';
import 'package:pet_clean/models/alert_model.dart';

class Alerts extends StatefulWidget {
  const Alerts({super.key});

  @override
  State<Alerts> createState() => _AlertsState();
}

class _AlertsState extends State<Alerts> {
  @override
  Widget build(BuildContext context) {
    final alertsCubit = context.watch<AlertsCubit>();

    return ListView.builder(
      itemCount: alertsCubit.notDiscardedAlerts.length,
      itemBuilder: (context, index) {
        AlertModel item = alertsCubit.notDiscardedAlerts[index];
        var title = item.title;

        return InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            '/alert_detail',
            arguments: item,
          ),
          child: Dismissible(
            key: Key(item.id),
            direction: DismissDirection.startToEnd,
            onDismissed: (direction) {
              setState(() {
                alertsCubit.markAsDiscarded(item.id);
              });

              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Borrada alerta: $title')));
            },
            background: Container(
              alignment: AlignmentDirectional.centerStart,
              color: Colors.transparent,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      'Borrar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            child: Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                title: Text(alertsCubit.notDiscardedAlerts[index].title),
                subtitle:
                    Text(alertsCubit.notDiscardedAlerts[index].description),
              ),
            ),
          ),
        );
      },
      //),
    );
  }
}
