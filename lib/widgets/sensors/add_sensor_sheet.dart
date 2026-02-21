import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/sensor_model.dart';
import '../../providers/sensor_provider.dart';
import '../../widgets/common/app_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Add Sensor Bottom Sheet — 4-step wizard
// ─────────────────────────────────────────────────────────────────────────────

/// Launches the multi-step Add Sensor wizard as a modal bottom sheet.
/// Resets the wizard state before showing.
void showAddSensorSheet(BuildContext context) {
  context.read<SensorProvider>().resetWizard();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AddSensorSheet(),
  );
}

class _AddSensorSheet extends StatelessWidget {
  const _AddSensorSheet();

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorProvider>(
      builder: (context, provider, _) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Drag handle
                  const SizedBox(height: 12),
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Step header
                  _SheetHeader(step: provider.wizardStep),

                  // Step progress indicator
                  _StepIndicator(currentStep: provider.wizardStep),

                  // Step content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _stepContent(provider.wizardStep, provider),
                    ),
                  ),

                  // Next / Submit button
                  _SheetFooter(provider: provider),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _stepContent(int step, SensorProvider provider) {
    switch (step) {
      case 0: return _Step1BasicInfo(form: provider.form, onUpdate: provider.updateForm);
      case 1: return _Step2Location(form: provider.form, onUpdate: provider.updateForm);
      case 2: return _Step3AiPrefs(form: provider.form, onUpdate: provider.updateForm);
      case 3: return _Step4Review(form: provider.form);
      default: return const SizedBox.shrink();
    }
  }
}

// ── Sheet Header ──────────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  final int step;
  const _SheetHeader({required this.step});

  static const _titles = [
    'Basic Sensor Information',
    'Location & Source Mapping',
    'AI Monitoring Preferences',
    'Review & Confirm Screen',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _titles[step],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.close, color: AppColors.textGrey, size: 22),
          ),
        ],
      ),
    );
  }
}

// ── Step progress dots ─────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: List.generate(4, (i) {
          final isActive   = i <= currentStep;
          final isCurrent  = i == currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: isActive ? AppColors.teal : AppColors.mintLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Footer with Next / Submit button ─────────────────────────────────────────

class _SheetFooter extends StatelessWidget {
  final SensorProvider provider;
  const _SheetFooter({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isLastStep = provider.wizardStep == 3;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: AppButton(
        label: isLastStep ? 'Add Sensor' : 'Next',
        enabled: _canAdvance(provider),
        isLoading: provider.addingLoading,
        onPressed: () => _handleNext(context, provider),
      ),
    );
  }

  bool _canAdvance(SensorProvider p) {
    switch (p.wizardStep) {
      case 0: return p.form.step1Valid;
      case 1: return p.form.step2Valid;
      case 2: return true; // AI prefs are optional
      case 3: return true;
      default: return false;
    }
  }

  Future<void> _handleNext(BuildContext context, SensorProvider provider) async {
    if (provider.wizardStep < 3) {
      provider.nextWizardStep();
    } else {
      // Final step — submit
      final sensor = await provider.submitSensor();
      if (context.mounted) {
        Navigator.of(context).pop(); // close wizard
        if (sensor != null) {
          _showSuccessSheet(context, sensor);
        }
      }
    }
  }
}

// ── Success bottom sheet ──────────────────────────────────────────────────────

void _showSuccessSheet(BuildContext context, SensorModel sensor) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _SuccessSheet(sensorId: sensor.id),
  );
}

