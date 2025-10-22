import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🔹 Holds slot information (temporary local logic)
class SlotNotifier extends StateNotifier<Map<String, int>> {
  SlotNotifier() : super({"usedSlots": 0, "maxSlots": 3});

  void increaseSlot() {
    if (state["usedSlots"]! < state["maxSlots"]!) {
      state = {
        "usedSlots": state["usedSlots"]! + 1,
        "maxSlots": state["maxSlots"]!,
      };
    }
  }

  void decreaseSlot() {
    if (state["usedSlots"]! > 0) {
      state = {
        "usedSlots": state["usedSlots"]! - 1,
        "maxSlots": state["maxSlots"]!,
      };
    }
  }

  void resetSlots() {
    state = {"usedSlots": 0, "maxSlots": state["maxSlots"]!};
  }

  void setMaxSlots(int newLimit) {
    state = {"usedSlots": state["usedSlots"]!, "maxSlots": newLimit};
  }
}

final slotProvider = StateNotifierProvider<SlotNotifier, Map<String, int>>(
  (ref) => SlotNotifier(),
);
