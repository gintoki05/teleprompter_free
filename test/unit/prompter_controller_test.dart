import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teleprompter_free/logic/prompter_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PrompterController Tests', () {
    late ScrollController scrollController;
    late PrompterController prompterController;

    setUp(() {
      scrollController = ScrollController();
      prompterController = PrompterController(
        scrollController: scrollController,
        initialSpeed: 50.0,
        initialFontSize: 24.0,
        initialBgOpacity: 0.70,
        initialMirrored: false,
      );
    });

    tearDown(() {
      prompterController.dispose();
      scrollController.dispose();
    });

    test('Initial properties are set correctly', () {
      expect(prompterController.state, equals(PrompterState.idle));
      expect(prompterController.speed, equals(50.0));
      expect(prompterController.fontSize, equals(24.0));
      expect(prompterController.bgOpacity, equals(0.70));
      expect(prompterController.isMirrored, isFalse);
      expect(prompterController.isPlaying, isFalse);
    });

    test('Property mutators work as expected', () {
      prompterController.setSpeed(75.0);
      expect(prompterController.speed, equals(75.0));

      prompterController.setFontSize(32.0);
      expect(prompterController.fontSize, equals(32.0));

      prompterController.setBgOpacity(0.9);
      expect(prompterController.bgOpacity, equals(0.9));

      prompterController.toggleMirror();
      expect(prompterController.isMirrored, isTrue);
    });

    test('State transitions pause and reset cleanly', () {
      prompterController.pause();
      expect(prompterController.state, equals(PrompterState.idle)); // since it wasn't playing

      prompterController.reset();
      expect(prompterController.state, equals(PrompterState.idle));
    });
  });
}