class _SuccessSheet extends StatelessWidget {
  final String sensorId;
  const _SuccessSheet({required this.sensorId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success icon — matches email verified screen style
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: AppColors.mintLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 72, height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.teal,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: AppColors.white, size: 34),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Successful',
              style: TextStyle(
                  style: Theme.of(context).textTheme.headlineSmall)),
          const SizedBox(height: 8),
          Text(
            'Sensor $sensorId successfully added and now being monitored.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          AppButton(
            label: 'Done',
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wizard Steps
// ─────────────────────────────────────────────────────────────────────────────

/// Step 1 — Basic Sensor Information
/// Collects: Parameter Type, Sensor ID, Sensor Name
class _Step1BasicInfo extends StatelessWidget {
  final AddSensorForm form;
  final VoidCallback onUpdate;
  const _Step1BasicInfo({required this.form, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const _WizardFieldLabel('Parameter Type'),
        const SizedBox(height: 8),
        _DropdownField<ParameterType>(
          hint: 'Select Parameter Type',
          value: form.parameterType,
          items: ParameterType.values,
          labelOf: (p) => p.label,
          onChanged: (v) { form.parameterType = v; onUpdate(); },
        ),
        const SizedBox(height: 16),
        const _WizardFieldLabel('Sensor ID'),
        const SizedBox(height: 8),
        _WizardTextField(
          hint: 'e.g - AQ-PH-206',
          initialValue: form.sensorId,
          onChanged: (v) { form.sensorId = v; onUpdate(); },
        ),
        const SizedBox(height: 16),
        const _WizardFieldLabel('Sensor Name'),
        const SizedBox(height: 8),
        _WizardTextField(
          hint: 'Enter Sensor Name',
          initialValue: form.sensorName,
          onChanged: (v) { form.sensorName = v; onUpdate(); },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Step 2 — Location & Source Mapping
/// Collects: Site, Specific Location, GPS, Data Source Type
class _Step2Location extends StatelessWidget {
  final AddSensorForm form;
  final VoidCallback onUpdate;
  const _Step2Location({required this.form, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const _WizardFieldLabel('Site/Facility'),
        const SizedBox(height: 8),
        _WizardTextField(
          hint: 'Select Site',
          initialValue: form.site,
          onChanged: (v) { form.site = v; onUpdate(); },
        ),
        const SizedBox(height: 16),
        const _WizardFieldLabel('Specific Location'),
        const SizedBox(height: 8),
        _WizardTextField(
          hint: 'Enter Location',
          initialValue: form.specificLocation,
          onChanged: (v) { form.specificLocation = v; onUpdate(); },
        ),
        const SizedBox(height: 16),
        const _WizardFieldLabel('GPS Coordinates'),
        const SizedBox(height: 8),
        _WizardTextField(
          hint: 'GPS Coordinates',
          initialValue: form.gpsCoordinates,
          onChanged: (v) { form.gpsCoordinates = v; onUpdate(); },
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 16),
        const _WizardFieldLabel('Data Source Type'),
        const SizedBox(height: 8),
        _DropdownField<DataSourceType>(
          hint: 'Select Data Source Type',
          value: form.dataSourceType,
          items: DataSourceType.values,
          labelOf: (d) => d.label,
          onChanged: (v) { form.dataSourceType = v; onUpdate(); },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Step 3 — AI Monitoring Preferences
/// Collects: Enable AI Advisory toggle, Risk Sensitivity Level
class _Step3AiPrefs extends StatelessWidget {
  final AddSensorForm form;
  final VoidCallback onUpdate;
  const _Step3AiPrefs({required this.form, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // AI Advisory checkbox row
        GestureDetector(
          onTap: () { form.aiAdvisoryEnabled = !form.aiAdvisoryEnabled; onUpdate(); },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Enable AI Advisory',
                    style: Theme.of(context).textTheme.bodyLarge),
                _CustomCheckbox(value: form.aiAdvisoryEnabled),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const _WizardFieldLabel('Risk Sensitivity Level'),
        const SizedBox(height: 8),
        _DropdownField<RiskSensitivityLevel>(
          hint: 'Enter Sensitivity Level',
          value: form.sensitivityLevel,
          items: RiskSensitivityLevel.values,
          labelOf: (r) => r.label,
          onChanged: (v) { form.sensitivityLevel = v; onUpdate(); },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Step 4 — Review & Confirm
/// Shows a read-only summary of all collected form data.
class _Step4Review extends StatelessWidget {
  final AddSensorForm form;
  const _Step4Review({required this.form});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _ReviewRow(label: 'Sensor ID',  value: form.sensorId),
        _ReviewRow(label: 'Parameter',  value: form.parameterType?.label ?? '—'),
        _ReviewRow(label: 'Location',   value: '${form.specificLocation}, ${form.site}'),
        _ReviewRow(label: 'Thresholds', value: form.sensitivityLevel?.label ?? '—'),
        // AI Advisory checkbox (read-only display)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Enable AI Advisory',
                  style: Theme.of(context).textTheme.bodyLarge),
              _CustomCheckbox(value: form.aiAdvisoryEnabled),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable wizard-specific sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Bold label used above wizard form fields.
/// Bold label above each wizard form field.
/// Uses [TextTheme.labelLarge] — defined once in [AppTheme], not here.
class _WizardFieldLabel extends StatelessWidget {
  final String text;
  const _WizardFieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.labelLarge);
  }
}

/// Outlined text input consistent with wizard design.
/// Text input used inside the Add Sensor wizard steps.
///
/// Decoration (borders, fill, padding, hint style) is fully inherited from
/// [AppTheme.inputDecorationTheme] — only the hint string and keyboard type
/// are configured here. This keeps the wizard consistent with [AppTextField]
/// without duplicating a single border radius or colour.
class _WizardTextField extends StatelessWidget {
  final String hint;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;

  const _WizardTextField({
    required this.hint,
    required this.initialValue,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue.isNotEmpty ? initialValue : null,
      onChanged:    onChanged,
      keyboardType: keyboardType,
      // Body style from textTheme — size and colour defined once in AppTheme
      style: Theme.of(context).textTheme.bodyLarge,
      // Only hint text is specified; all border/fill/padding comes from theme
      decoration: InputDecoration(hintText: hint),
    );
  }
}

/// Generic dropdown field for enum values.
class _DropdownField<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.hint,
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: Theme.of(context).textTheme.bodyMedium),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textGrey),
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      labelOf(item),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Read-only row in the Review step.
class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: tt.labelLarge),
          const SizedBox(height: 6),
          Container(
            width:   double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color:        AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border:       Border.all(color: AppColors.borderColor),
            ),
            child: Text(value.isNotEmpty ? value : '—', style: tt.bodyMedium),
          ),
        ],
      ),
    );
  }
}

/// Small square checkbox styled in AquaSense teal.
class _CustomCheckbox extends StatelessWidget {
  final bool value;
  const _CustomCheckbox({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20, height: 20,
      decoration: BoxDecoration(
        color: value ? AppColors.teal.withValues(alpha: 0.12) : AppColors.white,
        border: Border.all(
          color: value ? AppColors.teal : AppColors.borderColor,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: value
          ? const Icon(Icons.check, size: 13, color: AppColors.teal)
          : null,
    );
  }
}