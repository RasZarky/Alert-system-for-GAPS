import 'package:alert_system_for_gaps/core/constants/color_constants.dart';
import 'package:alert_system_for_gaps/responsive.dart';
import 'package:alert_system_for_gaps/screens/dashboard/components/header.dart';
import 'package:alert_system_for_gaps/screens/dashboard/components/mini_information_card.dart';
import 'package:alert_system_for_gaps/screens/dashboard/components/recent_forums.dart';
import 'package:alert_system_for_gaps/screens/dashboard/components/recent_users.dart';
import 'package:alert_system_for_gaps/screens/dashboard/components/user_details_widget.dart';
import 'package:flutter/material.dart';


class AdminDashboardScreen extends StatefulWidget {
  void Function() onTap;
  AdminDashboardScreen({
    super.key,required this.onTap
  });
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        //padding: EdgeInsets.all(defaultPadding),
        child: Container(
          padding: EdgeInsets.all(defaultPadding),
          child:
          Column(
            children: [
              Header(onTap: widget.onTap),
              SizedBox(height: defaultPadding),
              Center(
                child: Text("Admin Page"),
              )
              // MiniInformation(),
              // SizedBox(height: defaultPadding),
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     Expanded(
              //       flex: 5,
              //       child: Column(
              //         children: [
              //           //MyFiels(),
              //           //SizedBox(height: defaultPadding),
              //           RecentUsers(),
              //           SizedBox(height: defaultPadding),
              //           RecentDiscussions(),
              //           if (Responsive.isMobile(context))
              //             SizedBox(height: defaultPadding),
              //           if (Responsive.isMobile(context)) UserDetailsWidget(),
              //         ],
              //       ),
              //     ),
              //     if (!Responsive.isMobile(context))
              //       SizedBox(width: defaultPadding),
              //     // On Mobile means if the screen is less than 850 we dont want to show it
              //     if (!Responsive.isMobile(context))
              //       Expanded(
              //         flex: 2,
              //         child: UserDetailsWidget(),
              //       ),
              //   ],
              // )
            ],
          )
          ,
        ),
      ),
    );
  }
}
