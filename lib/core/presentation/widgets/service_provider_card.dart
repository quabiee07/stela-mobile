// import 'package:flutter/material.dart';
// import 'package:flutter_mobile_template/core/domain/model/image_model.dart';
// import 'package:flutter_mobile_template/core/presentation/resources/drawables.dart';
// import 'package:flutter_mobile_template/core/presentation/utils/navigation_mixin.dart';
// import 'package:flutter_mobile_template/core/presentation/widgets/cached_image.dart';
// import 'package:flutter_mobile_template/core/presentation/widgets/clickable.dart';
// import 'package:flutter_mobile_template/core/presentation/widgets/custom_image.dart';
// import 'package:flutter_mobile_template/core/presentation/widgets/svg_image.dart';
// import 'package:flutter_mobile_template/features/project/presentation/screens/sureplug_profile.dart';
// import 'package:gap/gap.dart';

// class ServiceProviderCard extends StatelessWidget {
//   const ServiceProviderCard({
//     super.key,
//     this.avatar,
//     required this.name,
//     required this.isVerified,
//     this.rating,
//     this.reviews,
//     this.role,
//   });
//   final ImageModel? avatar;
//   final String name;
//   final bool isVerified;
//   final String? rating;
//   final String? reviews;
//   final String? role;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//           color: const Color(0xFFF7F4FB),
//           borderRadius: BorderRadius.circular(8)),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(50),
//             child: avatar == null
//                 ? const CustomImage(
//                     asset: phto,
//                     height: 30,
//                     width: 30,
//                   )
//                 : CachedImage(
//                     asset: avatar!.url,
//                     height: 40,
//                     width: 40,
//                   ),
//           ),
//           const Gap(10),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Text(
//                     name,
//                     style: theme.textTheme.bodyLarge?.copyWith(fontSize: 13),
//                   ),
//                   if (isVerified) ...[
//                     const Gap(6),
//                     Icon(
//                       Icons.verified_rounded,
//                       color: theme.colorScheme.tertiary,
//                       size: 15,
//                     ),
//                   ],
//                 ],
//               ),
//               const Gap(4),
//               rating == null && reviews == null && role != null
//                   ? Row(
//                       spacing: 5,
//                       children: [
//                         const SvgImage(asset: userGear),
//                         Text(
//                           role!,
//                           style:
//                               theme.textTheme.bodySmall?.copyWith(fontSize: 12),
//                         ),
//                       ],
//                     )
//                   : Row(
//                       spacing: 5,
//                       children: [
//                         const SvgImage(asset: star),
//                         const Gap(4),
//                         Text(
//                           " $rating ($reviews)",
//                           style:
//                               theme.textTheme.bodySmall?.copyWith(fontSize: 12),
//                         ),
//                       ],
//                     ),
//             ],
//           ),
//           const Spacer(),
//           Clickable(
//             onPressed: () {
//               context.animPush(const SureplugProfileScreen());
//             },
//             child: Row(
//               children: [
//                 Text(
//                   'View Profile',
//                   overflow: TextOverflow.ellipsis,
//                   style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
//                 ),
//                 const Gap(4),
//                 const Icon(
//                   Icons.keyboard_arrow_right_rounded,
//                   color: Color(0xFF641BB4),
//                   size: 15,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
