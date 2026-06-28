import 'package:flutter/material.dart';

import '../../../domain/entities/episode.dart';
import '../../episode_player/application/episode_access.dart';

/// Loading/error overlay for a Shorts page. Video playback is handled by [ShortsPage].
class VideoCard extends StatelessWidget {
  const VideoCard({
    super.key,
    required this.episode,
    required this.isActive,
    required this.isLoading,
    required this.hasError,
    required this.access,
    required this.bonusBalance,
    required this.onRetry,
    required this.onUnlock,
    required this.onEarnBonus,
  });

  final Episode episode;
  final bool isActive;
  final bool isLoading;
  final bool hasError;
  final EpisodeAccessState access;
  final int bonusBalance;
  final VoidCallback onRetry;
  final VoidCallback onUnlock;
  final VoidCallback onEarnBonus;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (isActive && access == EpisodeAccessState.vipRequired)
          _LockedOverlay(
            icon: Icons.workspace_premium_rounded,
            title: 'VIP episode',
            subtitle: 'Upgrade to watch this short.',
            buttonLabel: 'Go to rewards',
            onPressed: onEarnBonus,
          )
        else if (isActive && access == EpisodeAccessState.bonusRequired)
          _LockedOverlay(
            icon: Icons.lock_open_rounded,
            title: 'Unlock this episode',
            subtitle:
                '${episode.bonusUnlockCost ?? 0} bonus - Your balance: $bonusBalance',
            buttonLabel: bonusBalance >= (episode.bonusUnlockCost ?? 0)
                ? 'Unlock episode'
                : 'Earn bonus',
            onPressed: bonusBalance >= (episode.bonusUnlockCost ?? 0)
                ? onUnlock
                : onEarnBonus,
          )
        else if (isActive && hasError)
          ColoredBox(
            color: Colors.black,
            child: Center(
              child: FilledButton(
                onPressed: onRetry,
                child: const Text('Tap to retry'),
              ),
            ),
          )
        else if (isActive && isLoading)
          const ColoredBox(
            color: Colors.black,
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

class _LockedOverlay extends StatelessWidget {
  const _LockedOverlay({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFF9B72FF), size: 76),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFC7B8F8),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton.icon(
                  onPressed: onPressed,
                  icon: const Icon(Icons.bolt_rounded),
                  label: Text(buttonLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
