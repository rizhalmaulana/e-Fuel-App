import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeSkeletonView extends StatelessWidget {
  const HomeSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey[300]!;
    final highlightColor = Colors.grey[100]!;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 35),
                child: Container(
                  height: 120, // Estimasi tinggi header
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 45),
                  decoration: BoxDecoration(
                    color: baseColor, // Placeholder warna header
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama User & Unit Selector Placeholder
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
                        // Profile Avatar Placeholder
                        Shimmer.fromColors(
                          baseColor: Colors.grey[400]!,
                          highlightColor: highlightColor,
                          child: const CircleAvatar(radius: 18, backgroundColor: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. TOTAL VOLUME CARD SKELETON (Positioned overlapping)
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Shimmer.fromColors(
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    child: Container(
                      height: 140, // Tinggi card volume
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 50), // Jarak setelah stack

          // 3. MENU SECTION SKELETON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Menu Utama
                Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(width: 100, height: 20, color: Colors.white),
                ),
                const SizedBox(height: 12),

                // Tabs Menu
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

                // Menu Icons
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

          // 4. TRANSACTION SKELETON
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 24, right: 24),
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
                            width: 280,
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
    );
  }
}