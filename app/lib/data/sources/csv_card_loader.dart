import '../../domain/models/card_models.dart';

class CsvCardLoader {
  const CsvCardLoader();

  List<StudyCard> parse({
    required String content,
    required CardCategory category,
    required CardLevel level,
    required String sourceName,
    String deckId = '',
    String idPrefix = '',
  }) {
    final rows = _parseRows(content);
    if (rows.isEmpty) {
      throw FormatException('$sourceName tidak berisi data.');
    }

    return [
      for (var index = 0; index < rows.length; index++)
        _cardFromRow(
          rows[index],
          index + 1,
          category,
          level,
          sourceName,
          deckId,
          idPrefix,
        ),
    ];
  }

  StudyCard _cardFromRow(
    List<String> row,
    int line,
    CardCategory category,
    CardLevel level,
    String sourceName,
    String deckId,
    String idPrefix,
  ) {
    if (row.length != 2 || row.any((value) => value.trim().isEmpty)) {
      throw FormatException(
        'Format CSV tidak valid di $sourceName baris $line: '
        'diperlukan tepat dua kolom yang tidak kosong.',
      );
    }

    final front = row[0].trim();
    final details = row[1].trim();
    final id = idPrefix.isEmpty
        ? '${category.name}-${level.name}-${line.toString().padLeft(4, '0')}'
        : '$idPrefix-${line.toString().padLeft(4, '0')}';

    if (category == CardCategory.kanji) {
      final separator = details.indexOf('—');
      if (separator < 0) {
        return StudyCard(
          id: id,
          category: category,
          level: level,
          front: front,
          reading: '',
          romaji: '',
          meaning: details,
          example: '',
          order: line,
          deckId: deckId,
        );
      }
      if (separator == 0 || separator == details.length - 1) {
        throw FormatException(
          'Format Kanji tidak valid di $sourceName baris $line: '
          'kolom kedua harus berbentuk "bacaan — arti".',
        );
      }
      return StudyCard(
        id: id,
        category: category,
        level: level,
        front: front,
        reading: details.substring(0, separator).trim(),
        romaji: '',
        meaning: details.substring(separator + 1).trim(),
        example: '',
        order: line,
        deckId: deckId,
      );
    }

    final asciiOpening = front.indexOf('(');
    final opening = asciiOpening >= 0 ? asciiOpening : front.indexOf('（');
    final asciiClosing = front.lastIndexOf(')');
    final closing = asciiClosing >= 0 ? asciiClosing : front.lastIndexOf('）');
    final word = opening > 0 && closing > opening
        ? front.substring(0, opening).trim()
        : front;
    final kanji = opening > 0 && closing > opening
        ? front.substring(opening + 1, closing).trim()
        : '';

    if (level == CardLevel.n3) {
      return StudyCard(
        id: id,
        category: category,
        level: level,
        front: opening > 0 && closing > opening ? kanji : front,
        reading: opening > 0 && closing > opening ? word : '',
        romaji: '',
        meaning: details,
        example: '',
        order: line,
        deckId: deckId,
      );
    }

    return StudyCard(
      id: id,
      category: category,
      level: level,
      front: word,
      reading: kanji,
      romaji: '',
      meaning: details,
      example: '',
      order: line,
      deckId: deckId,
    );
  }

  List<List<String>> _parseRows(String content) {
    final rows = <List<String>>[];
    var row = <String>[];
    var field = StringBuffer();
    var quoted = false;
    var index = 0;
    final normalized = content.replaceFirst('\uFEFF', '');

    void finishField() {
      row.add(field.toString());
      field = StringBuffer();
    }

    void finishRow() {
      finishField();
      if (row.any((value) => value.trim().isNotEmpty)) rows.add(row);
      row = <String>[];
    }

    while (index < normalized.length) {
      final character = normalized[index];
      if (character == '"') {
        if (quoted &&
            index + 1 < normalized.length &&
            normalized[index + 1] == '"') {
          field.write('"');
          index += 2;
          continue;
        }
        quoted = !quoted;
      } else if (character == ',' && !quoted) {
        finishField();
      } else if ((character == '\n' || character == '\r') && !quoted) {
        finishRow();
        if (character == '\r' &&
            index + 1 < normalized.length &&
            normalized[index + 1] == '\n') {
          index++;
        }
      } else {
        field.write(character);
      }
      index++;
    }
    if (field.isNotEmpty || row.isNotEmpty) finishRow();
    if (quoted) {
      throw FormatException(
        'Format CSV tidak valid: tanda kutip tidak lengkap.',
      );
    }
    return rows;
  }
}
