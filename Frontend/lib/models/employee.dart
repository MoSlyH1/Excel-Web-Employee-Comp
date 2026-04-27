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

  // ── Efadet Amal (CNSS 489 / إفادة عمل وراتب) ────────────────────
  final String? efadetIncomingNumber;
  final String? efadetIncomingDate;
  final String? efadetOfficeName;
  final String? efadetCompanyName;
  final String? efadetCnssRegNum;
  final String? efadetEmployeeName;
  final String? efadetEmployeeRegNum;
  final String? efadetStartDate;
  final String? efadetMonthlySalary;
  final String? efadetDeclarationDate;

    // ── Talab Thkyk (CNSS 482 / طلب اجراء تحقيق اجتماعي) ───────────────────
  final String? talabMaktab;                        // مكتب
  final String? talabRaqmWared;                     // رقم الوارد
  final String? talabTarikh;                        // تاريخ
  final String? talabLilIstifadaAn;                 // للاستفادة عن
  final String? talabIsmMadmoon;                    // اسم المضمون
  final String? talabRaqmhiFiDaman;                 // رقمه في الضمان
  final String? talabMuassasaWaRaqmuha;             // المؤسسة ورقمها
  final String? talabAjrShahri;                     // الاجر الشهري
  final String? talabIsmWaledWaTarikhWiladatih;     // اسم الوالد وتاريخ ولادته
  final String? talabIsmWaledaWaTarikhWiladatiha;   // اسم الوالدة وتاريخ ولادتها
  final String? talabQada;                          // القضاء
  final String? talabBalda;                         // البلدة
  final String? talabShare3;                        // شارع
  final String? talabMilk;                          // ملك
  final String? talabQurb;                          // قرب
  final String? talabHatif;                         // هاتف
  final String? talabAshiqqa1;                      // شقيق/شقيقة 1
  final String? talabAshiqqa2;                      // شقيق/شقيقة 2
  final String? talabAshiqqa3;                      // شقيق/شقيقة 3
  final String? talabAshiqqa4;                      // شقيق/شقيقة 4
  final String? talabAshiqqa5;                      // شقيق/شقيقة 5
  final String? talabAshiqqa6;                      // شقيق/شقيقة 6
  final String? talabAshiqqa7;                      // شقيق/شقيقة 7
  final String? talabAshiqqa8;                      // شقيق/شقيقة 8
  final String? talabAmalWaledeen;                  // عمل الوالد/الوالدة قبل الوفاة
  final String? talabMadakhilWaledeen;              // مداخيل الوالدين
  final String? talabRaqmiFilDaman;                 // رقمي في الضمان (signature)
 


  final String? alkasebMuassasa;          // تفيد مؤسسة
  final String? alkasebRaqmuha;           // رقمها
  final String? alkasebUnwan;             // العنوان
  final String? alkasebHatif;             // هاتف
  final String? alkasebBaridElektroni;    // بريد إلكتروني
  final String? alkasebIsmMadmoon;        // ان المضمون
  final String? alkasebRaqmuhu;           // رقمه
  final String? alkasebMinTarikh;         // عمل لحسابها من تاريخ
  final String? alkasebLighayet;          // لغاية
  final String? alkasebWageType;          // 'shahri'|'usbui'|'yawmi'|'saaa'
  // Shahri
  final String? alkasebAjrShahriAkhir;   // أجر الشهر الأخير
  final String? alkasebFaqatShahri;       // فقط (شهري)
  // Usbui
  final String? alkasebAdadAsabii;        // عدد أسابيع العمل
  final String? alkasebAjrUsbuyiAkhir;   // أجر الأسبوع الأخير
  final String? alkasebFaqatUsbui;        // فقط (أسبوعي)
  // Yawmi
  final String? alkasebAdadAyyam;         // عدد أيام العمل
  final String? alkasebAjrYawmiAkhir;    // الأجر اليومي الأخير
  final String? alkasebFaqatYawmi;        // فقط (يومي)
  // Saaa
  final String? alkasebMajmuSaaat;        // مجموع ساعات العمل
  final String? alkasebAjrSaaAkhira;     // أجر الساعة الأخيرة
  final String? alkasebFaqatSaaa;         // فقط (بالساعة)
  // Signature
  final String? alkasebIsmMasool;         // اسم المسؤول
  final String? alkasebSifatMasool;       // صفته
  final String? alkasebAlmuwaqiAdnah;     // الموقع أدناه

  // ── BayanMafsal flat fields ─────────────────────────────────────
  // Header
  final String? bayanIsmAjir;
  final String? bayanRaqmuhuFiSunduq;
  final String? bayanSana1;
  final String? bayanSana2;
  final String? bayanIsmMasool;
  final String? bayanSifatMasool;

  // Year 1 — months 1–12 + total
  final String? bayanY1Basic1;   final String? bayanY1Lawahiq1;   final String? bayanY1Maqbudat1;  final String? bayanY1Majmuu1;   final String? bayanY1Mulahazat1;
  final String? bayanY1Basic2;   final String? bayanY1Lawahiq2;   final String? bayanY1Maqbudat2;  final String? bayanY1Majmuu2;   final String? bayanY1Mulahazat2;
  final String? bayanY1Basic3;   final String? bayanY1Lawahiq3;   final String? bayanY1Maqbudat3;  final String? bayanY1Majmuu3;   final String? bayanY1Mulahazat3;
  final String? bayanY1Basic4;   final String? bayanY1Lawahiq4;   final String? bayanY1Maqbudat4;  final String? bayanY1Majmuu4;   final String? bayanY1Mulahazat4;
  final String? bayanY1Basic5;   final String? bayanY1Lawahiq5;   final String? bayanY1Maqbudat5;  final String? bayanY1Majmuu5;   final String? bayanY1Mulahazat5;
  final String? bayanY1Basic6;   final String? bayanY1Lawahiq6;   final String? bayanY1Maqbudat6;  final String? bayanY1Majmuu6;   final String? bayanY1Mulahazat6;
  final String? bayanY1Basic7;   final String? bayanY1Lawahiq7;   final String? bayanY1Maqbudat7;  final String? bayanY1Majmuu7;   final String? bayanY1Mulahazat7;
  final String? bayanY1Basic8;   final String? bayanY1Lawahiq8;   final String? bayanY1Maqbudat8;  final String? bayanY1Majmuu8;   final String? bayanY1Mulahazat8;
  final String? bayanY1Basic9;   final String? bayanY1Lawahiq9;   final String? bayanY1Maqbudat9;  final String? bayanY1Majmuu9;   final String? bayanY1Mulahazat9;
  final String? bayanY1Basic10;  final String? bayanY1Lawahiq10;  final String? bayanY1Maqbudat10; final String? bayanY1Majmuu10;  final String? bayanY1Mulahazat10;
  final String? bayanY1Basic11;  final String? bayanY1Lawahiq11;  final String? bayanY1Maqbudat11; final String? bayanY1Majmuu11;  final String? bayanY1Mulahazat11;
  final String? bayanY1Basic12;  final String? bayanY1Lawahiq12;  final String? bayanY1Maqbudat12; final String? bayanY1Majmuu12;  final String? bayanY1Mulahazat12;
  final String? bayanY1TotalBasic; final String? bayanY1TotalLawahiq; final String? bayanY1TotalMaqbudat; final String? bayanY1TotalMajmuu; final String? bayanY1TotalMulahazat;

  // Year 2 — months 1–12 + total
  final String? bayanY2Basic1;   final String? bayanY2Lawahiq1;   final String? bayanY2Maqbudat1;  final String? bayanY2Majmuu1;   final String? bayanY2Mulahazat1;
  final String? bayanY2Basic2;   final String? bayanY2Lawahiq2;   final String? bayanY2Maqbudat2;  final String? bayanY2Majmuu2;   final String? bayanY2Mulahazat2;
  final String? bayanY2Basic3;   final String? bayanY2Lawahiq3;   final String? bayanY2Maqbudat3;  final String? bayanY2Majmuu3;   final String? bayanY2Mulahazat3;
  final String? bayanY2Basic4;   final String? bayanY2Lawahiq4;   final String? bayanY2Maqbudat4;  final String? bayanY2Majmuu4;   final String? bayanY2Mulahazat4;
  final String? bayanY2Basic5;   final String? bayanY2Lawahiq5;   final String? bayanY2Maqbudat5;  final String? bayanY2Majmuu5;   final String? bayanY2Mulahazat5;
  final String? bayanY2Basic6;   final String? bayanY2Lawahiq6;   final String? bayanY2Maqbudat6;  final String? bayanY2Majmuu6;   final String? bayanY2Mulahazat6;
  final String? bayanY2Basic7;   final String? bayanY2Lawahiq7;   final String? bayanY2Maqbudat7;  final String? bayanY2Majmuu7;   final String? bayanY2Mulahazat7;
  final String? bayanY2Basic8;   final String? bayanY2Lawahiq8;   final String? bayanY2Maqbudat8;  final String? bayanY2Majmuu8;   final String? bayanY2Mulahazat8;
  final String? bayanY2Basic9;   final String? bayanY2Lawahiq9;   final String? bayanY2Maqbudat9;  final String? bayanY2Majmuu9;   final String? bayanY2Mulahazat9;
  final String? bayanY2Basic10;  final String? bayanY2Lawahiq10;  final String? bayanY2Maqbudat10; final String? bayanY2Majmuu10;  final String? bayanY2Mulahazat10;
  final String? bayanY2Basic11;  final String? bayanY2Lawahiq11;  final String? bayanY2Maqbudat11; final String? bayanY2Majmuu11;  final String? bayanY2Mulahazat11;
  final String? bayanY2Basic12;  final String? bayanY2Lawahiq12;  final String? bayanY2Maqbudat12; final String? bayanY2Majmuu12;  final String? bayanY2Mulahazat12;
  final String? bayanY2TotalBasic; final String? bayanY2TotalLawahiq; final String? bayanY2TotalMaqbudat; final String? bayanY2TotalMajmuu; final String? bayanY2TotalMulahazat;

 // ── Tfwyd (تفويض باستلام الدعوة لتسديد المبالغ المستحقة) ────────
  final String? tfwydMustadei;              // المستدعي
  final String? tfwydIsmMuassasa;           // اسم المؤسسة
  final String? tfwydRaqmTasjilFiSunduq;   // رقم تسجيلها في الصندوق
  final String? tfwydUnwanMuassasa;         // عنوان المؤسسة
  final String? tfwydRaqmHatif;             // رقم الهاتف
  final String? tfwydIsmMasoolWaSifatuh;    // اسم المسؤول وصفته
  final String? tfwydIsmAjir;              // اسم الأجير
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
    // Efadet Amal
    this.efadetIncomingNumber,
    this.efadetIncomingDate,
    this.efadetOfficeName,
    this.efadetCompanyName,
    this.efadetCnssRegNum,
    this.efadetEmployeeName,
    this.efadetEmployeeRegNum,
    this.efadetStartDate,
    this.efadetMonthlySalary,
    this.efadetDeclarationDate,

    this.talabMaktab,
    this.talabRaqmWared,
    this.talabTarikh,
    this.talabLilIstifadaAn,
    this.talabIsmMadmoon,
    this.talabRaqmhiFiDaman,
    this.talabMuassasaWaRaqmuha,
    this.talabAjrShahri,
    this.talabIsmWaledWaTarikhWiladatih,
    this.talabIsmWaledaWaTarikhWiladatiha,
    this.talabQada,
    this.talabBalda,
    this.talabShare3,
    this.talabMilk,
    this.talabQurb,
    this.talabHatif,
    this.talabAshiqqa1,
    this.talabAshiqqa2,
    this.talabAshiqqa3,
    this.talabAshiqqa4,
    this.talabAshiqqa5,
    this.talabAshiqqa6,
    this.talabAshiqqa7,
    this.talabAshiqqa8,
    this.talabAmalWaledeen,
    this.talabMadakhilWaledeen,
    this.talabRaqmiFilDaman,

    this.alkasebMuassasa,
    this.alkasebRaqmuha,
    this.alkasebUnwan,
    this.alkasebHatif,
    this.alkasebBaridElektroni,
    this.alkasebIsmMadmoon,
    this.alkasebRaqmuhu,
    this.alkasebMinTarikh,
    this.alkasebLighayet,
    this.alkasebWageType,
    this.alkasebAjrShahriAkhir,
    this.alkasebFaqatShahri,
    this.alkasebAdadAsabii,
    this.alkasebAjrUsbuyiAkhir,
    this.alkasebFaqatUsbui,
    this.alkasebAdadAyyam,
    this.alkasebAjrYawmiAkhir,
    this.alkasebFaqatYawmi,
    this.alkasebMajmuSaaat,
    this.alkasebAjrSaaAkhira,
    this.alkasebFaqatSaaa,
    this.alkasebIsmMasool,
    this.alkasebSifatMasool,
    this.alkasebAlmuwaqiAdnah,

    // BayanMafsal fields
    this.bayanIsmAjir,
    this.bayanRaqmuhuFiSunduq,
    this.bayanSana1,
    this.bayanSana2,
    this.bayanIsmMasool,
    this.bayanSifatMasool,
    this.bayanY1Basic1, this.bayanY1Lawahiq1, this.bayanY1Maqbudat1, this.bayanY1Majmuu1, this.bayanY1Mulahazat1,
    this.bayanY1Basic2, this.bayanY1Lawahiq2, this.bayanY1Maqbudat2, this.bayanY1Majmuu2, this.bayanY1Mulahazat2,
    this.bayanY1Basic3, this.bayanY1Lawahiq3, this.bayanY1Maqbudat3, this.bayanY1Majmuu3, this.bayanY1Mulahazat3,
    this.bayanY1Basic4, this.bayanY1Lawahiq4, this.bayanY1Maqbudat4, this.bayanY1Majmuu4, this.bayanY1Mulahazat4,
    this.bayanY1Basic5, this.bayanY1Lawahiq5, this.bayanY1Maqbudat5, this.bayanY1Majmuu5, this.bayanY1Mulahazat5,
    this.bayanY1Basic6, this.bayanY1Lawahiq6, this.bayanY1Maqbudat6, this.bayanY1Majmuu6, this.bayanY1Mulahazat6,
    this.bayanY1Basic7, this.bayanY1Lawahiq7, this.bayanY1Maqbudat7, this.bayanY1Majmuu7, this.bayanY1Mulahazat7,
    this.bayanY1Basic8, this.bayanY1Lawahiq8, this.bayanY1Maqbudat8, this.bayanY1Majmuu8, this.bayanY1Mulahazat8,
    this.bayanY1Basic9, this.bayanY1Lawahiq9, this.bayanY1Maqbudat9, this.bayanY1Majmuu9, this.bayanY1Mulahazat9,
    this.bayanY1Basic10, this.bayanY1Lawahiq10, this.bayanY1Maqbudat10, this.bayanY1Majmuu10, this.bayanY1Mulahazat10,
    this.bayanY1Basic11, this.bayanY1Lawahiq11, this.bayanY1Maqbudat11, this.bayanY1Majmuu11, this.bayanY1Mulahazat11,
    this.bayanY1Basic12, this.bayanY1Lawahiq12, this.bayanY1Maqbudat12, this.bayanY1Majmuu12, this.bayanY1Mulahazat12,
    this.bayanY1TotalBasic, this.bayanY1TotalLawahiq, this.bayanY1TotalMaqbudat, this.bayanY1TotalMajmuu, this.bayanY1TotalMulahazat,
    this.bayanY2Basic1, this.bayanY2Lawahiq1, this.bayanY2Maqbudat1, this.bayanY2Majmuu1, this.bayanY2Mulahazat1,
    this.bayanY2Basic2, this.bayanY2Lawahiq2, this.bayanY2Maqbudat2, this.bayanY2Majmuu2, this.bayanY2Mulahazat2,
    this.bayanY2Basic3, this.bayanY2Lawahiq3, this.bayanY2Maqbudat3, this.bayanY2Majmuu3, this.bayanY2Mulahazat3,
    this.bayanY2Basic4, this.bayanY2Lawahiq4, this.bayanY2Maqbudat4, this.bayanY2Majmuu4, this.bayanY2Mulahazat4,
    this.bayanY2Basic5, this.bayanY2Lawahiq5, this.bayanY2Maqbudat5, this.bayanY2Majmuu5, this.bayanY2Mulahazat5,
    this.bayanY2Basic6, this.bayanY2Lawahiq6, this.bayanY2Maqbudat6, this.bayanY2Majmuu6, this.bayanY2Mulahazat6,
    this.bayanY2Basic7, this.bayanY2Lawahiq7, this.bayanY2Maqbudat7, this.bayanY2Majmuu7, this.bayanY2Mulahazat7,
    this.bayanY2Basic8, this.bayanY2Lawahiq8, this.bayanY2Maqbudat8, this.bayanY2Majmuu8, this.bayanY2Mulahazat8,
    this.bayanY2Basic9, this.bayanY2Lawahiq9, this.bayanY2Maqbudat9, this.bayanY2Majmuu9, this.bayanY2Mulahazat9,
    this.bayanY2Basic10, this.bayanY2Lawahiq10, this.bayanY2Maqbudat10, this.bayanY2Majmuu10, this.bayanY2Mulahazat10,
    this.bayanY2Basic11, this.bayanY2Lawahiq11, this.bayanY2Maqbudat11, this.bayanY2Majmuu11, this.bayanY2Mulahazat11,
    this.bayanY2Basic12, this.bayanY2Lawahiq12, this.bayanY2Maqbudat12, this.bayanY2Majmuu12, this.bayanY2Mulahazat12,
    this.bayanY2TotalBasic, this.bayanY2TotalLawahiq, this.bayanY2TotalMaqbudat, this.bayanY2TotalMajmuu, this.bayanY2TotalMulahazat,

        this.tfwydMustadei,
    this.tfwydIsmMuassasa,
    this.tfwydRaqmTasjilFiSunduq,
    this.tfwydUnwanMuassasa,
    this.tfwydRaqmHatif,
    this.tfwydIsmMasoolWaSifatuh,
    this.tfwydIsmAjir,
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
      // Efadet Amal
      efadetIncomingNumber: j['efadet_incoming_number'] as String?,
      efadetIncomingDate: j['efadet_incoming_date'] as String?,
      efadetOfficeName: j['efadet_office_name'] as String?,
      efadetCompanyName: j['efadet_company_name'] as String?,
      efadetCnssRegNum: j['efadet_cnss_reg_num'] as String?,
      efadetEmployeeName: j['efadet_employee_name'] as String?,
      efadetEmployeeRegNum: j['efadet_employee_reg_num'] as String?,
      efadetStartDate: j['efadet_start_date'] as String?,
      efadetMonthlySalary: j['efadet_monthly_salary'] as String?,
      efadetDeclarationDate: j['efadet_declaration_date'] as String?,

      talabMaktab: j['talab_maktab'] as String?,
      talabRaqmWared: j['talab_raqm_wared'] as String?,
      talabTarikh: j['talab_tarikh'] as String?,
      talabLilIstifadaAn: j['talab_lil_istifada_an'] as String?,
      talabIsmMadmoon: j['talab_ism_madmoon'] as String?,
      talabRaqmhiFiDaman: j['talab_raqmhi_fi_daman'] as String?,
      talabMuassasaWaRaqmuha: j['talab_muassasa_wa_raqmuha'] as String?,
      talabAjrShahri: j['talab_ajr_shahri'] as String?,
      talabIsmWaledWaTarikhWiladatih: j['talab_ism_waled_wa_tarikh_wiladatih'] as String?,
      talabIsmWaledaWaTarikhWiladatiha: j['talab_ism_waleda_wa_tarikh_wiladatiha'] as String?,
      talabQada: j['talab_qada'] as String?,
      talabBalda: j['talab_balda'] as String?,
      talabShare3: j['talab_share3'] as String?,
      talabMilk: j['talab_milk'] as String?,
      talabQurb: j['talab_qurb'] as String?,
      talabHatif: j['talab_hatif'] as String?,
      talabAshiqqa1: j['talab_ashiqqa1'] as String?,
      talabAshiqqa2: j['talab_ashiqqa2'] as String?,
      talabAshiqqa3: j['talab_ashiqqa3'] as String?,
      talabAshiqqa4: j['talab_ashiqqa4'] as String?,
      talabAshiqqa5: j['talab_ashiqqa5'] as String?,
      talabAshiqqa6: j['talab_ashiqqa6'] as String?,
      talabAshiqqa7: j['talab_ashiqqa7'] as String?,
      talabAshiqqa8: j['talab_ashiqqa8'] as String?,
      talabAmalWaledeen: j['talab_amal_waledeen'] as String?,
      talabMadakhilWaledeen: j['talab_madakhil_waledeen'] as String?,
      talabRaqmiFilDaman: j['talab_raqmi_fil_daman'] as String?,

      alkasebMuassasa: j['alkaseb_muassasa'] as String?,
      alkasebRaqmuha: j['alkaseb_raqmuha'] as String?,
      alkasebUnwan: j['alkaseb_unwan'] as String?,
      alkasebHatif: j['alkaseb_hatif'] as String?,
      alkasebBaridElektroni: j['alkaseb_barid_elektroni'] as String?,
      alkasebIsmMadmoon: j['alkaseb_ism_madmoon'] as String?,
      alkasebRaqmuhu: j['alkaseb_raqmuhu'] as String?,
      alkasebMinTarikh: j['alkaseb_min_tarikh'] as String?,
      alkasebLighayet: j['alkaseb_lighayet'] as String?,
      alkasebWageType: j['alkaseb_wage_type'] as String?,
      alkasebAjrShahriAkhir: j['alkaseb_ajr_shahri_akhir'] as String?,
      alkasebFaqatShahri: j['alkaseb_faqat_shahri'] as String?,
      alkasebAdadAsabii: j['alkaseb_adad_asabii'] as String?,
      alkasebAjrUsbuyiAkhir: j['alkaseb_ajr_usbuy_akhir'] as String?,
      alkasebFaqatUsbui: j['alkaseb_faqat_usbui'] as String?,
      alkasebAdadAyyam: j['alkaseb_adad_ayyam'] as String?,
      alkasebAjrYawmiAkhir: j['alkaseb_ajr_yawmi_akhir'] as String?,
      alkasebFaqatYawmi: j['alkaseb_faqat_yawmi'] as String?,
      alkasebMajmuSaaat: j['alkaseb_majmu_saaat'] as String?,
      alkasebAjrSaaAkhira: j['alkaseb_ajr_saa_akhira'] as String?,
      alkasebFaqatSaaa: j['alkaseb_faqat_saaa'] as String?,
      alkasebIsmMasool: j['alkaseb_ism_masool'] as String?,
      alkasebSifatMasool: j['alkaseb_sifat_masool'] as String?,
      alkasebAlmuwaqiAdnah: j['alkaseb_almuwaqi_adnah'] as String?,

      // BayanMafsal fields
      bayanIsmAjir:            j['bayan_ism_ajir'] as String?,
      bayanRaqmuhuFiSunduq:    j['bayan_raqmuhu_fi_sunduq'] as String?,
      bayanSana1:              j['bayan_sana1'] as String?,
      bayanSana2:              j['bayan_sana2'] as String?,
      bayanIsmMasool:          j['bayan_ism_masool'] as String?,
      bayanSifatMasool:        j['bayan_sifat_masool'] as String?,

      bayanY1Basic1:   j['bayan_y1_basic_1'] as String?,   bayanY1Lawahiq1:   j['bayan_y1_lawahiq_1'] as String?,   bayanY1Maqbudat1:  j['bayan_y1_maqbudat_1'] as String?,   bayanY1Majmuu1:   j['bayan_y1_majmuu_1'] as String?,   bayanY1Mulahazat1: j['bayan_y1_mulahazat_1'] as String?,
      bayanY1Basic2:   j['bayan_y1_basic_2'] as String?,   bayanY1Lawahiq2:   j['bayan_y1_lawahiq_2'] as String?,   bayanY1Maqbudat2:  j['bayan_y1_maqbudat_2'] as String?,   bayanY1Majmuu2:   j['bayan_y1_majmuu_2'] as String?,   bayanY1Mulahazat2: j['bayan_y1_mulahazat_2'] as String?,
      bayanY1Basic3:   j['bayan_y1_basic_3'] as String?,   bayanY1Lawahiq3:   j['bayan_y1_lawahiq_3'] as String?,   bayanY1Maqbudat3:  j['bayan_y1_maqbudat_3'] as String?,   bayanY1Majmuu3:   j['bayan_y1_majmuu_3'] as String?,   bayanY1Mulahazat3: j['bayan_y1_mulahazat_3'] as String?,
      bayanY1Basic4:   j['bayan_y1_basic_4'] as String?,   bayanY1Lawahiq4:   j['bayan_y1_lawahiq_4'] as String?,   bayanY1Maqbudat4:  j['bayan_y1_maqbudat_4'] as String?,   bayanY1Majmuu4:   j['bayan_y1_majmuu_4'] as String?,   bayanY1Mulahazat4: j['bayan_y1_mulahazat_4'] as String?,
      bayanY1Basic5:   j['bayan_y1_basic_5'] as String?,   bayanY1Lawahiq5:   j['bayan_y1_lawahiq_5'] as String?,   bayanY1Maqbudat5:  j['bayan_y1_maqbudat_5'] as String?,   bayanY1Majmuu5:   j['bayan_y1_majmuu_5'] as String?,   bayanY1Mulahazat5: j['bayan_y1_mulahazat_5'] as String?,
      bayanY1Basic6:   j['bayan_y1_basic_6'] as String?,   bayanY1Lawahiq6:   j['bayan_y1_lawahiq_6'] as String?,   bayanY1Maqbudat6:  j['bayan_y1_maqbudat_6'] as String?,   bayanY1Majmuu6:   j['bayan_y1_majmuu_6'] as String?,   bayanY1Mulahazat6: j['bayan_y1_mulahazat_6'] as String?,
      bayanY1Basic7:   j['bayan_y1_basic_7'] as String?,   bayanY1Lawahiq7:   j['bayan_y1_lawahiq_7'] as String?,   bayanY1Maqbudat7:  j['bayan_y1_maqbudat_7'] as String?,   bayanY1Majmuu7:   j['bayan_y1_majmuu_7'] as String?,   bayanY1Mulahazat7: j['bayan_y1_mulahazat_7'] as String?,
      bayanY1Basic8:   j['bayan_y1_basic_8'] as String?,   bayanY1Lawahiq8:   j['bayan_y1_lawahiq_8'] as String?,   bayanY1Maqbudat8:  j['bayan_y1_maqbudat_8'] as String?,   bayanY1Majmuu8:   j['bayan_y1_majmuu_8'] as String?,   bayanY1Mulahazat8: j['bayan_y1_mulahazat_8'] as String?,
      bayanY1Basic9:   j['bayan_y1_basic_9'] as String?,   bayanY1Lawahiq9:   j['bayan_y1_lawahiq_9'] as String?,   bayanY1Maqbudat9:  j['bayan_y1_maqbudat_9'] as String?,   bayanY1Majmuu9:   j['bayan_y1_majmuu_9'] as String?,   bayanY1Mulahazat9: j['bayan_y1_mulahazat_9'] as String?,
      bayanY1Basic10:  j['bayan_y1_basic_10'] as String?,  bayanY1Lawahiq10:  j['bayan_y1_lawahiq_10'] as String?,  bayanY1Maqbudat10: j['bayan_y1_maqbudat_10'] as String?,  bayanY1Majmuu10:  j['bayan_y1_majmuu_10'] as String?,  bayanY1Mulahazat10:j['bayan_y1_mulahazat_10'] as String?,
      bayanY1Basic11:  j['bayan_y1_basic_11'] as String?,  bayanY1Lawahiq11:  j['bayan_y1_lawahiq_11'] as String?,  bayanY1Maqbudat11: j['bayan_y1_maqbudat_11'] as String?,  bayanY1Majmuu11:  j['bayan_y1_majmuu_11'] as String?,  bayanY1Mulahazat11:j['bayan_y1_mulahazat_11'] as String?,
      bayanY1Basic12:  j['bayan_y1_basic_12'] as String?,  bayanY1Lawahiq12:  j['bayan_y1_lawahiq_12'] as String?,  bayanY1Maqbudat12: j['bayan_y1_maqbudat_12'] as String?,  bayanY1Majmuu12:  j['bayan_y1_majmuu_12'] as String?,  bayanY1Mulahazat12:j['bayan_y1_mulahazat_12'] as String?,
      bayanY1TotalBasic:   j['bayan_y1_total_basic'] as String?,   bayanY1TotalLawahiq:  j['bayan_y1_total_lawahiq'] as String?,  bayanY1TotalMaqbudat: j['bayan_y1_total_maqbudat'] as String?,  bayanY1TotalMajmuu: j['bayan_y1_total_majmuu'] as String?, bayanY1TotalMulahazat: j['bayan_y1_total_mulahazat'] as String?,

      bayanY2Basic1:   j['bayan_y2_basic_1'] as String?,   bayanY2Lawahiq1:   j['bayan_y2_lawahiq_1'] as String?,   bayanY2Maqbudat1:  j['bayan_y2_maqbudat_1'] as String?,   bayanY2Majmuu1:   j['bayan_y2_majmuu_1'] as String?,   bayanY2Mulahazat1: j['bayan_y2_mulahazat_1'] as String?,
      bayanY2Basic2:   j['bayan_y2_basic_2'] as String?,   bayanY2Lawahiq2:   j['bayan_y2_lawahiq_2'] as String?,   bayanY2Maqbudat2:  j['bayan_y2_maqbudat_2'] as String?,   bayanY2Majmuu2:   j['bayan_y2_majmuu_2'] as String?,   bayanY2Mulahazat2: j['bayan_y2_mulahazat_2'] as String?,
      bayanY2Basic3:   j['bayan_y2_basic_3'] as String?,   bayanY2Lawahiq3:   j['bayan_y2_lawahiq_3'] as String?,   bayanY2Maqbudat3:  j['bayan_y2_maqbudat_3'] as String?,   bayanY2Majmuu3:   j['bayan_y2_majmuu_3'] as String?,   bayanY2Mulahazat3: j['bayan_y2_mulahazat_3'] as String?,
      bayanY2Basic4:   j['bayan_y2_basic_4'] as String?,   bayanY2Lawahiq4:   j['bayan_y2_lawahiq_4'] as String?,   bayanY2Maqbudat4:  j['bayan_y2_maqbudat_4'] as String?,   bayanY2Majmuu4:   j['bayan_y2_majmuu_4'] as String?,   bayanY2Mulahazat4: j['bayan_y2_mulahazat_4'] as String?,
      bayanY2Basic5:   j['bayan_y2_basic_5'] as String?,   bayanY2Lawahiq5:   j['bayan_y2_lawahiq_5'] as String?,   bayanY2Maqbudat5:  j['bayan_y2_maqbudat_5'] as String?,   bayanY2Majmuu5:   j['bayan_y2_majmuu_5'] as String?,   bayanY2Mulahazat5: j['bayan_y2_mulahazat_5'] as String?,
      bayanY2Basic6:   j['bayan_y2_basic_6'] as String?,   bayanY2Lawahiq6:   j['bayan_y2_lawahiq_6'] as String?,   bayanY2Maqbudat6:  j['bayan_y2_maqbudat_6'] as String?,   bayanY2Majmuu6:   j['bayan_y2_majmuu_6'] as String?,   bayanY2Mulahazat6: j['bayan_y2_mulahazat_6'] as String?,
      bayanY2Basic7:   j['bayan_y2_basic_7'] as String?,   bayanY2Lawahiq7:   j['bayan_y2_lawahiq_7'] as String?,   bayanY2Maqbudat7:  j['bayan_y2_maqbudat_7'] as String?,   bayanY2Majmuu7:   j['bayan_y2_majmuu_7'] as String?,   bayanY2Mulahazat7: j['bayan_y2_mulahazat_7'] as String?,
      bayanY2Basic8:   j['bayan_y2_basic_8'] as String?,   bayanY2Lawahiq8:   j['bayan_y2_lawahiq_8'] as String?,   bayanY2Maqbudat8:  j['bayan_y2_maqbudat_8'] as String?,   bayanY2Majmuu8:   j['bayan_y2_majmuu_8'] as String?,   bayanY2Mulahazat8: j['bayan_y2_mulahazat_8'] as String?,
      bayanY2Basic9:   j['bayan_y2_basic_9'] as String?,   bayanY2Lawahiq9:   j['bayan_y2_lawahiq_9'] as String?,   bayanY2Maqbudat9:  j['bayan_y2_maqbudat_9'] as String?,   bayanY2Majmuu9:   j['bayan_y2_majmuu_9'] as String?,   bayanY2Mulahazat9: j['bayan_y2_mulahazat_9'] as String?,
      bayanY2Basic10:  j['bayan_y2_basic_10'] as String?,  bayanY2Lawahiq10:  j['bayan_y2_lawahiq_10'] as String?,  bayanY2Maqbudat10: j['bayan_y2_maqbudat_10'] as String?,  bayanY2Majmuu10:  j['bayan_y2_majmuu_10'] as String?,  bayanY2Mulahazat10:j['bayan_y2_mulahazat_10'] as String?,
      bayanY2Basic11:  j['bayan_y2_basic_11'] as String?,  bayanY2Lawahiq11:  j['bayan_y2_lawahiq_11'] as String?,  bayanY2Maqbudat11: j['bayan_y2_maqbudat_11'] as String?,  bayanY2Majmuu11:  j['bayan_y2_majmuu_11'] as String?,  bayanY2Mulahazat11:j['bayan_y2_mulahazat_11'] as String?,
      bayanY2Basic12:  j['bayan_y2_basic_12'] as String?,  bayanY2Lawahiq12:  j['bayan_y2_lawahiq_12'] as String?,  bayanY2Maqbudat12: j['bayan_y2_maqbudat_12'] as String?,  bayanY2Majmuu12:  j['bayan_y2_majmuu_12'] as String?,  bayanY2Mulahazat12:j['bayan_y2_mulahazat_12'] as String?,
      bayanY2TotalBasic:   j['bayan_y2_total_basic'] as String?,   bayanY2TotalLawahiq:  j['bayan_y2_total_lawahiq'] as String?,  bayanY2TotalMaqbudat: j['bayan_y2_total_maqbudat'] as String?,  bayanY2TotalMajmuu: j['bayan_y2_total_majmuu'] as String?, bayanY2TotalMulahazat: j['bayan_y2_total_mulahazat'] as String?,
       tfwydMustadei:            j['tfwyd_mustadei'] as String?,
      tfwydIsmMuassasa:         j['tfwyd_ism_muassasa'] as String?,
      tfwydRaqmTasjilFiSunduq:  j['tfwyd_raqm_tasjil_fi_sunduq'] as String?,
      tfwydUnwanMuassasa:       j['tfwyd_unwan_muassasa'] as String?,
      tfwydRaqmHatif:           j['tfwyd_raqm_hatif'] as String?,
      tfwydIsmMasoolWaSifatuh:  j['tfwyd_ism_masool_wa_sifatuh'] as String?,
      tfwydIsmAjir:             j['tfwyd_ism_ajir'] as String?,
    );
  }

  // ── BayanMafsal getter helpers (flat fields) ────────────────────
  String? bayanY1Basic(int m) {
    switch(m) {
      case 1: return bayanY1Basic1; case 2: return bayanY1Basic2;
      case 3: return bayanY1Basic3; case 4: return bayanY1Basic4;
      case 5: return bayanY1Basic5; case 6: return bayanY1Basic6;
      case 7: return bayanY1Basic7; case 8: return bayanY1Basic8;
      case 9: return bayanY1Basic9; case 10: return bayanY1Basic10;
      case 11: return bayanY1Basic11; case 12: return bayanY1Basic12;
      default: return null;
    }
  }
  String? bayanY1Lawahiq(int m) {
    switch(m) {
      case 1: return bayanY1Lawahiq1; case 2: return bayanY1Lawahiq2;
      case 3: return bayanY1Lawahiq3; case 4: return bayanY1Lawahiq4;
      case 5: return bayanY1Lawahiq5; case 6: return bayanY1Lawahiq6;
      case 7: return bayanY1Lawahiq7; case 8: return bayanY1Lawahiq8;
      case 9: return bayanY1Lawahiq9; case 10: return bayanY1Lawahiq10;
      case 11: return bayanY1Lawahiq11; case 12: return bayanY1Lawahiq12;
      default: return null;
    }
  }
  String? bayanY1Maqbudat(int m) {
    switch(m) {
      case 1: return bayanY1Maqbudat1; case 2: return bayanY1Maqbudat2;
      case 3: return bayanY1Maqbudat3; case 4: return bayanY1Maqbudat4;
      case 5: return bayanY1Maqbudat5; case 6: return bayanY1Maqbudat6;
      case 7: return bayanY1Maqbudat7; case 8: return bayanY1Maqbudat8;
      case 9: return bayanY1Maqbudat9; case 10: return bayanY1Maqbudat10;
      case 11: return bayanY1Maqbudat11; case 12: return bayanY1Maqbudat12;
      default: return null;
    }
  }
  String? bayanY1Majmuu(int m) {
    switch(m) {
      case 1: return bayanY1Majmuu1; case 2: return bayanY1Majmuu2;
      case 3: return bayanY1Majmuu3; case 4: return bayanY1Majmuu4;
      case 5: return bayanY1Majmuu5; case 6: return bayanY1Majmuu6;
      case 7: return bayanY1Majmuu7; case 8: return bayanY1Majmuu8;
      case 9: return bayanY1Majmuu9; case 10: return bayanY1Majmuu10;
      case 11: return bayanY1Majmuu11; case 12: return bayanY1Majmuu12;
      default: return null;
    }
  }
  String? bayanY1Mulahazat(int m) {
    switch(m) {
      case 1: return bayanY1Mulahazat1; case 2: return bayanY1Mulahazat2;
      case 3: return bayanY1Mulahazat3; case 4: return bayanY1Mulahazat4;
      case 5: return bayanY1Mulahazat5; case 6: return bayanY1Mulahazat6;
      case 7: return bayanY1Mulahazat7; case 8: return bayanY1Mulahazat8;
      case 9: return bayanY1Mulahazat9; case 10: return bayanY1Mulahazat10;
      case 11: return bayanY1Mulahazat11; case 12: return bayanY1Mulahazat12;
      default: return null;
    }
  }
  String? bayanY2Basic(int m) {
    switch(m) {
      case 1: return bayanY2Basic1; case 2: return bayanY2Basic2;
      case 3: return bayanY2Basic3; case 4: return bayanY2Basic4;
      case 5: return bayanY2Basic5; case 6: return bayanY2Basic6;
      case 7: return bayanY2Basic7; case 8: return bayanY2Basic8;
      case 9: return bayanY2Basic9; case 10: return bayanY2Basic10;
      case 11: return bayanY2Basic11; case 12: return bayanY2Basic12;
      default: return null;
    }
  }
  String? bayanY2Lawahiq(int m) {
    switch(m) {
      case 1: return bayanY2Lawahiq1; case 2: return bayanY2Lawahiq2;
      case 3: return bayanY2Lawahiq3; case 4: return bayanY2Lawahiq4;
      case 5: return bayanY2Lawahiq5; case 6: return bayanY2Lawahiq6;
      case 7: return bayanY2Lawahiq7; case 8: return bayanY2Lawahiq8;
      case 9: return bayanY2Lawahiq9; case 10: return bayanY2Lawahiq10;
      case 11: return bayanY2Lawahiq11; case 12: return bayanY2Lawahiq12;
      default: return null;
    }
  }
  String? bayanY2Maqbudat(int m) {
    switch(m) {
      case 1: return bayanY2Maqbudat1; case 2: return bayanY2Maqbudat2;
      case 3: return bayanY2Maqbudat3; case 4: return bayanY2Maqbudat4;
      case 5: return bayanY2Maqbudat5; case 6: return bayanY2Maqbudat6;
      case 7: return bayanY2Maqbudat7; case 8: return bayanY2Maqbudat8;
      case 9: return bayanY2Maqbudat9; case 10: return bayanY2Maqbudat10;
      case 11: return bayanY2Maqbudat11; case 12: return bayanY2Maqbudat12;
      default: return null;
    }
  }
  String? bayanY2Majmuu(int m) {
    switch(m) {
      case 1: return bayanY2Majmuu1; case 2: return bayanY2Majmuu2;
      case 3: return bayanY2Majmuu3; case 4: return bayanY2Majmuu4;
      case 5: return bayanY2Majmuu5; case 6: return bayanY2Majmuu6;
      case 7: return bayanY2Majmuu7; case 8: return bayanY2Majmuu8;
      case 9: return bayanY2Majmuu9; case 10: return bayanY2Majmuu10;
      case 11: return bayanY2Majmuu11; case 12: return bayanY2Majmuu12;
      default: return null;
    }
  }
  String? bayanY2Mulahazat(int m) {
    switch(m) {
      case 1: return bayanY2Mulahazat1; case 2: return bayanY2Mulahazat2;
      case 3: return bayanY2Mulahazat3; case 4: return bayanY2Mulahazat4;
      case 5: return bayanY2Mulahazat5; case 6: return bayanY2Mulahazat6;
      case 7: return bayanY2Mulahazat7; case 8: return bayanY2Mulahazat8;
      case 9: return bayanY2Mulahazat9; case 10: return bayanY2Mulahazat10;
      case 11: return bayanY2Mulahazat11; case 12: return bayanY2Mulahazat12;
      default: return null;
    }
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