import 'package:flutter/material.dart';

class EmptyChatWidget extends StatelessWidget {
  const EmptyChatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.chat,
                size: 128,
              ),
              Text('Create or choose a conversation to start')
            ],
          ),
        ),
      )
    );
  }

}