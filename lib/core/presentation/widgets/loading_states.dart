import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

class LoadingAddresses extends StatelessWidget {
  const LoadingAddresses({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            height: 24,
            width: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFF7F4FB),
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .shimmer(
                  delay: 400.ms,
                  duration: 1800.ms,
                  color: Colors.grey.shade400),
          const Gap(10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 17,
                width: 41,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F4FB),
                  borderRadius: BorderRadius.circular(8),
                ),
              )
                  .animate(
                      onPlay: (controller) => controller.repeat(reverse: true))
                  .shimmer(
                      delay: 400.ms,
                      duration: 1800.ms,
                      color: Colors.grey.shade400),
              const Gap(10),
              Container(
                height: 17,
                width: 173,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F4FB),
                  borderRadius: BorderRadius.circular(8),
                ),
              )
                  .animate(
                      onPlay: (controller) => controller.repeat(reverse: true))
                  .shimmer(
                      delay: 400.ms,
                      duration: 1800.ms,
                      color: Colors.grey.shade400),
              const Gap(8),
              Container(
                height: 17,
                width: 41,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F4FB),
                  borderRadius: BorderRadius.circular(8),
                ),
              )
                  .animate(
                      onPlay: (controller) => controller.repeat(reverse: true))
                  .shimmer(
                      delay: 400.ms,
                      duration: 1800.ms,
                      color: Colors.grey.shade400),
            ],
          ),
          const Spacer(),
          // selected
          //     ?
          Container(
            height: 24,
            width: 24,
            decoration: const BoxDecoration(
                color: Color(0xFFF7F4FB), shape: BoxShape.circle),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .shimmer(
                  delay: 400.ms,
                  duration: 1800.ms,
                  color: Colors.grey.shade400),
        ],
      ),
    );
  }
}

class LoadingCategories extends StatelessWidget {
  const LoadingCategories({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 30,
            width: 30,
            decoration: const BoxDecoration(
              color: Color(0xFFF7F4FB),
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .shimmer(
                  delay: 400.ms,
                  duration: 1800.ms,
                  color: Colors.grey.shade400),
          const Gap(10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 17,
                width: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F4FB),
                  borderRadius: BorderRadius.circular(8),
                ),
              )
                  .animate(
                      onPlay: (controller) => controller.repeat(reverse: true))
                  .shimmer(
                      delay: 400.ms,
                      duration: 1800.ms,
                      color: Colors.grey.shade400),
              const Gap(10),
              Container(
                height: 17,
                width: 173,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F4FB),
                  borderRadius: BorderRadius.circular(8),
                ),
              )
                  .animate(
                      onPlay: (controller) => controller.repeat(reverse: true))
                  .shimmer(
                      delay: 400.ms,
                      duration: 1800.ms,
                      color: Colors.grey.shade400),
            ],
          ),
        ],
      ),
    );
  }
}

class LoadingCard extends StatelessWidget {
  const LoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: avatar + title + button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                  color:  Color(0xFFF7F4FB),
                  shape: BoxShape.circle,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .shimmer(delay: 400.ms, duration: 1800.ms, color: Colors.grey.shade400),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Container(
                      height: 16,
                      width: 190,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F4FB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    )
                        .animate(onPlay: (controller) => controller.repeat(reverse: true))
                        .shimmer(delay: 400.ms, duration: 1800.ms, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              // Button
              Container(
                height: 20,
                width: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F4FB),
                  borderRadius: BorderRadius.circular(8),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .shimmer(delay: 400.ms, duration: 1800.ms, color: Colors.grey.shade400),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: theme.dividerColor),
          const SizedBox(height: 12),
          // Body lines
          ...List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                height: 14,
                width: double.infinity ,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F4FB),
                  borderRadius: BorderRadius.circular(8),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .shimmer(delay: 400.ms, duration: 1800.ms, color: Colors.grey.shade400),
            );
          }),
        ],
      ),
    );
  }
}


