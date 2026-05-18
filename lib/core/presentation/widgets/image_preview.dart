import 'package:flutter/material.dart';
import 'package:stela_mobile/core/presentation/widgets/pop_widget.dart';

// import 'package:photo_view/photo_view.dart';
// import 'package:photo_view/photo_view_gallery.dart';

class ImagePreviewWidget extends StatefulWidget {
  const ImagePreviewWidget({super.key, this.attachments, this.images});
  final List<dynamic>? attachments;
  final List<dynamic>? images;
  @override
  State<ImagePreviewWidget> createState() => _ImagePreviewWidgetState();
}

class _ImagePreviewWidgetState extends State<ImagePreviewWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: PopWidget(),
        ),
        backgroundColor: Colors.white,
        title: Text(
          'Image Preview',
          style: theme.textTheme.labelLarge?.copyWith(
            fontSize: 16,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GalleryPhotoViewWrapper(
              galleryItems: widget.attachments ?? widget.images ?? [],
              backgroundDecoration: const BoxDecoration(
                color: Colors.black,
              ),
              initialIndex: 0,
              scrollDirection: Axis.horizontal,
            ),
          ),
        ],
      ),
    );
  }
}

class GalleryPhotoViewWrapper extends StatefulWidget {
  GalleryPhotoViewWrapper({
    super.key,
    // this.loadingBuilder,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialIndex = 0,
    required this.galleryItems,
    this.scrollDirection = Axis.horizontal,
  }) : pageController = PageController(initialPage: initialIndex);

  // final LoadingBuilder? loadingBuilder;
  final BoxDecoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final int initialIndex;
  final PageController pageController;
  final List<dynamic> galleryItems;
  final Axis scrollDirection;

  @override
  State<StatefulWidget> createState() {
    return _GalleryPhotoViewWrapperState();
  }
}

class _GalleryPhotoViewWrapperState extends State<GalleryPhotoViewWrapper> {
  late int currentIndex = widget.initialIndex;

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: widget.backgroundDecoration,
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
      //       PhotoViewGallery.builder(
      //         scrollPhysics: const BouncingScrollPhysics(),
      //         builder: _buildItem,
      //         itemCount: widget.galleryItems.length,
      //         loadingBuilder: widget.loadingBuilder,
      //         backgroundDecoration: widget.backgroundDecoration,
      //         pageController: widget.pageController,
      //         onPageChanged: onPageChanged,
      //         scrollDirection: widget.scrollDirection,
      //       ),
      //       Align(
      //         alignment: Alignment.bottomCenter,
      //         child: Container(
      //           padding: const EdgeInsets.all(20.0),
      //           child: Text(
      //             "${currentIndex + 1}/${widget.galleryItems.length}",
      //             style: const TextStyle(
      //               color: Colors.white,
      //               fontSize: 17.0,
      //               decoration: null,
      //             ),
      //           ),
      //         ),
      //       )
          ],
        ),
      ),
    );
  }

  // PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
  //   // final item = widget.galleryItems[index];

  //   String imageUrl = '';
  //   String heroTag = '';

  //   // if (item is AttachmentModel) {
  //   //   imageUrl = item.path; // assuming `path` holds URL
  //   //   heroTag = item.id;
  //   // } else if (item is ImageModel) {
  //   //   imageUrl = item.url; // assuming `url` holds URL in ImageModel
  //   //   heroTag = item.id;
  //   // } else {
  //   //   throw Exception('Unsupported item type: ${item.runtimeType}');
  //   // }

  //   return PhotoViewGalleryPageOptions(
  //     imageProvider: NetworkImage(imageUrl),
  //     initialScale: PhotoViewComputedScale.contained,
  //     minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
  //     maxScale: PhotoViewComputedScale.covered * 4.1,
  //     heroAttributes: PhotoViewHeroAttributes(tag: heroTag),
  //   );
  // }
}
