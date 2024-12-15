import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/core/utils/sync_test.dart';

void main() {
  group('SyncTest', () {
    test('should record and verify sync', () {
      // Record sync
      SyncTest.recordSync('Test sync verification');

      // Verify sync was recorded
      expect(SyncTest.getLastSyncTime(), isNotNull);
      expect(SyncTest.getSyncHistory(), isNotEmpty);
    });

    test('should record changes', () {
      // Record a change
      SyncTest.recordChange('Test change');

      // Verify change was recorded
      final changes = SyncTest.getChanges();
      expect(changes, isNotEmpty);
      expect(changes.last, contains('Test change'));
    });

    test('should provide statistics', () {
      // Record some data
      SyncTest.recordSync('Test sync');
      SyncTest.recordChange('Test change 1');
      SyncTest.recordChange('Test change 2');

      // Get statistics
      final stats = SyncTest.getStatistics();

      // Verify statistics
      expect(stats['totalChanges'], isPositive);
      expect(stats['lastSyncTime'], isNotNull);
    });

    test('should verify latest sync', () {
      // Record a sync
      SyncTest.recordSync('Test sync');

      // Verify the sync
      expect(SyncTest.verifyLatestSync(), isTrue);
    });
  });
}
