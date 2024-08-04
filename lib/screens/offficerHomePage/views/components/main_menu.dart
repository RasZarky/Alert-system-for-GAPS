part of '../screens/dashboard_screen.dart';

class _MainMenu extends StatelessWidget {
  const _MainMenu({
    required this.onSelected,
    Key? key,
  }) : super(key: key);

  final Function(int index, SelectionButtonData value) onSelected;

  @override
  Widget build(BuildContext context) {
    return SelectionButton(
      data: [
        SelectionButtonData(
          activeIcon: EvaIcons.home,
          icon: EvaIcons.homeOutline,
          label: "Home",
        ),
        // SelectionButtonData(
        //   activeIcon: EvaIcons.bell,
        //   icon: EvaIcons.bellOutline,
        //   label: "Notifications",
        // ),
        SelectionButtonData(
          activeIcon: EvaIcons.checkmarkCircle2,
          icon: EvaIcons.checkmarkCircle,
          label: "Task",
        ),
        SelectionButtonData(
          activeIcon: EvaIcons.calendar,
          icon: EvaIcons.calendarOutline,
          label: "Student Appointments",
        ),
        SelectionButtonData(
          activeIcon: EvaIcons.person,
          icon: EvaIcons.personOutline,
          label: "Profile",
        ),
        SelectionButtonData(
          activeIcon: EvaIcons.messageCircle,
          icon: EvaIcons.messageCircleOutline,
          label: "Chat",
          totalNotif: 4,
        ),
        SelectionButtonData(
          activeIcon: EvaIcons.logOut,
          icon: EvaIcons.logOutOutline,
          label: "Logout",
        ),
      ],
      onSelected: onSelected,
    );
  }
}
