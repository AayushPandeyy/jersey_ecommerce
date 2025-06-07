import 'package:flutter/material.dart';

class ImageViewerWidget extends StatefulWidget {
  final List<String> imageUrls;
  final double? height;
  final double? width;
  final double thumbnailWidth;
  final double thumbnailHeight;
  final BorderRadius borderRadius;
  final Color? selectedBorderColor;
  final double selectedBorderWidth;
  final EdgeInsets? padding;
  final double spacing;

  const ImageViewerWidget({
    super.key,
    required this.imageUrls,
    this.height = 400,
    this.width,
    this.thumbnailWidth = 80,
    this.thumbnailHeight = 90,
    this.borderRadius = const BorderRadius.all(Radius.circular(0)),
    this.selectedBorderColor = Colors.blue,
    this.selectedBorderWidth = 2.0,
    this.padding,
    this.spacing = 8.0,
  });

  @override
  _ImageViewerWidgetState createState() => _ImageViewerWidgetState();
}

class _ImageViewerWidgetState extends State<ImageViewerWidget> {
  int selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 64,
            color: Colors.grey[400],
          ),
        ),
      );
    }

    return Container(
      height: widget.height,
      width: widget.width,
      padding: widget.padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main image container
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: widget.borderRadius ,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: widget.borderRadius ,
                child: Image.network(
                  widget.imageUrls[selectedImageIndex],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          SizedBox(width: widget.spacing),

          // Thumbnail gallery
          SizedBox(
            width: widget.thumbnailWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                  widget.imageUrls.asMap().entries.map((entry) {
                    int index = entry.key;
                    String imageUrl = entry.value;
                    bool isSelected = index == selectedImageIndex;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedImageIndex = index;
                        });
                      },
                      child: Container(
                        height: widget.thumbnailHeight,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                isSelected
                                    ? (widget.selectedBorderColor ??
                                        Colors.blue)
                                    : Colors.transparent,
                            width: widget.selectedBorderWidth,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 20,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
