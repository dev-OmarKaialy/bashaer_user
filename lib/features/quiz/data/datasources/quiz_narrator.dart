import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:edge_tts/edge_tts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/extensions/log_colors_extension.dart';
import '../../data/datasources/quiz_media_cache.dart';
import '../../data/models/question_model.dart';

/// Which part of the question is currently being narrated.
enum NarrationFocus { none, prompt, answer, feedback }

class _WordSpan {
  const _WordSpan({
    required this.startTicks,
    required this.endTicks,
    required this.highlightStart,
    required this.highlightEnd,
  });

  /// Edge offsets are in 100-nanosecond ticks.
  final int startTicks;
  final int endTicks;
  final int highlightStart;
  final int highlightEnd;
}

/// Narrates quiz content:
/// 1. [QuestionModel.audio] when present
/// 2. Microsoft Edge neural TTS (`ar-SY-LaithNeural`)
/// 3. Device [FlutterTts] if Edge fails
@lazySingleton
class QuizNarrator extends ChangeNotifier {
  QuizNarrator(this._mediaCache) {
    unawaited(_ensureDeviceTtsReady());
  }

  final QuizMediaCache _mediaCache;
  final FlutterTts _deviceTts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();

  bool _speaking = false;
  Future<void>? _deviceReadyFuture;
  int _generation = 0;
  StreamSubscription<Duration>? _positionSub;
  String? _tempEdgeFilePath;

  NarrationFocus _focus = NarrationFocus.none;
  int? _answerIndex;
  String? _questionId;
  String _spokenText = '';
  String _displayText = '';
  int _displayOffset = 0;
  int _highlightStart = 0;
  int _highlightEnd = 0;

  bool get isSpeaking => _speaking;
  NarrationFocus get focus => _focus;
  int? get answerIndex => _answerIndex;
  String? get questionId => _questionId;
  String get displayText => _displayText;
  int get highlightStart => _highlightStart;
  int get highlightEnd => _highlightEnd;
  String get selectedVoiceLabel => _edgeVoice;

  static const _arabicLetters = ['أ', 'ب', 'ج', 'د', 'ه', 'و', 'ز', 'ح'];
  static const _edgeVoice = 'ar-AE-HamdanNeural';
  static const _edgeTimeout = Duration(seconds: 20);

  Future<void> _ensureDeviceTtsReady() {
    final existing = _deviceReadyFuture;
    if (existing != null) return existing;
    return _deviceReadyFuture = _initDeviceTts();
  }

