import 'package:pet_clean/models/alert_model.dart';

//generate 5 fake alerts so we can see them in the alerts page
final List<AlertModel> fakeAlerts = List.generate(
  5,
  (index) => AlertModel(
    id: index,
    title: 'Alerta $index',
    description: 'Descripcion de la alerta $index',
    date: DateTime.now(),
  ),
);


// generate 5 elements for marker_model.dart at 50 m from Latitude: 37.9722803, Longitude: -1.206868

