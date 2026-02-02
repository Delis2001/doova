import 'package:flutter/material.dart';

class TaskDescriptionView extends StatelessWidget {
  const TaskDescriptionView({super.key, required this.description});
  final String description;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
            child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: size.width * 0.03,
          ),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.04),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  description,
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        height: 1.4,
                      ),
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}
