// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StudentData {
    struct Student {
        uint256 id;
        string name;
        uint8 age;
        string course;
        string email;
    }

    mapping(uint256 => Student) private students;

    event StudentCreated(uint256 id, string name);
    event StudentUpdated(uint256 id, string name);
    event StudentDeleted(uint256 id);

    function createStudent(uint256 id, string memory name, uint8 age, string memory course, string memory email) public {
        require(bytes(name).length > 0, "Name required");
        require(age > 0, "Invalid age");
        require(students[id].id == 0, "ID exists");

        students[id] = Student(id, name, age, course, email);
        emit StudentCreated(id, name);
    }

    function getStudent(uint256 id) public view returns (Student memory) {
        require(students[id].id != 0, "Student not found");
        return students[id];
    }

    function updateStudent(uint256 id, string memory name, uint8 age, string memory course, string memory email) public {
        require(students[id].id != 0, "Student not found");

        students[id] = Student(id, name, age, course, email);
        emit StudentUpdated(id, name);
    }

    function deleteStudent(uint256 id) public {
        require(students[id].id != 0, "Student not found");

        delete students[id];
        emit StudentDeleted(id);
    }
}
