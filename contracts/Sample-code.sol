// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HealthPortal {
    address public owner;

    enum Role {None, Patient, Doctor}

    struct User {
        Role role;
        bool isRegistered;
        string name;
        uint256 age;
        address workplace; // Address of hospital/clinic for doctor
    }

    struct Disease {
        string name;
    }

    struct Medicine {
        uint256 id;
        string name;
        string expiryDate;
        string dose;
        uint256 price;
    }

    mapping(address => User) public users;
    mapping(address => Disease[]) public patientDiseases;
    mapping(uint256 => Medicine) public medicines;
    mapping(address => uint256[]) public prescribedMedicines;
    mapping(address => mapping(address => Disease[])) public doctorPatientDiseases;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier onlyPatient() {
        require(users[msg.sender].role == Role.Patient, "Only patients can call this function");
        _;
    }

    modifier onlyDoctor() {
        require(users[msg.sender].role == Role.Doctor, "Only doctors can call this function");
        _;
    }

    event DoctorRegistered(address indexed doctor, string name, string qualification, address workplace);
    event PatientRegistered(address indexed patient, string name, uint256 age);
    event DiseaseAdded(address indexed patient, string disease);
    event MedicineAdded(uint256 indexed id, string name, string expiryDate, string dose, uint256 price);
    event MedicinePrescribed(address indexed doctor, address indexed patient, uint256 indexed medicineId);
    event AgeUpdated(address indexed patient, uint256 newAge);
    event PatientDataViewed(address indexed patient, uint256 age, string name, string[] diseases);
    event MedicineDetailsViewed(uint256 indexed id, string name, string expiryDate, string dose, uint256 price);
    event PrescribedMedicinesViewed(address indexed patient, uint256[] medicineIds);
    event PatientDataViewedByDoctor(address indexed doctor, address indexed patient, uint256 age, string name, string[] diseases);
    event DoctorDetailsViewed(address indexed doctor, string name, string qualification, address workplace);

    constructor() {
        owner = msg.sender;
    }

    function registerDoctor(string memory _name, string memory _qualification, address _workplace) external {
        require(!users[msg.sender].isRegistered, "User already registered");
        
        users[msg.sender] = User({
            role: Role.Doctor,
            isRegistered: true,
            name: _name,
            age: 0,
            workplace: _workplace
        });

        emit DoctorRegistered(msg.sender, _name, _qualification, _workplace);
    }

    function registerPatient(string memory _name, uint256 _age) external {
        require(!users[msg.sender].isRegistered, "User already registered");
        
        users[msg.sender] = User({
            role: Role.Patient,
            isRegistered: true,
            name: _name,
            age: _age,
            workplace: address(0)
        });

        emit PatientRegistered(msg.sender, _name, _age);
    }

    function addPatientDisease(string memory _disease) external onlyPatient {
        patientDiseases[msg.sender].push(Disease(_disease));
        emit DiseaseAdded(msg.sender, _disease);
    }

    function addMedicine(uint256 _id, string memory _name, string memory _expiryDate, string memory _dose, uint256 _price) external onlyOwner {
        require(medicines[_id].id == 0, "Medicine ID already exists");

        medicines[_id] = Medicine({
            id: _id,
            name: _name,
            expiryDate: _expiryDate,
            dose: _dose,
            price: _price
        });

        emit MedicineAdded(_id, _name, _expiryDate, _dose, _price);
    }

    function prescribeMedicine(uint256 _id, address _patient) external onlyDoctor {
        require(users[_patient].role == Role.Patient, "Invalid patient address");
        require(medicines[_id].id != 0, "Medicine ID does not exist");

        prescribedMedicines[_patient].push(_id);
        emit MedicinePrescribed(msg.sender, _patient, _id);
    }

    function updatePatientAge(uint256 _age) external onlyPatient {
        users[msg.sender].age = _age;
        emit AgeUpdated(msg.sender, _age);
    }

    function viewPatientData() external onlyPatient view returns (uint256, string memory, string[] memory) {
        return (users[msg.sender].age, users[msg.sender].name, getPatientDiseases(msg.sender));
    }

    function viewMedicineDetails(uint256 _id) external view returns (string memory, string memory, string memory, uint256) {
        require(medicines[_id].id != 0, "Medicine ID does not exist");
        Medicine memory medicine = medicines[_id];
        return (medicine.name, medicine.expiryDate, medicine.dose, medicine.price);
    }

    function viewPrescribedMedicines() external onlyPatient view returns (uint256[] memory) {
        return prescribedMedicines[msg.sender];
    }

    function viewPatientDataByDoctor(address _patient) external onlyDoctor view returns (uint256, string memory, string[] memory) {
        require(users[_patient].role == Role.Patient, "Invalid patient address");
        return (users[_patient].age, users[_patient].name, getPatientDiseases(_patient));
    }

    function viewDoctorDetails(address _doctor) external view returns (string memory, string memory, address) {
        require(users[_doctor].role == Role.Doctor, "Invalid doctor address");
        User memory doctor = users[_doctor];
        return (doctor.name, "Doctor", doctor.workplace);
    }

    function getPatientDiseases(address _patient) private view returns (string[] memory) {
        uint256 length = patientDiseases[_patient].length;
        string[] memory diseases = new string[](length);
        for (uint256 i = 0; i < length; i++) {
            diseases[i] = patientDiseases[_patient][i].name;
        }
        return diseases;
    }
}
