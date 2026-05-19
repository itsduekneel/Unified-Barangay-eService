import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_data.dart';

class UserViewModel extends ChangeNotifier {
  final _client = Supabase.instance.client;

  List<ProfileData> _profiles = [];
  List<ProfileData> get profiles => _profiles;

  ProfileData? _currentUser;
  ProfileData? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _filter = 'All';
  String get filter => _filter;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<ProfileData> get filteredProfiles {
    return _profiles.where((p) {
      final passesFilter = switch (_filter) {
        'Active' => p.isActive,
        'Inactive' => !p.isActive,
        _ => true,
      };
      final q = _searchQuery.toLowerCase();
      final passesSearch = q.isEmpty ||
          p.fullName.toLowerCase().contains(q) ||
          (p.email?.toLowerCase().contains(q) ?? false) ||
          (p.barangay?.toLowerCase().contains(q) ?? false);
      return passesFilter && passesSearch;
    }).toList();
  }

  int get totalUsers => _profiles.length;
  int get activeCount => _profiles.where((p) => p.isActive).length;
  int get inactiveCount => _profiles.where((p) => !p.isActive).length;

  Future<void> fetchProfiles() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _client.from('profiles').select().order('first_name');
      _profiles = (data as List).map((e) => ProfileData.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error fetching profiles: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCurrentUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      debugPrint('UserViewModel: No logged in user found.');
      return;
    }

    try {
      debugPrint('UserViewModel: Fetching profile for UID: ${user.id}');
      
      // 1. Try fetching from profiles table
      final profileData = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profileData != null) {
        _currentUser = ProfileData.fromMap(profileData);
        debugPrint('UserViewModel: Profile found! Name: ${_currentUser?.firstName}');
        notifyListeners();
        return;
      }

      // 2. Fallback: Try fetching from barangays table if not in profiles
      debugPrint('UserViewModel: No profile found in "profiles", checking "barangays" table...');
      final barangayData = await _client
          .from('barangays')
          .select()
          .eq('auth_uid', user.id)
          .maybeSingle();

      if (barangayData != null) {
        _currentUser = ProfileData(
          id: user.id,
          firstName: barangayData['name'] ?? 'Barangay',
          middleName: '',
          lastName: '',
          email: barangayData['email'],
          role: 'Barangay',
          isActive: barangayData['is_active'] ?? true,
        );
        debugPrint('UserViewModel: Barangay profile found! Name: ${_currentUser?.firstName}');
        notifyListeners();
      } else {
        debugPrint('UserViewModel: No user data found in both tables for UID: ${user.id}');
      }
    } catch (e) {
      debugPrint('Error fetching current user profile: $e');
    }
  }

  void clearUser() {
    _currentUser = null;
    _profiles = [];
    notifyListeners();
  }
}
