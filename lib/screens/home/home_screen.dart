import 'package:alert_system_for_gaps/screens/dashboard/admin_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../responsive.dart';
import '../dashboard/dashboard_screen.dart';
import 'components/side_menu.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String role = "";

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? newRole = prefs.getString("role");
    print("/////////////////////////// $newRole");
    setState(() {
      role = newRole!;
    });
  }

  final scafoldKey = GlobalKey<ScaffoldState>();

  void openDrawer() {
    if (scafoldKey.currentState != null) {
      scafoldKey.currentState!.openDrawer();
    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scafoldKey,
      //key: context.read<MenuController>().scaffoldKey,
      drawer: const SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideMenu(),
              ),
            Expanded(
              // It takes 5/6 part of the screen
              flex: 5,
              child: role == "admin" ? AdminDashboardScreen(onTap: openDrawer) :
               role == "extension officer" ? DashboardScreen(onTap: openDrawer,) : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
