import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String userName;
  final String userId;

  const ProfilePage({
    super.key,
    this.userName = "Username",
    this.userId = "12345",
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionTitle("Preferences"),
                  accountTile(
                    icon: Icons.dark_mode_rounded,
                    text: "Dark Mode",
                    onTap: toggleDarkMode,
                  ),
                  const SizedBox(height: 20),
                  sectionTitle("Account"),
                  accountTile(
                    icon: Icons.notifications_none_rounded,
                    text: "Notification",
                  ),
                  accountTile(
                    icon: Icons.delete_outline,
                    text: "Delete Account",
                    iconColor: Colors.red,
                    onTap: () => debugPrint("Delete tapped"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== HEADER =====
  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 40),
      decoration: BoxDecoration(color: const Color(0xFF8B2CF5)),
      child: Center(
        child: Container(
          padding: const EdgeInsets.fromLTRB(30, 20, 30, 10),
          child: profileTile(),
        ),
      ),
    );
  }

  Widget profileTile() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildAvatar(),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              Text(
                widget.userId,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildAvatar({double size = 60}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(Icons.person, color: Color(0xFF8B2CF5), size: 30),
    );
  }

  // ===== SECTION TITLE =====
  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  // ===== ACCOUNT TILE =====
  Widget accountTile({
    required IconData icon,
    required String text,
    Color iconColor = Colors.black,
    void Function()? onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white, // subtle off-white
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2), // thin, soft border
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w500, // subtle but still readable
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
          enabled: false,
        ),
      ),
    );
  }

  // ===== TOGGLE DARK MODE =====
  void toggleDarkMode() {
    setState(() {
      darkMode = !darkMode;
    });
    debugPrint("Dark mode: $darkMode");
  }
}
