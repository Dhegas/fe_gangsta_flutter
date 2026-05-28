import 'package:fe_gangsta_flutter/features/merchant/order_management/domain/entities/order_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/order_management/domain/repositories/order_management_repository.dart';
import 'package:fe_gangsta_flutter/features/merchant/order_management/presentation/state/order_management_state.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/table_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/repositories/table_management_repository.dart';
import 'package:flutter/foundation.dart';

class OrderManagementController extends ChangeNotifier {
  OrderManagementController({
    required OrderManagementRepository orderRepository,
    required TableManagementRepository tableRepository,
  })  : _orderRepository = orderRepository,
        _tableRepository = tableRepository,
        _state = OrderManagementState.initial();

  final OrderManagementRepository _orderRepository;
  final TableManagementRepository _tableRepository;
  OrderManagementState _state;

  OrderManagementState get state => _state;

  Future<void> initialize() async {
    _state = _state.copyWith(isLoading: true, errorMessage: null, clearError: true);
    notifyListeners();

    try {
      final results = await Future.wait([
        _tableRepository.getTables(),
        _orderRepository.getOrders(),
      ]);

      final tablesList = results[0] as List<TableEntity>;
      final ordersList = results[1] as List<OrderEntity>;

      final tablesMap = <String, String>{};
      for (final table in tablesList) {
        tablesMap[table.id] = table.name;
      }

      _state = _state.copyWith(
        orders: ordersList,
        tables: tablesMap,
        isLoading: false,
      );
    } catch (e) {
      print('Error initializing orders: $e');
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat data pesanan: ${e.toString()}',
      );
    }
    notifyListeners();
  }

  Future<bool> deleteOrder(String id) async {
    _state = _state.copyWith(isLoading: true, errorMessage: null, clearError: true);
    notifyListeners();

    try {
      final success = await _orderRepository.deleteOrder(id);
      if (success) {
        final updatedOrders = _state.orders.where((order) => order.id != id).toList();
        _state = _state.copyWith(
          orders: updatedOrders,
          isLoading: false,
        );
        notifyListeners();
        return true;
      } else {
        _state = _state.copyWith(
          isLoading: false,
          errorMessage: 'Gagal menghapus pesanan.',
        );
      }
    } catch (e) {
      print('Error deleting order: $e');
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal menghapus pesanan: ${e.toString()}',
      );
    }

    notifyListeners();
    return false;
  }

  Future<bool> updateOrderStatus(String id, String status) async {
    _state = _state.copyWith(isLoading: true, errorMessage: null, clearError: true);
    notifyListeners();

    try {
      final success = await _orderRepository.updateOrderStatus(id, status);
      if (success) {
        final updatedOrders = _state.orders.map((order) {
          if (order.id == id) {
            return order.copyWith(status: status);
          }
          return order;
        }).toList();
        _state = _state.copyWith(
          orders: updatedOrders,
          isLoading: false,
        );
        notifyListeners();
        return true;
      } else {
        _state = _state.copyWith(
          isLoading: false,
          errorMessage: 'Gagal memperbarui status pesanan.',
        );
      }
    } catch (e) {
      print('Error updating order status: $e');
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memperbarui status pesanan: ${e.toString()}',
      );
    }

    notifyListeners();
    return false;
  }
}