class LoadingServiceDetails extends StatelessWidget {
  const LoadingServiceDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 280,
            width: double.maxFinite,
            clipBehavior: Clip.none,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F4FB),
              borderRadius: BorderRadius.circular(8),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .shimmer(
                  delay: 400.ms,
                  duration: 1800.ms,
                  color: Colors.grey.shade400),
          const Gap(16),
          Container(
            height: 17,
            width: 250,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F4FB),
              borderRadius: BorderRadius.circular(8),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .shimmer(
                  delay: 400.ms,
                  duration: 1800.ms,
                  color: Colors.grey.shade400),
          const Gap(16),
          Row(
            children: [
              Container(
                height: 24,
                width: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F4FB),
                  shape: BoxShape.circle,
                ),
              )
                  .animate(
                      onPlay: (controller) => controller.repeat(reverse: true))
                  .shimmer(
                      delay: 400.ms,
                      duration: 1800.ms,
                      color: Colors.grey.shade400),
              const Gap(10),
              Container(
                height: 17,
                width: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F4FB),
                  borderRadius: BorderRadius.circular(8),
                ),
              )
                  .animate(
                      onPlay: (controller) => controller.repeat(reverse: true))
                  .shimmer(
                      delay: 400.ms,
                      duration: 1800.ms,
                      color: Colors.grey.shade400),
            ],
          ),
          const Gap(8),
          Row(
            children: [
              Container(
                height: 24,
                width: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F4FB),
                  shape: BoxShape.circle,
                ),
              )
                  .animate(
                      onPlay: (controller) => controller.repeat(reverse: true))
                  .shimmer(
                      delay: 400.ms,
                      duration: 1800.ms,
                      color: Colors.grey.shade400),
              const Gap(10),
              Container(
                height: 17,
                width: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F4FB),
                  borderRadius: BorderRadius.circular(8),
                ),
              )
                  .animate(
                      onPlay: (controller) => controller.repeat(reverse: true))
                  .shimmer(
                      delay: 400.ms,
                      duration: 1800.ms,
                      color: Colors.grey.shade400),
            ],
          ),
          const Gap(16),
          Container(
            height: 17,
            width: 150,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F4FB),
              borderRadius: BorderRadius.circular(8),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .shimmer(
                  delay: 400.ms,
                  duration: 1800.ms,
                  color: Colors.grey.shade400),
          const Gap(16),
          Wrap(
            runSpacing: 12,
            children: List.generate(
              4,
              (index) {
                return Container(
                  height: 17,
                  width: 320,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F4FB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                )
                    .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true))
                    .shimmer(
                        delay: 400.ms,
                        duration: 1800.ms,
                        color: Colors.grey.shade400);
              },
            ),
          )
        ]),
      ),
    );
  }
}

