// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import IAccessRestriction from "./../accessRestriction/IAccessRestriction.sol";
import "./IRate.sol";
import "./IAccessRestriction.sol";

contract Rate is IRate {
    IAccessRestriction public accessRestriction;
    struct Service {
        address submiter;
        string info;
        bool exists;
    }

    mapping(address => Service) public services;

    constructor(address _accessRestrictionAddress) {
        IAccessRestriction accessRestriction = IAccessRestriction(_address);
    }

    modifier validAddress(address _address) {
        require(_address != address(0), "Invalid address");
        _;
    }
    modifier isScriptOnly(address _address) {
        require(accessRestriction.isScript(_address), "caller is not script!");
        _;
    }

    function addService(
        address _service,
        string calldata _infoHash,
        address _submitter
    ) external isScriptOnly(msg.sender) {
        Service storage serviceData = services[_service];
        require(
            serviceData.submiter == address(0),
            "service already submitted"
        );
        serviceData.info = _infoHash;
        serviceData.submiter = _submiter;
        serviceData.exists = true;

        emit ServiceAdded(_service, _submiter, _infoHash);
    }
}
