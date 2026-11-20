import 'package:flutter/material.dart';

abstract final class ImageSources {
  static IconData doiPlaceholder(String? resourceType) =>
      switch (resourceType) {
        'Dataset' => Icons.storage_outlined,
        'JournalArticle' => Icons.article_outlined,
        'Software' => Icons.terminal_outlined,
        'Preprint' => Icons.description_outlined,
        'PhysicalObject' => Icons.science_outlined,
        _ => Icons.category_outlined,
      };
}
