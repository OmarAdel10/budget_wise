import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class VoiceRecordingOverlay extends StatelessWidget {
  final PlayerController controller;

  const VoiceRecordingOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              AudioWaveforms(
                size: Size(constraints.maxWidth * 0.6, 40),
                recorderController: null, // This would be the recorder controller
                // For now, assume this is for playback or visualization
              ),
              const SizedBox(width: 16),
              const Text('Listening...'),
            ],
          ),
        );
      },
    );
  }
}
