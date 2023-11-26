// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

interface IAccessRestriction is IAccessControl {
    function giveUserRole(address _to) external;
}
