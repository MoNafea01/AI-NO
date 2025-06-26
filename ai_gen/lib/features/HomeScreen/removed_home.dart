import 'package:flutter/material.dart';



class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fullNameFirstController = TextEditingController(text: "mohamed");
    final fullNameLastController = TextEditingController(text: "nofal");
    final usernameController = TextEditingController(text: "mohamedNofal");
    final emailController =
        TextEditingController(text: "mohamedNofal123@mail.com");
    final jobTitleController = TextEditingController(text: "Software engineer");
    final countryController = TextEditingController(text: "Egypt");
    final bioController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text("Name:", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: fullNameFirstController,
                      hintText: 'First name',
                      icon: Icons.person,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: fullNameLastController,
                      hintText: 'Last name',
                      icon: Icons.person,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text("Username:", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: usernameController,
                icon: Icons.person,
              ),
              const SizedBox(height: 20),
              const Text("Email Address:", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: emailController,
                icon: Icons.email,
              ),
              const SizedBox(height: 20),
              const Text("Job Title:", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: jobTitleController,
                icon: Icons.work,
              ),
              const SizedBox(height: 20),
              const Text("Country:", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: countryController,
                icon: Icons.location_on,
              ),
              const SizedBox(height: 20),
              const Text("Bio:", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              TextFormField(
                controller: bioController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write about yourself',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                  onPressed: () {
                    // Save logic here
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Changes saved")),
                    );
                  },
                  child: const Text("Save changes"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final IconData? icon;

  const CustomTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText ?? controller.text,
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
