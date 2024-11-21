// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RealEstate {
    // State variables
    address public admin; // Contract admin

    struct Property {
        uint propertyId;
        string location;
        uint price; // Price in Wei
        address payable owner;
        bool isForSale;
    }

    struct LeaseAgreement {
        uint propertyId;
        address tenant;
        uint monthlyRent; // Rent amount in Wei
        uint leaseEndDate; // Timestamp of lease end date
        bool active;
    }

    uint public totalProperties;
    uint public totalLeases;

    mapping(uint => Property) public properties; // Mapping of property ID to Property
    mapping(uint => LeaseAgreement) public leases; // Mapping of lease ID to LeaseAgreement

    // Events
    event PropertyListed(uint propertyId, string location, uint price);
    event PropertySold(uint propertyId, address newOwner);
    event LeaseCreated(uint leaseId, uint propertyId, address tenant, uint monthlyRent);
    event RentPaid(uint leaseId, uint amount, uint timestamp);

    // Constructor
    constructor() {
        admin = msg.sender; // Set deployer as admin
    }

    // Modifier to restrict actions to the admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action.");
        _;
    }

    // Function to list a property for sale
    function listProperty(string memory _location, uint _price, address payable _owner) public onlyAdmin {
        require(_price > 0, "Price must be greater than zero.");

        uint propertyId = totalProperties++;
        properties[propertyId] = Property(propertyId, _location, _price, _owner, true);

        emit PropertyListed(propertyId, _location, _price);
    }

    // Function to buy a property
    function buyProperty(uint _propertyId) public payable {
        Property storage property = properties[_propertyId];
        require(property.isForSale, "Property is not for sale.");
        require(msg.value == property.price, "Incorrect payment amount.");

        // Transfer ownership
        property.owner.transfer(msg.value);
        property.owner = payable(msg.sender);
        property.isForSale = false;

        emit PropertySold(_propertyId, msg.sender);
    }

    // Function to create a lease agreement
    function createLease(uint _propertyId, address _tenant, uint _monthlyRent, uint _leaseDurationInMonths) public {
        Property storage property = properties[_propertyId];
        require(property.owner == msg.sender, "Only the property owner can create a lease.");
        require(!property.isForSale, "Cannot lease a property that is for sale.");

        uint leaseId = totalLeases++;
        uint leaseEndDate = block.timestamp + (_leaseDurationInMonths * 30 days);
        leases[leaseId] = LeaseAgreement(_propertyId, _tenant, _monthlyRent, leaseEndDate, true);

        emit LeaseCreated(leaseId, _propertyId, _tenant, _monthlyRent);
    }

    // Payable function for tenants to pay rent
    function payRent(uint _leaseId) public payable {
        LeaseAgreement storage lease = leases[_leaseId];
        require(lease.active, "Lease is not active.");
        require(lease.tenant == msg.sender, "Only the tenant can pay rent.");
        require(msg.value == lease.monthlyRent, "Incorrect rent amount.");
        require(block.timestamp <= lease.leaseEndDate, "Lease has expired.");

        Property storage property = properties[lease.propertyId];
        property.owner.transfer(msg.value);

        emit RentPaid(_leaseId, msg.value, block.timestamp);
    }

    // Function to terminate a lease
    function terminateLease(uint _leaseId) public {
        LeaseAgreement storage lease = leases[_leaseId];
        require(lease.active, "Lease is already terminated.");
        require(
            msg.sender == admin || msg.sender == lease.tenant || msg.sender == properties[lease.propertyId].owner,
            "Only admin, tenant, or property owner can terminate the lease."
        );

        lease.active = false;
    }

    // Function to get property details
    function getPropertyDetails(uint _propertyId) public view returns (string memory, uint, address, bool) {
        Property memory property = properties[_propertyId];
        return (property.location, property.price, property.owner, property.isForSale);
    }

    // Function to get lease details
    function getLeaseDetails(uint _leaseId) public view returns (uint, address, uint, uint, bool) {
        LeaseAgreement memory lease = leases[_leaseId];
        return (lease.propertyId, lease.tenant, lease.monthlyRent, lease.leaseEndDate, lease.active);
    }
}