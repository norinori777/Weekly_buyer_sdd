import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as speech_to_text;

abstract class ProductNameVoiceInputService {
  Future<String?> listen(BuildContext context);
}

final productNameVoiceInputServiceProvider = Provider<ProductNameVoiceInputService>((ref) {
  return SpeechToTextProductNameVoiceInputService();
});

class SpeechToTextProductNameVoiceInputService implements ProductNameVoiceInputService {
  SpeechToTextProductNameVoiceInputService();

  static final speech_to_text.SpeechToText _speechToText = speech_to_text.SpeechToText();
  static bool _isInitialized = false;

  @override
  Future<String?> listen(BuildContext context) async {
    final available = await _ensureAvailable();
    if (!available || !context.mounted) {
      return null;
    }

    return showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return _VoiceInputSheet(speechToText: _speechToText);
      },
    );
  }

  Future<bool> _ensureAvailable() async {
    if (_isInitialized) {
      return true;
    }

    _isInitialized = await _speechToText.initialize(
      onStatus: (_) {},
      onError: (_) {},
    );
    return _isInitialized;
  }
}

class _VoiceInputSheet extends StatefulWidget {
  const _VoiceInputSheet({required this.speechToText});

  final speech_to_text.SpeechToText speechToText;

  @override
  State<_VoiceInputSheet> createState() => _VoiceInputSheetState();
}

class _VoiceInputSheetState extends State<_VoiceInputSheet> {
  String _recognizedText = '';
  bool _isListening = false;
  bool _hasClosed = false;
  String _statusMessage = '商品名を話してください';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startListening();
      }
    });
  }

  @override
  void dispose() {
    widget.speechToText.stop();
    super.dispose();
  }

  Future<void> _startListening() async {
    try {
      final started = await widget.speechToText.listen(
        onResult: (result) {
          if (!mounted) {
            return;
          }

          setState(() {
            _recognizedText = result.recognizedWords;
            _statusMessage = result.finalResult ? '認識しました' : '聞き取り中...';
          });

          if (result.finalResult) {
            _finish(result.recognizedWords);
          }
        },
        onSoundLevelChange: (_) {},
        partialResults: true,
        localeId: 'ja_JP',
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isListening = started;
        if (started) {
          _statusMessage = '聞き取り中...';
        }
        if (!started) {
          _statusMessage = '音声入力を開始できませんでした';
        }
      });

      if (!started) {
        _finish(null);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isListening = false;
        _statusMessage = '音声入力を開始できませんでした';
      });
      _finish(null);
    }
  }

  void _finish(String? value) {
    if (_hasClosed) {
      return;
    }

    _hasClosed = true;
    final normalized = value?.trim();
    Navigator.of(context).pop(normalized == null || normalized.isEmpty ? null : normalized);
  }

  Future<void> _stopListening() async {
    if (!_isListening || _hasClosed) {
      return;
    }

    await widget.speechToText.stop();
    if (!mounted) {
      return;
    }

    _finish(_recognizedText);
  }

  void _cancelListening() {
    if (_hasClosed) {
      return;
    }

    widget.speechToText.cancel();
    _finish(null);
  }

  @override
  Widget build(BuildContext context) {
    final recognizedText = _recognizedText.trim();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('商品名を音声入力', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              _statusMessage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                recognizedText.isEmpty ? '認識結果はここに表示されます' : recognizedText,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _hasClosed ? null : _cancelListening,
                    child: const Text('キャンセル'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _hasClosed ? null : _stopListening,
                    child: Text(_isListening ? '停止して反映' : '閉じる'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}