import 'package:alert_system_for_gaps/core/constants/color_constants.dart';
import 'package:alert_system_for_gaps/screens/admins/admins.dart';
import 'package:alert_system_for_gaps/screens/calender/calenders.dart';
import 'package:alert_system_for_gaps/screens/extensionOfficer/officers.dart';
import 'package:alert_system_for_gaps/screens/farmers/farmers.dart';
import 'package:alert_system_for_gaps/screens/home/home_screen.dart';
import 'package:alert_system_for_gaps/screens/login/login_screen.dart';
import 'package:alert_system_for_gaps/screens/tasks/tasks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {

  String role = "loading";

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? newRole = prefs.getString("role");
    String? newName = prefs.getString("name");
    print("/////////////////////////// $newRole");
    setState(() {
      role = newRole!;
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        // it enables scrolling
        child: Column(
          children: [
            DrawerHeader(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: defaultPadding,
                ),
                Image.asset(
                  "assets/logo/logo_icon.png",
                  height: 50,
                ),
                SizedBox(
                  height: defaultPadding,
                ),
                richText(5),
              ],
            )),
            DrawerListTile(
              title: "Dashboard",
              svgSrc: "assets/icons/menu_dashbord.svg",
              press: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
              },
            ),
            role == "admin" ?
            DrawerListTile(
              title: "Tasks",
              svgSrc: "assets/icons/menu_tran.svg",
              press: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AllTasks()));
              },
            ) : Container(),
            DrawerListTile(
              title: "Farmers",
              svgSrc: "assets/icons/menu_task.svg",
              press: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AllFarmers()));
              },
            ),
            role == "admin" ?
            DrawerListTile(
              title: "Extension officers",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AllOfficers()));
              },
            ) : Container(),
            role == "admin" ?
            DrawerListTile(
              title: "Admins",
              svgSrc: "assets/icons/menu_store.svg",
              press: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AllAdmins()));
              },
            ) : Container(),

            DrawerListTile(
              title: "Calender",
              svgSrc: "assets/icons/menu_notification.svg",
              press: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AllCalenders()));
              },
            ),
            DrawerListTile(
              title: "logout",
              svgSrc: "assets/icons/menu_setting.svg",
              press: () {
                _showDeleteDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

void _showDeleteDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.clear();

              Navigator.of(context).push(MaterialPageRoute(builder: (context) => Login(title: "Alert System For GAPS")));
            },
            child: const Text('logout'),
          ),
        ],
      );
    },
  );
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        color: Colors.white54,
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}

Widget richText(double fontSize) {
  return Text.rich(
    TextSpan(
      style: GoogleFonts.inter(
        fontSize: 15,
        color: Colors.white,
        letterSpacing: 1.999999953855673,
      ),
      children: const [
        TextSpan(
          text: 'Alert system for ',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        TextSpan(
          text: 'GAPS',
          style: TextStyle(
            color: Color(0xFFFE9879),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}