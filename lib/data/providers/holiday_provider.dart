import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/data/models/holiday_model.dart';
import 'package:hr_management_system/data/models/mock_data.dart';

class HolidayState {
  final List<int> weeklyHolidays;
  final List<Holiday> customHolidays;
  final bool isLoading;
  final String? error;

  HolidayState({
    this.weeklyHolidays = const [],
    this.customHolidays = const [],
    this.isLoading = false,
    this.error,
  });

  HolidayState copyWith({
    List<int>? weeklyHolidays,
    List<Holiday>? customHolidays,
    bool? isLoading,
    String? error,
  }) {
    return HolidayState(
      weeklyHolidays: weeklyHolidays ?? this.weeklyHolidays,
      customHolidays: customHolidays ?? this.customHolidays,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class HolidayNotifier extends StateNotifier<HolidayState> {
  HolidayNotifier() : super(HolidayState()) {
    loadHolidays();
  }

  void loadHolidays() {
    state = state.copyWith(isLoading: true, error: null);
    try {
      state = HolidayState(
        weeklyHolidays: List<int>.from(MockDataProvider.mockWeeklyHolidays),
        customHolidays: List<Holiday>.from(MockDataProvider.mockCustomHolidays),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> toggleWeeklyHoliday(int dayIndex) async {
    try {
      final updatedWeekly = List<int>.from(state.weeklyHolidays);
      if (updatedWeekly.contains(dayIndex)) {
        updatedWeekly.remove(dayIndex);
      } else {
        updatedWeekly.add(dayIndex);
      }
      
      MockDataProvider.mockWeeklyHolidays.clear();
      MockDataProvider.mockWeeklyHolidays.addAll(updatedWeekly);

      state = state.copyWith(weeklyHolidays: updatedWeekly);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> addCustomHoliday(Holiday holiday) async {
    try {
      final updatedCustom = List<Holiday>.from(state.customHolidays);
      updatedCustom.add(holiday);
      updatedCustom.sort((a, b) => a.date.compareTo(b.date));

      MockDataProvider.mockCustomHolidays.clear();
      MockDataProvider.mockCustomHolidays.addAll(updatedCustom);

      state = state.copyWith(customHolidays: updatedCustom);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteCustomHoliday(String holidayId) async {
    try {
      final updatedCustom = state.customHolidays.where((h) => h.id != holidayId).toList();

      MockDataProvider.mockCustomHolidays.clear();
      MockDataProvider.mockCustomHolidays.addAll(updatedCustom);

      state = state.copyWith(customHolidays: updatedCustom);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final holidayProvider = StateNotifierProvider<HolidayNotifier, HolidayState>((ref) {
  return HolidayNotifier();
});
