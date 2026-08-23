import 'package:flutter/material.dart';
import 'package:mwakili/component/app_colors.dart';
import 'package:mwakili/controller/RatingController.dart';
 

void _showRatingDialog(BuildContext context, int consultationId, int lawyerId) {
  int _rating = 5;
  TextEditingController _reviewController = TextEditingController();
  bool _isLoading = false; 
  final RatingController _ratingController = RatingController();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1F314D),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Center(
              child: Text(
                'تقييم الاستشارة',
                style: TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'تم إنهاء الاستشارة بنجاح، يرجى تقييم الخدمة المقدمة لك:',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textLightGray, fontSize: 14),
                ),
                const SizedBox(height: 20),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _rating ? Icons.star_rounded : Icons.star_border_rounded,
                        color: AppColors.primaryGold,
                        size: 36,
                      ),
                      onPressed: _isLoading ? null : () {
                        setDialogState(() {
                          _rating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: _reviewController,
                  maxLines: 3,
                  enabled: !_isLoading, 
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'اكتب رأيك هنا (اختياري)...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setDialogState(() => _isLoading = true);

                          bool success = await _ratingController.submitRating(
                            consultationId: consultationId,
                            lawyerId: lawyerId,
                            rating: _rating,
                            review: _reviewController.text.trim(),
                          );

                          setDialogState(() => _isLoading = false);

                          if (success) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('شكرًا لتقييمك!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('حدث خطأ أثناء الإرسال، الرجاء المحاولة مرة أخرى'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: _isLoading 
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(color: AppColors.backgroundNavy, strokeWidth: 2)
                        )
                      : const Text(
                          'إرسال التقييم',
                          style: TextStyle(color: AppColors.backgroundNavy, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              if (!_isLoading) 
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('تخطي', style: TextStyle(color: AppColors.textLightGray)),
                )
            ],
          );
        },
      );
    },
  );
}