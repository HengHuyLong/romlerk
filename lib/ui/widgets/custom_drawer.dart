import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 100), // small top margin
          ListTile(
            leading: Icon(Icons.language, color: AppColors.darkGray),
            title: Text("Change Language"),
          ),
        ],
      ),
    );
  }
}
