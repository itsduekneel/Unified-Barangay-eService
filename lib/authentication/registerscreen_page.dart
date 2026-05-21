import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_colors.dart';
import 'authentication_page.dart';
import 'package:ube/core/utils/route_utils.dart';

// ─── SUPABASE CLIENT ──────────────────────────────────────────────────────────

final _supabase = Supabase.instance.client;

// ─── REGISTER SCREEN ──────────────────────────────────────────────────────────

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _scrollController = ScrollController();

  // ── Controllers ─────────────────────────────────────────────────────────────
  final _firstNameCtrl = TextEditingController();
  final _middleNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  // ── State ────────────────────────────────────────────────────────────────────
  String? _suffix;
  String? _gender;
  String? _citizenship;
  String? _country;
  String? _stateProvince;
  String? _cityMunicipality;
  String? _barangay;
  DateTime? _birthDate;
  bool _noMiddleName = false;
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirm = false;

  // ── Step (0 = Personal Info, 1 = Address, 2 = Account) ───────────────────
  int _step = 0;

  // ── Password strength getters ─────────────────────────────────────────────
  bool get _pwHas8 => _passwordCtrl.text.length >= 8;
  bool get _pwHasCap => _passwordCtrl.text.contains(RegExp(r'[A-Z]'));
  bool get _pwHasNum => _passwordCtrl.text.contains(RegExp(r'[0-9!@#\$%^&*]'));

  // ── Static data ───────────────────────────────────────────────────────────
  static const _suffixes = ['N/A', 'Jr.', 'Sr.', 'II', 'III', 'IV', 'V'];
  static const _genders = ['Male', 'Female', 'Prefer not to say'];

  static const _citizenships = [
    'Filipino',
    'American',
    'Australian',
    'British',
    'Canadian',
    'Chinese',
    'Indian',
    'Indonesian',
    'Japanese',
    'Korean',
    'Malaysian',
    'Singaporean',
    'Other',
  ];

  static const _countries = [
    'Philippines',
    'United States',
    'Australia',
    'Canada',
    'United Kingdom',
    'Japan',
    'South Korea',
    'Singapore',
    'Malaysia',
    'Indonesia',
    'Other',
  ];

  static const _phProvinces = [
    'Abra',
    'Agusan del Norte',
    'Agusan del Sur',
    'Aklan',
    'Albay',
    'Antique',
    'Apayao',
    'Aurora',
    'Basilan',
    'Bataan',
    'Batanes',
    'Batangas',
    'Benguet',
    'Biliran',
    'Bohol',
    'Bukidnon',
    'Bulacan',
    'Cagayan',
    'Camarines Norte',
    'Camarines Sur',
    'Camiguin',
    'Capiz',
    'Catanduanes',
    'Cavite',
    'Cebu',
    'Cotabato',
    'Davao de Oro',
    'Davao del Norte',
    'Davao del Sur',
    'Davao Occidental',
    'Davao Oriental',
    'Dinagat Islands',
    'Eastern Samar',
    'Guimaras',
    'Ifugao',
    'Ilocos Norte',
    'Ilocos Sur',
    'Iloilo',
    'Isabela',
    'Kalinga',
    'La Union',
    'Laguna',
    'Lanao del Norte',
    'Lanao del Sur',
    'Leyte',
    'Maguindanao del Norte',
    'Maguindanao del Sur',
    'Marinduque',
    'Masbate',
    'Metro Manila',
    'Misamis Occidental',
    'Misamis Oriental',
    'Mountain Province',
    'Negros Occidental',
    'Negros Oriental',
    'Northern Samar',
    'Nueva Ecija',
    'Nueva Vizcaya',
    'Occidental Mindoro',
    'Oriental Mindoro',
    'Palawan',
    'Pampanga',
    'Pangasinan',
    'Quezon',
    'Quirino',
    'Rizal',
    'Romblon',
    'Samar',
    'Sarangani',
    'Siquijor',
    'Sorsogon',
    'South Cotabato',
    'Southern Leyte',
    'Sultan Kudarat',
    'Sulu',
    'Surigao del Norte',
    'Surigao del Sur',
    'Tarlac',
    'Tawi-Tawi',
    'Zambales',
    'Zamboanga del Norte',
    'Zamboanga del Sur',
    'Zamboanga Sibugay',
  ];

  static const Map<String, List<String>> _citiesMap = {
    'Laguna': [
      'Alaminos',
      'Bay',
      'Biñan',
      'Cabuyao',
      'Calamba',
      'Calauan',
      'Cavinti',
      'Famy',
      'Kalayaan',
      'Liliw',
      'Los Baños',
      'Luisiana',
      'Lumban',
      'Mabitac',
      'Magdalena',
      'Majayjay',
      'Nagcarlan',
      'Paete',
      'Pagsanjan',
      'Pakil',
      'Pangil',
      'Pila',
      'Rizal',
      'San Pablo',
      'San Pedro',
      'Santa Cruz',
      'Santa Maria',
      'Santa Rosa',
      'Siniloan',
      'Victoria',
    ],
    'Metro Manila': [
      'Caloocan',
      'Las Piñas',
      'Makati',
      'Malabon',
      'Mandaluyong',
      'Manila',
      'Marikina',
      'Muntinlupa',
      'Navotas',
      'Parañaque',
      'Pasay',
      'Pasig',
      'Pateros',
      'Quezon City',
      'San Juan',
      'Taguig',
      'Valenzuela',
    ],
    'Cavite': [
      'Alfonso',
      'Amadeo',
      'Bacoor',
      'Carmona',
      'Cavite City',
      'Dasmariñas',
      'General Emilio Aguinaldo',
      'General Mariano Alvarez',
      'General Trias',
      'Imus',
      'Indang',
      'Kawit',
      'Magallanes',
      'Maragondon',
      'Mendez',
      'Naic',
      'Noveleta',
      'Rosario',
      'Silang',
      'Tagaytay',
      'Tanza',
      'Ternate',
      'Trece Martires',
    ],
    'Batangas': [
      'Agoncillo',
      'Alitagtag',
      'Balayan',
      'Balete',
      'Batangas City',
      'Bauan',
      'Calaca',
      'Calatagan',
      'Cuenca',
      'Ibaan',
      'Laurel',
      'Lemery',
      'Lian',
      'Lipa',
      'Lobo',
      'Mabini',
      'Malvar',
      'Mataas na Kahoy',
      'Nasugbu',
      'Padre Garcia',
      'Rosario',
      'San Jose',
      'San Juan',
      'San Luis',
      'San Nicolas',
      'San Pascual',
      'Santa Teresita',
      'Santo Tomas',
      'Taal',
      'Talisay',
      'Tanauan',
      'Taysan',
      'Tingloy',
      'Tuy',
    ],
    'Cebu': [
      'Alcantara',
      'Alcoy',
      'Alegria',
      'Aloguinsan',
      'Argao',
      'Asturias',
      'Badian',
      'Balamban',
      'Bantayan',
      'Barili',
      'Bogo',
      'Boljoon',
      'Borbon',
      'Carcar',
      'Carmen',
      'Catmon',
      'Cebu City',
      'Compostela',
      'Consolacion',
      'Cordova',
      'Daanbantayan',
      'Dalaguete',
      'Danao',
      'Dumanjug',
      'Ginatilan',
      'Lapu-Lapu',
      'Liloan',
      'Madridejos',
      'Mandaue',
      'Medellin',
      'Minglanilla',
      'Moalboal',
      'Naga',
      'Oslob',
      'Pilar',
      'Pinamungajan',
      'Poro',
      'Ronda',
      'Samboan',
      'San Fernando',
      'San Francisco',
      'San Remigio',
      'Santa Fe',
      'Santander',
      'Sibonga',
      'Sogod',
      'Tabogon',
      'Tabuelan',
      'Talisay',
      'Toledo',
      'Tuburan',
      'Tudela',
    ],
  };

  static const Map<String, List<String>> _barangaysMap = {
    'Los Baños': [
      'Bagong Silang',
      'Bambang',
      'Batong Malake',
      'Baybayin',
      'Bayog',
      'Lalakay',
      'Maahas',
      'Malinta',
      'Mayondon',
      'Putho-Tuntungin',
      'San Antonio',
      'Santo Tomas',
      'Tadlak',
      'Timugan',
    ],
    'Calamba': [
      'Bagong Kalsada',
      'Banadero',
      'Banlic',
      'Batino',
      'Bubuyan',
      'Bucal',
      'Bunggo',
      'Burol',
      'Camaligan',
      'Canlubang',
      'Casile',
      'Diezmo',
      'Gulod',
      'Halang',
      'Hornalan',
      'Kay-Anlog',
      'La Mesa',
      'Laguerta',
      'Lawa',
      'Lecheria',
      'Lingga',
      'Looc',
      'Mabato',
      'Makiling',
      'Mapagong',
      'Masili',
      'Maunong',
      'Mayapa',
      'Milagrosa',
      'Paciano Rizal',
      'Palingon',
      'Palo-Alto',
      'Pansol',
      'Parian',
      'Prinza',
      'Punta',
      'Puting Lupa',
      'Real',
      'Saimsim',
      'Sampiruhan',
      'San Cristobal',
      'San Jose',
      'San Juan',
      'Santisima Cruz',
      'Santo Niño',
      'Santo Tomas',
      'Sucol',
      'Turbina',
      'Ulango',
      'Uwisan',
    ],
    'Makati': [
      'Bangkal',
      'Bel-Air',
      'Carmona',
      'Cembo',
      'Comembo',
      'Dasmariñas',
      'East Rembo',
      'Forbes Park',
      'Guadalupe Nuevo',
      'Guadalupe Viejo',
      'Kasilawan',
      'La Paz',
      'Magallanes',
      'Olympia',
      'Palanan',
      'Pembo',
      'Pinagkaisahan',
      'Pio Del Pilar',
      'Pitogo',
      'Poblacion',
      'Post Proper Northside',
      'Post Proper Southside',
      'Rizal',
      'San Antonio',
      'San Isidro',
      'San Lorenzo',
      'Santa Cruz',
      'Singkamas',
      'South Cembo',
      'Tejeros',
      'Urdaneta',
      'West Rembo',
    ],
    'Quezon City': [
      'Alicia',
      'Amihan',
      'Apolonio Samson',
      'Aurora',
      'Baesa',
      'Bagbag',
      'Bagong Lipunan ng Crame',
      'Bagong Pag-Asa',
      'Bagong Silangan',
      'Bagumbayan',
      'Bagumbuhay',
      'Bahay Toro',
      'Balingasa',
      'Batasan Hills',
      'Bayanihan',
      'Blue Ridge A',
      'Blue Ridge B',
      'Botocan',
      'Bungad',
      'Camp Aguinaldo',
      'Capri',
      'Claro',
      'Commonwealth',
      'Culiat',
      'Damar',
      'Damayang Lagi',
      'Del Monte',
      'Diliman',
      'Dioquino Zobel',
      'Don Manuel',
      'Doña Aurora',
      'Doña Imelda',
      'Doña Josefa',
      'Duyan-Duyan',
      'E. Rodriguez',
    ],
    'Cebu City': [
      'Apas',
      'Bacayan',
      'Banilad',
      'Basak Pardo',
      'Basak San Nicolas',
      'Binaliw',
      'Bonbon',
      'Buhisan',
      'Bulacao',
      'Buot-Taup Pardo',
      'Busay',
      'Calamba',
      'Cambinocot',
      'Capitol Site',
      'Carreta',
      'Central Pardo',
      'Cogon Pardo',
      'Cogon Ramos',
      'Day-as',
      'Duljo Fatima',
      'Ermita',
      'Esperanza',
      'Guadalupe',
      'Guba',
      'Hippodromo',
      'Inayawan',
      'Kalubihan',
      'Kalunasan',
      'Kamagayan',
      'Kasambagan',
      'Kinasang-an Pardo',
      'Labangon',
      'Lahug',
      'Lorega',
      'Lusaran',
      'Luz',
      'Mabini',
      'Mabolo',
      'Malubog',
      'Mambaling',
      'Pahina Central',
      'Pahina San Nicolas',
      'Pamutan',
      'Pardo',
      'Pari-an',
      'Paril',
      'Pasil',
      'Pit-os',
      'Poblacion Pardo',
      'Pung-ol Sibugay',
      'Punta Princesa',
      'Quiot Pardo',
      'Sambag I',
      'Sambag II',
      'San Antonio',
      'San Jose',
      'San Nicolas Central',
      'San Roque',
      'Santa Cruz',
      'Santo Niño',
      'Sawang Calero',
      'Sinsin',
      'Sirao',
      'Suba',
      'Sudlon I',
      'Sudlon II',
      'T. Padilla',
      'Tabunan',
      'Tagba-o',
      'Talamban',
      'Taptap',
      'Tejero',
      'Tinago',
      'Tisa',
      'To-ong Pardo',
      'Zapatera',
    ],
  };

  List<String> get _availableCities {
    if (_stateProvince == null) return [];
    return _citiesMap[_stateProvince!] ?? ['Other'];
  }

  List<String> get _availableBarangays {
    if (_cityMunicipality == null) return [];
    return _barangaysMap[_cityMunicipality!] ?? ['Other'];
  }

  // ─── Validation ─────────────────────────────────────────────────────────────

  String? _validateStep() {
    if (_step == 0) {
      if (_firstNameCtrl.text.trim().isEmpty) return 'First Name is required.';
      if (!_noMiddleName && _middleNameCtrl.text.trim().isEmpty) {
        return 'Middle Name is required (or check "I have no middle name").';
      }
      if (_lastNameCtrl.text.trim().isEmpty) return 'Last Name is required.';
      if (_birthDate == null) return 'Date of Birth is required.';
      if (_gender == null) return 'Please select a gender.';
      if (_citizenship == null) return 'Please select a citizenship.';
    } else if (_step == 1) {
      if (_country == null) return 'Country is required.';
      if (_stateProvince == null) return 'State/Province is required.';
      if (_cityMunicipality == null) return 'City/Municipality is required.';
      if (_barangay == null) return 'Barangay is required.';
      if (_streetCtrl.text.trim().isEmpty) return 'Street Address is required.';
    } else if (_step == 2) {
      if (_emailCtrl.text.trim().isEmpty) return 'Email Address is required.';
      if (!RegExp(
        r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$',
      ).hasMatch(_emailCtrl.text.trim())) {
        return 'Please enter a valid email address.';
      }
      if (_passwordCtrl.text.length < 8) {
        return 'Password must be at least 8 characters.';
      }
      if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
        return 'Passwords do not match.';
      }
    }
    return null;
  }

  void _nextStep() {
    final err = _validateStep();
    if (err != null) {
      _showError(err);
      return;
    }
    if (_step < 2) {
      setState(() => _step++);
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _handleSignUp();
    }
  }

  void _prevStep() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
  }

  // ─── Sign Up ─────────────────────────────────────────────────────────────────

  Future<void> _handleSignUp() async {
    setState(() => _isLoading = true);
    try {
      final email = _emailCtrl.text.trim();
      final password = _passwordCtrl.text;

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': _firstNameCtrl.text.trim(),
          'last_name': _lastNameCtrl.text.trim(),
        },
      );

      final uid = response.user?.id;
      if (uid == null) throw Exception('Sign-up failed. No user returned.');

      await _supabase.from('profiles').insert({
        'id': uid,
        'first_name': _firstNameCtrl.text.trim(),
        'middle_name': _noMiddleName ? null : _middleNameCtrl.text.trim(),
        'last_name': _lastNameCtrl.text.trim(),
        'suffix': _suffix == 'N/A' ? null : _suffix,
        'email': email,
        'birth_date': _birthDate!.toIso8601String().split('T').first,
        'gender': _gender,
        'citizenship': _citizenship,
        'country': _country,
        'state_province': _stateProvince,
        'city_municipality': _cityMunicipality,
        'barangay': _barangay,
        'street_address': _streetCtrl.text.trim(),
        'postal_code': _postalCtrl.text.trim().isEmpty
            ? null
            : _postalCtrl.text.trim(),
      });

      if (!mounted) return;
      _showSuccess('Account created! Please check your email to verify.');
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pushReplacement(context, instantRoute(const LoginPage()));
    } on AuthException catch (e) {
      _showError(_friendlyAuthError(e.message));
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        _showError('An account with this email already exists.');
      } else {
        _showError('Failed to save profile details. Please try again.');
      }
    } catch (e) {
      _showError('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyAuthError(String message) {
    final m = message.toLowerCase();
    if (m.contains('database error saving new user')) {
      return 'Backend configuration error: Please disable the trigger in your Supabase dashboard.';
    }
    if (m.contains('already registered') || m.contains('already exists')) {
      return 'This email is already registered. Please sign in instead.';
    }
    if (m.contains('password')) {
      return 'Password is too weak. Please use at least 8 characters.';
    }
    if (m.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }
    if (m.contains('email rate limit')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    return message;
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // Rebuild when password changes so requirements update live
    _passwordCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _scrollController.dispose();
    _firstNameCtrl.dispose();
    _middleNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _streetCtrl.dispose();
    _postalCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Colors.black87,
          ),
          onPressed: _prevStep,
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 5),

          _StepProgress(step: _step),

          const SizedBox(height: 15),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildStepContent(),
              ),
            ),
          ),
          _BottomBar(step: _step, isLoading: _isLoading, onNext: _nextStep),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _Step0PersonalInfo(key: const ValueKey(0), state: this);
      case 1:
        return _Step1Address(key: const ValueKey(1), state: this);
      default:
        return _Step2Account(key: const ValueKey(2), state: this);
    }
  }
}

