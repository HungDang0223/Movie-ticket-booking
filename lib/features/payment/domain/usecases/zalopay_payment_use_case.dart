import 'package:movie_tickets/core/usecase/use_case.dart';
import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/features/payment/data/models/zalopay_order_response.dart';
import 'package:movie_tickets/features/payment/domain/repositories/payment_repository.dart';

class ZalopayPaymentUseCase implements UseCase<ZalopayOrderResponse, double> {
  final PaymentRepository _repository;

  ZalopayPaymentUseCase(this._repository);
  @override
  Future<Result<ZalopayOrderResponse>> call(double amount) {
    // TODO: implement call
    throw UnimplementedError();
  }
}