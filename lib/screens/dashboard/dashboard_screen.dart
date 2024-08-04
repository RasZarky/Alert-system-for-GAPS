import 'package:alert_system_for_gaps/core/constants/color_constants.dart';
import 'package:alert_system_for_gaps/responsive.dart';
import 'package:alert_system_for_gaps/screens/dashboard/components/mini_information_card.dart';
import 'package:alert_system_for_gaps/screens/dashboard/components/recent_forums.dart';
import 'package:alert_system_for_gaps/screens/dashboard/components/recent_users.dart';
import 'package:alert_system_for_gaps/screens/dashboard/components/user_details_widget.dart';
import 'package:alert_system_for_gaps/screens/offficerHomePage/views/screens/officer_dashboard_screen.dart';
import 'package:flutter/material.dart';

import 'components/header.dart';

class DashboardScreen extends StatefulWidget {
  void Function() onTap;
  DashboardScreen({
    Key? key,required this.onTap
  }) : super(key: key);
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
              Header(onTap: widget.onTap,),
              const SizedBox(height: defaultPadding),
              const OfficerDashboardScreen(),
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
