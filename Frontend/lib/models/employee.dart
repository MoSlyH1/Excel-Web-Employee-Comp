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
  final String? spouseRegistrationNumber;
  final String? spouseWorkSector;
  final String? spouseWorkCompany;
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

  // ── Tasreeh Zawja (CNSS 485 A) ───────────────────────────────────
  final String? tasreehSubscriberRegNum;
  final String? tasreehSubscriberName;
  final String? tasreehSubscriberMother;
  final String? tasreehSubscriberFather;
  final String? tasreehRegisterNum;
  final String? tasreehCompanyName;
  final String? tasreehCompanyRegNum;
  final String? tasreehAddress;
  final String? tasreehSpouseFullName;
  final DateTime? tasreehSpouseDob;
  final bool? tasreehSpouseHasWork;
  final String? tasreehSpouseWorkType;
  final DateTime? tasreehDeclarationDate;

  // ── Employee Declaration (CNSS-2 AA / تصريح باستخدام أجير) ───────
  final String? declEmployerName;
  final String? declCommercialRegPlace;
  final String? declCommercialRegNumber;
  final String? declEmployerPhone;
  final String? declWorkplaceAddress;
  final String? declEmployeeGender;
  final String? declEmployeeFirstName;
  final String? declEmployeeLastName;
  final String? declEmployeeFatherName;
  final String? declEmployeeMotherName;
  final String? declBirthDatePlace;
  final String? declBirthDistrict;
  final String? declRegisterNumber;
  final String? declMaritalStatus;
  final String? declReligion;
  final String? declIdResidencePlace;
  final String? declCurrentGovernorate;
  final String? declCurrentDistrict;
  final String? declCurrentCity;
  final String? declCurrentNeighborhood;
  final String? declCurrentStreet;
  final String? declCurrentBuildingFloor;
  final String? declCurrentPhone;
  final String? declWorkStartDate;
  final String? declMonthlyHours;
  final String? declWorkType;
  final String? declCurrentJob;
  final String? declCurrentSalary;
  final String? declSalaryAtEntry;
  final String? declPaymentMethod;
  final String? declNationality;
  final String? declWorkPermit;
  final bool? declHasOtherEmployer;
  final String? declOtherEmployerInfo;
  final String? declEmployeeSignedName;
  final DateTime? declDeclarationDate;

  // ── Efada (CNSS 2M) ─────────────────────────────────────────────
  final String? efadaInstitutionName;
  final String? efadaInstitutionNssfNum;
  final String? efadaEmployeeName;
  final String? efadaEmployeeNssfNum;
  final String? efadaIllnessDuration;
  final String? efadaDistribution;
  // Work months 1–7
  final String? efadaMonth1; final String? efadaDays1;
  final String? efadaFrom1_1; final String? efadaTo1_1;
  final String? efadaFrom2_1; final String? efadaTo2_1;
  final String? efadaFrom3_1; final String? efadaTo3_1;
  final String? efadaMonth2; final String? efadaDays2;
  final String? efadaFrom1_2; final String? efadaTo1_2;
  final String? efadaFrom2_2; final String? efadaTo2_2;
  final String? efadaFrom3_2; final String? efadaTo3_2;
  final String? efadaMonth3; final String? efadaDays3;
  final String? efadaFrom1_3; final String? efadaTo1_3;
  final String? efadaFrom2_3; final String? efadaTo2_3;
  final String? efadaFrom3_3; final String? efadaTo3_3;
  final String? efadaMonth4; final String? efadaDays4;
  final String? efadaFrom1_4; final String? efadaTo1_4;
  final String? efadaFrom2_4; final String? efadaTo2_4;
  final String? efadaFrom3_4; final String? efadaTo3_4;
  final String? efadaMonth5; final String? efadaDays5;
  final String? efadaFrom1_5; final String? efadaTo1_5;
  final String? efadaFrom2_5; final String? efadaTo2_5;
  final String? efadaFrom3_5; final String? efadaTo3_5;
  final String? efadaMonth6; final String? efadaDays6;
  final String? efadaFrom1_6; final String? efadaTo1_6;
  final String? efadaFrom2_6; final String? efadaTo2_6;
  final String? efadaFrom3_6; final String? efadaTo3_6;
  final String? efadaMonth7; final String? efadaDays7;
  final String? efadaFrom1_7; final String? efadaTo1_7;
  final String? efadaFrom2_7; final String? efadaTo2_7;
  final String? efadaFrom3_7; final String? efadaTo3_7;
  // Salary rows 1–4
  final String? efadaTotalAmount;
  final String? efadaSalMonth1; final String? efadaSalPaid1;
  final String? efadaSalMonth2; final String? efadaSalPaid2;
  final String? efadaSalMonth3; final String? efadaSalPaid3;
  final String? efadaSalMonth4; final String? efadaSalPaid4;
  // Absence / return
  final String? efadaAbsenceDate;
  final bool? efadaReturned;
  final String? efadaReturnDate;
  final bool? efadaNotReturned;
  final String? efadaNotReturnedDate;
  // Illness origin
  final bool? efadaWorkRelated;
  final bool? efadaNotWorkRelated;
  // Salary during illness
  final bool? efadaSalaryStopped;
  final bool? efadaSalaryContinued;
  // Signature
  final String? efadaResponsibleName;
  final String? efadaCity;
  final String? efadaSignDate;

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
    // Tasreeh Zawja
    this.tasreehSubscriberRegNum,
    this.tasreehSubscriberName,
    this.tasreehSubscriberMother,
    this.tasreehSubscriberFather,
    this.tasreehRegisterNum,
    this.tasreehCompanyName,
    this.tasreehCompanyRegNum,
    this.tasreehAddress,
    this.tasreehSpouseFullName,
    this.tasreehSpouseDob,
    this.tasreehSpouseHasWork,
    this.tasreehSpouseWorkType,
    this.tasreehDeclarationDate,
    // Declaration Employee
    this.declEmployerName,
    this.declCommercialRegPlace,
    this.declCommercialRegNumber,
    this.declEmployerPhone,
    this.declWorkplaceAddress,
    this.declEmployeeGender,
    this.declEmployeeFirstName,
    this.declEmployeeLastName,
    this.declEmployeeFatherName,
    this.declEmployeeMotherName,
    this.declBirthDatePlace,
    this.declBirthDistrict,
    this.declRegisterNumber,
    this.declMaritalStatus,
    this.declReligion,
    this.declIdResidencePlace,
    this.declCurrentGovernorate,
    this.declCurrentDistrict,
    this.declCurrentCity,
    this.declCurrentNeighborhood,
    this.declCurrentStreet,
    this.declCurrentBuildingFloor,
    this.declCurrentPhone,
    this.declWorkStartDate,
    this.declMonthlyHours,
    this.declWorkType,
    this.declCurrentJob,
    this.declCurrentSalary,
    this.declSalaryAtEntry,
    this.declPaymentMethod,
    this.declNationality,
    this.declWorkPermit,
    this.declHasOtherEmployer,
    this.declOtherEmployerInfo,
    this.declEmployeeSignedName,
    this.declDeclarationDate,
    // Efada
    this.efadaInstitutionName,
    this.efadaInstitutionNssfNum,
    this.efadaEmployeeName,
    this.efadaEmployeeNssfNum,
    this.efadaIllnessDuration,
    this.efadaDistribution,
    this.efadaMonth1, this.efadaDays1,
    this.efadaFrom1_1, this.efadaTo1_1,
    this.efadaFrom2_1, this.efadaTo2_1,
    this.efadaFrom3_1, this.efadaTo3_1,
    this.efadaMonth2, this.efadaDays2,
    this.efadaFrom1_2, this.efadaTo1_2,
    this.efadaFrom2_2, this.efadaTo2_2,
    this.efadaFrom3_2, this.efadaTo3_2,
    this.efadaMonth3, this.efadaDays3,
    this.efadaFrom1_3, this.efadaTo1_3,
    this.efadaFrom2_3, this.efadaTo2_3,
    this.efadaFrom3_3, this.efadaTo3_3,
    this.efadaMonth4, this.efadaDays4,
    this.efadaFrom1_4, this.efadaTo1_4,
    this.efadaFrom2_4, this.efadaTo2_4,
    this.efadaFrom3_4, this.efadaTo3_4,
    this.efadaMonth5, this.efadaDays5,
    this.efadaFrom1_5, this.efadaTo1_5,
    this.efadaFrom2_5, this.efadaTo2_5,
    this.efadaFrom3_5, this.efadaTo3_5,
    this.efadaMonth6, this.efadaDays6,
    this.efadaFrom1_6, this.efadaTo1_6,
    this.efadaFrom2_6, this.efadaTo2_6,
    this.efadaFrom3_6, this.efadaTo3_6,
    this.efadaMonth7, this.efadaDays7,
    this.efadaFrom1_7, this.efadaTo1_7,
    this.efadaFrom2_7, this.efadaTo2_7,
    this.efadaFrom3_7, this.efadaTo3_7,
    this.efadaTotalAmount,
    this.efadaSalMonth1, this.efadaSalPaid1,
    this.efadaSalMonth2, this.efadaSalPaid2,
    this.efadaSalMonth3, this.efadaSalPaid3,
    this.efadaSalMonth4, this.efadaSalPaid4,
    this.efadaAbsenceDate,
    this.efadaReturned,
    this.efadaReturnDate,
    this.efadaNotReturned,
    this.efadaNotReturnedDate,
    this.efadaWorkRelated,
    this.efadaNotWorkRelated,
    this.efadaSalaryStopped,
    this.efadaSalaryContinued,
    this.efadaResponsibleName,
    this.efadaCity,
    this.efadaSignDate,
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
      ministryRegistrationNumber:
          j['ministry_registration_number'] as String?,
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
      spouseRegistrationNumber2:
          j['spouse_registration_number_2'] as String?,
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
      registrationDepartmentName:
          j['registration_department_name'] as String?,
      registrationDepartmentDate:
          j['registration_department_date'] as String?,
      registrationProcessedDate:
          j['registration_processed_date'] as String?,
      // Tasreeh Zawja
      tasreehSubscriberRegNum:
          j['tasreeh_subscriber_reg_num'] as String?,
      tasreehSubscriberName: j['tasreeh_subscriber_name'] as String?,
      tasreehSubscriberMother: j['tasreeh_subscriber_mother'] as String?,
      tasreehSubscriberFather: j['tasreeh_subscriber_father'] as String?,
      tasreehRegisterNum: j['tasreeh_register_num'] as String?,
      tasreehCompanyName: j['tasreeh_company_name'] as String?,
      tasreehCompanyRegNum: j['tasreeh_company_reg_num'] as String?,
      tasreehAddress: j['tasreeh_address'] as String?,
      tasreehSpouseFullName: j['tasreeh_spouse_full_name'] as String?,
      tasreehSpouseDob: _dt(j['tasreeh_spouse_dob']),
      tasreehSpouseHasWork: j['tasreeh_spouse_has_work'] as bool?,
      tasreehSpouseWorkType: j['tasreeh_spouse_work_type'] as String?,
      tasreehDeclarationDate: _dt(j['tasreeh_declaration_date']),
      // Declaration Employee
      declEmployerName: j['decl_employer_name'] as String?,
      declCommercialRegPlace: j['decl_commercial_reg_place'] as String?,
      declCommercialRegNumber: j['decl_commercial_reg_number'] as String?,
      declEmployerPhone: j['decl_employer_phone'] as String?,
      declWorkplaceAddress: j['decl_workplace_address'] as String?,
      declEmployeeGender: j['decl_employee_gender'] as String?,
      declEmployeeFirstName: j['decl_employee_first_name'] as String?,
      declEmployeeLastName: j['decl_employee_last_name'] as String?,
      declEmployeeFatherName: j['decl_employee_father_name'] as String?,
      declEmployeeMotherName: j['decl_employee_mother_name'] as String?,
      declBirthDatePlace: j['decl_birth_date_place'] as String?,
      declBirthDistrict: j['decl_birth_district'] as String?,
      declRegisterNumber: j['decl_register_number'] as String?,
      declMaritalStatus: j['decl_marital_status'] as String?,
      declReligion: j['decl_religion'] as String?,
      declIdResidencePlace: j['decl_id_residence_place'] as String?,
      declCurrentGovernorate: j['decl_current_governorate'] as String?,
      declCurrentDistrict: j['decl_current_district'] as String?,
      declCurrentCity: j['decl_current_city'] as String?,
      declCurrentNeighborhood: j['decl_current_neighborhood'] as String?,
      declCurrentStreet: j['decl_current_street'] as String?,
      declCurrentBuildingFloor:
          j['decl_current_building_floor'] as String?,
      declCurrentPhone: j['decl_current_phone'] as String?,
      declWorkStartDate: j['decl_work_start_date'] as String?,
      declMonthlyHours: j['decl_monthly_hours'] as String?,
      declWorkType: j['decl_work_type'] as String?,
      declCurrentJob: j['decl_current_job'] as String?,
      declCurrentSalary: j['decl_current_salary'] as String?,
      declSalaryAtEntry: j['decl_salary_at_entry'] as String?,
      declPaymentMethod: j['decl_payment_method'] as String?,
      declNationality: j['decl_nationality'] as String?,
      declWorkPermit: j['decl_work_permit'] as String?,
      declHasOtherEmployer: j['decl_has_other_employer'] as bool?,
      declOtherEmployerInfo: j['decl_other_employer_info'] as String?,
      declEmployeeSignedName: j['decl_employee_signed_name'] as String?,
      declDeclarationDate: _dt(j['decl_declaration_date']),
      // Efada fields
      efadaInstitutionName: j['efada_institution_name'] as String?,
      efadaInstitutionNssfNum: j['efada_institution_nssf_num'] as String?,
      efadaEmployeeName: j['efada_employee_name'] as String?,
      efadaEmployeeNssfNum: j['efada_employee_nssf_num'] as String?,
      efadaIllnessDuration: j['efada_illness_duration'] as String?,
      efadaDistribution: j['efada_distribution'] as String?,
      efadaMonth1: j['efada_month1'] as String?,
      efadaDays1: j['efada_days1'] as String?,
      efadaFrom1_1: j['efada_from1_1'] as String?,
      efadaTo1_1: j['efada_to1_1'] as String?,
      efadaFrom2_1: j['efada_from2_1'] as String?,
      efadaTo2_1: j['efada_to2_1'] as String?,
      efadaFrom3_1: j['efada_from3_1'] as String?,
      efadaTo3_1: j['efada_to3_1'] as String?,
      efadaMonth2: j['efada_month2'] as String?,
      efadaDays2: j['efada_days2'] as String?,
      efadaFrom1_2: j['efada_from1_2'] as String?,
      efadaTo1_2: j['efada_to1_2'] as String?,
      efadaFrom2_2: j['efada_from2_2'] as String?,
      efadaTo2_2: j['efada_to2_2'] as String?,
      efadaFrom3_2: j['efada_from3_2'] as String?,
      efadaTo3_2: j['efada_to3_2'] as String?,
      efadaMonth3: j['efada_month3'] as String?,
      efadaDays3: j['efada_days3'] as String?,
      efadaFrom1_3: j['efada_from1_3'] as String?,
      efadaTo1_3: j['efada_to1_3'] as String?,
      efadaFrom2_3: j['efada_from2_3'] as String?,
      efadaTo2_3: j['efada_to2_3'] as String?,
      efadaFrom3_3: j['efada_from3_3'] as String?,
      efadaTo3_3: j['efada_to3_3'] as String?,
      efadaMonth4: j['efada_month4'] as String?,
      efadaDays4: j['efada_days4'] as String?,
      efadaFrom1_4: j['efada_from1_4'] as String?,
      efadaTo1_4: j['efada_to1_4'] as String?,
      efadaFrom2_4: j['efada_from2_4'] as String?,
      efadaTo2_4: j['efada_to2_4'] as String?,
      efadaFrom3_4: j['efada_from3_4'] as String?,
      efadaTo3_4: j['efada_to3_4'] as String?,
      efadaMonth5: j['efada_month5'] as String?,
      efadaDays5: j['efada_days5'] as String?,
      efadaFrom1_5: j['efada_from1_5'] as String?,
      efadaTo1_5: j['efada_to1_5'] as String?,
      efadaFrom2_5: j['efada_from2_5'] as String?,
      efadaTo2_5: j['efada_to2_5'] as String?,
      efadaFrom3_5: j['efada_from3_5'] as String?,
      efadaTo3_5: j['efada_to3_5'] as String?,
      efadaMonth6: j['efada_month6'] as String?,
      efadaDays6: j['efada_days6'] as String?,
      efadaFrom1_6: j['efada_from1_6'] as String?,
      efadaTo1_6: j['efada_to1_6'] as String?,
      efadaFrom2_6: j['efada_from2_6'] as String?,
      efadaTo2_6: j['efada_to2_6'] as String?,
      efadaFrom3_6: j['efada_from3_6'] as String?,
      efadaTo3_6: j['efada_to3_6'] as String?,
      efadaMonth7: j['efada_month7'] as String?,
      efadaDays7: j['efada_days7'] as String?,
      efadaFrom1_7: j['efada_from1_7'] as String?,
      efadaTo1_7: j['efada_to1_7'] as String?,
      efadaFrom2_7: j['efada_from2_7'] as String?,
      efadaTo2_7: j['efada_to2_7'] as String?,
      efadaFrom3_7: j['efada_from3_7'] as String?,
      efadaTo3_7: j['efada_to3_7'] as String?,
      efadaTotalAmount: j['efada_total_amount'] as String?,
      efadaSalMonth1: j['efada_sal_month1'] as String?,
      efadaSalPaid1: j['efada_sal_paid1'] as String?,
      efadaSalMonth2: j['efada_sal_month2'] as String?,
      efadaSalPaid2: j['efada_sal_paid2'] as String?,
      efadaSalMonth3: j['efada_sal_month3'] as String?,
      efadaSalPaid3: j['efada_sal_paid3'] as String?,
      efadaSalMonth4: j['efada_sal_month4'] as String?,
      efadaSalPaid4: j['efada_sal_paid4'] as String?,
      efadaAbsenceDate: j['efada_absence_date'] as String?,
      efadaReturned: j['efada_returned'] as bool?,
      efadaReturnDate: j['efada_return_date'] as String?,
      efadaNotReturned: j['efada_not_returned'] as bool?,
      efadaNotReturnedDate: j['efada_not_returned_date'] as String?,
      efadaWorkRelated: j['efada_work_related'] as bool?,
      efadaNotWorkRelated: j['efada_not_work_related'] as bool?,
      efadaSalaryStopped: j['efada_salary_stopped'] as bool?,
      efadaSalaryContinued: j['efada_salary_continued'] as bool?,
      efadaResponsibleName: j['efada_responsible_name'] as String?,
      efadaCity: j['efada_city'] as String?,
      efadaSignDate: j['efada_sign_date'] as String?,
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























