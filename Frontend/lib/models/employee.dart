class Employee {
  final int id;
  final String employeeId;
  final String fullName;
  final String? nationality;
  final String? email;
  final String? phone;
  final String? phone2;
  final String? contractType;
  final String? department;
  final String? jobPosition;
  final double? grade;
  final DateTime? joiningDate;
  final DateTime? startDate;
  final DateTime? leftDate;
  final DateTime? hiringDate;
  final DateTime? left2Date;
  final DateTime? hiring2Date;
  final double? status;
  final DateTime? endDate;
  final double? wage;
  final String? wageType;
  final double? basicSalary;
  final double? otherAllowances;
  final String? bankAccountNb;
  // R3 Form fields
  final String? socialSecurityNumber;
  final DateTime? workStartDate;
  // R4 Form fields
  final String? firstName;
  final String? lastName;
  final String? fatherName;
  final String? motherName;
  final String? gender;
  final String? placeOfBirth;
  final DateTime? dateOfBirth;
  final String? registerNumber;
  final String? registerPlace;
  final String? idCardNumber;
  final String? maritalStatus;
  final int? numberOfChildren;
  final bool? hasFinancialNumber;
  final String? personalFinancialNumber;
  final String? ministryRegistrationNumber;

  // Spouse
  final String? spouseName;
  final String? spouseMaidenName;
  final String? spouseFatherName;
  final String? spouseMotherName;
  final String? spouseNationality;
  final String? spousePlaceOfBirth;
  final DateTime? spouseDateOfBirth;
  final String? spouseIdCardNumber;
  final String? spouseRegisterNumber;
  final String? spouseRegisterPlace;
  final bool? spouseWorks;
  final String? spouseWorkDetails;
  final String? spouseRegistrationNumber;   // personal registration number (ministry)
  final String? spouseWorkSector;
  final String? spouseWorkCompany;
  // Second registration number (also to Ministry of Finance)
  final String? spouseRegistrationNumber2;

  // Address
  final String? governorate;
  final String? district;
  final String? area;
  final String? neighborhood;
  final String? street;
  final String? building;
  final String? floor;
  final String? propertyNumber;
  final String? fax;
  // 🆕 PO Box fields
  final String? poBoxNumber;
  final String? poBoxArea;
  // R3 Form fields
  final DateTime? r3SocialSecurityStartDate;
  final String? employerName;
  final String? employerTitle;
  final String? r3FinancialNumber;
  final DateTime? r3RegistrationDate;
  final String? r3RejectionReason;

  // E3lam Form fields
  final String? institutionResponsible;
  final String? institutionNssfNumber;
  final String? institutionPlace;
  final String? institutionNumber;
  final String? institutionPhone;
  final String? institutionFullAddress;
  final String? employeeFundNumber;
  final String? employeeName;
  final String? employeeSurname;
  final String? fatherNameE3lam;
  final String? motherNameE3lam;
  final String? birthDatePlace;
  final String? registerNumberE3lam;
  final String? leftWorkSince;
  final String? leaveReason;
  final String? currentJob;
  final String? salaryAtLeaveDate;
  final String? beirutDate;
  final String? employeeSignedName;
  final String? centerNumber;
  final String? registrationDepartmentName;
  final String? registrationDepartmentDate;
  final String? registrationProcessedDate;

  Employee({
    required this.id,
    required this.employeeId,
    required this.fullName,
    this.nationality,
    this.email,
    this.phone,
    this.phone2,
    this.contractType,
    this.department,
    this.jobPosition,
    this.grade,
    this.joiningDate,
    this.startDate,
    this.leftDate,
    this.hiringDate,
    this.left2Date,
    this.hiring2Date,
    this.status,
    this.endDate,
    this.wage,
    this.wageType,
    this.basicSalary,
    this.otherAllowances,
    this.bankAccountNb,
    this.firstName,
    this.lastName,
    this.fatherName,
    this.motherName,
    this.gender,
    this.placeOfBirth,
    this.dateOfBirth,
    this.registerNumber,
    this.registerPlace,
    this.idCardNumber,
    this.maritalStatus,
    this.numberOfChildren,
    this.hasFinancialNumber,
    this.personalFinancialNumber,
    this.ministryRegistrationNumber,
    this.spouseName,
    this.spouseMaidenName,
    this.spouseFatherName,
    this.spouseMotherName,
    this.spouseNationality,
    this.spousePlaceOfBirth,
    this.spouseDateOfBirth,
    this.spouseIdCardNumber,
    this.spouseRegisterNumber,
    this.spouseRegisterPlace,
    this.spouseWorks,
    this.spouseWorkDetails,
    this.spouseRegistrationNumber,
    this.spouseWorkSector,
    this.spouseWorkCompany,
    this.spouseRegistrationNumber2,
    this.governorate,
    this.district,
    this.area,
    this.neighborhood,
    this.street,
    this.building,
    this.floor,
    this.propertyNumber,
    this.fax,
    this.poBoxNumber,
    this.poBoxArea,
    this.socialSecurityNumber,
    this.workStartDate,
    this.r3SocialSecurityStartDate,
    this.employerName,
    this.employerTitle,
    this.r3FinancialNumber,
    this.r3RegistrationDate,
    this.r3RejectionReason,
    this.institutionResponsible,
    this.institutionNssfNumber,
    this.institutionPlace,
    this.institutionNumber,
    this.institutionPhone,
    this.institutionFullAddress,
    this.employeeFundNumber,
    this.employeeName,
    this.employeeSurname,
    this.fatherNameE3lam,
    this.motherNameE3lam,
    this.birthDatePlace,
    this.registerNumberE3lam,
    this.leftWorkSince,
    this.leaveReason,
    this.currentJob,
    this.salaryAtLeaveDate,
    this.beirutDate,
    this.employeeSignedName,
    this.centerNumber,
    this.registrationDepartmentName,
    this.registrationDepartmentDate,
    this.registrationProcessedDate,
  });

  factory Employee.fromJson(Map<String, dynamic> j) {
    return Employee(
      id: j['id'] is String
          ? int.tryParse(j['id']) ?? 0
          : j['id'] as int? ?? 0,
      employeeId: j['employee_id'] as String? ?? '',
      fullName: j['full_name'] as String? ?? '',
      nationality: j['nationality'] as String?,
      email: j['email'] as String?,
      phone: j['phone'] as String?,
      phone2: j['phone2'] as String?,
      contractType: j['contract_type'] as String?,
      department: j['department'] as String?,
      jobPosition: j['job_position'] as String?,
      grade: _d(j['grade']),
      joiningDate: _dt(j['joining_date']),
      startDate: _dt(j['start_date']),
      leftDate: _dt(j['left_date']),
      hiringDate: _dt(j['hiring_date']),
      left2Date: _dt(j['left_2_date']),
      hiring2Date: _dt(j['hiring_2_date']),
      status: _d(j['status']),
      endDate: _dt(j['end_date']),
      wage: _d(j['wage']),
      wageType: j['wage_type'] as String?,
      basicSalary: _d(j['basic_salary']),
      otherAllowances: _d(j['other_allowances']),
      bankAccountNb: j['bank_account_nb']?.toString(),
      firstName: j['first_name'] as String?,
      lastName: j['last_name'] as String?,
      fatherName: j['father_name'] as String?,
      motherName: j['mother_name'] as String?,
      gender: j['gender'] as String?,
      placeOfBirth: j['place_of_birth'] as String?,
      dateOfBirth: _dt(j['date_of_birth']),
      registerNumber: j['register_number'] as String?,
      registerPlace: j['register_place'] as String?,
      idCardNumber: j['id_card_number'] as String?,
      maritalStatus: j['marital_status'] as String?,
      numberOfChildren: j['number_of_children'] is String
          ? int.tryParse(j['number_of_children'])
          : j['number_of_children'] as int?,
      hasFinancialNumber: j['has_financial_number'] as bool?,
      personalFinancialNumber: j['personal_financial_number'] as String?,
      ministryRegistrationNumber: j['ministry_registration_number'] as String?,
      spouseName: j['spouse_name'] as String?,
      spouseMaidenName: j['spouse_maiden_name'] as String?,
      spouseFatherName: j['spouse_father_name'] as String?,
      spouseMotherName: j['spouse_mother_name'] as String?,
      spouseNationality: j['spouse_nationality'] as String?,
      spousePlaceOfBirth: j['spouse_place_of_birth'] as String?,
      spouseDateOfBirth: _dt(j['spouse_date_of_birth']),
      spouseIdCardNumber: j['spouse_id_card_number'] as String?,
      spouseRegisterNumber: j['spouse_register_number'] as String?,
      spouseRegisterPlace: j['spouse_register_place'] as String?,
      spouseWorks: j['spouse_works'] as bool?,
      spouseWorkDetails: j['spouse_work_details'] as String?,
      spouseRegistrationNumber: j['spouse_registration_number'] as String?,
      spouseWorkSector: j['spouse_work_sector'] as String?,
      spouseWorkCompany: j['spouse_work_company'] as String?,
      spouseRegistrationNumber2: j['spouse_registration_number_2'] as String?,
      governorate: j['governorate'] as String?,
      district: j['district'] as String?,
      area: j['area'] as String?,
      neighborhood: j['neighborhood'] as String?,
      street: j['street'] as String?,
      building: j['building'] as String?,
      floor: j['floor'] as String?,
      propertyNumber: j['property_number'] as String?,
      fax: j['fax'] as String?,
      socialSecurityNumber: j['social_security_number'] as String?,
      workStartDate: _dt(j['work_start_date']),
      poBoxNumber: j['po_box_number'] as String?,
      poBoxArea: j['po_box_area'] as String?,
      r3SocialSecurityStartDate: _dt(j['r3_social_security_start_date']),
      employerName: j['employer_name'] as String?,
      employerTitle: j['employer_title'] as String?,
      r3FinancialNumber: j['r3_financial_number'] as String?,
      r3RegistrationDate: _dt(j['r3_registration_date']),
      r3RejectionReason: j['r3_rejection_reason'] as String?,
      institutionResponsible: j['institution_responsible'] as String?,
      institutionNssfNumber: j['institution_nssf_number'] as String?,
      institutionPlace: j['institution_place'] as String?,
      institutionNumber: j['institution_number'] as String?,
      institutionPhone: j['institution_phone'] as String?,
      institutionFullAddress: j['institution_full_address'] as String?,
      employeeFundNumber: j['employee_fund_number'] as String?,
      employeeName: j['employee_name'] as String?,
      employeeSurname: j['employee_surname'] as String?,
      fatherNameE3lam: j['father_name_e3lam'] as String?,
      motherNameE3lam: j['mother_name_e3lam'] as String?,
      birthDatePlace: j['birth_date_place'] as String?,
      registerNumberE3lam: j['register_number_e3lam'] as String?,
      leftWorkSince: j['left_work_since'] as String?,
      leaveReason: j['leave_reason'] as String?,
      currentJob: j['current_job'] as String?,
      salaryAtLeaveDate: j['salary_at_leave_date'] as String?,
      beirutDate: j['beirut_date'] as String?,
      employeeSignedName: j['employee_signed_name'] as String?,
      centerNumber: j['center_number'] as String?,
      registrationDepartmentName: j['registration_department_name'] as String?,
      registrationDepartmentDate: j['registration_department_date'] as String?,
      registrationProcessedDate: j['registration_processed_date'] as String?,
    );
  }

  static double? _d(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static DateTime? _dt(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }
}

class EmployeeDocument {
  final int? id;
  final int employeeId;
  final String fileName;
  final String filePath;
  final int? fileSize;
  final String? mimeType;
  final DateTime? uploadedAt;

  EmployeeDocument({
    this.id,
    required this.employeeId,
    required this.fileName,
    required this.filePath,
    this.fileSize,
    this.mimeType,
    this.uploadedAt,
  });

  factory EmployeeDocument.fromJson(Map<String, dynamic> j) {
    return EmployeeDocument(
      id: j['id'] is String ? int.tryParse(j['id']) : j['id'] as int?,
      employeeId: j['employee_id'] is String
          ? int.tryParse(j['employee_id']) ?? 0
          : j['employee_id'] as int? ?? 0,
      fileName: j['file_name'] as String? ?? '',
      filePath: j['file_path'] as String? ?? '',
      fileSize: j['file_size'] is String
          ? int.tryParse(j['file_size'])
          : j['file_size'] as int?,
      mimeType: j['mime_type'] as String?,
      uploadedAt: j['uploaded_at'] != null
          ? DateTime.tryParse(j['uploaded_at'].toString())
          : null,
    );
  }
}