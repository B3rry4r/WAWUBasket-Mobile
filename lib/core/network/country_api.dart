import 'package:dio/dio.dart';

/// One country with its international dial code.
class Country {
  const Country({
    required this.name,
    required this.iso2,
    required this.dialCode,
    required this.flag,
  });

  final String name;
  final String iso2;
  final String dialCode;
  final String flag;

  String get pickerLabel => '$flag  $name  $dialCode';
  String get compactLabel => '$flag $dialCode';

  factory Country.fromJson(Map<String, dynamic> j) {
    final idd = (j['idd'] as Map?)?.cast<String, dynamic>() ?? const {};
    final root = (idd['root'] ?? '').toString();
    final suffixes =
        (idd['suffixes'] as List?)?.map((e) => e.toString()).toList() ??
            const [];
    // A single suffix → a unique full code (root+suffix). Many suffixes
    // (e.g. +1 NANP countries) → the root alone is the usable code.
    final dial = root.isEmpty
        ? ''
        : (suffixes.length == 1 ? '$root${suffixes.first}' : root);
    final nameMap = (j['name'] as Map?)?.cast<String, dynamic>() ?? const {};
    return Country(
      name: (nameMap['common'] ?? '').toString(),
      iso2: (j['cca2'] ?? '').toString(),
      dialCode: dial,
      flag: (j['flag'] ?? '').toString(),
    );
  }
}

/// Fetches the country + dial-code list from the public restcountries.com
/// API. States and cities come from countriesnow.space. All results are
/// cached in memory for the app session.
class CountryApi {
  CountryApi._();
  static final CountryApi instance = CountryApi._();

  final _dio = Dio();
  List<Country>? _cache;
  final _statesCache = <String, List<String>>{};
  final _citiesCache = <String, List<String>>{};

  Future<List<Country>> all() async {
    if (_cache != null) return _cache!;
    final res = await _dio.get<dynamic>(
      'https://restcountries.com/v3.1/all',
      queryParameters: {'fields': 'name,idd,cca2,flag'},
    );
    final list = ((res.data as List?) ?? const [])
        .map((e) => Country.fromJson((e as Map).cast<String, dynamic>()))
        .where((c) => c.dialCode.isNotEmpty && c.name.isNotEmpty)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    _cache = list;
    return list;
  }

  /// Best-effort lookup of a country by ISO-2 code (e.g. the default `NG`).
  Country? byIso(List<Country> list, String iso2) {
    for (final c in list) {
      if (c.iso2 == iso2) return c;
    }
    return null;
  }

  /// States/provinces for [countryName] via countriesnow.space.
  Future<List<String>> statesFor(String countryName) async {
    if (countryName.isEmpty) return const [];
    if (_statesCache.containsKey(countryName)) return _statesCache[countryName]!;
    try {
      final res = await _dio.get<dynamic>(
        'https://countriesnow.space/api/v0.1/countries/states/q',
        queryParameters: {'country': countryName},
      );
      final data = (res.data as Map?)?.cast<String, dynamic>() ?? const {};
      if (data['error'] == true) return const [];
      final states = ((data['data']?['states'] as List?) ?? const [])
          .map((s) => ((s as Map?)?['name'] ?? '').toString().trim())
          .where((s) => s.isNotEmpty)
          .toList()
        ..sort();
      _statesCache[countryName] = states;
      return states;
    } catch (_) {
      return const [];
    }
  }

  /// Cities in [stateName] of [countryName] via countriesnow.space.
  Future<List<String>> citiesFor(String countryName, String stateName) async {
    if (countryName.isEmpty || stateName.isEmpty) return const [];
    final key = '$countryName|$stateName';
    if (_citiesCache.containsKey(key)) return _citiesCache[key]!;
    Future<List<String>> parse(dynamic body) async {
      final data = (body as Map?)?.cast<String, dynamic>() ?? const {};
      if (data['error'] == true) return const [];
      final cities = ((data['data'] as List?) ?? const [])
          .map((c) => c.toString().trim())
          .where((c) => c.isNotEmpty)
          .toList()
        ..sort();
      return cities;
    }
    try {
      final res = await _dio.post<dynamic>(
        'https://countriesnow.space/api/v0.1/countries/state/cities',
        data: {
          'country': countryName,
          'state': stateName.replaceAll(' State', ''),
        },
      );
      final cities = await parse(res.data);
      if (cities.isNotEmpty) {
        _citiesCache[key] = cities;
        return cities;
      }
    } catch (_) {}
    // Fallback GET
    try {
      final res = await _dio.get<dynamic>(
        'https://countriesnow.space/api/v0.1/countries/state/cities/q',
        queryParameters: {'country': countryName, 'state': stateName},
      );
      final cities = await parse(res.data);
      _citiesCache[key] = cities;
      return cities;
    } catch (_) {
      return const [];
    }
  }
}
