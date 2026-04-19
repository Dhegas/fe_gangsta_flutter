import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/booking_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/table_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/table_status.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/waitlist_entry_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/presentation/controllers/table_management_controller.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/presentation/state/table_management_state.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/widgets/merchant_sidebar.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/presentation/widgets/merchant_top_bar.dart';
import 'package:fe_gangsta_flutter/features/merchant/shared/merchant_bottom_nav.dart';
import 'package:fe_gangsta_flutter/features/merchant/shared/merchant_navigation.dart';
import 'package:flutter/material.dart';

class TableStatusPage extends StatefulWidget {
  const TableStatusPage({super.key, this.onNavigate});

  final ValueChanged<MerchantNavItem>? onNavigate;

  @override
  State<TableStatusPage> createState() => _TableStatusPageState();
}

class _TableStatusPageState extends State<TableStatusPage> {
  late final TableManagementController _controller;
  final MerchantNavItem _selectedNav = MerchantNavItem.tables;

  @override
  void initState() {
    super.initState();
    _controller = TableManagementController()..addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1120;
        final isTablet = constraints.maxWidth >= 760;

        return Scaffold(
          backgroundColor: AppColors.surfaceNeutral,
          bottomNavigationBar: isDesktop
              ? null
              : MerchantBottomNav(
                  selectedItem: _selectedNav,
                  onTapItem: _handleNavTap,
                ),
          body: SafeArea(
            child: Row(
              children: [
                if (isDesktop)
                  MerchantSidebar(
                    merchantName: 'Bistro Moderne',
                    merchantRoleLabel: 'Kitchen Lead',
                    selectedItem: _selectedNav,
                    onTapItem: _handleNavTap,
                  ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? AppSpacing.space6 : AppSpacing.space4,
                      AppSpacing.space4,
                      isDesktop ? AppSpacing.space6 : AppSpacing.space4,
                      AppSpacing.space4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MerchantTopBar(
                          onSearchChanged: (_) {},
                          isCompact: !isTablet,
                        ),
                        const SizedBox(height: AppSpacing.space5),
                        _TableHeader(
                          onAddTable: _showAddTableDialog,
                          onEditTable: _showEditTableToast,
                          onDeleteTable: _showDeleteTableToast,
                        ),
                        const SizedBox(height: AppSpacing.space4),
                        Expanded(
                          child: isDesktop
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: _buildManagementSection(state: state, isCompact: false),
                                    ),
                                    const SizedBox(width: AppSpacing.space4),
                                    Expanded(
                                      flex: 2,
                                      child: _buildReservationAndPosSection(state: state, isCompact: false),
                                    ),
                                  ],
                                )
                              : ListView(
                                  physics: const BouncingScrollPhysics(),
                                  children: [
                                    _buildManagementSection(state: state, isCompact: true),
                                    const SizedBox(height: AppSpacing.space4),
                                    _buildReservationAndPosSection(state: state, isCompact: true),
                                    const SizedBox(height: AppSpacing.space16),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildManagementSection({
    required TableManagementState state,
    required bool isCompact,
  }) {
    return Column(
      children: [
        _TableFilters(
          selectedZone: state.selectedZone,
          selectedStatus: state.selectedStatus,
          onZoneChanged: _controller.setSelectedZone,
          onStatusChanged: _controller.setSelectedStatus,
        ),
        const SizedBox(height: AppSpacing.space3),
        if (isCompact)
          _TableLayoutBoard(
            tables: state.filteredTables,
            selectedTableId: state.currentTable.id,
            onSwapTablePosition: _controller.swapTableById,
            onSelectTable: _controller.selectTable,
            isCompact: true,
          )
        else
          Expanded(
            child: _TableLayoutBoard(
              tables: state.filteredTables,
              selectedTableId: state.currentTable.id,
              onSwapTablePosition: _controller.swapTableById,
              onSelectTable: _controller.selectTable,
            ),
          ),
        if (isCompact)
          const SizedBox(height: AppSpacing.space2),
        if (isCompact)
          _WaitlistCard(
            waitlist: state.waitlist,
            onAutoAssign: _autoAssignFromWaitlist,
            listHeight: 180,
          ),
      ],
    );
  }

  Widget _buildReservationAndPosSection({
    required TableManagementState state,
    required bool isCompact,
  }) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: isCompact,
      children: [
        _ReservationCard(
          bookings: state.bookings,
          onCreateBooking: _showCreateBookingToast,
          onDetectConflict: _showConflictToast,
          onManualOverride: _showManualOverrideToast,
        ),
        const SizedBox(height: AppSpacing.space3),
        _PosIntegrationCard(
          selectedTable: state.currentTable,
          onOpenOrder: _showOpenOrderToast,
          onSplitBill: _showSplitBillToast,
          onMergeTable: _showMergeTableToast,
          onMoveTable: _showMoveTableToast,
          onCloseTable: _closeCurrentTable,
        ),
        if (!isCompact) ...[
          const SizedBox(height: AppSpacing.space3),
          _WaitlistCard(
            waitlist: state.waitlist,
            onAutoAssign: _autoAssignFromWaitlist,
            listHeight: 220,
          ),
        ],
        const SizedBox(height: AppSpacing.space2),
      ],
    );
  }

  void _handleNavTap(MerchantNavItem item) {
    if (widget.onNavigate != null) {
      widget.onNavigate!(item);
      return;
    }

    navigateToMerchantSection(context, item, MerchantNavItem.tables);
  }

  void _showAddTableDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Table'),
        content: const Text(
          'UI ini sudah siap untuk flow Add/Edit/Delete table. Hubungkan ke datasource untuk simpan perubahan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showEditTableToast() {
    _showToast('Edit meja ${_controller.state.currentTable.id} siap dihubungkan ke form update.');
  }

  void _showDeleteTableToast() {
    _showToast('Hapus meja ${_controller.state.currentTable.id} siap dihubungkan ke konfirmasi delete.');
  }

  void _showCreateBookingToast() {
    _showToast('Form booking (nama, pax, waktu, durasi, reminder, deposit) siap diintegrasikan.');
  }

  void _showConflictToast() {
    _showToast('Conflict detection: tidak ada bentrok jadwal untuk slot terpilih.');
  }

  void _showManualOverrideToast() {
    _showToast('Manual override aktif: staff bisa memilih meja secara langsung.');
  }

  void _showOpenOrderToast() {
    _showToast('Meja ${_controller.state.currentTable.id} dibuka ke POS order.');
  }

  void _showSplitBillToast() {
    _showToast('Split bill untuk meja ${_controller.state.currentTable.id} siap diproses.');
  }

  void _showMergeTableToast() {
    _showToast('Merge table flow siap dihubungkan ke pemilihan meja target.');
  }

  void _showMoveTableToast() {
    _showToast('Move table flow siap dihubungkan ke denah meja.');
  }

  void _closeCurrentTable() {
    _showToast(_controller.closeCurrentTable());
  }

  void _autoAssignFromWaitlist(WaitlistEntryEntity entry) {
    _showToast(_controller.autoAssignFromWaitlist(entry));
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({
    required this.onAddTable,
    required this.onEditTable,
    required this.onDeleteTable,
  });

  final VoidCallback onAddTable;
  final VoidCallback onEditTable;
  final VoidCallback onDeleteTable;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.space3,
          runSpacing: AppSpacing.space3,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Tables Management & Booking',
              style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            FilledButton.icon(
              onPressed: onAddTable,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Table'),
            ),
            OutlinedButton.icon(
              onPressed: onEditTable,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit'),
            ),
            OutlinedButton.icon(
              onPressed: onDeleteTable,
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Delete'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space2),
        Text(
          'Manage table availability, walk-in + reservation, and POS table flow in one workspace.',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _TableFilters extends StatelessWidget {
  const _TableFilters({
    required this.selectedZone,
    required this.selectedStatus,
    required this.onZoneChanged,
    required this.onStatusChanged,
  });

  final String selectedZone;
  final TableStatus? selectedStatus;
  final ValueChanged<String> onZoneChanged;
  final ValueChanged<TableStatus?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    const zones = ['All', 'Indoor', 'Outdoor', 'VIP'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space3),
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.surfaceStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Zone / Area', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.space2),
          Wrap(
            spacing: AppSpacing.space2,
            runSpacing: AppSpacing.space2,
            children: zones
                .map(
                  (zone) => ChoiceChip(
                    label: Text(zone),
                    selected: selectedZone == zone,
                    onSelected: (_) => onZoneChanged(zone),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.space3),
          Text('Status', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.space2),
          Wrap(
            spacing: AppSpacing.space2,
            runSpacing: AppSpacing.space2,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: selectedStatus == null,
                onSelected: (_) => onStatusChanged(null),
              ),
              ...TableStatus.values.map(
                (status) => FilterChip(
                  avatar: Icon(Icons.circle, size: 12, color: _statusColor(status)),
                  label: Text(_statusLabel(status)),
                  selected: selectedStatus == status,
                  onSelected: (_) => onStatusChanged(status),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TableLayoutBoard extends StatelessWidget {
  const _TableLayoutBoard({
    required this.tables,
    required this.selectedTableId,
    required this.onSwapTablePosition,
    required this.onSelectTable,
    this.isCompact = false,
  });

  final List<TableEntity> tables;
  final String selectedTableId;
  final void Function(String draggedId, String targetId) onSwapTablePosition;
  final ValueChanged<String> onSelectTable;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    Widget buildGrid() {
      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
            return const SizedBox.shrink();
          }

          const gridSpacing = AppSpacing.space2;
          final columns = constraints.maxWidth >= 900
              ? 5
              : constraints.maxWidth >= 620
                  ? 4
                  : 3;
          final availableWidth = constraints.maxWidth - ((columns - 1) * gridSpacing);
          final tileWidth = (availableWidth > 0 ? availableWidth : 0.0) / columns;
          
          if (tileWidth <= 0 || !tileWidth.isFinite) return const SizedBox.shrink();

          const targetTileHeight = 124.0;
          final childAspectRatio =
              (tileWidth / targetTileHeight).clamp(0.5, 1.7).toDouble();
          final tileHeight = tileWidth / childAspectRatio;

          return GridView.builder(
            itemCount: tables.length,
            physics: const BouncingScrollPhysics(),
            shrinkWrap: false,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: AppSpacing.space2,
              crossAxisSpacing: AppSpacing.space2,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (context, index) {
              final table = tables[index];

              return DragTarget<String>(
                onWillAcceptWithDetails: (details) => details.data != table.id,
                onAcceptWithDetails: (details) {
                  onSwapTablePosition(details.data, table.id);
                },
                builder: (context, candidateData, rejectedData) {
                  final isHover = candidateData.isNotEmpty;

                  return Draggable<String>(
                    data: table.id,
                    feedback: Material(
                      color: Colors.transparent,
                      child: SizedBox(
                        width: tileWidth,
                        height: tileHeight,
                        child: _TableTile(
                          table: table,
                          isSelected: selectedTableId == table.id,
                          highlight: true,
                        ),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.35,
                      child: _TableTile(
                        table: table,
                        isSelected: selectedTableId == table.id,
                        highlight: isHover,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () => onSelectTable(table.id),
                      child: _TableTile(
                        table: table,
                        isSelected: selectedTableId == table.id,
                        highlight: isHover,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space3),
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.surfaceStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Drag & Drop Table Layout',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              const Icon(Icons.grid_view_rounded, color: AppColors.textMuted, size: 18),
            ],
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            'Visual floor plan for indoor, outdoor, and VIP areas.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space3),
          if (isCompact)
            SizedBox(
              height: 300,
              child: buildGrid(),
            )
          else
            Expanded(
              child: buildGrid(),
            ),
        ],
      ),
    );
  }
}

class _TableTile extends StatelessWidget {
  const _TableTile({
    required this.table,
    required this.isSelected,
    this.highlight = false,
  });

  final TableEntity table;
  final bool isSelected;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(table.status);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(AppSpacing.space2),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surfaceNeutral,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: highlight
              ? AppColors.primary
              : isSelected
                  ? AppColors.primary
                  : AppColors.surfaceStrong,
          width: highlight || isSelected ? 1.6 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.drag_indicator_rounded, color: AppColors.textMuted, size: 14),
              Icon(Icons.circle, size: 8, color: statusColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            table.id,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            '${table.capacity} pax • ${table.zone}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Text(
              _statusLabel(table.status),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.bookings,
    required this.onCreateBooking,
    required this.onDetectConflict,
    required this.onManualOverride,
  });

  final List<BookingEntity> bookings;
  final VoidCallback onCreateBooking;
  final VoidCallback onDetectConflict;
  final VoidCallback onManualOverride;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space3),
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.surfaceStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Reservation System',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              FilledButton.tonalIcon(
                onPressed: onCreateBooking,
                icon: const Icon(Icons.add_alarm_rounded),
                label: const Text('New Booking'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            'Walk-in + reservation with auto assignment and manual override.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space3),
          _FormStubRow(label: 'Customer Name', value: 'Nadya Putri'),
          _FormStubRow(label: 'Pax', value: '2 orang'),
          _FormStubRow(label: 'Arrival', value: '19:00'),
          _FormStubRow(label: 'Duration', value: '60 menit'),
          const SizedBox(height: AppSpacing.space2),
          Wrap(
            spacing: AppSpacing.space2,
            runSpacing: AppSpacing.space2,
            children: [
              OutlinedButton.icon(
                onPressed: onDetectConflict,
                icon: const Icon(Icons.rule_folder_outlined),
                label: const Text('Detect Conflict'),
              ),
              OutlinedButton.icon(
                onPressed: onManualOverride,
                icon: const Icon(Icons.touch_app_outlined),
                label: const Text('Manual Override'),
              ),
              Chip(
                avatar: const Icon(Icons.notifications_active_outlined, size: 16),
                label: const Text('Reminder WA/Email'),
                backgroundColor: AppColors.surfaceNeutral,
              ),
              Chip(
                avatar: const Icon(Icons.account_balance_wallet_outlined, size: 16),
                label: const Text('Deposit Ready'),
                backgroundColor: AppColors.surfaceNeutral,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          Text(
            'Booking Calendar (Today)',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.space2),
          SizedBox(
            height: 138,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                return _BookingTile(booking: bookings[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FormStubRow extends StatelessWidget {
  const _FormStubRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          const Text(':'),
          const SizedBox(width: AppSpacing.space2),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  const _BookingTile({required this.booking});

  final BookingEntity booking;

  @override
  Widget build(BuildContext context) {
    final color = _bookingColor(booking.status);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.space2),
      padding: const EdgeInsets.all(AppSpacing.space2),
      decoration: BoxDecoration(
        color: AppColors.surfaceNeutral,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.event_seat_outlined, size: 16, color: color),
          const SizedBox(width: AppSpacing.space2),
          Expanded(
            child: Text(
              '${booking.startTime} • ${booking.customerName} (${booking.pax} pax) • ${booking.assignedTableId}',
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.space2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Text(
              _bookingLabel(booking.status),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PosIntegrationCard extends StatelessWidget {
  const _PosIntegrationCard({
    required this.selectedTable,
    required this.onOpenOrder,
    required this.onSplitBill,
    required this.onMergeTable,
    required this.onMoveTable,
    required this.onCloseTable,
  });

  final TableEntity selectedTable;
  final VoidCallback onOpenOrder;
  final VoidCallback onSplitBill;
  final VoidCallback onMergeTable;
  final VoidCallback onMoveTable;
  final VoidCallback onCloseTable;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space3),
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.surfaceStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Table → POS Integration',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            'Selected: ${selectedTable.id} • ${selectedTable.capacity} pax',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space2),
          Wrap(
            spacing: AppSpacing.space2,
            runSpacing: AppSpacing.space2,
            children: [
              FilledButton.icon(
                onPressed: onOpenOrder,
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text('Open Order'),
              ),
              OutlinedButton(onPressed: onSplitBill, child: const Text('Split Bill')),
              OutlinedButton(onPressed: onMergeTable, child: const Text('Merge Tables')),
              OutlinedButton(onPressed: onMoveTable, child: const Text('Move Table')),
              OutlinedButton.icon(
                onPressed: onCloseTable,
                icon: const Icon(Icons.task_alt_rounded),
                label: const Text('Close Table'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            'Real-time Sync: multi-device ready (kasir, waiter, kitchen).',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _WaitlistCard extends StatelessWidget {
  const _WaitlistCard({
    required this.waitlist,
    required this.onAutoAssign,
    required this.listHeight,
  });

  final List<WaitlistEntryEntity> waitlist;
  final ValueChanged<WaitlistEntryEntity> onAutoAssign;
  final double listHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space3),
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.surfaceStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Waitlist System',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            'Queue customer and auto assign table when available.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space3),
          SizedBox(
            height: listHeight,
            child: waitlist.isEmpty
                ? Center(
                    child: Text(
                      'No waitlist sekarang.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
                    ),
                  )
                : ListView.builder(
                    itemCount: waitlist.length,
                    itemBuilder: (context, index) {
                      final entry = waitlist[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.space2),
                        padding: const EdgeInsets.all(AppSpacing.space2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceNeutral,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${entry.name} • ${entry.pax} pax • ETA ${entry.etaMinutes}m',
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton(
                              onPressed: () => onAutoAssign(entry),
                              child: const Text('Auto Assign'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(TableStatus status) {
  switch (status) {
    case TableStatus.available:
      return AppColors.statusSuccess;
    case TableStatus.occupied:
      return AppColors.statusError;
    case TableStatus.reserved:
      return AppColors.statusWarning;
    case TableStatus.cleaning:
      return AppColors.textMuted;
  }
}

String _statusLabel(TableStatus status) {
  switch (status) {
    case TableStatus.available:
      return 'Available';
    case TableStatus.occupied:
      return 'Occupied';
    case TableStatus.reserved:
      return 'Reserved';
    case TableStatus.cleaning:
      return 'Cleaning';
  }
}

Color _bookingColor(BookingStatus status) {
  switch (status) {
    case BookingStatus.pending:
      return const Color(0xFFF59E0B);
    case BookingStatus.confirmed:
      return AppColors.statusSuccess;
    case BookingStatus.cancelled:
      return AppColors.statusError;
    case BookingStatus.noShow:
      return AppColors.textMuted;
  }
}

String _bookingLabel(BookingStatus status) {
  switch (status) {
    case BookingStatus.pending:
      return 'Pending';
    case BookingStatus.confirmed:
      return 'Confirmed';
    case BookingStatus.cancelled:
      return 'Cancelled';
    case BookingStatus.noShow:
      return 'No-show';
  }
}
