part of dashboard;

class _HeaderWeeklyTask extends StatelessWidget {
  final BuildContext context;
  const _HeaderWeeklyTask({super.key, required this.context});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const HeaderText("Weekly Task"),
        const Spacer(),
        // _buildArchive(),
        const SizedBox(width: 10),
        // _buildAddNewButton(),
      ],
    );
  }

  Widget _buildAddNewButton() {
    return ElevatedButton.icon(
      icon: const Icon(
        EvaIcons.plus,
        size: 16,
      ),
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AllCalenders()));
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
      ),
      label: const Text("New"),
    );
  }

  Widget _buildArchive() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.grey[850],
        backgroundColor: Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
      ),
      child: const Text("Archive"),
    );
  }
}
