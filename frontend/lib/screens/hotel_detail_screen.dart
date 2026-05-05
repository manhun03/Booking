import 'package:flutter/material.dart';
import '../utils/colors.dart';

class HotelDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? hotel;

  const HotelDetailScreen({Key? key, this.hotel}) : super(key: key);

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen>
    with TickerProviderStateMixin {
  late Map<String, dynamic> hotelData;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    hotelData = widget.hotel ?? defaultHotel;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final Map<String, dynamic> defaultHotel = {
    'name': 'Grand Palais Hotel',
    'location': 'Hoàn Kiếm, Hà Nội',
    'image': '🏛️',
    'rating': 4.5,
    'reviews': 91,
    'price': '2,500,000 VND / đêm',
    'description':
        'Tọa lạc tại trung tâm Hà Nội, Grand Palais là một khách sạn 5 sao hàng đầu với các phòng rộng rãi, trang thiết bị đầy đủ và dịch vụ xuất sắc. Khách sạn cung cấp những trải nghiệm tuyệt vời cho du khách.',
    'amenities': [
      'WiFi miễn phí',
      'Nhà hàng 24/7',
      'Phòng gym',
      'Hồ bơi',
      'Dịch vụ phòng',
    ],
  };

  final Map<String, dynamic> returnPolicy = {
    'freeCancel': {
      'title': 'Chính sách hủy phòng',
      'description':
          'Khách hàng có thể hủy phòng miễn phí nếu hủy trước 48 giờ check-in. Nếu hủy sau 48 giờ, sẽ bị tính phí 50% giá phòng. Không hoàn tiền nếu hủy dưới 24 giờ trước ngày check-in.',
      'details': [
        'Hủy trước 48 giờ: Hoàn 100% tiền đã đặt',
        'Hủy 24-48 giờ: Hoàn 50% tiền đã đặt',
        'Hủy dưới 24 giờ: Không hoàn tiền',
      ],
    },
    'exchangePolicy': {
      'title': 'Chính sách đổi phòng, đổi giờ nhận/trả phòng',
      'description':
          'Khách hàng có thể yêu cầu đổi phòng hoặc thay đổi giờ nhận/trả phòng với các điều kiện sau:',
      'details': [
        'Trong trường hợp phòng loại được yêu cầu không có sẵn, chúng tôi sẽ cố gắng nâng cấp lên phòng loại tương đương hoặc cao hơn mà không tính thêm phí.',
        'Yêu cầu đổi giờ nhận/trả phòng phải được thông báo trước ít nhất 24 giờ. Phí thay đổi giờ sẽ được tính theo quy định của khách sạn.',
        'Trong trường hợp các chính sách khác nhau giữa các phòng, các điều khoản của phòng được đặt sẽ được áp dụng.',
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.colorBg,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.white,
              elevation: 0.5,
              pinned: true,
              leading: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
              ),
              title: const Text(
                'Hotel Detail',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: const Icon(
                    Icons.bookmark_border,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 250,
                    color: AppColors.colorBg,
                    child: Center(
                      child: Text(
                        hotelData['image'] ?? '🏛️',
                        style: const TextStyle(fontSize: 80),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hotelData['name'] ?? 'Hotel Name',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                size: 16, color: Colors.orange),
                            const SizedBox(width: 4),
                            Text(
                              '${hotelData['rating'] ?? 0} stars • ${hotelData['reviews'] ?? 0} reviews',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '📍 ${hotelData['location'] ?? 'Location'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '💰 ${hotelData['price'] ?? 'Price'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.colorPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tab Bar
                  Container(
                    color: AppColors.white,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: AppColors.colorPrimary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.colorPrimary,
                      tabs: const [
                        Tab(text: 'Chi tiết'),
                        Tab(text: 'Đánh giá'),
                        Tab(text: 'Chính sách'),
                      ],
                    ),
                  ),
                  // Tab Content
                  SizedBox(
                    height: 600,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Chi tiết
                        _buildDetailsTab(),
                        // Tab 2: Đánh giá
                        _buildReviewsTab(),
                        // Tab 3: Chính sách
                        _buildPolicyTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hotelData['description'] ?? 'No description',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Tiện nghi',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _buildAmenitiesSection(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.colorPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Xem phòng trống',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.colorBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${hotelData['rating'] ?? 0}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              index < (hotelData['rating'] ?? 0).toInt()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.orange,
                              size: 16,
                            ),
                          ),
                        ),
                        Text(
                          '${hotelData['reviews'] ?? 0} đánh giá',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Đánh giá từ khách hàng',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildReviewItem(
            'Nguyễn Văn A',
            5,
            'Khách sạn rất đẹp, dịch vụ tốt, nhân viên thân thiện. Tôi rất hài lòng!',
          ),
          _buildReviewItem(
            'Trần Thị B',
            4,
            'Phòng sạch sẽ, view đẹp. Nhưng nhà hàng ăn sáng có thể tốt hơn.',
          ),
          _buildReviewItem(
            'Lê Văn C',
            5,
            'Vị trí thuận tiện, gần trung tâm. Sẽ quay lại lần tới!',
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String name, int rating, String review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              review,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildPolicyContainer(),
    );
  }

  Widget _buildAmenitiesSection() {
    final amenities = hotelData['amenities'] as List?;
    if (amenities == null || amenities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var amenity in amenities)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppColors.colorSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  amenity as String? ?? 'Amenity',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPolicyContainer() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  returnPolicy['freeCancel']['title'] ?? 'Policy',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  returnPolicy['freeCancel']['description'] ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDetailsList(returnPolicy['freeCancel']['details']),
              ],
            ),
          ),
          const Divider(
            height: 1,
            color: AppColors.divider,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  returnPolicy['exchangePolicy']['title'] ?? 'Policy',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  returnPolicy['exchangePolicy']['description'] ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDetailsList(returnPolicy['exchangePolicy']['details']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsList(dynamic details) {
    if (details == null || !(details is List)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var detail in details)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Expanded(
                  child: Text(
                    detail as String? ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
