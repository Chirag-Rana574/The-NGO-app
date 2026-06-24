class BenchDetails {
  final int judgeCount;
  final int courtrooms;
  final String established;

  BenchDetails({
    required this.judgeCount,
    required this.courtrooms,
    required this.established,
  });
}

class Timings {
  final String weekdays;
  final String saturday;
  final String sunday;

  Timings({
    required this.weekdays,
    required this.saturday,
    required this.sunday,
  });
}

class DistrictCourt {
  final String id;
  final String name;
  final String location;
  final String phone;
  final String description;
  final List<String> courts;
  final List<String> jurisdictions;
  final BenchDetails benchDetails;
  final Timings timings;
  final List<String> services;
  final String website;
  final String address;

  DistrictCourt({
    required this.id,
    required this.name,
    required this.location,
    required this.phone,
    required this.description,
    required this.courts,
    required this.jurisdictions,
    required this.benchDetails,
    required this.timings,
    required this.services,
    required this.website,
    required this.address,
  });
}
