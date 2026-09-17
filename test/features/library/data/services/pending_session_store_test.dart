import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/features/library/data/dto/session_log_request_dto.dart';
import 'package:stela_mobile/features/library/data/services/pending_session_store.dart';

SessionLogRequestDto _payload(String sessionId, {String chapterId = 'ch1'}) {
  return SessionLogRequestDto(
    sessionId: sessionId,
    bookId: 'book',
    bookTitle: 'The Book',
    genre: 'fantasy',
    chapterId: chapterId,
    isAudioSession: true,
    isBookComplete: false,
    speedMultiplier: 1,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PendingSessionStore', () {
    late PendingSessionStore store;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      store = PendingSessionStore.test(prefs: SharedPreferences.getInstance());
    });

    test('enqueues and peeks payloads', () async {
      await store.enqueue(_payload('s1'));
      await store.enqueue(_payload('s2', chapterId: 'ch2'));

      final pending = await store.peekAll();
      expect(pending.map((item) => item.sessionId), ['s1', 's2']);
    });

    test('replaces an existing payload with the same session id', () async {
      await store.enqueue(_payload('s1'));
      await store.enqueue(
        SessionLogRequestDto(
          sessionId: 's1',
          bookId: 'book',
          bookTitle: 'The Book',
          genre: 'fantasy',
          chapterId: 'ch1',
          isAudioSession: true,
          isBookComplete: true,
          speedMultiplier: 1.25,
        ),
      );

      final pending = await store.peekAll();
      expect(pending, hasLength(1));
      expect(pending.single.isBookComplete, isTrue);
      expect(pending.single.speedMultiplier, 1.25);
    });

    test('removes a delivered session', () async {
      await store.enqueue(_payload('s1'));
      await store.enqueue(_payload('s2', chapterId: 'ch2'));
      await store.remove('s1');

      final pending = await store.peekAll();
      expect(pending.map((item) => item.sessionId), ['s2']);
    });
  });
}
