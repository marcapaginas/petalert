import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_clean/blocs/alerts_cubit.dart';
import 'package:pet_clean/blocs/username_cubit.dart';
import 'package:pet_clean/models/alert_model.dart';
import 'package:pet_clean/pages/alerts.dart';
import 'package:pet_clean/pages/first_page.dart';
import 'package:pet_clean/pages/settings.dart';
import 'package:pet_clean/widgets/custom_switch.dart';
import 'package:pet_clean/widgets/mapa.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // _pageController.animateToPage(index,
      //     duration: Duration(milliseconds: 300), curve: Curves.ease);
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final usernameCubit = context.watch<UsernameCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('PetAlert'),
        actions: const [CustomSwitch()],
        backgroundColor: Colors.green,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: <Widget>[
          Container(
            color: Colors.blue,
            child: const FirstPage(),
          ),
          Container(
            color: Colors.green,
            padding: const EdgeInsets.all(20),
            child: const Mapa(),
          ),
          Container(
            color: Colors.green,
            child: const Alerts(),
          ),
          Container(
            color: Colors.red,
            child: const Center(
              child: Settings(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BlocBuilder<AlertsCubit, List<AlertModel>>(
        builder: (context, state) {
          return NavigationBar(
            backgroundColor: Colors.white24,
            onDestinationSelected: _onItemTapped,
            indicatorColor: Colors.greenAccent,
            selectedIndex: _selectedIndex,
            destinations: <NavigationDestination>[
              const NavigationDestination(
                selectedIcon: Icon(Icons.home),
                icon: Icon(Icons.home_outlined),
                label: 'Inicio',
              ),
              const NavigationDestination(
                icon: Icon(Icons.map),
                label: 'Mapa',
              ),
              NavigationDestination(
                icon: state.isNotEmpty
                    ? Badge(
                        label: Text(state.length.toString()),
                        child: const Icon(Icons.notifications_sharp))
                    : const Icon(Icons.notifications_none),
                label: 'Alertas',
              ),
              const NavigationDestination(
                icon: Icon(Icons.settings),
                label: 'Opciones',
              ),
            ],
          );
        },
      ),
    );
  }
}
