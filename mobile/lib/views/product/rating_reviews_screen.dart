import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../widgets/safe_network_image.dart';

class RatingReviewsScreen extends StatefulWidget {
  const RatingReviewsScreen({super.key});

  @override
  State<RatingReviewsScreen> createState() => _RatingReviewsScreenState();
}

class _RatingReviewsScreenState extends State<RatingReviewsScreen> {
  bool _withPhotoOnly = false;
  bool _isLoading = true;
  int? _productId;
  bool _didLoad = false;

  List<Map<String, dynamic>> _reviews = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _productId = args?['productId'] is int ? args!['productId'] as int : null;
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final productId = _productId;
    if (productId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    try {
      final data = await ApiService.reviews(productId);
      if (!mounted) return;
      setState(() {
        _reviews = data
            .map((item) => _mapReview(item as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cannot load reviews: $error')));
    }
  }

  Map<String, dynamic> _mapReview(Map<String, dynamic> review) {
    final customer = review['customer'] as Map<String, dynamic>?;
    final firstName = customer?['firstName'] ?? '';
    final lastName = customer?['lastName'] ?? '';
    final name = '$firstName $lastName'.trim();
    final photos = (review['images'] as List?) ?? [];
    return {
      "name": name.isEmpty ? 'Customer' : name,
      "avatar": "assets/picture/catalog1/blouse.webp",
      "stars": review['rating'] ?? 5,
      "date": '${review['createdAt'] ?? ''}'.split('T').first,
      "content": review['comment'] ?? '',
      "helpful": false,
      "hasPhoto": photos.isNotEmpty,
      "photos": photos,
    };
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0;
    final total = _reviews.fold<int>(
      0,
      (sum, review) => sum + ((review['stars'] ?? 0) as int),
    );
    return total / _reviews.length;
  }

  int _ratingCount(int stars) {
    return _reviews.where((review) => review['stars'] == stars).length;
  }

  Future<String> _savePickedReviewPhoto(XFile photo) async {
    final directory = await getApplicationDocumentsDirectory();
    final originalName = photo.name.trim().isEmpty
        ? photo.path.split('/').last
        : photo.name.trim();
    final extension = originalName.contains('.')
        ? originalName.substring(originalName.lastIndexOf('.'))
        : '.jpg';
    final targetPath =
        '${directory.path}/review_${DateTime.now().microsecondsSinceEpoch}$extension';
    final savedFile = await File(photo.path).copy(targetPath);
    return savedFile.path;
  }

  @override
  Widget build(BuildContext context) {
    // Lọc reviews nếu "With photo" được chọn
    final filteredReviews = _withPhotoOnly
        ? _reviews.where((r) => r['hasPhoto'] == true).toList()
        : _reviews;

    final average = _averageRating;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textBlack,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed),
            )
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 80,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      const Text(
                        'Rating&Reviews',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Ratings overview
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Average score
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                average.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textBlack,
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                '${_reviews.length} ratings',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 24),
                          // Progress bars
                          Expanded(
                            child: Column(
                              children: [
                                _buildRatingRow(
                                  5,
                                  _reviews.isEmpty
                                      ? 0
                                      : _ratingCount(5) / _reviews.length,
                                  _ratingCount(5),
                                ),
                                _buildRatingRow(
                                  4,
                                  _reviews.isEmpty
                                      ? 0
                                      : _ratingCount(4) / _reviews.length,
                                  _ratingCount(4),
                                ),
                                _buildRatingRow(
                                  3,
                                  _reviews.isEmpty
                                      ? 0
                                      : _ratingCount(3) / _reviews.length,
                                  _ratingCount(3),
                                ),
                                _buildRatingRow(
                                  2,
                                  _reviews.isEmpty
                                      ? 0
                                      : _ratingCount(2) / _reviews.length,
                                  _ratingCount(2),
                                ),
                                _buildRatingRow(
                                  1,
                                  _reviews.isEmpty
                                      ? 0
                                      : _ratingCount(1) / _reviews.length,
                                  _ratingCount(1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Review Header & Checkbox
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${filteredReviews.length} reviews',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textBlack,
                            ),
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: _withPhotoOnly,
                                activeColor: AppColors.textBlack,
                                onChanged: (val) {
                                  setState(() {
                                    _withPhotoOnly = val ?? false;
                                  });
                                },
                              ),
                              const Text(
                                'With photo',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textBlack,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Reviews List
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredReviews.length,
                        itemBuilder: (context, index) {
                          final review = filteredReviews[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Card container
                                Container(
                                  margin: const EdgeInsets.only(
                                    left: 20,
                                    top: 10,
                                  ),
                                  padding: const EdgeInsets.only(
                                    left: 24,
                                    right: 16,
                                    top: 20,
                                    bottom: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Name
                                      Text(
                                        review['name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColors.textBlack,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Stars & Date
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: List.generate(5, (sIdx) {
                                              return Icon(
                                                sIdx < review['stars']
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                color: Colors.amber,
                                                size: 14,
                                              );
                                            }),
                                          ),
                                          Text(
                                            review['date'],
                                            style: const TextStyle(
                                              color: AppColors.textGrey,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Content
                                      Text(
                                        review['content'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          height: 1.4,
                                          color: AppColors.textBlack,
                                        ),
                                      ),
                                      // Photos row
                                      if (review['photos'] != null &&
                                          (review['photos'] as List)
                                              .isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          height: 104,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount:
                                                (review['photos'] as List)
                                                    .length,
                                            itemBuilder: (context, pIdx) {
                                              return Container(
                                                width: 104,
                                                margin: const EdgeInsets.only(
                                                  right: 12,
                                                ),
                                                child: SafeNetworkImage(
                                                  url: review['photos'][pIdx],
                                                  width: 104,
                                                  height: 104,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 16),
                                      // Helpful interaction
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Text(
                                            'Helpful',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textGrey,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                review['helpful'] =
                                                    !(review['helpful']
                                                        as bool);
                                              });
                                            },
                                            child: Icon(
                                              Icons.thumb_up,
                                              size: 14,
                                              color: review['helpful'] as bool
                                                  ? AppColors.primaryRed
                                                  : AppColors.textGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Overlapping Circular Avatar
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.white,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: SafeNetworkImage(
                                        url: review['avatar'],
                                        width: 36,
                                        height: 36,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Floating pill FAB "Write a review"
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => _showWriteReviewBottomSheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 6,
                        shadowColor: AppColors.primaryRed.withOpacity(0.4),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      icon: const Icon(
                        Icons.edit,
                        color: AppColors.white,
                        size: 18,
                      ),
                      label: const Text(
                        'Write a review',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Helper rating bar builder
  Widget _buildRatingRow(int starCount, double progressValue, int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      height: 14,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Stars Row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              return Icon(
                Icons.star,
                color: index < starCount ? Colors.amber : Colors.transparent,
                size: 12,
              );
            }),
          ),
          const SizedBox(width: 8),
          // Progress bar
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progressValue,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryRed,
                ),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Number count
          SizedBox(
            width: 16,
            child: Text(
              '$count',
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 12, color: AppColors.textBlack),
            ),
          ),
        ],
      ),
    );
  }

  // Show Write Review Bottom Sheet
  void _showWriteReviewBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _WriteReviewSheet(
        productId: _productId,
        savePhoto: _savePickedReviewPhoto,
        onSubmitted: _loadReviews,
      ),
    );
  }
}

class _WriteReviewSheet extends StatefulWidget {
  final int? productId;
  final Future<String> Function(XFile photo) savePhoto;
  final Future<void> Function() onSubmitted;

  const _WriteReviewSheet({
    required this.productId,
    required this.savePhoto,
    required this.onSubmitted,
  });

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _controller = TextEditingController();
  final List<String> _photos = [];
  int _rating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImages(ImageSource source) async {
    try {
      final remainingSlots = 4 - _photos.length;
      if (remainingSlots <= 0) {
        _showMessage('Max 4 photos allowed.');
        return;
      }

      if (source == ImageSource.camera) {
        final photo = await _imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 78,
          maxWidth: 1400,
        );
        if (photo == null) return;
        final savedPath = await widget.savePhoto(photo);
        if (!mounted) return;
        setState(() {
          _photos.add(savedPath);
        });
        return;
      }

      final photos = await _imagePicker.pickMultiImage(
        imageQuality: 78,
        maxWidth: 1400,
      );
      if (photos.isEmpty) return;
      final savedPaths = await Future.wait(
        photos.take(remainingSlots).map(widget.savePhoto),
      );
      if (!mounted) return;
      setState(() {
        _photos.addAll(savedPaths);
      });
    } catch (error) {
      if (!mounted) return;
      _showMessage('Cannot pick photo: $error');
    }
  }

  Future<void> _showPhotoSourceSheet() async {
    FocusScope.of(context).unfocus();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source != null) {
      await _pickImages(source);
    }
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      _showMessage('Please select a rating!');
      return;
    }
    final reviewText = _controller.text.trim();
    if (reviewText.isEmpty) {
      _showMessage('Please enter your review!');
      return;
    }
    final productId = widget.productId;
    if (productId == null) {
      _showMessage('Cannot find product to review');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });
    try {
      await ApiService.addReview(
        productId,
        rating: _rating,
        comment: reviewText,
        images: List<String>.from(_photos),
      );
      if (!mounted) return;
      Navigator.pop(context);
      await widget.onSubmitted();
      if (!mounted) return;
      _showMessage('Review sent successfully!');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      _showMessage('Cannot send review: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        padding: const EdgeInsets.only(
          top: 12,
          bottom: 32,
          left: 16,
          right: 16,
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.textGrey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'What is you rate?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final isSelected = index < _rating;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        isSelected ? Icons.star : Icons.star_border,
                        color: isSelected ? Colors.amber : AppColors.textGrey,
                        size: 36,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              const Text(
                'Please share your opinion\nabout the product',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  minLines: 3,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    hintText: 'Your review',
                    hintStyle: TextStyle(color: AppColors.textGrey),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 92,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...List.generate(_photos.length, (idx) {
                      return Container(
                        width: 72,
                        height: 72,
                        margin: const EdgeInsets.only(right: 12),
                        child: Stack(
                          children: [
                            SafeNetworkImage(
                              url: _photos[idx],
                              width: 72,
                              height: 72,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _photos.removeAt(idx);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryRed,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 10,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    GestureDetector(
                      onTap: _showPhotoSourceSheet,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryRed,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: AppColors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Add your photos',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    disabledBackgroundColor: AppColors.primaryRed.withOpacity(
                      0.55,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.primaryRed.withOpacity(0.4),
                  ),
                  child: Text(
                    _isSubmitting ? 'SENDING...' : 'SEND REVIEW',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
