import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/features/library/data/services/session_id_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SessionIdStore', () {
    late SessionIdStore store;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      var nextId = 0;
      store = SessionIdStore.test(
        prefs: SharedPreferences.getInstance(),
        createId: () => 'id-${nextId++}',
      );
    });

    test('creates and reuses an id for the same chapter', () async {
      final first = await store.getOrCreate(bookId: 'book', chapterId: 'ch1');
      final second = await store.getOrCreate(bookId: 'book', chapterId: 'ch1');

      expect(first, 'id-0');
      expect(second, 'id-0');
    });

    test('creates a new id after clear', () async {
      await store.getOrCreate(bookId: 'book', chapterId: 'ch1');
      await store.clear(bookId: 'book', chapterId: 'ch1');
      final next = await store.getOrCreate(bookId: 'book', chapterId: 'ch1');

      expect(next, 'id-1');
    });

    test('keeps ids isolated per chapter', () async {
      final first = await store.getOrCreate(bookId: 'book', chapterId: 'ch1');
      final second = await store.getOrCreate(bookId: 'book', chapterId: 'ch2');

      expect(first, 'id-0');
      expect(second, 'id-1');
    });
  });
}
