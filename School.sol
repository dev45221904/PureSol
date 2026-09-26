// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract School{

    uint256 public constant Fees = 4e18;

    uint256 public constant Wages = 1e18;

    address immutable owner;

    address Admin;

    struct student{
        address addres;
        string name;
        uint256 id;
        uint256 roll;
    }
    student[] public Students;

    struct faculty{
        address wallet;
        string name;
        uint256 id;
        string subject;
    }
    faculty[] public Faculties;

    address[] public classroom;

    mapping (address => bool) public HasPaid;
    mapping (address => bool) public IsPresent;
    mapping (uint256 => bool) public WagesGiven;
    mapping (address => bool) public IsFaculty;
    mapping (address => bool) public IsStudent;
    mapping (address => bool) public StudentPresent;
    mapping (uint256 => bool) public IsHePresent;

    constructor()  {
        owner = msg.sender;
    }

    modifier OnlyAdmin(){
        Admin = owner;
        require(msg.sender == Admin, "You are not admin");
        _;
    }

    modifier OnlyFaculty(){
        require(IsFaculty[msg.sender], "You are not faculty!");
        _;
    }

    modifier OnlyStudent(){
        require(IsStudent[msg.sender], "Not a student");
        _;
    }

    function EnrollFaculty(address _address, string memory _name, uint256 _id, string memory _sub) public OnlyAdmin{
        Faculties.push(faculty(_address,_name,_id,_sub));
        IsFaculty[_address] = true;
    }

    function EnrollStudents(address _address, string memory _name, uint256 _id, uint256 _roll) public OnlyAdmin{
        Students.push(student(_address,_name,_id,_roll));
        IsStudent[_address] = true;
    }

    function facultyLogin() public OnlyFaculty returns(bool) {
        bool activity = IsPresent[msg.sender] = true;
        return activity;
    }

    function PayFees() public payable OnlyStudent{
        require(msg.value == Fees, "Pay the valid amount");
        HasPaid[msg.sender] = true;
    }

    function setclassroom(address _Swallet) public  OnlyFaculty{
        require(HasPaid[_Swallet], "fees not paid");
        classroom.push(_Swallet);
    }

    function markattendence(address _student) public OnlyFaculty returns(bool){
        require(HasPaid[_student], "Student hasn't paid fees / not in classroom");
        StudentPresent[_student] = true;
        return true;
    }

    function PayFaculty(address _faculty) public payable  OnlyAdmin {
        require(IsFaculty[_faculty], "Not Faculty!!");
        require(msg.value == Wages, "Invalid Amount");
        (bool success, ) = _faculty.call{value: Wages}("");
        require(success, "ETH transfer failed");
    } 
}