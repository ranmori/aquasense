
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Search bar + filter icon row used on Home and Sensors screens.
///
/// The [TextField] inherits [AppTheme.inputDecorationTheme] for its borders
/// and padding. We override [fillColor] to [AppColors.surfaceGrey] so the
/// search field reads as a distinct surface from the white auth fields,
/// matching the design's light-grey search pill.
class SearchBarWidget extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;

  const SearchBarWidget({
    super.key,
    this.hint = 'Search sensor or parameter',
    this.onChanged,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        // ── Search field ─────────────────────────────────────────────
        Expanded(
          child: TextField(
            onChanged: onChanged,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textDark),
            decoration: InputDecoration(
              hintText:   hint,
              // Override fill so search bar uses grey surface, not white
              fillColor:  AppColors.surfaceGrey,
              // Transparent borders on the search bar — the grey fill
              // provides sufficient affordance without a border stroke
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textGrey,
                size:  20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // ── Filter icon button ────────────────────────────────────────
        _FilterButton(onTap: onFilterTap),
      ],
    );
  }
}

/// Square icon button with the same surface colour as the search bar.
class _FilterButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _FilterButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:  44,
        height: 44,
        decoration: BoxDecoration(
          color:        AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.tune, color: AppColors.textGrey, size: 20),
      ),
    );
  }
}