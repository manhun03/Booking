import 'package:flutter/material.dart';

import '../utils/colors.dart';
import 'widgets/responsive_page.dart';

class CancelBookingScreen extends StatelessWidget {
  const CancelBookingScreen({
    Key? key,
    this.booking,
  }) : super(key: key);

  final Map<String, dynamic>? booking;

  @override
  Widget build(BuildContext context) {
    return ResponsivePageScaffold(
      mobileBody: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(40, 12, 40, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate(_buildContent(context)),
            ),
          ),
        ],
      ),
      desktopBody: WebAppShell(
        title: 'Hủy đặt phòng',
        subtitle:
            'Xác nhận hủy toàn bộ phòng trong đơn. Nội dung được tách thành card để người dùng web đọc và thao tác rõ ràng.',
        selectedIndex: 2,
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: WebPanel(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildContent(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent(BuildContext context) {
    return [
      const Text(
        'Bạn sẽ hủy toàn bộ phòng đã đặt khi bấm nút xác nhận hủy. Bạn có chắc chắn hủy?',
        style: TextStyle(
          fontSize: 14,
          height: 1.18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      const SizedBox(height: 26),
      _buildConfirmButton(context),
    ];
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.arrow_back,
                size: 20,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Hủy đặt phòng',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/booking',
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.colorPrimary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
          ),
          padding: EdgeInsets.zero,
        ),
        child: const Text(
          'Xác nhận hủy',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