// ─── STEP PROGRESS BAR ────────────────────────────────────────────────────────

class _StepProgress extends StatelessWidget {
  final int step;
  const _StepProgress({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(3, (i) {
          final active = i <= step;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── BOTTOM BAR ───────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int step;
  final bool isLoading;
  final VoidCallback onNext;
  const _BottomBar({
    required this.step,
    required this.isLoading,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEBE0FF), width: 0.5)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: isLoading ? null : onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      step < 2 ? 'Next' : 'Create Account',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      step < 2
                          ? Icons.arrow_forward_rounded
                          : Icons.check_rounded,
                      size: 17,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── STEP 0 — PERSONAL INFO ───────────────────────────────────────────────────

class _Step0PersonalInfo extends StatelessWidget {
  final _RegisterScreenState state;
  const _Step0PersonalInfo({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final s = state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        _Card(
          icon: Icons.person_outline_rounded,
          title: 'Personal Information',
          subtitle: 'Enter your legal name as it appears on your ID',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _RegField(
                      label: 'First Name',
                      hint: 'First Name',
                      controller: s._firstNameCtrl,
                      required: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: _RegDropdown(
                      label: 'Suffix',
                      hint: 'Suffix',
                      value: s._suffix,
                      items: _RegisterScreenState._suffixes,
                      onChanged: (v) => s.setState(() => s._suffix = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _RegField(
                label: 'Middle Name',
                hint: 'Middle Name',
                controller: s._middleNameCtrl,
                enabled: !s._noMiddleName,
                required: true,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Transform.scale(
                    scale: 0.85,
                    child: Checkbox(
                      value: s._noMiddleName,
                      onChanged: (v) =>
                          s.setState(() => s._noMiddleName = v ?? false),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const Text(
                    'I have no middle name',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
              _RegField(
                label: 'Last Name',
                hint: 'Last Name',
                controller: s._lastNameCtrl,
                required: true,
              ),
              const SizedBox(height: 12),
              const _Divider(),
              const SizedBox(height: 12),
              _DateField(
                label: 'Date of Birth',
                value: s._birthDate,
                onTap: s._pickDate,
                required: true,
              ),
              const SizedBox(height: 12),
              _RegDropdown(
                label: 'Citizenship',
                hint: 'Select Citizenship',
                value: s._citizenship,
                items: _RegisterScreenState._citizenships,
                onChanged: (v) => s.setState(() => s._citizenship = v),
                required: true,
              ),
              const SizedBox(height: 12),
              const _FieldLabel(text: 'Sex', required: true),
              const SizedBox(height: 8),
              Row(
                children: _RegisterScreenState._genders.map((g) {
                  final selected = s._gender == g;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => s.setState(() => s._gender = g),
                      child: Container(
                        margin: EdgeInsets.only(
                          right: g != _RegisterScreenState._genders.last
                              ? 8
                              : 0,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFF5F0FF)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : const Color(0xFFEBE0FF),
                            width: selected ? 1.5 : 0.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              g == 'Male'
                                  ? Icons.male
                                  : g == 'Female'
                                  ? Icons.female
                                  : Icons.person_outline,
                              size: 18,
                              color: selected ? AppColors.primary : Colors.grey,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              g == 'Prefer not to say' ? 'Prefer not' : g,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: selected
                                    ? AppColors.primary
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─── STEP 1 — ADDRESS ─────────────────────────────────────────────────────────

class _Step1Address extends StatelessWidget {
  final _RegisterScreenState state;
  const _Step1Address({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final s = state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F0FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFEBE0FF), width: 0.5),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.primary,
                size: 15,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Please make sure your address details are accurate and up to date.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF360C78)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const _SectionLabel(text: 'Current Address'),
        const SizedBox(height: 10),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RegDropdown(
                label: 'Country',
                hint: 'Select Country',
                value: s._country,
                items: _RegisterScreenState._countries,
                onChanged: (v) => s.setState(() {
                  s._country = v;
                  s._stateProvince = null;
                  s._cityMunicipality = null;
                  s._barangay = null;
                }),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _RegDropdown(
                      label: 'State / Province',
                      hint: 'Select Province',
                      value: s._stateProvince,
                      items: s._country == 'Philippines'
                          ? _RegisterScreenState._phProvinces
                          : ['Other'],
                      onChanged: (v) => s.setState(() {
                        s._stateProvince = v;
                        s._cityMunicipality = null;
                        s._barangay = null;
                      }),
                      required: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _RegDropdown(
                      label: 'City / Municipality',
                      hint: 'Select City',
                      value: s._cityMunicipality,
                      items: s._availableCities,
                      onChanged: s._stateProvince == null
                          ? null
                          : (v) => s.setState(() {
                              s._cityMunicipality = v;
                              s._barangay = null;
                            }),
                      required: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _RegDropdown(
                label: 'Barangay',
                hint: 'Select Barangay',
                value: s._barangay,
                items: s._availableBarangays,
                onChanged: s._cityMunicipality == null
                    ? null
                    : (v) => s.setState(() => s._barangay = v),
                required: true,
              ),
              const SizedBox(height: 12),
              _RegField(
                label: 'House No. / Bldg / Street Name',
                hint: 'Street address',
                controller: s._streetCtrl,
                required: true,
              ),
              const SizedBox(height: 12),
              _RegField(
                label: 'Postal Code (optional)',
                hint: 'e.g. 4030',
                controller: s._postalCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─── STEP 2 — ACCOUNT ─────────────────────────────────────────────────────────

class _Step2Account extends StatelessWidget {
  final _RegisterScreenState state;
  const _Step2Account({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final s = state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        const _SectionLabel(text: 'Login Credentials'),
        const SizedBox(height: 10),
        _Card(
          child: Column(
            children: [
              _RegField(
                label: 'Email Address',
                hint: 'you@email.com',
                controller: s._emailCtrl,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(
                  Icons.mail_outline_rounded,
                  size: 16,
                  color: Colors.grey,
                ),
                required: true,
              ),
              const SizedBox(height: 12),
              _PasswordField(
                label: 'Password',
                hint: 'Min. 8 characters',
                controller: s._passwordCtrl,
                show: s._showPassword,
                onToggle: () =>
                    s.setState(() => s._showPassword = !s._showPassword),
                required: true,
              ),
              const SizedBox(height: 12),
              _PasswordField(
                label: 'Confirm Password',
                hint: 'Re-enter password',
                controller: s._confirmPasswordCtrl,
                show: s._showConfirm,
                onToggle: () =>
                    s.setState(() => s._showConfirm = !s._showConfirm),
                required: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F0FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEBE0FF), width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 15,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Password requirements',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF360C78),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _PwReq(text: 'At least 8 characters', met: s._pwHas8),
              _PwReq(
                text: 'One uppercase letter (recommended)',
                met: s._pwHasCap,
              ),
              _PwReq(
                text: 'One number or symbol (recommended)',
                met: s._pwHasNum,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F0FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFEBE0FF), width: 0.5),
          ),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
                height: 1.6,
              ),
              children: [
                const TextSpan(text: 'By tapping '),
                const TextSpan(
                  text: 'Create Account',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const TextSpan(text: ', you agree with the '),
                TextSpan(
                  text: 'Terms and Conditions',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Notice',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─── PASSWORD REQUIREMENT ROW ─────────────────────────────────────────────────

class _PwReq extends StatelessWidget {
  final String text;
  final bool met;
  const _PwReq({required this.text, required this.met});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.circle_outlined,
            size: 13,
            color: met ? Colors.green : const Color(0xFFEBE0FF),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

// ─── REUSABLE: CARD ───────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final IconData? icon;
  final String? title;
  final String? subtitle;

  const _Card({required this.child, this.icon, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEBE0FF), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null && title != null) ...[
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F0FF),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: const Color(0xFFEBE0FF),
                      width: 0.5,
                    ),
                  ),
                  child: Icon(icon, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E0447),
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 0.5, color: Color(0xFFEBE0FF)),
            ),
          ],
          child,
        ],
      ),
    );
  }
}

// ─── REUSABLE: SECTION LABEL ──────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E0447),
          ),
        ),
      ],
    );
  }
}

// ─── REUSABLE: FIELD LABEL ────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  const _FieldLabel({required this.text, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        if (required)
          const Text(' *', style: TextStyle(color: Colors.red, fontSize: 11)),
      ],
    );
  }
}

// ─── REUSABLE: DIVIDER ────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 0.5, color: Color(0xFFEBE0FF));
}

// ─── REUSABLE: REG FIELD ──────────────────────────────────────────────────────

class _RegField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool enabled;
  final bool required;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;

  const _RegField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.required = false,
    this.inputFormatters,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(text: label, required: required),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textInputAction: TextInputAction.next,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E0447),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: prefixIcon,
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 11,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFEBE0FF),
                width: 0.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFEBE0FF),
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── REUSABLE: REG DROPDOWN ───────────────────────────────────────────────────

class _RegDropdown extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;
  final bool required;

  const _RegDropdown({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(text: label, required: required),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          initialValue: value,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.black54,
            size: 18,
          ),
          isExpanded: true,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E0447),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: onChanged == null ? Colors.grey.shade50 : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 11,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFEBE0FF),
                width: 0.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFEBE0FF),
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          items: items
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// ─── REUSABLE: DATE FIELD ─────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final bool required;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.required = false,
  });

  String _format(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(text: label, required: required),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEBE0FF), width: 0.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null ? _format(value!) : 'mm/dd/yyyy',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: value != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                      color: value != null
                          ? const Color(0xFF1E0447)
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.black45,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── REUSABLE: PASSWORD FIELD ─────────────────────────────────────────────────

class _PasswordField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool show;
  final bool required;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.show,
    required this.onToggle,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(text: label, required: required),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: !show,
          textInputAction: TextInputAction.next,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E0447),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 11,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFEBE0FF),
                width: 0.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFEBE0FF),
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                show
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.black38,
                size: 18,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}
