import 'package:event_bus/event_bus.dart';

class EventBusManager {
  EventBusManager._();
  /// The shared instance of [EventBusManager].
  static final EventBusManager instance = EventBusManager._();
  EventBus eventBus = EventBus();
}

final eventBusManager = EventBusManager.instance;