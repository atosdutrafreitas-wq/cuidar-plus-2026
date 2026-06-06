import '../models/alert_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class AlertRepository {
  final FirestoreService _service;
  final NotificationService _notifications;

  AlertRepository(this._service, this._notifications);

  Stream<List<AlertModel>> watchAlerts(String familyId) =>
      _service.alertsStream(familyId);

  Future<void> sendHelpAlert({
    required String elderlyId,
    required String familyId,
    required String elderlyName,
  }) async {
    final alert = AlertModel(
      id: '',
      elderlyId: elderlyId,
      familyId: familyId,
      type: AlertType.help,
      status: AlertStatus.pending,
      title: 'PEDIDO DE AJUDA',
      message: '$elderlyName está pedindo ajuda!',
      scheduledFor: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await _service.addAlert(alert);
    await _notifications.showHelpAlert(elderlyName: elderlyName);
  }

  Future<void> acknowledge(String alertId) =>
      _service.acknowledgeAlert(alertId);
}
