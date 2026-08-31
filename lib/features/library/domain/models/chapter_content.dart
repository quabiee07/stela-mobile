import 'package:stela_mobile/features/library/domain/models/chapter_paragraph.dart';

class ChapterContent {
  final String storyId;
  final String chapterId;
  final int chapterNumber;
  final String title;
  final int wordCount;
  final String imageUrl;
  final List<ChapterParagraph> paragraphs;

  const ChapterContent({
    required this.storyId,
    required this.chapterId,
    required this.chapterNumber,
    required this.title,
    required this.wordCount,
    required this.paragraphs,
    this.imageUrl = '',
  });

  List<String> get sentences {
    return paragraphs.expand((paragraph) => paragraph.sentences).toList();
  }

  String get fullText => sentences.join(' ');
}
