// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HospitalManagement {
    // State variables
    address public owner; // Hospital admin
    uint public totalPatients; // Total registered patients
    uint public totalDoctors; // Total registered doctors

    // Patient and Doctor structs
    struct Patient {
        string name;
        uint age;
        string medicalHistory;
        address wallet;
    }

    struct Doctor {
        string name;
        string specialization;
        address wallet;
    }

    // Mappings for storing doctors and patients
    mapping(address => Patient) public patients;
    mapping(address => Doctor) public doctors;

    // Constructor
    constructor() {
        owner = msg.sender; // Set the contract deployer as the owner
    }

    // Modifier for access control
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    // Modifier to check if the caller is registered as a patient
    modifier onlyPatient() {
        require(bytes(patients[msg.sender].name).length > 0, "Caller is not a registered patient.");
        _;
    }

    // Modifier to check if the caller is registered as a doctor
    modifier onlyDoctor() {
        require(bytes(doctors[msg.sender].name).length > 0, "Caller is not a registered doctor.");
        _;
    }

    // Function to register a patient
    function registerPatient(string memory _name, uint _age, string memory _medicalHistory) public {
        require(bytes(patients[msg.sender].name).length == 0, "Patient is already registered.");
        patients[msg.sender] = Patient(_name, _age, _medicalHistory, msg.sender);
        totalPatients++;
    }

    // Function to register a doctor (only by owner)
    function registerDoctor(address _doctorAddress, string memory _name, string memory _specialization) public onlyOwner {
        require(bytes(doctors[_doctorAddress].name).length == 0, "Doctor is already registered.");
        doctors[_doctorAddress] = Doctor(_name, _specialization, _doctorAddress);
        totalDoctors++;
    }

    // Function to update medical history (only for patients)
    function updateMedicalHistory(string memory _newHistory) public onlyPatient {
        patients[msg.sender].medicalHistory = _newHistory;
    }

    // Payable function for consultation fees
    function payConsultationFee(address _doctorAddress) public payable {
        require(bytes(doctors[_doctorAddress].name).length > 0, "Doctor not found.");
        require(msg.value > 0, "Consultation fee must be greater than 0.");
        payable(_doctorAddress).transfer(msg.value); // Transfer funds to doctor
    }

    // Function to get patient details (only by owner or the patient)
    function getPatientDetails(address _patientAddress) public view onlyOwner returns (string memory, uint, string memory) {
        Patient memory p = patients[_patientAddress];
        return (p.name, p.age, p.medicalHistory);
    }
}