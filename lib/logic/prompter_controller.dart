import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

enum PrompterState { idle, countingDown, playing, paused, completed }

/// In-house Prompter Scroll Engine menggunakan Ticker bawaan Flutter (Zero-bloat, 60-120 FPS smooth)
class PrompterController extends ChangeNotifier {
  final ScrollController scrollController;
  Ticker? _ticker;
  Duration _lastDuration = Duration.zero;

  PrompterState _state = PrompterState.idle;
  double _speed; // pixels per second
  double _fontSize;
  double _bgOpacity;
  bool _isMirrored;
  final int _countdown;

  PrompterController({
    required this.scrollController,
    double initialSpeed = 45.0,
    double initialFontSize = 24.0,
    double initialBgOpacity = 0.70,
    bool initialMirrored = false,
    int initialCountdown = 3,
    TickerProvider? vsync,
  })  : _speed = initialSpeed,
        _fontSize = initialFontSize,
        _bgOpacity = initialBgOpacity,
        _isMirrored = initialMirrored,
        _countdown = initialCountdown {
    if (vsync != null) {
      attachVsync(vsync);
    }
  }

  PrompterState get state => _state;
  double get speed => _speed;
  double get fontSize => _fontSize;
  double get bgOpacity => _bgOpacity;
  bool get isMirrored => _isMirrored;
  int get countdown => _countdown;
  bool get isPlaying => _state == PrompterState.playing;

  void attachVsync(TickerProvider vsync) {
    _ticker?.dispose();
    _ticker = vsync.createTicker(_onTick);
  }

  void _onTick(Duration elapsed) {
    if (_lastDuration == Duration.zero) {
      _lastDuration = elapsed;
      return;
    }

    final double dt = (elapsed - _lastDuration).inMicroseconds / 1000000.0;
    _lastDuration = elapsed;

    if (!scrollController.hasClients) return;

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;

    if (currentScroll >= maxScroll) {
      pause();
      _state = PrompterState.completed;
      notifyListeners();
      return;
    }

    final double deltaScroll = _speed * dt;
    final double targetOffset = (currentScroll + deltaScroll).clamp(0.0, maxScroll);
    scrollController.jumpTo(targetOffset);
  }

  void play() {
    if (_state == PrompterState.playing) return;
    _state = PrompterState.playing;
    _lastDuration = Duration.zero;
    _ticker?.start();
    notifyListeners();
  }

  void pause() {
    if (_state != PrompterState.playing) return;
    _state = PrompterState.paused;
    _ticker?.stop();
    _lastDuration = Duration.zero;
    notifyListeners();
  }

  void togglePlayPause() {
    if (isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void reset() {
    pause();
    _state = PrompterState.idle;
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
    notifyListeners();
  }

  void jumpBy(double pixels) {
    if (!scrollController.hasClients) return;
    final maxScroll = scrollController.position.maxScrollExtent;
    final target = (scrollController.offset + pixels).clamp(0.0, maxScroll);
    scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void setSpeed(double newSpeed) {
    _speed = newSpeed;
    notifyListeners();
  }

  void setFontSize(double newSize) {
    _fontSize = newSize;
    notifyListeners();
  }

  void setBgOpacity(double newOpacity) {
    _bgOpacity = newOpacity;
    notifyListeners();
  }

  void toggleMirror() {
    _isMirrored = !_isMirrored;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }
}
