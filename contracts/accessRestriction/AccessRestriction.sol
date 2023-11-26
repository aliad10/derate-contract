// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import "./IAccessRestriction.sol";

contract AccessRestriction is AccessControl, IAccessRestriction {
    bytes32 public constant USER_ROLE = keccak256("USER");
    bytes32 public constant SCRIPT_ROLE = keccak256("SCRIPT");

    constructor(address _script) {
        _grantRole(SCRIPT_ROLE, _script);
    }

    function giveUserRole(address _to) external onlyRole(SCRIPT_ROLE) {
        _grantRole(USER_ROLE, _to);
    }
}
