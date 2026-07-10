import 'package:hr_management_system/config/supabase_config.dart';
import 'package:hr_management_system/data/models/holiday_model.dart';

class HolidayService {
  static const String _tableName = 'holidays';

  static Future<List<Holiday>> getAllHolidays() async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .order('date', ascending: true);

      if (response == null || response is! List) return [];

      return (response)
          .map((item) => Holiday.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch holidays: $e');
    }
  }

  static Future<Holiday?> fetchHolidayById(String holidayId) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('id', holidayId)
          .maybeSingle();

      if (response == null) return null;
      return Holiday.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch holiday: $e');
    }
  }

  static Future<Holiday?> createHoliday(Holiday holiday) async {
    try {
      final data = holiday.toJson();
      if (holiday.id.startsWith('holiday_')) data.remove('id');

      final response = await SupabaseConfig.client
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      if (response == null) return null;
      return Holiday.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create holiday: $e');
    }
  }

  static Future<Holiday?> updateHoliday(String holidayId, Map<String, dynamic> data) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .update(data)
          .eq('id', holidayId)
          .select()
          .single();

      if (response == null) return null;
      return Holiday.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update holiday: $e');
    }
  }

  static Future<bool> deleteHoliday(String holidayId) async {
    try {
      await SupabaseConfig.client
          .from(_tableName)
          .delete()
          .eq('id', holidayId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete holiday: $e');
    }
  }
}
