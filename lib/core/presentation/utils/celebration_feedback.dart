import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Short celebration SFX + haptics that mix with story playback audio.
///
/// Shared across XP toast / streak celebration so we don't spin up multiple
/// low-latency players.
abstract final class CelebrationFeedback {
  static AudioPlayer? _sfxPlayer;
  static bool _sfxReady = false;

  /// Streak celebration horn (checked in under `assets/sounds/`).
  static const streakSoundAsset = 'sounds/Streak-horns.wav';

  /// Badge celebration horn (checked in under `assets/sounds/`).
  static const badgeSoundAsset = 'sounds/badge-horns.wav';

  /// XP toast chime — enable once `xp_earned.mp3` is added.
  static const xpSoundAsset = 'sounds/xp-earned.wav';
  static const xpSoundEnabled = true;

  static Future<void> streak() =>
      play(soundAsset: streakSoundAsset, haptic: HapticFeedback.heavyImpact);

  static Future<void> badge() =>
      play(soundAsset: badgeSoundAsset, haptic: HapticFeedback.mediumImpact);

  static Future<void> xp() => play(
    soundAsset: xpSoundEnabled ? xpSoundAsset : null,
    haptic: HapticFeedback.mediumImpact,
  );

  static Future<void> play({
    String? soundAsset,
    Future<void> Function()? haptic,
  }) async {
    if (haptic != null) {
      try {
        await haptic();
      } catch (stackTrace) {
        debugPrint('Error playing haptic: ${stackTrace.toString()}');
      }
    }

    if (soundAsset == null || soundAsset.isEmpty) return;

    try {
      final player = await _ensureSfxPlayer();
      await player.stop();
      await player.play(AssetSource(soundAsset, mimeType: 'audio/wav'));
    } catch (stackTrace) {
      // Missing asset or session conflict — never break the celebration UI.
      debugPrint('Error playing sound: ${stackTrace.toString()}');
    }
  }

  static Future<AudioPlayer> _ensureSfxPlayer() async {
    if (_sfxPlayer != null && _sfxReady) return _sfxPlayer!;

    final player = _sfxPlayer ??= AudioPlayer();
    await player.setPlayerMode(PlayerMode.lowLatency);
    await player.setReleaseMode(ReleaseMode.stop);
    await player.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          // playback + mixWithOthers: plays over story audio without
          // stealing focus. (respectSilence cannot be combined with this.)
          category: AVAudioSessionCategory.playback,
          options: const {AVAudioSessionOptions.mixWithOthers},
        ),
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          audioFocus: AndroidAudioFocus.none,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.assistanceSonification,
          audioMode: AndroidAudioMode.normal,
        ),
      ),
    );
    _sfxReady = true;
    return player;
  }
}
