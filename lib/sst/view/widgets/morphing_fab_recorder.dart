import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'voice_recording_overlay.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class MorphingFabRecorder extends StatelessWidget {
  const MorphingFabRecorder({super.key});

  Future<bool> _requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      openBuilder: (context, closeContainer) => Scaffold(
        body: Center(
          child: VoiceRecordingOverlay(
            controller: PlayerController(), // Placeholder
          ),
        ),
      ),
      closedBuilder: (context, openContainer) => FloatingActionButton(
        onPressed: () async {
          if (await _requestPermission()) {
            openContainer();
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Microphone permission required')),
              );
            }
          }
        },
        child: const Icon(Icons.mic),
      ),
    );
  }
}
