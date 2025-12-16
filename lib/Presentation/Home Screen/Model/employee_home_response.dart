

class EmployeeHomeResponse {
  final bool status;
  final EmployeeData? data;

  EmployeeHomeResponse({required this.status, this.data});

  factory EmployeeHomeResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeHomeResponse(
      status: json['status'] ?? false,
      data: json['data'] != null ? EmployeeData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'data': data?.toJson()};
  }
}

class EmployeeData {
  final Employee? employee;
  final Metrics? metrics;
  final List<RecentActivity> recentActivity;

  EmployeeData({this.employee, this.metrics, required this.recentActivity});

  factory EmployeeData.fromJson(Map<String, dynamic> json) {
    return EmployeeData(
      employee:
          json['employee'] != null ? Employee.fromJson(json['employee']) : null,
      metrics:
          json['metrics'] != null ? Metrics.fromJson(json['metrics']) : null,
      recentActivity:
          (json['recentActivity'] as List<dynamic>? ?? [])
              .map((e) => RecentActivity.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee': employee?.toJson(),
      'metrics': metrics?.toJson(),
      'recentActivity': recentActivity.map((e) => e.toJson()).toList(),
    };
  }
}

class Employee {
  final String id;
  final String name;
  final String employeeCode;
  final String vendorName;
  final String avatarUrl;

  Employee({
    required this.id,
    required this.name,
    required this.employeeCode,
    required this.vendorName,
    required this.avatarUrl,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      employeeCode: json['employeeCode'] ?? '',
      vendorName: json['vendorName'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'employeeCode': employeeCode,
      'vendorName': vendorName,
      'avatarUrl': avatarUrl,
    };
  }
}

class Metrics {
  final int totalEntry;
  final int totalCollectionAmount;

  Metrics({required this.totalEntry, required this.totalCollectionAmount});

  factory Metrics.fromJson(Map<String, dynamic> json) {
    return Metrics(
      totalEntry: json['totalEntry'] ?? 0,
      totalCollectionAmount: json['totalCollectionAmount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEntry': totalEntry,
      'totalCollectionAmount': totalCollectionAmount,
    };
  }
}

class RecentActivity {
  final DateTime date;
  final int entryCount;

  RecentActivity({required this.date, required this.entryCount});

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      entryCount: json['entryCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'entryCount': entryCount,
    };
  }
}


// class RecentActivity {
//   // Add fields when backend sends activity data
//
//   RecentActivity();
//
//   factory RecentActivity.fromJson(Map<String, dynamic> json) {
//     return RecentActivity();
//   }
//
//   Map<String, dynamic> toJson() {
//     return {};
//   }
// }
