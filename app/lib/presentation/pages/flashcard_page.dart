import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../data/repositories/study_store.dart';
import '../../domain/models/card_models.dart';

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({
    required this.store,
    this.category,
    this.level,
    this.deckId,
    super.key,
  });
  final StudyStore store;
  final CardCategory? category;
  final CardLevel? level;
  final String? deckId;
  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage>
    with SingleTickerProviderStateMixin {
  CardFilter filter = CardFilter.all;
  bool random = true;
  bool _isBack = false;
  int index = 0;
  late List<StudyCard> cards;
  late final AnimationController _flipController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  late final CurvedAnimation _flipAnimation = CurvedAnimation(
    parent: _flipController,
    curve: Curves.easeInOutCubic,
  );

  StudyDeck get deck {
    if (widget.deckId != null) {
      final found = widget.store.deckById(widget.deckId!);
      if (found != null) return found;
    }
    return widget.store.builtInDeck(
      widget.category ?? CardCategory.kotoba,
      widget.level ?? CardLevel.n5,
    );
  }

  CardCategory get category => deck.category;
  CardLevel get level => deck.level;

  double get _scale => widget.store.settings.flashcardTextScale;

  @override
  void initState() {
    super.initState();
    filter = widget.store.settings.lastFilters[deck.id] ?? CardFilter.all;
    _refresh();
  }

  @override
  void dispose() {
    _flipAnimation.dispose();
    _flipController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    setState(() => _isBack = !_isBack);
    if (_isBack) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  void _resetFlip() {
    _isBack = false;
    _flipController.value = 0;
  }

  bool _matchesFilter(StudyCard card) {
    final item = widget.store.progressFor(card.id);
    return switch (filter) {
      CardFilter.all => true,
      CardFilter.unseen => !item.memorized,
      CardFilter.memorized => item.memorized,
      CardFilter.difficult => item.difficult,
    };
  }

  void _refresh({bool resetIndex = false}) {
    final previous = index;
    final all = widget.store.cardsForDeck(deck);
    cards = all.where(_matchesFilter).toList();
    if (random) cards.shuffle(Random());
    index = cards.isEmpty || resetIndex
        ? 0
        : min(previous, cards.length - 1);
    _resetFlip();
  }

  Future<void> _editCurrentCard() async {
    if (cards.isEmpty) return;
    final card = cards[min(index, cards.length - 1)];
    await Navigator.pushNamed(
      context,
      AppRoutes.cardEditor,
      arguments: {'deckId': deck.id, 'cardId': card.id},
    );
    if (!mounted) return;
    setState(_refresh);
  }

  void _setFilter(CardFilter value) {
    setState(() {
      filter = value;
      widget.store.settings.lastFilters[deck.id] = value;
      _refresh(resetIndex: true);
    });
    widget.store.save();
  }

  void _toggleRandom() {
    setState(() {
      random = !random;
      _refresh(resetIndex: true);
    });
  }

  void _previous() {
    if (index == 0) return;
    setState(() {
      index--;
      _resetFlip();
    });
  }

  void _next() {
    if (index >= cards.length - 1) return;
    setState(() {
      index++;
      _resetFlip();
    });
  }

  void _mark({bool? memorized, bool? difficult}) {
    if (cards.isEmpty) return;
    final card = cards[index];
    final item = widget.store.progressFor(card.id);
    setState(() {
      if (memorized != null) {
        item.memorized = memorized;
        if (memorized) item.difficult = false;
      }
      if (difficult != null) item.difficult = difficult;
    });
    widget.store.recordCard(card);
    widget.store.save();
    if (!_matchesFilter(card)) {
      setState(() {
        cards.removeAt(index);
        if (index >= cards.length) index = cards.length - 1;
        if (index < 0) index = 0;
        _resetFlip();
      });
    }
  }

  double _frontFontSize(StudyCard card) {
    final length = card.front.length;
    final double base;
    if (card.category == CardCategory.kotoba) {
      base = 32;
    } else if (card.category == CardCategory.kanji && length <= 2) {
      base = 96;
    } else if (length <= 6) {
      base = 72;
    } else if (length <= 12) {
      base = 52;
    } else if (length <= 24) {
      base = 36;
    } else {
      base = 26;
    }
    return base * _scale;
  }

  TextStyle _baseStyle(double size, {FontWeight? weight, Color? color}) =>
      TextStyle(
        fontSize: size,
        color: color ?? AppPalette.of(context).textPrimary,
        fontWeight: weight,
        height: 1.25,
      );

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final current = cards.isEmpty ? null : cards[index];
    return Scaffold(
      appBar: AppBar(
        title: Text(deck.name),
        actions: [
          IconButton(
            tooltip: 'Edit kartu',
            icon: const Icon(Icons.edit_outlined),
            onPressed: cards.isEmpty ? null : _editCurrentCard,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final item in CardFilter.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_filterLabel(item)),
                        selected: filter == item,
                        onSelected: (_) => _setFilter(item),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (current == null)
              AppCard(child: const Text('Belum ada kartu pada filter ini.'))
            else ...[
              Row(
                children: [
                  Text(
                    '${index + 1} / ${cards.length}',
                    style: textTheme.bodySmall?.copyWith(
                      color: palette.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  FilterChip(
                    avatar: Icon(
                      Icons.shuffle,
                      size: 18,
                      color: random
                          ? Theme.of(context).colorScheme.onPrimary
                          : palette.textSecondary,
                    ),
                    label: const Text('Acak'),
                    selected: random,
                    onSelected: (_) => _toggleRandom(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildCard(current),
            ],
          ],
        ),
      ),
      bottomNavigationBar: current == null ? null : _buildBottomBar(current),
    );
  }

  Widget _buildCard(StudyCard current) {
    final front = _buildFront(current);
    final back = Column(
      key: const ValueKey('back'),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: _buildBackChildren(current),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleFlip,
      child: AppCard(
        padding: EdgeInsets.zero,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 280),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: Alignment.center,
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  final showBack = _flipAnimation.value >= 0.5;
                  final angle = _flipAnimation.value * pi;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0015)
                      ..rotateY(angle),
                    child: showBack
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(pi),
                            child: back,
                          )
                        : front,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFront(StudyCard current) {
    final front = Column(
      key: const ValueKey('front'),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          current.front,
          textAlign: TextAlign.center,
          softWrap: true,
          style: _baseStyle(
            _frontFontSize(current),
            weight: current.category == CardCategory.kanji
                ? null
                : FontWeight.w600,
          ),
        ),
        if (current.category == CardCategory.kotoba &&
            current.reading.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            current.reading,
            textAlign: TextAlign.center,
            softWrap: true,
            style: _baseStyle(24 * _scale, color: AppPalette.of(context).textSecondary),
          ),
        ],
      ],
    );

    return current.category == CardCategory.kotoba
        ? FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: front,
          )
        : front;
  }

  List<Widget> _buildBackChildren(StudyCard current) {
    final palette = AppPalette.of(context);
    final settings = widget.store.settings;
    final readingStyle = _baseStyle(22 * _scale);
    final meaningStyle = _baseStyle(
      28 * _scale,
      weight: current.category == CardCategory.kanji
          ? null
          : FontWeight.w600,
    );
    final exampleStyle = _baseStyle(16 * _scale, color: palette.textSecondary);

    Widget label(String text) => Text(
      text,
      textAlign: TextAlign.center,
      style: _baseStyle(
        12 * _scale,
        weight: FontWeight.w500,
        color: palette.textMuted,
      ).copyWith(letterSpacing: 0.8),
    );

    Widget front() => Text(
      current.front,
      textAlign: TextAlign.center,
      softWrap: true,
      style: _baseStyle(
        _frontFontSize(current),
        weight: current.category == CardCategory.kanji
            ? null
            : FontWeight.w600,
      ),
    );

    Widget meaning() => Text(
      current.meaning,
      textAlign: TextAlign.center,
      softWrap: true,
      style: meaningStyle,
    );

    final exampleText = settings.showExamples && current.example.isNotEmpty
        ? current.example
        : null;

    switch (current.category) {
      case CardCategory.kanji:
        final parts = current.reading
            .split('/')
            .map((part) => part.trim())
            .where((part) => part.isNotEmpty)
            .toList();
        final kunyomi = parts.length > 1
            ? parts[1]
            : (parts.isNotEmpty ? parts[0] : null);
        final onyomi = parts.length > 1 ? parts[0] : null;
        return [
          if (kunyomi != null && kunyomi.isNotEmpty) ...[
            label('Kunyomi'),
            Text(
              kunyomi,
              textAlign: TextAlign.center,
              softWrap: true,
              style: readingStyle,
            ),
          ],
          if (onyomi != null && settings.showOnyomi) ...[
            const SizedBox(height: 4),
            label('Onyomi'),
            Text(
              onyomi,
              textAlign: TextAlign.center,
              softWrap: true,
              style: readingStyle,
            ),
          ],
          const SizedBox(height: 16),
          front(),
          const SizedBox(height: 16),
          meaning(),
          if (exampleText != null) ...[
            const SizedBox(height: 12),
            Text(
              exampleText,
              textAlign: TextAlign.center,
              softWrap: true,
              style: exampleStyle,
            ),
          ],
        ];
      case CardCategory.kotoba:
        return [meaning()];
    }
  }

  Widget _buildBottomBar(StudyCard current) {
    final palette = AppPalette.of(context);
    final difficult = widget.store.progressFor(current.id).difficult;
    final memorized = widget.store.progressFor(current.id).memorized;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: palette.surface1,
          border: Border(top: BorderSide(color: palette.divider)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      foregroundColor: difficult
                          ? palette.warning
                          : palette.textPrimary,
                      side: BorderSide(
                        color: difficult
                            ? palette.warning.withValues(alpha: 0.5)
                            : palette.borderSubtle,
                      ),
                    ),
                    onPressed: () => _mark(difficult: !difficult),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          difficult ? Icons.flag : Icons.flag_outlined,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            difficult ? 'Susah ✓' : 'Susah',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [palette.primaryHover, palette.primary],
                      ),
                      boxShadow: palette.primaryGlow,
                    ),
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        backgroundColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: () => _mark(memorized: !memorized),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            memorized ? Icons.undo : Icons.check_circle_outline,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              memorized ? 'Batalkan hafal' : 'Sudah hafal',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onPressed: index == 0 ? null : _previous,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Sebelumnya'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onPressed: index >= cards.length - 1 ? null : _next,
                    icon: const Icon(Icons.chevron_right),
                    iconAlignment: IconAlignment.end,
                    label: const Text('Berikutnya'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _filterLabel(CardFilter value) => switch (value) {
    CardFilter.all => 'Semua',
    CardFilter.unseen => 'Belum hafal',
    CardFilter.memorized => 'Sudah hafal',
    CardFilter.difficult => 'Susah',
  };

}
