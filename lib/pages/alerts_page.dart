import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_clean/blocs/alerts_cubit.dart';
import 'package:pet_clean/blocs/user_data_cubit.dart';
import 'package:pet_clean/database/redis_database.dart';
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
    final userDataCubit = context.watch<UserDataCubit>();

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'Alertas',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Divider(
          thickness: 1,
          indent: 20,
          endIndent: 20,
          color: Colors.black,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Notificar en segundo plano: ',
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
            Switch(
              inactiveTrackColor: MaterialStateColor.resolveWith(
                  (states) => Colors.white.withOpacity(0.3)),
              trackOutlineColor: MaterialStateProperty.resolveWith(
                  (states) => Colors.white.withOpacity(0.3)),
              activeColor:
                  MaterialStateColor.resolveWith((states) => Colors.white),
              inactiveThumbColor: MaterialStateColor.resolveWith(
                  (states) => Colors.white.withOpacity(0.2)),
              thumbIcon: MaterialStateProperty.resolveWith(
                  (states) => const Icon(Icons.notifications_active)),
              value: userDataCubit.state.backgroundNotify,
              onChanged: (value) {
                userDataCubit.switchBackgroundNotify();
                RedisDatabase().storeUserData(userDataCubit.state);
              },
            ),
          ],
        ),
        const Divider(
          thickness: 1,
          indent: 20,
          endIndent: 20,
          color: Colors.black,
        ),
        alertsCubit.notDiscardedAlerts.length == 0
            ? const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Icon(
                          Icons.notifications_off,
                          size: 50.0,
                        ),
                      ),
                      Text('No hay alertas'),
                    ],
                  ),
                ),
              )
            : Expanded(
                child: ListView.builder(
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
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Borrada alerta: $title')));
                        },
                        background: Container(
                          alignment: AlignmentDirectional.centerStart,
                          color: Colors.transparent,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 30.0),
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
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 20.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          child: ListTile(
                            leading: Icon(Icons.notifications_active), // Icono
                            title: Text(alertsCubit
                                .notDiscardedAlerts[index].title), // Título
                            subtitle: Text(alertsCubit.notDiscardedAlerts[index]
                                .description), // Texto
                          ),
                        ),
                      ),
                    );
                  },
                  //),
                ),
              ),
      ],
    );
  }
}
