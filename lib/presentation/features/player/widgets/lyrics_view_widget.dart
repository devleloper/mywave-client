import 'package:flutter/material.dart';

import '../../../../domain/entities/lyrics.dart';

class LyricLine {
  final Duration time;
  final String text;
  LyricLine({required this.time, required this.text});
}

class LyricsViewWidget extends StatefulWidget {
  final Lyrics lyrics;
  final Duration position;

  const LyricsViewWidget({
    super.key,
    required this.lyrics,
    required this.position,
  });

  @override
  State<LyricsViewWidget> createState() => _LyricsViewWidgetState();
}

class _LyricsViewWidgetState extends State<LyricsViewWidget> {
  final ScrollController _scrollController = ScrollController();
  final List<LyricLine> _parsedLyrics = [];
  List<GlobalKey> _keys = [];
  int _currentIndex = -1;

  @override
  void initState() {
    super.initState();
    _parseLyrics();
  }

  void _parseLyrics() {
    if (widget.lyrics.synced != null && widget.lyrics.synced!.isNotEmpty) {
      final lines = widget.lyrics.synced!.split('\n');
      final regExp = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)');
      for (final line in lines) {
        final match = regExp.firstMatch(line);
        if (match != null) {
          final minutes = int.parse(match.group(1)!);
          final seconds = int.parse(match.group(2)!);
          final millisStr = match.group(3)!;
          // Handle both [00:10.00] (centiseconds) and [00:10.000] (milliseconds)
          final milliseconds = millisStr.length == 2 
             ? int.parse(millisStr) * 10 
             : int.parse(millisStr);
          final text = match.group(4)!.trim();
          _parsedLyrics.add(LyricLine(
            time: Duration(minutes: minutes, seconds: seconds, milliseconds: milliseconds),
            text: text,
          ));
        }
      }
      _keys = List.generate(_parsedLyrics.length, (index) => GlobalKey());
    }
  }

  @override
  void didUpdateWidget(LyricsViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lyrics != oldWidget.lyrics) {
      _parsedLyrics.clear();
      _parseLyrics();
      _currentIndex = -1;
    }
    
    if (_parsedLyrics.isNotEmpty) {
      int newIndex = _parsedLyrics.indexWhere((line) => line.time > widget.position) - 1;
      if (newIndex < -1) newIndex = _parsedLyrics.length - 1; // All lines passed
      if (newIndex != _currentIndex) {
        setState(() {
          _currentIndex = newIndex;
        });
        _scrollToCurrent();
      }
    }
  }

  void _scrollToCurrent() {
    if (_currentIndex >= 0 && _scrollController.hasClients && _currentIndex < _keys.length) {
      final key = _keys[_currentIndex];
      
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          alignment: 0.35, // 35% from the top
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      } else {
        // Fallback for seeking (when the target item isn't rendered yet)
        final approximateOffset = (_currentIndex * 60.0) - (MediaQuery.of(context).size.height / 3.0);
        _scrollController.jumpTo(approximateOffset.clamp(0.0, _scrollController.position.maxScrollExtent));
        
        // Correct position precisely once it gets rendered
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && key.currentContext != null) {
            Scrollable.ensureVisible(
              key.currentContext!,
              alignment: 0.35,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_parsedLyrics.isEmpty && widget.lyrics.plain != null) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Text(
            widget.lyrics.plain!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              height: 1.8,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_parsedLyrics.isEmpty) {
      return const Center(
        child: Text(
          "No lyrics available",
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      );
    }

    // Gradient fade at top and bottom of the list view for a cleaner edge
    return ShaderMask(
      shaderCallback: (Rect rect) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black,
            Colors.black,
            Colors.transparent,
          ],
          stops: [0.0, 0.15, 0.85, 1.0],
        ).createShader(rect);
      },
      blendMode: BlendMode.dstIn,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 150, // Space for mini track info and some breathing room
          bottom: MediaQuery.of(context).size.height / 2, // Keep bottom padding so last line can scroll to center
        ),
        physics: const BouncingScrollPhysics(),
        itemCount: _parsedLyrics.length,
        itemBuilder: (context, index) {
          final line = _parsedLyrics[index];
          final isActive = index == _currentIndex;
          final isPassed = index < _currentIndex;

          return Padding(
            key: _keys[index],
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                color: isActive 
                    ? Colors.white 
                    : (isPassed ? Colors.white54 : Colors.white24),
                fontSize: isActive ? 28 : 24,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w700,
                height: 1.3,
                shadows: isActive ? [
                  const BoxShadow(
                    color: Colors.black45,
                    blurRadius: 10,
                  )
                ] : null,
              ),
              child: Text(
                line.text.isEmpty ? "•••" : line.text,
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}
