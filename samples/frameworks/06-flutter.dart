import 'package:flutter/material.dart';

/// Flutter framework tour.
///
/// Covers StatelessWidget, StatefulWidget, build methods, named
/// arguments, theming, layout widgets, keys and lifecycle hooks.
class ArticleCard extends StatelessWidget {
  const ArticleCard({
    super.key,
    required this.title,
    required this.likeCount,
    this.subtitle,
    this.onTap,
  });

  final String title;
  final int likeCount;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: theme.textTheme.titleLarge, maxLines: 2),
              if (subtitle != null) // inline comment
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Icon(Icons.favorite, size: 18, color: theme.colorScheme.primary),
                  Text('$likeCount likes'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A stateful counter demonstrating the widget lifecycle.
class LikeButton extends StatefulWidget {
  const LikeButton({super.key, this.initial = 0});

  final int initial;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late int _count = widget.initial;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _increment() => setState(() => _count += 1);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.thumb_up),
      tooltip: 'Like',
      onPressed: _increment,
    );
  }
}
