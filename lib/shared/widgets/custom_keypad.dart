import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/sound_manager.dart';
import '../../core/accessibility/accessibility_settings.dart';

class CustomKeypad extends ConsumerWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onClear;
  final VoidCallback onSubmit;
  final String currentInput;

  const CustomKeypad({
    super.key,
    required this.onKeyPressed,
    required this.onClear,
    required this.onSubmit,
    required this.currentInput,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLargeTarget = ref.watch(accessibilitySettingsProvider.select((s) => s.largeTargetMode));
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Answer display row - Minimalist thin line
        Container(
          height: isLargeTarget ? 80 : 60,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    currentInput.isEmpty ? '?' : currentInput,
                    style: TextStyle(
                      fontSize: isLargeTarget ? 48 : 40,
                      fontWeight: FontWeight.w200,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  HapticManager.instance.lightImpact();
                  onClear();
                },
                icon: Icon(
                  Icons.backspace_outlined,
                   color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                iconSize: isLargeTarget ? 28 : 20,
              ),
            ],
          ),
        ),
        _buildKeypad(context, isLargeTarget),
      ],
    );
  }

  Widget _buildKeypad(BuildContext context, bool isLargeTarget) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(context, ['1', '2', '3'], isLargeTarget),
          _buildRow(context, ['4', '5', '6'], isLargeTarget),
          _buildRow(context, ['7', '8', '9'], isLargeTarget),
          Row(
            children: [
              Expanded(
                child: _buildActionKey(
                  context,
                  Icons.close,
                  () {
                    HapticManager.instance.mediumImpact();
                    onClear();
                  },
                  isLargeTarget,
                ),
              ),
              Expanded(child: _buildKey(context, '0', isLargeTarget)),
              Expanded(
                child: _buildActionKey(
                  context,
                  Icons.check,
                  () {
                    HapticManager.instance.heavyImpact();
                    onSubmit();
                  },
                  isLargeTarget,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, List<String> keys, bool isLargeTarget) {
    return Row(
      children: keys.map((k) {
        return Expanded(
          child: _buildKey(context, k, isLargeTarget),
        );
      }).toList(),
    );
  }

  Widget _buildKey(BuildContext context, String key, bool isLargeTarget) {
    final theme = Theme.of(context);
    return SizedBox(
      height: isLargeTarget ? 85 : 65,
      child: Semantics(
        label: 'Key $key',
        button: true,
        child: InkWell(
          onTap: () {
            HapticManager.instance.selectionClick();
            onKeyPressed(key);
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                width: 0.25,
              ),
            ),
            child: Center(
              child: Text(
                key,
                style: TextStyle(
                  fontSize: isLargeTarget ? 36 : 28,
                  fontWeight: FontWeight.w200,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed,
    bool isLargeTarget,
  ) {
    final theme = Theme.of(context);
    final isSubmit = icon == Icons.check;
    return SizedBox(
      height: isLargeTarget ? 85 : 65,
      child: Semantics(
        label: isSubmit ? 'Submit' : 'Clear',
        button: true,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                width: 0.25,
              ),
            ),
            child: Icon(
              icon,
              size: isLargeTarget ? 32 : 24,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}


class DisableKeyboard extends StatelessWidget {
  final Widget child;

  const DisableKeyboard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {},
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: child,
      ),
    );
  }
}
