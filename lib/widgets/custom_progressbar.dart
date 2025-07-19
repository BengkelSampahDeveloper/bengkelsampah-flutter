import 'package:bengkelsampah_app/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ProgressStep {
  final String title;
  final int xp;

  ProgressStep({required this.title, required this.xp});
}

class CustomProgressBar extends StatelessWidget {
  final int currentXP;
  final List<ProgressStep> steps;

  const CustomProgressBar({
    Key? key,
    required this.currentXP,
    required this.steps,
  }) : super(key: key);

  int getCurrentStep() {
    for (int i = steps.length - 1; i >= 0; i--) {
      if (currentXP >= steps[i].xp) {
        return i;
      }
    }
    return 0;
  }

  double getProgressPercentage() {
    int currentStep = getCurrentStep();
    if (currentStep >= steps.length - 1) return 1.0;

    int currentStepXP = steps[currentStep].xp;
    int nextStepXP = steps[currentStep + 1].xp;
    double progressInStep =
        (currentXP - currentStepXP) / (nextStepXP - currentStepXP);

    return (currentStep + progressInStep.clamp(0.0, 1.0)) / (steps.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    int currentStep = getCurrentStep();
    double totalProgress = getProgressPercentage();

    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Column(
        children: [
          // Progress Bar
          SizedBox(
            height: 100,
            child: Stack(
              children: [
                // Background line
                Positioned(
                  top: 25,
                  left: 12,
                  right: 12,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),

                // Progress line
                Positioned(
                  top: 27,
                  left: 12,
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 72) *
                        totalProgress,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF40E0D0), Color(0xFF0FB7A6)],
                        stops: [0.0, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),

                // Step circles
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: steps.asMap().entries.map((entry) {
                    int index = entry.key;
                    ProgressStep step = entry.value;
                    bool isActive = index <= currentStep;

                    if (isActive) {
                      // Active circle with gradient border
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFD9D9D9),
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(3.5),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF40E0D0),
                                    Color(0xFF0FB7A6)
                                  ],
                                  stops: [0.0, 1.0],
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            step.title,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              color: AppColors.color_535353,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '${step.xp} XP',
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              color: AppColors.color_535353,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    } else {
                      // Inactive circle
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFD9D9D9),
                            ),
                            child: Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            step.title,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.normal,
                              color: AppColors.color_535353,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '${step.xp} XP',
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.normal,
                              color: AppColors.color_535353,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    }
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
