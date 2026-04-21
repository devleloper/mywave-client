import 'dart:async';
import 'package:flutter/material.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration pauseDuration;
  final double scrollVelocity; // pixels per second

  const MarqueeText({
    super.key,
    required this.text,
    required this.style,
    this.pauseDuration = const Duration(seconds: 3),
    this.scrollVelocity = 25.0, // Reduced speed for smoother reading
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> {
  late ScrollController _scrollController;
  Timer? _timer;
  bool _isScrolling = false;
  double _loopWidth = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      _timer?.cancel();
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      _loopWidth = 0.0;
      _isScrolling = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startScrolling(double loopWidth) {
    if (!mounted || !_scrollController.hasClients) return;

    if (loopWidth > 0) {
      _loopWidth = loopWidth;
      setState(() => _isScrolling = true);
      _scheduleScroll();
    } else {
      setState(() => _isScrolling = false);
    }
  }

  void _scheduleScroll() {
    _timer?.cancel();
    _timer = Timer(widget.pauseDuration, () async {
      if (!mounted || !_scrollController.hasClients) return;

      final actualDuration = Duration(
        milliseconds: (_loopWidth / widget.scrollVelocity * 1000).toInt(),
      );

      await _scrollController.animateTo(
        _loopWidth,
        duration: actualDuration,
        curve: Curves.linear,
      );

      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.jumpTo(0.0);
      _scheduleScroll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();

        final isOverflowing = textPainter.width > constraints.maxWidth;
        final double textWidth = textPainter.width;
        final double gap = 40.0;
        final double loopWidth = textWidth + gap;

        if (isOverflowing && _loopWidth != loopWidth) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _startScrolling(loopWidth);
          });
        } else if (!isOverflowing && _isScrolling) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _startScrolling(0);
          });
        }

        Widget content = SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: DefaultTextStyle(
            style: widget.style,
            child: isOverflowing
                ? Row(
                    children: [
                      Text(widget.text, maxLines: 1, softWrap: false),
                      SizedBox(width: gap),
                      Text(widget.text, maxLines: 1, softWrap: false),
                      SizedBox(width: gap),
                      Text(widget.text, maxLines: 1, softWrap: false),
                    ],
                  )
                : Text(widget.text, maxLines: 1, softWrap: false),
          ),
        );

        if (isOverflowing || _isScrolling) {
          content = ShaderMask(
            shaderCallback: (rect) {
              final fadeStop = (24.0 / constraints.maxWidth).clamp(0.0, 0.5);
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: const [
                  Colors.transparent,
                  Colors.black,
                  Colors.black,
                  Colors.transparent,
                ],
                stops: [0.0, fadeStop, 1.0 - fadeStop, 1.0],
              ).createShader(rect);
            },
            blendMode: BlendMode.dstIn,
            child: content,
          );
        }

        return SizedBox(
          width: constraints.maxWidth,
          child: content,
        );
      },
    );
  }
}
