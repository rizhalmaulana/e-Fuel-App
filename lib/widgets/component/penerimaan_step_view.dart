import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import '../../datas/models/widgets/penerimaan_step.dart';

class PenerimaanStepView extends StatelessWidget {
  final List<PenerimaanStep> steps;
  const PenerimaanStepView({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        return _buildStepItem(step, index < steps.length - 1);
      }),
    ));
  }

  Widget _buildStepItem(PenerimaanStep step, bool hasLine) {
    bool isCompleted = step.isCompleted.value;
    bool isActive = step.isActive.value;
    bool isFinishedStep = isCompleted || isActive;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 50,
            child: Column(
              children: [
                // Icon
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  child: isFinishedStep
                      ? const Icon(Icons.check_circle, color: AppColors.primary, size: 24)
                      : const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 24),
                ),
                // Garis
                if (hasLine)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted ? AppColors.primary : const Color(0xFFE0E0E0),
                      margin: const EdgeInsets.symmetric(vertical: 2),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: isFinishedStep ? () => Get.toNamed(step.routeName) : null,
              child: Container(
                padding: const EdgeInsets.only(top: 4, bottom: 24),
                child: Text(
                  step.title,
                  style: AppFonts.fUrbanistMedium14.copyWith(
                    color: isFinishedStep ? AppColors.darkText : AppColors.secondaryText,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}