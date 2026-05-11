import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeSkeletonView extends StatelessWidget {
  const HomeSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey[300]!;
    final highlightColor = Colors.grey[100]!;
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // 1. HEADER SKELETON
          Container(
            width: double.infinity,
            // Padding bawah diperbesar untuk ruang overlap Card
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 60),
            decoration: BoxDecoration(color: baseColor),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[400]!,
                      highlightColor: highlightColor,
                      child: Container(width: 120, height: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[400]!,
                      highlightColor: highlightColor,
                      child: Container(width: 100, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
                    ),
                  ],
                ),
                Shimmer.fromColors(
                  baseColor: Colors.grey[400]!,
                  highlightColor: highlightColor,
                  child: const CircleAvatar(radius: 18, backgroundColor: Colors.white),
                ),
              ],
            ),
          ),

          // SEMUA KONTEN DI BAWAH DITARIK NAIK (Efek Overlap)
          Transform.translate(
            offset: const Offset(0, -35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. TOTAL VOLUME CARD SKELETON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Shimmer.fromColors(
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 3. MENU SECTION SKELETON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: baseColor,
                        highlightColor: highlightColor,
                        child: Container(width: 100, height: 20, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(3, (index) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Shimmer.fromColors(
                            baseColor: baseColor,
                            highlightColor: highlightColor,
                            child: Container(width: 80, height: 32, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
                          ),
                        )),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: 4,
                          separatorBuilder: (_, __) => const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            return Shimmer.fromColors(
                              baseColor: baseColor,
                              highlightColor: highlightColor,
                              child: Column(
                                children: [
                                  Container(width: 45, height: 45, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                                  const SizedBox(height: 8),
                                  Container(width: 40, height: 8, color: Colors.white),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 4. TRANSACTION SKELETON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: baseColor,
                        highlightColor: highlightColor,
                        child: Container(width: 140, height: 20, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 2,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Shimmer.fromColors(
                                baseColor: baseColor,
                                highlightColor: highlightColor,
                                child: Container(
                                  // Lebar responsif ~45% dari layar
                                  width: screenWidth * 0.45,
                                  height: 160,
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}