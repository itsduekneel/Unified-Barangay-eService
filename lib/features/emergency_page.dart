import 'package:flutter/material.dart';
import 'package:ube/widgets/emergency_request_caller.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FA),
      appBar: AppBar(
        title: const Text(
          'Services',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F4FA),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF8B2CF5),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
              child: EmergencyRequestCaller(),
            ),
          ],
        ),
      ),
    );
  }
}