  Future<void> _initDeviceTts() async {
    try {
      await _deviceTts.awaitSpeakCompletion(true);
      await _deviceTts.setLanguage('ar');
      await _deviceTts.setSpeechRate(0.5);
      await _deviceTts.setVolume(1);
      await _deviceTts.setPitch(1);
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        try {
          await _deviceTts.setSharedInstance(true);
          await _deviceTts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
          ], IosTextToSpeechAudioMode.spokenAudio);
        } catch (_) {}
      }
      _deviceTts.setCancelHandler(() {
        _clearHighlight();
        _setSpeaking(false);
      });
      _deviceTts.setErrorHandler((message) {
        log('Device TTS error: $message'.logRed);
        _clearHighlight();
        _setSpeaking(false);
      });
      _deviceTts.setProgressHandler((text, start, end, word) {
        if (!_speaking || text != _spokenText) return;
        final rawStart = start.clamp(0, text.length);
        final rawEnd = end.clamp(rawStart, text.length);
        final adjStart = (rawStart - _displayOffset).clamp(0, _displayText.length);
        final adjEnd = (rawEnd - _displayOffset).clamp(0, _displayText.length);
        if (adjStart == _highlightStart && adjEnd == _highlightEnd) return;
        _highlightStart = adjStart;
        _highlightEnd = adjEnd;
        notifyListeners();
      });
      log('Device TTS ready (fallback)'.logWhite);
    } catch (e) {
      log('Device TTS init failed: $e'.logYellow);
    }
  }

  void _setSpeaking(bool value) {
    if (_speaking == value) return;
    _speaking = value;
    if (!value) _clearHighlight(notify: false);
    notifyListeners();
  }

  void _clearHighlight({bool notify = true}) {
    _focus = NarrationFocus.none;
    _answerIndex = null;
    _spokenText = '';
    _displayText = '';
    _displayOffset = 0;
    _highlightStart = 0;
    _highlightEnd = 0;
    if (notify) notifyListeners();
  }

  void _beginSegment({
    required NarrationFocus focus,
    required String spokenText,
    required String displayText,
    int displayOffset = 0,
    int? answerIndex,
  }) {
    _focus = focus;
    _answerIndex = answerIndex;
    _spokenText = spokenText;
    _displayText = displayText;
    _displayOffset = displayOffset;
    _highlightStart = 0;
    _highlightEnd = 0;
    notifyListeners();
  }

  /// Priority: [QuestionModel.audio] → Edge neural TTS → device TTS.
  Future<void> speakQuestion(QuestionModel question) async {
    await stop();
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final generation = _generation;
    _questionId = question.id;

    final audio = question.audio?.trim();
    if (audio != null && audio.isNotEmpty) {
      final prompt = promptScript(question);
      _beginSegment(focus: NarrationFocus.prompt, spokenText: prompt, displayText: prompt);
      _setSpeaking(true);
      final played = await _playRemoteOrCachedAudio(audio, generation);
      if (played) {
        if (generation == _generation) {
          _clearHighlight(notify: false);
          _setSpeaking(false);
        }
        return;
      }
      log('Question audio failed — falling through to TTS'.logYellow);
    }

    _setSpeaking(true);
    try {
      final prompt = promptScript(question);
      await _speakSegment(
        spokenText: prompt,
        displayText: prompt,
        focus: NarrationFocus.prompt,
        generation: generation,
      );

      for (var i = 0; i < question.answers.length; i++) {
        if (generation != _generation) return;
        final letter = i < _arabicLetters.length ? _arabicLetters[i] : '${i + 1}';
        final body = question.answers[i].text;
        final prefix = '$letter: ';
        await _speakSegment(
          spokenText: '$prefix$body',
          displayText: body,
          displayOffset: prefix.length,
          focus: NarrationFocus.answer,
          answerIndex: i,
          generation: generation,
        );
      }
    } finally {
      if (generation == _generation) {
        _clearHighlight(notify: false);
        _setSpeaking(false);
      }
    }
  }

  Future<void> speakFeedback({required bool correct}) async {
    await stop();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final generation = _generation;
    _questionId = null;
    _setSpeaking(true);
    try {
      final text = correct ? 'صحيح' : 'خطأ';
      await _speakSegment(
        spokenText: text,
        displayText: text,
        focus: NarrationFocus.feedback,
        generation: generation,
      );
    } finally {
      if (generation == _generation) {
        _clearHighlight(notify: false);
        _setSpeaking(false);
      }
    }
  }

  Future<void> stop() async {
    _generation++;
    await _positionSub?.cancel();
    _positionSub = null;
    try {
      await _deviceTts.stop();
    } catch (_) {}
    try {
      await _player.stop();
    } catch (_) {}
    await _deleteTempEdgeFile();
    _clearHighlight(notify: false);
    _setSpeaking(false);
  }

  static String promptScript(QuestionModel question) {
    final buffer = StringBuffer(question.title);
    final description = question.description?.trim();
    if (description != null && description.isNotEmpty) {
      buffer.write('. ');
      buffer.write(description);
    }
    return buffer.toString();
  }

  Future<void> _speakSegment({
    required String spokenText,
    required String displayText,
    required NarrationFocus focus,
    required int generation,
    int displayOffset = 0,
    int? answerIndex,
  }) async {
    if (generation != _generation) return;
    if (spokenText.trim().isEmpty) return;

    _beginSegment(
      focus: focus,
      spokenText: spokenText,
      displayText: displayText,
      displayOffset: displayOffset,
      answerIndex: answerIndex,
    );

    final edgeOk = await _speakWithEdge(
      spokenText: spokenText,
      displayText: displayText,
      displayOffset: displayOffset,
      generation: generation,
    );
    if (edgeOk || generation != _generation) return;

    log('Edge TTS failed — falling back to device TTS'.logYellow);
    await _speakWithDevice(spokenText, generation);
  }

  Future<bool> _speakWithEdge({
    required String spokenText,
    required String displayText,
    required int displayOffset,
    required int generation,
  }) async {
    try {
      log('Edge TTS → $_edgeVoice'.logWhite);
      final communicate = Communicate(
        text: spokenText,
        voice: _edgeVoice,
        rate: '-10%',
        wordBoundary: true,
      );

      final audio = BytesBuilder(copy: false);
      final words = <WordBoundaryEvent>[];

      await _collectEdgeStream(
        communicate.stream(),
        generation: generation,
        onAudio: audio.add,
        onWord: words.add,
      ).timeout(_edgeTimeout);

      if (generation != _generation) return true;

      final bytes = audio.toBytes();
      if (bytes.isEmpty) {
        log('Edge TTS returned empty audio'.logYellow);
        return false;
      }

      final spans = _spansFromWords(
        spokenText: spokenText,
        displayText: displayText,
        displayOffset: displayOffset,
        words: words,
      );

      await _playMp3Bytes(bytes, spans: spans, generation: generation);
      return true;
    } catch (e) {
      log('Edge TTS error: $e'.logYellow);
      return false;
    }
  }

  Future<void> _collectEdgeStream(
    Stream<TtsEvent> stream, {
    required int generation,
    required void Function(List<int> data) onAudio,
    required void Function(WordBoundaryEvent word) onWord,
  }) async {
    await for (final event in stream) {
      if (generation != _generation) return;
      switch (event) {
        case AudioDataEvent(:final data):
          onAudio(data);
        case WordBoundaryEvent():
          onWord(event);
        case SentenceBoundaryEvent():
          break;
      }
    }
  }

  List<_WordSpan> _spansFromWords({
    required String spokenText,
    required String displayText,
    required int displayOffset,
    required List<WordBoundaryEvent> words,
  }) {
    final spans = <_WordSpan>[];
    var searchFrom = 0;
    for (final word in words) {
      final idx = spokenText.indexOf(word.text, searchFrom);
      if (idx < 0) continue;
      final start = (idx - displayOffset).clamp(0, displayText.length);
      final end = (idx + word.text.length - displayOffset).clamp(0, displayText.length);
      spans.add(
        _WordSpan(
          startTicks: word.offset,
          endTicks: word.offset + word.duration,
          highlightStart: start,
          highlightEnd: end,
        ),
      );
      searchFrom = idx + word.text.length;
    }
    return spans;
  }

  Future<void> _playMp3Bytes(
    Uint8List bytes, {
    required List<_WordSpan> spans,
    required int generation,
  }) async {
    await _deleteTempEdgeFile();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/quiz_edge_$generation.mp3');
    await file.writeAsBytes(bytes, flush: true);
    _tempEdgeFilePath = file.path;

    await _positionSub?.cancel();
    _positionSub = null;

    await _player.setFilePath(file.path);
    if (generation != _generation) return;

    if (spans.isNotEmpty) {
      _positionSub = _player.positionStream.listen((position) {
        if (generation != _generation) return;
        final ticks = position.inMicroseconds * 10;
        _WordSpan? active;
        for (final span in spans) {
          if (ticks >= span.startTicks) {
            active = span;
            if (ticks < span.endTicks) break;
          } else {
            break;
          }
        }
        if (active == null) return;
        if (active.highlightStart == _highlightStart && active.highlightEnd == _highlightEnd) {
          return;
        }
        _highlightStart = active.highlightStart;
        _highlightEnd = active.highlightEnd;
        notifyListeners();
      });
    }

    await _player.seek(Duration.zero);
    await _player.play();
    await _player.processingStateStream
        .firstWhere((state) => state == ProcessingState.completed || generation != _generation)
        .timeout(const Duration(seconds: 90));

    await _positionSub?.cancel();
    _positionSub = null;
    await _deleteTempEdgeFile();
  }

  Future<void> _speakWithDevice(String spokenText, int generation) async {
    try {
      await _ensureDeviceTtsReady().timeout(const Duration(seconds: 4));
    } catch (_) {}
    if (generation != _generation) return;

    final useFocus = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    try {
      var result = useFocus
          ? await _deviceTts.speak(spokenText, focus: true)
          : await _deviceTts.speak(spokenText);
      if (result != 1 && generation == _generation) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        if (generation != _generation) return;
        result = useFocus
            ? await _deviceTts.speak(spokenText, focus: true)
            : await _deviceTts.speak(spokenText);
      }
      log('Device TTS speak → $result'.logWhite);
    } catch (e) {
      log('Device TTS speak failed: $e'.logYellow);
    }
  }

  Future<bool> _playRemoteOrCachedAudio(String url, int generation) async {
    try {
      final local = _mediaCache.fileFor(url);
      if (local != null) {
        await _player.setFilePath(local.path);
      } else if (url.startsWith('/') || url.startsWith('file:')) {
        final path = url.startsWith('file:') ? Uri.parse(url).toFilePath() : url;
        await _player.setFilePath(path);
      } else {
        await _player.setUrl(url).timeout(const Duration(seconds: 8));
      }
      if (generation != _generation) return true;
      await _player.seek(Duration.zero);
      await _player.play();
      await _player.processingStateStream
          .firstWhere((state) => state == ProcessingState.completed || generation != _generation)
          .timeout(const Duration(seconds: 60));
      return true;
    } catch (e) {
      log('Question audio play failed: $e'.logYellow);
      return false;
    }
  }

  Future<void> _deleteTempEdgeFile() async {
    final path = _tempEdgeFilePath;
    _tempEdgeFilePath = null;
    if (path == null) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }
}