class LoadingHomeScreen extends StatelessWidget {
  const LoadingHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              decoration: const BoxDecoration(
                color: Color(0xFFF7F4FB),
              ),
            )
                .animate(
                    onPlay: (controller) => controller.repeat(reverse: true))
                .shimmer(
                    delay: 400.ms,
                    duration: 1800.ms,
                    color: Colors.grey.shade400),
            const Gap(24),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        height: 20,
                        width: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F4FB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )
                          .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true))
                          .shimmer(
                              delay: 400.ms,
                              duration: 1800.ms,
                              color: Colors.grey.shade400),
                      const Spacer(),
                      Container(
                        height: 20,
                        width: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F4FB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )
                          .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true))
                          .shimmer(
                              delay: 400.ms,
                              duration: 1800.ms,
                              color: Colors.grey.shade400),
                    ],
                  ),
                ),
                const Gap(24),
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    itemCount: 3,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 130,
                            width: 210,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F4FB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          )
                              .animate(
                                  onPlay: (controller) =>
                                      controller.repeat(reverse: true))
                              .shimmer(
                                  delay: 400.ms,
                                  duration: 1800.ms,
                                  color: Colors.grey.shade400),
                          const Gap(8),
                          Container(
                            height: 16,
                            width: 111,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F4FB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          )
                              .animate(
                                  onPlay: (controller) =>
                                      controller.repeat(reverse: true))
                              .shimmer(
                                  delay: 400.ms,
                                  duration: 1800.ms,
                                  color: Colors.grey.shade400),
                        ],
                      );
                    },
                    separatorBuilder: (context, index) => const Gap(16),
                  ),
                ),
                const Gap(48),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        height: 20,
                        width: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F4FB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )
                          .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true))
                          .shimmer(
                              delay: 400.ms,
                              duration: 1800.ms,
                              color: Colors.grey.shade400),
                      const Spacer(),
                      Container(
                        height: 20,
                        width: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F4FB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )
                          .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true))
                          .shimmer(
                              delay: 400.ms,
                              duration: 1800.ms,
                              color: Colors.grey.shade400),
                    ],
                  ),
                ),
                const Gap(16),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    itemCount: 7,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 64,
                            width: 64,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF7F4FB),
                              shape: BoxShape.circle,
                            ),
                          )
                              .animate(
                                  onPlay: (controller) =>
                                      controller.repeat(reverse: true))
                              .shimmer(
                                  delay: 400.ms,
                                  duration: 1800.ms,
                                  color: Colors.grey.shade400),
                          const Gap(8),
                          Container(
                            height: 14,
                            width: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F4FB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          )
                              .animate(
                                  onPlay: (controller) =>
                                      controller.repeat(reverse: true))
                              .shimmer(
                                  delay: 400.ms,
                                  duration: 1800.ms,
                                  color: Colors.grey.shade400),
                        ],
                      );
                    },
                    separatorBuilder: (context, index) => const Gap(16),
                  ),
                ),
                const Gap(48),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        height: 20,
                        width: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F4FB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )
                          .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true))
                          .shimmer(
                              delay: 400.ms,
                              duration: 1800.ms,
                              color: Colors.grey.shade400),
                      const Spacer(),
                      Container(
                        height: 20,
                        width: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F4FB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )
                          .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true))
                          .shimmer(
                              delay: 400.ms,
                              duration: 1800.ms,
                              color: Colors.grey.shade400),
                    ],
                  ),
                ),
                const Gap(16),
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    itemCount: 3,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 130,
                            width: 210,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F4FB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          )
                              .animate(
                                  onPlay: (controller) =>
                                      controller.repeat(reverse: true))
                              .shimmer(
                                  delay: 400.ms,
                                  duration: 1800.ms,
                                  color: Colors.grey.shade400),
                          const Gap(8),
                          Container(
                            height: 16,
                            width: 111,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F4FB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          )
                              .animate(
                                  onPlay: (controller) =>
                                      controller.repeat(reverse: true))
                              .shimmer(
                                  delay: 400.ms,
                                  duration: 1800.ms,
                                  color: Colors.grey.shade400),
                        ],
                      );
                    },
                    separatorBuilder: (context, index) => const Gap(16),
                  ),
                ),
              ],
            ),

            // Two cards in a row
            // Row(
            //   children: [
            //     Expanded(
            //       child: Container(
            //         height: 160,
            //         decoration: BoxDecoration(
            //           color: const Color(0xFFF7F4FB),
            //           borderRadius: BorderRadius.circular(12),
            //         ),
            //       )
            //           .animate(
            //               onPlay: (controller) =>
            //                   controller.repeat(reverse: true))
            //           .shimmer(
            //               delay: 400.ms,
            //               duration: 1800.ms,
            //               color: Colors.grey.shade400),
            //     ),
            //     const Gap(16),

            //   ],
            // ),
            // const Gap(24),

            // Horizontal scroll indicators

            // // Bottom section
            // Row(
            //   children: [
            //     Container(
            //       height: 20,
            //       width: 150,
            //       decoration: BoxDecoration(
            //         color: const Color(0xFFF7F4FB),
            //         borderRadius: BorderRadius.circular(8),
            //       ),
            //     )
            //         .animate(
            //             onPlay: (controller) => controller.repeat(reverse: true))
            //         .shimmer(
            //             delay: 400.ms,
            //             duration: 1800.ms,
            //             color: Colors.grey.shade400),
            //     const Spacer(),
            //     Container(
            //       height: 20,
            //       width: 60,
            //       decoration: BoxDecoration(
            //         color: const Color(0xFFF7F4FB),
            //         borderRadius: BorderRadius.circular(8),
            //       ),
            //     )
            //         .animate(
            //             onPlay: (controller) => controller.repeat(reverse: true))
            //         .shimmer(
            //             delay: 400.ms,
            //             duration: 1800.ms,
            //             color: Colors.grey.shade400),
            //   ],
            // ),
            // const Gap(16),

            // // Bottom card
            // Container(
            //   height: 180,
            //   width: double.infinity,
            //   decoration: BoxDecoration(
            //     color: const Color(0xFFF7F4FB),
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            // )
            //     .animate(onPlay: (controller) => controller.repeat(reverse: true))
            //     .shimmer(
            //         delay: 400.ms,
            //         duration: 1800.ms,
            //         color: Colors.grey.shade400),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 100,
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            4,
            (index) => Column(
              children: [
                Container(
                  height: 24,
                  width: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7F4FB),
                    shape: BoxShape.circle,
                  ),
                )
                    .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true))
                    .shimmer(
                        delay: 400.ms,
                        duration: 1800.ms,
                        color: Colors.grey.shade400),
                const Gap(4),
                Container(
                  height: 10,
                  width: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F4FB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
                    .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true))
                    .shimmer(
                        delay: 400.ms,
                        duration: 1800.ms,
                        color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
