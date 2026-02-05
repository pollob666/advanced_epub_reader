library advanced_epub_reader;

// Main widgets
export 'src/widgets/epub_viewer.dart';
export 'src/widgets/chapter_list.dart';
export 'src/widgets/reading_controls.dart';
export 'src/widgets/table_of_contents.dart';
export 'src/widgets/epub_viewer_menu.dart';
export 'src/widgets/text_selection_menu.dart';
export 'src/widgets/epub_content_builder.dart';
export 'src/widgets/note_dialog.dart';
export 'src/widgets/page_jump_dialog.dart';

// Models
export 'src/models/highlight.dart';
export 'src/models/bookmark.dart';
export 'src/models/note.dart';
export 'src/models/epub_book.dart';
export 'src/models/epub_chapter.dart';
export 'src/models/epub_metadata.dart';
export 'src/models/reading_progress.dart';
export 'src/models/annotation.dart';
export 'src/models/app_bar_style.dart';

// Services
export 'src/services/highlight_service.dart';
export 'src/services/bookmark_service.dart';
export 'src/services/note_service.dart';
export 'src/services/epub_parser_service.dart';
export 'src/services/progress_service.dart';
export 'src/services/annotation_service.dart';
export 'src/services/page_calculation_service.dart';
export 'src/services/search_controller.dart';

// Utilities
export 'src/utils/reading_theme.dart';
export 'src/utils/reading_themes.dart';
export 'src/utils/theme_manager.dart';
export 'src/utils/epub_utils.dart';
